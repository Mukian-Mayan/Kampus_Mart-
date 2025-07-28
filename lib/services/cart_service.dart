import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kampusmart2/models/cart_model.dart';

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
          throw Exception('Cannot add more items. Maximum quantity is $maxQuantity');
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
  Future<void> updateCartItemQuantity(String cartItemId, int newQuantity) async {
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
        .map((snapshot) => snapshot.docs
            .map((doc) => CartModel.fromFirestore(
                doc.data() as Map<String, dynamic>, 
                doc.id
            ))
            .toList());
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
        double price = (data['price'] as num?)?.toDouble() ?? 0.0;
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
  Future<void> updateProductAvailability(String productId, bool isAvailable) async {
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

