// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/home_page.dart';
import '../models/interest_model.dart';
import '../data/interests_data.dart';
import '../widgets/interest_chip.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/continue_button.dart';
import '../Theme/app_theme.dart';

class InterestsScreen extends StatefulWidget {
  static const String routeName = '/InterestsScreen';
  final UserRole userRole;
  const InterestsScreen({super.key, required this.userRole});

  @override
   State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen>
    with SingleTickerProviderStateMixin {
  late List<Interest> _interests;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _interests = List.from(InterestsData.defaultInterests);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleInterest(String interestId) {
    setState(() {
      final index = _interests.indexWhere(
        (interest) => interest.id == interestId,
      );
      if (index != -1) {
        _interests[index] = _interests[index].copyWith(
          isSelected: !_interests[index].isSelected,
        );
      }
    });
  }
  //UserRole userRole = await _getUserRole(userCredential.user!.uid);

  void _onContinuePressed() {
    final selectedInterests = _interests
        .where((interest) => interest.isSelected)
        .map((interest) => interest.name)
        .toList();

    debugPrint('Selected interests: $selectedInterests');
    // Navigate to home/dashboard screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(userRole: widget.userRole)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryOrange,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Title
                const Text('Choose Your Interests', style: AppTheme.titleStyle),

                const SizedBox(height: 30),

                // Interests Grid
                Expanded(child: _buildInterestsGrid()),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: GenericContinueButton(onPressed: _onContinuePressed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsGrid() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 3.5,
      ),
      itemCount: _interests.length,
      itemBuilder: (context, index) {
        final interest = _interests[index];
        return AnimatedScale(
          scale: interest.isSelected ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 150),
          child: InterestChip(
            interest: interest,
            onTap: () => _toggleInterest(interest.id),
            animationDelay: index * 50,
          ),
        );
      },
    );
  }
}
