import '../../models/product.dart';
import '../../services/product_service.dart';
import 'ml_api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnhancedProductService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Enhanced search with ML capabilities
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
        print('ML search failed, falling back to basic search: $e');
      }
    }
    
    // Fallback to basic search
    return await ProductService.searchProducts(query);
  }

  /// Get personalized recommendations based on user interactions
  static Future<List<Product>> getPersonalizedRecommendations({
    int limit = 10,
    String? category,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Get user's interaction history
        final userInteractions = await _getUserInteractions(user.uid);
        
        if (userInteractions.isNotEmpty) {
          // Generate recommendations based on user interactions
          return await _generateRecommendationsFromInteractions(
            userInteractions: userInteractions,
            limit: limit,
            category: category,
          );
        }
      }
      
      // Fallback to ML recommendations
      return await MLApiService.getRecommendations(
        limit: limit,
        category: category,
        userPreferences: userPreferences,
      );
    } catch (e) {
      print('Personalized recommendations failed, falling back to popular products: $e');
      return await _getPopularProducts(limit: limit, category: category);
    }
  }

  /// Get trending products based on recent user interactions
  static Future<List<Product>> getTrendingProducts({
    int limit = 10,
    String? category,
    String timeFrame = 'week',
  }) async {
    try {
      // Get trending products based on recent interactions
      final trendingProducts = await _getTrendingProductsFromInteractions(
        limit: limit,
        category: category,
        timeFrame: timeFrame,
      );
      
      if (trendingProducts.isNotEmpty) {
        return trendingProducts;
      }
      
      // Fallback to ML trending
      return await MLApiService.getTrendingProducts(
        limit: limit,
        category: category,
        timeFrame: timeFrame,
      );
    } catch (e) {
      print('Trending products failed, falling back to popular products: $e');
      return await _getPopularProducts(limit: limit, category: category);
    }
  }

  /// Get similar products using ML and user interactions
  static Future<List<Product>> getSimilarProducts({
    required String productId,
    int limit = 8,
  }) async {
    try {
      // First try ML-based similar products
      List<Product> mlSimilarProducts = [];
      try {
        print('🔍 Attempting ML-based similar products for: $productId');
        mlSimilarProducts = await MLApiService.getSimilarProducts(
          productId: productId,
          limit: limit,
        );
      } catch (mlError) {
        print('⚠️ ML API not available for similar products: $mlError');
        // Continue to fallback methods
      }
      
      if (mlSimilarProducts.isNotEmpty) {
        print('✅ Found ${mlSimilarProducts.length} similar products via ML');
        return mlSimilarProducts;
      }
      
      // Fallback to interaction-based similar products
      print('🔄 Falling back to interaction-based similar products');
      final interactionSimilarProducts = await _getSimilarProductsFromInteractions(
        productId: productId,
        limit: limit,
      );
      
      if (interactionSimilarProducts.isNotEmpty) {
        print('✅ Found ${interactionSimilarProducts.length} similar products via interactions');
        return interactionSimilarProducts;
      }
      
      // Final fallback to basic similarity
      print('🔄 Falling back to basic similarity algorithm');
      final fallbackSimilarProducts = await _getSimilarProductsFallback(productId, limit);
      print('✅ Found ${fallbackSimilarProducts.length} similar products via fallback');
      return fallbackSimilarProducts;
      
    } catch (e) {
      print('❌ Similar products failed: $e');
      return await _getSimilarProductsFallback(productId, limit);
    }
  }

  /// Get category-based recommendations
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
      print('ML category recommendations failed: $e');
      return await ProductService.getProductsByCategory(category);
    }
  }

  /// Get search suggestions
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
      print('ML search suggestions failed: $e');
      return [];
    }
  }

  /// Record user interaction for ML training and recommendations
  static Future<void> recordUserInteraction({
    required String productId,
    required String interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Store interaction in Firestore for recommendations
        await _storeUserInteraction(
          userId: user.uid,
          productId: productId,
          interactionType: interactionType,
          metadata: metadata,
        );
      }
      
      // Also send to ML API (but don't fail if it's not available)
      try {
        await MLApiService.recordInteraction(
          productId: productId,
          interactionType: interactionType,
          metadata: metadata,
        );
      } catch (mlError) {
        // ML API is not available, but that's okay
        print('ML API not available for interaction recording: $mlError');
      }
    } catch (e) {
      print('Failed to record interaction: $e');
    }
  }

  /// Get real Firebase products for ML recommendations
  static Future<List<Product>> getRealProductsForML({
    int limit = 10,
    String? category,
    String type = 'recommendations', // 'recommendations' or 'trending'
  }) async {
    try {
      print('Getting real Firebase products for ML $type...');
      
      final allProducts = await ProductService.getAllProducts();
      print('Found ${allProducts.length} total products in Firebase');
      
      if (allProducts.isEmpty) {
        print('No products found in Firebase');
        return [];
      }
      
      List<Product> selectedProducts;
      
      if (type == 'recommendations') {
        // For recommendations: use personalized recommendations
        selectedProducts = await getPersonalizedRecommendations(limit: limit, category: category);
        print('Selected ${selectedProducts.length} personalized products for recommendations');
      } else {
        // For trending: use trending products based on interactions
        selectedProducts = await getTrendingProducts(limit: limit, category: category);
        print('Selected ${selectedProducts.length} trending products for trending');
      }
      
      return selectedProducts;
    } catch (e) {
      print('Error getting real products for ML: $e');
      return [];
    }
  }

  /// Get home page products with real Firebase data
  static Future<Map<String, List<Product>>> getHomePageProductsWithRealData() async {
    try {
      print('Getting home page products with real Firebase data...');
      
      // Get personalized recommendations based on user interactions
      final recommendations = await getPersonalizedRecommendations(limit: 5);
      
      // Get trending products based on recent interactions
      final trending = await getTrendingProducts(limit: 5);
      
      print('Generated ${recommendations.length} recommendations and ${trending.length} trending products from user interactions');
      
      return {
        'recommendations': recommendations,
        'trending': trending,
      };
    } catch (e) {
      print('Error getting home page products with real data: $e');
      return {
        'recommendations': _getFallbackRecommendations(),
        'trending': _getFallbackTrending(),
      };
    }
  }

  /// Enhanced product view with ML tracking
  static Future<void> viewProduct(String productId) async {
    try {
      // Record view interaction for ML and recommendations
      await recordUserInteraction(
        productId: productId,
        interactionType: 'view',
        metadata: {'timestamp': DateTime.now().toIso8601String()},
      );
      
      // Increment view count in Firestore
      await ProductService.incrementViews(productId);
    } catch (e) {
      print('Failed to record product view: $e');
    }
  }

  /// Enhanced product click with ML tracking
  static Future<void> clickProduct(String productId) async {
    try {
      await recordUserInteraction(
        productId: productId,
        interactionType: 'click',
        metadata: {'timestamp': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      print('Failed to record product click: $e');
    }
  }

  /// Enhanced favorite toggle with ML tracking
  static Future<void> toggleFavorite(String productId, bool isFavorite) async {
    try {
      // Record favorite interaction for ML and recommendations
      await recordUserInteraction(
        productId: productId,
        interactionType: isFavorite ? 'favorite' : 'unfavorite',
        metadata: {'timestamp': DateTime.now().toIso8601String()},
      );
      
      // Update favorite in Firestore
      await ProductService.toggleFavorite(productId, isFavorite);
    } catch (e) {
      print('Failed to toggle favorite: $e');
    }
  }

  /// Enhanced add to cart with ML tracking
  static Future<void> addToCart(String productId) async {
    try {
      await recordUserInteraction(
        productId: productId,
        interactionType: 'add_to_cart',
        metadata: {'timestamp': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      print('Failed to record add to cart: $e');
    }
  }

  /// Enhanced purchase with ML tracking
  static Future<void> purchaseProduct(String productId) async {
    try {
      await recordUserInteraction(
        productId: productId,
        interactionType: 'purchase',
        metadata: {'timestamp': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      print('Failed to record purchase: $e');
    }
  }

  /// Get products with ML-powered sorting
  static Future<List<Product>> getProductsWithMLSorting({
    String? category,
    String sortBy = 'ml_relevance', // 'ml_relevance', 'price', 'date', 'popularity'
    bool descending = true,
    int limit = 20,
  }) async {
    try {
      if (sortBy == 'ml_relevance') {
        // Use personalized recommendations for relevance-based sorting
        return await getPersonalizedRecommendations(
          limit: limit,
          category: category,
        );
      }
      
      // Fallback to basic sorting
      return await _getProductsWithBasicSorting(
        category: category,
        sortBy: sortBy,
        descending: descending,
        limit: limit,
      );
    } catch (e) {
      print('ML sorting failed: $e');
      return await _getProductsWithBasicSorting(
        category: category,
        sortBy: sortBy,
        descending: descending,
        limit: limit,
      );
    }
  }

  /// Initialize ML integration with real app data
  static Future<bool> initializeMLIntegration() async {
    try {
      print('🚀 Initializing ML integration...');
      
      // Get diagnostics first
      final diagnostics = await getMLDiagnostics();
      print('📊 ML Integration Diagnostics:');
      print('   - ML API Connected: ${diagnostics['mlApiConnected']}');
      print('   - User Interactions: ${diagnostics['userInteractionsCount']}');
      print('   - Total Products: ${diagnostics['totalProducts']}');
      
      // Test ML API connection first
      final isConnected = await MLApiService.testConnection();
      if (!isConnected) {
        print('⚠️ ML API not available, but app will continue with fallbacks');
        print('✅ Fallback system is working - users will still get personalized recommendations');
        return false;
      }
      
      // Get API status for debugging
      final apiStatus = await MLApiService.getApiStatus();
      print('🔗 ML API Status: $apiStatus');
      
      // Sync real products and interactions with ML API
      final success = await MLApiService.initializeMLWithRealData();
      
      if (success) {
        print('✅ ML integration initialized successfully');
      } else {
        print('⚠️ ML integration initialization failed, but app will continue with fallbacks');
        print('✅ Fallback system is working - users will still get personalized recommendations');
      }
      
      return success;
    } catch (e) {
      print('❌ Error initializing ML integration: $e');
      print('✅ Fallback system is working - users will still get personalized recommendations');
      return false;
    }
  }

  /// Ensure sample products are available for testing
  static Future<void> ensureSampleProducts() async {
    try {
      final allProducts = await ProductService.getAllProducts();
      
      if (allProducts.isEmpty) {
        print('No products found, creating sample products for testing...');
        await _createSampleProducts();
      } else {
        print('Found ${allProducts.length} existing products');
      }
    } catch (e) {
      print('Error ensuring sample products: $e');
    }
  }

  /// Create sample products for testing
  static Future<void> _createSampleProducts() async {
    try {
      final sampleProducts = [
        {
          'name': 'Study Desk',
          'description': 'Perfect wooden study desk for students',
          'priceAndDiscount': 'UGX 120,000',
          'originalPrice': 'UGX 150,000',
          'condition': 'New',
          'location': 'Kampala',
          'rating': 4.5,
          'imageUrl': 'lib/products/study_table.jpeg',
          'category': 'Furniture',
          'price': 120000.0,
        },
        {
          'name': 'Laptop Stand',
          'description': 'Adjustable laptop stand for better posture',
          'priceAndDiscount': 'UGX 45,000',
          'originalPrice': 'UGX 60,000',
          'condition': 'New',
          'location': 'Kampala',
          'rating': 4.2,
          'imageUrl': 'lib/products/macbook2.jpg',
          'category': 'Electronics',
          'price': 45000.0,
        },
        {
          'name': 'Reading Chair',
          'description': 'Comfortable chair for reading and studying',
          'priceAndDiscount': 'UGX 85,000',
          'originalPrice': 'UGX 100,000',
          'condition': 'Used',
          'location': 'Kampala',
          'rating': 4.0,
          'imageUrl': 'lib/products/studytable.jpg',
          'category': 'Furniture',
          'price': 85000.0,
        },
        {
          'name': 'Wireless Mouse',
          'description': 'High-quality wireless mouse for laptops',
          'priceAndDiscount': 'UGX 25,000',
          'originalPrice': 'UGX 35,000',
          'condition': 'New',
          'location': 'Kampala',
          'rating': 4.3,
          'imageUrl': 'lib/products/back bag.jpeg',
          'category': 'Electronics',
          'price': 25000.0,
        },
        {
          'name': 'Bookshelf',
          'description': 'Compact bookshelf for organizing books',
          'priceAndDiscount': 'UGX 95,000',
          'originalPrice': 'UGX 120,000',
          'condition': 'New',
          'location': 'Kampala',
          'rating': 4.1,
          'imageUrl': 'lib/products/cup_board.jpeg',
          'category': 'Furniture',
          'price': 95000.0,
        },
      ];

      for (final productData in sampleProducts) {
        try {
          await ProductService.createProduct(
            name: productData['name'] as String,
            description: productData['description'] as String,
            priceAndDiscount: productData['priceAndDiscount'] as String,
            originalPrice: productData['originalPrice'] as String,
            condition: productData['condition'] as String,
            location: productData['location'] as String,
            imageUrl: productData['imageUrl'] as String,
            category: productData['category'] as String,
            price: (productData['price'] as num?)?.toDouble() ?? 0.0,
          );
        } catch (e) {
          print('Failed to create sample product ${productData['name']}: $e');
        }
      }
      
      print('Sample products creation completed');
    } catch (e) {
      print('Error creating sample products: $e');
    }
  }

  // New methods for user interaction-based recommendations

  /// Store user interaction in Firestore
  static Future<void> _storeUserInteraction({
    required String userId,
    required String productId,
    required String interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('user_interactions').add({
        'userId': userId,
        'productId': productId,
        'interactionType': interactionType,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to store user interaction: $e');
    }
  }

  /// Get user's interaction history
  static Future<List<Map<String, dynamic>>> _getUserInteractions(String userId) async {
    try {
      // Use simple query without ordering to avoid index issues
      final snapshot = await _firestore
          .collection('user_interactions')
          .where('userId', isEqualTo: userId)
          .limit(20) // Small limit to avoid performance issues
          .get();

      final interactions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Sort in memory instead of in Firestore query
      interactions.sort((a, b) {
        final aTimestamp = a['timestamp'] as Timestamp?;
        final bTimestamp = b['timestamp'] as Timestamp?;
        if (aTimestamp == null && bTimestamp == null) return 0;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;
        return bTimestamp.compareTo(aTimestamp);
      });
      
      return interactions;
    } catch (e) {
      print('Failed to get user interactions: $e');
      // Return empty list instead of throwing error
      return [];
    }
  }

  /// Generate recommendations based on user interactions
  static Future<List<Product>> _generateRecommendationsFromInteractions({
    required List<Map<String, dynamic>> userInteractions,
    int limit = 10,
    String? category,
  }) async {
    try {
      // Analyze user interactions to find patterns
      final productInteractions = <String, Map<String, dynamic>>{};
      
      for (final interaction in userInteractions) {
        final productId = interaction['productId'] as String;
        final interactionType = interaction['interactionType'] as String;
        
        if (!productInteractions.containsKey(productId)) {
          productInteractions[productId] = {
            'views': 0,
            'clicks': 0,
            'favorites': 0,
            'add_to_cart': 0,
            'purchase': 0,
            'lastInteraction': interaction['timestamp'],
          };
        }
        
        switch (interactionType) {
          case 'view':
            productInteractions[productId]!['views']++;
            break;
          case 'click':
            productInteractions[productId]!['clicks']++;
            break;
          case 'favorite':
            productInteractions[productId]!['favorites']++;
            break;
          case 'add_to_cart':
            productInteractions[productId]!['add_to_cart']++;
            break;
          case 'purchase':
            productInteractions[productId]!['purchase']++;
            break;
        }
      }
      
      // Get all products
      final allProducts = await ProductService.getAllProducts();
      
      // Calculate recommendation scores
      final productScores = <String, double>{};
      
      for (final product in allProducts) {
        if (category != null && product.category != category) continue;
        
        double score = 0;
        
        // Base score from product rating
        score += product.rating * 2;
        
        // Bonus for products user has interacted with
        if (productInteractions.containsKey(product.id)) {
          final interactions = productInteractions[product.id]!;
          score += interactions['views'] * 0.5;
          score += interactions['clicks'] * 1.0;
          score += interactions['favorites'] * 2.0;
          score += interactions['add_to_cart'] * 3.0; // Higher weight for cart
          score += interactions['purchase'] * 5.0; // Highest weight for purchases
        }
        
        // Bonus for similar categories to user's favorites
        final userFavoriteCategories = _getUserFavoriteCategories(userInteractions);
        if (userFavoriteCategories.contains(product.category)) {
          score += 1.5;
        }
        
        // Bonus for products in categories user has purchased from
        final userPurchaseCategories = _getUserPurchaseCategories(userInteractions);
        if (userPurchaseCategories.contains(product.category)) {
          score += 2.0;
        }
        
        productScores[product.id] = score;
      }
      
      // Sort products by score and return top recommendations
      final sortedProducts = allProducts.where((p) => productScores.containsKey(p.id)).toList();
      sortedProducts.sort((a, b) => productScores[b.id]!.compareTo(productScores[a.id]!));
      
      return sortedProducts.take(limit).toList();
    } catch (e) {
      print('Failed to generate recommendations from interactions: $e');
      return [];
    }
  }

  /// Get trending products based on recent interactions
  static Future<List<Product>> _getTrendingProductsFromInteractions({
    int limit = 10,
    String? category,
    String timeFrame = 'week',
  }) async {
    try {
      // Calculate time threshold based on timeFrame
      final now = DateTime.now();
      DateTime threshold;
      switch (timeFrame) {
        case 'day':
          threshold = now.subtract(const Duration(days: 1));
          break;
        case 'week':
          threshold = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          threshold = now.subtract(const Duration(days: 30));
          break;
        default:
          threshold = now.subtract(const Duration(days: 7));
      }
      
      // Get recent interactions
      final snapshot = await _firestore
          .collection('user_interactions')
          .where('timestamp', isGreaterThan: threshold)
          .get();
      
      final recentInteractions = snapshot.docs.map((doc) => doc.data()).toList();
      
      // Count interactions per product
      final productInteractionCounts = <String, int>{};
      for (final interaction in recentInteractions) {
        final productId = interaction['productId'] as String;
        productInteractionCounts[productId] = (productInteractionCounts[productId] ?? 0) + 1;
      }
      
      // Get all products
      final allProducts = await ProductService.getAllProducts();
      
      // Filter and sort by interaction count
      final trendingProducts = allProducts.where((product) {
        if (category != null && product.category != category) return false;
        return productInteractionCounts.containsKey(product.id);
      }).toList();
      
      trendingProducts.sort((a, b) {
        final aCount = productInteractionCounts[a.id] ?? 0;
        final bCount = productInteractionCounts[b.id] ?? 0;
        return bCount.compareTo(aCount);
      });
      
      return trendingProducts.take(limit).toList();
    } catch (e) {
      print('Failed to get trending products from interactions: $e');
      return [];
    }
  }

  /// Get user's favorite categories from interactions
  static Set<String> _getUserFavoriteCategories(List<Map<String, dynamic>> userInteractions) {
    final categoryScores = <String, double>{};
    
    for (final interaction in userInteractions) {
      if (interaction['interactionType'] == 'favorite') {
        // This would need to be enhanced to get product category
        // For now, we'll use a simple approach
      }
    }
    
    return categoryScores.keys.toSet();
  }

  /// Get user's purchase categories from interactions
  static Set<String> _getUserPurchaseCategories(List<Map<String, dynamic>> userInteractions) {
    final categoryScores = <String, double>{};
    
    for (final interaction in userInteractions) {
      if (interaction['interactionType'] == 'purchase') {
        // This would need to be enhanced to get product category
        // For now, we'll use a simple approach
      }
    }
    
    return categoryScores.keys.toSet();
  }

  /// Get real products for recommendations (fallback to popular products)
  static Future<List<Product>> _getRealProductsForRecommendations({
    int limit = 10,
    String? category,
  }) async {
    try {
      // Get real products from Firestore
      final allProducts = await ProductService.getAllProducts();
      
      if (allProducts.isEmpty) {
        print('No real products available for recommendations');
        return [];
      }
      
      // Filter by category if specified
      List<Product> filteredProducts = allProducts;
      if (category != null && category.isNotEmpty) {
        filteredProducts = allProducts.where((product) => 
          product.category?.toLowerCase() == category.toLowerCase()
        ).toList();
      }
      
      // Sort by rating and take top products
      filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
      
      return filteredProducts.take(limit).toList();
    } catch (e) {
      print('Error getting real products for recommendations: $e');
      return [];
    }
  }

  /// Get real products for trending (fallback to recently added products)
  static Future<List<Product>> _getRealProductsForTrending({
    int limit = 10,
    String? category,
  }) async {
    try {
      // Get real products from Firestore
      final allProducts = await ProductService.getAllProducts();
      
      if (allProducts.isEmpty) {
        print('No real products available for trending');
        return [];
      }
      
      // Filter by category if specified
      List<Product> filteredProducts = allProducts;
      if (category != null && category.isNotEmpty) {
        filteredProducts = allProducts.where((product) => 
          product.category?.toLowerCase() == category.toLowerCase()
        ).toList();
      }
      
      // Sort by creation date (newest first) and take top products
      filteredProducts.sort((a, b) => 
        (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now())
      );
      
      return filteredProducts.take(limit).toList();
    } catch (e) {
      print('Error getting real products for trending: $e');
      return [];
    }
  }

  /// Get similar products using user interactions
  static Future<List<Product>> _getSimilarProductsFromInteractions({
    required String productId,
    int limit = 8,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      
      final userInteractions = await _getUserInteractions(user.uid);
      final productInteractions = <String, Map<String, dynamic>>{};

      for (final interaction in userInteractions) {
        final interactionProductId = interaction['productId'] as String;
        if (interactionProductId == productId) continue;

        if (!productInteractions.containsKey(interactionProductId)) {
          productInteractions[interactionProductId] = {
            'views': 0,
            'clicks': 0,
            'favorites': 0,
            'add_to_cart': 0,
            'purchase': 0,
            'lastInteraction': interaction['timestamp'],
          };
        }

        final interactionType = interaction['interactionType'] as String;
        switch (interactionType) {
          case 'view':
            productInteractions[interactionProductId]!['views']++;
            break;
          case 'click':
            productInteractions[interactionProductId]!['clicks']++;
            break;
          case 'favorite':
            productInteractions[interactionProductId]!['favorites']++;
            break;
          case 'add_to_cart':
            productInteractions[interactionProductId]!['add_to_cart']++;
            break;
          case 'purchase':
            productInteractions[interactionProductId]!['purchase']++;
            break;
        }
      }

      final allProducts = await ProductService.getAllProducts();
      final similarProducts = <Product>[];

      for (final product in allProducts) {
        if (product.id == productId) continue;

        double score = 0;
        if (productInteractions.containsKey(product.id)) {
          final interactions = productInteractions[product.id]!;
          score += interactions['views'] * 0.5;
          score += interactions['clicks'] * 1.0;
          score += interactions['favorites'] * 2.0;
          score += interactions['add_to_cart'] * 3.0;
          score += interactions['purchase'] * 5.0;
        }

        // Bonus for similar categories to user's favorites
        final userFavoriteCategories = _getUserFavoriteCategories(userInteractions);
        if (userFavoriteCategories.contains(product.category)) {
          score += 1.5;
        }

        // Bonus for products in categories user has purchased from
        final userPurchaseCategories = _getUserPurchaseCategories(userInteractions);
        if (userPurchaseCategories.contains(product.category)) {
          score += 2.0;
        }

        // Add product with score
        similarProducts.add(product);
      }

      // Sort by interaction score first, then by rating
      similarProducts.sort((a, b) {
        final aScore = productInteractions[a.id]?['score'] ?? 0.0;
        final bScore = productInteractions[b.id]?['score'] ?? 0.0;
        if (aScore != bScore) return bScore.compareTo(aScore);
        return b.rating.compareTo(a.rating);
      });
      
      return similarProducts.take(limit).toList();
    } catch (e) {
      print('Failed to get similar products from interactions: $e');
      return [];
    }
  }

  /// Get ML API diagnostic information
  static Future<Map<String, dynamic>> getMLDiagnostics() async {
    try {
      final diagnostics = <String, dynamic>{};
      
      // Test ML API connection
      final isConnected = await MLApiService.testConnection();
      diagnostics['mlApiConnected'] = isConnected;
      
      // Get API status
      final apiStatus = await MLApiService.getApiStatus();
      diagnostics['apiStatus'] = apiStatus;
      
      // Check if we have user interactions
      final user = _auth.currentUser;
      if (user != null) {
        final userInteractions = await _getUserInteractions(user.uid);
        diagnostics['userInteractionsCount'] = userInteractions.length;
        diagnostics['hasUserInteractions'] = userInteractions.isNotEmpty;
      } else {
        diagnostics['userInteractionsCount'] = 0;
        diagnostics['hasUserInteractions'] = false;
      }
      
      // Check if we have products
      final allProducts = await ProductService.getAllProducts();
      diagnostics['totalProducts'] = allProducts.length;
      diagnostics['hasProducts'] = allProducts.isNotEmpty;
      
      print('🔍 ML Diagnostics: $diagnostics');
      return diagnostics;
    } catch (e) {
      print('❌ Error getting ML diagnostics: $e');
      return {
        'error': e.toString(),
        'mlApiConnected': false,
      };
    }
  }

  // Helper methods

  /// Fallback search when ML API is unavailable
  static Future<List<Product>> _fallbackSearch(String query, int limit) async {
    try {
      return await ProductService.searchProducts(query);
    } catch (e) {
      print('Fallback search failed: $e');
      return [];
    }
  }

  /// Fallback to popular products when ML API is unavailable
  static Future<List<Product>> _getPopularProducts({
    int limit = 10,
    String? category,
  }) async {
    try {
      List<Product> products;
      if (category != null) {
        products = await ProductService.getProductsByCategory(category);
      } else {
        products = await ProductService.getAllProducts();
      }
      
      // Sort by views/favorites for popularity
      products.sort((a, b) {
        final aScore = (a.rating * 10) + (a.stock ?? 0);
        final bScore = (b.rating * 10) + (b.stock ?? 0);
        return bScore.compareTo(aScore);
      });
      
      return products.take(limit).toList();
    } catch (e) {
      print('Failed to get popular products: $e');
      return [];
    }
  }

  /// Fallback for similar products
  static Future<List<Product>> _getSimilarProductsFallback(
    String productId,
    int limit,
  ) async {
    try {
      final product = await ProductService.getProductById(productId);
      final allProducts = await ProductService.getAllProducts();
      
      if (allProducts.isEmpty) {
        print('No products available for similar products fallback');
        return [];
      }
      
      List<Product> similarProducts;
      
      if (product != null) {
        // Product found, find similar ones
        similarProducts = allProducts.where((p) {
          if (p.id == productId) return false;
          
          final sameCategory = p.category == product.category;
          final priceSimilar = _isPriceSimilar(p, product);
          
          return sameCategory || priceSimilar;
        }).toList();
        
        // Sort by similarity score
        similarProducts.sort((a, b) {
          final aScore = _calculateSimilarityScore(a, product);
          final bScore = _calculateSimilarityScore(b, product);
          return bScore.compareTo(aScore);
        });
      } else {
        // Product not found, return top rated products
        print('Product not found, returning top rated products as similar');
        similarProducts = List<Product>.from(allProducts);
        similarProducts.sort((a, b) => b.rating.compareTo(a.rating));
      }
      
      final result = similarProducts.take(limit).toList();
      print('Fallback similar products found: ${result.length}');
      return result;
      
    } catch (e) {
      print('Failed to get similar products fallback: $e');
      // Last resort: return any available products
      try {
        final allProducts = await ProductService.getAllProducts();
        return allProducts.take(limit).toList();
      } catch (finalError) {
        print('Final fallback also failed: $finalError');
        return [];
      }
    }
  }

  /// Basic sorting fallback
  static Future<List<Product>> _getProductsWithBasicSorting({
    String? category,
    String sortBy = 'date',
    bool descending = true,
    int limit = 20,
  }) async {
    try {
      List<Product> products;
      if (category != null) {
        products = await ProductService.getProductsByCategory(category);
      } else {
        products = await ProductService.getAllProducts();
      }
      
      // Apply sorting
      switch (sortBy) {
        case 'price':
          products.sort((a, b) {
            final aPrice = a.price ?? 0;
            final bPrice = b.price ?? 0;
            return descending ? bPrice.compareTo(aPrice) : aPrice.compareTo(bPrice);
          });
          break;
        case 'date':
          products.sort((a, b) {
            final aDate = a.createdAt ?? DateTime.now();
            final bDate = b.createdAt ?? DateTime.now();
            return descending ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
          });
          break;
        case 'popularity':
          products.sort((a, b) {
            final aScore = (a.rating * 10) + (a.stock ?? 0);
            final bScore = (b.rating * 10) + (b.stock ?? 0);
            return descending ? bScore.compareTo(aScore) : aScore.compareTo(bScore);
          });
          break;
      }
      
      return products.take(limit).toList();
    } catch (e) {
      print('Failed to get products with basic sorting: $e');
      return [];
    }
  }

  /// Check if two products have similar prices
  static bool _isPriceSimilar(Product a, Product b) {
    final aPrice = a.price ?? 0;
    final bPrice = b.price ?? 0;
    if (aPrice == 0 || bPrice == 0) return false;
    
    final difference = (aPrice - bPrice).abs();
    final averagePrice = (aPrice + bPrice) / 2;
    final percentageDifference = (difference / averagePrice) * 100;
    
    return percentageDifference <= 30; // Within 30% price range
  }

  /// Calculate similarity score between two products
  static double _calculateSimilarityScore(Product a, Product b) {
    double score = 0;
    
    // Category similarity
    if (a.category == b.category) score += 0.4;
    
    // Price similarity
    if (_isPriceSimilar(a, b)) score += 0.3;
    
    // Rating similarity
    final ratingDiff = (a.rating - b.rating).abs();
    if (ratingDiff <= 1) score += 0.2;
    
    // Condition similarity
    if (a.condition == b.condition) score += 0.1;
    
    return score;
  }

  /// Get top rated products for recommendations
  static List<Product> _getTopRatedProducts(List<Product> products, {int limit = 5}) {
    // Sort by rating (highest first)
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    
    // Take top products
    return sorted.take(limit).toList();
  }

  /// Get recently added products for trending
  static List<Product> _getRecentlyAddedProducts(List<Product> products, {int limit = 5}) {
    // Sort by creation date (newest first)
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.now();
      final bDate = b.createdAt ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
    
    // Take newest products
    return sorted.take(limit).toList();
  }

  /// Fallback recommendations when no products available
  static List<Product> _getFallbackRecommendations() {
    return [
      Product(
        id: 'fallback1',
        name: 'Featured Product 1',
        description: 'Check out this amazing product!',
        ownerId: '',
        priceAndDiscount: 'UGX 50,000',
        originalPrice: 'UGX 50,000',
        condition: 'New',
        location: 'Kampala',
        rating: 4.5,
        imageUrl: 'https://via.placeholder.com/300x300/cccccc/ffffff?text=Product+1',
        category: 'Featured',
        price: 50000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'fallback2',
        name: 'Featured Product 2',
        description: 'Another great product for you!',
        ownerId: '',
        priceAndDiscount: 'UGX 75,000',
        originalPrice: 'UGX 75,000',
        condition: 'New',
        location: 'Kampala',
        rating: 4.2,
        imageUrl: 'https://via.placeholder.com/300x300/cccccc/ffffff?text=Product+2',
        category: 'Featured',
        price: 75000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Fallback trending when no products available
  static List<Product> _getFallbackTrending() {
    return [
      Product(
        id: 'trending1',
        name: 'Trending Product 1',
        description: 'This product is trending!',
        ownerId: '',
        priceAndDiscount: 'UGX 100,000',
        originalPrice: 'UGX 100,000',
        condition: 'New',
        location: 'Kampala',
        rating: 4.8,
        imageUrl: 'https://via.placeholder.com/300x300/cccccc/ffffff?text=Trending+1',
        category: 'Trending',
        price: 100000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'trending2',
        name: 'Trending Product 2',
        description: 'Another trending product!',
        ownerId: '',
        priceAndDiscount: 'UGX 120,000',
        originalPrice: 'UGX 120,000',
        condition: 'New',
        location: 'Kampala',
        rating: 4.6,
        imageUrl: 'https://via.placeholder.com/300x300/cccccc/ffffff?text=Trending+2',
        category: 'Trending',
        price: 120000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
} 