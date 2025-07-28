# ML Module

This directory contains all machine learning related components for the Kampus Mart application.

## Structure

```
lib/ml/
├── services/           # ML API services and enhanced product services
├── widgets/           # ML-powered UI widgets
├── screens/           # ML-enhanced screens
├── config/            # ML configuration
├── docs/              # ML documentation
├── ml_module.dart     # Module index for easy imports
└── README.md          # This file
```

## Components

### Services
- **ml_api_service.dart**: Handles communication with ML APIs for search and recommendations
- **enhanced_product_service.dart**: Provides ML-enhanced product search and recommendation features

### Widgets
- **ml_search_suggestions.dart**: Widget for displaying ML-powered search suggestions
- **product_recommendations.dart**: Widget for displaying personalized product recommendations

### Screens
- **enhanced_search_screen.dart**: ML-enhanced search screen with semantic search capabilities

### Configuration
- **ml_config.dart**: Configuration for ML API endpoints and settings

### Documentation
- **ML_INTEGRATION_README.md**: Detailed documentation for ML integration

## Usage

### Import the entire module
```dart
import 'package:kampusmart2/ml/ml_module.dart';
```

### Import specific components
```dart
import 'package:kampusmart2/ml/services/enhanced_product_service.dart';
import 'package:kampusmart2/ml/widgets/ml_search_suggestions.dart';
import 'package:kampusmart2/ml/screens/enhanced_search_screen.dart';
```

## Features

- **Semantic Search**: AI-powered search that understands user intent
- **Personalized Recommendations**: ML-based product recommendations
- **Search Suggestions**: Real-time search suggestions as users type
- **Trending Products**: ML-powered trending product detection
- **Similar Products**: Find similar products using ML algorithms

## Configuration

Update the ML configuration in `config/ml_config.dart` to point to your ML API endpoints.

## Dependencies

- http: For API communication
- firebase_auth: For user authentication
- cloud_firestore: For data storage
- flutter: For UI components 