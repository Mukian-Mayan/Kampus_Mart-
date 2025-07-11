// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/cart_page.dart';
import 'package:kampusmart2/screens/chats_screen.dart';
import 'package:kampusmart2/screens/home_page.dart';
import 'package:kampusmart2/screens/settings_page.dart';
import 'package:kampusmart2/screens/user_profile_page.dart';
import 'package:kampusmart2/screens/chats_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  const BottomNavBar({super.key, required this.selectedIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _handleTabChange(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CartPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatsScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          color: AppTheme.deepBlue,
          boxShadow: [
            BoxShadow(
              color: AppTheme.taleBlack,
              blurRadius: 5,
              offset: Offset(2, 2),
              spreadRadius: 2,
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 15),
          child: GNav(
            selectedIndex: widget.selectedIndex,
            backgroundColor: AppTheme.deepBlue,
            textStyle: TextStyle(
              fontFamily: 'TypoGraphica',
              color: AppTheme.paleWhite,
            ),
            gap: 7,
            padding: EdgeInsets.all(8),
            activeColor: AppTheme.paleWhite,
            color: Theme.of(context).colorScheme.secondary,
            tabBackgroundColor: Theme.of(
              context,
            ).colorScheme.onPrimary.withOpacity(0.5),
            onTabChange: (index) => _handleTabChange(context, index),

            tabs: [
              const GButton(icon: Icons.home, text: 'Home'),
              const GButton(icon: Icons.shopping_cart_outlined, text: 'Cart'),
              const GButton(icon: Icons.message_outlined, text: ' \t messages'),
              const GButton(icon: Icons.settings, text: 'Settings'),
              const GButton(icon: Icons.person, text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
