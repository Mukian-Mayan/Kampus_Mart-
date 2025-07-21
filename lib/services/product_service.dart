// Fixed lib/services/product_service.dart
// ignore_for_file: avoid_print

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
    int? stock,
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
      if (roleData?['role'] != 'seller') {
        throw Exception('User is not authorized to create products');
      }

      // Create product document
      final productData = {
        'name': name,
        'description': description,
        'priceAndDiscount': priceAndDiscount,
        'originalPrice': originalPrice,
        'condition': condition,
        'location': location,
        'imageUrl': imageUrl,
        'imageUrls': imageUrls ?? [imageUrl],
        'bestOffer': bestOffer,
        'category': category,
        'price': price,
        'stock': stock ?? 0,
        'sellerId': user.uid,
        'sellerName': user.displayName ?? 'Unknown Seller',
        'sellerEmail': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'views': 0,
        'favorites': 0,
      };

      print('Product data: $productData');

      final docRef = await _firestore.collection('products').add(productData);
      
      print('Product created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating product: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  // Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Get products by seller ID
  static Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching seller products: $e');
      throw Exception('Failed to fetch seller products: $e');
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  // Search products
  static Future<List<Product>> searchProducts(String query) async {
    try {
      // Firestore doesn't have full-text search, so we'll use array-contains-any
      // or implement a simple name/description search
      final List<String> searchTerms = query.toLowerCase().split(' ');
      
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      final List<Product> allProducts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromFirestore(data, doc.id);
      }).toList();

      // Filter products based on search query
      return allProducts.where((product) {
        final productText = '${product.name} ${product.description}'.toLowerCase();
        return searchTerms.any((term) => productText.contains(term));
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      throw Exception('Failed to search products: $e');
    }
  }

  // Get product by ID
  static Future<Product?> getProductById(String productId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return Product.fromFirestore(data, doc.id);
    } catch (e) {
      print('Error fetching product: $e');
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Update product
  static Future<void> updateProduct({
    required String productId,
    String? name,
    String? description,
    String? priceAndDiscount,
    String? originalPrice,
    String? condition,
    String? location,
    String? imageUrl,
    List<String>? imageUrls,
    bool? bestOffer,
    String? category,
    double? price,
    int? stock,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      // Verify ownership
      final productDoc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      final productData = productDoc.data()!;
      if (productData['sellerId'] != user.uid) {
        throw Exception('Not authorized to update this product');
      }

      // Prepare update data
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (priceAndDiscount != null) updateData['priceAndDiscount'] = priceAndDiscount;
      if (originalPrice != null) updateData['originalPrice'] = originalPrice;
      if (condition != null) updateData['condition'] = condition;
      if (location != null) updateData['location'] = location;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (imageUrls != null) updateData['imageUrls'] = imageUrls;
      if (bestOffer != null) updateData['bestOffer'] = bestOffer;
      if (category != null) updateData['category'] = category;
      if (price != null) updateData['price'] = price;
      if (stock != null) updateData['stock'] = stock;

      await _firestore.collection('products').doc(productId).update(updateData);
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product (soft delete)
  static Future<void> deleteProduct(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      // Verify ownership
      final productDoc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      final productData = productDoc.data()!;
      if (productData['sellerId'] != user.uid) {
        throw Exception('Not authorized to delete this product');
      }

      // Soft delete by setting isActive to false
      await _firestore.collection('products').doc(productId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  // Permanently delete product
  static Future<void> permanentlyDeleteProduct(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      // Verify ownership
      final productDoc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      final productData = productDoc.data()!;
      if (productData['sellerId'] != user.uid) {
        throw Exception('Not authorized to delete this product');
      }

      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error permanently deleting product: $e');
      throw Exception('Failed to permanently delete product: $e');
    }
  }

  // Increment product views
  static Future<void> incrementViews(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
      // Don't throw error for this non-critical operation
    }
  }

  // Toggle favorite
  static Future<void> toggleFavorite(String productId, bool isFavorite) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      final userFavoritesRef = _firestore
          .collection('user_favorites')
          .doc(user.uid);

      if (isFavorite) {
        // Add to favorites
        await userFavoritesRef.set({
          'productIds': FieldValue.arrayUnion([productId])
        }, SetOptions(merge: true));
        
        // Increment product favorites count
        await _firestore.collection('products').doc(productId).update({
          'favorites': FieldValue.increment(1),
        });
      } else {
        // Remove from favorites
        await userFavoritesRef.update({
          'productIds': FieldValue.arrayRemove([productId])
        });
        
        // Decrement product favorites count
        await _firestore.collection('products').doc(productId).update({
          'favorites': FieldValue.increment(-1),
        });
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // Get user favorites
  static Future<List<Product>> getUserFavorites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      final userFavoritesDoc = await _firestore
          .collection('user_favorites')
          .doc(user.uid)
          .get();

      if (!userFavoritesDoc.exists) {
        return [];
      }

      final List<String> productIds = List<String>.from(
        userFavoritesDoc.data()?['productIds'] ?? []
      );

      if (productIds.isEmpty) {
        return [];
      }

      // Fetch favorite products
      final List<Product> favoriteProducts = [];
      
      // Firestore has a limit of 10 items for 'in' queries
      for (int i = 0; i < productIds.length; i += 10) {
        final batch = productIds.skip(i).take(10).toList();
        
        final QuerySnapshot snapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batch)
            .where('isActive', isEqualTo: true)
            .get();

        favoriteProducts.addAll(
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Product.fromFirestore(data, doc.id);
          })
        );
      }

      return favoriteProducts;
    } catch (e) {
      print('Error fetching user favorites: $e');
      throw Exception('Failed to fetch user favorites: $e');
    }
  }

  // Check if product is favorited by current user
  static Future<bool> isProductFavorited(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      final userFavoritesDoc = await _firestore
          .collection('user_favorites')
          .doc(user.uid)
          .get();

      if (!userFavoritesDoc.exists) {
        return false;
      }

      final List<String> productIds = List<String>.from(
        userFavoritesDoc.data()?['productIds'] ?? []
      );

      return productIds.contains(productId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Get products with filters
  static Future<List<Product>> getFilteredProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? location,
    String? sortBy, // 'price_asc', 'price_desc', 'date_asc', 'date_desc', 'popularity'
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('products')
          .where('isActive', isEqualTo: true);

      // Apply filters
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      if (condition != null && condition != 'All') {
        query = query.where('condition', isEqualTo: condition);
      }

      if (location != null && location != 'All') {
        query = query.where('location', isEqualTo: location);
      }

      // Apply sorting
      switch (sortBy) {
        case 'price_asc':
          query = query.orderBy('price', descending: false);
          break;
        case 'price_desc':
          query = query.orderBy('price', descending: true);
          break;
        case 'date_asc':
          query = query.orderBy('createdAt', descending: false);
          break;
        case 'popularity':
          query = query.orderBy('views', descending: true);
          break;
        default:
          query = query.orderBy('createdAt', descending: true);
      }

      query = query.limit(limit);

      final QuerySnapshot snapshot = await query.get();

      List<Product> products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromFirestore(data, doc.id);
      }).toList();

      // Apply price filter after fetching (since Firestore doesn't support range queries well with other filters)
      if (minPrice != null || maxPrice != null) {
        products = products.where((product) {
          final price = product.price ?? 0.0;
          if (minPrice != null && price < minPrice) return false;
          if (maxPrice != null && price > maxPrice) return false;
          return true;
        }).toList();
      }

      return products;
    } catch (e) {
      print('Error fetching filtered products: $e');
      throw Exception('Failed to fetch filtered products: $e');
    }
  }

  // Get product statistics for seller
  static Future<Map<String, dynamic>> getSellerProductStats(String sellerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      int totalProducts = 0;
      int activeProducts = 0;
      int totalViews = 0;
      int totalFavorites = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalProducts++;
        
        if (data['isActive'] == true) {
          activeProducts++;
        }
        
        totalViews += (data['views'] as int? ?? 0);
        totalFavorites += (data['favorites'] as int? ?? 0);
      }

      return {
        'totalProducts': totalProducts,
        'activeProducts': activeProducts,
        'totalViews': totalViews,
        'totalFavorites': totalFavorites,
      };
    } catch (e) {
      print('Error fetching seller stats: $e');
      throw Exception('Failed to fetch seller stats: $e');
    }
  }

  // Get available categories
  static Future<List<String>> getAvailableCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      final Set<String> categories = <String>{};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      final List<String> sortedCategories = categories.toList()..sort();
      return ['All', ...sortedCategories];
    } catch (e) {
      print('Error fetching categories: $e');
      return ['All'];
    }
  }

  // Stream products (for real-time updates)
  static Stream<List<Product>> streamProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  // Stream seller products
  static Stream<List<Product>> streamSellerProducts(String sellerId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromFirestore(data, doc.id);
      }).toList();
    });
  }
  
}
