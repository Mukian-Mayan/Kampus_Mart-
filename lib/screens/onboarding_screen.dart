// onboarding_screen.dart
import 'package:flutter/material.dart';
import '../Theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/Illustration_widget.dart';
import 'interest_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const InterestsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _onSkipPressed() {
    debugPrint('Skip pressed');
    _onGetStarted(); // For now, skip goes to interests screen
  }

  void _onBackPressed() {
    debugPrint('Back pressed');
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryOrange,
      appBar: CustomAppBar(
        onBackPressed: _onBackPressed,
        onSkipPressed: _onSkipPressed,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Illustration Section
              Expanded(
                flex: 3,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const IllustrationWidget(),
                ),
              ),
              
              // Content Section
              Expanded(
                flex: 2,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContentSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Declutter & Discover',
              style: AppTheme.onboardingTitleStyle,
            ),
            const SizedBox(height: 16),
            
            // Subtitle
            const Text(
              'List old items in seconds. Find deals from students like you, verified and close by',
              style: AppTheme.subtitleStyle,
            ),
            
            const Spacer(),
            
            // Action Buttons
            Row(
              children: [
                // Get Started Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: AppTheme.buttonTextStyle,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Arrow Button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: _onGetStarted,
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}