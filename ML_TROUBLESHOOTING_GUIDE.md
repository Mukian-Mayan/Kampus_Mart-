# ML API Troubleshooting Guide

## Current Issue Analysis

Based on your logs, the app is experiencing timeout issues when trying to connect to the ML API. Here's what's happening:

### Current Status:
- ✅ **Render Service**: `https://deployingml-f8pc.onrender.com` - Should be online
- ❌ **Localhost Fallback**: `http://10.0.2.2:8000` - Not running (causing timeouts)
- 🔄 **App Behavior**: Correctly switching to fallback, but fallback is not available

### Error Pattern:
```
HTTP request failed (attempt 3/3): TimeoutException after 0:00:10.000000: Future not completed
ML API using FALLBACK URL (Android): http://10.0.2.2:8000
Max retries reached, giving up
```

## Solutions

### Option 1: Use Only Render Service (Recommended)

Since your Render service is deployed and working, you can disable the localhost fallback:

1. **Update ML Configuration**:
   ```dart
   // In lib/ml/config/ml_config.dart
   static const bool enableFallbacks = false; // Disable fallback
   ```

2. **Or force primary mode**:
   ```dart
   // In your app initialization
   MLConfig.switchToPrimary();
   ```

### Option 2: Start Localhost Server

If you want to use localhost as fallback:

1. **Start your ML API server locally**:
   ```bash
   # Navigate to your ML API project directory
   cd /path/to/your/ml/api
   
   # Start the server on port 8000
   python app.py  # or whatever command starts your server
   ```

2. **Verify it's running**:
   ```bash
   curl http://localhost:8000/
   # Should return: {"message":"KMart ML API is running!"}
   ```

### Option 3: Smart Fallback (Implemented)

The app now has improved fallback logic:

1. **Faster timeouts** (5 seconds instead of 10)
2. **Pre-flight checks** before making requests
3. **Smart fallback detection**

## Testing the Fix

### Run Status Check:
```dart
// In your app, run this to check current status
await MLStatusChecker.checkAllServices();
```

### Expected Output:
```
=== ML API Status Check ===
Current Configuration:
  Using Fallback: false
  API Base URL: https://deployingml-f8pc.onrender.com

Testing Render Service...
  Render Service: ONLINE

Testing Localhost Service...
  Localhost Service: OFFLINE

Testing Current API Connection...
  Current Connection: SUCCESS

=== Recommendations ===
✅ Render service is online and being used
```

## Quick Fix Commands

### To Force Render Service Only:
```dart
MLConfig.switchToPrimary();
```

### To Check Current Status:
```dart
MLStatusChecker.quickCheck();
```

### To Run Full Diagnostics:
```dart
MLStatusChecker.checkAllServices();
```

## What's Fixed

1. **Reduced Timeouts**: From 10 seconds to 5 seconds for faster fallback
2. **Pre-flight Checks**: Check if API is reachable before making requests
3. **Smart Fallback**: Only use localhost if it's actually running
4. **Better Error Handling**: Non-critical errors don't break the app
5. **Status Monitoring**: Easy way to check service status

## Expected Behavior After Fix

- ✅ **No more timeout errors** in console
- ✅ **Faster response times** when services are unavailable
- ✅ **Clean fallback** to Firebase-based features when ML API is down
- ✅ **Automatic recovery** when services come back online

## Monitoring

The app will now show cleaner logs:
```
ML API using RENDER URL: https://deployingml-f8pc.onrender.com
ML API connection successful: KMart ML API is running!
```

Instead of timeout errors, you'll see:
```
ML API not reachable, skipping interaction recording
```

This means the app gracefully handles unavailable services without causing delays or errors. 