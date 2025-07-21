import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/guest_welcome_screen.dart';
import 'package:kampusmart2/screens/login_page.dart';
import 'package:kampusmart2/screens/register_page.dart';
import 'package:kampusmart2/widgets/my_button1.dart';
import 'package:kampusmart2/widgets/radio_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginOrRegisterPage extends StatelessWidget {
  static const String routeName = '/Signup';
  const LoginOrRegisterPage({super.key});

  // Convert string to UserRole enum
  UserRole _stringToUserRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'seller':
      case 'option1': // If your dialog returns 'option2' for seller
        return UserRole.seller;
      case 'buyer':
      case 'option2': // If your dialog returns 'option1' for buyer
        return UserRole.buyer;
      default:
        return UserRole.buyer; // Default to buyer
    }
  }

  void _handleRoleAndNavigateToRegister(BuildContext context) async {
    String? selected = await RadioDialog.show(context, null);
    if (selected != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user_role', selected);
      print("User selected: $selected");

      // Convert selected string to UserRole enum
      UserRole userRole = _stringToUserRole(selected);
      print("Converted to UserRole: $userRole");

      // Navigate to RegisterPage with the correct role
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage(userRole: userRole),
        ),
      );
    } else {
      print("Dialog canceled");
    }
  }

  void _handleRoleAndNavigateToLogin(BuildContext context) async {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => LoginPage(),
         ),
       );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("lib/images/logo.png"),
                      Image.asset("lib/images/mart.png"),
                    ],
                  ),
                  Image.asset("lib/images/image7.png"),
                ],
              ),
              const SizedBox(height: 17),
              Text(
                'Continue as',
                style: TextStyle(
                  color: AppTheme.taleBlack,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TypoGraphica',
                ),
              ),

              MyButton1(
                pad: 8,
                text: 'Sign In',
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.75,
                fontSize: 22,
                onTap: () => _handleRoleAndNavigateToLogin(context),
              ),

              MyButton1(
                pad: 8,
                text: 'Sign Up',
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.75,
                fontSize: 22,
                onTap: () => _handleRoleAndNavigateToRegister(context),
              ),

              MyButton1(
                pad: 8,
                text: 'Guest',
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.75,
                fontSize: 22,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GuestWelcomeScreen()),
                ),
              ),

              Expanded(
                child: Image.asset('lib/images/image6.png', fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}