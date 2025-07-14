// chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create or get existing chat room
  Future<String> createOrGetChatRoom({
    required String sellerId,
    required String buyerId,
    required String productId,
    required String productName,
    required String sellerName,
    required String buyerName,
  }) async {
    try {
      // Create chat room ID (consistent for same participants)
      String chatRoomId = _generateChatRoomId(sellerId, buyerId, productId);
      
      // Check if chat room already exists
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (!chatRoomDoc.exists) {
        // Create new chat room
        ChatRoom newChatRoom = ChatRoom(
          id: chatRoomId,
          sellerId: sellerId,
          buyerId: buyerId,
          productId: productId,
          productName: productName,
          sellerName: sellerName,
          buyerName: buyerName,
          lastMessage: '',
          lastMessageTime: Timestamp.now(),
          unreadCountSeller: 0,
          unreadCountBuyer: 0,
          isActiveForSeller: true,
          isActiveForBuyer: true,
          createdAt: Timestamp.now(),
        );

        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .set(newChatRoom.toMap());
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

  // Send message
  Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    required String receiverId,
    String? imageUrl,
  }) async {
    try {
      if (currentUser == null) throw Exception('User not authenticated');

      String senderId = currentUser!.uid;
      Timestamp timestamp = Timestamp.now();

      // Create message
      Message newMessage = Message(
        id: '', // Will be auto-generated
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        imageUrl: imageUrl,
        timestamp: timestamp,
        isRead: false,
        messageType: imageUrl != null ? MessageType.image : MessageType.text,
      );

      // Add message to subcollection
      DocumentReference messageRef = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

      // Update message with generated ID
      await messageRef.update({'id': messageRef.id});

      // Update chat room with last message info
      await _updateChatRoomLastMessage(
        chatRoomId: chatRoomId,
        lastMessage: message,
        lastMessageTime: timestamp,
        senderId: senderId,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Update chat room last message and unread counts
  Future<void> _updateChatRoomLastMessage({
    required String chatRoomId,
    required String lastMessage,
    required Timestamp lastMessageTime,
    required String senderId,
  }) async {
    try {
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        Map<String, dynamic> data = chatRoomDoc.data() as Map<String, dynamic>;
        ChatRoom chatRoom = ChatRoom.fromMap(data);

        // Determine who should get the unread count increment
        Map<String, dynamic> updateData = {
          'lastMessage': lastMessage,
          'lastMessageTime': lastMessageTime,
        };

        if (senderId == chatRoom.sellerId) {
          // Seller sent message, increment buyer's unread count
          updateData['unreadCountBuyer'] = chatRoom.unreadCountBuyer + 1;
        } else {
          // Buyer sent message, increment seller's unread count
          updateData['unreadCountSeller'] = chatRoom.unreadCountSeller + 1;
        }

        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update chat room: $e');
    }
  }

  // Get messages stream
  Stream<List<Message>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Message.fromMap(data);
      }).toList();
    });
  }

  // Get chat rooms for current user
  Stream<List<ChatRoom>> getChatRooms() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    String userId = currentUser!.uid;
    
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
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
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      // Get unread messages for this user
      QuerySnapshot unreadMessages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      // Mark all unread messages as read
      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Reset unread count in chat room
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        Map<String, dynamic> data = chatRoomDoc.data() as Map<String, dynamic>;
        ChatRoom chatRoom = ChatRoom.fromMap(data);

        Map<String, dynamic> updateData = {};
        if (userId == chatRoom.sellerId) {
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
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // Delete chat room
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      // Delete all messages in the chat room
      QuerySnapshot messages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete the chat room
      await _firestore.collection('chatRooms').doc(chatRoomId).delete();
    } catch (e) {
      throw Exception('Failed to delete chat room: $e');
    }
  }

  // Search chat rooms
  Future<List<ChatRoom>> searchChatRooms(String query) async {
    try {
      if (currentUser == null) return [];

      String userId = currentUser!.uid;
      QuerySnapshot snapshot = await _firestore
          .collection('chatRooms')
          .where('participants', arrayContains: userId)
          .get();

      List<ChatRoom> allChatRooms = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ChatRoom.fromMap(data);
      }).toList();

      // Filter by search query
      return allChatRooms.where((chatRoom) {
        String searchTarget = userId == chatRoom.sellerId 
            ? chatRoom.buyerName.toLowerCase()
            : chatRoom.sellerName.toLowerCase();
        return searchTarget.contains(query.toLowerCase()) ||
               chatRoom.productName.toLowerCase().contains(query.toLowerCase()) ||
               chatRoom.lastMessage.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search chat rooms: $e');
    }
  }

  // Get unread message count for user
  Future<int> getUnreadMessageCount() async {
    try {
      if (currentUser == null) return 0;

      String userId = currentUser!.uid;
      QuerySnapshot snapshot = await _firestore
          .collection('chatRooms')
          .where('participants', arrayContains: userId)
          .get();

      int totalUnread = 0;
      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        ChatRoom chatRoom = ChatRoom.fromMap(data);
        
        if (userId == chatRoom.sellerId) {
          totalUnread += chatRoom.unreadCountSeller;
        } else {
          totalUnread += chatRoom.unreadCountBuyer;
        }
      }

      return totalUnread;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}