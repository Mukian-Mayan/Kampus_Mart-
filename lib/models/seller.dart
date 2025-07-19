// models/seller_model.dart
class Seller {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final String businessName;
  final String businessDescription;
  final String businessLocation;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SellerStats stats;

  Seller({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.businessName,
    required this.businessDescription,
    required this.businessLocation,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    required this.stats,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'businessLocation': businessLocation,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'stats': stats.toJson(),
    };
  }

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImageUrl: json['profileImageUrl'],
      businessName: json['businessName'],
      businessDescription: json['businessDescription'],
      businessLocation: json['businessLocation'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      stats: SellerStats.fromJson(json['stats'] ?? {}),
    );
  }

  Seller copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? businessName,
    String? businessDescription,
    String? businessLocation,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    SellerStats? stats,
  }) {
    return Seller(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      businessLocation: businessLocation ?? this.businessLocation,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }
}

class SellerStats {
  final int totalProducts;
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final double totalRevenue;
  final double monthlyRevenue;
  final double rating;
  final int totalReviews;

  SellerStats({
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.pendingOrders = 0,
    this.totalRevenue = 0.0,
    this.monthlyRevenue = 0.0,
    this.rating = 0.0,
    this.totalReviews = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'pendingOrders': pendingOrders,
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }

  factory SellerStats.fromJson(Map<String, dynamic> json) {
    return SellerStats(
      totalProducts: json['totalProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  int get cancelledOrders => totalOrders - completedOrders - pendingOrders;

  SellerStats copyWith({
    int? totalProducts,
    int? totalOrders,
    int? completedOrders,
    int? pendingOrders,
    double? totalRevenue,
    double? monthlyRevenue,
    double? rating,
    int? totalReviews,
  }) {
    return SellerStats(
      totalProducts: totalProducts ?? this.totalProducts,
      totalOrders: totalOrders ?? this.totalOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }
  
}
