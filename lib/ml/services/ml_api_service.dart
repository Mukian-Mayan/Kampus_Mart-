import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/ml_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/product_service.dart';

class MLApiService {
  // Base URL for your ML API
  static String get baseUrl => MLConfig.apiBaseUrl;

  // API endpoints - Updated to match your real API
  static String get searchEndpoint => '/search';
  static String get recommendEndpoint => '/recommendations';
  static String get trendingEndpoint => '/trending';
  static String get similarProductsEndpoint => '/similar-products';
  static String get productDetailsEndpoint => '/products';

  //static String get apiKey => MLConfig.apiKeyValue;

  // HTTP client with better connection management
  static final http.Client _client = http.Client();

  // Connection timeout
  static const Duration _timeout = Duration(seconds: 10);

  // Headers for API requests (no Authorization needed)
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Connection': 'keep-alive',
    'Host': 'localhost:8000',
  };

  /// Make HTTP request with retry mechanism
  static Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    int maxRetries = 2,
  }) async {
    int attempt = 0;

    while (attempt <= maxRetries) {
      try {
        // Ensure we're using the correct base URL
        final baseUrl = MLConfig.apiBaseUrl;
        final uri = Uri.parse('$baseUrl$endpoint');

        print(
          'Making $method request to: $uri (attempt ${attempt + 1}/${maxRetries + 1})',
        );
        print('Base URL: $baseUrl');
        print('Full URL: $uri');

        http.Response response;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await _client
                .get(uri, headers: _headers)
                .timeout(_timeout);
            break;
          case 'POST':
            response = await _client
                .post(
                  uri,
                  headers: _headers,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(_timeout);
            break;
          default:
            throw Exception('Unsupported HTTP method: $method');
        }

        print('Response status: ${response.statusCode}');
        return response;
      } catch (e) {
        attempt++;
        print('HTTP request failed (attempt $attempt/${maxRetries + 1}): $e');
        print(
          'Request details - Method: $method, Endpoint: $endpoint, Base URL: ${MLConfig.apiBaseUrl}',
        );

        if (attempt > maxRetries) {
          print('Max retries reached, giving up');
          rethrow;
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: attempt));
      }
    }

    throw Exception('Unexpected error in _makeRequest');
  }

  /// Enhanced semantic search using ML model
  static Future<List<Product>> semanticSearch({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/search',
        body: {
          'query': query,
          'num_results': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseProductList(data['products']);
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in semantic search: $e');
      // Fallback to basic search if ML API fails
      return _fallbackSearch(query, limit);
    }
  }

  /// Get personalized product recommendations
  static Future<List<Product>> getRecommendations({
    int limit = 10,
    String? category,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in, using fallback products');
        return _getPopularProducts(limit: limit, category: category);
      }

      final requestBody = {
        'user_id': user.uid,
        'num_recommendations': limit,
      };

      print(
        'Calling recommendations API with body: ${jsonEncode(requestBody)}',
      );

      final response = await _makeRequest(
        'POST',
        recommendEndpoint,
        body: requestBody,
      );

      print('Recommendations API response status: ${response.statusCode}');
      print('Recommendations API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed response data: $data');

        // Handle direct array response from API
        List<dynamic> productsData = [];
        if (data is List) {
          productsData = data;
        } else if (data['recommendations'] != null) {
          productsData = data['recommendations'];
        } else if (data['products'] != null) {
          productsData = data['products'];
        } else {
          print('Unexpected response format: $data');
          return _getPopularProducts(limit: limit, category: category);
        }

        print('Products data to parse: $productsData');
        return await _parseProductList(productsData);
      } else {
        throw Exception('Recommendations failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      // Fallback to popular products
      return _getPopularProducts(limit: limit, category: category);
    }
  }

  /// Get trending products using ML analysis
  static Future<List<Product>> getTrendingProducts({
    int limit = 10,
    String? category,
    String timeFrame = 'week', // 'day', 'week', 'month'
  }) async {
    try {
      print('Calling trending API...');

      final response = await _makeRequest('GET', '$trendingEndpoint?days=7&limit=$limit');

      print('Trending API response status: ${response.statusCode}');
      print('Trending API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed trending response data: $data');

        // Handle direct array response from API
        List<dynamic> productsData = [];
        if (data is List) {
          productsData = data;
        } else if (data['trending_products'] != null) {
          productsData = data['trending_products'];
        } else if (data['products'] != null) {
          productsData = data['products'];
        } else {
          print('Unexpected trending response format: $data');
          return _getPopularProducts(limit: limit, category: category);
        }

        print('Trending products data to parse: $productsData');
        return await _parseProductList(productsData);
      } else {
        throw Exception('Trending products failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting trending products: $e');
      // Fallback to popular products
      return _getPopularProducts(limit: limit, category: category);
    }
  }

  /// Get similar products based on a product
  static Future<List<Product>> getSimilarProducts({
    required String productId,
    int limit = 8,
  }) async {
    try {
      // First check if API is reachable
      final isReachable = await isApiReachable();
      if (!isReachable) {
        print('ML API not reachable');
        return [];
      }

      final response = await _makeRequest(
        'GET',
        '/similar-products/$productId?limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseProductList(data['similar_products']);
      } else {
        print('Similar products API returned status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting similar products from ML API: $e');
      print('This is expected behavior - the app will use fallback methods');
      return [];
    }
  }

  /// Record user interaction for ML training
  static Future<void> recordInteraction({
    required String productId,
    required String interactionType, // 'view', 'click', 'purchase', 'favorite'
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _makeRequest(
        'POST',
        '/user_interactions',
        body: {
          'user_id': user.uid,
          'product_id': productId,
          'interaction_type': interactionType,
          'timestamp': DateTime.now().toIso8601String(),
          'metadata': metadata ?? {},
        },
      );
    } catch (e) {
      print('Error recording interaction: $e');
    }
  }

  /// Get search suggestions based on user behavior
  static Future<List<String>> getSearchSuggestions({
    required String partialQuery,
    int limit = 5,
  }) async {
    try {
      // Since your API doesn't have search suggestions, we'll create them from existing products
      final products = await ProductService.getAllProducts();
      final suggestions = <String>[];
      final partialLower = partialQuery.toLowerCase();
      
      // Get product names and categories that match the partial query
      for (final product in products) {
        if (suggestions.length >= limit) break;
        
        // Check product name
        if (product.name.toLowerCase().contains(partialLower)) {
          suggestions.add(product.name);
        }
        // Check category
        else if (product.category != null && 
                 product.category!.toLowerCase().contains(partialLower) &&
                 !suggestions.contains(product.category!)) {
          suggestions.add(product.category!);
        }
      }
      
      // Add common search terms if we don't have enough suggestions
      final commonTerms = ['laptop', 'phone', 'books', 'furniture', 'electronics'];
      for (final term in commonTerms) {
        if (suggestions.length >= limit) break;
        if (term.toLowerCase().contains(partialLower) && !suggestions.contains(term)) {
          suggestions.add(term);
        }
      }
      
      return suggestions;
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }

  /// Get category-based recommendations
  static Future<List<Product>> getCategoryRecommendations({
    required String category,
    int limit = 10,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final response = await _client.post(
        Uri.parse('$baseUrl/category-recommendations'),
        headers: _headers,
        body: jsonEncode({
          'category': category,
          'user_id': user?.uid,
          'limit': limit,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseProductList(data['recommendations']);
      } else {
        throw Exception(
          'Category recommendations failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error getting category recommendations: $e');
      return _getPopularProducts(limit: limit, category: category);
    }
  }

  /// Sync app's products with ML API
  static Future<bool> syncProductsWithML() async {
    try {
      print('Syncing products with ML API...');

      // Get all products from Firestore
      final products = await ProductService.getAllProducts();
      print('Found ${products.length} products to sync');

      if (products.isEmpty) {
        print('No products to sync');
        return false;
      }

      // Convert products to ML API format
      final productsData = products
          .map(
            (product) => {
              'product_id': product.id,
              'name': product.name,
              'description': product.description,
              'price': product.price ?? 0.0,
              'category': product.category ?? '',
              'image_url': product.imageUrl,
              'seller_id': product.ownerId,
              'condition': product.condition,
              'location': product.location,
              'rating': product.rating,
              'stock': product.stock ?? 0,
              'created_at': product.createdAt?.toIso8601String(),
              'updated_at': product.updatedAt?.toIso8601String(),
            },
          )
          .toList();

      final url = '$baseUrl/sync-products';
      print('Calling sync products API: $url');
      print('Syncing ${productsData.length} products');

      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({'products': productsData}),
      );

      print('Sync products API response status: ${response.statusCode}');
      print('Sync products API response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Products synced successfully with ML API');
        return true;
      } else {
        print('Failed to sync products: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error syncing products with ML API: $e');
      return false;
    }
  }

  /// Sync user interactions with ML API
  static Future<bool> syncUserInteractions() async {
    try {
      print('Syncing user interactions with ML API...');

      // Get user interactions from your app's data
      // This would typically come from your analytics or interaction tracking
      final interactions = await _getUserInteractions();
      print('Found ${interactions.length} interactions to sync');

      if (interactions.isEmpty) {
        print('No interactions to sync');
        return false;
      }

      final url = '$baseUrl/sync-interactions';
      print('Calling sync interactions API: $url');

      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({'interactions': interactions}),
      );

      print('Sync interactions API response status: ${response.statusCode}');
      print('Sync interactions API response body: ${response.body}');

      if (response.statusCode == 200) {
        print('User interactions synced successfully with ML API');
        return true;
      } else {
        print('Failed to sync interactions: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error syncing user interactions with ML API: $e');
      return false;
    }
  }

  /// Get user interactions from your app's data sources
  static Future<List<Map<String, dynamic>>> _getUserInteractions() async {
    try {
      final interactions = <Map<String, dynamic>>[];

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in, cannot get interactions');
        return interactions;
      }

      // Get user's cart items (view interactions)
      final cartItems = await FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('products')
          .get();

      for (var doc in cartItems.docs) {
        final data = doc.data();
        interactions.add({
          'user_id': user.uid,
          'product_id': data['productId'] ?? '',
          'interaction_type': 'view',
          'timestamp': DateTime.now().toIso8601String(),
          'metadata': {'source': 'cart', 'quantity': data['quantity'] ?? 1},
        });
      }

      // Get user's orders (purchase interactions)
      final orders = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (var doc in orders.docs) {
        final data = doc.data();
        final orderItems = data['items'] as List<dynamic>? ?? [];

        for (var item in orderItems) {
          interactions.add({
            'user_id': user.uid,
            'product_id': item['productId'] ?? '',
            'interaction_type': 'purchase',
            'timestamp':
                (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ??
                DateTime.now().toIso8601String(),
            'metadata': {
              'source': 'order',
              'order_id': doc.id,
              'quantity': item['quantity'] ?? 1,
              'price': item['price'] ?? 0.0,
            },
          });
        }
      }

      // Get user's favorites (like interactions)
      final favorites = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      for (var doc in favorites.docs) {
        interactions.add({
          'user_id': user.uid,
          'product_id': doc.id,
          'interaction_type': 'like',
          'timestamp': DateTime.now().toIso8601String(),
          'metadata': {'source': 'favorites'},
        });
      }

      print('Collected ${interactions.length} user interactions');
      return interactions;
    } catch (e) {
      print('Error getting user interactions: $e');
      return [];
    }
  }

  /// Initialize ML integration with real data
  static Future<bool> initializeMLWithRealData() async {
    try {
      print('Initializing ML integration with real data...');

      // Sync products first
      final productsSynced = await syncProductsWithML();
      if (!productsSynced) {
        print('Failed to sync products, but continuing...');
      }

      // Sync user interactions
      final interactionsSynced = await syncUserInteractions();
      if (!interactionsSynced) {
        print('Failed to sync interactions, but continuing...');
      }

      print('ML integration initialization completed');
      return productsSynced || interactionsSynced;
    } catch (e) {
      print('Error initializing ML integration: $e');
      return false;
    }
  }

  /// Check if ML API is reachable
  static Future<bool> isApiReachable() async {
    try {
      print('Checking if ML API is reachable...');

      // Try a simple ping to the base URL
      final baseUrl = MLConfig.apiBaseUrl;
      final uri = Uri.parse('$baseUrl/');

      print('Pinging: $uri');

      final response = await _client
          .get(
            uri,
            headers: {'Accept': 'application/json', 'Connection': 'keep-alive'},
          )
          .timeout(const Duration(seconds: 5));

      final isReachable = response.statusCode == 200;
      print('ML API reachable: $isReachable (Status: ${response.statusCode})');

      return isReachable;
    } catch (e) {
      print('ML API not reachable: $e');
      return false;
    }
  }

  /// Test ML API connection
  static Future<bool> testConnection() async {
    try {
      print('Testing ML API connection...');

      // First check if API is reachable
      final isReachable = await isApiReachable();
      if (!isReachable) {
        print('❌ ML API is not reachable');
        return false;
      }

      final response = await _makeRequest('GET', '/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ ML API connection successful: ${data['message']}');
        return true;
      } else {
        print('❌ ML API connection failed: Status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ ML API connection failed: $e');
      return false;
    }
  }

  /// Get ML API status and configuration
  static Future<Map<String, dynamic>> getApiStatus() async {
    try {
      final isConnected = await testConnection();
      return {
        'connected': isConnected,
        'baseUrl': baseUrl,
        'endpoints': {
          'search': searchEndpoint,
          'recommendations': recommendEndpoint,
          'trending': trendingEndpoint,
          'similarProducts': '/similar-products',
          'interactions': '/interactions',
        },
        'config': {'timeout': _timeout.inSeconds, 'headers': _headers},
      };
    } catch (e) {
      return {'connected': false, 'error': e.toString(), 'baseUrl': baseUrl};
    }
  }

  // Helper methods

  /// Parse product list from API response with real image URLs
  static Future<List<Product>> _parseProductList(
    List<dynamic> productsData,
  ) async {
    final products = <Product>[];

    for (final productData in productsData) {
      final data = Map<String, dynamic>.from(productData);
      final productId = data['product_id'] ?? data['id'] ?? '';

      // Try to get real product image from Firestore
      String imageUrl = data['imageUrl'] ?? data['image_url'] ?? '';
      if (imageUrl.isEmpty && productId.isNotEmpty) {
        try {
          print('Fetching real image for product: $productId');
          final realProduct = await ProductService.getProductById(productId);
          if (realProduct != null && realProduct.imageUrl.isNotEmpty) {
            imageUrl = realProduct.imageUrl;
            print('✅ Found real image for product $productId: $imageUrl');
          } else {
            print(
              '⚠️ No real image found for product $productId, using placeholder',
            );
          }
        } catch (e) {
          print('❌ Error fetching real image for product $productId: $e');
        }
      } else if (imageUrl.isNotEmpty) {
        print('✅ Using image from ML API for product $productId: $imageUrl');
      }

      // Use placeholder if no real image found
      if (imageUrl.isEmpty) {
        imageUrl =
            'https://via.placeholder.com/300x300/cccccc/ffffff?text=Product';
      }

      final product = Product(
        id: productId,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        ownerId: data['sellerId'] ?? data['ownerId'] ?? '',
        priceAndDiscount: 'UGX ${data['price']?.toString() ?? '0'}',
        originalPrice: 'UGX ${data['price']?.toString() ?? '0'}',
        condition: data['condition'] ?? 'New',
        location: data['location'] ?? 'Kampala',
        rating: (data['rating'] ?? data['score'] as num?)?.toDouble() ?? 0.0,
        imageUrl: imageUrl,
        imageUrls: data['imageUrls'] != null
            ? List<String>.from(data['imageUrls'])
            : [],
        bestOffer: data['bestOffer'] ?? false,
        category: data['category'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        discountPercentage:
            (data['discountPercentage'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: data['stock'] ?? 10,
      );

      products.add(product);
    }

    return products;
  }

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
      print('Getting popular products from Firebase...');
      final products = await ProductService.getAllProducts();

      if (products.isEmpty) {
        print('No products available for fallback');
        return [];
      }

      // Filter by category if specified
      List<Product> filteredProducts = products;
      if (category != null && category.isNotEmpty) {
        filteredProducts = products
            .where(
              (product) =>
                  product.category?.toLowerCase() == category.toLowerCase(),
            )
            .toList();
      }

      // Sort by rating and take top products
      filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));

      final result = filteredProducts.take(limit).toList();
      print('✅ Found ${result.length} popular products from Firebase');
      return result;
    } catch (e) {
      print('Fallback popular products failed: $e');
      return [];
    }
  }

  /// Close the HTTP client
  static void dispose() {
    _client.close();
  }
}
