// Enhanced NotificationsScreen with proper parameter validation and debugging
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/services/notificaations_service.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar2.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';
  final UserRole? userRole;
  final String? userId;
  
  const NotificationsScreen({
    Key? key,
    this.userRole,
    this.userId,
  }) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Stream<List<NotificationModel>> _notificationsStream;
  int _unreadCount = 0;
  String? _currentUserId;
  UserRole? _currentUserRole;
  bool _isLoading = true;
  String? _debugInfo;
  
  // Add subscription to track and dispose properly
  StreamSubscription<List<NotificationModel>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  @override
  void dispose() {
    // Cancel any active subscriptions to prevent permission errors
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeUserData() async {
    try {
      setState(() {
        _debugInfo = "Initializing user data...";
      });

      // Get userId - prioritize widget parameter, fallback to Firebase Auth
      _currentUserId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
      
      // Debug: Check for placeholder values
      if (_currentUserId == "current_user_id" || _currentUserId == null) {
        _currentUserId = FirebaseAuth.instance.currentUser?.uid;
        debugPrint('Warning: Using placeholder userId, replaced with: $_currentUserId');
      }

      // Get userRole - prioritize widget parameter, fallback to fetching from Firebase
      if (widget.userRole != null) {
        _currentUserRole = widget.userRole;
      } else if (_currentUserId != null) {
        // Fetch user role from Firebase if not provided
        _currentUserRole = await _fetchUserRole(_currentUserId!);
      }

      setState(() {
        _debugInfo = "UserId: $_currentUserId, UserRole: $_currentUserRole";
      });

      // Validate that we have both userId and userRole
      if (_currentUserId == null || _currentUserRole == null) {
        setState(() {
          _isLoading = false;
          _debugInfo = "Missing data - UserId: $_currentUserId, UserRole: $_currentUserRole";
        });
        return;
      }

      // Initialize notifications stream
      _initializeNotificationsStream();
      
      setState(() {
        _isLoading = false;
        _debugInfo = "Initialization complete";
      });
    } catch (e) {
      debugPrint('Error initializing user data: $e');
      setState(() {
        _isLoading = false;
        _debugInfo = "Error: $e";
      });
    }
  }

  Future<UserRole?> _fetchUserRole(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final roleString = data['role'] as String?;
        return roleString == 'buyer' ? UserRole.buyer : UserRole.seller;
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
    return null;
  }

  void _initializeNotificationsStream() {
    if (_currentUserId == null || _currentUserRole == null) return;
    
    debugPrint('Creating notifications stream for userId: $_currentUserId, userRole: $_currentUserRole');
    
    // Cancel existing subscription if any
    _notificationSubscription?.cancel();
    
    _notificationsStream = NotificationService.getUserNotificationsStream(
      userId: _currentUserId!,
      userRole: _currentUserRole!,
    );

    // Listen to stream to update unread count with proper subscription tracking
    _notificationSubscription = _notificationsStream.listen((notifications) {
      debugPrint('Received ${notifications.length} notifications');
      if (mounted) {
        setState(() {
          _unreadCount = notifications.where((n) => !n.isRead).length;
        });
      }
    }, onError: (error) {
      debugPrint('Stream error: $error');
      // Check if error is due to auth state change
      if (error.toString().contains('PERMISSION_DENIED') || 
          error.toString().contains('permission-denied')) {
        // User is likely signed out, cancel subscription
        _notificationSubscription?.cancel();
        if (mounted) {
          setState(() {
            _unreadCount = 0;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: widget.userRole == UserRole.seller
          ? BottomNavBar2(
              selectedIndex: -1,
              navBarColor: AppTheme.tertiaryOrange,
            )
          : BottomNavBar(
              selectedIndex: -1,
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
          if (!_isLoading && _currentUserId != null && _currentUserRole != null)
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.primaryOrange,
            ),
            const SizedBox(height: 16),
            if (_debugInfo != null)
              Text(
                _debugInfo!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      );
    }

    // Show error if user data is missing
    if (_currentUserId == null || _currentUserRole == null) {
      return _buildErrorState();
    }

    // Show notifications
    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationsStream,
      builder: (context, snapshot) {
        // Debug information
        debugPrint('StreamBuilder state: ${snapshot.connectionState}');
        debugPrint('Has data: ${snapshot.hasData}');
        debugPrint('Data length: ${snapshot.data?.length ?? 0}');
        debugPrint('Has error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryOrange,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildStreamErrorState(snapshot.error.toString());
        }

        final notifications = snapshot.data ?? [];
        
        // Debug: Print each notification
        for (var i = 0; i < notifications.length; i++) {
          final notif = notifications[i];
          debugPrint('Notification $i: ${notif.title} - ${notif.message}');
        }

        if (notifications.isEmpty) {
          return _buildEmptyStateWithDebug();
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

  Widget _buildEmptyStateWithDebug() {
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
            _currentUserRole == UserRole.buyer
                ? 'You\'ll see payment updates and cart reminders here'
                : 'You\'ll see new orders and business updates here',
            style: AppTheme.subtitleStyle.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Debug information
          // Container(
          //   padding: const EdgeInsets.all(12),
          //   margin: const EdgeInsets.symmetric(horizontal: 20),
          //   decoration: BoxDecoration(
          //     color: Colors.grey.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
            // child: Column(
            //   children: [
            //     Text(
            //       'Debug Info:',
            //       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            //     ),
            //     const SizedBox(height: 4),
            //     Text(
            //       'User ID: $_currentUserId',
            //       style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
            //     ),
            //     Text(
            //       'User Role: $_currentUserRole',
            //       style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
            //     ),
            //      const SizedBox(height: 8),
            //      ElevatedButton(
            //        onPressed: _testDirectQuery,
            //        child: const Text('Test Direct Query'),
            //      ),
            //   ],
            // ),
          //),
        ],
      ),
    );
  }

  Future<void> _testDirectQuery() async {
    try {
      debugPrint('Testing direct Firestore query...');
      
      // Test direct query to notifications collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .limit(10)
          .get();
      
      debugPrint('Total notifications in collection: ${querySnapshot.docs.length}');
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        debugPrint('Doc ${doc.id}: userId=${data['userId']}, userRole=${data['userRole']}, type=${data['type']}');
      }
      
      // Test specific query for current user
      final userQuery = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: _currentUserId)
          .where('userRole', isEqualTo: _currentUserRole.toString().split('.').last)
          .get();
      
      debugPrint('Notifications for current user: ${userQuery.docs.length}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${userQuery.docs.length} notifications for you'),
          backgroundColor: AppTheme.primaryOrange,
        ),
      );
      
    } catch (e) {
      debugPrint('Test query error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Query error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildErrorState() {
    return Center(
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
          ),
          const SizedBox(height: 8),
          Text(
            _currentUserId == null 
                ? 'User ID is required' 
                : 'User role is required',
            style: AppTheme.subtitleStyle.copyWith(color: Colors.red),
          ),
          if (_debugInfo != null) ...[
            const SizedBox(height: 8),
            Text(
              _debugInfo!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Try to re-authenticate or navigate to login
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
            ),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamErrorState(String error) {
    return Center(
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
            'Error loading notifications',
            style: AppTheme.titleStyle,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTheme.subtitleStyle.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await _initializeUserData();
            },
            child: const Text('Retry'),
          ),
        ],
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
                if (_currentUserId != null && _currentUserRole != null) {
                  NotificationService.markAllAsRead(_currentUserId!, _currentUserRole!);
                }
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
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Debug Info'),
              onTap: () {
                Navigator.pop(context);
                _testDirectQuery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Include all your existing notification item building methods here
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
        NotificationService.deleteNotification(notification.id);
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
                          if (notification.orderId != null && notification.orderId!.isNotEmpty)
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

  // Include all the rest of your existing methods here...
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
    case NotificationType.chatMessage:
      icon = Icons.chat_bubble;
      color = AppTheme.selectedBlue; // Fixed: changed from colon (:) to equals (=)
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
      case NotificationType.chatMessage:
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
        buttonText = _currentUserRole == UserRole.seller ? 'View Order' : 'Track Order';
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
      case NotificationType.chatMessage:
        buttonText = 'Open Chat';
        onPressed = () => _openChat(notification.additionalData);
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
    // Mark notification as read in Firebase
    if (!notification.isRead) {
      NotificationService.markAsRead(notification.id);
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
      case NotificationType.chatMessage:
        _openChat(notification.additionalData);
        break;
      default:
        break;
    }
  }

  void _navigateToProductManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Product Management'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }

  void _trackOrder(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tracking order #$orderId'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }

  void _viewCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Cart'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }

  void _viewOrder(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing order #$orderId'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }

  void _manageStock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Stock Management'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }

  void _viewReceipt(String? orderId) {
    if (orderId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Viewing receipt for order #$orderId'),
          backgroundColor: AppTheme.deepBlue,
        ),
      );
    }
  }

  void _openChat(Map<String, dynamic> chatData) {
    final chatRoomId = chatData['chatRoomId'];
    final productName = chatData['productName'];
    final senderName = chatData['senderName'];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with $senderName'),
        backgroundColor: AppTheme.deepBlue,
      ),
    );
  }
}