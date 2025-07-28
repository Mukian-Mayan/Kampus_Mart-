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

                Center(
                  child: Text(
                    'Developer Team',
                    style: TextStyle(
                      color: AppTheme.taleBlack,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'DreamOrphans-Bold',
                    ),
                  ),
                ),

                // Developer Cards - Expandable Dropdowns
                ExpansionTile(
                  title: Center(
                    child: Text(
                      'Nagawa Sandra RobinahBackend Specialist',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.deepBlue,
                        fontFamily: 'DreamOrphans-Bold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  leading: Text(
                    'Nagawa Sandra Robinah',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.deepBlue,
                      fontFamily: 'DreamOrphans-Bold',
                      fontSize: 15,
                    ),
                  ),
                  children: [
                    ProfileCard(
                      name: 'Nagawa Sama Sandra',
                      developerImage: 'assets/developers/sama.jpg',
                      majorRole: 'Backend Specialist',
                      developerDescription:
                          'Expert in cloud systems, APIs, and scalable server architecture using modern backend frameworks.',
                      developerLocation: 'Kikoni - Makerere',
                      developerSkill1: 'Dart',
                      developerSkill2: 'SupaBase',
                      developerSkill3: 'Firebase',
                      developerSkill4: 'SupperBase',
                      githubLink: 'https://github.com/nagawasandrarobinah',
                      instagramLink: 'https://instagram.com/nagawasandra30',
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Center(
                    child: Text(
                      'DevOps & QA Engineer',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.deepBlue,
                        fontFamily: 'DreamOrphans-Bold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  leading: Text(
                    'Nakimuli Jollyne',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.deepBlue,
                      fontFamily: 'DreamOrphans-Bold',
                      fontSize: 15,
                    ),
                  ),
                  children: [
                    ProfileCard(
                      name: 'Nakimuli Jollyne ',
                      developerImage: 'assets/jollyne.jpg',
                      majorRole: '	DevOps & QA Engineer',
                      developerDescription:
                          'Automates builds, deploys infrastructure, and writes robust test coverage for CI/CD pipelines.',
                      developerLocation: 'Wandegeya - Makerere',
                      developerSkill1: 'Firebase',
                      developerSkill2: 'Dart',
                      developerSkill3: 'Flutter',
                      developerSkill4: 'React Native',
                      githubLink: 'https://github.com/Jollyneflavia',
                      instagramLink: 'https://www.instagram.com/jo_lly_ne/',
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Center(
                    child: Text(
                      'Flutter Lead Engineer',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.deepBlue,
                        fontFamily: 'DreamOrphans-Bold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  leading: Text(
                    'Nambirige Eron',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.deepBlue,
                      fontFamily: 'DreamOrphans-Bold',
                      fontSize: 15,
                    ),
                  ),
                  children: [
                    ProfileCard(
                      name: 'Nambirige Eron',
                      developerImage: 'assets/developers/eron.jpg',
                      majorRole: 'Flutter Lead Engineer',
                      developerDescription:
                          'Leads architecture and feature planning for enterprise-grade mobile applications across platforms',
                      developerLocation: 'Uganda - Kampala',
                      developerSkill1: 'Html',
                      developerSkill2: 'Dart',
                      developerSkill3: 'CSS',
                      developerSkill4: 'flutter',
                      githubLink: 'https://github.com/Nambirige-Eron',
                      instagramLink:
                          'https://www.instagram.com/chosen8094?utm_source=ig_web_button_share_sheet&igsh=M2hqeGdjOWtzMWRx',
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Center(
                    child: Text(
                      'Data Scientist & full stack',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.deepBlue,
                        fontFamily: 'DreamOrphans-Bold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  leading: Text(
                    'Malual Martin Biar',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.deepBlue,
                      fontFamily: 'DreamOrphans-Bold',
                      fontSize: 15,
                    ),
                  ),
                  children: [
                    ProfileCard(
                      name: 'Malual Martin Biar',
                      developerImage: 'assets/developers/martin.jpg',
                      majorRole: 'Machine Learning Engineer & full stack',
                      developerDescription:
                          'Bridges frontend and backend with solid code structure, REST/GraphQL APIs, and UI component systems',
                      developerLocation: 'Kikoni - Makerere',
                      developerSkill1: 'Python',
                      developerSkill2: 'dart',
                      developerSkill3: 'React Native',
                      developerSkill4: 'SQL',
                      githubLink: 'https://github.com/Priez211',
                      instagramLink:
                          'https://www.instagram.com/preiz_biaralier?igsh=cnFnajF3MzhscG03&utm_source=qr',
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Center(
                    child: Text(
                      'Data Scientist',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.deepBlue,
                        fontFamily: 'DreamOrphans-Bold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  leading: Text(
                    'Mayanja Joel Stephen',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.deepBlue,
                      fontFamily: 'DreamOrphans-Bold',
                      fontSize: 15,
                    ),
                  ),
                  children: [
                    ProfileCard(
                      name: 'Mayanja Joel Stephen',
                      developerImage: 'assets/moen.jpg',
                      majorRole: 'Data Scientist',
                      developerDescription:
                          '	A hands-on Flutter developer who transforms ideas into scalable mobile solutions. Skilled in UI/UX design, API integration, and app logic.',
                      developerLocation: 'Kampala - Uganda',
                      developerSkill1: 'Dart',
                      developerSkill2: 'Flutter',
                      developerSkill3: 'Firebase ',
                      developerSkill4: 'UI/UX Specialist',
                      githubLink: 'https://github.com/Mukian-Mayan',
                      instagramLink:
                          'https://www.instagram.com/_its_moen_?igsh=MXdtNmVxdnJwbnJlag==',
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const SizedBox(height: 25),

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
                      _buildContactItem(
                        Icons.location_on,
                        'Makerere,Kampala, Uganda',
                      ),
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
          Text(emoji, style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(
            feature,
            style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
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
          Icon(icon, color: AppTheme.deepBlue, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
