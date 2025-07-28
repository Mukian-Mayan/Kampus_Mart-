class MLConfig {
  // ML API Configuration
  static const String baseUrl = 'http://localhost:8000';
  static const String environment = 'development';

  // API Endpoints (all relative paths)
  static const String searchEndpoint = '/search';
  static const String semanticSearchEndpoint = '/semantic-search';
  static const String recommendEndpoint = '/recommendations';
  static const String trendingEndpoint = '/trending';
  static const String similarProductsEndpoint = '/similar-products';
  static const String interactionsEndpoint = '/interactions';
  static const String searchSuggestionsEndpoint = '/search-suggestions';
  static const String categoryRecommendationsEndpoint =
      '/category-recommendations';

  // Feature Flags
  static const bool enableMLSearch = true; // ML API enabled
  static const bool enableMLRecommendations = true; // ML API enabled
  static const bool enableMLTrending = true; // ML API enabled
  static const bool enableMLSimilarProducts = true; // ML API enabled
  static const bool enableMLSearchSuggestions = true; // ML API enabled
  static const bool enableInteractionTracking = true; // ML API enabled

  // ML Model Configuration
  static const String searchModel = 'semantic-search-v1';
  static const String recommendationModel = 'collaborative-filtering-v1';
  static const String trendingModel = 'trending-analysis-v1';
  static const String similarityModel = 'product-similarity-v1';

  // Search Configuration
  static const int defaultSearchLimit = 20;
  static const int maxSearchLimit = 100;
  static const int searchSuggestionLimit = 5;

  // Recommendation Configuration
  static const int defaultRecommendationLimit = 10;
  static const int maxRecommendationLimit = 50;
  static const String defaultTimeFrame = 'week'; // 'day', 'week', 'month'

  // Similar Products Configuration
  static const int defaultSimilarProductsLimit = 8;
  static const int maxSimilarProductsLimit = 20;

  // Interaction Tracking Configuration
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

  // Fallback Configuration
  static const bool enableFallbacks = true;
  static const int fallbackTimeoutSeconds = 5;

  // Cache Configuration
  static const bool enableCaching = true;
  static const int cacheExpirationMinutes = 15;

  // Error Handling Configuration
  static const bool enableErrorReporting = true;
  static const bool enableRetryOnFailure = true;
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 1;

  // Performance Configuration
  static const int requestTimeoutSeconds = 10;
  static const bool enableRequestDebouncing = true;
  static const int debounceDelayMilliseconds = 300;

  // User Experience Configuration
  static const bool showLoadingStates = true;
  static const bool showErrorStates = true;
  static const bool showEmptyStates = true;

  // Analytics Configuration
  static const bool enableAnalytics = true;
  static const bool trackSearchQueries = true;
  static const bool trackRecommendationClicks = true;
  static const bool trackTrendingViews = true;

  // Development Configuration
  static const bool enableDebugLogging = true;
  static const bool enableMockResponses = false;
  static const String mockDataPath = 'assets/mock/ml_responses.json';

  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';

  // Get the appropriate base URL based on environment
  static String get apiBaseUrl {
    switch (environment) {
      case 'development':
        return 'http://localhost:8000';
      case 'staging':
        return 'http://localhost:8000';
      case 'production':
        return 'http://localhost:8000';
      default:
        return baseUrl;
    }
  }

  // // Get the appropriate API key based on environment
  // static String get apiKeyValue {
  //   switch (environment) {
  //     case 'development':
  //       return 'dev-api-key';
  //     case 'staging':
  //       return 'staging-api-key';
  //     case 'production':
  //       return apiKey;
  //     default:
  //       return apiKey;
  //   }
  // }

  //   // Validate configuration
  //   static bool get isConfigurationValid {
  //     return apiBaseUrl.isNotEmpty &&
  //         apiKeyValue.isNotEmpty &&
  //         !apiBaseUrl.contains('http://localhost:8000');
  //   }

  //   // Get configuration for debugging
  //   static Map<String, dynamic> get configurationSummary {
  //     return {
  //       'environment': environment,
  //       'baseUrl': apiBaseUrl,
  //       'hasApiKey': apiKeyValue.isNotEmpty,
  //       'enableMLSearch': enableMLSearch,
  //       'enableMLRecommendations': enableMLRecommendations,
  //       'enableMLTrending': enableMLTrending,
  //       'enableMLSimilarProducts': enableMLSimilarProducts,
  //       'enableMLSearchSuggestions': enableMLSearchSuggestions,
  //       'enableInteractionTracking': enableInteractionTracking,
  //       'enableFallbacks': enableFallbacks,
  //       'enableCaching': enableCaching,
  //       'enableErrorReporting': enableErrorReporting,
  //       'enableDebugLogging': enableDebugLogging,
  //       'isConfigurationValid': isConfigurationValid,
  //     };
  //   }
}
