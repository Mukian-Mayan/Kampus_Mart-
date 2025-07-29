import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/ml_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/product_service.dart';

/// ML API Service - Handles all communication with our deployed ML service
/// This service provides intelligent search, recommendations, and trending analysis
/// It automatically handles fallback to localhost when the deployed service is unavailable
class MLApiService {
  /// Get the current base URL for ML API requests
  /// This automatically switches between Render and localhost based on availability
  static String get baseUrl => MLConfig.apiBaseUrl;

  /// API endpoints for different ML features
  static String get searchEndpoint => '/search';
  static String get recommendEndpoint => '/recommendations';
  static String get trendingEndpoint => '/trending';
  static String get similarProductsEndpoint => '/similar-products';
  static String get productDetailsEndpoint => '/products';

  /// HTTP client for making requests to the ML API
  /// Configured with connection pooling for better performance
  static final http.Client _client = http.Client();

  /// Request timeout - reduced for faster fallback detection
  static const Duration _timeout = Duration(seconds: 5);

  /// HTTP headers for API requests
  /// Includes proper content type and host headers for routing
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Connection': 'keep-alive',
    'Host': MLConfig.hostHeader,
  };

  /// Make HTTP request with intelligent retry and fallback logic
  /// This method handles automatic switching between Render and localhost
  /// when the primary service becomes unavailable
  static Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    int maxRetries = 2,
  }) async {
    int attempt = 0;
    bool triedFallback = false;

    while (attempt <= maxRetries) {
      try {
        final baseUrl = MLConfig.apiBaseUrl;
        final uri = Uri.parse('$baseUrl$endpoint');

        print('ML API: Making $method request to $endpoint');
        print('   URL: $uri');
        print(
          '   Using: ${MLConfig.isUsingFallback ? 'Fallback' : 'Primary'} service',
        );

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

        print('ML API: Request successful (Status: ${response.statusCode})');

        // If we're using fallback and got a successful response, try switching back to primary
        if (MLConfig.isUsingFallback && response.statusCode == 200) {
          print(
            'ML API: Fallback successful, attempting to switch back to primary service',
          );
          MLConfig.switchToPrimary();
        }

        return response;
      } catch (e) {
        attempt++;
        print(' ML API: Request failed (attempt $attempt/${maxRetries + 1})');
        print('   Error: $e');
        print('   Endpoint: $endpoint');

        // Only switch to fallback if we've exhausted all retries and we're not already using fallback
        if (!triedFallback &&
            !MLConfig.isUsingFallback &&
            attempt >= maxRetries) {
          print('ML API: Primary service failed, switching to fallback');
          MLConfig.switchToFallback();
          triedFallback = true;
          attempt = 0; // Reset attempt counter for fallback
          continue;
        }

        if (attempt > maxRetries) {
          print('ML API: Max retries reached, giving up');
          rethrow;
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(Duration(seconds: attempt));
      }
    }

    throw Exception('Unexpected error in _makeRequest');
  }

  /// Enhanced semantic search using our ML model
  /// Provides intelligent search results based on meaning, not just keywords
  static Future<List<Product>> semanticSearch({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    print('ML API: Starting semantic search for "$query"');

    try {
      final response = await _makeRequest(
        'POST',
        '/search',
        body: {'query': query, 'num_results': limit},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
          'ML API: Semantic search successful, found ${data['products']?.length ?? 0} results',
        );
        return _parseProductList(data['products']);
      } else {
        print(
          'ML API: Semantic search failed with status ${response.statusCode}',
        );
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('ML API: Semantic search failed, falling back to basic search');
      print('   Error: $e');
      return _fallbackSearch(query, limit);
    }
  }

  /// Get personalized product recommendations based on user behavior
  /// Uses collaborative filtering to suggest products the user might like
  static Future<List<Product>> getRecommendations({
    int limit = 10,
    String? category,
    Map<String, dynamic>? userPreferences,
  }) async {
    print('ML API: Getting personalized recommendations');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('ML API: No user logged in, using popular products');
        return _getPopularProducts(limit: limit, category: category);
      }

      final requestBody = {'user_id': user.uid, 'num_recommendations': limit};

      print('ML API: Requesting recommendations for user ${user.uid}');

      final response = await _makeRequest(
        'POST',
        recommendEndpoint,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> productsData = [];
        if (data is List) {
          productsData = data;
        } else if (data['recommendations'] != null) {
          productsData = data['recommendations'];
        } else if (data['products'] != null) {
          productsData = data['products'];
        } else {
          print('ML API: Unexpected response format, using popular products');
          return _getPopularProducts(limit: limit, category: category);
        }

        print(
          'ML API: Recommendations successful, found ${productsData.length} products',
        );
        return await _parseProductList(productsData);
      } else {
        print(
          'ML API: Recommendations failed with status ${response.statusCode}',
        );
        throw Exception('Recommendations failed: ${response.statusCode}');
      }
    } catch (e) {
      print('ML API: Recommendations failed, falling back to popular products');
      print('   Error: $e');
      return _getPopularProducts(limit: limit, category: category);
    }
  }

  /// Get trending products based on recent user interactions
  /// Analyzes user behavior to identify what's currently popular
  static Future<List<Product>> getTrendingProducts({
    int limit = 10,
    String? category,
    String timeFrame = 'week',
  }) async {
    print('ML API: Getting trending products (timeframe: $timeFrame)');

    try {
      final response = await _makeRequest(
        'GET',
        '$trendingEndpoint?days=7&limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> productsData = [];
        if (data is List) {
          productsData = data;
        } else if (data['trending'] != null) {
          productsData = data['trending'];
        } else if (data['products'] != null) {
          productsData = data['products'];
        } else {
          print(
            'ML API: Unexpected trending response format, using popular products',
          );
          return _getPopularProducts(limit: limit, category: category);
        }

        print(
          'ML API: Trending products successful, found ${productsData.length} products',
        );
        return await _parseProductList(productsData);
      } else {
        print('ML API: Trending failed with status ${response.statusCode}');
        throw Exception('Trending failed: ${response.statusCode}');
      }
    } catch (e) {
      print('ML API: Trending failed, falling back to popular products');
      print('   Error: $e');
      return _getPopularProducts(limit: limit, category: category);
    }
  }

  /// Get similar products based on a given product
  /// Uses ML to find products that are similar in features or user preferences
  static Future<List<Product>> getSimilarProducts({
    required String productId,
    int limit = 8,
  }) async {
    print(' ML API: Getting similar products for product $productId');

    try {
      final isReachable = await isApiReachable();
      if (!isReachable) {
        print('ML API: Service not reachable for similar products');
        return [];
      }

      final response = await _makeRequest(
        'GET',
        '/similar-products/$productId?limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
          'ML API: Similar products successful, found ${data['similar_products']?.length ?? 0} products',
        );
        return _parseProductList(data['similar_products']);
      } else {
        print(
          'ML API: Similar products failed with status ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('ML API: Similar products failed');
      print('   Error: $e');
      return [];
    }
  }

  /// Record user interaction for ML training and personalization
  /// This helps improve recommendations and trending analysis
  static Future<void> recordInteraction({
    required String productId,
    required String interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    print(
      'ML API: Recording interaction - $interactionType for product $productId',
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('ML API: No user logged in, skipping interaction recording');
        return;
      }

      final isReachable = await isApiReachable();
      if (!isReachable) {
        print('ML API: Service not reachable, skipping interaction recording');
        return;
      }

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

      print('ML API: Interaction recorded successfully');
    } catch (e) {
      print('ML API: Failed to record interaction (non-critical)');
      print('   Error: $e');
      // Non-critical functionality, don't throw
    }
  }

  /// Get search suggestions based on user behavior and product data
  /// Provides intelligent autocomplete suggestions
  static Future<List<String>> getSearchSuggestions({
    required String partialQuery,
    int limit = 5,
  }) async {
    print(' ML API: Getting search suggestions for "$partialQuery"');

    try {
      // Since your API doesn't have search suggestions, we'll create them from existing products
      final products = await ProductService.getAllProducts();
      final suggestions = <String>[];
      final partialLower = partialQuery.toLowerCase();

      // Get product names and categories that match the partial query
      for (final product in products) {
        if (suggestions.length >= limit) break;

        if (product.name.toLowerCase().contains(partialLower)) {
          suggestions.add(product.name);
        } else if (product.category != null &&
            product.category!.toLowerCase().contains(partialLower) &&
            !suggestions.contains(product.category!)) {
          suggestions.add(product.category!);
        }
      }

      // Add common search terms if we don't have enough suggestions
      final commonTerms = [
        'laptop',
        'phone',
        'books',
        'furniture',
        'electronics',
      ];
      for (final term in commonTerms) {
        if (suggestions.length >= limit) break;
        if (term.toLowerCase().contains(partialLower) &&
            !suggestions.contains(term)) {
          suggestions.add(term);
        }
      }

      print('ML API: Generated ${suggestions.length} search suggestions');
      return suggestions;
    } catch (e) {
      print('ML API: Failed to generate search suggestions');
      print('   Error: $e');
      return [];
    }
  }

  /// Get category-based recommendations
  /// Suggests products within a specific category
  static Future<List<Product>> getCategoryRecommendations({
    required String category,
    int limit = 10,
  }) async {
    print(' ML API: Getting category recommendations for "$category"');

    try {
      final products = await ProductService.getProductsByCategory(category);
      print(
        'ML API: Found ${products.length} products in category "$category"',
      );
      return products.take(limit).toList();
    } catch (e) {
      print('ML API: Category recommendations failed');
      print('   Error: $e');
      return [];
    }
  }

  /// Check if the ML API is reachable and responding
  /// Used for health checks and fallback decisions
  static Future<bool> isApiReachable() async {
    try {
      final baseUrl = MLConfig.apiBaseUrl;
      final uri = Uri.parse('$baseUrl/');

      print('ML API: Checking service health at $uri');

      final response = await _client
          .get(
            uri,
            headers: {'Accept': 'application/json', 'Connection': 'keep-alive'},
          )
          .timeout(const Duration(seconds: 3));

      final isReachable = response.statusCode == 200;
      print(
        '${isReachable ? '✅' : '❌'} ML API: Service ${isReachable ? 'is' : 'is not'} reachable',
      );

      if (isReachable) {
        final data = jsonDecode(response.body);
        print('   Response: ${data['message'] ?? 'OK'}');
      }

      return isReachable;
    } catch (e) {
      print('ML API: Service health check failed');
      print('   Error: $e');
      return false;
    }
  }

  /// Test the ML API connection and functionality
  /// Performs a comprehensive health check
  static Future<bool> testConnection() async {
    print('ML API: Testing connection and functionality');

    try {
      final isReachable = await isApiReachable();
      if (!isReachable) {
        print('ML API: Service is not reachable');
        return false;
      }

      final response = await _makeRequest('GET', '/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('ML API: Connection test successful');
        print('   Service: ${data['message'] ?? 'OK'}');
        return true;
      } else {
        print(
          'ML API: Connection test failed with status ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      print('ML API: Connection test failed');
      print('   Error: $e');
      return false;
    }
  }

  /// Get comprehensive API status and configuration
  /// Returns detailed information about the ML service
  static Future<Map<String, dynamic>> getApiStatus() async {
    print('ML API: Getting service status and configuration');

    try {
      final isConnected = await testConnection();
      final status = {
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

      print('ML API: Status retrieved successfully');
      print('   Connected: $isConnected');
      print('   Base URL: $baseUrl');

      return status;
    } catch (e) {
      print('ML API: Failed to get status');
      print('   Error: $e');
      return {'connected': false, 'error': e.toString(), 'baseUrl': baseUrl};
    }
  }

  /// Parse product list from API response with real image URLs
  /// Converts API data to our Product model format
  static Future<List<Product>> _parseProductList(
    List<dynamic> productsData,
  ) async {
    print('ML API: Parsing ${productsData.length} products from response');

    final products = <Product>[];

    for (final productData in productsData) {
      final data = Map<String, dynamic>.from(productData);
      final productId = data['product_id'] ?? data['id'] ?? '';

      String imageUrl = data['imageUrl'] ?? data['image_url'] ?? '';
      if (imageUrl.isEmpty && productId.isNotEmpty) {
        try {
          final realProduct = await ProductService.getProductById(productId);
          if (realProduct != null && realProduct.imageUrl.isNotEmpty) {
            imageUrl = realProduct.imageUrl;
          }
        } catch (e) {
          // Continue with placeholder
        }
      }

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

    print('ML API: Successfully parsed ${products.length} products');
    return products;
  }

  /// Fallback search when ML API is unavailable
  /// Uses basic Firebase search as backup
  static Future<List<Product>> _fallbackSearch(String query, int limit) async {
    print('ML API: Using fallback search for "$query"');

    try {
      final results = await ProductService.searchProducts(query);
      print(
        'ML API: Fallback search successful, found ${results.length} results',
      );
      return results;
    } catch (e) {
      print('ML API: Fallback search failed');
      print('   Error: $e');
      return [];
    }
  }

  /// Fallback to popular products when ML API is unavailable
  /// Returns top-rated products from Firebase
  static Future<List<Product>> _getPopularProducts({
    int limit = 10,
    String? category,
  }) async {
    print('ML API: Getting popular products from Firebase');

    try {
      final products = await ProductService.getAllProducts();

      if (products.isEmpty) {
        print('ML API: No products available for fallback');
        return [];
      }

      List<Product> filteredProducts = products;
      if (category != null && category.isNotEmpty) {
        filteredProducts = products
            .where(
              (product) =>
                  product.category?.toLowerCase() == category.toLowerCase(),
            )
            .toList();
      }

      filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
      final result = filteredProducts.take(limit).toList();

      print('ML API: Found ${result.length} popular products from Firebase');
      return result;
    } catch (e) {
      print('ML API: Fallback popular products failed');
      print('   Error: $e');
      return [];
    }
  }

  /// Check if localhost fallback is actually running
  /// Used to determine if we should switch to fallback mode
  static Future<bool> isLocalhostRunning() async {
    try {
      final localhostUrl = Platform.isAndroid
          ? MLConfig.androidLocalhostUrl
          : MLConfig.localhostBaseUrl;

      print('ML API: Checking if localhost is running at $localhostUrl');

      final response = await _client
          .get(Uri.parse('$localhostUrl/'))
          .timeout(const Duration(seconds: 2));

      final isRunning = response.statusCode == 200;
      print(
        '${isRunning ? '✅' : '❌'} ML API: Localhost ${isRunning ? 'is' : 'is not'} running',
      );

      return isRunning;
    } catch (e) {
      print(' ML API: Localhost not running');
      print('   Error: $e');
      return false;
    }
  }

  /// Check if Render service is available and switch back if it is
  /// Automatically restores primary service when it becomes available
  static Future<void> checkAndSwitchToPrimary() async {
    if (MLConfig.isUsingFallback) {
      print(' ML API: Checking if primary service is back online');

      try {
        MLConfig.switchToPrimary();
        final response = await _client
            .get(Uri.parse('${MLConfig.renderBaseUrl}/'))
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          print('ML API: Primary service is back online, staying with primary');
        } else {
          print(
            'ML API: Primary service still down, switching back to fallback',
          );
          MLConfig.switchToFallback();
        }
      } catch (e) {
        print('ML API: Primary service still down, staying with fallback');
        print('   Error: $e');
        MLConfig.switchToFallback();
      }
    }
  }

  /// Smart fallback strategy - only use localhost if it's actually running
  /// Prevents switching to a non-functioning fallback service
  static Future<void> smartFallbackCheck() async {
    if (MLConfig.isUsingFallback) {
      print('ML API: Performing smart fallback check');

      final localhostRunning = await isLocalhostRunning();
      if (!localhostRunning) {
        print(
          'ML API: Localhost fallback not running, switching back to Render service',
        );
        MLConfig.switchToPrimary();
      } else {
        print('ML API: Localhost fallback is running, staying with fallback');
      }
    }
  }

  /// Close the HTTP client to free up resources
  /// Should be called when the app is shutting down
  static void dispose() {
    print('ML API: Disposing HTTP client');
    _client.close();
  }
}
