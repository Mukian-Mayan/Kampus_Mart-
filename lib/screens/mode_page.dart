// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class ModeSettingsPage extends StatefulWidget {
  const ModeSettingsPage({super.key});

  @override
  State<ModeSettingsPage> createState() => _ModeSettingsPageState();
}

class _ModeSettingsPageState extends State<ModeSettingsPage> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = true;
  bool isLocationEnabled = true;
  bool isPushNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25, left: 25),
          child: Text(
            'App Settings',
            style: TextStyle(
              color: AppTheme.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(top: 22, left: 25),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.deepBlue),
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
                    color: AppTheme.paleWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
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
                            color: AppTheme.deepBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Display Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.deepBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Dark Mode Toggle
                      _buildToggleItem(
                        icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        title: 'Dark Mode',
                        subtitle: isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                        value: isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            isDarkMode = value;
                          });
                          // Here you would typically save to shared preferences
                          _showSnackBar('${value ? 'Dark' : 'Light'} mode ${value ? 'enabled' : 'disabled'}');
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
                    color: AppTheme.paleWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
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
                            color: AppTheme.deepBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Notification Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.deepBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Push Notifications Toggle
                      _buildToggleItem(
                        icon: Icons.notifications_active,
                        title: 'Push Notifications',
                        subtitle: 'Receive notifications for orders and updates',
                        value: isPushNotificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            isPushNotificationsEnabled = value;
                          });
                          _showSnackBar('Push notifications ${value ? 'enabled' : 'disabled'}');
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // General Notifications Toggle
                      _buildToggleItem(
                        icon: Icons.notification_important,
                        title: 'General Notifications',
                        subtitle: 'App updates and promotional notifications',
                        value: isNotificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            isNotificationsEnabled = value;
                          });
                          _showSnackBar('General notifications ${value ? 'enabled' : 'disabled'}');
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
                    color: AppTheme.paleWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
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
                            color: AppTheme.deepBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Privacy Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.deepBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Location Services Toggle
                      _buildToggleItem(
                        icon: Icons.location_on,
                        title: 'Location Services',
                        subtitle: 'Allow app to access your location for delivery',
                        value: isLocationEnabled,
                        onChanged: (value) {
                          setState(() {
                            isLocationEnabled = value;
                          });
                          _showSnackBar('Location services ${value ? 'enabled' : 'disabled'}');
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
                    color: AppTheme.deepBlue,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
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
                        icon: Icons.refresh,
                        title: 'Reset All Settings',
                        subtitle: 'Restore default app settings',
                        onTap: () {
                          _showResetDialog();
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Clear Cache Button
                      _buildActionButton(
                        icon: Icons.cleaning_services,
                        title: 'Clear Cache',
                        subtitle: 'Free up storage space',
                        onTap: () {
                          _showSnackBar('Cache cleared successfully');
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

  Widget _buildToggleItem({
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
          color: AppTheme.deepBlue,
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
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.deepBlue,
          activeTrackColor: AppTheme.tertiaryOrange,
        ),
      ],
    );
  }

  Widget _buildActionButton({
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

  void _showSnackBar(String message) {
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

  void _showResetDialog() {
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
              onPressed: () {
                setState(() {
                  isDarkMode = false;
                  isNotificationsEnabled = true;
                  isLocationEnabled = true;
                  isPushNotificationsEnabled = true;
                });
                Navigator.of(context).pop();
                _showSnackBar('Settings reset to default');
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