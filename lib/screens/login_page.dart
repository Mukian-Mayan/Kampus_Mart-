// ignore_for_file: avoid_print, use_key_in_widget_constructors, deprecated_member_use
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/home_page.dart';
import 'package:kampusmart2/screens/register_page.dart';
import 'package:kampusmart2/services/auth_services.dart';
import 'package:kampusmart2/widgets/layout1.dart';
import 'package:kampusmart2/widgets/my_button1.dart';
import 'package:kampusmart2/widgets/my_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_role.dart';

class LoginPage extends StatefulWidget {
  final UserRole? userRole;
  LoginPage({super.key, this.userRole});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController pwController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool obscureText = true;

  void signInUser(BuildContext context) async {
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

      UserRole userRole = await _getUserRole(userCredential.user!.uid);

      // ✅ Save login state and role
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString(
        'user_role',
        userRole == UserRole.seller ? 'seller' : 'buyer',
      );

      Navigator.of(context).pop();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(userRole: userRole)),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
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

  Future<UserRole> _getUserRole(String userId) async {
    try {
      DocumentSnapshot roleDoc = await FirebaseFirestore.instance
          .collection('user_roles')
          .doc(userId)
          .get();

      if (roleDoc.exists) {
        String role =
            (roleDoc.data() as Map<String, dynamic>)['role'] ?? 'buyer';
        return role == 'seller' ? UserRole.seller : UserRole.buyer;
      }

      DocumentSnapshot sellerDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .get();

      return sellerDoc.exists ? UserRole.seller : UserRole.buyer;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return UserRole.buyer;
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
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: const Text(
                          'Kampus Mart',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 58,
                            fontFamily: 'Keania One',
                          ),
                        ),
                      ),
                      Layout1(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 19),
                            Text(
                              'Welcome Back, We missed you',
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
                                  obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                                        userRole:
                                            widget.userRole ?? UserRole.buyer,
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
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final credential = await AuthService()
                                      .signInWithGoogle();
                                  if (credential != null) {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      // Optional: Determine user role
                                      final userRole = await _getUserRole(
                                        user.uid,
                                      );

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool('isLoggedIn', true);
                                      await prefs.setString(
                                        'user_role',
                                        userRole == UserRole.seller
                                            ? 'seller'
                                            : 'buyer',
                                      );

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HomePage(userRole: userRole),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Google sign-in failed: $e',
                                      ),
                                      backgroundColor: Colors.red.shade400,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },

                              //onTap: () =>
                              //AuthService().signInWithGoogle(),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10.0,
                                    sigmaY: 10.0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.borderGrey.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 150.0,
                                      vertical: 6.0,
                                    ),
                                    child: Image.asset(
                                      'lib/images/Icon-google.png',
                                      height: 25,
                                      width: 90,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
