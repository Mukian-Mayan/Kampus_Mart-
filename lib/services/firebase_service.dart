import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/product.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/category_model.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Collection references
  CollectionReference get productsCollection =>
      _firestore.collection('products');
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get ordersCollection => _firestore.collection('orders');
  CollectionReference get cartCollection => _firestore.collection('cart');
  CollectionReference get categoriesCollection =>
      _firestore.collection('categories');

  // ============================================
  // PRODUCT OPERATIONS
  // ============================================

  Future<void> addProduct(Product product) async {
    try {
      await productsCollection.add({
        ...product.toFirestore(),
        'sellerId': currentUser?.uid,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update seller product count
      if (currentUser != null) {
        await _incrementSellerProductCount(currentUser!.uid);
      }
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  /// Helper method to increment seller product count
  Future<void> _incrementSellerProductCount(String sellerId) async {
    try {
      final sellerRef = _firestore.collection('sellers').doc(sellerId);

      await _firestore.runTransaction((transaction) async {
        final sellerDoc = await transaction.get(sellerRef);

        if (sellerDoc.exists) {
          final currentStats =
              sellerDoc.data()?['stats'] as Map<String, dynamic>? ?? {};
          final currentCount =
              (currentStats['totalProducts'] as num?)?.toInt() ?? 0;

          final updatedStats = {
            ...currentStats,
            'totalProducts': currentCount + 1,
          };

          transaction.update(sellerRef, {
            'stats': updatedStats,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error incrementing seller product count: $e');
      // Don't rethrow - product creation should still succeed
    }
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
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
      // Get product data first to get seller ID
      DocumentSnapshot productDoc = await productsCollection
          .doc(productId)
          .get();
      if (productDoc.exists) {
        Map<String, dynamic> productData =
            productDoc.data() as Map<String, dynamic>;
        String sellerId = productData['sellerId'] ?? '';

        // Delete the product
        await productsCollection.doc(productId).delete();

        // Update seller product count if seller ID exists
        if (sellerId.isNotEmpty) {
          await _decrementSellerProductCount(sellerId);
        }
      } else {
        await productsCollection.doc(productId).delete();
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Helper method to decrement seller product count
  Future<void> _decrementSellerProductCount(String sellerId) async {
    try {
      final sellerRef = _firestore.collection('sellers').doc(sellerId);

      await _firestore.runTransaction((transaction) async {
        final sellerDoc = await transaction.get(sellerRef);

        if (sellerDoc.exists) {
          final currentStats =
              sellerDoc.data()?['stats'] as Map<String, dynamic>? ?? {};
          final currentCount =
              (currentStats['totalProducts'] as num?)?.toInt() ?? 0;

          // Ensure count doesn't go below 0
          final newCount = currentCount > 0 ? currentCount - 1 : 0;

          final updatedStats = {...currentStats, 'totalProducts': newCount};

          transaction.update(sellerRef, {
            'stats': updatedStats,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error decrementing seller product count: $e');
      // Don't rethrow - product deletion should still succeed
    }
  }

  Future<void> toggleProductStatus(String productId, bool isActive) async {
    try {
      await productsCollection.doc(productId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product status: $e');
    }
  }

  Stream<List<Product>> getProducts({
    String? categoryId,
    bool activeOnly = true,
  }) {
    Query query = productsCollection.orderBy('createdAt', descending: true);

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => Product.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList(),
    );
  }

  Stream<List<Product>> getProductsBySeller(String sellerId) {
    return productsCollection
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Product.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<Product?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc = await productsCollection.doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  // ============================================
  // CATEGORY OPERATIONS
  // ============================================

  Future<void> addCategory(CategoryModel category) async {
    try {
      await categoriesCollection.add({
        ...category.toFirestore(),
        'productCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      await categoriesCollection.doc(categoryId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Stream<List<CategoryModel>> getCategories() {
    return categoriesCollection
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CategoryModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<CategoryModel?> getCategory(String categoryId) async {
    try {
      DocumentSnapshot doc = await categoriesCollection.doc(categoryId).get();
      if (doc.exists) {
        return CategoryModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  Future<void> recalculateCategoryCounts() async {
    try {
      final callable = _functions.httpsCallable('recalculateCategoryCounts');
      final result = await callable.call();

      if (!result.data['success']) {
        throw Exception('Failed to recalculate category counts');
      }
    } catch (e) {
      throw Exception('Failed to recalculate category counts: $e');
    }
  }

  // ============================================
  // USER OPERATIONS
  // ============================================

  Future<void> createUserProfile(UserModel user) async {
    try {
      // Get FCM token for notifications
      final fcmToken = await _messaging.getToken();

      await usersCollection.doc(currentUser?.uid).set({
        ...user.toFirestore(),
        'fcmToken': fcmToken,
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

  Future<void> updateFCMToken() async {
    try {
      final fcmToken = await _messaging.getToken();
      if (fcmToken != null && currentUser != null) {
        await usersCollection.doc(currentUser!.uid).update({
          'fcmToken': fcmToken,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  Future<UserModel?> getUserProfile([String? userId]) async {
    try {
      final uid = userId ?? currentUser?.uid;
      if (uid == null) return null;

      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // ============================================
  // ORDER OPERATIONS
  // ============================================

  Future<String> createOrder(OrderModel order) async {
    try {
      DocumentReference orderRef = await ordersCollection.add({
        ...order.toFirestore(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return orderRef.id;
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

  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    try {
      await ordersCollection.doc(orderId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await ordersCollection.doc(orderId).delete();
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  Stream<List<OrderModel>> getUserOrders() {
    return ordersCollection
        .where('userId', isEqualTo: currentUser?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => OrderModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Stream<List<OrderModel>> getSellerOrders(String sellerId, {String? status}) {
    Query query = ordersCollection.where('sellerId', isEqualTo: sellerId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => OrderModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      DocumentSnapshot doc = await ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // ============================================
  // CART OPERATIONS
  // ============================================

  Future<void> addToCart(CartModel cartItem) async {
    try {
      // Check if item already exists in cart
      final existingItem = await getCartItemByProductId(cartItem.productId);

      if (existingItem != null) {
        // Update quantity instead of adding new item
        await updateCartItem(existingItem.id, {
          'quantity': existingItem.quantity + cartItem.quantity,
        });
      } else {
        await cartCollection.add({
          ...cartItem.toFirestore(),
          'userId': currentUser?.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
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

  Future<void> updateCartItem(
    String cartItemId,
    Map<String, dynamic> data,
  ) async {
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
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CartModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> clearUserCart() async {
    try {
      QuerySnapshot cartItems = await cartCollection
          .where('userId', isEqualTo: currentUser?.uid)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot item in cartItems.docs) {
        batch.delete(item.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

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

  Future<int> getCartItemCount() async {
    try {
      QuerySnapshot cartItems = await cartCollection
          .where('userId', isEqualTo: currentUser?.uid)
          .get();

      int count = 0;
      for (DocumentSnapshot item in cartItems.docs) {
        Map<String, dynamic> data = item.data() as Map<String, dynamic>;
        count += (data['quantity'] ?? 0) as int;
      }
      return count;
    } catch (e) {
      throw Exception('Failed to get cart item count: $e');
    }
  }

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

  Future<CartModel?> getCartItemByProductId(String productId) async {
    try {
      QuerySnapshot result = await cartCollection
          .where('userId', isEqualTo: currentUser?.uid)
          .where('productId', isEqualTo: productId)
          .get();

      if (result.docs.isNotEmpty) {
        DocumentSnapshot doc = result.docs.first;
        return CartModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get cart item: $e');
    }
  }

  // ============================================
  // SEARCH AND FILTERING
  // ============================================

  Stream<List<Product>> searchProducts(String searchTerm) {
    return productsCollection
        .where('isActive', isEqualTo: true)
        .where('name', isGreaterThanOrEqualTo: searchTerm.toLowerCase())
        .where('name', isLessThan: '${searchTerm.toLowerCase()}\uf8ff')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Product.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Stream<List<Product>> getProductsByCategory(String categoryId) {
    return productsCollection
        .where('categoryId', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Product.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Stream<List<Product>> getFilteredProducts({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool descending = true,
  }) {
    Query query = productsCollection.where('isActive', isEqualTo: true);

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }

    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    // Apply sorting
    switch (sortBy) {
      case 'price':
        query = query.orderBy('price', descending: descending);
        break;
      case 'name':
        query = query.orderBy('name', descending: descending);
        break;
      case 'rating':
        query = query.orderBy('averageRating', descending: descending);
        break;
      default:
        query = query.orderBy('createdAt', descending: descending);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => Product.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList(),
    );
  }

  // ============================================
  // ANALYTICS AND REPORTING
  // ============================================

  Future<Map<String, dynamic>> getSalesReport({
    String? sellerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateSalesReport');
      final result = await callable.call({
        'sellerId': sellerId ?? currentUser?.uid,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      });

      return result.data;
    } catch (e) {
      throw Exception('Failed to generate sales report: $e');
    }
  }

  Stream<List<OrderModel>> getSalesData(
    String sellerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = ordersCollection
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'completed');

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: endDate);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => OrderModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  // Batch operations
  WriteBatch createBatch() {
    return _firestore.batch();
  }

  Future<void> commitBatch(WriteBatch batch) async {
    await batch.commit();
  }

  // Transaction operations
  Future<T> runTransaction<T>(TransactionHandler<T> updateFunction) {
    return _firestore.runTransaction(updateFunction);
  }

  // Get document reference
  DocumentReference getDocumentReference(String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId);
  }

  // Get collection reference
  CollectionReference getCollectionReference(String collection) {
    return _firestore.collection(collection);
  }

  // Error handling helper
  String _getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this operation.';
        case 'unavailable':
          return 'The service is currently unavailable. Please try again later.';
        case 'deadline-exceeded':
          return 'The operation timed out. Please check your connection and try again.';
        case 'not-found':
          return 'The requested resource was not found.';
        case 'already-exists':
          return 'The resource already exists.';
        case 'resource-exhausted':
          return 'Quota exceeded. Please try again later.';
        case 'failed-precondition':
          return 'The operation failed due to precondition requirements.';
        case 'aborted':
          return 'The operation was aborted due to a conflict.';
        case 'out-of-range':
          return 'The specified value is out of range.';
        case 'unimplemented':
          return 'This operation is not implemented or supported.';
        case 'internal':
          return 'An internal error occurred. Please try again.';
        case 'data-loss':
          return 'Unrecoverable data loss or corruption.';
        case 'unauthenticated':
          return 'User is not authenticated. Please sign in and try again.';
        default:
          return error.message ?? 'An unknown error occurred.';
      }
    }
    return error.toString();
  }

  // Health check
  Future<bool> isConnected() async {
    try {
      await _firestore.doc('health/check').get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cleanup resources
  void dispose() {
    // Any cleanup operations if needed
  }

  static Future<String> uploadProductImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'product_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}',
      );
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get cartCollection => _firestore.collection('cart');
  User? get currentUser => _auth.currentUser;

  // Add item to cart with comprehensive options
  Future<void> addToCart({
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    required int quantity,
    required String sellerId,
    required String sellerName,
    String? size,
    String? color,
    String? variant,
    Map<String, dynamic>? selectedOptions,
    int maxQuantity = 999,
  }) async {
    if (currentUser == null) {
      throw Exception('User must be authenticated to add items to cart');
    }

    try {
      // Create unique identifier for this specific product configuration
      String configId = _createConfigurationId(
        productId,
        size: size,
        color: color,
        variant: variant,
        selectedOptions: selectedOptions,
      );

      // Check if this exact configuration already exists in cart
      QuerySnapshot existingItems = await cartCollection
          .where('userId', isEqualTo: currentUser!.uid)
          .where('productId', isEqualTo: productId)
          .where('configurationId', isEqualTo: configId)
          .get();

      if (existingItems.docs.isNotEmpty) {
        // Update existing item quantity
        DocumentSnapshot existingItem = existingItems.docs.first;
        Map<String, dynamic> data = existingItem.data() as Map<String, dynamic>;
        int currentQuantity = data['quantity'] ?? 0;
        int newQuantity = currentQuantity + quantity;

        // Check if new quantity exceeds maximum
        if (newQuantity > maxQuantity) {
          throw Exception(
            'Cannot add more items. Maximum quantity is $maxQuantity',
          );
        }

        await existingItem.reference.update({
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new cart item
        await cartCollection.add({
          'userId': currentUser!.uid,
          'productId': productId,
          'productName': productName,
          'productImage': productImage,
          'price': price,
          'quantity': quantity,
          'size': size,
          'color': color,
          'variant': variant,
          'selectedOptions': selectedOptions,
          'configurationId': configId,
          'isAvailable': true,
          'maxQuantity': maxQuantity,
          'sellerId': sellerId,
          'sellerName': sellerName,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Update cart item quantity with validation
  Future<void> updateCartItemQuantity(
    String cartItemId,
    int newQuantity,
  ) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    try {
      // Get current cart item to check max quantity
      DocumentSnapshot cartDoc = await cartCollection.doc(cartItemId).get();
      if (!cartDoc.exists) {
        throw Exception('Cart item not found');
      }

      Map<String, dynamic> data = cartDoc.data() as Map<String, dynamic>;
      int maxQuantity = data['maxQuantity'] ?? 999;

      if (newQuantity > maxQuantity) {
        throw Exception('Maximum quantity allowed is $maxQuantity');
      }

      await cartCollection.doc(cartItemId).update({
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await cartCollection.doc(cartItemId).delete();
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Get user's cart with real-time updates
  Stream<List<CartModel>> getUserCart() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return cartCollection
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CartModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Get cart summary
  Future<CartSummary> getCartSummary() async {
    if (currentUser == null) {
      return CartSummary.empty();
    }

    try {
      QuerySnapshot cartItems = await cartCollection
          .where('userId', isEqualTo: currentUser!.uid)
          .get();

      double subtotal = 0.0;
      int itemCount = 0;
      Map<String, int> sellerCounts = {};
      List<String> unavailableItems = [];

      for (DocumentSnapshot doc in cartItems.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        int quantity = data['quantity'] ?? 0;
        double price = (data['price'] ?? 0.0).toDouble();
        bool isAvailable = data['isAvailable'] ?? true;
        String sellerId = data['sellerId'] ?? '';

        if (isAvailable) {
          subtotal += price * quantity;
          itemCount += quantity;
          sellerCounts[sellerId] = (sellerCounts[sellerId] ?? 0) + 1;
        } else {
          unavailableItems.add(data['productName'] ?? 'Unknown Product');
        }
      }

      return CartSummary(
        subtotal: subtotal,
        itemCount: itemCount,
        uniqueSellerCount: sellerCounts.length,
        unavailableItems: unavailableItems,
      );
    } catch (e) {
      throw Exception('Failed to get cart summary: $e');
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    if (currentUser == null) return;

    try {
      QuerySnapshot cartItems = await cartCollection
          .where('userId', isEqualTo: currentUser!.uid)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Remove items from specific seller
  Future<void> removeSellerItems(String sellerId) async {
    if (currentUser == null) return;

    try {
      QuerySnapshot sellerItems = await cartCollection
          .where('userId', isEqualTo: currentUser!.uid)
          .where('sellerId', isEqualTo: sellerId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in sellerItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to remove seller items: $e');
    }
  }

  // Check if specific product configuration exists in cart
  Future<bool> isProductConfigurationInCart(
    String productId, {
    String? size,
    String? color,
    String? variant,
    Map<String, dynamic>? selectedOptions,
  }) async {
    if (currentUser == null) return false;

    try {
      String configId = _createConfigurationId(
        productId,
        size: size,
        color: color,
        variant: variant,
        selectedOptions: selectedOptions,
      );

      QuerySnapshot result = await cartCollection
          .where('userId', isEqualTo: currentUser!.uid)
          .where('productId', isEqualTo: productId)
          .where('configurationId', isEqualTo: configId)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Update product availability in cart (called when product stock changes)
  Future<void> updateProductAvailability(
    String productId,
    bool isAvailable,
  ) async {
    try {
      QuerySnapshot productInCarts = await cartCollection
          .where('productId', isEqualTo: productId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in productInCarts.docs) {
        batch.update(doc.reference, {
          'isAvailable': isAvailable,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update product availability: $e');
    }
  }

  // Private helper method to create configuration ID
  String _createConfigurationId(
    String productId, {
    String? size,
    String? color,
    String? variant,
    Map<String, dynamic>? selectedOptions,
  }) {
    List<String> configParts = [productId];

    if (size != null) configParts.add('size:$size');
    if (color != null) configParts.add('color:$color');
    if (variant != null) configParts.add('variant:$variant');

    if (selectedOptions != null && selectedOptions.isNotEmpty) {
      List<String> sortedKeys = selectedOptions.keys.toList()..sort();
      for (String key in sortedKeys) {
        configParts.add('$key:${selectedOptions[key]}');
      }
    }

    return configParts.join('|');
  }
}

// ============================================
// CART SUMMARY MODEL
// ============================================

class CartSummary {
  final double subtotal;
  final int itemCount;
  final int uniqueSellerCount;
  final List<String> unavailableItems;

  CartSummary({
    required this.subtotal,
    required this.itemCount,
    required this.uniqueSellerCount,
    required this.unavailableItems,
  });

  factory CartSummary.empty() {
    return CartSummary(
      subtotal: 0.0,
      itemCount: 0,
      uniqueSellerCount: 0,
      unavailableItems: [],
    );
  }

  bool get isEmpty => itemCount == 0;
  bool get hasUnavailableItems => unavailableItems.isNotEmpty;

  // Calculate tax (you can customize this based on your requirements)
  double getTax({double taxRate = 0.0}) => subtotal * taxRate;

  // Calculate total with tax
  double getTotal({double taxRate = 0.0, double shippingCost = 0.0}) {
    return subtotal + getTax(taxRate: taxRate) + shippingCost;
  }
}
