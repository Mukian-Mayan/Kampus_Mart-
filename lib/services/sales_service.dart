// ignore_for_file: avoid_print, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/seller.dart' hide Seller;
import '../models/sales_data.dart';

class SaleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current seller based on authenticated user
  static Future<Seller?> getCurrentSeller() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Check if current user is a seller
      final roleDoc = await _firestore
          .collection('user_roles')
          .doc(currentUser.uid)
          .get();

      if (!roleDoc.exists) {
        throw Exception('User role not found');
      }

      final roleData = roleDoc.data() as Map<String, dynamic>;
      if (roleData['role'] != 'seller') {
        throw Exception('Current user is not a seller');
      }

      // Get seller data
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(currentUser.uid)
          .get();

      if (!sellerDoc.exists) {
        throw Exception('Seller data not found');
      }

      return Seller.fromFirestore(sellerDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting current seller: $e');
      return null;
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
      // Get seller document to get current stats
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .get();

      if (!sellerDoc.exists) {
        throw Exception('Seller not found');
      }

      final sellerData = sellerDoc.data() as Map<String, dynamic>;
      final stats = sellerData['stats'] as Map<String, dynamic>? ?? {};

      // Get recent orders for additional stats
      final ordersQuery = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      List<Map<String, dynamic>> recentOrders = [];
      int pendingOrders = 0;
      int completedOrders = 0;

      for (var doc in ordersQuery.docs) {
        final orderData = doc.data();
        recentOrders.add(orderData);
        
        final status = orderData['status'] as String?;
        if (status == 'pending') {
          pendingOrders++;
        } else if (status == 'completed') {
          completedOrders++;
        }
      }

      // Get product count
      final productsQuery = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      return {
        'sellerStats': stats,
        'orderStats': {
          'recentOrders': recentOrders,
          'pendingOrders': pendingOrders,
          'completedOrders': completedOrders,
          'totalProducts': productsQuery.docs.length,
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