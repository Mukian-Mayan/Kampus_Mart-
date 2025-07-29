import 'config/ml_config.dart';
import 'services/ml_api_service.dart';

class MLConfigTest {
  static void testConfiguration() {
    final summary = MLConfig.configurationSummary;
  }
  
  static void testFallbackLogic() {
    MLConfig.switchToFallback();
    MLConfig.switchToPrimary();
  }
  
  static Future<void> testAPIConnection() async {
    await MLApiService.testConnection();
  }
  
  static Future<void> runAllTests() async {
    testConfiguration();
    testFallbackLogic();
    await testAPIConnection();
  }
} 