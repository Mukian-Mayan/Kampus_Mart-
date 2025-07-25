// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/widgets/profile_card.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25, left: 25),
          child: Text(
            'About Us',
            style: TextStyle(
              color: AppTheme.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(top: 22, left: 25),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.deepBlue),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo/Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.deepBlue,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.taleBlack.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.school,
                      size: 60,
                      color: AppTheme.paleWhite,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // App Name
                Center(
                  child: Text(
                    'Kampusmart',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.deepBlue,
                      fontFamily: 'League Spartan',
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Version
                Center(
                  child: Text(
                    'Version 2.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // About Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.paleWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About KampuSmart',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepBlue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Kampus Mart is your ultimate campus companion, designed to make student life easier and more efficient. Our platform connects students with everything they need on campus- easying connection between freshers, continuing students and finalists.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Features
                      Text(
                        'Key Features:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureItem('💬', 'Campus Chat'),
                      _buildFeatureItem('🛒', 'Shopping Cart'),
                      _buildFeatureItem('📚', 'Academic Resources'),
                      _buildFeatureItem('💳', 'Secure Payments'),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Mission Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.deepBlue,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Mission',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.paleWhite,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'To revolutionize campus life by providing students with a seamless, all-in-one platform that connects them to essential services, fosters community, and enhances their academic journey.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.paleWhite,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Use SizedBox with enough height + padding + decoration wrapping horizontal scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ProfileCard(
                        name: 'Kalio Baaf',
                        developerImage: 'assets/dp_1.jpeg',
                        majorRole: 'Backend Guru',
                        developerDescription:
                            'A complete specialist in backend. cloud computing and all cloud bassed and local hub based concerns',
                        developerLocation: 'Kikoni - Makerere',
                        developerSkill1: 'Python',
                        developerSkill2: 'C, C+, C++',
                        developerSkill3: 'Firebase',
                        developerSkill4: 'SupperBase',
                        githubLink: 'https://github.com/yourprofile',
                        instagramLink: 'https://instagram.com/yourprofile',
                      ),
                      // Add horizontal spacing if you add more ProfileCards
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                         const SizedBox(height: 25,),

                // Contact Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.paleWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.taleBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepBlue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildContactItem(Icons.email, 'support@kampusmart.com'),
                      _buildContactItem(Icons.phone, '+256 709 101  171'),
                      _buildContactItem(Icons.location_on, 'Makerere,Kampala, Uganda'),
                      _buildContactItem(Icons.web, 'www.kampusmart.com'),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Footer
                Center(
                  child: Text(
                    '© 2025 KampuSmart. All rights reserved.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Text(
            feature,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.deepBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}