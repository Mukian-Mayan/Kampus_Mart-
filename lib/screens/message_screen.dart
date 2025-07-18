// ignore_for_file: deprecated_member_use, sized_box_for_whitespace, use_build_context_synchronously, unused_import, unused_field, prefer_final_fields, avoid_print, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../Theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/chats_service.dart';
import '../models/chat_models.dart';
import '../screens/chats_screen.dart';

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
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isTyping = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _markMessagesAsRead();
    
    // Add listener to scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final fileName = 'chat_images/${DateTime.now().millisecondsSinceEpoch}_${widget.chatRoomId}_${_currentUserId}.jpg';
      
      final response = await _supabase.storage
          .from('chat-images')
          .upload(fileName, imageFile);

      if (response.isEmpty) {
        throw Exception('Failed to upload image to Supabase');
      }

      // Get public URL
      final imageUrl = _supabase.storage
          .from('chat-images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUserId == null) return;

    String message = _messageController.text.trim();
    _messageController.clear();

    try {
      await _chatService.sendMessage(
        chatRoomId: widget.chatRoomId,
        message: message,
        receiverId: widget.otherParticipantId,
      );
      
      // Scroll to bottom after sending message
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
      // Restore message in text field if sending failed
      _messageController.text = message;
    }
  }

  Future<void> _sendImage() async {
    if (_currentUserId == null) return;

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

      // Upload image to Supabase Storage
      final imageFile = File(image.path);
      final imageUrl = await _uploadImageToSupabase(imageFile);

      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      // Send message with image URL using the service method
      await _chatService.sendImageMessage(
        chatRoomId: widget.chatRoomId,
        imageUrl: imageUrl,
        caption: 'Photo',
        receiverId: widget.otherParticipantId,
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.tertiaryOrange,
              child: Text(
                widget.otherParticipantName[0].toUpperCase(),
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[400],
                          child: const Icon(Icons.error),
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
                      color: isCurrentUser ? Colors.white : Colors.black87,
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
                widget.userName[0].toUpperCase(),
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
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
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
      bottomNavigationBar: const BottomNavBar(selectedIndex: 3, navBarColor: Colors.transparent),
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
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
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
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
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
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