// models/chat_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  system,
}

enum UserType {
  seller,
  buyer,
}

class ChatRoom {
  final String id;
  final String sellerId;
  final String buyerId;
  final String productId;
  final String productName;
  final String sellerName;
  final String buyerName;
  final String lastMessage;
  final Timestamp lastMessageTime;
  final int unreadCountSeller;
  final int unreadCountBuyer;
  final bool isActiveForSeller;
  final bool isActiveForBuyer;
  final Timestamp createdAt;
  final List<String> participants;
  final String? productImageUrl;

  ChatRoom({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.productId,
    required this.productName,
    required this.sellerName,
    required this.buyerName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCountSeller,
    required this.unreadCountBuyer,
    required this.isActiveForSeller,
    required this.isActiveForBuyer,
    required this.createdAt,
    this.productImageUrl,
  }) : participants = [sellerId, buyerId];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'productId': productId,
      'productName': productName,
      'sellerName': sellerName,
      'buyerName': buyerName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCountSeller': unreadCountSeller,
      'unreadCountBuyer': unreadCountBuyer,
      'isActiveForSeller': isActiveForSeller,
      'isActiveForBuyer': isActiveForBuyer,
      'createdAt': createdAt,
      'participants': participants,
      'productImageUrl': productImageUrl,
    };
  }

  static ChatRoom fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      sellerName: map['sellerName'] ?? '',
      buyerName: map['buyerName'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? Timestamp.now(),
      unreadCountSeller: map['unreadCountSeller'] ?? 0,
      unreadCountBuyer: map['unreadCountBuyer'] ?? 0,
      isActiveForSeller: map['isActiveForSeller'] ?? true,
      isActiveForBuyer: map['isActiveForBuyer'] ?? true,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      productImageUrl: map['productImageUrl'],
    );
  }

  // Get the other participant's name based on current user
  String getOtherParticipantName(String currentUserId) {
    return currentUserId == sellerId ? buyerName : sellerName;
  }

  // Get the other participant's ID based on current user
  String getOtherParticipantId(String currentUserId) {
    return currentUserId == sellerId ? buyerId : sellerId;
  }

  // Get unread count for current user
  int getUnreadCount(String currentUserId) {
    return currentUserId == sellerId ? unreadCountSeller : unreadCountBuyer;
  }

  // Check if current user is seller
  bool isCurrentUserSeller(String currentUserId) {
    return currentUserId == sellerId;
  }

  // Get formatted time string
  String getFormattedTime() {
    DateTime dateTime = lastMessageTime.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String? imageUrl;
  final Timestamp timestamp;
  final bool isRead;
  final MessageType messageType;
  final String? replyToMessageId;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    required this.isRead,
    required this.messageType,
    this.replyToMessageId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'isRead': isRead,
      'messageType': messageType.toString().split('.').last,
      'replyToMessageId': replyToMessageId,
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'] ?? Timestamp.now(),
      isRead: map['isRead'] ?? false,
      messageType: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['messageType'],
        orElse: () => MessageType.text,
      ),
      replyToMessageId: map['replyToMessageId'],
    );
  }

  // Get formatted time string
  String getFormattedTime() {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted date string
  String getFormattedDate() {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Check if message is from current user
  bool isFromCurrentUser(String currentUserId) {
    return senderId == currentUserId;
  }
}

class ChatUser {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final bool isOnline;
  final Timestamp lastSeen;
  final UserType userType;
  final String? fcmToken; // For push notifications

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.isOnline,
    required this.lastSeen,
    required this.userType,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'userType': userType.toString().split('.').last,
      'fcmToken': fcmToken,
    };
  }

  static ChatUser fromMap(Map<String, dynamic> map) {
    return ChatUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] ?? Timestamp.now(),
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == map['userType'],
        orElse: () => UserType.buyer,
      ),
      fcmToken: map['fcmToken'],
    );
  }

  // Get last seen formatted string
  String getLastSeenFormatted() {
    if (isOnline) {
      return 'Online';
    }
    
    DateTime dateTime = lastSeen.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours}h ago';
    } else {
      return 'Last seen ${difference.inDays}d ago';
    }
  }
}