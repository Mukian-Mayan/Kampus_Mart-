// models/cart_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String id;  // This is the document ID from Firestore
  final String userId;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    this.createdAt,
    this.updatedAt,
  });

  // Create CartModel from Firestore document
  factory CartModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CartModel(
      id: id,  // Store the document ID
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImage: data['productImage'],
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convert CartModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      // Note: Don't include 'id' here as it's the document ID, not a field
    };
  }

  // Create a copy with updated fields
  CartModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate total price for this cart item
  double get totalPrice => price * quantity;

  @override
  String toString() {
    return 'CartModel(id: $id, productName: $productName, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}