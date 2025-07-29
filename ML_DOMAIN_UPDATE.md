# ML API Domain Update - Render Deployment with Localhost Fallback

## Overview
Updated the Kampus Mart Flutter app's ML API configuration to use the deployed Render service as the primary domain with automatic fallback to localhost when the Render service is unavailable.

## Changes Made

### 1. Updated ML Configuration (`lib/ml/config/ml_config.dart`)

**New Configuration:**
- **Primary Domain**: `https://deployingml-f8pc.onrender.com` (Render deployment)
- **Fallback Domain**: `http://localhost:8000` (local development)
- **Android Fallback**: `http://10.0.2.2:8000` (Android emulator)

**Key Features Added:**
- Automatic fallback detection and switching
- Platform-specific URL handling
- Fallback state tracking
- Configuration debugging methods

### 2. Enhanced ML API Service (`lib/ml/services/ml_api_service.dart`)

**New Features:**
- Automatic fallback when Render service is down
- Retry mechanism with fallback switching
- Connection testing capabilities
- Automatic recovery when primary service comes back online

**Fallback Logic:**
1. Attempts to connect to Render service first
2. If Render fails, automatically switches to localhost
3. Continues monitoring Render service availability
4. Automatically switches back to Render when it's available again

### 3. Test Configuration (`lib/ml/test_ml_config.dart`)

**Testing Capabilities:**
- Configuration validation
- Fallback logic testing
- API connection testing
- Comprehensive test suite

## How It Works

### Primary Mode (Default)
```
🌐 API Base URL: https://deployingml-f8pc.onrender.com
🔧 Using Fallback: false
```

### Fallback Mode (When Render is down)
```
🌐 API Base URL: http://localhost:8000 (or http://10.0.2.2:8000 for Android)
🔧 Using Fallback: true
```

### Automatic Switching
1. **Primary → Fallback**: When Render service fails to respond
2. **Fallback → Primary**: When Render service becomes available again
3. **Manual Control**: Available through `MLConfig.switchToFallback()` and `MLConfig.switchToPrimary()`

## Usage Examples

### Check Current Configuration
```dart
// Print current configuration
MLConfig.printConfiguration();

// Get configuration summary
final summary = MLConfig.configurationSummary;
print('Using Fallback: ${summary['isUsingFallback']}');
```

### Test API Connection
```dart
// Test if API is accessible
final isConnected = await MLApiService.testConnection();
print('API Connected: $isConnected');
```

### Manual Fallback Control
```dart
// Force switch to fallback
MLConfig.switchToFallback();

// Force switch back to primary
MLConfig.switchToPrimary();
```

### Run Complete Test Suite
```dart
// Run all tests
await MLConfigTest.runAllTests();
```

## API Endpoints

The following endpoints are available on both primary and fallback domains:

- `GET /` - Health check
- `POST /search` - Semantic search
- `POST /recommendations` - Product recommendations
- `GET /trending` - Trending products
- `POST /similar-products` - Similar products
- `POST /interactions` - User interactions
- `GET /search-suggestions` - Search suggestions

## Monitoring and Debugging

### Console Logs
The system provides detailed logging:
- `🚀 ML API using RENDER URL` - Using primary service
- `🔄 ML API using FALLBACK URL` - Using fallback service
- `⚠️ Primary service failed, switching to fallback` - Fallback triggered
- `✅ Render service is back online` - Recovery detected

### Configuration Status
```dart
// Check if currently using fallback
if (MLConfig.isUsingFallback) {
  print('Currently using localhost fallback');
} else {
  print('Using Render service');
}
```

## Deployment Notes

### Render Service
- **URL**: https://deployingml-f8pc.onrender.com
- **Status**: Confirmed running (returns `{"message":"KMart ML API is running!"}`)
- **Fallback**: Automatically switches to localhost if unavailable

### Local Development
- **URL**: http://localhost:8000
- **Android Emulator**: http://10.0.2.2:8000
- **Activation**: Automatic when Render service is down

## Benefits

1. **High Availability**: App continues working even when Render service is down
2. **Automatic Recovery**: Seamlessly switches back to Render when available
3. **Development Friendly**: Easy local development with automatic fallback
4. **Platform Aware**: Handles Android emulator vs iOS simulator differences
5. **Comprehensive Logging**: Detailed debugging information
6. **Test Coverage**: Complete test suite for validation

## Troubleshooting

### Common Issues

#### Duplicate Method Error
If you encounter a "testConnection is already declared in this scope" error:
- ✅ **Fixed**: Removed duplicate `testConnection` method from `MLApiService`
- The service now has only one comprehensive `testConnection` method
- All references have been updated to use the correct method

#### Connection Issues
- Check if Render service is accessible: https://deployingml-f8pc.onrender.com
- Verify localhost fallback is working: http://localhost:8000
- Check console logs for detailed error messages

#### Fallback Not Working
- Ensure localhost server is running on port 8000
- Check Android emulator uses `10.0.2.2:8000` instead of `localhost:8000`
- Verify network connectivity

## Future Enhancements

- Add health check monitoring
- Implement circuit breaker pattern
- Add metrics collection
- Support for multiple fallback endpoints
- Configuration via environment variables 