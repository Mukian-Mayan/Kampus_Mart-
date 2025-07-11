import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/help_&_support_page.dart';
import 'package:kampusmart2/screens/payment_transactions.dart';
import 'package:kampusmart2/screens/about_us.dart';
import 'package:kampusmart2/screens/mode_page.dart';
import 'package:kampusmart2/screens/user_profile_page.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/widgets/detail_container.dart';
import 'package:kampusmart2/widgets/layout1.dart';
import 'package:kampusmart2/widgets/profile_pic_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            'Settings',
            style: TextStyle(
              color: AppTheme.deepBlue,
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
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.deepBlue),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: ProfilePicWidget(
                      radius: 100,
                      height: 200,
                      width: 200,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Layout1(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DetailContainer(
                            onTap: () {
                              // Navigate to profile edit page
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => const UserProfilePage(),
                                 ),
                               );
                            },
                            iconData: Icons.person,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'User name',
                            containerHeight: MediaQuery.of(context).size.height * 0.065,
                            containerWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          
                          DetailContainer(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentTransactions(),
                                ),
                              );
                            },
                            iconData: Icons.credit_card_rounded,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'Payment Method',
                            containerHeight: MediaQuery.of(context).size.height * 0.065,
                            containerWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          
                          DetailContainer(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ModeSettingsPage(),
                                ),
                              );
                            },
                            iconData: Icons.settings_applications,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'App Settings',
                            containerHeight: MediaQuery.of(context).size.height * 0.065,
                            containerWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          
                          DetailContainer(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutUsPage(),
                                ),
                              );
                            },
                            iconData: Icons.info_outline,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'About Us',
                            containerHeight: MediaQuery.of(context).size.height * 0.065,
                            containerWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          
                          DetailContainer(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HelpAndSupportPage(),
                                ),
                              );
                            },
                            iconData: Icons.support_agent,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'Help And Support',
                            containerHeight: MediaQuery.of(context).size.height * 0.065,
                            containerWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          
                          DetailContainer(
                            onTap: () {
                              _showLogoutDialog(context);
                            },
                            iconData: Icons.logout_rounded,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'Logout',
                            containerHeight: MediaQuery.of(context).size.height * 0.065,
                            containerWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(
              color: AppTheme.deepBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: AppTheme.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
                foregroundColor: AppTheme.paleWhite,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    // Add your logout logic here
    // For example:
    // - Clear user session/tokens
    // - Clear shared preferences
    // - Navigate to login screen
    
    // Example logout implementation:
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.clear();
    // });
    
    // Navigate to login screen and clear navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login', // Replace with your login route
      (Route<dynamic> route) => false,
    );
  }
}