// ignore_for_file: avoid_print, use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/home_page.dart';
import 'package:kampusmart2/screens/sellers_dashboard.dart';
import 'package:kampusmart2/screens/register_page.dart';
import 'package:kampusmart2/services/auth_services.dart';
import 'package:kampusmart2/widgets/layout1.dart';
import 'package:kampusmart2/widgets/my_button1.dart';
import 'package:kampusmart2/widgets/my_square_tile.dart';
import 'package:kampusmart2/widgets/my_textfield.dart';
import '../models/user_role.dart';

class LoginPage extends StatefulWidget {
  final UserRole? userRole;
  LoginPage({super.key, this.userRole});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Optional - if null, detect from database
  final TextEditingController pwController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  bool obscureText = true;
  void signInUser(BuildContext context) async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: pwController.text,
        );

    // Get user role
    UserRole userRole = await _getUserRole(userCredential.user!.uid);

    // Close loading indicator
    Navigator.of(context).pop();

    // Navigate to home with the correct bottom nav bar
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(userRole: userRole),
      ),
      (route) => false,
    );
  
    } on FirebaseAuthException catch (e) {
      // Close the loading indicator FIRST
      Navigator.of(context).pop();

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password entered.';
          break;
        case 'invalid-email':
          errorMessage = 'The email format is incorrect.';
          break;
        case 'user-disabled':
          errorMessage = 'Your account has been disabled.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check your internet.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Try again later.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid login credentials.';
          break;
        default:
          errorMessage = 'An unknown error occurred. Please try again.';
      }

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to determine user role: ${e.toString()}'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Update the _getUserRole method in login_page.dart
Future<UserRole> _getUserRole(String userId) async {
  try {
    // First check user_roles collection
    DocumentSnapshot roleDoc = await FirebaseFirestore.instance
        .collection('user_roles')
        .doc(userId)
        .get();

    if (roleDoc.exists) {
      String role = (roleDoc.data() as Map<String, dynamic>)['role'] ?? 'buyer';
      return role == 'seller' ? UserRole.seller : UserRole.buyer;
    }

    // Fallback: check if user exists in sellers collection
    DocumentSnapshot sellerDoc = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(userId)
        .get();

    return sellerDoc.exists ? UserRole.seller : UserRole.buyer;
  } catch (e) {
    debugPrint('Error getting user role: $e');
    return UserRole.buyer; // Default fallback
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          widget.userRole == UserRole.seller
              ? 'Seller Login'
              : 'Customer Login',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: const Text(
              'Kampus Mart',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 58, fontFamily: 'Keania One'),
            ),
          ),
          Layout1(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 19),
                  Text('Welcome Back, We missed you',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'KG Red Hands',
                      color: AppTheme.paleWhite,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 4.0,
                          color: AppTheme.taleBlack.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                  MyTextField(
                    maxLength: null,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: emailController,
                    hintText: 'Enter your email',
                    obscureText: false,
                  ),
                  MyTextField(
                    maxLength: 16,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: pwController,
                    hintText: 'Enter your password',
                    obscureText: obscureText,
                    prefix: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                        color: AppTheme.borderGrey,
                      ),
                    ),
                  ),
                  MyButton1(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.7,
                    fontSize: 20,
                    text: 'Login',
                    onTap: () => signInUser(context),
                    pad: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Not a member? ',
                        style: TextStyle(
                          color: AppTheme.paleWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(
                              userRole: widget.userRole ?? UserRole.buyer,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Register Now',
                          style: TextStyle(
                            color: AppTheme.lightGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Social login options
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: AppTheme.deepOrange,
                          ),
                        ),
                        const Text(
                          '\t or continue with \t',
                          style: TextStyle(
                            color: AppTheme.paleWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: AppTheme.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MySquareTile(
                        onTap: () => AuthService().signInWithGoogle(),
                        imagePath: 'lib/images/Icon-google.png',
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                      MySquareTile(
                        onTap: () {}, // Apple sign-in implementation
                        imagePath: 'lib/images/apple_icon.png',
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
}
