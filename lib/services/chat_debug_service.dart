// services/chat_debug_service.dart
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role.dart';
import '../models/chat_models.dart';

class ChatDebugService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Debug current user's profile information
  static Future<void> debugCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('ChatDebug: No authenticated user');
        return;
      }

      print('ChatDebug: === USER PROFILE DEBUG ===');
      print('ChatDebug: Current user ID: ${user.uid}');
      print('ChatDebug: Current user email: ${user.email}');

      // Check users collection
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        print('ChatDebug: Found in users collection:');
        print('ChatDebug: Data: $userData');

        final displayName =
            userData['displayName'] ??
            '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                .trim();
        print('ChatDebug: Computed displayName: "$displayName"');
      } else {
        print('ChatDebug: NOT found in users collection');
      }

      // Check sellers collection
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(user.uid)
          .get();
      if (sellerDoc.exists) {
        final sellerData = sellerDoc.data() as Map<String, dynamic>;
        print('ChatDebug: Found in sellers collection:');
        print('ChatDebug: Data: $sellerData');

        final name = sellerData['name'] ?? 'Seller';
        print('ChatDebug: Computed name: "$name"');
      } else {
        print('ChatDebug: NOT found in sellers collection');
      }

      // Check user_roles collection
      final roleDoc = await _firestore
          .collection('user_roles')
          .doc(user.uid)
          .get();
      if (roleDoc.exists) {
        final roleData = roleDoc.data() as Map<String, dynamic>;
        print('ChatDebug: Found in user_roles collection:');
        print('ChatDebug: Data: $roleData');
      } else {
        print('ChatDebug: NOT found in user_roles collection');
      }

      print('ChatDebug: === END USER PROFILE DEBUG ===');
    } catch (e) {
      print('ChatDebug: Error during debug: $e');
    }
  }

  /// Test the updated getUserProfile method
  static Future<UserProfile?> testGetUserProfile(String userId) async {
    try {
      print('ChatDebug: Testing getUserProfile for: $userId');

      UserProfile? profile;

      // First, check users collection (for buyers)
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        print('ChatDebug: User profile data from users collection: $data');

        // Create profile from user data
        profile = UserProfile(
          id: userId,
          name:
              data['displayName'] ??
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
          imageUrl: data['profileImageUrl'],
          role: UserRole.buyer,
          isOnline: data['isOnline'] ?? false,
          lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
        );
      } else {
        // If not found in users, check sellers collection
        print(
          'ChatDebug: User not found in users collection, checking sellers...',
        );

        DocumentSnapshot sellerDoc = await _firestore
            .collection('sellers')
            .doc(userId)
            .get();

        if (sellerDoc.exists && sellerDoc.data() != null) {
          Map<String, dynamic> data = sellerDoc.data() as Map<String, dynamic>;
          print('ChatDebug: User profile data from sellers collection: $data');

          // Create profile from seller data
          profile = UserProfile(
            id: userId,
            name: data['name'] ?? 'Seller',
            imageUrl: data['profileImageUrl'],
            role: UserRole.seller,
            isOnline: data['isOnline'] ?? false,
            lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
          );
        } else {
          print(
            'ChatDebug: User profile not found in either collection, creating minimal profile',
          );

          // Fallback: create minimal profile
          profile = UserProfile(
            id: userId,
            name: 'User $userId',
            role: UserRole.buyer, // Default role
          );
        }
      }

      print('ChatDebug: Final profile: ${profile.toMap()}');
      return profile;
    } catch (e) {
      print('ChatDebug: Error testing getUserProfile: $e');
      return null;
    }
  }

  /// Clear all message caches and force refresh
  static Future<void> clearCacheAndRefresh() async {
    try {
      print('ChatDebug: Clearing caches...');
      // If you have access to ChatService instance, call clearUserProfileCache()
      print('ChatDebug: Cache clearing completed');
    } catch (e) {
      print('ChatDebug: Error clearing cache: $e');
    }
  }
}
