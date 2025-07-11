

// ignore_for_file: avoid_print, sized_box_for_whitespace, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import '../Theme/app_theme.dart';
import '../widgets/layout1.dart';
import '../screens/message_screen.dart';
import '../widgets/search_bar.dart' as custom;

class ChatsScreen extends StatefulWidget {
  static const String routeName = '/ChatsScreen';
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ChatMessage> chatMessages = [
    ChatMessage(
      id: 1,
      name: "Eron",
      message: "Hey, how are you doing?",
      time: "12:00 pm",
      unreadCount: 3,
      hasNewMessage: true,
    ),
    ChatMessage(
      id: 2,
      name: "Martin",
      message: "Can we meet tomorrow?",
      time: "12:00 pm",
      unreadCount: 1,
      hasNewMessage: true,
    ),
    ChatMessage(
      id: 3,
      name: "Joel",
      message: "Thanks for the help!",
      time: "12:00 pm",
      unreadCount: 0,
      hasNewMessage: false,
    ),
    ChatMessage(
      id: 4,
      name: "Jollyne",
      message: "See you when we meet",
      time: "12:00 pm",
      unreadCount: 2,
      hasNewMessage: true,
    ),
    ChatMessage(
      id: 5,
      name: "Alex Brown",
      message: "Can you give me a discount",
      time: "12:00 pm",
      unreadCount: 0,
      hasNewMessage: false,
    ),
    ChatMessage(
      id: 6,
      name: "Emma Davis",
      message: "do you have that suitcase in only blue",
      time: "12:00 pm",
      unreadCount: 1,
      hasNewMessage: true,
    ),
  ];

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<ChatMessage> get filteredChatMessages {
    if (_searchQuery.isEmpty) {
      return chatMessages;
    }
    return chatMessages.where((chat) {
      return chat.name.toLowerCase().contains(_searchQuery) ||
             chat.message.toLowerCase().contains(_searchQuery);
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        elevation: 0,
        title: Text('Chats', style: AppTheme.titleStyle.copyWith(fontSize: 22)),
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 3),
      backgroundColor: AppTheme.backgroundLavender,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: custom.SearchBar(
              hintText: 'Search chats...',
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
          ),
          // Chat list section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredChatMessages.length,
                itemBuilder: (context, index) {
                  final chat = filteredChatMessages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageScreen(
                              userName: chat.name,
                            ),
                          ),
                        );
                        // Mark as read when opened
                        setState(() {
                          chat.hasNewMessage = false;
                          chat.unreadCount = 0;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.paleWhite,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: chat.hasNewMessage
                              ? Border.all(color: AppTheme.primaryOrange, width: 2)
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Profile avatar with indicator
                            Stack(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundLavender,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: AppTheme.textSecondary,
                                    size: 30,
                                  ),
                                ),
                                if (chat.hasNewMessage)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.lightGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Message content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat.name,
                                    style: AppTheme.titleStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    chat.message,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Time and notification
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  chat.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (chat.unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryOrange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${chat.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _buildNavItem(IconData icon, bool isSelected, String route) {
    return GestureDetector(
      onTap: () {
        _navigateToScreen(route);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.deepBlue : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppTheme.deepBlue,
          size: 24,
        ),
      ),
    );
  }*/
}

class ChatMessage {
  final int id;
  final String name;
  final String message;
  final String time;
  int unreadCount; // Changed from final to mutable
  bool hasNewMessage; // Changed from final to mutable

  ChatMessage({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
    required this.hasNewMessage,
  });
}