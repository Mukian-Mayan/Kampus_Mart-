import 'config/ml_config.dart';
import 'services/ml_api_service.dart';

class RenderConnectionTest {
  static Future<void> testRenderService() async {
    MLConfig.forcePrimaryMode();
    
    try {
      await MLApiService.isApiReachable();
    } catch (e) {
      // Handle error
    }
    
    try {
      await MLApiService.testConnection();
    } catch (e) {
      // Handle error
    }
  }
  
  static Future<bool> quickRenderCheck() async {
    MLConfig.forcePrimaryMode();
    
    try {
      return await MLApiService.isApiReachable();
    } catch (e) {
      return false;
    }
  }
} 