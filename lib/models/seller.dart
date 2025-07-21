// seller.dart - Fixed Seller model with proper Firestore Timestamp handling
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerStats {
  final int totalProducts;
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double monthlyRevenue;
  final int totalReviews;
  final double rating;

  SellerStats({
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.pendingOrders = 0,
    this.cancelledOrders = 0,
    this.totalRevenue = 0.0,
    this.monthlyRevenue = 0.0,
    this.totalReviews = 0,
    this.rating = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalProducts': totalProducts,
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'pendingOrders': pendingOrders,
      'cancelledOrders': cancelledOrders,
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'totalReviews': totalReviews,
      'rating': rating,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory SellerStats.fromMap(Map<String, dynamic> map) {
    return SellerStats(
      totalProducts: (map['totalProducts'] as num?)?.toInt() ?? 0,
      totalOrders: (map['totalOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (map['completedOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (map['pendingOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (map['cancelledOrders'] as num?)?.toInt() ?? 0,
      totalRevenue: (map['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenue: (map['monthlyRevenue'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (map['totalReviews'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory SellerStats.fromJson(Map<String, dynamic> json) => SellerStats.fromMap(json);

  SellerStats copyWith({
    int? totalProducts,
    int? totalOrders,
    int? completedOrders,
    int? pendingOrders,
    int? cancelledOrders,
    double? totalRevenue,
    double? monthlyRevenue,
    int? totalReviews,
    double? rating,
  }) {
    return SellerStats(
      totalProducts: totalProducts ?? this.totalProducts,
      totalOrders: totalOrders ?? this.totalOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      totalReviews: totalReviews ?? this.totalReviews,
      rating: rating ?? this.rating,
    );
  }
}

class Seller {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? phoneNumber; // Add this for compatibility with your registration
  final String businessName;
  final String businessDescription;
  final String? businessLocation;
  final String? profileImageUrl;
  final bool isVerified;
  final bool? isActive; // Add this for compatibility
  final DateTime createdAt;
  final DateTime updatedAt;
  final SellerStats stats;

  Seller({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.phoneNumber,
    required this.businessName,
    required this.businessDescription,
    this.businessLocation,
    this.profileImageUrl,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.stats,
  });

  // Helper method to safely convert timestamps from Firestore
  static DateTime _convertTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }
    
    if (timestamp is Timestamp) {
      // This is a Firestore Timestamp - use toDate()
      return timestamp.toDate();
    }
    
    if (timestamp is int) {
      // This is milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    if (timestamp is DateTime) {
      return timestamp;
    }
    
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        print('Error parsing timestamp string: $timestamp, error: $e');
        return DateTime.now();
      }
    }
    
    print('Unknown timestamp type: ${timestamp.runtimeType}, value: $timestamp');
    return DateTime.now();
  }

  // Convert Seller object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'phoneNumber': phoneNumber ?? phone, // Ensure backward compatibility
      'businessName': businessName,
      'businessDescription': businessDescription,
      'businessLocation': businessLocation,
      'profileImageUrl': profileImageUrl ?? '',
      'isVerified': isVerified,
      'isActive': isActive ?? true,
      'createdAt': Timestamp.fromDate(createdAt), // Convert to Firestore Timestamp
      'updatedAt': Timestamp.fromDate(updatedAt), // Convert to Firestore Timestamp
      'stats': stats.toMap(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  // Create Seller object from Firestore document data
  factory Seller.fromFirestore(Map<String, dynamic> data) {
    try {
      print('Creating Seller from Firestore data: $data');
      
      return Seller(
        id: data['id'] as String? ?? '',
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        phone: data['phone'] as String?,
        phoneNumber: data['phoneNumber'] as String? ?? data['phone'] as String?,
        businessName: data['businessName'] as String? ?? '',
        businessDescription: data['businessDescription'] as String? ?? '',
        businessLocation: data['businessLocation'] as String?,
        profileImageUrl: data['profileImageUrl'] as String?,
        isVerified: data['isVerified'] as bool? ?? false,
        isActive: data['isActive'] as bool? ?? true,
        createdAt: _convertTimestamp(data['createdAt']),
        updatedAt: _convertTimestamp(data['updatedAt']),
        stats: data['stats'] != null 
            ? SellerStats.fromMap(data['stats'] as Map<String, dynamic>)
            : SellerStats(),
      );
    } catch (e) {
      print('Error creating Seller from Firestore data: $e');
      print('Problematic data: $data');
      rethrow;
    }
  }

  // Create Seller from DocumentSnapshot
  factory Seller.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null for seller: ${doc.id}');
    }
    
    // Ensure the document ID is included
    data['id'] = doc.id;
    
    return Seller.fromFirestore(data);
  }

  // Alternative constructor from Map (useful for general Map conversions)
  factory Seller.fromMap(Map<String, dynamic> map) {
    return Seller.fromFirestore(map);
  }

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String?,
      businessName: json['businessName'] as String? ?? '',
      businessDescription: json['businessDescription'] as String? ?? '',
      businessLocation: json['businessLocation'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _convertTimestamp(json['createdAt']),
      updatedAt: _convertTimestamp(json['updatedAt']),
      stats: json['stats'] != null 
          ? SellerStats.fromJson(json['stats'] as Map<String, dynamic>)
          : SellerStats(),
    );
  }

  // Create a copy of Seller with updated fields
  Seller copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? phoneNumber,
    String? businessName,
    String? businessDescription,
    String? businessLocation,
    String? profileImageUrl,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    SellerStats? stats,
  }) {
    return Seller(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      businessLocation: businessLocation ?? this.businessLocation,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }

  @override
  String toString() {
    return 'Seller(id: $id, name: $name, email: $email, businessName: $businessName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Seller && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper getter for backward compatibility
  String? get number => phoneNumber ?? phone;
}