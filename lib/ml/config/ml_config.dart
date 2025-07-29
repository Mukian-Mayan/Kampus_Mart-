import 'dart:io';

/// ML Configuration - Central hub for all ML API settings and status
/// This class manages the connection to our deployed ML service on Render
/// and provides fallback mechanisms for local development
class MLConfig {
  // Primary ML API endpoint - our deployed service on Render
  static const String renderBaseUrl = 'https://deployingml-f8pc.onrender.com';
  
  // Fallback endpoints for local development
  static const String localhostBaseUrl = 'http://localhost:8000';
  static const String androidLocalhostUrl = 'http://10.0.2.2:8000';
  
  // Environment configuration
  static const String environment = 'development';

  /// Get the appropriate localhost URL based on platform
  /// Android emulator needs special IP, iOS/desktop uses localhost
  static String get localhostUrl => Platform.isAndroid ? androidLocalhostUrl : localhostBaseUrl;

  // API endpoints for different ML features
  static const String searchEndpoint = '/search';
  static const String semanticSearchEndpoint = '/semantic-search';
  static const String recommendEndpoint = '/recommendations';
  static const String trendingEndpoint = '/trending';
  static const String similarProductsEndpoint = '/similar-products';
  static const String interactionsEndpoint = '/interactions';
  static const String searchSuggestionsEndpoint = '/search-suggestions';
  static const String categoryRecommendationsEndpoint = '/category-recommendations';

  // Feature toggles - enable/disable specific ML capabilities
  static const bool enableMLSearch = true;
  static const bool enableMLRecommendations = true;
  static const bool enableMLTrending = true;
  static const bool enableMLSimilarProducts = true;
  static const bool enableMLSearchSuggestions = true;
  static const bool enableInteractionTracking = true;

  // ML model identifiers for different tasks
  static const String searchModel = 'semantic-search-v1';
  static const String recommendationModel = 'collaborative-filtering-v1';
  static const String trendingModel = 'trending-analysis-v1';
  static const String similarityModel = 'product-similarity-v1';

  // Search configuration limits
  static const int defaultSearchLimit = 20;
  static const int maxSearchLimit = 100;
  static const int searchSuggestionLimit = 5;

  // Recommendation settings
  static const int defaultRecommendationLimit = 10;
  static const int maxRecommendationLimit = 50;
  static const String defaultTimeFrame = 'week';

  // Similar products configuration
  static const int defaultSimilarProductsLimit = 8;
  static const int maxSimilarProductsLimit = 20;

  /// Valid interaction types that can be tracked for ML training
  /// These help the ML model understand user behavior patterns
  static const List<String> validInteractionTypes = [
    'view',
    'click',
    'search',
    'favorite',
    'unfavorite',
    'purchase',
    'add_to_cart',
    'remove_from_cart',
  ];

  // Fallback configuration - disabled since Render service is stable
  static const bool enableFallbacks = false;
  static const int fallbackTimeoutSeconds = 5;

  // Caching settings for performance
  static const bool enableCaching = true;
  static const int cacheExpirationMinutes = 15;

  // Error handling and retry logic
  static const bool enableErrorReporting = true;
  static const bool enableRetryOnFailure = true;
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 1;

  // Performance tuning
  static const int requestTimeoutSeconds = 10;
  static const bool enableRequestDebouncing = true;
  static const int debounceDelayMilliseconds = 300;

  // User experience settings
  static const bool showLoadingStates = true;
  static const bool showErrorStates = true;
  static const bool showEmptyStates = true;

  // Analytics and tracking configuration
  static const bool enableAnalytics = true;
  static const bool trackSearchQueries = true;
  static const bool trackRecommendationClicks = true;
  static const bool trackTrendingViews = true;

  // Development and debugging settings
  static const bool enableDebugLogging = true;
  static const bool enableMockResponses = false;
  static const String mockDataPath = 'assets/mock/ml_responses.json';

  /// Internal state tracking for fallback mode
  /// When true, we're using localhost instead of Render service
  static bool _isUsingFallback = false;

  // Environment getters for easy checking
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';
  static bool get isUsingFallback => _isUsingFallback;

  /// Get the current API base URL with intelligent fallback logic
  /// This method automatically switches between Render and localhost
  /// based on availability and configuration
  static String get apiBaseUrl {
    if (_isUsingFallback) {
      // We're in fallback mode - use local development server
      if (Platform.isAndroid) {
        print('ML API: Using Android emulator fallback (10.0.2.2:8000)');
        return androidLocalhostUrl;
      } else {
        print('ML API: Using localhost fallback (localhost:8000)');
        return localhostBaseUrl;
      }
    } else {
      // Primary mode - use our deployed Render service
      print('ML API: Using deployed Render service (deployingml-f8pc.onrender.com)');
      return renderBaseUrl;
    }
  }

  /// Switch to fallback mode when primary service is unavailable
  /// This is called automatically when Render service fails
  static void switchToFallback() {
    if (!_isUsingFallback) {
      _isUsingFallback = true;
      print('ML API: Switching to fallback mode - Render service unavailable');
      print('   Using localhost for ML features');
    }
  }

  /// Switch back to primary mode when Render service becomes available
  /// This is called automatically when we detect Render is back online
  static void switchToPrimary() {
    if (_isUsingFallback) {
      _isUsingFallback = false;
      print('ML API: Switching back to primary mode - Render service restored');
      print('   Using deployed service for ML features');
    }
  }

  /// Force primary mode - useful for initialization and testing
  /// This ensures we start with the deployed service
  static void forcePrimaryMode() {
    _isUsingFallback = false;
    print('ML API: Forced to primary mode - using Render service');
  }

  /// Get the appropriate host header for HTTP requests
  /// This ensures proper routing to the correct service
  static String get hostHeader {
    if (_isUsingFallback) {
      return Platform.isAndroid ? '10.0.2.2:8000' : 'localhost:8000';
    } else {
      return 'deployingml-f8pc.onrender.com';
    }
  }

  /// Print current configuration status for debugging
  /// Shows which service we're using and current settings
  static void printConfiguration() {
    print('\nML Configuration Status:');
    print('   Environment: $environment');
    print('   Platform: ${Platform.isAndroid ? 'Android' : 'iOS/Desktop'}');
    print('   API Base URL: $apiBaseUrl');
    print('   Host Header: $hostHeader');
    print('   Using Fallback: $_isUsingFallback');
    print('   Render URL: $renderBaseUrl');
    print('   Localhost URL: ${Platform.isAndroid ? androidLocalhostUrl : localhostBaseUrl}');
    print('   ML Features Enabled: ${enableMLSearch ? 'Yes' : 'No'}');
    print('   Debug Logging: ${enableDebugLogging ? 'Yes' : 'No'}');
  }

  /// Get comprehensive configuration summary for external use
  /// Returns a map with all current settings and status
  static Map<String, dynamic> get configurationSummary {
    return {
      'environment': environment,
      'baseUrl': apiBaseUrl,
      'isUsingFallback': _isUsingFallback,
      'renderBaseUrl': renderBaseUrl,
      'localhostBaseUrl': Platform.isAndroid ? androidLocalhostUrl : localhostBaseUrl,
      'enableMLSearch': enableMLSearch,
      'enableMLRecommendations': enableMLRecommendations,
      'enableMLTrending': enableMLTrending,
      'enableMLSimilarProducts': enableMLSimilarProducts,
      'enableMLSearchSuggestions': enableMLSearchSuggestions,
      'enableInteractionTracking': enableInteractionTracking,
      'enableFallbacks': enableFallbacks,
      'enableCaching': enableCaching,
      'enableErrorReporting': enableErrorReporting,
      'enableDebugLogging': enableDebugLogging,
    };
  }
}
