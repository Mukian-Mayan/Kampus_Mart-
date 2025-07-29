import '../../models/product.dart';
import '../../services/product_service.dart';
import 'ml_api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnhancedProductService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Product>> enhancedSearch({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
    bool useML = true,
  }) async {
    if (useML) {
      try {
        return await MLApiService.semanticSearch(
          query: query,
          limit: limit,
          filters: filters,
        );
      } catch (e) {
        // Fallback to basic search
      }
    }
    
    return await ProductService.searchProducts(query);
  }

  static Future<List<Product>> getPersonalizedRecommendations({
    int limit = 10,
    String? category,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userInteractions = await _getUserInteractions(user.uid);
        
        if (userInteractions.isNotEmpty) {
          return await _generateRecommendationsFromInteractions(
            userInteractions: userInteractions,
            limit: limit,
            category: category,
          );
        }
      }
      
      return await MLApiService.getRecommendations(
        limit: limit,
        category: category,
        userPreferences: userPreferences,
      );
    } catch (e) {
      return await _getPopularProducts(limit: limit, category: category);
    }
  }

  static Future<List<Product>> getTrendingProducts({
    int limit = 10,
    String? category,
    String timeFrame = 'week',
  }) async {
    try {
      final trendingProducts = await _getTrendingProductsFromInteractions(
        limit: limit,
        category: category,
        timeFrame: timeFrame,
      );
      
      if (trendingProducts.isNotEmpty) {
        return trendingProducts;
      }
      
      return await MLApiService.getTrendingProducts(
        limit: limit,
        category: category,
        timeFrame: timeFrame,
      );
    } catch (e) {
      return await _getPopularProducts(limit: limit, category: category);
    }
  }

  static Future<List<Product>> getSimilarProducts({
    required String productId,
    int limit = 8,
  }) async {
    try {
      final mlSimilarProducts = await MLApiService.getSimilarProducts(
        productId: productId,
        limit: limit,
      );
      
      if (mlSimilarProducts.isNotEmpty) {
        return mlSimilarProducts;
      }
      
      final interactionSimilarProducts = await _getSimilarProductsFromInteractions(
        productId: productId,
        limit: limit,
      );
      
      if (interactionSimilarProducts.isNotEmpty) {
        return interactionSimilarProducts;
      }
      
      final fallbackSimilarProducts = await _getSimilarProductsFallback(productId, limit);
      return fallbackSimilarProducts;
      
    } catch (e) {
      return await _getSimilarProductsFallback(productId, limit);
    }
  }

  static Future<List<Product>> getCategoryRecommendations({
    required String category,
    int limit = 10,
  }) async {
    try {
      return await MLApiService.getCategoryRecommendations(
        category: category,
        limit: limit,
      );
    } catch (e) {
      return await ProductService.getProductsByCategory(category);
    }
  }

  static Future<List<String>> getSearchSuggestions({
    required String partialQuery,
    int limit = 5,
  }) async {
    try {
      return await MLApiService.getSearchSuggestions(
        partialQuery: partialQuery,
        limit: limit,
      );
    } catch (e) {
      return [];
    }
  }

  static Future<void> recordUserInteraction({
    required String productId,
    required String interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _storeUserInteraction(
          userId: user.uid,
          productId: productId,
          interactionType: interactionType,
          metadata: metadata,
        );
      }
      
      try {
        await MLApiService.recordInteraction(
          productId: productId,
          interactionType: interactionType,
          metadata: metadata,
        );
      } catch (mlError) {
        // ML API not available, but that's okay
      }
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<List<Product>> getRealProductsForML({
    int limit = 10,
    String? category,
    String type = 'recommendations',
  }) async {
    try {
      final allProducts = await ProductService.getAllProducts();
      
      if (allProducts.isEmpty) {
        return [];
      }
      
      List<Product> selectedProducts;
      
      if (category != null && category.isNotEmpty) {
        selectedProducts = allProducts
            .where((product) => product.category?.toLowerCase() == category.toLowerCase())
            .toList();
      } else {
        selectedProducts = allProducts;
      }
      
      if (selectedProducts.isEmpty) {
        return [];
      }
      
      selectedProducts.sort((a, b) => b.rating.compareTo(a.rating));
      return selectedProducts.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> initializeMLIntegration() async {
    try {
      final diagnostics = await getMLDiagnostics();
      
      final isConnected = await MLApiService.testConnection();
      if (!isConnected) {
        return false;
      }
      
      final success = await _initializeMLWithRealData();
      return success;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getMLDiagnostics() async {
    try {
      final apiStatus = await MLApiService.getApiStatus();
      final userInteractions = await _getAllUserInteractions();
      
      return {
        'mlApiConnected': apiStatus['connected'] ?? false,
        'userInteractionsCount': userInteractions.length,
        'apiStatus': apiStatus,
        'lastInteraction': userInteractions.isNotEmpty ? userInteractions.first['timestamp'] : null,
        'topCategories': await _getTopCategories(),
        'topProducts': await _getTopProducts(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'mlApiConnected': false,
        'userInteractionsCount': 0,
      };
    }
  }

  static Future<List<Map<String, dynamic>>> _getUserInteractions(String userId) async {
    try {
      final interactions = <Map<String, dynamic>>[];
      
      final cartItems = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('products')
          .get();
      
      for (var doc in cartItems.docs) {
        final data = doc.data();
        interactions.add({
          'productId': data['productId'] ?? '',
          'interactionType': 'view',
          'timestamp': DateTime.now().toIso8601String(),
          'metadata': {'source': 'cart', 'quantity': data['quantity'] ?? 1},
        });
      }
      
      final orders = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in orders.docs) {
        final data = doc.data();
        final orderItems = data['items'] as List<dynamic>? ?? [];
        
        for (var item in orderItems) {
          interactions.add({
            'productId': item['productId'] ?? '',
            'interactionType': 'purchase',
            'timestamp': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
            'metadata': {
              'source': 'order',
              'order_id': doc.id,
              'quantity': item['quantity'] ?? 1,
              'price': item['price'] ?? 0.0,
            },
          });
        }
      }
      
      final favorites = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
      
      for (var doc in favorites.docs) {
        interactions.add({
          'productId': doc.id,
          'interactionType': 'like',
          'timestamp': DateTime.now().toIso8601String(),
          'metadata': {'source': 'favorites'},
        });
      }
      
      return interactions;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> _getAllUserInteractions() async {
    try {
      final allInteractions = <Map<String, dynamic>>[];
      
      final users = await _firestore.collection('users').get();
      
      for (var userDoc in users.docs) {
        final userInteractions = await _getUserInteractions(userDoc.id);
        allInteractions.addAll(userInteractions);
      }
      
      allInteractions.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      return allInteractions;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Product>> _generateRecommendationsFromInteractions({
    required List<Map<String, dynamic>> userInteractions,
    int limit = 10,
    String? category,
  }) async {
    try {
      final productIds = userInteractions.map((i) => i['productId'] as String).toSet();
      final products = <Product>[];
      
      for (final productId in productIds) {
        if (products.length >= limit) break;
        
        final product = await ProductService.getProductById(productId);
        if (product != null) {
          if (category == null || product.category?.toLowerCase() == category.toLowerCase()) {
            products.add(product);
          }
        }
      }
      
      return products;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Product>> _getTrendingProductsFromInteractions({
    int limit = 10,
    String? category,
    String timeFrame = 'week',
  }) async {
    try {
      final allInteractions = await _getAllUserInteractions();
      final productInteractionCount = <String, int>{};
      
      for (final interaction in allInteractions) {
        final productId = interaction['productId'] as String;
        productInteractionCount[productId] = (productInteractionCount[productId] ?? 0) + 1;
      }
      
      final sortedProductIds = productInteractionCount.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      final trendingProducts = <Product>[];
      
      for (final entry in sortedProductIds) {
        if (trendingProducts.length >= limit) break;
        
        final product = await ProductService.getProductById(entry.key);
        if (product != null) {
          if (category == null || product.category?.toLowerCase() == category.toLowerCase()) {
            trendingProducts.add(product);
          }
        }
      }
      
      return trendingProducts;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Product>> _getSimilarProductsFromInteractions({
    required String productId,
    int limit = 8,
  }) async {
    try {
      final allInteractions = await _getAllUserInteractions();
      final productInteractions = <String, List<Map<String, dynamic>>>{};
      
      for (final interaction in allInteractions) {
        final pid = interaction['productId'] as String;
        productInteractions.putIfAbsent(pid, () => []).add(interaction);
      }
      
      final similarProducts = <Product>[];
      final targetInteractions = productInteractions[productId] ?? [];
      
      for (final entry in productInteractions.entries) {
        if (entry.key == productId) continue;
        if (similarProducts.length >= limit) break;
        
        final product = await ProductService.getProductById(entry.key);
        if (product != null) {
          similarProducts.add(product);
        }
      }
      
      return similarProducts;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Product>> _getSimilarProductsFallback(String productId, int limit) async {
    try {
      final targetProduct = await ProductService.getProductById(productId);
      if (targetProduct == null) return [];
      
      final allProducts = await ProductService.getAllProducts();
      final similarProducts = <Product>[];
      
      for (final product in allProducts) {
        if (product.id == productId) continue;
        if (similarProducts.length >= limit) break;
        
        if (product.category == targetProduct.category) {
          similarProducts.add(product);
        }
      }
      
      return similarProducts;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Product>> _getPopularProducts({
    int limit = 10,
    String? category,
  }) async {
    try {
      final products = await ProductService.getAllProducts();
      
      if (products.isEmpty) {
        return [];
      }
      
      List<Product> filteredProducts = products;
      if (category != null && category.isNotEmpty) {
        filteredProducts = products
            .where((product) => product.category?.toLowerCase() == category.toLowerCase())
            .toList();
      }
      
      filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
      return filteredProducts.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _storeUserInteraction({
    required String userId,
    required String productId,
    required String interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore
          .collection('user_interactions')
          .add({
        'userId': userId,
        'productId': productId,
        'interactionType': interactionType,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      });
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<bool> _initializeMLWithRealData() async {
    try {
      final products = await ProductService.getAllProducts();
      if (products.isEmpty) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> _getTopCategories() async {
    try {
      final products = await ProductService.getAllProducts();
      final categoryCount = <String, int>{};
      
      for (final product in products) {
        if (product.category != null) {
          categoryCount[product.category!] = (categoryCount[product.category!] ?? 0) + 1;
        }
      }
      
      final sortedCategories = categoryCount.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      return sortedCategories.take(5).map((e) => e.key).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<String>> _getTopProducts() async {
    try {
      final products = await ProductService.getAllProducts();
      products.sort((a, b) => b.rating.compareTo(a.rating));
      return products.take(5).map((p) => p.id).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clickProduct({
    required String productId,
    Map<String, dynamic>? metadata,
  }) async {
    await recordUserInteraction(
      productId: productId,
      interactionType: 'click',
      metadata: metadata,
    );
  }
} 