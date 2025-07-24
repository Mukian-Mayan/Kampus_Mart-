// lib/models/product.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String priceAndDiscount;
  final String originalPrice;
  final String condition;
  final String location;
  final double rating;
  final String imageUrl;
  final List<String>? imageUrls;
  final bool bestOffer;
  final String? category;
  final double? price;
  final double? discountPercentage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.priceAndDiscount,
    required this.originalPrice,
    required this.condition,
    required this.location,
    required this.rating,
    required this.imageUrl,
    this.imageUrls,
    this.bestOffer = false,
    this.category,
    this.price,
    this.discountPercentage,
    this.createdAt,
    this.updatedAt,
    this.stock,
  });

  // Helper functions for robust type conversion
  static String _toString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String _getId(dynamic value) {
    if (value is String) return value;
    if (value is DocumentReference) return value.id;
    return '';
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String && value.isNotEmpty) {
      // Try to parse numeric string
      String numStr = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(numStr);
    }
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String && value.isNotEmpty) return int.tryParse(value);
    return null;
  }

  // Get formatted original price
  String get formattedOriginalPrice {
    if (price != null) {
      return 'UGX ${price!.toStringAsFixed(0)}';
    }
    return originalPrice;
  }

  // Get formatted discounted price
  String get formattedDiscountedPrice {
    if (price != null && discountPercentage != null) {
      final discountAmount = price! * (discountPercentage! / 100);
      final discountedPrice = price! - discountAmount;
      return 'UGX ${discountedPrice.toStringAsFixed(0)}';
    }
    // If no numeric price/discount, use the string-based price
    return priceAndDiscount;
  }

  // Get formatted discount percentage
  String get formattedDiscount {
    if (discountPercentage != null) {
      return '(${discountPercentage!.toStringAsFixed(0)}% off)';
    }
    // Try to calculate discount from string prices
    try {
      final originalNum = _toDouble(originalPrice);
      final discountedNum = _toDouble(priceAndDiscount);
      if (originalNum != null && discountedNum != null && originalNum > 0) {
        final discount = ((originalNum - discountedNum) / originalNum * 100).round();
        return '($discount% off)';
      }
    } catch (_) {}
    return '';
  }

  // Factory constructor to create Product from Firestore document
  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Try to extract numeric values from string prices
    final originalPriceStr = _toString(data['originalPrice']);
    final discountedPriceStr = _toString(data['priceAndDiscount']);
    
    double? price = _toDouble(data['price']);
    if (price == null) {
      // Try to get price from originalPrice string
      price = _toDouble(originalPriceStr);
    }

    double? discountPercentage = _toDouble(data['discountPercentage']);
    if (discountPercentage == null && price != null) {
      // Try to calculate discount percentage from prices
      final discountedPrice = _toDouble(discountedPriceStr);
      if (discountedPrice != null && price > 0) {
        discountPercentage = ((price - discountedPrice) / price * 100);
      }
    }

    // Use sellerId if available, otherwise use ownerId
    final String sellerId = _getId(data['sellerId'] ?? '');
    final String ownerId = _getId(data['ownerId'] ?? '');
    final String effectiveId = sellerId.isNotEmpty ? sellerId : ownerId;

    return Product(
      id: documentId,
      name: _toString(data['name']),
      description: _toString(data['description']),
      ownerId: effectiveId,
      priceAndDiscount: discountedPriceStr,
      originalPrice: originalPriceStr,
      condition: _toString(data['condition']),
      location: _toString(data['location']),
      rating: _toDouble(data['rating']) ?? 0.0,
      imageUrl: _toString(data['imageUrl']),
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from((data['imageUrls'] as List).map(_toString))
          : null,
      bestOffer: data['bestOffer'] ?? false,
      category: data['category'],
      price: price,
      discountPercentage: discountPercentage,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      stock: _toInt(data['stock']),
    );
  }

  // Convert Product to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'priceAndDiscount': priceAndDiscount,
      'originalPrice': originalPrice,
      'condition': condition,
      'location': location,
      'rating': rating,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'bestOffer': bestOffer,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'stock': stock,
    };
  }

  // Convert Product to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'sellerId': ownerId,
      'priceAndDiscount': priceAndDiscount,
      'originalPrice': originalPrice,
      'condition': condition,
      'location': location,
      'rating': rating,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'bestOffer': bestOffer,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
    };
  }

  // Copy method for creating updated instances
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? priceAndDiscount,
    String? originalPrice,
    String? condition,
    String? location,
    double? rating,
    String? imageUrl,
    List<String>? imageUrls,
    bool? bestOffer,
    String? category,
    double? price,
    double? discountPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      priceAndDiscount: priceAndDiscount ?? this.priceAndDiscount,
      originalPrice: originalPrice ?? this.originalPrice,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      bestOffer: bestOffer ?? this.bestOffer,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}