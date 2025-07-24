// screens/enhanced_chats_screen.dart
// ignore_for_file: unused_import, unused_field, prefer_final_fields, sized_box_for_whitespace, deprecated_member_use, use_build_context_synchronously, override_on_non_overriding_member, unused_element

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Theme/app_theme.dart';
import '../widgets/layout1.dart';
import '../services/chats_service.dart';
import '../models/chat_models.dart';
import '../screens/message_screen.dart';

class ChatsScreen extends StatefulWidget {
  static const String routeName = '/ChatsScreen';
  final UserRole userRole;
  const ChatsScreen({super.key, required this.userRole});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  String _searchQuery = '';
  List<ChatRoom> _filteredChatRooms = [];
  bool _isLoading = true;
  String? _currentUserId;
  String? userRole;
  int selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    print('Current User ID: $_currentUserId');
    _searchController.addListener(_onSearchChanged);
    _loadUserRole();

    // Clear chat service cache to force refresh of user profiles
    _chatService.clearUserProfileCache();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role');
    });
  }

  void testFirestoreConnection() async {
    await _chatService.debugFirestoreConnection();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Replace the _filterChatRooms method in chats_screen.dart

  List<ChatRoom> _filterChatRooms(List<ChatRoom> chatsRooms) {
    if (_searchQuery.isEmpty) {
      return chatsRooms;
    }
    return chatsRooms.where((chat) {
      // Get the other participant's name directly from the chat room data
      bool isCurrentUserSeller = chat.sellerId == _currentUserId;
      String otherParticipantName = isCurrentUserSeller
          ? chat.buyerName
          : chat.sellerName;

      return otherParticipantName.toLowerCase().contains(_searchQuery) ||
          chat.productName.toLowerCase().contains(_searchQuery) ||
          chat.lastMessage.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _onTab(int index) {
    if (selectedIndex != index) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return _buildAuthRequired();
    }

    return Scaffold(
      // Update the bottomNavigationBar section to match home_page.dart
      bottomNavigationBar: widget.userRole == UserRole.seller
          ? BottomNavBar2(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            )
          : BottomNavBar(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            ),
      backgroundColor: AppTheme.tertiaryOrange,
      body: SafeArea(
        child: Column(
          children: [
            // Header section with Layout1 inverted
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(1.0, -1.0),
                  child: Layout1(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(1.0, -1.0),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Title with unread count
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Chats',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                FutureBuilder<int>(
                                  future: _chatService.getUnreadMessagesCount(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data! > 0) {
                                      return Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${snapshot.data}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Search bar
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search chats...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                        )
                                      : Icon(
                                          Icons.search,
                                          color: Colors.grey[600],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Chat list section
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: // Replace the StreamBuilder in your ChatsScreen with this version
                StreamBuilder<List<ChatRoom>>(
                  stream: _chatService.getChatRoomsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      print('StreamBuilder error: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading chats',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {});
                              },
                              child: const Text('Retry'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () async {
                                await _chatService.debugFirestoreConnection();
                              },
                              child: const Text('Debug Connection'),
                            ),
                          ],
                        ),
                      );
                    }

                    List<ChatRoom> chatsRooms = snapshot.data ?? [];
                    List<ChatRoom> filteredChatRooms = _filterChatRooms(
                      chatsRooms,
                    );
                    _debugChatRooms(chatsRooms);

                    if (filteredChatRooms.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No chats yet'
                                  : 'No chats found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchQuery.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Start a conversation by messaging a seller',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredChatRooms.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChatRooms[index];
                        return _buildChatItem(chat);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update the _buildChatItem method in _ChatsScreenState
  Widget _buildChatItem(ChatRoom chat) {
    // Get the other participant's details
    bool isCurrentUserSeller = chat.sellerId == _currentUserId;
    String otherParticipantName = isCurrentUserSeller
        ? chat.buyerName
        : chat.sellerName;
    String otherParticipantId = isCurrentUserSeller
        ? chat.buyerId
        : chat.sellerId;

    // Fallback to IDs if names are empty or look like fallback names
    if (otherParticipantName.isEmpty ||
        otherParticipantName.startsWith('User ')) {
      otherParticipantName = 'User';
    }

    // Same for current user name
    String currentUserName = isCurrentUserSeller
        ? chat.sellerName
        : chat.buyerName;
    if (currentUserName.isEmpty || currentUserName.startsWith('User ')) {
      currentUserName = 'You';
    }

    // Get unread count for current user
    int unreadCount = isCurrentUserSeller
        ? chat.unreadCountSeller
        : chat.unreadCountBuyer;
    bool hasUnread = unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          // Mark messages as read when opening chat
          if (hasUnread) {
            await _chatService.markMessagesAsRead(chat.id);
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessageScreen(
                chatRoomId: chat.id,
                otherParticipantName: otherParticipantName,
                otherParticipantId: otherParticipantId,
                productName: chat.productName,
                productImageUrl: chat.productImageUrl,
                userName: currentUserName,
              ),
            ),
          );
        },
        onLongPress: () {
          _showChatOptions(chat);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.paleWhite.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: hasUnread
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
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: 30,
                    ),
                  ),
                  if (hasUnread)
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherParticipantName,
                            style: TextStyle(
                              fontWeight: hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (!isCurrentUserSeller)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Seller',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chat.productName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessage.isNotEmpty
                          ? chat.lastMessage
                          : 'No messages yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: hasUnread
                            ? FontWeight.w600
                            : FontWeight.normal,
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
                    ChatService.getFormattedTime(chat.lastMessageTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: hasUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
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
  }

  void _showChatOptions(ChatRoom chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_chat_read),
              title: const Text('Mark as Read'),
              onTap: () async {
                Navigator.pop(context);
                await _chatService.markMessagesAsRead(chat.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Chat',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                _showDeleteConfirmation(chat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ChatRoom chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
          'Are you sure you want to delete this chat? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _chatService.deleteChatRoom(chat.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete chat: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _debugChatRooms(List<ChatRoom> chatsRooms) {
    print('=== CHAT ROOMS DEBUG ===');
    print('Current User ID: $_currentUserId');
    print('Total Chat Rooms: ${chatsRooms.length}');

    for (var chat in chatsRooms) {
      print('--- Chat Room: ${chat.id} ---');
      print('Seller ID: ${chat.sellerId}');
      print('Buyer ID: ${chat.buyerId}');
      print('Seller Name: ${chat.sellerName}');
      print('Buyer Name: ${chat.buyerName}');
      print('Product: ${chat.productName}');
      print('Last Message: ${chat.lastMessage}');
      print('Last Message Time: ${chat.lastMessageTime}');
      print('Last Message Sender: ${chat.lastMessageSenderId}');
      print('Unread Count Seller: ${chat.unreadCountSeller}');
      print('Unread Count Buyer: ${chat.unreadCountBuyer}');
      print('Participants: ${chat.participants}');
      print('Is Current User Seller: ${chat.sellerId == _currentUserId}');
      print('');
    }
    print('=== END DEBUG ===');
  }

  Widget _buildAuthRequired() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Please log in to view chats',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to login screen
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
