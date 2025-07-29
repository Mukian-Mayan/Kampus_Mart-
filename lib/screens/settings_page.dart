// ignore_for_file: override_on_non_overriding_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/edit_profile_screen.dart';
import 'package:kampusmart2/screens/seller_profile_edit_screen.dart';
import 'package:kampusmart2/screens/help_&_support_page.dart';
import 'package:kampusmart2/screens/login_or_register_page.dart';
import 'package:kampusmart2/screens/payment_transactions.dart';
import 'package:kampusmart2/screens/about_us.dart';
import 'package:kampusmart2/screens/mode_page.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar2.dart';
import 'package:kampusmart2/widgets/circle_design.dart';
import 'package:kampusmart2/widgets/detail_container.dart';
import 'package:kampusmart2/widgets/glass_container.dart';
import 'package:kampusmart2/widgets/layout1.dart';
import 'package:kampusmart2/widgets/layout2.dart';
import 'package:kampusmart2/widgets/layout3.dart';
//import 'package:kampusmart2/widgets/profile_pic_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final UserRole userRole;
  const SettingsPage({super.key, required this.userRole});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userRole;
  int selectedIndex = 3;

  void logoutUser() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Logging out...'),
            ],
          ),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear session data

      // Clear Firestore cache to prevent permission errors
      try {
        await FirebaseFirestore.instance.terminate();
        await FirebaseFirestore.instance.clearPersistence();
      } catch (e) {
        print('Firestore cleanup error: $e');
      }

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  //initial link up
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role');
    });
  }

  //till here guys

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      // Update the bottomNavigationBar section to match home_page.dart
      bottomNavigationBar: widget.userRole == UserRole.seller
          ? BottomNavBar2(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            )
          : BottomNavBar(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            ),
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
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /*const Center(
                    child: ProfilePicWidget(
                      radius: 60,
                      height: 120,
                      width: 120,
                      isEditable: true,
                    ),
                  ),*/

                  //CircleDesign(baseSize: 100,),
                  const SizedBox(height: 40),
                  Stack(
                    children: [
                      //Layout2(),
                      Layout3(),
                      GlassContainer(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DetailContainer(
                                onTap: () async {
                                  // Navigate to appropriate profile edit page based on user role
                                  Widget profileScreen;
                                  if (widget.userRole == UserRole.seller) {
                                    profileScreen =
                                        const SellerProfileEditScreen();
                                  } else {
                                    profileScreen = const EditProfileScreen();
                                  }
                  
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => profileScreen,
                                    ),
                                  );
                  
                                  // Refresh the screen if profile was updated
                                  if (result == true) {
                                    setState(() {});
                                  }
                                },
                                iconData: Icons.person,
                                fontColor: AppTheme.paleWhite,
                                fontSize: 20,
                                text: ' Profile ',
                                
                              ),
                  
                              DetailContainer(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PaymentTransactions(),
                                    ),
                                  );
                                },
                                iconData: Icons.credit_card_rounded,
                                fontColor: AppTheme.paleWhite,
                                fontSize: 20,
                                text: 'Payment Method',
                                
                              ),
                  
                              DetailContainer(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ModeSettingsPage(),
                                    ),
                                  );
                                },
                                iconData: Icons.settings_applications,
                                fontColor: AppTheme.paleWhite,
                                fontSize: 20,
                                text: 'App Settings',
                                
                              ),
                  
                              DetailContainer(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AboutUsPage(),
                                    ),
                                  );
                                },
                                iconData: Icons.info_outline,
                                fontColor: AppTheme.paleWhite,
                                fontSize: 20,
                                text: 'About Us',
                                
                              ),
                  
                              DetailContainer(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HelpAndSupportPage(),
                                    ),
                                  );
                                },
                                iconData: Icons.support_agent,
                                fontColor: AppTheme.paleWhite,
                                fontSize: 20,
                                text: 'Help And Support',
                              ),
                  
                              DetailContainer(
                                onTap: () {
                                  _showLogoutDialog(context);
                                },
                                iconData: Icons.logout_rounded,
                                fontColor: AppTheme.paleWhite,
                                fontSize: 20,
                                text: 'Logout',
                                
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
            style: TextStyle(color: AppTheme.textPrimary),
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
                logoutUser();
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

  /*void _performLogout(BuildContext context) {
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
  }*/
}












/*                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DetailContainer(
                            onTap: () async {
                              // Navigate to appropriate profile edit page based on user role
                              Widget profileScreen;
                              if (widget.userRole == UserRole.seller) {
                                profileScreen = const SellerProfileEditScreen();
                              } else {
                                profileScreen = const EditProfileScreen();
                              }

                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => profileScreen,
                                ),
                              );

                              // Refresh the screen if profile was updated
                              if (result == true) {
                                setState(() {});
                              }
                            },
                            iconData: Icons.person,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: ' Profile ',
                            containerHeight:
                                MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.7,
                          ),

                          DetailContainer(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PaymentTransactions(),
                                ),
                              );
                            },
                            iconData: Icons.credit_card_rounded,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'Payment Method',
                            containerHeight:
                                MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.7,
                          ),

                          DetailContainer(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ModeSettingsPage(),
                                ),
                              );
                            },
                            iconData: Icons.settings_applications,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'App Settings',
                            containerHeight:
                                MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.7,
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
                            containerHeight:
                                MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.7,
                          ),

                          DetailContainer(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HelpAndSupportPage(),
                                ),
                              );
                            },
                            iconData: Icons.support_agent,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'Help And Support',
                            containerHeight:
                                MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.7,
                          ),

                          DetailContainer(
                            onTap: () {
                              _showLogoutDialog(context);
                            },
                            iconData: Icons.logout_rounded,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'Logout',
                            containerHeight:
                                MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.7,
                          ),
                        ],
                      ),
                    ),
*/