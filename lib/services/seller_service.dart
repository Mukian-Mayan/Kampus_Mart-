// services/seller_service.dart
// ignore_for_file: prefer_interpolation_to_compose_strings, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/seller.dart';
import 'supabase_storage_service.dart';

class SellerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'sellers';

  /// Register a new seller
  static Future<Seller> registerSeller({
    required String email,
    required String password,
    required String name,
    required String businessName,
    required String businessDescription,
    required String businessLocation,
    String? phone,
    XFile? profileImage,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String userId = userCredential.user!.uid;
      String? profileImageUrl;

      // Upload profile image if provided
      if (profileImage != null) {
        profileImageUrl = await SupabaseStorageService.uploadProfileImage(
          profileImage,
          userId,
        );
      }

      // Create seller document
      final Seller seller = Seller(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
        businessName: businessName,
        businessDescription: businessDescription,
        businessLocation: businessLocation,
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stats: SellerStats(),
      );

      // Save to Firestore
      await _firestore
          .collection(_collection)
          .doc(userId)
          .set(seller.toJson());

      return seller;
    } catch (e) {
      throw Exception('Failed to register seller: $e');
    }
  }

  /// Login seller
  static Future<Seller> loginSeller({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String userId = userCredential.user!.uid;
      return await getSellerById(userId);
    } catch (e) {
      throw Exception('Failed to login seller: $e');
    }
  }

  /// Get seller by ID
  static Future<Seller> getSellerById(String sellerId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(sellerId)
          .get();

      if (!doc.exists) {
        throw Exception('Seller not found');
      }

      return Seller.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get seller: $e');
    }
  }

  /// Get current seller
  static Future<Seller?> getCurrentSeller() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      return await getSellerById(user.uid);
    } catch (e) {
      return null;
    }
  }

  /// Update seller profile
  static Future<Seller> updateSellerProfile({
    required String sellerId,
    String? name,
    String? phone,
    String? businessName,
    String? businessDescription,
    String? businessLocation,
    XFile? profileImage,
  }) async {
    try {
      final Seller currentSeller = await getSellerById(sellerId);
      String? profileImageUrl = currentSeller.profileImageUrl;

      // Upload new profile image if provided
      if (profileImage != null) {
        profileImageUrl = await SupabaseStorageService.uploadProfileImage(
          profileImage,
          sellerId,
        );
      }

      final Seller updatedSeller = currentSeller.copyWith(
        name: name ?? currentSeller.name,
        phone: phone ?? currentSeller.phone,
        businessName: businessName ?? currentSeller.businessName,
        businessDescription: businessDescription ?? currentSeller.businessDescription,
        businessLocation: businessLocation ?? currentSeller.businessLocation,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(sellerId)
          .update(updatedSeller.toJson());

      return updatedSeller;
    } catch (e) {
      throw Exception('Failed to update seller profile: $e');
    }
  }

  /// Update seller stats
  static Future<void> updateSellerStats({
    required String sellerId,
    SellerStats? stats,
    int? totalProducts,
    int? totalOrders,
    int? completedOrders,
    int? pendingOrders,
    double? totalRevenue,
    double? monthlyRevenue,
    double? rating,
    int? totalReviews, required int cancelledOrders,
  }) async {
    try {
      final Seller currentSeller = await getSellerById(sellerId);
      
      final SellerStats updatedStats = stats ?? currentSeller.stats.copyWith(
        totalProducts: totalProducts ?? currentSeller.stats.totalProducts,
        totalOrders: totalOrders ?? currentSeller.stats.totalOrders,
        completedOrders: completedOrders ?? currentSeller.stats.completedOrders,
        pendingOrders: pendingOrders ?? currentSeller.stats.pendingOrders,
        totalRevenue: totalRevenue ?? currentSeller.stats.totalRevenue,
        monthlyRevenue: monthlyRevenue ?? currentSeller.stats.monthlyRevenue,
        rating: rating ?? currentSeller.stats.rating,
        totalReviews: totalReviews ?? currentSeller.stats.totalReviews,
      );

      await _firestore
          .collection(_collection)
          .doc(sellerId)
          .update({
            'stats': updatedStats.toJson(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update seller stats: $e');
    }
  }

  /// Verify seller
  static Future<void> verifySeller(String sellerId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(sellerId)
          .update({
            'isVerified': true,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to verify seller: $e');
    }
  }

  /// Get all sellers (admin function)
  static Future<List<Seller>> getAllSellers({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => Seller.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sellers: $e');
    }
  }

  /// Search sellers
  static Future<List<Seller>> searchSellers({
    required String query,
    int limit = 20,
  }) async {
    try {
      // Search by name
      final QuerySnapshot nameResults = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .limit(limit)
          .get();

      // Search by business name
      final QuerySnapshot businessResults = await _firestore
          .collection(_collection)
          .where('businessName', isGreaterThanOrEqualTo: query)
          .where('businessName', isLessThan: query + '\uf8ff')
          .limit(limit)
          .get();

      // Combine results and remove duplicates
      final Set<String> addedIds = {};
      final List<Seller> sellers = [];

      for (var doc in [...nameResults.docs, ...businessResults.docs]) {
        final seller = Seller.fromJson(doc.data() as Map<String, dynamic>);
        if (!addedIds.contains(seller.id)) {
          sellers.add(seller);
          addedIds.add(seller.id);
        }
      }

      return sellers;
    } catch (e) {
      throw Exception('Failed to search sellers: $e');
    }
  }

  /// Get sellers by location
  static Future<List<Seller>> getSellersByLocation({
    required String location,
    int limit = 20,
  }) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('businessLocation', isEqualTo: location)
          .where('isVerified', isEqualTo: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Seller.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sellers by location: $e');
    }
  }

  /// Delete seller account
  static Future<void> deleteSeller(String sellerId) async {
    try {
      // Delete from Firestore
      await _firestore
          .collection(_collection)
          .doc(sellerId)
          .delete();

      // Delete from Firebase Auth
      final User? user = _auth.currentUser;
      if (user != null && user.uid == sellerId) {
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete seller: $e');
    }
  }

  /// Sign out seller
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Listen to seller changes
  static Stream<Seller?> sellerStream(String sellerId) {
    return _firestore
        .collection(_collection)
        .doc(sellerId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return Seller.fromJson(snapshot.data() as Map<String, dynamic>);
        });
  }

  /// Get seller dashboard stats
  static Future<Map<String, dynamic>> getSellerDashboardStats(String sellerId) async {
    try {
      final Seller seller = await getSellerById(sellerId);
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      // Get orders from orders collection (you'll need to implement OrderService)
      // This is a placeholder for the actual implementation
      final Map<String, dynamic> orderStats = {
        'todayOrders': 0,
        'weeklyOrders': 0,
        'monthlyOrders': 0,
        'todayRevenue': 0.0,
        'weeklyRevenue': 0.0,
        'monthlyRevenue': seller.stats.monthlyRevenue,
      };

      return {
        'seller': seller,
        'stats': seller.stats,
        'orderStats': orderStats,
        'recentActivity': [], // Implement based on your needs
      };
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }
}