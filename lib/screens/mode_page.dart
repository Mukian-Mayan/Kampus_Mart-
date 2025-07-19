// ignore_for_file: deprecated_member_use, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import '../widgets/theme_provider.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:provider/provider.dart';
class ModeSettingsPage extends StatefulWidget {
  const ModeSettingsPage({super.key});

  @override
  State<ModeSettingsPage> createState() => _ModeSettingsPageState();
}

class _ModeSettingsPageState extends State<ModeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode 
          ? AppTheme.deepBlue 
          : AppTheme.tertiaryOrange,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode 
            ? AppTheme.deepBlue 
            : AppTheme.tertiaryOrange,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25, left: 25),
          child: Text(
            'App Settings',
            style: TextStyle(
              color: themeProvider.isDarkMode 
                  ? AppTheme.paleWhite 
                  : AppTheme.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 22, left: 25),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios, 
              color: themeProvider.isDarkMode 
                  ? AppTheme.paleWhite 
                  : AppTheme.deepBlue,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display Settings Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode 
                        ? AppTheme.paleWhite.withOpacity(0.1)
                        : AppTheme.paleWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.display_settings,
                            color: themeProvider.isDarkMode 
                                ? AppTheme.paleWhite 
                                : AppTheme.deepBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Display Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: themeProvider.isDarkMode 
                                  ? AppTheme.paleWhite 
                                  : AppTheme.deepBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Dark Mode Toggle
                      _buildToggleItem(
                        context,
                        themeProvider,
                        icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        title: 'Dark Mode',
                        subtitle: themeProvider.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                        value: themeProvider.isDarkMode,
                        onChanged: (value) async {
                          await themeProvider.toggleDarkMode();
                          _showSnackBar(context, '${value ? 'Dark' : 'Light'} mode ${value ? 'enabled' : 'disabled'}');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Notification Settings Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode 
                        ? AppTheme.paleWhite.withOpacity(0.1)
                        : AppTheme.paleWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: themeProvider.isDarkMode 
                                ? AppTheme.paleWhite 
                                : AppTheme.deepBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Notification Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: themeProvider.isDarkMode 
                                  ? AppTheme.paleWhite 
                                  : AppTheme.deepBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Push Notifications Toggle
                      _buildToggleItem(
                        context,
                        themeProvider,
                        icon: Icons.notifications_active,
                        title: 'Push Notifications',
                        subtitle: 'Receive notifications for orders and updates',
                        value: themeProvider.pushNotificationsEnabled,
                        onChanged: (value) async {
                          await themeProvider.togglePushNotifications();
                          _showSnackBar(context, 'Push notifications ${value ? 'enabled' : 'disabled'}');
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // General Notifications Toggle
                      _buildToggleItem(
                        context,
                        themeProvider,
                        icon: Icons.notification_important,
                        title: 'General Notifications',
                        subtitle: 'App updates and promotional notifications',
                        value: themeProvider.notificationsEnabled,
                        onChanged: (value) async {
                          await themeProvider.toggleNotifications();
                          _showSnackBar(context, 'General notifications ${value ? 'enabled' : 'disabled'}');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Privacy Settings Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode 
                        ? AppTheme.paleWhite.withOpacity(0.1)
                        : AppTheme.paleWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.privacy_tip,
                            color: themeProvider.isDarkMode 
                                ? AppTheme.paleWhite 
                                : AppTheme.deepBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Privacy Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: themeProvider.isDarkMode 
                                  ? AppTheme.paleWhite 
                                  : AppTheme.deepBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Location Services Toggle
                      _buildToggleItem(
                        context,
                        themeProvider,
                        icon: Icons.location_on,
                        title: 'Location Services',
                        subtitle: 'Allow app to access your location for delivery',
                        value: themeProvider.locationEnabled,
                        onChanged: (value) async {
                          await themeProvider.toggleLocation();
                          _showSnackBar(context, 'Location services ${value ? 'enabled' : 'disabled'}');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Additional Options Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode 
                        ? AppTheme.paleWhite.withOpacity(0.2)
                        : AppTheme.deepBlue,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Options',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.paleWhite,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Reset Settings Button
                      _buildActionButton(
                        context,
                        themeProvider,
                        icon: Icons.refresh,
                        title: 'Reset All Settings',
                        subtitle: 'Restore default app settings',
                        onTap: () {
                          _showResetDialog(context, themeProvider);
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Clear Cache Button
                      _buildActionButton(
                        context,
                        themeProvider,
                        icon: Icons.cleaning_services,
                        title: 'Clear Cache',
                        subtitle: 'Free up storage space',
                        onTap: () {
                          _showSnackBar(context, 'Cache cleared successfully');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context,
    ThemeProvider themeProvider, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: themeProvider.isDarkMode 
              ? AppTheme.paleWhite 
              : AppTheme.deepBlue,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode 
                      ? AppTheme.paleWhite 
                      : AppTheme.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode 
                      ? AppTheme.paleWhite.withOpacity(0.7) 
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: themeProvider.isDarkMode 
              ? AppTheme.tertiaryOrange 
              : AppTheme.deepBlue,
          activeTrackColor: themeProvider.isDarkMode 
              ? AppTheme.tertiaryOrange.withOpacity(0.5) 
              : AppTheme.tertiaryOrange,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeProvider themeProvider, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.paleWhite.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.paleWhite,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.paleWhite,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.paleWhite.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.paleWhite,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.deepBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reset Settings',
            style: TextStyle(
              color: AppTheme.deepBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to reset all settings to their default values?',
            style: TextStyle(
              color: AppTheme.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await themeProvider.resetSettings();
                Navigator.of(context).pop();
                _showSnackBar(context, 'Settings reset to default');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
              ),
              child: Text(
                'Reset',
                style: TextStyle(color: AppTheme.paleWhite),
              ),
            ),
          ],
        );
      },
    );
  }
}