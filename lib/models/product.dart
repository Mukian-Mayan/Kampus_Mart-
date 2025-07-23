// lib/models/product.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id; // Add this field - it's required for CRUD operations
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? stock;

  Product({
    required this.id, // Add this to constructor
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
    if (value is String && value.isNotEmpty) return double.tryParse(value);
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String && value.isNotEmpty) return int.tryParse(value);
    return null;
  }

  // Factory constructor to create Product from Firestore document
  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId, // Set the document ID as the product ID
      name: _toString(data['name']),
      description: _toString(data['description']),
      ownerId: _getId(data['ownerId'] ?? data['sellerId']), // Handle both field names and DocumentReference
      priceAndDiscount: _toString(data['priceAndDiscount']),
      originalPrice: _toString(data['originalPrice']),
      condition: _toString(data['condition']),
      location: _toString(data['location']),
      rating: _toDouble(data['rating']) ?? 0.0,
      imageUrl: _toString(data['imageUrl']),
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from((data['imageUrls'] as List).map(_toString))
          : null,
      bestOffer: data['bestOffer'] ?? false,
      category: data['category'],
      price: _toDouble(data['price']),
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
      'sellerId': ownerId, // Add sellerId for compatibility
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
      // Note: createdAt and updatedAt will be set by Firestore timestamps
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}