import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileCard extends StatelessWidget {
  final String developerImage;
  final String majorRole;
  final String developerDescription;
  final String developerLocation;
  final String developerSkill1;
  final String developerSkill2;
  final String developerSkill3;
  final String developerSkill4;
  final String githubLink;
  final String instagramLink;

  ProfileCard({
    Key? key,
    required this.developerImage,
    required this.majorRole,
    required this.developerDescription,
    required this.developerLocation,
    required this.developerSkill1,
    required this.developerSkill2,
    required this.developerSkill3,
    required this.developerSkill4,
    required this.githubLink,
    required this.instagramLink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleWhite,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 350),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppTheme.paleWhite,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header with gradient
                    Container(
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          colors: [AppTheme.deepBlue, AppTheme.coffeeBrown],
                        ),
                      ),
                    ),

                    // Profile Picture
                    Transform.translate(
                      offset: const Offset(0, -75),
                      child: CircleAvatar(
                        radius: 76,
                        backgroundColor: AppTheme.deepOrange,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(developerImage),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Column(
                        children: [
                          // Name and Title
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: Column(
                              children: [
                                Text(
                                  'Alex Chen',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.taleBlack,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  majorRole,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.deepBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Description
                          Transform.translate(
                            offset: const Offset(0, -25),
                            child: Text(
                              developerDescription,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppTheme.taleBlack.withOpacity(0.7),
                              ),
                            ),
                          ),

                          // Info Row
                          Transform.translate(
                            offset: const Offset(0, -10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoItem(
                                  Icons.calendar_today,
                                  '5+ Years',
                                  AppTheme.deepBlue,
                                ),
                                _buildInfoItem(
                                  Icons.location_on,
                                  developerLocation,
                                  AppTheme.coffeeBrown,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Skills
                          Text(
                            'Core Skills',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.taleBlack,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildSkillChip('Flutter', AppTheme.deepBlue),
                              _buildSkillChip(
                                developerSkill1,
                                AppTheme.lightGreen,
                              ),
                              _buildSkillChip(
                                developerSkill2,
                                AppTheme.deepOrange,
                              ),
                              _buildSkillChip(
                                developerSkill3,
                                AppTheme.deepBlue,
                              ),
                              _buildSkillChip(
                                developerSkill4,
                                AppTheme.suggestedTabBrown,
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                'GitHub',
                                Icons.code,
                                AppTheme.deepBlue,
                                url: githubLink,
                              ),
                              _buildActionButton(
                                'Portfolio',
                                Icons.launch,
                                AppTheme.coffeeBrown,
                                isOutlined: true,
                                url: instagramLink,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.taleBlack.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        skill,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color, {
    bool isOutlined = false,
    required String url,
  }) {
    return ElevatedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : color,
        foregroundColor: isOutlined ? color : Colors.white,
        side: isOutlined ? BorderSide(color: color) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}
