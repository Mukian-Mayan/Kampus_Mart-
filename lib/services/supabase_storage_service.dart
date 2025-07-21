// services/supabase_storage_service.dart
// ignore_for_file: avoid_print, depend_on_referenced_packages, unused_import

import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class SupabaseStorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Storage bucket names
  static const String chatImagesBucket = 'chat-images';
  static const String profileImagesBucket = 'profile-images';
  static const String productImagesBucket = 'product-images';

  /// Upload image to Supabase Storage
  /// 
  /// [bucketName] - The name of the storage bucket
  /// [file] - The XFile to upload
  /// [folderPath] - Optional folder path within the bucket
  /// [fileName] - Optional custom filename (will generate if not provided)
  /// 
  /// Returns the public URL of the uploaded image
  static Future<String> uploadImage({
    required String bucketName,
    required XFile file,
    String? folderPath,
    String? fileName,
  }) async {
    try {
      // Generate unique filename if not provided
      fileName ??= '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      
      // Construct full path
      String fullPath = folderPath != null ? '$folderPath/$fileName' : fileName;
      
      // Read file as bytes
      final Uint8List fileBytes = await file.readAsBytes();
      
      // Determine content type
      String contentType = _getContentType(file.path);
      
      // Upload to Supabase Storage
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            fullPath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fullPath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
  // In your SupabaseStorageService class
static Future<void> initializeBuckets() async {
  await Future.wait([
    createBucket(bucketName: chatImagesBucket, isPublic: false),
    createBucket(bucketName: profileImagesBucket, isPublic: false),
    createBucket(bucketName: productImagesBucket, isPublic: true),
  ]);
}

  /// Upload chat image
  static Future<String> uploadChatImage(XFile image, [String? s]) async {
    return await uploadImage(
      bucketName: chatImagesBucket,
      file: image,
      folderPath: 'chats',
    );
  }
  

  /// Upload profile image
  static Future<String> uploadProfileImage(XFile image, String userId) async {
    return await uploadImage(
      bucketName: profileImagesBucket,
      file: image,
      folderPath: 'profiles',
      fileName: '$userId.jpg',
    );
  }

  /// Upload product image
  static Future<String> uploadProductImage(XFile image, String productId) async {
    return await uploadImage(
      bucketName: productImagesBucket,
      file: image,
      folderPath: 'products',
      fileName: '${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  /// Upload multiple images
  static Future<List<String>> uploadMultipleImages({
    required String bucketName,
    required List<XFile> files,
    String? folderPath,
  }) async {
    List<String> uploadedUrls = [];
    
    for (XFile file in files) {
      try {
        String url = await uploadImage(
          bucketName: bucketName,
          file: file,
          folderPath: folderPath,
        );
        uploadedUrls.add(url);
      } catch (e) {
        // Log error but continue with other files
        print('Failed to upload ${file.name}: $e');
      }
    }
    
    return uploadedUrls;
  }

  /// Delete image from storage
  static Future<void> deleteImage({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await _supabase.storage
          .from(bucketName)
          .remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Delete chat image
  static Future<void> deleteChatImage(String imageUrl) async {
    try {
      String filePath = _extractFilePathFromUrl(imageUrl, chatImagesBucket);
      await deleteImage(
        bucketName: chatImagesBucket,
        filePath: filePath,
      );
    } catch (e) {
      throw Exception('Failed to delete chat image: $e');
    }
  }

  /// Get signed URL for private files (if needed)
  static Future<String> getSignedUrl({
    required String bucketName,
    required String filePath,
    int expiresInSeconds = 3600, // 1 hour default
  }) async {
    try {
      final String signedUrl = await _supabase.storage
          .from(bucketName)
          .createSignedUrl(filePath, expiresInSeconds);
      
      return signedUrl;
    } catch (e) {
      throw Exception('Failed to get signed URL: $e');
    }
  }

  /// Create storage bucket if it doesn't exist
  // Update in createBucket method
static Future<void> createBucket({
  required String bucketName,
  bool isPublic = true,
}) async {
  try {
    await _supabase.storage.createBucket(
      bucketName,
      BucketOptions(
        public: isPublic,
        allowedMimeTypes: [
          'image/jpeg', 
          'image/png', 
          'image/gif', 
          'image/webp',
          'audio/mpeg',
          'audio/wav',
          'audio/ogg',
          'application/pdf',
          'application/msword',
          'application/vnd.ms-excel',
          'application/vnd.ms-powerpoint',
          'application/zip'
        ],
        fileSizeLimit: (25 * 1024 * 1024).toString(), // Increased to 25MB for audio/files
      ),
    );
  } catch (e) {
    // Bucket might already exist
    print('Bucket creation info: $e');
  }
}

  /// List files in a bucket
  static Future<List<FileObject>> listFiles({
    required String bucketName,
    String? folderPath,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final List<FileObject> files = await _supabase.storage
          .from(bucketName)
          .list(
            path: folderPath,
            searchOptions: SearchOptions(
              limit: limit,
              offset: offset,
              sortBy: SortBy(
                column: 'created_at',
                order: 'desc',
              ),
            ),
          );
      
      return files;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// Get file info
  static Future<FileObject?> getFileInfo({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      final List<FileObject> files = await _supabase.storage
          .from(bucketName)
          .list(path: path.dirname(filePath));
      
      return files.firstWhere(
        (file) => file.name == path.basename(filePath),
        orElse: () => throw Exception('File not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Download file as bytes
  static Future<Uint8List> downloadFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      final Uint8List fileBytes = await _supabase.storage
          .from(bucketName)
          .download(filePath);
      
      return fileBytes;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  /// Move/rename file
  static Future<String> moveFile({
    required String bucketName,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await _supabase.storage
          .from(bucketName)
          .move(fromPath, toPath);
      
      // Return new public URL
      return _supabase.storage
          .from(bucketName)
          .getPublicUrl(toPath);
    } catch (e) {
      throw Exception('Failed to move file: $e');
    }
  }

  /// Copy file
  static Future<String> copyFile({
    required String bucketName,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await _supabase.storage
          .from(bucketName)
          .copy(fromPath, toPath);
      
      // Return new public URL
      return _supabase.storage
          .from(bucketName)
          .getPublicUrl(toPath);
    } catch (e) {
      throw Exception('Failed to copy file: $e');
    }
  }

  /// Update file (replace existing)
  static Future<String> updateFile({
    required String bucketName,
    required String filePath,
    required XFile newFile,
  }) async {
    try {
      // Read file as bytes
      final Uint8List fileBytes = await newFile.readAsBytes();
      
      // Determine content type
      String contentType = _getContentType(newFile.path);
      
      // Upload with upsert: true to replace existing
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to update file: $e');
    }
  }

  

  /// Get storage usage info
  static Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      int totalFiles = 0;
      int totalSize = 0;
      
      for (String bucket in [chatImagesBucket, profileImagesBucket, productImagesBucket]) {
        try {
          final List<FileObject> files = await listFiles(
            bucketName: bucket,
            limit: 1000,
          );
          
          totalFiles += files.length;
          totalSize += files.fold<int>(0, (sum, file) => sum + ((file.metadata?['size'] ?? 0) as int));
        } catch (e) {
          print('Error getting usage for bucket $bucket: $e');
        }
      }
      
      return {
        'totalFiles': totalFiles,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      throw Exception('Failed to get storage usage: $e');
    }
  }

  /// Helper method to get content type based on file extension
  // Update in supabase_storage_service.dart
static String _getContentType(String filePath) {
  final String extension = path.extension(filePath).toLowerCase();
  switch (extension) {
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.png':
      return 'image/png';
    case '.gif':
      return 'image/gif';
    case '.webp':
      return 'image/webp';
    case '.mp3':
    case '.m4a':
      return 'audio/mpeg';
    case '.wav':
      return 'audio/wav';
    case '.ogg':
      return 'audio/ogg';
    case '.pdf':
      return 'application/pdf';
    case '.doc':
    case '.docx':
      return 'application/msword';
    case '.xls':
    case '.xlsx':
      return 'application/vnd.ms-excel';
    case '.ppt':
    case '.pptx':
      return 'application/vnd.ms-powerpoint';
    case '.zip':
      return 'application/zip';
    default:
      return 'application/octet-stream';
  }
}

  /// Helper method to extract file path from public URL
  static String _extractFilePathFromUrl(String url, String bucketName) {
    try {
      final Uri uri = Uri.parse(url);
      final String pathSegments = uri.pathSegments.join('/');
      
      // Remove the bucket name and 'object' prefix from path
      final String bucketPrefix = 'storage/v1/object/public/$bucketName/';
      if (pathSegments.contains(bucketPrefix)) {
        return pathSegments.substring(pathSegments.indexOf(bucketPrefix) + bucketPrefix.length);
      }
      
      // Fallback: try to extract from the end of the URL
      final List<String> segments = uri.pathSegments;
      final int bucketIndex = segments.indexOf(bucketName);
      if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
        return segments.sublist(bucketIndex + 1).join('/');
      }
      
      throw Exception('Could not extract file path from URL');
    } catch (e) {
      throw Exception('Invalid URL format: $e');
    }
  }

  /// Validate file before upload
  static Future<bool> validateFile(XFile file) async {
    try {
      // Check file size (5MB limit)
      final int fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('File size exceeds 5MB limit');
      }
      
      // Check file type
      final String contentType = _getContentType(file.path);
      final List<String> allowedTypes = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp',
        'image/bmp',
      ];
      
      if (!allowedTypes.contains(contentType)) {
        throw Exception('File type not supported');
      }
      
      return true;
    } catch (e) {
      print('File validation error: $e');
      return false;
    }
  }

  /// Generate thumbnail URL (if you have image transformation service)
  static String getThumbnailUrl(String originalUrl, {int width = 200, int height = 200}) {
    // This is a placeholder for thumbnail generation
    // You would need to implement this based on your image transformation service
    // For example, using Supabase's image transformation or a third-party service
    return '$originalUrl?width=$width&height=$height';
  }

  /// Clean up old files (based on date)
  static Future<void> cleanupOldFiles({
    required String bucketName,
    required Duration olderThan,
    String? folderPath,
  }) async {
    try {
      final List<FileObject> files = await listFiles(
        bucketName: bucketName,
        folderPath: folderPath,
        limit: 1000,
      );
      
      final DateTime cutoffDate = DateTime.now().subtract(olderThan);
      final List<String> filesToDelete = [];
      
      for (FileObject file in files) {
        if (file.createdAt != null) {
          DateTime? fileDate;
          
          // Handle different date formats from Supabase
          if (file.createdAt is String) {
            try {
              fileDate = DateTime.parse(file.createdAt as String);
            } catch (e) {
              print('Error parsing date for file ${file.name}: $e');
              continue;
            }
          } else if (file.createdAt is DateTime) {
            fileDate = file.createdAt as DateTime;
          }
          
          if (fileDate != null && fileDate.isBefore(cutoffDate)) {
            String filePath = folderPath != null ? '$folderPath/${file.name}' : file.name;
            filesToDelete.add(filePath);
          }
        }
      }
      
      if (filesToDelete.isNotEmpty) {
        await _supabase.storage
            .from(bucketName)
            .remove(filesToDelete);
        
        print('Cleaned up ${filesToDelete.length} old files from $bucketName');
      }
    } catch (e) {
      throw Exception('Failed to cleanup old files: $e');
    }
  }
  // Add to SupabaseStorageService class in supabase_storage_service.dart

/// Upload voice message to Supabase Storage
Future<String> uploadVoiceMessage(
  String filePath,
  String storagePath,
) async {
  try {
    final file = File(filePath);
    final fileName = path.basename(filePath);
    final fullPath = '$storagePath/$fileName';

    // Read file as bytes
    final Uint8List fileBytes = await file.readAsBytes();

    // Upload to Supabase Storage
    await _supabase.storage
        .from(chatImagesBucket) // Using same bucket as chat images
        .uploadBinary(
          fullPath,
          fileBytes,
          fileOptions: FileOptions(
            contentType: 'audio/mpeg', // or appropriate audio type
            upsert: false,
          ),
        );

    // Get public URL
    return _supabase.storage
        .from(chatImagesBucket)
        .getPublicUrl(fullPath);
  } catch (e) {
    throw Exception('Failed to upload voice message: $e');
  }
}

/// Upload chat file to Supabase Storage
Future<String> uploadChatFile(
  XFile file,
  String storagePath,
) async {
  try {
    // Generate unique filename
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.name)}';
    final fullPath = '$storagePath/$fileName';

    // Read file as bytes
    final Uint8List fileBytes = await file.readAsBytes();

    // Determine content type
    String contentType = _getContentType(file.path);

    // Upload to Supabase Storage
    await _supabase.storage
        .from(chatImagesBucket) // Using same bucket as chat images
        .uploadBinary(
          fullPath,
          fileBytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: false,
          ),
        );

    // Get public URL
    return _supabase.storage
        .from(chatImagesBucket)
        .getPublicUrl(fullPath);
  } catch (e) {
    throw Exception('Failed to upload chat file: $e');
  }
}
}
