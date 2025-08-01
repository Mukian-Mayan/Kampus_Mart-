// chat_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kampusmart2/models/user_role.dart';

// Enums
enum MessageType { text, image, voice, file, system }

enum DeliveryStatus { sent, delivered, read, failed }

enum ChatRoomStatus { active, blocked, archived, deleted }

// ChatMessage model specifically for MessageScreen compatibility
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final MessageType messageType;
  final bool isRead;
  final String? imageUrl;
  final String? voiceUrl;
  final String? fileName;
  final String? fileUrl;
  final String? participants;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.messageType,
    required this.isRead,
    this.imageUrl,
    this.voiceUrl,
    this.fileName,
    this.fileUrl,
    this.participants,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'messageType': messageType.name, // Use .name instead of .toString()
      'isRead': isRead,
      'imageUrl': imageUrl,
      'voiceUrl': voiceUrl,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'participants': participants,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      messageType: _parseMessageType(map['messageType']),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
      voiceUrl: map['voiceUrl'],
      fileName: map['fileName'],
      fileUrl: map['fileUrl'],
      participants: map['participants'],
    );
  }

  static MessageType _parseMessageType(dynamic messageType) {
    if (messageType == null) return MessageType.text;

    if (messageType is String) {
      // Handle both enum.name format and toString() format for backward compatibility
      switch (messageType) {
        case 'text':
        case 'MessageType.text':
          return MessageType.text;
        case 'image':
        case 'MessageType.image':
          return MessageType.image;
        case 'voice':
        case 'MessageType.voice':
          return MessageType.voice;
        case 'file':
        case 'MessageType.file':
          return MessageType.file;
        case 'system':
        case 'MessageType.system':
          return MessageType.system;
        default:
          return MessageType.text;
      }
    }

    return MessageType.text;
  }
}

// UserProfile model
class UserProfile {
  final String id;
  final String name;
  final String? imageUrl;
  final UserRole role;
  final bool isOnline;
  final DateTime? lastSeen;

  UserProfile({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.role,
    this.isOnline = false,
    this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'role': role.name, // Use .name instead of .toString()
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      role: _parseUserRole(map['role']),
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  static UserRole _parseUserRole(dynamic role) {
    if (role == null) return UserRole.buyer;

    if (role is String) {
      // Handle both enum.name format and toString() format for backward compatibility
      switch (role) {
        case 'buyer':
        case 'UserRole.buyer':
          return UserRole.buyer;
        case 'seller':
        case 'UserRole.seller':
          return UserRole.seller;
        default:
          return UserRole.buyer;
      }
    }

    return UserRole.buyer;
  }
}

// Message model for detailed message handling
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final Timestamp timestamp;
  final MessageType messageType;
  final bool isRead;
  final DeliveryStatus deliveryStatus;
  final String? imageUrl;
  final String? voiceUrl;
  final String? fileName;
  final String? fileUrl;
  final Map<String, dynamic> metadata;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.messageType,
    required this.isRead,
    required this.deliveryStatus,
    this.imageUrl,
    this.voiceUrl,
    this.fileName,
    this.fileUrl,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'messageType': messageType.name, // Use .name instead of .toString()
      'isRead': isRead,
      'deliveryStatus': deliveryStatus.name, // Use .name instead of .toString()
      'imageUrl': imageUrl,
      'voiceUrl': voiceUrl,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'metadata': metadata,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      messageType: _parseMessageType(map['messageType']),
      isRead: map['isRead'] ?? false,
      deliveryStatus: _parseDeliveryStatus(map['deliveryStatus']),
      imageUrl: map['imageUrl'],
      voiceUrl: map['voiceUrl'],
      fileName: map['fileName'],
      fileUrl: map['fileUrl'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  static MessageType _parseMessageType(dynamic messageType) {
    if (messageType == null) return MessageType.text;

    if (messageType is String) {
      // Handle both enum.name format and toString() format for backward compatibility
      switch (messageType) {
        case 'text':
        case 'MessageType.text':
          return MessageType.text;
        case 'image':
        case 'MessageType.image':
          return MessageType.image;
        case 'voice':
        case 'MessageType.voice':
          return MessageType.voice;
        case 'file':
        case 'MessageType.file':
          return MessageType.file;
        case 'system':
        case 'MessageType.system':
          return MessageType.system;
        default:
          return MessageType.text;
      }
    }

    return MessageType.text;
  }

  static DeliveryStatus _parseDeliveryStatus(dynamic status) {
    if (status == null) return DeliveryStatus.sent;

    if (status is String) {
      // Handle both enum.name format and toString() format for backward compatibility
      switch (status) {
        case 'sent':
        case 'DeliveryStatus.sent':
          return DeliveryStatus.sent;
        case 'delivered':
        case 'DeliveryStatus.delivered':
          return DeliveryStatus.delivered;
        case 'read':
        case 'DeliveryStatus.read':
          return DeliveryStatus.read;
        case 'failed':
        case 'DeliveryStatus.failed':
          return DeliveryStatus.failed;
        default:
          return DeliveryStatus.sent;
      }
    }

    return DeliveryStatus.sent;
  }
}

// ChatRoom model
class ChatRoom {
  final String id;
  final String sellerId;
  final String buyerId;
  final String sellerName;
  final String buyerName;
  final String? sellerImageUrl;
  final String? buyerImageUrl;
  final UserRole sellerRole;
  final UserRole buyerRole;
  final String productId;
  final String productName;
  final String productImageUrl;
  final String productPrice;
  final String productDescription;
  final String lastMessage;
  final Timestamp lastMessageTime;
  final String lastMessageSenderId;
  final MessageType lastMessageType;
  final int unreadCountSeller;
  final int unreadCountBuyer;
  final bool isActiveForSeller;
  final bool isActiveForBuyer;
  final ChatRoomStatus status;
  final List<String> participants;
  final List<String> blockedBy;
  final bool isGroupChat;
  final Timestamp createdAt;
  final Map<String, dynamic> metadata;

  ChatRoom({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.sellerName,
    required this.buyerName,
    this.sellerImageUrl,
    this.buyerImageUrl,
    required this.sellerRole,
    required this.buyerRole,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
    required this.productDescription,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.lastMessageType,
    required this.unreadCountSeller,
    required this.unreadCountBuyer,
    required this.isActiveForSeller,
    required this.isActiveForBuyer,
    required this.status,
    required this.participants,
    required this.blockedBy,
    required this.isGroupChat,
    required this.createdAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'sellerName': sellerName,
      'buyerName': buyerName,
      'sellerImageUrl': sellerImageUrl,
      'buyerImageUrl': buyerImageUrl,
      'sellerRole': sellerRole.name, // Use .name instead of .toString()
      'buyerRole': buyerRole.name, // Use .name instead of .toString()
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      'productDescription': productDescription,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageType':
          lastMessageType.name, // Use .name instead of .toString()
      'unreadCountSeller': unreadCountSeller,
      'unreadCountBuyer': unreadCountBuyer,
      'isActiveForSeller': isActiveForSeller,
      'isActiveForBuyer': isActiveForBuyer,
      'status': status.name, // Use .name instead of .toString()
      'participants': participants,
      'blockedBy': blockedBy,
      'isGroupChat': isGroupChat,
      'createdAt': createdAt,
      'metadata': metadata,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      buyerName: map['buyerName'] ?? '',
      sellerImageUrl: map['sellerImageUrl'],
      buyerImageUrl: map['buyerImageUrl'],
      sellerRole: UserProfile._parseUserRole(map['sellerRole']),
      buyerRole: UserProfile._parseUserRole(map['buyerRole']),
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImageUrl: map['productImageUrl'] ?? '',
      productPrice: map['productPrice'] ?? '',
      productDescription: map['productDescription'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? Timestamp.now(),
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      lastMessageType: Message._parseMessageType(map['lastMessageType']),
      unreadCountSeller: map['unreadCountSeller'] ?? 0,
      unreadCountBuyer: map['unreadCountBuyer'] ?? 0,
      isActiveForSeller: map['isActiveForSeller'] ?? true,
      isActiveForBuyer: map['isActiveForBuyer'] ?? true,
      status: _parseChatRoomStatus(map['status']),
      participants: List<String>.from(map['participants'] ?? []),
      blockedBy: List<String>.from(map['blockedBy'] ?? []),
      isGroupChat: map['isGroupChat'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  static ChatRoomStatus _parseChatRoomStatus(dynamic status) {
    if (status == null) return ChatRoomStatus.active;

    if (status is String) {
      // Handle both enum.name format and toString() format for backward compatibility
      switch (status) {
        case 'active':
        case 'ChatRoomStatus.active':
          return ChatRoomStatus.active;
        case 'blocked':
        case 'ChatRoomStatus.blocked':
          return ChatRoomStatus.blocked;
        case 'archived':
        case 'ChatRoomStatus.archived':
          return ChatRoomStatus.archived;
        case 'deleted':
        case 'ChatRoomStatus.deleted':
          return ChatRoomStatus.deleted;
        default:
          return ChatRoomStatus.active;
      }
    }

    return ChatRoomStatus.active;
  }
}
