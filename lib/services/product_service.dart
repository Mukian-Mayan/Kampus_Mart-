// lib/services/product_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class ProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new product (matching your Product model)
  static Future<String> createProduct({
    required String name,
    required String description,
    required String priceAndDiscount,
    required String originalPrice,
    required String condition,
    required String location,
    required String imageUrl,
    List<String>? imageUrls,
    bool bestOffer = false,
    String? category,
    double? price,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      print('Creating product for user: ${user.uid}');

      // Verify user is a seller
      final roleDoc = await _firestore
          .collection('user_roles')
          .doc(user.uid)
          .get();

      if (!roleDoc.exists) {
        throw Exception('User role not found');
      }

      final roleData = roleDoc.data();
      final userRole = roleData?['role'] as String?;

      if (userRole != 'seller') {
        throw Exception('Only sellers can create products. Current role: $userRole');
      }

      // Create product data matching your model
      final productData = {
        'name': name.trim(),
        'description': description.trim(),
        'ownerId': user.uid, // Using ownerId as per your model
        'sellerId': user.uid, // Also adding sellerId for compatibility
        'priceAndDiscount': priceAndDiscount.trim(),
        'originalPrice': originalPrice.trim(),
        'condition': condition.trim(),
        'location': location.trim(),
        'rating': 0.0, // Default rating
        'imageUrl': imageUrl.trim(),
        'imageUrls': imageUrls ?? [],
        'bestOffer': bestOffer,
        'category': category?.trim(),
        'price': price,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('Product data to be created: $productData');

      // Add product to Firestore
      final docRef = await _firestore.collection('products').add(productData);
      
      print('Product created with ID: ${docRef.id}');

      // Update seller stats
      await _updateSellerProductCount(user.uid, 1);

      return docRef.id;
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  // Update seller product count
  static Future<void> _updateSellerProductCount(String sellerId, int increment) async {
    try {
      final sellerRef = _firestore.collection('sellers').doc(sellerId);
      
      await _firestore.runTransaction((transaction) async {
        final sellerDoc = await transaction.get(sellerRef);
        
        if (sellerDoc.exists) {
          final currentStats = sellerDoc.data()?['stats'] as Map<String, dynamic>? ?? {};
          final currentCount = (currentStats['totalProducts'] as num?)?.toInt() ?? 0;
          
          final updatedStats = {
            ...currentStats,
            'totalProducts': currentCount + increment,
          };
          
          transaction.update(sellerRef, {
            'stats': updatedStats,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
      
      print('Seller product count updated');
    } catch (e) {
      print('Error updating seller product count: $e');
      // Don't rethrow - product creation should still succeed
    }
  }

  // Get products by seller (using ownerId from your model)
  static Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('ownerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting products by seller: $e');
      return [];
    }
  }

  // Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  // Update product
  static Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      // Verify ownership
      final productDoc = await _firestore.collection('products').doc(productId).get();
      
      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      final productData = productDoc.data()!;
      final ownerId = productData['ownerId'] as String? ?? productData['sellerId'] as String?;

      if (ownerId != user.uid) {
        throw Exception('You can only update your own products');
      }

      // Update product
      await _firestore.collection('products').doc(productId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Product updated successfully');
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  // Delete product
  static Future<void> deleteProduct(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      // Verify ownership
      final productDoc = await _firestore.collection('products').doc(productId).get();
      
      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      final productData = productDoc.data()!;
      final ownerId = productData['ownerId'] as String? ?? productData['sellerId'] as String?;

      if (ownerId != user.uid) {
        throw Exception('You can only delete your own products');
      }

      // Delete product
      await _firestore.collection('products').doc(productId).delete();

      // Update seller stats
      await _updateSellerProductCount(user.uid, -1);

      print('Product deleted successfully');
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // Search products
  static Future<List<Product>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getAllProducts();
      }

      final querySnapshot = await _firestore
          .collection('products')
          .get();

      final allProducts = querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();

      // Filter products by name or description containing the query
      return allProducts.where((product) {
        final searchQuery = query.toLowerCase();
        return product.name.toLowerCase().contains(searchQuery) ||
               product.description.toLowerCase().contains(searchQuery) ||
               (product.category?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Get product by ID
  static Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      
      if (!doc.exists) {
        return null;
      }

      return Product.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }
}