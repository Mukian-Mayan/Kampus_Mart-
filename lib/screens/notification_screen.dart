// ignore_for_file: deprecated_member_use, use_super_parameters, prefer_final_fields, unreachable_switch_case

import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/payment_processing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar2.dart';
import '../screens/Product_management.dart';
import '../screens/order_management.dart';
import '../Theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/cart_page.dart';
import '../services/firebase_base_service.dart';
import '../models/user_role.dart';

// Enhanced Notification Service Integration
class NotificationBackendService {
  static const String _collection = 'notifications';
  
  // Create notification types mapping
  static const Map<String, NotificationType> _typeMapping = {
    'order_confirmed': NotificationType.orderConfirmed,
    'order_preparing': NotificationType.orderPreparing,
    'order_ready': NotificationType.orderReady,
    'order_delivered': NotificationType.orderDelivered,
    'cart_reminder': NotificationType.cartReminder,
    'payment': NotificationType.payment,
    'general': NotificationType.general,
    'new_order': NotificationType.newOrder,
    'order_cancelled': NotificationType.orderCancelled,
    'low_stock': NotificationType.lowStock,
    'product_approved': NotificationType.productApproved,
    'chat_message': NotificationType.general,
  };

  // Send notification to Firebase - Added null safety and error handling
  static Future<bool> sendNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    required UserRole userRole,
    String? orderId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Validate required parameters
      if (userId.isEmpty || title.isEmpty || message.isEmpty) {
        debugPrint('Error: Missing required notification parameters');
        return false;
      }

      final notificationData = {
        'userId': userId,
        'title': title,
        'message': message,
        'type': _getTypeString(type),
        'userRole': userRole.toString().split('.').last,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'orderId': orderId,
        'additionalData': additionalData ?? {},
      };

      await FirebaseFirestore.instance
          .collection(_collection)
          .add(notificationData);
      
      return true;
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }

  // Get user notifications from Firebase - Fixed query structure
  static Stream<List<NotificationModel>> getUserNotificationsStream({
    required String userId,
    required UserRole userRole,
  }) {
    try {
      return FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('userRole', isEqualTo: userRole.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .handleError((error) {
            debugPrint('Error in notifications stream: $error');
            return Stream.empty();
          })
          .map((snapshot) {
            try {
              return snapshot.docs
                  .map((doc) => _convertToNotificationModel(doc))
                  .where((notification) => notification != null)
                  .cast<NotificationModel>()
                  .toList();
            } catch (e) {
              debugPrint('Error mapping notifications: $e');
              return <NotificationModel>[];
            }
          });
    } catch (e) {
      debugPrint('Error creating notifications stream: $e');
      return Stream.value(<NotificationModel>[]);
    }
  }

  // Mark notification as read - Added error handling
  static Future<void> markAsRead(String notificationId) async {
    try {
      if (notificationId.isEmpty) return;
      
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read for a user - Improved batch processing
  static Future<void> markAllAsRead(String userId) async {
    try {
      if (userId.isEmpty) return;
      
      final batch = FirebaseFirestore.instance.batch();
      final notifications = await FirebaseFirestore.instance
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .limit(500) // Add limit to prevent oversized batches
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Delete notification - Added validation
  static Future<void> deleteNotification(String notificationId) async {
    try {
      if (notificationId.isEmpty) return;
      
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  // Helper methods - Improved error handling
  static String _getTypeString(NotificationType type) {
    try {
      return type.toString().split('.').last.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      ).substring(1);
    } catch (e) {
      debugPrint('Error converting type to string: $e');
      return 'general';
    }
  }

  static NotificationModel? _convertToNotificationModel(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      final typeString = data['type'] as String?;
      final userRoleString = data['userRole'] as String?;
      final timestamp = data['createdAt'] as Timestamp?;

      if (typeString == null || userRoleString == null) {
        debugPrint('Missing required fields in notification: ${doc.id}');
        return null;
      }

      final type = _typeMapping[typeString] ?? NotificationType.general;
      UserRole userRole;
      
      // Improved user role parsing
      switch (userRoleString.toLowerCase()) {
        case 'buyer':
          userRole = UserRole.buyer;
          break;
        case 'seller':
          userRole = UserRole.seller;
          break;
        default:
          debugPrint('Unknown user role: $userRoleString');
          return null;
      }

      return NotificationModel(
        id: doc.id,
        title: data['title'] ?? 'No Title',
        message: data['message'] ?? 'No Message',
        type: type,
        timestamp: timestamp?.toDate() ?? DateTime.now(),
        isRead: data['isRead'] ?? false,
        orderId: data['orderId'],
        userRole: userRole,
      );
    } catch (e) {
      debugPrint('Error converting notification ${doc.id}: $e');
      return null;
    }
  }

  // Predefined notification templates with validation
  static Future<void> sendOrderConfirmation({
    required String userId,
    required String orderId,
    required double amount,
  }) async {
    if (userId.isEmpty || orderId.isEmpty || amount < 0) {
      debugPrint('Invalid parameters for order confirmation');
      return;
    }
    
    await sendNotification(
      userId: userId,
      title: 'Order Confirmed',
      message: 'Your order #$orderId for UGX ${amount.toStringAsFixed(0)} has been confirmed',
      type: NotificationType.orderConfirmed,
      userRole: UserRole.buyer,
      orderId: orderId,
    );
  }

  static Future<void> sendPaymentSuccess({
    required String userId,
    required String orderId,
    required double amount,
  }) async {
    if (userId.isEmpty || orderId.isEmpty || amount < 0) {
      debugPrint('Invalid parameters for payment success');
      return;
    }
    
    await sendNotification(
      userId: userId,
      title: 'Payment Successful',
      message: 'Payment of UGX ${amount.toStringAsFixed(0)} for order #$orderId was successful',
      type: NotificationType.payment,
      userRole: UserRole.buyer,
      orderId: orderId,
    );
  }

  static Future<void> sendCartReminder({
    required String userId,
    required int itemCount,
  }) async {
    if (userId.isEmpty || itemCount <= 0) {
      debugPrint('Invalid parameters for cart reminder');
      return;
    }
    
    await sendNotification(
      userId: userId,
      title: 'Items in Cart',
      message: 'You have $itemCount items waiting in your cart. Complete your order now!',
      type: NotificationType.cartReminder,
      userRole: UserRole.buyer,
    );
  }

  static Future<void> sendNewOrderToSeller({
    required String sellerId,
    required String orderId,
    required double amount,
  }) async {
    if (sellerId.isEmpty || orderId.isEmpty || amount < 0) {
      debugPrint('Invalid parameters for new order to seller');
      return;
    }
    
    await sendNotification(
      userId: sellerId,
      title: 'New Order Received',
      message: 'You have received a new order #$orderId worth UGX ${amount.toStringAsFixed(0)}',
      type: NotificationType.newOrder,
      userRole: UserRole.seller,
      orderId: orderId,
    );
  }

  static Future<void> sendLowStockAlert({
    required String sellerId,
    required String productName,
    required int remainingStock,
  }) async {
    if (sellerId.isEmpty || productName.isEmpty || remainingStock < 0) {
      debugPrint('Invalid parameters for low stock alert');
      return;
    }
    
    await sendNotification(
      userId: sellerId,
      title: 'Low Stock Alert',
      message: '$productName is running low ($remainingStock items remaining)',
      type: NotificationType.lowStock,
      userRole: UserRole.seller,
      additionalData: {'productName': productName, 'remainingStock': remainingStock},
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? orderId;
  final UserRole userRole;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.userRole,
    this.isRead = false,
    this.orderId,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? orderId,
    UserRole? userRole,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      orderId: orderId ?? this.orderId,
      userRole: userRole ?? this.userRole,
    );
  }
}

enum NotificationType {
  orderConfirmed,
  orderPreparing,
  orderReady,
  orderDelivered,
  cartReminder,
  payment,
  general,
  newOrder, // For sellers
  orderCancelled,
  lowStock, // For sellers
  productApproved, // For sellers
}

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';
  final UserRole userRole;
  final String userId;
  
  const NotificationsScreen({
    Key? key,
    required this.userRole,
    required this.userId,
  }) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Stream<List<NotificationModel>> _notificationsStream;
  int _unreadCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeNotificationsStream();
  }

  void _initializeNotificationsStream() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validate required parameters
      if (widget.userId.isEmpty) {
        setState(() {
          _errorMessage = 'User ID is required';
          _isLoading = false;
        });
        return;
      }

      _notificationsStream = NotificationBackendService.getUserNotificationsStream(
        userId: widget.userId,
        userRole: widget.userRole,
      );

      // Listen to stream to update unread count and handle errors
      _notificationsStream.listen(
        (notifications) {
          if (mounted) {
            setState(() {
              _unreadCount = notifications.where((n) => !n.isRead).length;
              _isLoading = false;
              _errorMessage = null;
            });
          }
        },
        onError: (error) {
          debugPrint('Stream error: $error');
          if (mounted) {
            setState(() {
              _errorMessage = 'Failed to load notifications';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Error initializing stream: $e');
      setState(() {
        _errorMessage = 'Failed to initialize notifications';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Update the bottomNavigationBar section to match home_page.dart
bottomNavigationBar: widget.userRole != UserRole.seller
    ? BottomNavBar(
        selectedIndex: -1, // Keep this if you want to highlight no tab
        navBarColor: AppTheme.tertiaryOrange,
      )
    : BottomNavBar2(
        selectedIndex: -1, // Keep this if you want to highlight no tab
        navBarColor: AppTheme.tertiaryOrange,
      ),
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () => _showNotificationOptions(),
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryOrange,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryOrange,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState('Error loading notifications: ${snapshot.error}');
        }

        final notifications = snapshot.data ?? [];
        
        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppTheme.primaryOrange,
          onRefresh: () async {
            _initializeNotificationsStream();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(notification);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Notifications',
              style: AppTheme.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.subtitleStyle.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializeNotificationsStream(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read),
              title: const Text('Mark all as read'),
              onTap: () {
                NotificationBackendService.markAllAsRead(widget.userId);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh'),
              onTap: () {
                _initializeNotificationsStream();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: AppTheme.titleStyle.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            widget.userRole == UserRole.buyer
                ? 'You\'ll see payment updates and cart reminders here'
                : 'You\'ll see new orders and business updates here',
            style: AppTheme.subtitleStyle.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        NotificationBackendService.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? AppTheme.chipBackground.withOpacity(0.8)
              : AppTheme.chipBackground,
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead 
              ? null 
              : Border.all(color: AppTheme.primaryOrange, width: 2),
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTheme.chipTextStyle.copyWith(
                                fontWeight: notification.isRead 
                                    ? FontWeight.w500 
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTheme.subtitleStyle.copyWith(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: AppTheme.subtitleStyle.copyWith(
                              fontSize: 12,
                              color: AppTheme.textSecondary.withOpacity(0.7),
                            ),
                          ),
                          if (notification.orderId != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#${notification.orderId}',
                                style: AppTheme.subtitleStyle.copyWith(
                                  fontSize: 12,
                                  color: AppTheme.primaryOrange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (_shouldShowAction(notification))
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildActionButton(notification),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.orderConfirmed:
        icon = Icons.check_circle;
        color = AppTheme.lightGreen;
        break;
      case NotificationType.orderPreparing:
        icon = Icons.restaurant;
        color = AppTheme.primaryOrange;
        break;
      case NotificationType.orderReady:
        icon = Icons.shopping_bag;
        color = AppTheme.selectedBlue;
        break;
      case NotificationType.orderDelivered:
        icon = Icons.delivery_dining;
        color = AppTheme.lightGreen;
        break;
      case NotificationType.cartReminder:
        icon = Icons.shopping_cart;
        color = AppTheme.coffeeBrown;
        break;
      case NotificationType.payment:
        icon = Icons.payment;
        color = AppTheme.selectedBlue;
        break;
      case NotificationType.general:
        icon = Icons.info;
        color = AppTheme.textSecondary;
        break;
      case NotificationType.newOrder:
        icon = Icons.add_shopping_cart;
        color = AppTheme.lightGreen;
        break;
      case NotificationType.orderCancelled:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case NotificationType.lowStock:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case NotificationType.productApproved:
        icon = Icons.verified;
        color = AppTheme.lightGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  bool _shouldShowAction(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.orderReady:
      case NotificationType.cartReminder:
      case NotificationType.newOrder:
      case NotificationType.lowStock:
      case NotificationType.orderConfirmed:
      case NotificationType.payment:
        return true;
      default:
        return false;
    }
  }

  Widget _buildActionButton(NotificationModel notification) {
    String buttonText;
    VoidCallback onPressed;

    switch (notification.type) {
      case NotificationType.orderReady:
        buttonText = widget.userRole == UserRole.seller ? 'View Order' : 'Track Order';
        onPressed = () => _trackOrder(notification.orderId!);
        break;
      case NotificationType.cartReminder:
        buttonText = 'View Cart';
        onPressed = () => _viewCart();
        break;
      case NotificationType.newOrder:
        buttonText = 'View Order';
        onPressed = () => _viewOrder(notification.orderId!);
        break;
      case NotificationType.lowStock:
        buttonText = 'Manage Stock';
        onPressed = () => _manageStock();
        break;
      case NotificationType.orderConfirmed:
        buttonText = 'Track Order';
        onPressed = () => _trackOrder(notification.orderId!);
        break;
      case NotificationType.payment:
        buttonText = 'View Receipt';
        onPressed = () => _viewReceipt(notification.orderId);
        break;
      default:
        buttonText = 'View';
        onPressed = () => _viewCart();
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    try {
      // Mark notification as read in Firebase
      if (!notification.isRead) {
        NotificationBackendService.markAsRead(notification.id);
      }

      // Handle navigation based on notification type
      switch (notification.type) {
        case NotificationType.orderConfirmed:
        case NotificationType.orderPreparing:
        case NotificationType.orderReady:
        case NotificationType.orderDelivered:
          if (notification.orderId != null) {
            _trackOrder(notification.orderId!);
          }
          break;
        case NotificationType.cartReminder:
          _viewCart();
          break;
        case NotificationType.newOrder:
          if (notification.orderId != null) {
            _viewOrder(notification.orderId!);
          }
          break;
        case NotificationType.productApproved:
          _navigateToProductManagement();
          break;
        case NotificationType.lowStock:
          _manageStock();
          break;
        case NotificationType.payment:
          _viewReceipt(notification.orderId);
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open notification'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Complete navigation methods with proper error handling
    void _navigateToProductManagement() {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerProductManagementScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to product management: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open product management'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _trackOrder(String orderId) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerOrderManagementScreen(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tracking order #$orderId'),
          backgroundColor: AppTheme.deepBlue,
        ),
      );
    } catch (e) {
      debugPrint('Error tracking order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to track order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewCart() {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartPage(userRole: UserRole.buyer),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewOrder(String orderId) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerOrderManagementScreen(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Viewing order #$orderId'),
          backgroundColor: AppTheme.deepBlue,
        ),
      );
    } catch (e) {
      debugPrint('Error viewing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to view order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _manageStock() {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerProductManagementScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to stock management: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open stock management'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewReceipt(String? orderId) {
    try {
      if (orderId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentProcessingScreen(
              cartItems: [], 
              totalAmount: 0.0,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No order ID associated with this notification'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error viewing receipt: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open receipt'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}