# ML API Setup Guide

## ✅ **ML Features Enabled!**

All ML features are now enabled in your Flutter app. The app will try to connect to the ML API server.

## 🚀 **To Start the ML API Server:**

### 1. **Install Python (if not installed)**
Download and install Python from: https://www.python.org/downloads/

### 2. **Start the ML API Server**
```bash
# Navigate to the ML API directory
cd ml-api-server

# Install dependencies
pip install -r requirements.txt

# Start the server
python app.py
```

The server will start on `http://localhost:8000`

### 3. **Test the API**
Visit `http://localhost:8000` in your browser to see the API documentation.

## 🎯 **ML Features Now Active:**

- ✅ **ML Search**: Semantic search with suggestions
- ✅ **Search Suggestions**: Real-time suggestions as you type
- ✅ **User Interaction Tracking**: Records product views and searches
- ✅ **Enhanced Search Screen**: Full ML-powered search experience
- ✅ **Fallback Mechanisms**: Falls back to regular search if ML API is down

## 🧪 **Testing ML Features:**

1. **Search Suggestions**: Type in the search bar to see ML-powered suggestions
2. **Enhanced Search**: Tap the search icon for full ML search experience
3. **Debug Button**: Use the orange bug icon to test ML search
4. **User Tracking**: Product views are automatically tracked for ML learning

## 📋 **API Endpoints Available:**

- `POST /search` - Semantic search for products
- `POST /search-suggestions` - Get search suggestions
- `POST /user_interactions` - Record user interactions
- `POST /recommendations` - Get personalized recommendations
- `GET /trending` - Get trending products
- `GET /health` - API health check

## 🔧 **If You Get Connection Errors:**

The app will automatically fall back to regular search if the ML API is not available. You'll see:
- Regular search results instead of ML-enhanced results
- No search suggestions
- Console logs showing connection attempts

## 🎉 **Ready to Use!**

Your Flutter app now has full ML integration! Start the Python server and enjoy enhanced search and recommendations! 🚀 