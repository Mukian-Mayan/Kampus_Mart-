import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final DateTime createdAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Add or update a cart item
  Future<void> addOrUpdateCartItem(CartItem item) async {
    final docRef = _firestore.collection('cart').doc('${_userId}_${item.productId}');
    await docRef.set(item.toMap(), SetOptions(merge: true));
  }

  // Remove a cart item
  Future<void> removeCartItem(String productId) async {
    final docRef = _firestore.collection('cart').doc('${_userId}_$productId');
    await docRef.delete();
  }

  // Get all cart items for the current user
  Stream<List<CartItem>> getCartItems() {
    return _firestore
        .collection('cart')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList());
  }

  // Clear all cart items for the current user
  Future<void> clearCart() async {
    final query = await _firestore.collection('cart').where('userId', isEqualTo: _userId).get();
    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }
} 