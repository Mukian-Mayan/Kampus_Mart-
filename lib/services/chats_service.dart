// services/chats_service.dart
// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat_models.dart';
import '../services/supabase_storage_service.dart';
import '../services/notificaations_service.dart'; // Fixed typo: notificaations -> notifications

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseStorageService _storageService = SupabaseStorageService();
  final NotificationService _notificationService = NotificationService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user profile from users collection
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Create or get existing chat room with enhanced features
  Future<String> createOrGetChatRoom({
    required String sellerId,
    required String buyerId,
    required String productId,
    required String productName,
    required String productImageUrl,
    required String productPrice,
    required String productDescription,
    required String sellerName,
    required String buyerName,
    String? sellerImageUrl,
    String? buyerImageUrl,
  }) async {
    try {
      // Get user profiles to fetch roles from database
      UserProfile? sellerProfile = await getUserProfile(sellerId);
      UserProfile? buyerProfile = await getUserProfile(buyerId);
      
      // Create chat room ID (consistent for same participants)
      String chatRoomId = _generateChatRoomId(sellerId, buyerId, productId);
      
      // Check if chat room document already exists in chatRooms collection
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (!chatRoomDoc.exists) {
        // Create new chat room document with enhanced features
        ChatRoom newChatRoom = ChatRoom(
          id: chatRoomId,
          sellerId: sellerId,
          buyerId: buyerId,
          sellerName: sellerName,
          buyerName: buyerName,
          sellerImageUrl: sellerImageUrl ?? sellerProfile?.imageUrl,
          buyerImageUrl: buyerImageUrl ?? buyerProfile?.imageUrl,
          sellerRole: sellerProfile?.role ?? UserRole.seller,
          buyerRole: buyerProfile?.role ?? UserRole.buyer,
          productId: productId,
          productName: productName,
          productImageUrl: productImageUrl,
          productPrice: productPrice,
          productDescription: productDescription,
          lastMessage: '',
          lastMessageTime: Timestamp.now(),
          lastMessageSenderId: '',
          lastMessageType: MessageType.text,
          unreadCountSeller: 0,
          unreadCountBuyer: 0,
          isActiveForSeller: true,
          isActiveForBuyer: true,
          status: ChatRoomStatus.active,
          participants: [sellerId, buyerId],
          blockedBy: [],
          isGroupChat: false,
          createdAt: Timestamp.now(),
          metadata: {
            'created_by': currentUser?.uid,
            'chat_type': 'product_inquiry',
          },
        );

        // Save chat room document to Firestore
        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .set(newChatRoom.toMap());

        // Send welcome message to messages subcollection
        await _sendWelcomeMessage(chatRoomId, productName);
      } else {
        // Update existing chat room document if needed
        await _updateChatRoomActivity(chatRoomId);
      }

      return chatRoomId;
    } catch (e) {
      throw Exception('Failed to create/get chat room: $e');
    }
  }

  // Generate consistent chat room ID
  String _generateChatRoomId(String sellerId, String buyerId, String productId) {
    List<String> participants = [sellerId, buyerId];
    participants.sort(); // Ensure consistent ordering
    return '${participants[0]}_${participants[1]}_$productId';
  }

  // Send welcome message to messages subcollection
  Future<void> _sendWelcomeMessage(String chatRoomId, String productName) async {
    try {
      final messagesCollection = _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages');
      
      final welcomeMessage = Message(
        id: messagesCollection.doc().id,
        senderId: 'system',
        senderName: 'System',
        message: 'Welcome! You\'re now connected to discuss "$productName".',
        timestamp: Timestamp.now(),
        messageType: MessageType.system,
        isRead: false,
        deliveryStatus: DeliveryStatus.delivered,
        metadata: {
          'message_type': 'welcome',
          'product_name': productName,
        },
      );

      await messagesCollection
          .doc(welcomeMessage.id)
          .set(welcomeMessage.toMap());
    } catch (e) {
      print('Error sending welcome message: $e');
    }
  }

  // Update chat room document activity
  Future<void> _updateChatRoomActivity(String chatRoomId) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .update({
        'lastActivityTime': Timestamp.now(),
        'isActiveForSeller': true,
        'isActiveForBuyer': true,
      });
    } catch (e) {
      print('Error updating chat room activity: $e');
    }
  }

  // Send message with enhanced features
  Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    MessageType messageType = MessageType.text,
    String? imageUrl,
    String? voiceUrl,
    String? fileName,
    String? fileUrl,
    Map<String, dynamic>? metadata,
    String? receiverId, // Made optional with default null
  }) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');

      // Get user profile from users collection
      UserProfile? senderProfile = await getUserProfile(currentUser!.uid);
      String senderName = senderProfile?.name ?? 'Unknown';

      // Get chat room to determine receiver ID if not provided
      if (receiverId == null) {
        DocumentSnapshot chatRoomDoc = await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .get();
        
        if (chatRoomDoc.exists) {
          Map<String, dynamic> chatRoomData = chatRoomDoc.data() as Map<String, dynamic>;
          receiverId = currentUser!.uid == chatRoomData['sellerId'] 
              ? chatRoomData['buyerId'] 
              : chatRoomData['sellerId'];
        }
      }

      // Create message document
      final messagesCollection = _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages');
      
      final chatMessage = Message(
        id: messagesCollection.doc().id,
        senderId: currentUser!.uid,
        senderName: senderName,
        message: message,
        timestamp: Timestamp.now(),
        messageType: messageType,
        isRead: false,
        deliveryStatus: DeliveryStatus.sent,
        imageUrl: imageUrl,
        voiceUrl: voiceUrl,
        fileName: fileName,
        fileUrl: fileUrl,
        metadata: metadata ?? {},
      );

      // Save message document to messages subcollection
      await messagesCollection
          .doc(chatMessage.id)
          .set(chatMessage.toMap());

      // Update chat room with last message info
      await _updateChatRoomLastMessage(chatRoomId, chatMessage);

      // Send notification to other participant
      if (receiverId != null) {
        await _sendNotificationToParticipant(chatRoomId, chatMessage);
      }

      // Update delivery status
      await _updateMessageDeliveryStatus(chatRoomId, chatMessage.id, DeliveryStatus.delivered);

    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Update chat room last message
  Future<void> _updateChatRoomLastMessage(String chatRoomId, Message message) async {
    try {
      // Get chat room to determine unread counts
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData = chatRoomDoc.data() as Map<String, dynamic>;
        
        // Update unread count for the recipient
        Map<String, dynamic> updateData = {
          'lastMessage': message.message,
          'lastMessageTime': message.timestamp,
          'lastMessageSenderId': message.senderId,
          'lastMessageType': message.messageType.toString(),
        };

        if (message.senderId == chatRoomData['sellerId']) {
          updateData['unreadCountBuyer'] = (chatRoomData['unreadCountBuyer'] ?? 0) + 1;
        } else {
          updateData['unreadCountSeller'] = (chatRoomData['unreadCountSeller'] ?? 0) + 1;
        }

        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .update(updateData);
      }
    } catch (e) {
      print('Error updating chat room last message: $e');
    }
  }

  // Send notification to participant
  Future<void> _sendNotificationToParticipant(String chatRoomId, Message message) async {
    try {
      // Get chat room info
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData = chatRoomDoc.data() as Map<String, dynamic>;
        
        // Determine recipient
        String recipientId = message.senderId == chatRoomData['sellerId'] 
            ? chatRoomData['buyerId'] 
            : chatRoomData['sellerId'];

        // Send notification
        await NotificationService.sendChatNotification(
          recipientId: recipientId,
          senderName: message.senderName,
          message: message.message,
          chatRoomId: chatRoomId,
          productName: chatRoomData['productName'],
        );
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Update message delivery status
  Future<void> _updateMessageDeliveryStatus(String chatRoomId, String messageId, DeliveryStatus status) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'deliveryStatus': status.toString(),
        'deliveredAt': status == DeliveryStatus.delivered ? Timestamp.now() : null,
      });
    } catch (e) {
      print('Error updating message delivery status: $e');
    }
  }

  // Upload multiple images - FIXED METHOD
  Future<List<String>> uploadImages(List<XFile> images, String chatRoomId) async {
    try {
      List<String> imageUrls = [];
      
      for (int i = 0; i < images.length; i++) {
        String fileName = 'chat_images/${chatRoomId}/${DateTime.now().millisecondsSinceEpoch}_$i';
        String imageUrl = await SupabaseStorageService.uploadChatImage(images[i], fileName);
        imageUrls.add(imageUrl);
      }
      
      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  // Send image message with URL (for MessageScreen compatibility)
  Future<void> sendImageMessage({
    required String chatRoomId,
    required String imageUrl,
    String? caption,
    String? receiverId,
  }) async {
    try {
      // Send message with image URL
      await sendMessage(
        chatRoomId: chatRoomId,
        message: caption ?? 'Photo',
        messageType: MessageType.image,
        imageUrl: imageUrl,
        receiverId: receiverId,
      );
    } catch (e) {
      throw Exception('Failed to send image message: $e');
    }
  }

  // Send image message with file upload
  Future<void> sendImageMessageWithFile({
    required String chatRoomId,
    required XFile imageFile,
    String? caption,
    String? receiverId,
  }) async {
    try {
      // Upload image to storage
      String imageUrl = await SupabaseStorageService.uploadChatImage(
        imageFile,
        'chat_images/${chatRoomId}/${DateTime.now().millisecondsSinceEpoch}',
      );

      // Send message with image
      await sendMessage(
        chatRoomId: chatRoomId,
        message: caption ?? 'Photo',
        messageType: MessageType.image,
        imageUrl: imageUrl,
        receiverId: receiverId,
      );
    } catch (e) {
      throw Exception('Failed to send image message: $e');
    }
  }

  // Send multiple images
  Future<void> sendMultipleImages({
    required String chatRoomId,
    required List<XFile> images,
    String? caption,
    String? receiverId,
  }) async {
    try {
      // Upload all images
      List<String> imageUrls = await uploadImages(images, chatRoomId);
      
      // Send each image as a separate message
      for (int i = 0; i < imageUrls.length; i++) {
        String messageCaption = caption ?? 'Photo ${i + 1}';
        if (images.length > 1) {
          messageCaption += ' (${i + 1}/${images.length})';
        }
        
        await sendMessage(
          chatRoomId: chatRoomId,
          message: messageCaption,
          messageType: MessageType.image,
          imageUrl: imageUrls[i],
          receiverId: receiverId,
        );
      }
    } catch (e) {
      throw Exception('Failed to send multiple images: $e');
    }
  }

  // Send voice message
  Future<void> sendVoiceMessage({
    required String chatRoomId,
    required String voiceFilePath,
    required int duration,
    String? receiverId,
  }) async {
    try {
      // Upload voice file to storage
      String voiceUrl = await _storageService.uploadVoiceMessage(
        voiceFilePath,
        'voice_messages/${chatRoomId}/${DateTime.now().millisecondsSinceEpoch}',
      );

      // Send message with voice
      await sendMessage(
        chatRoomId: chatRoomId,
        message: 'Voice message',
        messageType: MessageType.voice,
        voiceUrl: voiceUrl,
        metadata: {'duration': duration},
        receiverId: receiverId,
      );
    } catch (e) {
      throw Exception('Failed to send voice message: $e');
    }
  }

  // Send file message
  Future<void> sendFileMessage({
    required String chatRoomId,
    required XFile file,
    String? caption,
    String? receiverId,
  }) async {
    try {
      // Upload file to storage
      String fileUrl = await _storageService.uploadChatFile(
        file,
        'chat_files/${chatRoomId}/${DateTime.now().millisecondsSinceEpoch}',
      );

      // Send message with file
      await sendMessage(
        chatRoomId: chatRoomId,
        message: caption ?? 'File',
        messageType: MessageType.file,
        fileUrl: fileUrl,
        fileName: file.name,
        receiverId: receiverId,
      );
    } catch (e) {
      throw Exception('Failed to send file message: $e');
    }
  }

  // Get messages for MessageScreen compatibility
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Changed to ascending for proper chat order
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        
        // Convert Message to ChatMessage for MessageScreen compatibility
        return ChatMessage(
          id: doc.id,
          senderId: data['senderId'] ?? '',
          senderName: data['senderName'] ?? '',
          message: data['message'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          messageType: _parseMessageType(data['messageType']),
          isRead: data['isRead'] ?? false,
          imageUrl: data['imageUrl'],
          voiceUrl: data['voiceUrl'],
          fileName: data['fileName'],
          fileUrl: data['fileUrl'],
        );
      }).toList();
    });
  }

  // Helper method to parse message type
  MessageType _parseMessageType(dynamic messageType) {
    if (messageType == null) return MessageType.text;
    
    if (messageType is String) {
      switch (messageType) {
        case 'MessageType.text':
          return MessageType.text;
        case 'MessageType.image':
          return MessageType.image;
        case 'MessageType.voice':
          return MessageType.voice;
        case 'MessageType.file':
          return MessageType.file;
        case 'MessageType.system':
          return MessageType.system;
        default:
          return MessageType.text;
      }
    }
    
    if (messageType is MessageType) {
      return messageType;
    }
    
    return MessageType.text;
  }

  // Get chat rooms stream for current user
  Stream<List<ChatRoom>> getChatRoomsStream() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUser!.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return ChatRoom.fromMap(data);
      }).toList();
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      if (currentUser == null) return;

      // Get unread messages for current user
      QuerySnapshot unreadMessages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUser!.uid)
          .where('isRead', isEqualTo: false)
          .get();

      // Update each unread message
      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.now(),
        });
      }
      await batch.commit();

      // Update unread count in chat room
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData = chatRoomDoc.data() as Map<String, dynamic>;
        
        Map<String, dynamic> updateData = {};
        if (currentUser!.uid == chatRoomData['sellerId']) {
          updateData['unreadCountSeller'] = 0;
        } else {
          updateData['unreadCountBuyer'] = 0;
        }

        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .update(updateData);
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Get total unread messages count
  Future<int> getUnreadMessagesCount() async {
    try {
      if (currentUser == null) return 0;

      QuerySnapshot chatRooms = await _firestore
          .collection('chatRooms')
          .where('participants', arrayContains: currentUser!.uid)
          .get();

      int totalUnread = 0;
      for (QueryDocumentSnapshot doc in chatRooms.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        if (currentUser!.uid == data['sellerId']) {
          totalUnread += (data['unreadCountSeller'] ?? 0) as int;
        } else {
          totalUnread += (data['unreadCountBuyer'] ?? 0) as int;
        }
      }

      return totalUnread;
    } catch (e) {
      print('Error getting unread messages count: $e');
      return 0;
    }
  }

  // Delete chat room
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');

      // Delete all messages in the chat room
      QuerySnapshot messages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete the chat room document
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete chat room: $e');
    }
  }

  // Block user
  Future<void> blockUser(String chatRoomId, String userId) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');

      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .update({
        'blockedBy': FieldValue.arrayUnion([currentUser!.uid]),
        'status': ChatRoomStatus.blocked.toString(),
      });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  // Unblock user
  Future<void> unblockUser(String chatRoomId, String userId) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');

      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .update({
        'blockedBy': FieldValue.arrayRemove([currentUser!.uid]),
        'status': ChatRoomStatus.active.toString(),
      });
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  // Check if user is blocked
  Future<bool> isUserBlocked(String chatRoomId, String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> blockedBy = data['blockedBy'] ?? [];
        return blockedBy.contains(userId);
      }
      return false;
    } catch (e) {
      print('Error checking if user is blocked: $e');
      return false;
    }
  }

  // Get chat room details
  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (doc.exists) {
        return ChatRoom.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting chat room: $e');
      return null;
    }
  }

  // Archive chat room
  Future<void> archiveChatRoom(String chatRoomId) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');

      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData = chatRoomDoc.data() as Map<String, dynamic>;
        
        Map<String, dynamic> updateData = {};
        if (currentUser!.uid == chatRoomData['sellerId']) {
          updateData['isActiveForSeller'] = false;
        } else {
          updateData['isActiveForBuyer'] = false;
        }

        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to archive chat room: $e');
    }
  }

  // Unarchive chat room
  Future<void> unarchiveChatRoom(String chatRoomId) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');

      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData = chatRoomDoc.data() as Map<String, dynamic>;
        
        Map<String, dynamic> updateData = {};
        if (currentUser!.uid == chatRoomData['sellerId']) {
          updateData['isActiveForSeller'] = true;
        } else {
          updateData['isActiveForBuyer'] = true;
        }

        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to unarchive chat room: $e');
    }
  }
  // Add these methods to the ChatService class in chats_service.dart

// Get the other participant's name in a chat room
Future<String?> getOtherParticipantName(String chatRoomId) async {
  try {
    if (currentUser == null) return null;
    
    DocumentSnapshot chatRoomDoc = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .get();

    if (chatRoomDoc.exists) {
      Map<String, dynamic> data = chatRoomDoc.data() as Map<String, dynamic>;
      if (currentUser!.uid == data['sellerId']) {
        return data['buyerName'] as String?;
      } else {
        return data['sellerName'] as String?;
      }
    }
    return null;
  } catch (e) {
    print('Error getting other participant name: $e');
    return null;
  }
}

// Get unread count for the current user in a specific chat room
Future<int> getUnreadCount(String chatRoomId) async {
  try {
    if (currentUser == null) return 0;
    
    DocumentSnapshot chatRoomDoc = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .get();

    if (chatRoomDoc.exists) {
      Map<String, dynamic> data = chatRoomDoc.data() as Map<String, dynamic>;
      if (currentUser!.uid == data['sellerId']) {
        return (data['unreadCountSeller'] ?? 0) as int;
      } else {
        return (data['unreadCountBuyer'] ?? 0) as int;
      }
    }
    return 0;
  } catch (e) {
    print('Error getting unread count: $e');
    return 0;
  }
}

// Check if a given user ID is the current user
bool isCurrentUser(String userId) {
  return currentUser?.uid == userId;
}

// Helper method to format timestamp
String getFormattedTime(Timestamp timestamp) {
  final date = timestamp.toDate();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final messageDate = DateTime(date.year, date.month, date.day);

  if (messageDate == today) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } else if (messageDate == yesterday) {
    return 'Yesterday';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}
// Add these methods to your ChatService class


// Get other participant's details (including role)
Future<Map<String, dynamic>?> getOtherParticipantDetailsById(String chatRoomId, String currentUserId) async {
  try {
    DocumentSnapshot chatRoomDoc = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .get();

    if (chatRoomDoc.exists) {
      Map<String, dynamic> data = chatRoomDoc.data() as Map<String, dynamic>;
      bool isSeller = currentUserId == data['sellerId'];
      
      return {
        'id': isSeller ? data['buyerId'] : data['sellerId'],
        'name': isSeller ? data['buyerName'] : data['sellerName'],
        'imageUrl': isSeller ? data['buyerImageUrl'] : data['sellerImageUrl'],
        'isSeller': !isSeller, // The other participant's role
        'currentUserIsSeller': isSeller,
      };
    }
    return null;
  } catch (e) {
    print('Error getting other participant details: $e');
    return null;
  }
}
// Add these methods to your ChatService class

// Check if current user is seller
Future<bool> isCurrentUserSeller(String userId) async {
  try {
    UserProfile? userProfile = await getUserProfile(userId);
    return userProfile?.role == UserRole.seller;
  } catch (e) {
    print('Error checking user role: $e');
    return false;
  }
}

// Get other participant's details (including role)
Future<Map<String, dynamic>?> getOtherParticipantDetails(String chatRoomId, String currentUserId) async {
  try {
    DocumentSnapshot chatRoomDoc = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .get();

    if (chatRoomDoc.exists) {
      Map<String, dynamic> data = chatRoomDoc.data() as Map<String, dynamic>;
      bool isSeller = currentUserId == data['sellerId'];
      
      return {
        'id': isSeller ? data['buyerId'] : data['sellerId'],
        'name': isSeller ? data['buyerName'] : data['sellerName'],
        'imageUrl': isSeller ? data['buyerImageUrl'] : data['sellerImageUrl'],
        'isSeller': !isSeller, // The other participant's role
        'currentUserIsSeller': isSeller,
      };
    }
    return null;
  } catch (e) {
    print('Error getting other participant details: $e');
    return null;
  }
}
}