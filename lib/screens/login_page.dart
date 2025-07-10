// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/home_page.dart';
import 'package:kampusmart2/screens/register_page.dart';
import 'package:kampusmart2/services/auth_services.dart';
import 'package:kampusmart2/widgets/layout1.dart';
import 'package:kampusmart2/widgets/my_button1.dart';
import 'package:kampusmart2/widgets/my_square_tile.dart';
import 'package:kampusmart2/widgets/my_textfield.dart';

import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController pwController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final obscureText = true;

  LoginPage({super.key});

  void signInUser(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Attempt sign-in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: pwController.text,
      );

      // Close the loading indicator
      Navigator.of(context).pop();

      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
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

      // Show snackbar (correctly)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
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
                  Text(
                    'Welcome Back, We missed you',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Birdy Script',
                      color: AppTheme.paleWhite,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
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
                    hintText: 'enter your email',
                    obscureText: false,
                  ),
                  MyTextField(
                    maxLength: 16,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: pwController,
                    hintText: 'enter your password',
                    obscureText: true,
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
                      Text(
                        'not a member, ',
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
                            builder: (context) => RegisterPage(),
                          ),
                        ),
                        child: Text(
                          'Register Now ',
                          style: TextStyle(
                            color: AppTheme.lightGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),

                  //const SizedBox(height: 10,),
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

                        Text(
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
                        onTap: () =>
                            AuthService().signInWithGoogle(), // NOT YET FILLED
                        imagePath: 'lib/images/Icon-google.png',
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                      MySquareTile(
                        onTap: () {}, // NOT YET FILLED
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
