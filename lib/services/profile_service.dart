// services/profile_service.dart
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_role.dart';
import '../models/user_model.dart';
import '../models/seller.dart';
import 'user_service.dart';
import 'seller_service.dart';

class ProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user role
  static Future<UserRole?> getCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      print('ProfileService: Getting role for userId: ${user.uid}');

      // Check user_roles collection first
      final roleDoc = await _firestore
          .collection('user_roles')
          .doc(user.uid)
          .get();

      if (roleDoc.exists) {
        final roleData = roleDoc.data();
        final role = roleData?['role'] as String?;
        print('ProfileService: Role from user_roles collection: $role');

        switch (role) {
          case 'seller':
            return UserRole.seller;
          case 'buyer':
            return UserRole.buyer;
          default:
            print('ProfileService: Unknown role "$role", defaulting to buyer');
            return UserRole.buyer;
        }
      }

      // Fallback: check if user exists in sellers collection
      print(
        'ProfileService: No role document found, checking sellers collection...',
      );
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(user.uid)
          .get();

      final isSeller = sellerDoc.exists;
      print('ProfileService: User exists in sellers collection: $isSeller');

      return isSeller ? UserRole.seller : UserRole.buyer;
    } catch (e) {
      print('Error getting user role: $e');
      return UserRole.buyer;
    }
  }

  /// Get current user profile (buyer or seller)
  static Future<dynamic> getCurrentUserProfile() async {
    try {
      final userRole = await getCurrentUserRole();
      final userId = _auth.currentUser?.uid;

      if (userId == null) return null;

      if (userRole == UserRole.seller) {
        return await SellerService.getSellerById(userId);
      } else {
        return await UserService.getUserById(userId);
      }
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }

  /// Update profile image for current user
  static Future<bool> updateProfileImage(XFile imageFile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('ProfileService: No authenticated user found');
        return false;
      }

      print('ProfileService: Updating profile image for userId: $userId');
      final userRole = await getCurrentUserRole();
      print('ProfileService: User role: $userRole');

      if (userRole == UserRole.seller) {
        print('ProfileService: Updating seller profile image');
        final updatedSeller = await SellerService.updateSellerProfile(
          sellerId: userId,
          profileImage: imageFile,
        );
        final success = updatedSeller.profileImageUrl != null;
        print(
          'ProfileService: Seller update result - success: $success, imageUrl: ${updatedSeller.profileImageUrl}',
        );
        return success;
      } else {
        print('ProfileService: Updating user profile image');
        final updatedUser = await UserService.updateUserProfile(
          userId: userId,
          profileImage: imageFile,
        );
        final success = updatedUser?.profileImageUrl != null;
        print(
          'ProfileService: User update result - success: $success, imageUrl: ${updatedUser?.profileImageUrl}',
        );
        return success;
      }
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }

  /// Delete profile image for current user
  static Future<bool> deleteProfileImage() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final userRole = await getCurrentUserRole();

      if (userRole == UserRole.seller) {
        await SellerService.deleteProfileImage(userId);
      } else {
        await UserService.deleteProfileImage(userId);
      }

      return true;
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }

  /// Get current user profile image URL
  static Future<String?> getCurrentUserProfileImageUrl() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('ProfileService: No authenticated user found');
        return null;
      }

      print('ProfileService: Getting profile image URL for userId: $userId');
      final userRole = await getCurrentUserRole();
      print('ProfileService: User role: $userRole');

      if (userRole == UserRole.seller) {
        print('ProfileService: Getting seller profile image');
        final seller = await SellerService.getSellerById(userId);
        print('ProfileService: Seller image URL: ${seller.profileImageUrl}');
        return seller.profileImageUrl;
      } else {
        print('ProfileService: Getting user profile image');
        final user = await UserService.getUserById(userId);
        print('ProfileService: User image URL: ${user?.profileImageUrl}');
        return user?.profileImageUrl;
      }
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }

  /// Get user display name
  static Future<String?> getCurrentUserDisplayName() async {
    try {
      final profile = await getCurrentUserProfile();

      if (profile is Seller) {
        return profile.name;
      } else if (profile is UserModel) {
        return profile.displayName;
      }

      return null;
    } catch (e) {
      print('Error getting user display name: $e');
      return null;
    }
  }

  /// Get user email
  static Future<String?> getCurrentUserEmail() async {
    try {
      final profile = await getCurrentUserProfile();

      if (profile is Seller) {
        return profile.email;
      } else if (profile is UserModel) {
        return profile.email;
      }

      return null;
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  /// Update user display name
  static Future<bool> updateDisplayName(String displayName) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final userRole = await getCurrentUserRole();

      if (userRole == UserRole.seller) {
        await SellerService.updateSellerProfile(
          sellerId: userId,
          name: displayName,
        );
      } else {
        await UserService.updateUserProfile(
          userId: userId,
          displayName: displayName,
        );
      }

      return true;
    } catch (e) {
      print('Error updating display name: $e');
      return false;
    }
  }

  /// Update user phone number
  static Future<bool> updatePhoneNumber(String phoneNumber) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final userRole = await getCurrentUserRole();

      if (userRole == UserRole.seller) {
        await SellerService.updateSellerProfile(
          sellerId: userId,
          phone: phoneNumber,
        );
      } else {
        await UserService.updateUserProfile(
          userId: userId,
          phoneNumber: phoneNumber,
        );
      }

      return true;
    } catch (e) {
      print('Error updating phone number: $e');
      return false;
    }
  }
}
