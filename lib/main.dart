// === main.dart (MODIFIED) ===
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/interest_screen.dart';
import 'screens/onboarding_screen1.dart';
import 'screens/sellers_dashboard.dart';
import 'screens/seller_add_product.dart';
import 'screens/seller_sales_tracking.dart';
import 'screens/login_or_register_page.dart';
import 'screens/home_page.dart';
import 'package:kampusmart2/widgets/theme_provider.dart';
import 'models/user_role.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Check login state from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String? role = prefs.getString('user_role');
  final UserRole userRole = role == 'seller' ? UserRole.seller : UserRole.buyer;

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: MyApp(isLoggedIn: isLoggedIn, userRole: userRole),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final UserRole userRole;

  const MyApp({super.key, required this.isLoggedIn, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Kampus mart',
      theme: themeProvider.currentTheme,
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? HomePage(userRole: userRole) : const SplashScreen(),
      routes: {
        '/WelcomeScreen': (context) => const WelcomeScreen(),
        '/OnboardingScreen': (context) => const OnboardingScreen(),
        '/FourthOnboardingScreen': (context) => const FourthOnboardingScreen(),
        '/InterestsScreen': (context) => const InterestsScreen(),
        '/Signup': (context) => const LoginOrRegisterPage(),
        '/SellerDashboard': (context) => const SellerDashboardScreen(),
        '/AddProduct': (context) => const SellerAddProductScreen(),
        '/SalesTracking': (context) => const SellerSalesTrackingScreen(),
      },
    );
  }
}
