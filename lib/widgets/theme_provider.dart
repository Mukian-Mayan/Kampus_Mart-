// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _pushNotificationsEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationEnabled => _locationEnabled;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _locationKey = 'location_enabled';
  static const String _pushNotificationsKey = 'push_notifications_enabled';

  // Initialize theme settings from shared preferences
  Future<void> initializeTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _locationEnabled = prefs.getBool(_locationKey) ?? true;
    _pushNotificationsEnabled = prefs.getBool(_pushNotificationsKey) ?? true;
    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, _notificationsEnabled);
    notifyListeners();
  }

  // Toggle location
  Future<void> toggleLocation() async {
    _locationEnabled = !_locationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationKey, _locationEnabled);
    notifyListeners();
  }

  // Toggle push notifications
  Future<void> togglePushNotifications() async {
    _pushNotificationsEnabled = !_pushNotificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationsKey, _pushNotificationsEnabled);
    notifyListeners();
  }

  // Reset all settings to default
  Future<void> resetSettings() async {
    _isDarkMode = false;
    _notificationsEnabled = true;
    _locationEnabled = true;
    _pushNotificationsEnabled = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, false);
    await prefs.setBool(_notificationsKey, true);
    await prefs.setBool(_locationKey, true);
    await prefs.setBool(_pushNotificationsKey, true);
    
    notifyListeners();
  }

  // Get current theme data
  ThemeData get currentTheme {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Light theme
  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F4F0), // AppTheme.tertiaryOrange
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF7F4F0),
      foregroundColor: Color(0xFF1B365C),
      elevation: 0,
    ),
    cardColor: const Color(0xFFFDFDFD), // AppTheme.paleWhite
    primaryColor: const Color(0xFF1B365C), // AppTheme.deepBlue
  );

  // Dark theme with deep blue base
  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1B365C), // AppTheme.deepBlue
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B365C),
      foregroundColor: Color(0xFFFDFDFD),
      elevation: 0,
    ),
    cardColor: const Color(0xFF2D4A6B), // Darker shade of deepBlue
    primaryColor: const Color(0xFFFDFDFD), // AppTheme.paleWhite
  );
}