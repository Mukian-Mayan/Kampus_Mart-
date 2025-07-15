import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Collection references
  CollectionReference get productsCollection => _firestore.collection('products');
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get ordersCollection => _firestore.collection('orders');
  CollectionReference get cartCollection => _firestore.collection('cart');

  // Product operations
  Future<void> addProduct(Product product) async {
    try {
      await productsCollection.add({
        ...product.toFirestore(),
        'sellerId': currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await productsCollection.doc(productId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await productsCollection.doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Stream<List<Product>> getProducts() {
    return productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<Product>> getProductsBySeller(String sellerId) {
    return productsCollection
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // User operations
  Future<void> createUserProfile(UserModel user) async {
    try {
      await usersCollection.doc(currentUser?.uid).set({
        ...user.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      await usersCollection.doc(currentUser?.uid).update({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<UserModel?> getUserProfile() async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(currentUser?.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Order operations
  Future<void> createOrder(OrderModel order) async {
    try {
      await ordersCollection.add({
        ...order.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Stream<List<OrderModel>> getUserOrders() {
    return ordersCollection
        .where('userId', isEqualTo: currentUser?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    return ordersCollection
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Cart operations
  Future<void> addToCart(CartModel cartItem) async {
    try {
      await cartCollection.add({
        ...cartItem.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await cartCollection.doc(cartItemId).delete();
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  Future<void> updateCartItem(String cartItemId, Map<String, dynamic> data) async {
    try {
      await cartCollection.doc(cartItemId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  Stream<List<CartModel>> getUserCart() {
    return cartCollection
        .where('userId', isEqualTo: currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> clearUserCart() async {
    try {
      QuerySnapshot cartItems = await cartCollection
          .where('userId', isEqualTo: currentUser?.uid)
          .get();
      
      for (DocumentSnapshot item in cartItems.docs) {
        await item.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Search operations
  Stream<List<Product>> searchProducts(String searchTerm) {
    return productsCollection
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThan: searchTerm + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Category operations
  Stream<List<Product>> getProductsByCategory(String category) {
    return productsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Sales tracking
  Stream<List<OrderModel>> getSalesData(String sellerId, {DateTime? startDate, DateTime? endDate}) {
    Query query = ordersCollection
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'completed');
    
    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: endDate);
    }
    
    return query.orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get cart total
  Future<double> getCartTotal() async {
    try {
      QuerySnapshot cartItems = await cartCollection
          .where('userId', isEqualTo: currentUser?.uid)
          .get();
      
      double total = 0.0;
      for (DocumentSnapshot item in cartItems.docs) {
        Map<String, dynamic> data = item.data() as Map<String, dynamic>;
        total += (data['price'] ?? 0.0) * (data['quantity'] ?? 0);
      }
      return total;
    } catch (e) {
      throw Exception('Failed to calculate cart total: $e');
    }
  }

  // Check if product is in cart
  Future<bool> isProductInCart(String productId) async {
    try {
      QuerySnapshot result = await cartCollection
          .where('userId', isEqualTo: currentUser?.uid)
          .where('productId', isEqualTo: productId)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if product is in cart: $e');
    }
  }

  // Get cart item by product ID
  Future<CartModel?> getCartItemByProductId(String productId) async {
    try {
      QuerySnapshot result = await cartCollection
          .where('userId', isEqualTo: currentUser?.uid)
          .where('productId', isEqualTo: productId)
          .get();
      
      if (result.docs.isNotEmpty) {
        DocumentSnapshot doc = result.docs.first;
        return CartModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get cart item: $e');
    }
  }
} 