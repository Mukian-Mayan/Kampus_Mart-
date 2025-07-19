// Enhanced Firebase Service with Supabase Storage Integration
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:typed_data';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Uuid _uuid = const Uuid();
  
  // Supabase client
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get Firestore instance
  static FirebaseFirestore get firestore => _firestore;

  // Get Auth instance
  static FirebaseAuth get auth => _auth;

  // Get Storage instance (Firebase - for backward compatibility)
  static FirebaseStorage get storage => _storage;

  // Get Supabase client
  static SupabaseClient get supabase => _supabase;

  // Get UUID generator
  static Uuid get uuid => _uuid;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  // Upload product image to Supabase Storage
  static Future<String> uploadProductImage(
    File imageFile,
    String userId,
    String fileName,
  ) async {
    try {
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();
      
      // Create file path in Supabase storage
      final filePath = 'products/$userId/$fileName.jpg';
      
      // Upload to Supabase storage
      await _supabase.storage
          .from('product-images') // Your bucket name
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from('product-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Supabase: $e');
    }
  }

  // Upload multiple product images to Supabase
  static Future<List<String>> uploadMultipleProductImages(
    List<File> imageFiles,
    String userId,
  ) async {
    try {
      List<String> imageUrls = [];
      
      for (int i = 0; i < imageFiles.length; i++) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i';
        String imageUrl = await uploadProductImage(
          imageFiles[i],
          userId,
          fileName,
        );
        imageUrls.add(imageUrl);
      }
      
      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload multiple images: $e');
    }
  }

  // Delete image from Supabase Storage
  static Future<void> deleteProductImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('product-images');
      
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        
        await _supabase.storage
            .from('product-images')
            .remove([filePath]);
      }
    } catch (e) {
      throw Exception('Failed to delete image from Supabase: $e');
    }
  }

  // Upload user profile image to Supabase
  static Future<String> uploadUserProfileImage(
    File imageFile,
    String userId,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final filePath = 'profiles/$userId/avatar.jpg';
      
      await _supabase.storage
          .from('user-profiles')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final publicUrl = _supabase.storage
          .from('user-profiles')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Upload from bytes (useful for web or when you have Uint8List)
  static Future<String> uploadImageFromBytes(
    Uint8List bytes,
    String bucketName,
    String filePath,
    String contentType,
  ) async {
    try {
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

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
      final signedUrl = await _supabase.storage
          .from(bucketName)
          .createSignedUrl(filePath, expiresInSeconds);
      
      return signedUrl;
    } catch (e) {
      throw Exception('Failed to get signed URL: $e');
    }
  }

  // List files in a bucket (useful for management)
  static Future<List<FileObject>> listFiles(
    String bucketName,
    String path,
  ) async {
    try {
      final files = await _supabase.storage
          .from(bucketName)
          .list(path: path);
      
      return files;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}