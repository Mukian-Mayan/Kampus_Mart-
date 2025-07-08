import 'package:flutter/material.dart';
import '../Theme/app_theme.dart';

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
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        title: Text(userName),
      ),
      body: Column(
        children: [
          // Message list would go here
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Example messages
                _buildMessage('Hi there!', false),
                _buildMessage('How are you?', true),
                _buildMessage('I\'m good, thanks!', false),
              ],
            ),
          ),
          // Message input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Send message logic
                  },
                ),
              ],
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
          color: isMe ? AppTheme.selectedBlue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
      ),
    );
  }
}