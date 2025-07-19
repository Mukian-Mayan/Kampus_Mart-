// ignore_for_file: deprecated_member_use, use_super_parameters, prefer_final_fields, unreachable_switch_case

import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/payment_processing.dart';
import '../screens/Product_management.dart';
import '../screens/order_management.dart';
import '../Theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/cart_page.dart';

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

enum UserRole {
  buyer,
  seller,
}

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';
  final UserRole userRole;
  
  // BUYER NOTIFICATIONS - Only payment and cart related
  static List<NotificationModel> buyerNotifications = [
    NotificationModel(
      id: '3',
      title: 'Items in Cart',
      message: 'You have 3 items waiting in your cart. Complete your order now!',
      type: NotificationType.cartReminder,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      userRole: UserRole.buyer,
    ),
    NotificationModel(
      id: '5',
      title: 'Payment Successful',
      message: 'Payment of UGX 45,000 for order #1234 was successful',
      type: NotificationType.payment,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      orderId: '1234',
      userRole: UserRole.buyer,
    ),
  ];

  const NotificationsScreen({
    Key? key,
    required this.userRole,
  }) : super(key: key);

  // Static method to add a notification to the buyer notifications list
  static void addBuyerNotification(NotificationModel notification) {
    NotificationsScreen.buyerNotifications.insert(0, notification);
  }

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> get notifications {
    if (widget.userRole == UserRole.buyer) {
      return NotificationsScreen.buyerNotifications.where((n) => 
        n.type == NotificationType.payment || 
        n.type == NotificationType.cartReminder
      ).toList();
    } else {
      return _sellerNotifications.where((n) =>
        n.type != NotificationType.payment &&
        n.type != NotificationType.cartReminder
      ).toList();
    }
  }

  // SELLER NOTIFICATIONS - Business related
  List<NotificationModel> _sellerNotifications = [
    NotificationModel(
      id: '1',
      title: 'Order Confirmed',
      message: 'Order #1234 has been confirmed and is being prepared',
      type: NotificationType.orderConfirmed,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      orderId: '1234',
      userRole: UserRole.seller,
    ),
    NotificationModel(
      id: '2',
      title: 'Order Being Prepared',
      message: 'Order #1234 is now being prepared',
      type: NotificationType.orderPreparing,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      orderId: '1234',
      userRole: UserRole.seller,
    ),
    NotificationModel(
      id: '4',
      title: 'Order Ready',
      message: 'Order #1234 is ready for pickup',
      type: NotificationType.orderReady,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      orderId: '1234',
      userRole: UserRole.seller,
    ),
    NotificationModel(
      id: '6',
      title: 'Order Delivered',
      message: 'Order #1228 has been delivered successfully',
      type: NotificationType.orderDelivered,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      orderId: '1228',
      isRead: true,
      userRole: UserRole.seller,
    ),
    NotificationModel(
      id: '7',
      title: 'New Order Received',
      message: 'You have received a new order #1235 worth UGX 35,000',
      type: NotificationType.newOrder,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      orderId: '1235',
      userRole: UserRole.seller,
    ),
    NotificationModel(
      id: '8',
      title: 'Order Cancelled',
      message: 'Order #1233 has been cancelled by the customer',
      type: NotificationType.orderCancelled,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      orderId: '1233',
      userRole: UserRole.seller,
      isRead: true,
    ),
    NotificationModel(
      id: '9',
      title: 'Low Stock Alert',
      message: 'Tables are running low (5 items remaining)',
      type: NotificationType.lowStock,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      userRole: UserRole.seller,
    ),
    NotificationModel(
      id: '10',
      title: 'Product Approved',
      message: 'Your new product "Iced Latte" has been approved and is now live',
      type: NotificationType.productApproved,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      userRole: UserRole.seller,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(notification);
              },
            ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: -1, navBarColor: AppTheme.tertiaryOrange ,// No specific tab selected for notifications
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
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: AppTheme.titleStyle.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            widget.userRole == UserRole.buyer
                ? 'You\'ll see payment updates and cart reminders here'
                : 'You\'ll see new orders and business updates here',
            style: AppTheme.subtitleStyle.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
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
      case NotificationType.orderConfirmed:
        buttonText = 'Track Order';
        onPressed = () =>  PaymentProcessingScreen(cartItems: [], totalAmount: 0.0,);
        break;
      default:
        buttonText = 'View';
        onPressed = () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder:(context)=> const CartPage(),),);
          
        };
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
    // Mark notification as read
    setState(() {
      final index = notifications.indexOf(notification);
      if (index != -1) {
        if (widget.userRole == UserRole.buyer) {
          NotificationsScreen.buyerNotifications[index] = notification.copyWith(isRead: true);
        } else {
          _sellerNotifications[index] = notification.copyWith(isRead: true);
        }
      }
    });

    // Handle navigation based on notification type
    switch (notification.type) {
      case NotificationType.orderConfirmed:
      case NotificationType.orderPreparing:
      case NotificationType.orderReady:
      case NotificationType.orderDelivered:
        _trackOrder(notification.orderId!);
        break;
      case NotificationType.cartReminder:
        _viewCart();
        break;
      case NotificationType.newOrder:
        _viewOrder(notification.orderId!);
        break;
      case NotificationType.productApproved:
        _navigateToProductManagement();
        break;
      case NotificationType.lowStock:
        _manageStock();
        break;
      default:
        break;
    }
  }

  void _navigateToProductManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerProductManagementScreen(),
      ),
    );
  }

  void _trackOrder(String orderId) {
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
  }

  void _viewCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(),
      ),
    );
  }

  void _viewOrder(String orderId) {
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
  }

  void _manageStock() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerProductManagementScreen(),
      ),
    );
  }
  
}