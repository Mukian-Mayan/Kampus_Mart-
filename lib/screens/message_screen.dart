// ignore_for_file: deprecated_member_use, sized_box_for_whitespace, use_build_context_synchronously, unused_import, unused_field, prefer_final_fields, avoid_print, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'dart:io';
import '../Theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/chats_service.dart';
import '../models/chat_models.dart';
import '../screens/chats_screen.dart';
import '../utils/chat_utils.dart';
import '../ml/services/enhanced_product_service.dart';

class MessageScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherParticipantName;
  final String otherParticipantId;
  final String productName;
  final String? productImageUrl;
  final String userName;

  const MessageScreen({
    super.key,
    required this.chatRoomId,
    required this.otherParticipantName,
    required this.otherParticipantId,
    required this.productName,
    this.productImageUrl,
    required this.userName,
  });

  @override
  State<MessageScreen> createState() => _EnhancedMessageScreenState();
}

class _EnhancedMessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool _isTyping = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _verifyChatRoomAndInit();

    // Add listener to scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _verifyChatRoomAndInit() async {
    try {
      // Verify the chat room exists
      final chatRoom = await _chatService.getChatRoom(widget.chatRoomId);
      if (chatRoom == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Chat room not found. Please start a new conversation.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      _markMessagesAsRead();
      _chatService.debugChatRoomStructure(widget.chatRoomId);
    } catch (e) {
      print('Error verifying chat room: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading chat: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() {
    if (_currentUserId != null) {
      _chatService.markMessagesAsRead(widget.chatRoomId);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUserId == null)
      return;

    String message = _messageController.text.trim();
    _messageController.clear();

    try {
      // First verify the chat room exists
      final chatRoom = await _chatService.getChatRoom(widget.chatRoomId);
      if (chatRoom == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Chat room not found. Please start a new conversation.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        _messageController.text = message; // Restore message
        return;
      }

      await _chatService.sendMessage(
        chatRoomId: widget.chatRoomId,
        message: message,
        receiverId: widget.otherParticipantId,
      );

      // Track chat interaction with ML API
      try {
        await EnhancedProductService.recordUserInteraction(
          productId: 'chat_${widget.chatRoomId}',
          interactionType: 'chat_message',
          metadata: {
            'product_name': widget.productName,
            'seller_id': widget.otherParticipantId,
            'seller_name': widget.otherParticipantName,
            'message_length': message.length.toString(),
            'chat_room_id': widget.chatRoomId,
          },
        );
      } catch (e) {
        print('Error recording chat interaction: $e');
      }

      // Scroll to bottom after sending message
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send message: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      // Restore message in text field if sending failed
      _messageController.text = message;
    }
  }

  Future<void> _sendImage() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to send images'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      // Verify user authentication again
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (kDebugMode) {
        print('Current user authenticated: ${currentUser.uid}');
        print('Attempting to send image: ${image.name}');
      }

      // Test storage permissions first
      final permissionsTest = await _chatService.testStoragePermissions();
      if (!permissionsTest) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permissions test failed. Please check Firebase configuration or contact support.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // First verify the chat room exists
      final chatRoom = await _chatService.getChatRoom(widget.chatRoomId);
      if (chatRoom == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Chat room not found. Please start a new conversation.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Send image message using the chat service (handles upload automatically)
      await _chatService.sendImageMessage(
        chatRoomId: widget.chatRoomId,
        imageFile: image,
        caption: 'Photo',
        receiverId: widget.otherParticipantId,
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error sending image: $e');

      String errorMessage = 'Failed to send image';

      // Provide specific error messages for common issues
      String errorString = e.toString().toLowerCase();
      if (errorString.contains('unauthorized') ||
          errorString.contains('permission')) {
        errorMessage =
            'Upload permission denied. Please check your account settings.';
      } else if (errorString.contains('network') ||
          errorString.contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (errorString.contains('size') ||
          errorString.contains('large')) {
        errorMessage =
            'Image file is too large. Please choose a smaller image.';
      } else if (errorString.contains('format') ||
          errorString.contains('type')) {
        errorMessage =
            'Unsupported image format. Please choose a JPEG or PNG image.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _sendImage(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAuthRequired() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: AppTheme.tertiaryOrange,
      ),
      body: const Center(
        child: Text(
          'Please log in to access chat',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showChatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat with: ${widget.otherParticipantName}'),
            const SizedBox(height: 8),
            Text('Product: ${widget.productName}'),
            const SizedBox(height: 8),
            Text('Chat ID: ${widget.chatRoomId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isCurrentUser = message.senderId == _currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.tertiaryOrange,
              child: Text(
                widget.otherParticipantName.isNotEmpty
                    ? widget.otherParticipantName[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentUser ? AppTheme.tertiaryOrange : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      message.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading message image: $error');
                        return Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[400],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              Text(
                                'Failed to load',
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (message.message.isNotEmpty) const SizedBox(height: 8),
                ],
                if (message.message.isNotEmpty)
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.black87 : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.tertiaryOrange,
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return _buildAuthRequired();
    }

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 3,
        navBarColor: Colors.transparent,
      ),
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherParticipantName,
              style: AppTheme.titleStyle.copyWith(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              widget.productName,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showChatInfo();
            },
          ),
        ],
      ),
      backgroundColor: AppTheme.backgroundLavender,
      body: Column(
        children: [
          // Product info header
          if (widget.productImageUrl != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.paleWhite,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.productImageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 1),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading product image: $error');
                        return Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Product discussion',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Messages area
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(widget.chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index]);
                  },
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 8),
                  Text('Sending image...'),
                ],
              ),
            ),

          // Message input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.paleWhite,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.photo_camera,
                    color: AppTheme.tertiaryOrange,
                  ),
                  onPressed: _isLoading ? null : _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.tertiaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
