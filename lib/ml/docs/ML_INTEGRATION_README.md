# ML Integration Guide for Kampus Mart

## Overview
This guide covers the integration of Machine Learning capabilities into the Kampus Mart Flutter app, including search, recommendations, trending products, and user interaction tracking.

## Architecture

### Components
1. **MLApiService** (`lib/services/ml_api_service.dart`) - Core API communication
2. **EnhancedProductService** (`lib/services/enhanced_product_service.dart`) - Business logic layer
3. **MLConfig** (`lib/config/ml_config.dart`) - Configuration management
4. **UI Components** - Search suggestions, recommendations, enhanced search

### Data Flow
```
Flutter App → EnhancedProductService → MLApiService → FastAPI ML Backend
                ↓
            Fallback to Firebase
```

## Setup Instructions

### 1. FastAPI Backend Setup

#### Required Endpoints
Your FastAPI server should implement these endpoints:

```python
# Base URL: http://localhost:8000

# Search and Recommendations
POST /search - Semantic search
POST /recommendations - Personalized recommendations  
GET /trending - Trending products
POST /similar-products - Similar products
POST /search-suggestions - Search autocomplete

# Data Sync (NEW - for real app data)
POST /sync-products - Sync app products with ML model
POST /sync-interactions - Sync user interactions
POST /interactions - Record user interactions

# Category and Analytics
POST /category-recommendations - Category-based recommendations
```

#### New Endpoints for Real Data Integration

##### POST /sync-products
Sync your app's real products with the ML model:

```python
@app.post("/sync-products")
async def sync_products(products: List[ProductData]):
    """
    Sync app products with ML model for better recommendations
    """
    # Store products in ML model's database
    # Update product embeddings
    # Return success status
    return {"status": "success", "synced_count": len(products)}

class ProductData(BaseModel):
    product_id: str
    name: str
    description: str
    price: float
    category: str
    image_url: str
    seller_id: str
    condition: str
    location: str
    rating: float
    stock: int
    created_at: str
    updated_at: str
```

##### POST /sync-interactions
Sync user interactions for personalized recommendations:

```python
@app.post("/sync-interactions")
async def sync_interactions(interactions: List[InteractionData]):
    """
    Sync user interactions for ML model training
    """
    # Store interactions in ML model's database
    # Update user profiles and product embeddings
    # Return success status
    return {"status": "success", "synced_count": len(interactions)}

class InteractionData(BaseModel):
    user_id: str
    product_id: str
    interaction_type: str  # "view", "purchase", "like", "cart"
    timestamp: str
    metadata: dict
```

##### POST /interactions
Record real-time user interactions:

```python
@app.post("/interactions")
async def record_interaction(interaction: InteractionData):
    """
    Record a single user interaction in real-time
    """
    # Store interaction immediately
    # Update ML model if needed
    return {"status": "success"}
```

### 2. Flutter App Integration

#### Automatic Initialization
The ML integration is automatically initialized when the app starts:

```dart
// In main.dart
Future<void> _initializeMLIntegration() async {
  await EnhancedProductService.initializeMLIntegration();
}
```

#### Manual Sync
You can also manually sync data:

```dart
// Sync products
await MLApiService.syncProductsWithML();

// Sync user interactions  
await MLApiService.syncUserInteractions();
```

## Real Data Integration

### How It Works

1. **Product Sync**: When the app starts, it automatically syncs all your Firestore products with the ML API
2. **Interaction Sync**: User interactions (views, purchases, likes) are collected and synced
3. **Real-time Tracking**: New interactions are recorded as they happen
4. **ML Training**: Your ML model uses this real data to provide better recommendations

### Data Sources

The app collects interactions from:
- **Cart items** → View interactions
- **Orders** → Purchase interactions  
- **Favorites** → Like interactions
- **Product views** → View interactions (tracked in real-time)

### Benefits

- **Personalized Recommendations**: Based on real user behavior
- **Trending Products**: Based on actual interaction data
- **Better Search**: Semantic search trained on your products
- **Category Insights**: Understanding which categories are popular

## API Specifications

### Request/Response Formats

#### Recommendations Request
```json
{
  "user_id": "user123",
  "limit": 10,
  "category": "electronics",
  "preferences": {
    "price_range": [10000, 500000],
    "preferred_categories": ["laptops", "phones"]
  }
}
```

#### Recommendations Response
```json
[
  {
    "product_id": "laptop_001",
    "name": "MacBook Pro",
    "description": "Powerful laptop for developers",
    "price": 3500000.0,
    "score": 0.95
  }
]
```

#### Trending Response
```json
[
  {
    "product_id": "phone_001", 
    "name": "iPhone 15",
    "description": "Latest iPhone model",
    "price": 2500000.0,
    "interaction_count": 45
  }
]
```

## Integration Points

### 1. Home Page (`lib/screens/home_page.dart`)
- **Carousel**: Shows ML-powered recommendations/trending products
- **Product Grid**: Shows all products from backend
- **Tab Switching**: Dynamically loads different ML data

### 2. Product Details (`lib/screens/product_details_page.dart`)
- **Similar Products**: ML-powered similar product suggestions
- **Interaction Tracking**: Records product views

### 3. Search (`lib/screens/enhanced_search_screen.dart`)
- **Semantic Search**: ML-powered search beyond keywords
- **Search Suggestions**: Intelligent autocomplete

## Fallback Mechanisms

### When ML API is Unavailable
1. **Recommendations**: Fallback to highest-rated products
2. **Trending**: Fallback to recently added products
3. **Search**: Fallback to Firebase text search
4. **Similar Products**: Fallback to same category products

### Error Handling
- Network timeouts: 10 seconds
- Automatic retry: 3 attempts
- Graceful degradation to Firebase data

## Performance Optimization

### Caching Strategy
- **Recommendations**: Cache for 5 minutes
- **Trending**: Cache for 2 minutes
- **Search Results**: Cache for 1 minute

### Background Sync
- **Product Sync**: Runs on app startup
- **Interaction Sync**: Runs every 30 minutes
- **Real-time Tracking**: Immediate recording

## Analytics and Monitoring

### Debug Logging
Enable debug mode in `MLConfig`:
```dart
static const bool enableDebugLogging = true;
```

### Key Metrics
- API response times
- Cache hit rates
- Fallback usage
- User interaction rates

## Security Considerations

### API Security
- No API key required for localhost
- Production: Implement proper authentication
- Rate limiting recommended

### Data Privacy
- User interactions are anonymized
- No personal data sent to ML API
- Local data retention policies

## Testing

### Unit Tests
```bash
flutter test test/ml_integration_test.dart
```

### Integration Tests
```bash
flutter test test/ml_api_integration_test.dart
```

### Manual Testing
1. Start FastAPI server
2. Run Flutter app
3. Check console logs for ML integration
4. Verify carousel shows products
5. Test tab switching
6. Test search functionality

## Troubleshooting

### Common Issues

#### 1. Carousel Not Showing Products
**Symptoms**: Empty carousel or placeholder images
**Solutions**:
- Check FastAPI server is running
- Verify API endpoints are correct
- Check console logs for errors
- Ensure products exist in Firestore

#### 2. API Connection Errors
**Symptoms**: Network timeouts or 404 errors
**Solutions**:
- Verify `baseUrl` in `MLConfig`
- Check FastAPI server status
- Test endpoints manually with curl/Postman
- Check firewall settings

#### 3. Data Sync Issues
**Symptoms**: ML recommendations not improving
**Solutions**:
- Check product sync logs
- Verify interaction collection
- Ensure ML model is training on new data
- Check data format compatibility

### Debug Commands

#### Check ML API Status
```bash
curl http://localhost:8000/health
```

#### Test Recommendations
```bash
curl -X POST http://localhost:8000/recommendations \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test_user","limit":5}'
```

#### Test Product Sync
```bash
curl -X POST http://localhost:8000/sync-products \
  -H "Content-Type: application/json" \
  -d '{"products":[]}'
```

## Next Steps

### Immediate Actions
1. **Update FastAPI**: Add the new sync endpoints
2. **Test Integration**: Run the app and verify ML features work
3. **Monitor Logs**: Check console output for any issues
4. **Add Real Images**: Update ML API to include product image URLs

### Future Enhancements
1. **Advanced ML Features**: 
   - Price prediction
   - Demand forecasting
   - Fraud detection
2. **Real-time Updates**: WebSocket integration for live recommendations
3. **A/B Testing**: Compare ML vs non-ML performance
4. **User Feedback**: Collect explicit ratings and reviews

### Production Deployment
1. **Secure API**: Add authentication and rate limiting
2. **Scalable Infrastructure**: Deploy ML API to cloud
3. **Monitoring**: Add comprehensive logging and alerts
4. **Backup Strategy**: Implement data backup and recovery

## Support

For issues or questions:
1. Check console logs for error messages
2. Verify FastAPI server is running correctly
3. Test API endpoints manually
4. Review this documentation for troubleshooting steps

---

**Note**: This integration is designed to work with your existing Firebase backend while adding ML capabilities. The app will continue to function normally even if the ML API is unavailable, thanks to the fallback mechanisms. 