// Complete lib/services/product_service.dart
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import 'category_service.dart'; // Import the CategoryService

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
        'categoryId': category, // For compatibility with category service
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

      // Update category product count if categoryId exists
      if (category != null && category.isNotEmpty) {
        await CategoryService.incrementCategoryProductCount(category);
      }

      // Update seller product count
      await _incrementSellerProductCount(user.uid);

      print('Product created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating product: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  /// Add a new product and update category count (alternative method from first version)
  static Future<String> addProduct(Map<String, dynamic> productData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Add seller ID and timestamps
      productData['sellerId'] = user.uid;
      productData['createdAt'] = FieldValue.serverTimestamp();
      productData['updatedAt'] = FieldValue.serverTimestamp();
      productData['isActive'] = true;

      // Add the product
      final DocumentReference productRef = await _firestore
          .collection('products')
          .add(productData);

      // Update category product count if categoryId exists
      final String? categoryId = productData['categoryId'] as String?;
      if (categoryId != null && categoryId.isNotEmpty) {
        await CategoryService.incrementCategoryProductCount(categoryId);
      }

      // Update seller product count
      await _incrementSellerProductCount(user.uid);

      print('Successfully added product ${productRef.id} and updated counts');
      return productRef.id;
    } catch (e) {
      print('Error adding product: $e');
      throw e;
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
        final productText = '${product.name} ${product.description}'
            .toLowerCase();
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
      if (priceAndDiscount != null)
        updateData['priceAndDiscount'] = priceAndDiscount;
      if (originalPrice != null) updateData['originalPrice'] = originalPrice;
      if (condition != null) updateData['condition'] = condition;
      if (location != null) updateData['location'] = location;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (imageUrls != null) updateData['imageUrls'] = imageUrls;
      if (bestOffer != null) updateData['bestOffer'] = bestOffer;
      if (category != null) {
        updateData['category'] = category;
        updateData['categoryId'] = category; // For compatibility
      }
      if (price != null) updateData['price'] = price;
      if (stock != null) updateData['stock'] = stock;

      await _firestore.collection('products').doc(productId).update(updateData);
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  /// Update product category and adjust counts accordingly
  static Future<void> updateProductCategory(
    String productId,
    String newCategoryId,
  ) async {
    try {
      // Get current product data
      final DocumentSnapshot productDoc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      final productData = productDoc.data() as Map<String, dynamic>;
      final String? oldCategoryId = productData['categoryId'] as String?;
      final bool isActive = productData['isActive'] as bool? ?? true;

      // Only proceed if the category is actually changing and product is active
      if (oldCategoryId != newCategoryId && isActive) {
        // Update the product
        await _firestore.collection('products').doc(productId).update({
          'categoryId': newCategoryId,
          'category': newCategoryId, // For compatibility
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Decrement old category count
        if (oldCategoryId != null && oldCategoryId.isNotEmpty) {
          await CategoryService.decrementCategoryProductCount(oldCategoryId);
        }

        // Increment new category count
        if (newCategoryId.isNotEmpty) {
          await CategoryService.incrementCategoryProductCount(newCategoryId);
        }

        print(
          'Successfully moved product $productId from category $oldCategoryId to $newCategoryId',
        );
      }
    } catch (e) {
      print('Error updating product category: $e');
      throw e;
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

      final String? categoryId = productData['categoryId'] as String?;

      // Soft delete by setting isActive to false
      await _firestore.collection('products').doc(productId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update category product count if categoryId exists
      if (categoryId != null && categoryId.isNotEmpty) {
        await CategoryService.decrementCategoryProductCount(categoryId);
      }

      // Update seller product count
      await _decrementSellerProductCount(user.uid);

      print(
        'Successfully deleted product $productId and updated category count',
      );
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Helper method to decrement seller product count
  static Future<void> _decrementSellerProductCount(String sellerId) async {
    try {
      final sellerRef = _firestore.collection('sellers').doc(sellerId);

      await _firestore.runTransaction((transaction) async {
        final sellerDoc = await transaction.get(sellerRef);

        if (sellerDoc.exists) {
          final currentStats =
              sellerDoc.data()?['stats'] as Map<String, dynamic>? ?? {};
          final currentCount =
              (currentStats['totalProducts'] as num?)?.toInt() ?? 0;

          // Ensure count doesn't go below 0
          final newCount = currentCount > 0 ? currentCount - 1 : 0;

          final updatedStats = {...currentStats, 'totalProducts': newCount};

          transaction.update(sellerRef, {
            'stats': updatedStats,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      print('Seller product count decremented successfully');
    } catch (e) {
      print('Error decrementing seller product count: $e');
      // Don't rethrow - product deletion should still succeed
    }
  }

  /// Helper method to increment seller product count
  static Future<void> _incrementSellerProductCount(String sellerId) async {
    try {
      final sellerRef = _firestore.collection('sellers').doc(sellerId);

      await _firestore.runTransaction((transaction) async {
        final sellerDoc = await transaction.get(sellerRef);

        if (sellerDoc.exists) {
          final currentStats =
              sellerDoc.data()?['stats'] as Map<String, dynamic>? ?? {};
          final currentCount =
              (currentStats['totalProducts'] as num?)?.toInt() ?? 0;

          final updatedStats = {
            ...currentStats,
            'totalProducts': currentCount + 1,
          };

          transaction.update(sellerRef, {
            'stats': updatedStats,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      print('Seller product count incremented successfully');
    } catch (e) {
      print('Error incrementing seller product count: $e');
      // Don't rethrow - product creation should still succeed
    }
  }

  /// Utility method to recalculate seller product counts for all sellers
  /// This can be used to fix any inconsistencies in the data
  static Future<void> recalculateAllSellerProductCounts() async {
    try {
      print('Starting to recalculate all seller product counts...');

      // Get all sellers
      final sellersSnapshot = await _firestore.collection('sellers').get();

      for (final sellerDoc in sellersSnapshot.docs) {
        final sellerId = sellerDoc.id;

        // Count active products for this seller
        final productsSnapshot = await _firestore
            .collection('products')
            .where('sellerId', isEqualTo: sellerId)
            .where('isActive', isEqualTo: true)
            .get();

        final actualProductCount = productsSnapshot.docs.length;

        // Update seller stats with correct count
        final currentStats =
            sellerDoc.data()['stats'] as Map<String, dynamic>? ?? {};
        final updatedStats = {
          ...currentStats,
          'totalProducts': actualProductCount,
        };

        await _firestore.collection('sellers').doc(sellerId).update({
          'stats': updatedStats,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('Updated seller $sellerId: $actualProductCount products');
      }

      print('Finished recalculating all seller product counts');
    } catch (e) {
      print('Error recalculating seller product counts: $e');
      throw Exception('Failed to recalculate seller product counts: $e');
    }
  }

  /// Helper method to recalculate product count for a specific seller
  static Future<void> recalculateSellerProductCount(String sellerId) async {
    try {
      // Count active products for this seller
      final productsSnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .where('isActive', isEqualTo: true)
          .get();

      final actualProductCount = productsSnapshot.docs.length;

      // Get current seller data
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .get();
      if (!sellerDoc.exists) {
        throw Exception('Seller not found');
      }

      // Update seller stats with correct count
      final currentStats =
          sellerDoc.data()?['stats'] as Map<String, dynamic>? ?? {};
      final updatedStats = {
        ...currentStats,
        'totalProducts': actualProductCount,
      };

      await _firestore.collection('sellers').doc(sellerId).update({
        'stats': updatedStats,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Recalculated seller $sellerId product count: $actualProductCount');
    } catch (e) {
      print('Error recalculating seller product count: $e');
      throw Exception('Failed to recalculate seller product count: $e');
    }
  }

  /// Soft delete a product (mark as inactive) and update category count
  static Future<void> softDeleteProduct(String productId) async {
    try {
      // First, get the product to find its categoryId
      final DocumentSnapshot productDoc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      final productData = productDoc.data() as Map<String, dynamic>;
      final String? categoryId = productData['categoryId'] as String?;

      // Mark product as inactive
      await _firestore.collection('products').doc(productId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      // Update category product count if categoryId exists
      if (categoryId != null && categoryId.isNotEmpty) {
        await CategoryService.decrementCategoryProductCount(categoryId);
      }

      // Update seller product count
      final String sellerId = productData['sellerId'] as String;
      await _decrementSellerProductCount(sellerId);

      print(
        'Successfully soft deleted product $productId and updated category count',
      );
    } catch (e) {
      print('Error soft deleting product: $e');
      throw e;
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

      final String? categoryId = productData['categoryId'] as String?;

      await _firestore.collection('products').doc(productId).delete();

      // Update category product count if categoryId exists
      if (categoryId != null && categoryId.isNotEmpty) {
        await CategoryService.decrementCategoryProductCount(categoryId);
      }

      // Update seller product count
      await _decrementSellerProductCount(user.uid);

      print(
        'Successfully permanently deleted product $productId and updated category count',
      );
    } catch (e) {
      print('Error permanently deleting product: $e');
      throw Exception('Failed to permanently delete product: $e');
    }
  }

  /// Restore a soft-deleted product and update category count
  static Future<void> restoreProduct(String productId) async {
    try {
      // Get the product to find its categoryId
      final DocumentSnapshot productDoc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      final productData = productDoc.data() as Map<String, dynamic>;
      final String? categoryId = productData['categoryId'] as String?;

      // Restore product
      await _firestore.collection('products').doc(productId).update({
        'isActive': true,
        'deletedAt': FieldValue.delete(),
        'restoredAt': FieldValue.serverTimestamp(),
      });

      // Update category product count if categoryId exists
      if (categoryId != null && categoryId.isNotEmpty) {
        await CategoryService.incrementCategoryProductCount(categoryId);
      }

      // Update seller product count
      final String sellerId = productData['sellerId'] as String;
      await _incrementSellerProductCount(sellerId);

      print(
        'Successfully restored product $productId and updated category count',
      );
    } catch (e) {
      print('Error restoring product: $e');
      throw e;
    }
  }

  /// Batch delete multiple products and update category counts
  static Future<void> batchDeleteProducts(List<String> productIds) async {
    try {
      final WriteBatch batch = _firestore.batch();
      final Map<String, int> categoryDecrements = {};

      // Process each product
      for (final productId in productIds) {
        final DocumentSnapshot productDoc = await _firestore
            .collection('products')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          final productData = productDoc.data() as Map<String, dynamic>;
          final String? categoryId = productData['categoryId'] as String?;

          // Add deletion to batch
          batch.delete(_firestore.collection('products').doc(productId));

          // Track category decrements
          if (categoryId != null && categoryId.isNotEmpty) {
            categoryDecrements[categoryId] =
                (categoryDecrements[categoryId] ?? 0) + 1;
          }
        }
      }

      // Execute batch delete
      await batch.commit();

      // Update category counts
      for (final entry in categoryDecrements.entries) {
        final categoryId = entry.key;
        // The decrementAmount was already accounted for in the batch delete
        // Get current count and calculate new count
        await CategoryService.updateCategoryProductCount(categoryId);
      }

      print(
        'Successfully batch deleted ${productIds.length} products and updated category counts',
      );
    } catch (e) {
      print('Error batch deleting products: $e');
      throw e;
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
          'productIds': FieldValue.arrayUnion([productId]),
        }, SetOptions(merge: true));

        // Increment product favorites count
        await _firestore.collection('products').doc(productId).update({
          'favorites': FieldValue.increment(1),
        });
      } else {
        // Remove from favorites
        await userFavoritesRef.update({
          'productIds': FieldValue.arrayRemove([productId]),
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
        userFavoritesDoc.data()?['productIds'] ?? [],
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
          }),
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
        userFavoritesDoc.data()?['productIds'] ?? [],
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
    String?
    sortBy, // 'price_asc', 'price_desc', 'date_asc', 'date_desc', 'popularity'
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
  static Future<Map<String, dynamic>> getSellerProductStats(
    String sellerId,
  ) async {
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

  /// Get products by seller with real-time updates
  static Stream<QuerySnapshot> getSellerProductsStream(String sellerId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get products by category with real-time updates
  static Stream<QuerySnapshot> getCategoryProductsStream(String categoryId) {
    return _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
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

  /// Update product stock during order processing (system operation)
  /// This bypasses ownership checks as it's called during legitimate order processing
  static Future<void> updateProductStockForOrder({
    required String productId,
    required int newStock,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating product stock: $e');
      throw Exception('Failed to update product stock: $e');
    }
  }
}
