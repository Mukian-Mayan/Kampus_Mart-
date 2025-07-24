// ignore_for_file: avoid_print, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/seller.dart';
import '../models/sales_data.dart' hide Seller;

class SaleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current seller based on authenticated user
  static Future<Seller?> getCurrentSeller() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user found');
        throw Exception('No authenticated user found');
      }

      print('Getting seller data for user: ${currentUser.uid}');

      // First, check if the seller document exists directly
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(currentUser.uid)
          .get();

      if (!sellerDoc.exists) {
        print('Seller document not found for user: ${currentUser.uid}');
        throw Exception('Seller document not found in Firestore');
      }

      final sellerData = sellerDoc.data() as Map<String, dynamic>;
      print('Seller data found: $sellerData');

      // Check if current user is a seller in user_roles (optional check)
      try {
        final roleDoc = await _firestore
            .collection('user_roles')
            .doc(currentUser.uid)
            .get();

        if (roleDoc.exists) {
          final roleData = roleDoc.data() as Map<String, dynamic>;
          print('User role: ${roleData['role']}');
          
          if (roleData['role'] != 'seller') {
            print('User role is not seller: ${roleData['role']}');
            throw Exception('Current user is not a seller');
          }
        } else {
          print('No role document found, but seller document exists');
        }
      } catch (roleError) {
        print('Role check failed: $roleError');
        // Continue anyway if seller document exists
      }

      return Seller.fromFirestore(sellerData);
    } catch (e) {
      print('Error getting current seller: $e');
      throw e; // Re-throw to let the calling code handle it
    }
  }
  // Add this method to your SaleService class in sales_service.dart

// Fix product counts for all categories
static Future<bool> fixProductCounts() async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('fixProductCounts');
    final result = await callable.call();
    
    print('Product counts fixed: ${result.data}');
    return result.data['success'] == true;
  } catch (e) {
    print('Error fixing product counts: $e');
    return false;
  }
}

  // Get seller by ID
  static Future<Seller?> getSellerById(String sellerId) async {
    try {
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .get();

      if (!sellerDoc.exists) {
        return null;
      }

      return Seller.fromFirestore(sellerDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting seller by ID: $e');
      return null;
    }
  }

  // Update seller profile
  static Future<bool> updateSellerProfile(Seller seller) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(seller.id)
          .update({
        'name': seller.name,
        'businessName': seller.businessName,
        'businessDescription': seller.businessDescription,
        'phoneNumber': seller.number,
        'profileImageUrl': seller.profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating seller profile: $e');
      return false;
    }
  }

  // Get seller dashboard stats
  static Future<Map<String, dynamic>> getSellerDashboardStats(String sellerId) async {
    try {
      print('Getting dashboard stats for seller: $sellerId');
      
      // Get seller document to get current stats
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .get();

      if (!sellerDoc.exists) {
        throw Exception('Seller not found');
      }

      final sellerData = sellerDoc.data() as Map<String, dynamic>;
      final stats = sellerData['stats'] as Map<String, dynamic>? ?? {
        'totalProducts': 0,
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'rating': 0.0,
        'totalReviews': 0,
      };

      // Get recent orders for additional stats
      List<Map<String, dynamic>> recentOrders = [];
      int pendingOrders = 0;
      int completedOrders = 0;

      try {
        final ordersQuery = await _firestore
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId)
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();

        for (var doc in ordersQuery.docs) {
          final orderData = doc.data();
          orderData['id'] = doc.id; // Add document ID
          recentOrders.add(orderData);
          
          final status = orderData['status'] as String?;
          if (status == 'pending') {
            pendingOrders++;
          } else if (status == 'completed') {
            completedOrders++;
          }
        }
      } catch (orderError) {
        print('Error getting orders: $orderError');
        // Continue with empty orders
      }

      // Get product count
      int totalProducts = 0;
      try {
        final productsQuery = await _firestore
            .collection('products')
            .where('sellerId', isEqualTo: sellerId)
            .get();
        totalProducts = productsQuery.docs.length;
      } catch (productError) {
        print('Error getting products: $productError');
      }

      return {
        'sellerStats': stats,
        'orderStats': {
          'recentOrders': recentOrders,
          'pendingOrders': pendingOrders,
          'completedOrders': completedOrders,
          'totalProducts': totalProducts,
        },
      };
    } catch (e) {
      print('Error getting seller dashboard stats: $e');
      return {
        'sellerStats': {
          'totalProducts': 0,
          'totalOrders': 0,
          'totalRevenue': 0.0,
          'rating': 0.0,
          'totalReviews': 0,
        },
        'orderStats': {
          'recentOrders': [],
          'pendingOrders': 0,
          'completedOrders': 0,
          'totalProducts': 0,
        },
      };
    }
  }

  // Update seller stats
  static Future<bool> updateSellerStats(String sellerId, Map<String, dynamic> stats) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(sellerId)
          .update({
        'stats': stats,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating seller stats: $e');
      return false;
    }
  }

  // Check if current user is a seller
  static Future<bool> isCurrentUserSeller() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // First check if seller document exists
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(currentUser.uid)
          .get();

      if (sellerDoc.exists) {
        return true;
      }

      // Fallback to role check
      final roleDoc = await _firestore
          .collection('user_roles')
          .doc(currentUser.uid)
          .get();

      if (!roleDoc.exists) return false;

      final roleData = roleDoc.data() as Map<String, dynamic>;
      return roleData['role'] == 'seller';
    } catch (e) {
      print('Error checking if user is seller: $e');
      return false;
    }
  }

  // Verify seller account
  static Future<bool> verifySellerAccount(String sellerId) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(sellerId)
          .update({
        'isVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error verifying seller account: $e');
      return false;
    }
  }

  // Get all sellers (for admin purposes)
  static Future<List<Seller>?> getAllSellers() async {
    try {
      final sellersQuery = await _firestore
          .collection('sellers')
          .get();

      List<Seller> sellers = [];
      for (var doc in sellersQuery.docs) {
        sellers.add(Seller.fromFirestore(doc.data()));
      }

      return sellers;
    } catch (e) {
      print('Error getting all sellers: $e');
      return null;
    }
  }

  // Sign out seller
  static Future<void> signOutSeller() async {
    try {
      await _auth.signOut();
      
    } catch (e) {
      print('Error signing out seller: $e');
      rethrow;
    }
  }
}