// Product Service for Kmart E-commerce App

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kampusmart2/models/models.dart';
import 'firebase_base_service.dart';

class ProductService extends FirebaseService {
  static const String _collection = 'products';

  // Add new product
  static Future<String> addProduct(Product product, {
    required String name,
    required String description,
    required String category,
    required double price,
    required int stockQuantity,
    required List<File> imageFiles,
    List<String> tags = const [],
    Map<String, dynamic>? specifications,
  }) async {
    try {
      if (!FirebaseService.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      // Upload images first
      List<String> imageUrls = await _uploadProductImages(imageFiles);

      // Create product document
      final productId = FirebaseService.uuid.v4();
      final now = DateTime.now();
      
      final product = Product(
        id: productId,
        sellerId: FirebaseService.currentUserId!,
        name: name,
        description: description,
        category: category,
        price: price,
        stockQuantity: stockQuantity,
        imageUrls: imageUrls,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        tags: tags,
        specifications: specifications, stock: 0, rating: 0, reviewCount: 0,
      );

      await FirebaseService.firestore.collection(_collection).doc(productId).set(product.toMap());

      return productId;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Get seller's products
  static Future<List<Product>> getSellerProducts({String? sellerId}) async {
    try {
      final String targetSellerId = sellerId ?? FirebaseService.currentUserId!;
      
      final querySnapshot = await FirebaseService.firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: targetSellerId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  // Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all products: $e');
    }
  }

  // Get product by ID
  static Future<Product?> getProductById(String productId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection(_collection)
          .doc(productId)
          .get();

      if (doc.exists) {
        return Product.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Update product
  static Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now();
      await FirebaseService.firestore.collection(_collection).doc(productId).update(updates);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product (soft delete)
  static Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseService.firestore.collection(_collection).doc(productId).update({
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Update product stock
  static Future<void> updateStock(String productId, int newStock) async {
    try {
      await updateProduct(productId, {'stockQuantity': newStock});
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  // Increment product views
  static Future<void> incrementViews(String productId) async {
    try {
      await FirebaseService.firestore.collection(_collection).doc(productId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment views: $e');
    }
  }

  // Toggle product like
  static Future<void> toggleLike(String productId) async {
    try {
      await FirebaseService.firestore.collection(_collection).doc(productId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Upload product images
  static Future<List<String>> _uploadProductImages(List<File> imageFiles) async {
    List<String> imageUrls = [];
    
    for (File imageFile in imageFiles) {
      try {
        final fileName = '${FirebaseService.uuid.v4()}.jpg';
        final ref = FirebaseService.storage.ref().child('products').child(fileName);
        
        final uploadTask = ref.putFile(imageFile);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        imageUrls.add(downloadUrl);
      } catch (e) {
        throw Exception('Failed to upload image: $e');
      }
    }
    
    return imageUrls;
  }

  // Search products
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .where((product) => 
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()) ||
              product.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Get featured products (most viewed/liked)
  static Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('views', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  // Get products with pagination
  static Future<List<Product>> getProductsWithPagination({
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String? category,
  }) async {
    try {
      Query query = FirebaseService.firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products with pagination: $e');
    }
  }
}