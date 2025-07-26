// services/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import 'seller_service.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'orders';

  /// Create a new order
  static Future<Order> createOrder({
    required String buyerId,
    required String name,
    required String email,
    required String phone,
    required String sellerId,
    required List<OrderItem> items,
    required double subtotal,
    required double deliveryFee,
    required DeliveryAddress deliveryAddress,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      // Get seller info
      final seller = await SellerService.getSellerById(sellerId);

      final String orderId = _firestore.collection(_collection).doc().id;
      final double totalAmount = subtotal + deliveryFee;

      final Order order = Order(
        id: orderId,
        buyerId: buyerId,
        name: name,
        email: email,
        phone: phone,
        sellerId: sellerId,
        sellerName: seller.name,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore.collection(_collection).doc(orderId).set(order.toJson());

      // Update seller stats
      await SellerService.updateSellerStats(
        sellerId: sellerId,
        pendingOrders: seller.stats.pendingOrders + 1,
        totalOrders: seller.stats.totalOrders + 1,
        cancelledOrders: 0,
        totalRevenue: seller.stats.totalRevenue + totalAmount,
      );

      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get order by ID
  static Future<Order> getOrderById(String orderId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(orderId)
          .get();

      if (!doc.exists) {
        throw Exception('Order not found');
      }

      return Order.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  /// Get orders by customer ID
  static Future<List<Order>> getOrdersByCustomerId(String buyerId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Order.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get customer orders: $e');
    }
  }

  /// Get orders by seller ID
  static Future<List<Order>> getOrdersBySellerId(String sellerId) async {
    try {
      print('🔍 Fetching orders for seller: $sellerId');

      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      print(
        '📦 Found ${querySnapshot.docs.length} orders for seller: $sellerId',
      );

      final orders = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(
          '📋 Order data: ${data['id']} - Status: ${data['status']} - Total: ${data['totalAmount']}',
        );
        return Order.fromJson(data);
      }).toList();

      print('✅ Successfully parsed ${orders.length} orders');
      return orders;
    } catch (e) {
      print('❌ Error fetching seller orders: $e');
      throw Exception('Failed to get seller orders: $e');
    }
  }

  /// Update order status
  static Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update seller stats if order is completed or cancelled
      if (status == OrderStatus.completed || status == OrderStatus.cancelled) {
        final order = await getOrderById(orderId);
        final seller = await SellerService.getSellerById(order.sellerId);

        int pendingOrders = seller.stats.pendingOrders - 1;
        int completedOrders = seller.stats.completedOrders;
        int cancelledOrders = seller.stats.cancelledOrders;
        double totalRevenue = seller.stats.totalRevenue;

        if (status == OrderStatus.completed) {
          completedOrders += 1;
          totalRevenue += order.totalAmount;
        } else if (status == OrderStatus.cancelled) {
          cancelledOrders += 1;
        }

        await SellerService.updateSellerStats(
          sellerId: order.sellerId,
          pendingOrders: pendingOrders,
          completedOrders: completedOrders,
          cancelledOrders: cancelledOrders,
          totalRevenue: totalRevenue,
        );
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Update payment status
  static Future<void> updatePaymentStatus(
    String orderId,
    PaymentStatus paymentStatus,
  ) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'paymentStatus': paymentStatus.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Get orders by status
  static Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Order.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  /// Delete order (soft delete by updating status)
  static Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': 'deleted',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  /// Get order statistics
  static Future<Map<String, dynamic>> getOrderStats() async {
    try {
      final QuerySnapshot allOrders = await _firestore
          .collection(_collection)
          .get();

      int totalOrders = allOrders.docs.length;
      int pendingOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      double totalRevenue = 0.0;

      for (var doc in allOrders.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String;
        final totalAmount = (data['totalAmount'] as num).toDouble();

        switch (status) {
          case 'pending':
            pendingOrders++;
            break;
          case 'completed':
            completedOrders++;
            totalRevenue += totalAmount;
            break;
          case 'cancelled':
            cancelledOrders++;
            break;
        }
      }

      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  /// Stream orders for real-time updates
  static Stream<List<Order>> streamOrders() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Order.fromJson(doc.data())).toList(),
        );
  }

  /// Stream orders by customer ID
  static Stream<List<Order>> streamOrdersByCustomerId(String customerId) {
    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Order.fromJson(doc.data())).toList(),
        );
  }

  /// Stream orders by seller ID
  static Stream<List<Order>> streamOrdersBySellerId(String sellerId) {
    return _firestore
        .collection(_collection)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Order.fromJson(doc.data())).toList(),
        );
  }
}
