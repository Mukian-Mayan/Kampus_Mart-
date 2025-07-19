class CartModel {
  final String? id;
  final String userId;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create CartModel from Firestore document
  factory CartModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return CartModel(
      id: documentId,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImage: data['productImage'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convert CartModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
    };
  }

  // Create a copy of CartModel with updated fields
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
} 