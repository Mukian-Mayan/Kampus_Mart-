// services/storage_test_service.dart
// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageTestService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Test Firebase Storage permissions
  static Future<void> testStoragePermissions() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('StorageTest: No authenticated user');
        return;
      }

      print('StorageTest: Testing storage permissions for user: ${user.uid}');
      print('StorageTest: User email: ${user.email}');

      // Test different storage paths
      final paths = [
        'user_profile_images/${user.uid}/test.txt',
        'seller_profile_images/${user.uid}/test.txt',
        'profile_images/${user.uid}/test.txt',
        'images/${user.uid}/test.txt',
        'test/${user.uid}/test.txt',
      ];

      for (final path in paths) {
        await _testPath(path);
      }
    } catch (e) {
      print('StorageTest: Error testing storage permissions: $e');
    }
  }

  static Future<void> _testPath(String path) async {
    try {
      print('StorageTest: Testing path: $path');

      final ref = _storage.ref().child(path);
      final testData = Uint8List.fromList('test'.codeUnits);

      // Try to upload a small test file
      final uploadTask = await ref.putData(
        testData,
        SettableMetadata(contentType: 'text/plain'),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('StorageTest: ✅ SUCCESS for path: $path');
      print('StorageTest: Download URL: $downloadUrl');

      // Clean up - delete the test file
      await ref.delete();
      print('StorageTest: Test file deleted for path: $path');
    } catch (e) {
      print('StorageTest: ❌ FAILED for path: $path');
      print('StorageTest: Error: $e');
    }
  }

  /// Test basic Firebase auth status
  static Future<void> testAuthStatus() async {
    try {
      final user = _auth.currentUser;
      print('StorageTest: Auth Status:');
      print('  - User: ${user?.uid ?? 'null'}');
      print('  - Email: ${user?.email ?? 'null'}');
      print('  - Email Verified: ${user?.emailVerified ?? false}');
      print('  - Anonymous: ${user?.isAnonymous ?? false}');

      if (user != null) {
        final token = await user.getIdToken();
        print('  - Has ID Token: ${token != null && token.isNotEmpty}');
      }
    } catch (e) {
      print('StorageTest: Error getting auth status: $e');
    }
  }
}
