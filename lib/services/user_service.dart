// services/user_service.dart
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _usersCollection = 'users';
  static const String _profileImagesPath = 'profile_images';

  /// Upload profile image to Firebase Storage
  static Future<String?> _uploadProfileImage(
    XFile imageFile,
    String userId,
  ) async {
    try {
      print('UserService: Starting image upload for userId: $userId');
      print('UserService: Image file path: ${imageFile.path}');

      // Read image data
      final imageData = await imageFile.readAsBytes();
      print('UserService: Image data size: ${imageData.length} bytes');

      // Create a reference to the file location
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final Reference storageRef = _storage.ref().child(
        '$_profileImagesPath/$userId/$timestamp.jpg',
      );

      print('UserService: Storage reference path: ${storageRef.fullPath}');

      // Upload the file
      final TaskSnapshot uploadTask = await storageRef.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      print('UserService: Upload completed, getting download URL...');

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('UserService: Download URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('UserService: Error uploading profile image: $e');

      // Check if it's a permission error
      if (e.toString().contains('unauthorized') ||
          e.toString().contains('Permission denied')) {
        print(
          'UserService: PERMISSION ERROR - Firebase Storage rules need to be updated',
        );
        print('UserService: Please check Firebase Console > Storage > Rules');
        throw Exception(
          'Permission denied: Firebase Storage rules need to allow authenticated users to upload to profile_images/{userId}/',
        );
      }

      return null;
    }
  }

  /// Get current user
  static Future<UserModel?> getCurrentUser() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      return await getUserById(user.uid);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Get user by ID
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<UserModel?> updateUserProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? address,
    XFile? profileImage,
  }) async {
    try {
      print('UserService: Starting profile update for userId: $userId');

      final currentUser = await getUserById(userId);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      String? profileImageUrl = currentUser.profileImageUrl;
      print('UserService: Current profile image URL: $profileImageUrl');

      // Upload new profile image if provided
      if (profileImage != null) {
        print('UserService: Uploading new profile image...');

        // Delete old image if exists
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          try {
            final oldRef = _storage.refFromURL(profileImageUrl);
            await oldRef.delete();
            print('UserService: Deleted old profile image');
          } catch (e) {
            print('Error deleting old image: $e');
          }
        }

        profileImageUrl = await _uploadProfileImage(profileImage, userId);
        print('UserService: New profile image URL: $profileImageUrl');

        if (profileImageUrl == null) {
          throw Exception('Failed to upload profile image');
        }
      }

      // Update user document
      final updatedData = {
        'displayName': displayName ?? currentUser.displayName,
        'phoneNumber': phoneNumber ?? currentUser.phoneNumber,
        'address': address ?? currentUser.address,
        'profileImageUrl': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('UserService: Updating user document with data: $updatedData');

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(updatedData);

      print('UserService: Successfully updated user document');

      // Return updated user
      final updatedUser = await getUserById(userId);
      print(
        'UserService: Retrieved updated user with image URL: ${updatedUser?.profileImageUrl}',
      );

      return updatedUser;
    } catch (e) {
      print('UserService: Error updating profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Delete profile image from storage
  static Future<void> deleteProfileImage(String userId) async {
    try {
      final user = await getUserById(userId);

      if (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty) {
        // Delete from storage
        final ref = _storage.refFromURL(user.profileImageUrl!);
        await ref.delete();

        // Update user document to remove image URL
        await _firestore.collection(_usersCollection).doc(userId).update({
          'profileImageUrl': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to delete profile image: $e');
    }
  }

  /// Get user profile image URL
  static Future<String?> getUserProfileImageUrl(String userId) async {
    try {
      final user = await getUserById(userId);
      return user?.profileImageUrl;
    } catch (e) {
      print('Error getting user profile image URL: $e');
      return null;
    }
  }

  /// Check if current user is authenticated
  static bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
