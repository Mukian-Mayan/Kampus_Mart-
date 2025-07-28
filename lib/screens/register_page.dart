// ignore_for_file: deprecated_member_use, unused_element, use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/Interest_screen.dart';
import 'package:kampusmart2/screens/login_page.dart';
import 'package:kampusmart2/widgets/layout1.dart';
import 'package:kampusmart2/widgets/my_button1.dart';
import 'package:kampusmart2/widgets/my_textfield.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  final UserRole userRole; // Add this parameter

  const RegisterPage({super.key, required this.userRole});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // All controllers declared at the top
  final pwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessDescriptionController =
      TextEditingController();
  bool obscureText = true;

  void signUpUser(BuildContext context) async {
    // Validate inputs first
    if (!_validateInputs()) {
      return;
    }

    // Check if passwords match
    if (pwController.text != confirmPwController.text) {
      _showErrorSnackBar("Passwords do not match");
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      print('Starting user registration process...');
      print('Email: ${emailController.text.trim()}');
      print('User role: ${widget.userRole}');
      print('Role string representation: ${widget.userRole.toString()}');

      // Create user account
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: pwController.text,
          );

      print('Firebase Auth user created with UID: ${userCredential.user!.uid}');

      // Store user data in Firestore and WAIT for completion
      await _storeUserData(userCredential.user!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString(
        'user_role',
        widget.userRole == UserRole.seller ? 'seller' : 'buyer',
      );

      // IMPORTANT: Add a small delay to ensure Firestore consistency
      await Future.delayed(const Duration(milliseconds: 500));

      // Close loading indicator
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show success message
      _showSuccessSnackBar("Account created successfully!");

      // Navigate based on user role with data ready
      // In the signUpUser method, after successful registration:
      if (widget.userRole == UserRole.seller) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => InterestsScreen(userRole: widget.userRole)),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => InterestsScreen(userRole: widget.userRole)),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      print('Firebase Auth error: ${e.code} - ${e.message}');
      _handleFirebaseAuthError(e);
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      print('Registration error: $e');
      _showErrorSnackBar('Registration failed: ${e.toString()}');
    }
  }

  // Add this method to your RegisterPage class
  Future<UserRole?> _getUserRole(String userId) async {
    try {
      final roleDoc = await FirebaseFirestore.instance
          .collection('user_roles')
          .doc(userId)
          .get();

      if (!roleDoc.exists) {
        print('User role document not found for user: $userId');
        return null;
      }

      final roleData = roleDoc.data() as Map<String, dynamic>;
      final roleString = roleData['role'] as String?;

      if (roleString == null) {
        print('Role field is null for user: $userId');
        return null;
      }

      switch (roleString) {
        case 'seller':
          return UserRole.seller;
        case 'buyer':
          return UserRole.buyer;
        default:
          print('Unknown role: $roleString for user: $userId');
          return UserRole.none;
      }
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  void signInUser(BuildContext context) async {
    // Validate email and password fields
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your email address");
      return;
    }

    if (pwController.text.isEmpty) {
      _showErrorSnackBar("Please enter your password");
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      print('Attempting to sign in user: ${emailController.text.trim()}');

      // Attempt sign-in
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: pwController.text,
          );

      print('Sign-in successful, getting user role...');

      // Get user role and navigate accordingly
      UserRole? detectedRole = await _getUserRole(userCredential.user!.uid);

      print('Detected user role: $detectedRole'); // Debug log

      // Close the loading indicator
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Navigate based on role
      if (widget.userRole == UserRole.seller) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => InterestsScreen(userRole: widget.userRole)),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => InterestsScreen(userRole: widget.userRole)),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Close the loading indicator FIRST
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('Sign-in error: ${e.code} - ${e.message}');

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
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      print('Login error: $e'); // Debug log
      _showErrorSnackBar('Failed to determine user role: ${e.toString()}');
    }
  }

  bool _validateInputs() {
    // Check if user role is properly set
    if (widget.userRole == UserRole.none) {
      _showErrorSnackBar("Please select a valid user type (buyer or seller)");
      return false;
    }

    // Validate required fields
    if (firstNameController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your first name");
      return false;
    }

    if (secondNameController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your last name");
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your email address");
      return false;
    }

    // Basic email validation
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text.trim())) {
      _showErrorSnackBar("Please enter a valid email address");
      return false;
    }

    if (pwController.text.isEmpty) {
      _showErrorSnackBar("Please enter a password");
      return false;
    }

    if (pwController.text.length < 6) {
      _showErrorSnackBar("Password must be at least 6 characters long");
      return false;
    }

    // Validate seller-specific fields
    if (widget.userRole == UserRole.seller) {
      if (businessNameController.text.trim().isEmpty) {
        _showErrorSnackBar("Please enter your business name");
        return false;
      }

      if (businessDescriptionController.text.trim().isEmpty) {
        _showErrorSnackBar("Please enter your business description");
        return false;
      }

      if (phoneController.text.trim().isEmpty) {
        _showErrorSnackBar("Please enter your phone number");
        return false;
      }

      // Basic phone number validation
      if (phoneController.text.trim().length < 10) {
        _showErrorSnackBar("Please enter a valid phone number");
        return false;
      }
    }

    return true;
  }

  void _handleFirebaseAuthError(FirebaseAuthException e) {
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
    _showErrorSnackBar(errorMessage);
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _storeUserData(User user) async {
    final firestore = FirebaseFirestore.instance;
    final timestamp = FieldValue.serverTimestamp();

    try {
      print('Starting to store user data for UID: ${user.uid}');

      // Use batch writes for atomic operations
      final batch = firestore.batch();

      if (widget.userRole == UserRole.seller) {
        print('Storing seller data...');

        // Store seller data
        final sellerRef = firestore.collection('sellers').doc(user.uid);
        final sellerData = {
          'id': user.uid,
          'name':
              '${firstNameController.text.trim()} ${secondNameController.text.trim()}',
          'email': emailController.text.trim(),
          'businessName': businessNameController.text.trim(),
          'businessDescription': businessDescriptionController.text.trim(),
          'phoneNumber': phoneController.text.trim(),
          'profileImageUrl': '',
          'isVerified': false,
          'isActive': true,
          'createdAt': timestamp,
          'updatedAt': timestamp,
          'stats': {
            'totalProducts': 0,
            'totalOrders': 0,
            'totalRevenue': 0.0,
            'rating': 0.0,
            'totalReviews': 0,
          },
        };

        batch.set(sellerRef, sellerData);
        print('Seller data prepared: $sellerData');
      } else {
        print('Storing buyer data...');

        // Store regular user data
        final userRef = firestore.collection('users').doc(user.uid);
        final userData = {
          'id': user.uid,
          'firstName': firstNameController.text.trim(),
          'lastName': secondNameController.text.trim(),
          'email': emailController.text.trim(),
          'profileImageUrl': '',
          'createdAt': timestamp,
          'updatedAt': timestamp,
          'role': 'buyer',
        };

        batch.set(userRef, userData);
        print('User data prepared: $userData');
      }

      // Store user role mapping with explicit string conversion
      final roleRef = firestore.collection('user_roles').doc(user.uid);
      String roleString;
      if (widget.userRole == UserRole.seller) {
        roleString = 'seller';
      } else if (widget.userRole == UserRole.buyer) {
        roleString = 'buyer';
      } else {
        roleString = 'buyer'; // Default to buyer if none specified
      }

      final roleData = {
        'userId': user.uid,
        'role': roleString,
        'createdAt': timestamp,
      };

      batch.set(roleRef, roleData);
      print('Role data prepared: $roleData');
      print('Confirmed role being stored: $roleString');

      // Commit batch operation
      print('Committing batch operation...');
      await batch.commit();
      print('Batch write completed successfully for user: ${user.uid}');

      // Verify data was stored correctly
      await Future.delayed(
        const Duration(milliseconds: 200),
      ); // Brief delay for consistency

      if (widget.userRole == UserRole.seller) {
        final sellerDoc = await firestore
            .collection('sellers')
            .doc(user.uid)
            .get();
        if (!sellerDoc.exists) {
          throw Exception('Seller document was not created properly');
        }
        print('Seller document verified: ${sellerDoc.data()}');
      } else {
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          throw Exception('User document was not created properly');
        }
        print('User document verified: ${userDoc.data()}');
      }

      // Verify role document
      final roleDoc = await firestore
          .collection('user_roles')
          .doc(user.uid)
          .get();
      if (!roleDoc.exists) {
        throw Exception('Role document was not created properly');
      }
      print('Role document verified: ${roleDoc.data()}');
    } catch (e) {
      print('Error storing user data: $e');
      throw Exception('Failed to store user data: $e');
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    pwController.dispose();
    confirmPwController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    secondNameController.dispose();
    phoneController.dispose();
    businessNameController.dispose();
    businessDescriptionController.dispose();
    super.dispose();
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
              ? 'Seller Registration'
              : 'Customer Registration',
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 19),
                  Text(
                    widget.userRole == UserRole.seller
                        ? 'Start Selling Today!'
                        : 'Register Today, Save Every Day!',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Birdy Script',
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 4.0,
                          color: AppTheme.taleBlack.withOpacity(0.7),
                        ),
                      ],
                      color: AppTheme.paleWhite,
                    ),
                  ),

                  // Name fields
                  Row(
                    children: [
                      Expanded(
                        child: MyTextField(
                          maxLength: null,
                          focusedColor: AppTheme.deepOrange,
                          enabledColor: AppTheme.taleBlack,
                          hintText: 'First name',
                          obscureText: false,
                          controller: firstNameController,
                        ),
                      ),
                      Expanded(
                        child: MyTextField(
                          maxLength: null,
                          focusedColor: AppTheme.deepOrange,
                          enabledColor: AppTheme.taleBlack,
                          hintText: 'Last name',
                          obscureText: false,
                          controller: secondNameController,
                        ),
                      ),
                    ],
                  ),

                  // Email field
                  MyTextField(
                    maxLength: null,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: emailController,
                    hintText: 'Email address',
                    obscureText: false,
                  ),

                  // Seller-specific fields
                  if (widget.userRole == UserRole.seller) ...[
                    MyTextField(
                      maxLength: null,
                      focusedColor: AppTheme.deepOrange,
                      enabledColor: AppTheme.taleBlack,
                      controller: businessNameController,
                      hintText: 'Business name',
                      obscureText: false,
                    ),
                    MyTextField(
                      maxLength: null,
                      focusedColor: AppTheme.deepOrange,
                      enabledColor: AppTheme.taleBlack,
                      controller: businessDescriptionController,
                      hintText: 'Business description',
                      obscureText: false,
                    ),
                    MyTextField(
                      maxLength: null,
                      focusedColor: AppTheme.deepOrange,
                      enabledColor: AppTheme.taleBlack,
                      controller: phoneController,
                      hintText: 'Phone number',
                      obscureText: false,
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Password fields
                  MyTextField(
                    maxLength: 16,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: pwController,
                    hintText: 'Create password',
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
                  MyTextField(
                    maxLength: 16,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: confirmPwController,
                    hintText: 'Confirm password',
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

                  // Register button
                  MyButton1(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.7,
                    fontSize: 20,
                    text: 'Register',
                    onTap: () => signUpUser(context),
                    pad: 15,
                  ),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppTheme.paleWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: AppTheme.lightGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
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
}

// Add this enum if not already present
