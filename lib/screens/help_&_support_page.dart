// ignore_for_file: deprecated_member_use, unnecessary_import, file_names, unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/widgets/detail_container.dart';
import 'package:kampusmart2/widgets/layout1.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportPage extends StatefulWidget {
  const HelpAndSupportPage({super.key});

  @override
  State<HelpAndSupportPage> createState() => _HelpAndSupportPageState();
}

class _HelpAndSupportPageState extends State<HelpAndSupportPage> {
  bool _isExpanded1 = false;
  bool _isExpanded2 = false;
  bool _isExpanded3 = false;
  bool _isExpanded4 = false;
  bool _isExpanded5 = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.1),
        child: AppBar(
          backgroundColor: AppTheme.tertiaryOrange,
          elevation: 0,
          centerTitle: true,
          title: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Text(
              'Help & Support',
              style: TextStyle(
                color: AppTheme.deepBlue,
                fontWeight: FontWeight.w900,
                fontSize: screenWidth * 0.045,
              ),
            ),
          ),
          leading: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.015,
              left: screenWidth * 0.02,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.deepBlue,
                size: screenWidth * 0.05,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: screenWidth * 0.15,
                    color: AppTheme.deepBlue,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepBlue,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Text(
                    'Find answers to common questions or get in touch with our support team.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Support Section
                    _buildSectionHeader('Contact Support'),
                    SizedBox(height: screenHeight * 0.015),
                    
                    // Contact Options
                    _buildContactOption(
                      context: context,
                      onTap: () => _launchEmail(),
                      iconData: Icons.email,
                      text: 'Email Support',
                    ),
                    
                    _buildContactOption(
                      context: context,
                      onTap: () => _launchPhone(),
                      iconData: Icons.phone,
                      text: 'Call Support',
                    ),
                    
                    _buildContactOption(
                      context: context,
                      onTap: () => _launchWhatsApp(),
                      iconData: Icons.chat,
                      text: 'WhatsApp Chat',
                    ),
                    
                    SizedBox(height: screenHeight * 0.03),
                    
                    // FAQ Section
                    _buildSectionHeader('Frequently Asked Questions'),
                    SizedBox(height: screenHeight * 0.015),
                    
                    // FAQ Items
                    _buildFAQItem(
                      question: 'How do I reset my password?',
                      answer: 'Go to the login screen and tap "Forgot Password". Enter your email address and we\'ll send you a reset link.',
                      isExpanded: _isExpanded1,
                      onTap: () => setState(() => _isExpanded1 = !_isExpanded1),
                    ),
                    
                    _buildFAQItem(
                      question: 'How do I add a payment method?',
                      answer: 'Go to Settings > Payment Method. You can add credit cards, debit cards, or mobile money accounts.',
                      isExpanded: _isExpanded2,
                      onTap: () => setState(() => _isExpanded2 = !_isExpanded2),
                    ),
                    
                    _buildFAQItem(
                      question: 'How do I track my orders?',
                      answer: 'You can track your orders in the Orders section. Each order has a tracking number and status updates.',
                      isExpanded: _isExpanded3,
                      onTap: () => setState(() => _isExpanded3 = !_isExpanded3),
                    ),
                    
                    _buildFAQItem(
                      question: 'What are your delivery hours?',
                      answer: 'We deliver from 8:00 AM to 10:00 PM, Monday through Sunday. Express delivery is available for urgent orders.',
                      isExpanded: _isExpanded4,
                      onTap: () => setState(() => _isExpanded4 = !_isExpanded4),
                    ),
                    
                    _buildFAQItem(
                      question: 'How do I report a problem with my order?',
                      answer: 'Contact our support team immediately via email, phone, or WhatsApp. Have your order number ready for faster assistance.',
                      isExpanded: _isExpanded5,
                      onTap: () => setState(() => _isExpanded5 = !_isExpanded5),
                    ),
                    
                    SizedBox(height: screenHeight * 0.03),
                    
                    // Quick Actions
                    _buildSectionHeader('Quick Actions'),
                    SizedBox(height: screenHeight * 0.015),
                    
                    _buildContactOption(
                      context: context,
                      onTap: () => _showReportProblemDialog(),
                      iconData: Icons.report_problem,
                      text: 'Report a Problem',
                    ),
                    
                    _buildContactOption(
                      context: context,
                      onTap: () => _showFeedbackDialog(),
                      iconData: Icons.feedback,
                      text: 'Send Feedback',
                    ),
                    
                    SizedBox(height: screenHeight * 0.03),
                    
                    // Support Hours
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: AppTheme.deepBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: AppTheme.deepBlue,
                                size: screenWidth * 0.05,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                'Support Hours',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepBlue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Monday - Friday: 8:00 AM - 8:00 PM\nSaturday - Sunday: 9:00 AM - 6:00 PM',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bottom padding to ensure last item is visible
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Text(
      title,
      style: TextStyle(
        fontSize: screenWidth * 0.045,
        fontWeight: FontWeight.bold,
        color: AppTheme.deepBlue,
      ),
    );
  }

  Widget _buildContactOption({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData iconData,
    required String text,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: double.infinity,
      height: screenHeight * 0.06,
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: DetailContainer(
        onTap: onTap,
        iconData: iconData,
        fontColor: AppTheme.paleWhite,
        fontSize: screenWidth * 0.04,
        text: text,
        
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: AppTheme.paleWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.005,
          ),
          childrenPadding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenHeight * 0.01,
          ),
          title: Text(
            question,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepBlue,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: AppTheme.deepBlue,
            size: screenWidth * 0.05,
          ),
          onExpansionChanged: (expanded) => onTap(),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: screenWidth * 0.033,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'sandranagawa@gmail.com',
      query: 'subject=Support Request&body=Hello, I need help with...',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showErrorDialog('Email app not found');
      }
    } catch (e) {
      _showErrorDialog('Error launching email: $e');
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+256709101171');
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorDialog('Phone app not found');
      }
    } catch (e) {
      _showErrorDialog('Error launching phone: $e');
    }
  }

  void _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/256709101171?text=Hello, I need help with KampuSmart');
    
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('WhatsApp not found');
      }
    } catch (e) {
      _showErrorDialog('Error launching WhatsApp: $e');
    }
  }

  void _showReportProblemDialog() {
    final TextEditingController controller = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report a Problem',
          style: TextStyle(
            color: AppTheme.deepBlue,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        content: SizedBox(
          width: screenWidth * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please describe the problem you\'re experiencing:',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe your problem...',
                    hintStyle: TextStyle(fontSize: screenWidth * 0.035),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.all(screenWidth * 0.03),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog('Problem reported successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepBlue,
              foregroundColor: AppTheme.paleWhite,
            ),
            child: Text(
              'Submit',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController controller = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Send Feedback',
          style: TextStyle(
            color: AppTheme.deepBlue,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        content: SizedBox(
          width: screenWidth * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'We\'d love to hear your thoughts:',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Your feedback...',
                    hintStyle: TextStyle(fontSize: screenWidth * 0.035),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.all(screenWidth * 0.03),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog('Feedback sent successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepBlue,
              foregroundColor: AppTheme.paleWhite,
            ),
            child: Text(
              'Send',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: screenWidth * 0.05,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Success',
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: screenWidth * 0.04),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: screenWidth * 0.05,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Error',
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: screenWidth * 0.04),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
          ),
        ],
      ),
    );
  }
}