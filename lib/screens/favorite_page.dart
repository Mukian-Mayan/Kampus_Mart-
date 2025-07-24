import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/login_or_register_page.dart';
import 'package:kampusmart2/widgets/layout2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<FavoritePage> {
  String? userRole;
  
  void logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear session data
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
      (route) => false, // Remove all previous routes
    );
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
      backgroundColor: AppTheme.paleWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.deepBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
          color: AppTheme.paleWhite,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Layout2(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('  Favorites  ', style: TextStyle(color: AppTheme.paleWhite, fontSize: 20, fontFamily: 'DreamOrphans-Bold'), ),
                    Icon(Icons.favorite, color: AppTheme.selectedBlue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
