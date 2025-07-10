// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/home_page.dart';
import 'package:kampusmart2/screens/login_page.dart';
import 'package:kampusmart2/services/auth_services.dart';
import 'package:kampusmart2/widgets/layout1.dart';
import 'package:kampusmart2/widgets/my_button1.dart';
import 'package:kampusmart2/widgets/my_square_tile.dart';
import 'package:kampusmart2/widgets/my_textfield.dart';

import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final obscureText = true;

  RegisterPage({super.key});
void signUpUser(BuildContext context) async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const Center(child: CircularProgressIndicator());
    },
  );

  try {
    // Check if passwords match
    if (pwController.text != confirmPwController.text) {
      Navigator.of(context).pop(); // Dismiss loading first
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords don't match"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Create user
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
    Navigator.of(context).pop(); // Dismiss loading

    String errorMessage;

    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'An account already exists with this email.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is not valid.';
        break;
      case 'weak-password':
        errorMessage = 'The password is too weak.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Email/password accounts are not enabled.';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Please check your connection.';
        break;
      default:
        errorMessage = 'An unknown error occurred. Please try again.';
    }

    // Show error
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
                    'Register Today, Save Every Day!',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Birdy Script',
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4.0,
                          color: AppTheme.taleBlack.withOpacity(0.7),
                        ),
                      ],
                      color: AppTheme.paleWhite,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MyTextField(
                          maxLength: null,
                          focusedColor: AppTheme.deepOrange,
                          enabledColor: AppTheme.taleBlack,
                          hintText: 'enter your first name',
                          obscureText: false,
                          controller: firstNameController,
                        ),
                      ),
                      Expanded(
                        child: MyTextField(
                          maxLength: null,
                          focusedColor: AppTheme.deepOrange,
                          enabledColor: AppTheme.taleBlack,
                          hintText: 'enter Your Second Name',
                          obscureText: false,
                          controller: secondNameController,
                        ),
                      ),
                    ],
                  ),
                  MyTextField(
                    maxLength: null,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: emailController,
                    hintText: 'enter your email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10,),

                  MyTextField(
                    maxLength: 16,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: pwController,
                    hintText: 'create password',
                    obscureText: true,
                  ),

                  MyTextField(
                    maxLength: 16,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: confirmPwController,
                    hintText: 'confirm password',
                    obscureText: true,
                  ),

                  MyButton1(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.7,
                    fontSize: 20,
                    text: 'Login',
                    onTap: () => signUpUser(context),
                    pad: 15,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account, ',
                        style: TextStyle(
                          color: AppTheme.paleWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        ),
                        child: Text(
                          'LogIn ',
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
