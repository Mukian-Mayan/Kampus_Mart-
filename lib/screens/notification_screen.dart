// ignore_for_file: deprecated_member_use, use_super_parameters

import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/cart_page.dart';
import 'package:kampusmart2/screens/home_page.dart';
import 'package:kampusmart2/screens/settings_page.dart';
import 'package:kampusmart2/screens/user_profile_page.dart';
import '../screens/Product_management.dart';
import '../screens/order_management.dart';
import '../Theme/app_theme.dart';

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
  
  const NotificationsScreen({
    Key? key,
    required this.userRole,
  }) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> get notifications {
    if (widget.userRole == UserRole.buyer) {
      return _buyerNotifications;
    } else {
      return _sellerNotifications;
    }
  }

  final List<NotificationModel> _buyerNotifications = [
    
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

  final List<NotificationModel> _sellerNotifications = [
    NotificationModel(
      id: '6',
      title: 'Order Being Prepared',
      message: 'Your order #1234 is now being prepared by our baristas',
      type: NotificationType.orderPreparing,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      orderId: '1234',
      userRole: UserRole.buyer,
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
    NotificationModel(
      id: '11',
      title: 'Order Ready',
      message: 'Order #1234 is ready for customer pickup',
      type: NotificationType.orderReady,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      orderId: '1234',
      userRole: UserRole.seller,
    ),
    NotificationModel(
      id: '12',
      title: 'Payment Received',
      message: 'Payment of UGX 28,000 received for order #1232',
      type: NotificationType.payment,
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      orderId: '1232',
      userRole: UserRole.seller,
    ),
    NotificationModel(
      id: '4',
      title: 'Order Delivered',
      message: 'Your order #1228 has been delivered successfully',
      type: NotificationType.orderDelivered,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      orderId: '1228',
      isRead: true,
      userRole: UserRole.seller,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryOrange,
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.userRole == UserRole.buyer ? 'Buyer' : 'Seller'} Notifications',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
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
      bottomNavigationBar: _buildBottomNavigation(),
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
                ? 'You\'ll see order updates and promotions here'
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
        buttonText = widget.userRole == UserRole.seller ? 'Track order' : 'Mark Ready';
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
        buttonText = 'Order confirmed';
        onPressed = () => _trackOrder(notification.orderId!);
        break;
      default:
        buttonText = 'View';
        onPressed = () {};
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

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.deepBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.settings, false, _navigateToSettings),
          _buildNavItem(Icons.shopping_cart, false, _navigateToCart),
          _buildNavItem(Icons.home, false, _navigateToHome),
          _buildNavItem(Icons.receipt, false, _navigateToOrders),
          _buildNavItem(Icons.person, false, _navigateToProfile),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryOrange : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
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
    setState(() {
      final index = notifications.indexOf(notification);
      if (widget.userRole == UserRole.seller) {
        _buyerNotifications[index] = NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          timestamp: notification.timestamp,
          isRead: true,
          orderId: notification.orderId,
          userRole: notification.userRole,
        );
      } else {
        _sellerNotifications[index] = NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          timestamp: notification.timestamp,
          isRead: true,
          orderId: notification.orderId,
          userRole: notification.userRole,
        );
      }
    });

    // Handle navigation based on notification type
    switch (notification.type) {
      case NotificationType.orderPreparing:
      case NotificationType.orderReady:
      case NotificationType.orderDelivered:
        _navigateToOrderDetails(notification.orderId!);
        break;
      case NotificationType.cartReminder:
        _viewCart();
        break;

      case NotificationType.productApproved:
        _navigateToProductManagement();
        break;
      default:
        break;
    }
  }

  void _navigateToOrderDetails(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerOrderManagementScreen(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to order #$orderId details'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
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
    _viewCart();
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening cart'),
        backgroundColor: AppTheme.deepBlue,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Managing stock'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }

  // Navigation methods for bottom navigation bar
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Settings'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Cart'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }

  void _navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Home'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }

  void _navigateToOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Orders'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Profile'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }
}