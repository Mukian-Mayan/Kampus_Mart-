import 'config/ml_config.dart';
import 'services/ml_api_service.dart';

class MLStatusChecker {
  static Future<Map<String, dynamic>> checkAllServices() async {
    final status = <String, dynamic>{};
    
    status['currentConfig'] = {
      'usingFallback': MLConfig.isUsingFallback,
      'apiBaseUrl': MLConfig.apiBaseUrl,
      'renderUrl': MLConfig.renderBaseUrl,
      'localhostUrl': MLConfig.localhostUrl,
    };
    
    try {
      final renderResponse = await MLApiService.isApiReachable();
      status['renderService'] = {
        'reachable': renderResponse,
        'url': MLConfig.renderBaseUrl,
      };
    } catch (e) {
      status['renderService'] = {
        'reachable': false,
        'error': e.toString(),
        'url': MLConfig.renderBaseUrl,
      };
    }
    
    try {
      final localhostResponse = await MLApiService.isLocalhostRunning();
      status['localhostService'] = {
        'reachable': localhostResponse,
        'url': MLConfig.localhostUrl,
      };
    } catch (e) {
      status['localhostService'] = {
        'reachable': false,
        'error': e.toString(),
        'url': MLConfig.localhostUrl,
      };
    }
    
    try {
      final currentResponse = await MLApiService.testConnection();
      status['currentConnection'] = {
        'connected': currentResponse,
        'url': MLConfig.apiBaseUrl,
      };
    } catch (e) {
      status['currentConnection'] = {
        'connected': false,
        'error': e.toString(),
        'url': MLConfig.apiBaseUrl,
      };
    }
    
    if (!status['renderService']['reachable'] && !status['localhostService']['reachable']) {
      // Both services offline
    } else if (status['renderService']['reachable'] && !MLConfig.isUsingFallback) {
      // Render service online
    } else if (status['localhostService']['reachable'] && MLConfig.isUsingFallback) {
      // Localhost service online as fallback
    } else if (status['renderService']['reachable'] && MLConfig.isUsingFallback) {
      // Render service back online
    } else if (!status['renderService']['reachable'] && status['localhostService']['reachable'] && !MLConfig.isUsingFallback) {
      MLConfig.switchToFallback();
    }
    
    return status;
  }
  
  static Future<void> quickCheck() async {
    await MLApiService.testConnection();
  }
} 