// services/chats_service.dart
// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode

import '../models/chat_models.dart';
import 'notifications_service.dart';
import '../models/user_role.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  static const int _maxFileSize = 10 * 1024 * 1024; // 10 MB

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Cache for user profiles to avoid repeated lookups
  final Map<String, UserProfile> _userProfileCache = {};

  /// Clear the user profile cache to force refresh
  void clearUserProfileCache() {
    _userProfileCache.clear();
    if (kDebugMode) print('User profile cache cleared');
  }

  /// Clear cache for a specific user
  void clearUserProfileCacheForUser(String userId) {
    _userProfileCache.remove(userId);
    if (kDebugMode) print('User profile cache cleared for: $userId');
  }

  /// Force refresh user profile for current user (for testing)
  Future<UserProfile?> refreshCurrentUserProfile() async {
    if (currentUser == null) return null;

    clearUserProfileCacheForUser(currentUser!.uid);
    return await getUserProfile(currentUser!.uid);
  }

  // Get user profile from users collection with caching
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      // Check cache first
      if (_userProfileCache.containsKey(userId)) {
        if (kDebugMode) print('Using cached profile for: $userId');
        return _userProfileCache[userId];
      }

      if (kDebugMode) print('Getting user profile for: $userId');

      UserProfile? profile;

      // First, check users collection (for buyers)
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (kDebugMode) print('User profile data from users collection: $data');

        // Create profile from user data
        profile = UserProfile(
          id: userId,
          name:
              data['displayName'] ??
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
          imageUrl: data['profileImageUrl'],
          role: UserRole.buyer,
          isOnline: data['isOnline'] ?? false,
          lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
        );
      } else {
        // If not found in users, check sellers collection
        if (kDebugMode)
          print('User not found in users collection, checking sellers...');

        DocumentSnapshot sellerDoc = await _firestore
            .collection('sellers')
            .doc(userId)
            .get();

        if (sellerDoc.exists && sellerDoc.data() != null) {
          Map<String, dynamic> data = sellerDoc.data() as Map<String, dynamic>;
          if (kDebugMode)
            print('User profile data from sellers collection: $data');

          // Create profile from seller data
          profile = UserProfile(
            id: userId,
            name: data['name'] ?? 'Seller',
            imageUrl: data['profileImageUrl'],
            role: UserRole.seller,
            isOnline: data['isOnline'] ?? false,
            lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
          );
        } else {
          if (kDebugMode)
            print(
              'User profile not found in either collection, creating minimal profile',
            );

          // Fallback: create minimal profile
          profile = UserProfile(
            id: userId,
            name: 'User $userId',
            role: UserRole.buyer, // Default role
          );
        }
      }

      // Cache the profile
      _userProfileCache[userId] = profile;

      return profile;
    } catch (e) {
      if (kDebugMode) print('Error getting user profile: $e');
      UserProfile fallbackProfile = UserProfile(
        id: userId,
        name: 'Unknown User',
        role: UserRole.buyer, // Default role
      );
      _userProfileCache[userId] = fallbackProfile;
      return fallbackProfile;
    }
  }

  Future<bool> chatRoomExists(String chatRoomId) async {
    final doc = await _firestore.collection('chatsRooms').doc(chatRoomId).get();
    return doc.exists;
  }

  // Generate consistent chat room ID
  String _generateChatRoomId(
    String sellerId,
    String buyerId,
    String productId,
  ) {
    if (sellerId.isEmpty || buyerId.isEmpty || productId.isEmpty) {
      throw Exception('Invalid parameters for chat room ID generation');
    }
    if (sellerId == buyerId) {
      throw Exception('Seller and buyer cannot be the same person');
    }

    List<String> participants = [sellerId, buyerId];
    participants.sort(); // Ensure consistent ordering
    return '${participants[0]}_${participants[1]}_$productId';
  }

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
      if (kDebugMode) print('=== CREATING/GETTING CHAT ROOM ===');
      if (sellerId.isEmpty || buyerId.isEmpty || productId.isEmpty) {
        throw Exception('Missing required parameters for chat room creation');
      }
      if (sellerId == buyerId) {
        throw Exception(
          'Cannot create chat room: seller and buyer cannot be the same person',
        );
      }

      // Additional validation to ensure current user is not chatting with themselves
      if (currentUser != null &&
          ((currentUser!.uid == sellerId && currentUser!.uid == buyerId) ||
              (sellerId == buyerId))) {
        throw Exception(
          'Cannot create chat room: You cannot start a chat with yourself',
        );
      }

      UserProfile? sellerProfile = await getUserProfile(sellerId);
      UserProfile? buyerProfile = await getUserProfile(buyerId);

      String finalSellerName = sellerProfile?.name ?? sellerName;
      String finalBuyerName = buyerProfile?.name ?? buyerName;

      // Ensure correct role assignment
      UserRole finalSellerRole = sellerProfile?.role ?? UserRole.seller;
      UserRole finalBuyerRole = buyerProfile?.role ?? UserRole.buyer;

      // Override roles to ensure seller is seller and buyer is buyer
      if (finalSellerRole == UserRole.buyer) {
        finalSellerRole = UserRole.seller; // Force seller role for seller
      }
      if (finalBuyerRole == UserRole.seller) {
        finalBuyerRole = UserRole.buyer; // Force buyer role for buyer
      }

      String chatRoomId = _generateChatRoomId(sellerId, buyerId, productId);
      if (kDebugMode) {
        print('Chat Room ID: $chatRoomId');
        print('Seller ID: $sellerId');
        print('Buyer ID: $buyerId');
        print('Product ID: $productId');
      }

      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();

      if (!chatRoomDoc.exists) {
        if (kDebugMode) print('Creating new chat room...');

        Map<String, dynamic> chatRoomData = {
          'id': chatRoomId,
          'sellerId': sellerId,
          'buyerId': buyerId,
          'sellerName': finalSellerName,
          'buyerName': finalBuyerName,
          'sellerImageUrl': sellerImageUrl ?? sellerProfile?.imageUrl ?? '',
          'buyerImageUrl': buyerImageUrl ?? buyerProfile?.imageUrl ?? '',
          'sellerRole': finalSellerRole.name, // Use corrected role
          'buyerRole': finalBuyerRole.name, // Use corrected role
          'productId': productId,
          'productName': productName,
          'productImageUrl': productImageUrl,
          'productPrice': productPrice,
          'productDescription': productDescription,
          'lastMessage': '',
          'lastMessageTime': Timestamp.now(),
          'lastMessageSenderId': '',
          'lastMessageType': MessageType.text.name, // Storing enum name
          'unreadCountSeller': 0,
          'unreadCountBuyer': 0,
          'isActiveForSeller': true,
          'isActiveForBuyer': true,
          'status': ChatRoomStatus.active.name, // Storing enum name
          'participants': [sellerId, buyerId],
          'blockedBy': [],
          'isGroupChat': false,
          'createdAt': Timestamp.now(),
          'lastActivityTime': Timestamp.now(),
          'metadata': {
            'created_by': currentUser?.uid ?? 'system',
            'chat_type': 'product_inquiry',
            'version': '1.0',
          },
        };

        await _firestore
            .collection('chatsRooms')
            .doc(chatRoomId)
            .set(chatRoomData);

        // Verify the chat room was created successfully
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // Give Firestore time to propagate
        DocumentSnapshot verificationDoc = await _firestore
            .collection('chatsRooms')
            .doc(chatRoomId)
            .get();
        if (!verificationDoc.exists) {
          throw Exception('Failed to create chat room: verification failed');
        }

        if (kDebugMode) print('Chat room created successfully');
        await _sendWelcomeMessage(
          chatRoomId,
          productName,
          finalSellerName,
          finalBuyerName,
        );
      } else {
        if (kDebugMode) print('Chat room exists, updating...');
        await _firestore.collection('chatsRooms').doc(chatRoomId).update({
          'participants': [sellerId, buyerId],
          'lastActivityTime': Timestamp.now(),
          'isActiveForSeller': true,
          'isActiveForBuyer': true,
          'sellerName': finalSellerName,
          'buyerName': finalBuyerName,
        });
      }
      return chatRoomId;
    } catch (e) {
      if (kDebugMode) print('ERROR in createOrGetChatRoom: $e');
      throw Exception('Failed to create/get chat room: $e');
    }
  }

  Future<void> _sendWelcomeMessage(
    String chatRoomId,
    String productName,
    String sellerName,
    String buyerName,
  ) async {
    try {
      final messagesCollection = _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .collection('messages');
      String messageId = messagesCollection.doc().id;

      final welcomeMessage = Message(
        id: messageId,
        senderId: 'system',
        senderName: 'Kampusmart',
        message:
            'Chat started! $buyerName and $sellerName are now connected to discuss "$productName".',
        timestamp: Timestamp.now(),
        messageType: MessageType.system,
        isRead: false,
        deliveryStatus: DeliveryStatus.delivered,
        metadata: {
          'message_type': 'welcome',
          'product_name': productName,
          'seller_name': sellerName,
          'buyer_name': buyerName,
        },
      );
      await messagesCollection.doc(messageId).set(welcomeMessage.toMap());
      if (kDebugMode) print('Welcome message sent');
    } catch (e) {
      if (kDebugMode) print('Error sending welcome message: $e');
    }
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    MessageType messageType = MessageType.text,
    String? imageUrl,
    String? voiceUrl,
    String? fileName,
    String? fileUrl,
    Map<String, dynamic>? metadata,
    String? receiverId,
  }) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');
      if (chatRoomId.isEmpty) throw Exception('Chat room ID cannot be empty');
      if (message.trim().isEmpty && messageType == MessageType.text) {
        throw Exception('Message cannot be empty');
      }

      if (kDebugMode) {
        print('=== SENDING MESSAGE ===');
        print('Chat Room ID: $chatRoomId');
        print('Message: $message');
        print('Current User: ${currentUser!.uid}');
      }

      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();

      // Improved retry logic with more attempts and longer delays
      int retryCount = 0;
      const maxRetries = 5;
      while (!chatRoomDoc.exists && retryCount < maxRetries) {
        if (kDebugMode) {
          print(
            'DEBUG: Chat room does not exist yet, waiting... (attempt ${retryCount + 1}/$maxRetries)',
          );
        }
        await Future.delayed(
          Duration(seconds: 2 + retryCount),
        ); // Exponential backoff
        chatRoomDoc = await _firestore
            .collection('chatsRooms')
            .doc(chatRoomId)
            .get();
        retryCount++;
      }

      if (!chatRoomDoc.exists) {
        throw Exception(
          'Chat room does not exist and could not be found after $maxRetries retries: $chatRoomId',
        );
      }
      if (kDebugMode) print('Chat room verified, proceeding with message send');

      UserProfile? senderProfile = await getUserProfile(currentUser!.uid);
      String senderName = senderProfile?.name ?? 'Unknown User';

      // Determine receiverId if not provided
      if (receiverId == null) {
        Map<String, dynamic> chatRoomData =
            chatRoomDoc.data() as Map<String, dynamic>;
        receiverId = currentUser!.uid == chatRoomData['sellerId']
            ? chatRoomData['buyerId']
            : chatRoomData['sellerId'];
      }

      final messagesCollection = _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .collection('messages');
      String messageId = messagesCollection.doc().id;

      final chatMessage = Message(
        id: messageId,
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

      await messagesCollection.doc(messageId).set(chatMessage.toMap());
      if (kDebugMode) print('Message saved to Firestore');

      await _updateChatRoomLastMessage(chatRoomId, chatMessage);

      if (receiverId != null) {
        await _sendNotificationToParticipant(chatRoomId, chatMessage);
      }

      await _updateMessageDeliveryStatus(
        chatRoomId,
        messageId,
        DeliveryStatus.delivered,
      );
    } catch (e) {
      if (kDebugMode) print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> _updateChatRoomLastMessage(
    String chatRoomId,
    Message message,
  ) async {
    try {
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData =
            chatRoomDoc.data() as Map<String, dynamic>;

        Map<String, dynamic> updateData = {
          'lastMessage': message.message,
          'lastMessageTime': message.timestamp,
          'lastMessageSenderId': message.senderId,
          'lastMessageType': message.messageType.name, // Storing enum name
        };

        if (message.senderId == chatRoomData['sellerId']) {
          updateData['unreadCountBuyer'] =
              (chatRoomData['unreadCountBuyer'] ?? 0) + 1;
        } else {
          updateData['unreadCountSeller'] =
              (chatRoomData['unreadCountSeller'] ?? 0) + 1;
        }

        await _firestore
            .collection('chatsRooms')
            .doc(chatRoomId)
            .update(updateData);
      }
    } catch (e) {
      if (kDebugMode) print('Error updating chat room last message: $e');
    }
  }

  Future<void> _sendNotificationToParticipant(
    String chatRoomId,
    Message message,
  ) async {
    try {
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData =
            chatRoomDoc.data() as Map<String, dynamic>;

        String recipientId = message.senderId == chatRoomData['sellerId']
            ? chatRoomData['buyerId']
            : chatRoomData['sellerId'];

        UserRole recipientRole = recipientId == chatRoomData['sellerId']
            ? UserRole.seller
            : UserRole.buyer;

        await NotificationService.sendChatNotification(
          recipientId: recipientId,
          senderName: message.senderName,
          message: message.message,
          chatRoomId: chatRoomId,
          productName: chatRoomData['productName'],
          recipientRole: recipientRole,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Error sending notification: $e');
    }
  }

  Future<void> _updateMessageDeliveryStatus(
    String chatRoomId,
    String messageId,
    DeliveryStatus status,
  ) async {
    try {
      await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
            'deliveryStatus': status.name, // Storing enum name
            'deliveredAt': status == DeliveryStatus.delivered
                ? Timestamp.now()
                : null,
          });
    } catch (e) {
      if (kDebugMode) print('Error updating message delivery status: $e');
    }
  }

  Future<List<String>> uploadImages(
    List<XFile> images,
    String chatRoomId,
  ) async {
    try {
      List<String> imageUrls = [];
      for (int i = 0; i < images.length; i++) {
        String fileName =
            'chat-images/${chatRoomId}/${DateTime.now().millisecondsSinceEpoch}_$i';
        String imageUrl = await _uploadFileToStorage(images[i], fileName);
        imageUrls.add(imageUrl);
      }
      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  Future<void> sendImageMessage({
    required String chatRoomId,
    required XFile imageFile,
    String? caption,
    String? receiverId,
  }) async {
    try {
      if (kDebugMode) print('Sending image message with optimistic UI...');

      // Verify authentication before attempting upload
      if (currentUser == null) {
        throw Exception('User must be authenticated to send images');
      }

      if (kDebugMode) {
        print('User authenticated: ${currentUser!.uid}');
        print('Chat room: $chatRoomId');
      }

      // Read image bytes for immediate display
      final imageBytes = await imageFile.readAsBytes();

      // Generate a temporary message ID for optimistic UI
      final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create and send message immediately with placeholder
      await sendMessageOptimistic(
        chatRoomId: chatRoomId,
        content: caption ?? 'Photo',
        messageType: MessageType.image,
        imageBytes: imageBytes,
        fileName: imageFile.name,
        receiverId: receiverId,
        tempMessageId: tempMessageId,
      );

      if (kDebugMode) print('Image message sent with optimistic UI');
    } catch (e) {
      if (kDebugMode) print('Error sending image message: $e');
      throw Exception('Failed to send image message: $e');
    }
  }

  // New optimistic UI method for fast message display
  Future<void> sendMessageOptimistic({
    required String chatRoomId,
    required String content,
    MessageType messageType = MessageType.text,
    Uint8List? imageBytes,
    String? fileName,
    String? receiverId,
    String? tempMessageId,
  }) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');
      if (chatRoomId.isEmpty) throw Exception('Chat room ID cannot be empty');

      if (kDebugMode) {
        print('=== SENDING MESSAGE WITH OPTIMISTIC UI ===');
        print('Chat Room ID: $chatRoomId');
        print('Content: $content');
        print('Message Type: ${messageType.name}');
        print('Current User: ${currentUser!.uid}');
      }

      // Get user profile (consider caching for performance)
      UserProfile? senderProfile = await getUserProfile(currentUser!.uid);
      String senderName = senderProfile?.name ?? 'Unknown User';

      final messagesCollection = _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .collection('messages');
      String messageId = tempMessageId ?? messagesCollection.doc().id;

      // Create message with local image data for immediate display
      final chatMessage = Message(
        id: messageId,
        senderId: currentUser!.uid,
        senderName: senderName,
        message: content,
        timestamp: Timestamp.now(),
        messageType: messageType,
        isRead: false,
        deliveryStatus: DeliveryStatus.sent, // Show as sent initially
        imageUrl: null, // Will be updated after upload
        metadata: {
          'upload_timestamp': DateTime.now().toIso8601String(),
          if (fileName != null) 'original_filename': fileName,
          'optimistic_ui': 'true',
          if (imageBytes != null) 'local_image_data': 'true',
        },
      );

      // Save message immediately for fast UI response
      await messagesCollection.doc(messageId).set(chatMessage.toMap());
      if (kDebugMode) print('Message saved to Firestore for immediate display');

      // Handle image upload asynchronously if needed
      if (messageType == MessageType.image && imageBytes != null) {
        // Don't await this - let it run in background
        _uploadImageAsync(
          chatRoomId,
          messageId,
          imageBytes,
          fileName ?? 'image.jpg',
        );
      } else {
        // For non-image messages, update status immediately
        await _updateMessageDeliveryStatus(
          chatRoomId,
          messageId,
          DeliveryStatus.delivered,
        );
      }

      // Update chat room last message (don't await to keep it fast)
      _updateChatRoomLastMessageAsync(chatRoomId, chatMessage);

      // Send notification asynchronously
      if (receiverId != null) {
        _sendNotificationAsync(chatRoomId, chatMessage);
      }
    } catch (e) {
      if (kDebugMode) print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Async helper for non-blocking operations
  Future<void> _uploadImageAsync(
    String chatRoomId,
    String messageId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      if (kDebugMode) print('Starting background image upload...');

      String imageUrl = await _uploadBytesToStorage(imageBytes, fileName);
      if (kDebugMode) print('Image uploaded successfully: $imageUrl');

      // Update the message with the image URL
      await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
            'imageUrl': imageUrl,
            'deliveryStatus': DeliveryStatus.delivered.name,
            'uploadedAt': Timestamp.now(),
          });

      if (kDebugMode) print('Message updated with image URL');
    } catch (e) {
      if (kDebugMode) print('Error in background image upload: $e');

      // Update message to show upload failed
      await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
            'deliveryStatus': DeliveryStatus.failed.name,
            'uploadError': e.toString(),
            'failedAt': Timestamp.now(),
          });
    }
  }

  // Non-blocking chat room update
  void _updateChatRoomLastMessageAsync(String chatRoomId, Message message) {
    _updateChatRoomLastMessage(chatRoomId, message).catchError((error) {
      if (kDebugMode) print('Background chat room update error: $error');
    });
  }

  // Non-blocking notification
  void _sendNotificationAsync(String chatRoomId, Message message) {
    _sendNotificationToParticipant(chatRoomId, message).catchError((error) {
      if (kDebugMode) print('Background notification error: $error');
    });
  }

  // Helper method to upload bytes directly
  Future<String> _uploadBytesToStorage(Uint8List bytes, String fileName) async {
    try {
      if (kDebugMode) print('Uploading image bytes to storage...');

      // Check if user is authenticated
      if (currentUser == null) {
        throw Exception('User must be authenticated to upload files');
      }

      if (bytes.length > _maxFileSize) {
        throw Exception(
          'File size too large. Maximum ${_maxFileSize / (1024 * 1024)}MB allowed.',
        );
      }

      // Use optimized upload strategy - try product_images first as it's most likely to work
      String uploadPath =
          'product_images/chat_${DateTime.now().millisecondsSinceEpoch}_$fileName';

      String? contentType = 'image/jpeg';
      String lowerFileName = fileName.toLowerCase();
      if (lowerFileName.endsWith('.png')) {
        contentType = 'image/png';
      } else if (lowerFileName.endsWith('.gif')) {
        contentType = 'image/gif';
      }

      if (kDebugMode) {
        print('Uploading to: $uploadPath');
        print('File size: ${bytes.length} bytes');
        print('Content type: $contentType');
      }

      Reference storageRef = _firebaseStorage.ref().child(uploadPath);

      TaskSnapshot uploadTask = await storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'uploadedBy': currentUser!.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalName': fileName,
            'chatContext': 'true',
          },
        ),
      );

      String downloadUrl = await uploadTask.ref.getDownloadURL();
      if (kDebugMode) print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image bytes: $e');
        if (e.toString().toLowerCase().contains('unauthorized')) {
          printStorageRulesGuidance();
        }
      }
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> _uploadFileToStorage(XFile file, String storagePath) async {
    try {
      if (kDebugMode) print('Uploading file to: $storagePath');

      // Check if user is authenticated
      if (currentUser == null) {
        throw Exception('User must be authenticated to upload files');
      }

      final bytes = await file.readAsBytes();
      if (bytes.length > _maxFileSize) {
        throw Exception(
          'File size too large. Maximum ${_maxFileSize / (1024 * 1024)}MB allowed.',
        );
      }

      // Try multiple upload strategies to handle different Firebase Storage rules
      List<String> uploadPaths = [
        // Strategy 1: Use the same path as product images (more likely to work)
        'product_images/chat_${DateTime.now().millisecondsSinceEpoch}_${file.name}',

        // Strategy 2: Original chat-specific path
        'chat_images/${currentUser!.uid}/$storagePath',

        // Strategy 3: Simple chat images path
        'chat_images/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      ];

      String? contentType = 'application/octet-stream';
      String fileName = file.name.toLowerCase();

      if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (fileName.endsWith('.png')) {
        contentType = 'image/png';
      } else if (fileName.endsWith('.gif')) {
        contentType = 'image/gif';
      } else if (fileName.endsWith('.mp4')) {
        contentType = 'video/mp4';
      } else if (fileName.endsWith('.pdf')) {
        contentType = 'application/pdf';
      }

      Exception? lastError;

      // Try each upload path until one succeeds
      for (int i = 0; i < uploadPaths.length; i++) {
        try {
          String currentPath = uploadPaths[i];
          if (kDebugMode) {
            print('Attempt ${i + 1}: Uploading to $currentPath');
            print('Authenticated user: ${currentUser!.uid}');
            print('File size: ${bytes.length} bytes');
            print('Content type: $contentType');
          }

          Reference storageRef = _firebaseStorage.ref().child(currentPath);

          TaskSnapshot uploadTask = await storageRef.putData(
            bytes,
            SettableMetadata(
              contentType: contentType,
              customMetadata: {
                'uploadedBy': currentUser!.uid,
                'uploadedAt': DateTime.now().toIso8601String(),
                'originalName': file.name,
                'chatContext': 'true',
                'uploadStrategy': (i + 1).toString(),
              },
            ),
          );

          String downloadUrl = await uploadTask.ref.getDownloadURL();
          if (kDebugMode)
            print(
              'File uploaded successfully using strategy ${i + 1}: $downloadUrl',
            );
          return downloadUrl;
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          if (kDebugMode) {
            print('Upload attempt ${i + 1} failed: $e');

            // Print storage rules guidance if this is an authorization error
            if (e.toString().toLowerCase().contains('unauthorized') ||
                e.toString().toLowerCase().contains('permission')) {
              printStorageRulesGuidance();
            }
          } // If this is the last attempt, we'll throw the error
          if (i == uploadPaths.length - 1) {
            break;
          }

          // Wait a bit before trying the next strategy
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // If all strategies failed, throw the last error
      throw lastError ?? Exception('All upload strategies failed');
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
        print('Error type: ${e.runtimeType}');
        if (currentUser != null) {
          print('Current user ID: ${currentUser!.uid}');
          print('Current user email: ${currentUser!.email}');
        } else {
          print('No current user found');
        }
      }
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> sendImageMessageWithFile({
    required String chatRoomId,
    required XFile imageFile,
    String? caption,
    String? receiverId,
  }) async {
    try {
      String imageUrl = await _uploadFileToStorage(
        imageFile,
        'chat-images/${chatRoomId}/${DateTime.now().millisecondsSinceEpoch}',
      );
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

  Future<void> sendMultipleImages({
    required String chatRoomId,
    required List<XFile> images,
    String? caption,
    String? receiverId,
  }) async {
    try {
      if (kDebugMode) print('Sending ${images.length} images...');
      for (int i = 0; i < images.length; i++) {
        String imageCaption = caption ?? 'Photo';
        if (images.length > 1) {
          imageCaption += ' (${i + 1}/${images.length})';
        }
        await sendImageMessageWithFile(
          chatRoomId: chatRoomId,
          imageFile: images[i],
          caption: imageCaption,
          receiverId: receiverId,
        );
        if (i < images.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      if (kDebugMode) print('All images sent successfully');
    } catch (e) {
      if (kDebugMode) print('Error sending multiple images: $e');
      throw Exception('Failed to send multiple images: $e');
    }
  }

  Future<void> sendVoiceMessage({
    required String chatRoomId,
    required String voiceFilePath,
    required int duration,
    String? receiverId,
  }) async {
    try {
      String voiceUrl = await _uploadFileToStorage(
        XFile(voiceFilePath),
        'voice_messages/${chatRoomId}/${DateTime.now().millisecondsSinceEpoch}',
      );
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

  Future<void> sendFileMessage({
    required String chatRoomId,
    required XFile file,
    String? caption,
    String? receiverId,
  }) async {
    try {
      String fileUrl = await _uploadFileToStorage(
        file,
        'chat-files/${chatRoomId}/${DateTime.now().millisecondsSinceEpoch}',
      );
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

  // Consolidated and optimized getMessages method
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    if (kDebugMode) print('Getting messages for chat room: $chatRoomId');

    return _firestore
        .collection('chatsRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limit(100) // Limit messages for performance
        .snapshots()
        .map((snapshot) {
          if (kDebugMode)
            print('Found ${snapshot.docs.length} messages in subcollection');

          List<ChatMessage> messages = [];
          for (var doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data();
              if (kDebugMode)
                print('Processing message: ${doc.id} - ${data['message']}');

              // Handle optimistic UI - show local image data if available
              String? displayImageUrl = data['imageUrl'];

              messages.add(
                ChatMessage(
                  id: doc.id,
                  senderId: data['senderId'] ?? '',
                  senderName: data['senderName'] ?? '',
                  message: data['message'] ?? '',
                  timestamp:
                      (data['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                  messageType: _parseMessageType(data['messageType']),
                  isRead: data['isRead'] ?? false,
                  imageUrl: displayImageUrl,
                  voiceUrl: data['voiceUrl'],
                  fileName: data['fileName'],
                  fileUrl: data['fileUrl'],
                ),
              );
            } catch (e) {
              if (kDebugMode) print('Error processing message ${doc.id}: $e');
            }
          }

          return messages;
        })
        .handleError((error) {
          if (kDebugMode) print('Stream error: $error');
          return <ChatMessage>[];
        });
  }

  MessageType _parseMessageType(dynamic messageType) {
    if (messageType == null) return MessageType.text;
    if (messageType is String) {
      for (var type in MessageType.values) {
        if (type.name == messageType) {
          return type;
        }
      }
    }
    return MessageType.text;
  }

  Stream<List<ChatRoom>> getChatRoomsStream() {
    if (currentUser == null) {
      if (kDebugMode) print('DEBUG: No current user found');
      return Stream.value([]);
    }
    if (kDebugMode) {
      print('DEBUG: Getting chat rooms for user: ${currentUser!.uid}');
      // Run cleanup in debug mode
      cleanupInvalidChatRooms();
    }
    return _firestore
        .collection('chatsRooms')
        .where('participants', arrayContains: currentUser!.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          if (kDebugMode)
            print('DEBUG: Found ${snapshot.docs.length} chat rooms');
          return snapshot.docs
              .map((doc) {
                try {
                  Map<String, dynamic> data = doc.data();
                  if (kDebugMode) {
                    print('DEBUG: Processing chat room: ${doc.id}');
                    print('DEBUG: Chat room data: $data');
                  }

                  // Skip invalid chat rooms where buyer and seller are the same
                  if (data['sellerId'] == data['buyerId']) {
                    if (kDebugMode) {
                      print(
                        'DEBUG: Skipping invalid chat room where buyer and seller are the same: ${doc.id}',
                      );
                    }
                    return null;
                  }

                  return ChatRoom.fromMap(data);
                } catch (e) {
                  if (kDebugMode)
                    print('DEBUG: Error processing chat room ${doc.id}: $e');
                  return null;
                }
              })
              .where((chatRoom) => chatRoom != null)
              .cast<ChatRoom>()
              .toList();
        })
        .handleError((error) {
          if (kDebugMode) print('DEBUG: Stream error: $error');
          return <ChatRoom>[];
        });
  }

  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot unreadMessages = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUser!.uid)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.now(),
        });
      }
      await batch.commit();

      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData =
            chatRoomDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> updateData = {};
        if (currentUser!.uid == chatRoomData['sellerId']) {
          updateData['unreadCountBuyer'] = 0;
        } else {
          updateData['unreadCountSeller'] = 0;
        }
        await _firestore
            .collection('chatsRooms')
            .doc(chatRoomId)
            .update(updateData);
      }
    } catch (e) {
      if (kDebugMode) print('Error marking messages as read: $e');
    }
  }

  Future<int> getUnreadMessagesCount() async {
    try {
      if (currentUser == null) return 0;
      QuerySnapshot chatsRooms = await _firestore
          .collection('chatsRooms')
          .where('participants', arrayContains: currentUser!.uid)
          .get();

      int totalUnread = 0;
      for (QueryDocumentSnapshot doc in chatsRooms.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (currentUser!.uid == data['sellerId']) {
          totalUnread += (data['unreadCountSeller'] ?? 0) as int;
        } else {
          totalUnread += (data['unreadCountBuyer'] ?? 0) as int;
        }
      }
      return totalUnread;
    } catch (e) {
      if (kDebugMode) print('Error getting unread messages count: $e');
      return 0;
    }
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');

      QuerySnapshot messages = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();
      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await _firestore.collection('chatsRooms').doc(chatRoomId).delete();
    } catch (e) {
      throw Exception('Failed to delete chat room: $e');
    }
  }

  Future<void> blockUser(String chatRoomId, String userId) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');
      await _firestore.collection('chatsRooms').doc(chatRoomId).update({
        'blockedBy': FieldValue.arrayUnion([currentUser!.uid]),
        'status': ChatRoomStatus.blocked.name,
      });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  Future<void> unblockUser(String chatRoomId, String userId) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');
      await _firestore.collection('chatsRooms').doc(chatRoomId).update({
        'blockedBy': FieldValue.arrayRemove([currentUser!.uid]),
        'status': ChatRoomStatus.active.name,
      });
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  Future<bool> isUserBlocked(String chatRoomId, String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> blockedBy = data['blockedBy'] ?? [];
        return blockedBy.contains(userId);
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Error checking if user is blocked: $e');
      return false;
    }
  }

  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      if (doc.exists) {
        return ChatRoom.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting chat room: $e');
      return null;
    }
  }

  Future<void> archiveChatRoom(String chatRoomId) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData =
            chatRoomDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> updateData = {};
        if (currentUser!.uid == chatRoomData['sellerId']) {
          updateData['isActiveForSeller'] = false;
        } else {
          updateData['isActiveForBuyer'] = false;
        }
        await _firestore
            .collection('chatsRooms')
            .doc(chatRoomId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to archive chat room: $e');
    }
  }

  Future<void> unarchiveChatRoom(String chatRoomId) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData =
            chatRoomDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> updateData = {};
        if (currentUser!.uid == chatRoomData['sellerId']) {
          updateData['isActiveForSeller'] = true;
        } else {
          updateData['isActiveForBuyer'] = true;
        }
        await _firestore
            .collection('chatsRooms')
            .doc(chatRoomId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to unarchive chat room: $e');
    }
  }

  Future<String?> getOtherParticipantName(String chatRoomId) async {
    try {
      if (currentUser == null) return null;
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      if (chatRoomDoc.exists) {
        Map<String, dynamic> data = chatRoomDoc.data() as Map<String, dynamic>;
        return currentUser!.uid == data['sellerId']
            ? data['buyerName'] as String?
            : data['sellerName'] as String?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting other participant name: $e');
      return null;
    }
  }

  Future<int> getUnreadCount(String chatRoomId) async {
    try {
      if (currentUser == null) return 0;
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      if (chatRoomDoc.exists) {
        Map<String, dynamic> data = chatRoomDoc.data() as Map<String, dynamic>;
        return currentUser!.uid == data['sellerId']
            ? (data['unreadCountSeller'] ?? 0) as int
            : (data['unreadCountBuyer'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      if (kDebugMode) print('Error getting unread count: $e');
      return 0;
    }
  }

  bool isCurrentUser(String userId) {
    return currentUser?.uid == userId;
  }

  static String getFormattedTime(Timestamp timestamp) {
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

  Future<Map<String, dynamic>?> getOtherParticipantDetails(
    String chatRoomId,
    String currentUserId,
  ) async {
    try {
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      if (chatRoomDoc.exists) {
        Map<String, dynamic> data = chatRoomDoc.data() as Map<String, dynamic>;
        bool isSeller = currentUserId == data['sellerId'];
        return {
          'id': isSeller ? data['buyerId'] : data['sellerId'],
          'name': isSeller ? data['buyerName'] : data['sellerName'],
          'imageUrl': isSeller ? data['buyerImageUrl'] : data['sellerImageUrl'],
          'isSeller': !isSeller,
          'currentUserIsSeller': isSeller,
        };
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting other participant details: $e');
      return null;
    }
  }

  Future<bool> isCurrentUserSeller(String userId) async {
    try {
      UserProfile? userProfile = await getUserProfile(userId);
      return userProfile?.role == UserRole.seller;
    } catch (e) {
      if (kDebugMode) print('Error checking user role: $e');
      return false;
    }
  }

  // --- Debugging Methods (Guarded by kDebugMode) ---
  Future<void> debugChatRoomCreation({
    required String sellerId,
    required String buyerId,
    required String productId,
  }) async {
    if (!kDebugMode) return;
    String chatRoomId = _generateChatRoomId(sellerId, buyerId, productId);
    print('=== CHAT ROOM DEBUG ===');
    print('Generated Chat Room ID: $chatRoomId');
    print('Seller ID: $sellerId');
    print('Buyer ID: $buyerId');
    print('Product ID: $productId');
    print('Current User ID: ${currentUser?.uid}');
    try {
      DocumentSnapshot doc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      print('Chat room exists: ${doc.exists}');
      if (doc.exists) {
        print('Chat room data: ${doc.data()}');
      }
    } catch (e) {
      print('Error checking chat room: $e');
    }
    print('=== END DEBUG ===');
  }

  Future<void> debugMessageSending({
    required String chatRoomId,
    required String message,
    String? receiverId,
  }) async {
    if (!kDebugMode) return;
    print('=== MESSAGE SENDING DEBUG ===');
    print('Chat Room ID: $chatRoomId');
    print('Message: $message');
    print('Receiver ID: $receiverId');
    print('Current User ID: ${currentUser?.uid}');
    try {
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      print('Chat room exists: ${chatRoomDoc.exists}');
      if (chatRoomDoc.exists) {
        Map<String, dynamic> chatRoomData =
            chatRoomDoc.data() as Map<String, dynamic>;
        print('Chat room participants: ${chatRoomData['participants']}');
        print('Seller ID: ${chatRoomData['sellerId']}');
        print('Buyer ID: ${chatRoomData['buyerId']}');
        List<dynamic> participants = chatRoomData['participants'] ?? [];
        bool isParticipant = participants.contains(currentUser?.uid);
        print('Current user is participant: $isParticipant');
        String determinedReceiverId =
            currentUser!.uid == chatRoomData['sellerId']
            ? chatRoomData['buyerId']
            : chatRoomData['sellerId'];
        print('Determined receiver ID: $determinedReceiverId');
      }
      QuerySnapshot messagesSnapshot = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();
      print('Recent messages count: ${messagesSnapshot.docs.length}');
      for (var doc in messagesSnapshot.docs) {
        Map<String, dynamic> messageData = doc.data() as Map<String, dynamic>;
        print(
          'Message: ${messageData['message']} from ${messageData['senderId']}',
        );
      }
    } catch (e) {
      print('Error in debug: $e');
    }
    print('=== END MESSAGE DEBUG ===');
  }

  Future<void> debugUserPermissions() async {
    if (!kDebugMode) return;
    print('=== USER PERMISSIONS DEBUG ===');
    print('Current User: ${currentUser?.uid}');
    print('Current User Email: ${currentUser?.email}');
    if (currentUser != null) {
      try {
        UserProfile? profile = await getUserProfile(currentUser!.uid);
        print('User Profile: ${profile?.toMap()}');
      } catch (e) {
        print('Error getting user profile: $e');
      }
    }
    print('=== END USER PERMISSIONS DEBUG ===');
  }

  Future<void> debugFirestoreConnection() async {
    if (!kDebugMode) return;
    print('=== FIRESTORE CONNECTION DEBUG ===');
    print('Current User: ${currentUser?.uid}');
    print('Current User Email: ${currentUser?.email}');
    if (currentUser == null) {
      print('ERROR: No authenticated user');
      return;
    }
    try {
      print('Testing Firestore read access...');
      QuerySnapshot testQuery = await _firestore
          .collection('chatsRooms')
          .limit(1)
          .get();
      print(
        'Firestore read successful. Documents found: ${testQuery.docs.length}',
      );
      print('Testing user-specific query...');
      QuerySnapshot userQuery = await _firestore
          .collection('chatsRooms')
          .where('participants', arrayContains: currentUser!.uid)
          .limit(5)
          .get();
      print(
        'User-specific query successful. Documents found: ${userQuery.docs.length}',
      );
      for (var doc in userQuery.docs) {
        print('Found chat room: ${doc.id}');
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('  Participants: ${data['participants']}');
        print('  Seller ID: ${data['sellerId']}');
        print('  Buyer ID: ${data['buyerId']}');
        print('  Product: ${data['productName']}');

        // Check for invalid chat rooms (same buyer and seller)
        if (data['sellerId'] == data['buyerId']) {
          print(
            '  ⚠️  WARNING: Invalid chat room detected - same buyer and seller!',
          );
        }
      }
    } catch (e) {
      print('ERROR in Firestore connection: $e');
      print('Error type: ${e.runtimeType}');
    }
    print('=== END FIRESTORE DEBUG ===');
  }

  // Helper method to provide Firebase Storage rules guidance
  void printStorageRulesGuidance() {
    if (!kDebugMode) return;
    print('=== FIREBASE STORAGE RULES GUIDANCE ===');
    print(
      'If you\'re getting authorization errors, ensure your Firebase Storage rules allow authenticated users to upload:',
    );
    print('');
    print('rules_version = \'2\';');
    print('service firebase.storage {');
    print('  match /b/{bucket}/o {');
    print(
      '    // Allow authenticated users to upload to product_images and chat_images',
    );
    print('    match /product_images/{allPaths=**} {');
    print('      allow read, write: if request.auth != null;');
    print('    }');
    print('    match /chat_images/{allPaths=**} {');
    print('      allow read, write: if request.auth != null;');
    print('    }');
    print('    // Default rule for other paths');
    print('    match /{allPaths=**} {');
    print('      allow read, write: if request.auth != null;');
    print('    }');
    print('  }');
    print('}');
    print('=== END STORAGE RULES GUIDANCE ===');
  }

  Future<bool> testStoragePermissions() async {
    if (currentUser == null) {
      if (kDebugMode) print('No authenticated user for storage test');
      return false;
    }

    try {
      if (kDebugMode) print('Testing Firebase Storage permissions...');

      // Create a small test file
      final testData = Uint8List.fromList('test'.codeUnits);

      // Try uploading to the product_images path (most likely to work)
      final testPath =
          'product_images/test_${DateTime.now().millisecondsSinceEpoch}.txt';
      final storageRef = _firebaseStorage.ref().child(testPath);

      final uploadTask = await storageRef.putData(
        testData,
        SettableMetadata(
          contentType: 'text/plain',
          customMetadata: {
            'uploadedBy': currentUser!.uid,
            'testUpload': 'true',
          },
        ),
      );

      // Get download URL to confirm upload succeeded
      await uploadTask.ref.getDownloadURL();

      // Clean up test file
      try {
        await storageRef.delete();
      } catch (e) {
        // Ignore delete errors
      }

      if (kDebugMode) print('Storage permissions test PASSED');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Storage permissions test FAILED: $e');
        if (e.toString().toLowerCase().contains('unauthorized')) {
          printStorageRulesGuidance();
        }
      }
      return false;
    }
  }

  Future<void> cleanupInvalidChatRooms() async {
    if (!kDebugMode) return;
    print('=== CLEANING UP INVALID CHAT ROOMS ===');
    try {
      QuerySnapshot invalidChats = await _firestore
          .collection('chatsRooms')
          .get();

      List<String> toDelete = [];
      for (var doc in invalidChats.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['sellerId'] == data['buyerId']) {
          print('Found invalid chat room: ${doc.id}');
          print('  Seller ID: ${data['sellerId']}');
          print('  Buyer ID: ${data['buyerId']}');
          toDelete.add(doc.id);
        }
      }

      if (toDelete.isNotEmpty) {
        print('Deleting ${toDelete.length} invalid chat rooms...');
        WriteBatch batch = _firestore.batch();
        for (String chatRoomId in toDelete) {
          batch.delete(_firestore.collection('chatsRooms').doc(chatRoomId));
        }
        await batch.commit();
        print('Invalid chat rooms deleted successfully');
      } else {
        print('No invalid chat rooms found');
      }
    } catch (e) {
      print('Error cleaning up invalid chat rooms: $e');
    }
    print('=== END CLEANUP ===');
  }

  Future<void> debugChatRoomStructure(String chatRoomId) async {
    if (!kDebugMode) return;
    print('=== CHAT ROOM STRUCTURE DEBUG ===');
    print('Checking chat room: $chatRoomId');
    try {
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .get();
      print('Chat room exists: ${chatRoomDoc.exists}');
      if (chatRoomDoc.exists) {
        print('Chat room data: ${chatRoomDoc.data()}');
      }
      QuerySnapshot messagesSnapshot = await _firestore
          .collection('chatsRooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();
      print('Messages in subcollection: ${messagesSnapshot.docs.length}');
      for (var doc in messagesSnapshot.docs) {
        print('Message: ${doc.id} - ${doc.data()}');
      }
      QuerySnapshot rootMessages = await _firestore
          .collection('messages')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .get();
      print('Messages in root collection: ${rootMessages.docs.length}');
      for (var doc in rootMessages.docs) {
        print('Root message: ${doc.id} - ${doc.data()}');
      }
    } catch (e) {
      print('Error in structure debug: $e');
    }
    print('=== END STRUCTURE DEBUG ===');
  }

  Future<void> fixMessageStructure() async {
    if (!kDebugMode) return;
    print('=== FIXING MESSAGE STRUCTURE ===');
    try {
      QuerySnapshot rootMessages = await _firestore
          .collection('messages')
          .get();
      print('Found ${rootMessages.docs.length} messages in root collection');
      WriteBatch batch = _firestore.batch(); // Use batch for efficiency

      for (QueryDocumentSnapshot messageDoc in rootMessages.docs) {
        Map<String, dynamic> messageData =
            messageDoc.data() as Map<String, dynamic>;
        String? chatRoomId = messageData['chatRoomId'];
        if (chatRoomId != null) {
          print('Moving message ${messageDoc.id} to chat room $chatRoomId');
          batch.set(
            _firestore
                .collection('chatsRooms')
                .doc(chatRoomId)
                .collection('messages')
                .doc(messageDoc.id),
            messageData,
          );
          batch.delete(messageDoc.reference);
        }
      }
      await batch.commit();
      print('Message structure fix completed');
    } catch (e) {
      print('Error fixing message structure: $e');
    }
    print('=== END STRUCTURE FIX ===');
  }
}
