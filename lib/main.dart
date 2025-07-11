import 'package:firebase_core/firebase_core.dart';
import 'package:kampusmart2/screens/cart_page.dart';
import 'package:kampusmart2/screens/home_page.dart';
import 'package:kampusmart2/widgets/custom_app_bar.dart';
import 'package:kampusmart2/widgets/my_square_tile.dart';
import '../screens/chats_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_screen.dart';
import 'screens/interest_screen.dart';
import 'screens/onboarding_screen1.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/sellers_dashboard.dart';
import 'screens/seller_add_product.dart';
import 'screens/seller_sales_tracking.dart';
import 'Theme/app_theme.dart';
import 'screens/login_or_register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kampus mart',
      theme: AppTheme.lightTheme,
      home: HomePage(),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,

      // routes: {
      //   '/': (context) => const SplashScreen(), // Splash screen (first)
      //   '/WelcomeScreen': (context) => const WelcomeScreen(), // Welcome screen (second)
      //   '/OnboardingScreen': (context) => const OnboardingScreen(), // Third screen
      //   '/FourthOnboardingScreen': (context) => const FourthOnboardingScreen(), // Fourth screen
      //   '/InterestsScreen': (context) => const InterestsScreen(),
      //   '/Signup': (context) => const LoginOrRegisterPage(),
      //   '/ChatsScreen': (context) => const ChatsScreen(), // Seller dashboard
      //   '/SellerDashboard': (context) => const SellerDashboardScreen (), // Seller dashboard
      //   '/AddProduct': (context) => const SellerAddProductScreen(), // Add product screen
      //   '/SalesTracking': (context) => const SellerSalesTrackingScreen(), // Sales tracking screen
      // },
    );
  }
}
