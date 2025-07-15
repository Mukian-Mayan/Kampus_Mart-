// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../Theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class MessageScreen extends StatelessWidget {
  final String userName;
  final String userAvatar; // You can add this to your ChatMessage class later

  const MessageScreen({
    super.key,
    required this.userName,
    this.userAvatar = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(selectedIndex: 3,navBarColor: AppTheme.tertiaryOrange),
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        title: Text(userName, style: AppTheme.titleStyle.copyWith(fontSize: 20)),
        elevation: 0,
      ),
      backgroundColor: AppTheme.backgroundLavender,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessage('Hi there!', false),
                _buildMessage('How are you?', true),
                _buildMessage('I\'m good, thanks!', false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.paleWhite,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: AppTheme.primaryOrange),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.selectedBlue : AppTheme.paleWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : AppTheme.textPrimary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}