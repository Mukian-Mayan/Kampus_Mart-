// Models for Kmart E-commerce App

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stockQuantity;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int views;
  final int likes;
  final List<String> tags;
  final Map<String, dynamic>? specifications;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.imageUrls,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.views = 0,
    this.likes = 0,
    this.tags = const [],
    this.specifications, required int stock, required double rating, required int reviewCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stockQuantity': stockQuantity,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'views': views,
      'likes': likes,
      'tags': tags,
      'specifications': specifications,
    };
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: map['stockQuantity'] ?? 0,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      specifications: map['specifications'], stock:0, rating: 0, reviewCount: 0,
    );
  }
}

class SaleRecord {
  final String id;
  final String sellerId;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final double commission;
  final double profit;
  final DateTime saleDate;
  final String period;
  final int year;
  final int month;
  final int week;
  final int day;

  SaleRecord({
    required this.id,
    required this.sellerId,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.commission,
    required this.profit,
    required this.saleDate,
    required this.period,
    required this.year,
    required this.month,
    required this.week,
    required this.day,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'commission': commission,
      'profit': profit,
      'saleDate': saleDate,
      'period': period,
      'year': year,
      'month': month,
      'week': week,
      'day': day,
    };
  }

  static SaleRecord fromMap(Map<String, dynamic> map) {
    return SaleRecord(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      orderId: map['orderId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      commission: (map['commission'] as num?)?.toDouble() ?? 0.0,
      profit: (map['profit'] as num?)?.toDouble() ?? 0.0,
      saleDate: (map['saleDate'] as Timestamp).toDate(),
      period: map['period'] ?? '',
      year: map['year'] ?? 0,
      month: map['month'] ?? 0,
      week: map['week'] ?? 0,
      day: map['day'] ?? 0,
    );
  }
}