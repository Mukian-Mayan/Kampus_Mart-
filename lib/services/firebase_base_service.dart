// Enhanced Firebase Service with Supabase Storage Integration
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:typed_data';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Uuid _uuid = const Uuid();
  
  // Get Firestore instance
  static FirebaseFirestore get firestore => _firestore;

  // Get Auth instance
  static FirebaseAuth get auth => _auth;

  // Get Storage instance (Firebase - for backward compatibility)
  static FirebaseStorage get storage => _storage;

  // Get UUID generator
  static Uuid get uuid => _uuid;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  // Upload from bytes (useful for web or when you have Uint8List)
  static Future<String> uploadImageFromBytes(
    Uint8List bytes,
    String bucketName,
    String filePath,
    String contentType,
  ) async {
    try {
      await _storage
          .ref()
          .child(bucketName)
          .child(filePath)
          .putData(bytes);

      final publicUrl = await _storage
          .ref()
          .child(bucketName)
          .child(filePath)
          .getDownloadURL();

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image from bytes: $e');
    }
  }

  // Get signed URL for private files (if needed)
  static Future<String> getSignedUrl(
    String bucketName,
    String filePath,
    int expiresInSeconds,
  ) async {
    try {
      final signedUrl = await _storage
          .ref()
          .child(bucketName)
          .child(filePath)
          .getDownloadURL();
      
      return signedUrl;
    } catch (e) {
      throw Exception('Failed to get signed URL: $e');
    }
  }

  // List files in a bucket (useful for management)
  static Future<List<String>> listFiles(
    String bucketName,
    String path,
  ) async {
    try {
      final files = await _storage
          .ref()
          .child(bucketName)
          .child(path)
          .listAll();
      
      return files.items.map((item) => item.fullPath).toList();
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}