import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kampusmart2/screens/home_page.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/interest_screen.dart';
import 'screens/onboarding_screen1.dart';
import 'screens/chats_screen.dart';
import 'screens/sellers_dashboard.dart';
import 'screens/seller_add_product.dart';
import 'screens/seller_sales_tracking.dart';
import 'screens/login_or_register_page.dart';
import 'package:kampusmart2/widgets/theme_provider.dart';
import 'Theme/app_theme.dart';
import 'screens/notification_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://oydcifonjmzfnuaihrln.supabase.co', // Replace with your Supabase project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im95ZGNpZm9uam16Zm51YWlocmxuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1ODk1MzMsImV4cCI6MjA2ODE2NTUzM30.ufJqhFhkMoRoJRIbwZ9rpoMSyUHCOKthG427rk1SoWk', // Replace with your Supabase anon key
  );

  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ChangeNotifierProvider.value(value: themeProvider, child: const MyApp()),
  );
}

class SupabaseAdmin {
  static final SupabaseClient _adminClient = SupabaseClient(
    'https://oydcifonjmzfnuaihrln.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im95ZGNpZm9uam16Zm51YWlocmxuIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MjU4OTUzMywiZXhwIjoyMDY4MTY1NTMzfQ.x5Aiz-KigL2H2Lc5ZRp8gJZiFqp4yk4BMGDSCHTC-wk', // Replace with your actual service role key
  );

  static SupabaseClient get client => _adminClient;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Kampus mart',
      theme: themeProvider.currentTheme,
      debugShowCheckedModeBanner: false,
     //ome: HomePage(),
      routes: {
        '/': (context) => const SplashScreen(),
        '/WelcomeScreen': (context) => const WelcomeScreen(),
        '/OnboardingScreen': (context) => const OnboardingScreen(),
        '/FourthOnboardingScreen': (context) => const FourthOnboardingScreen(),
        '/InterestsScreen': (context) => const InterestsScreen(),
        '/Signup': (context) => const LoginOrRegisterPage(),
        '/ChatsScreen': (context) => const ChatsScreen(),
        '/SellerDashboard': (context) => const SellerDashboardScreen(),
        '/AddProduct': (context) => const SellerAddProductScreen(),
        '/SalesTracking': (context) => const SellerSalesTrackingScreen(),
      },
    );
  }
}
