// order_management.dart - Updated with services integration
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import '../Theme/app_theme.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/seller_service.dart';

class SellerOrderManagementScreen extends StatefulWidget {
  static const String routeName = '/SellerOrderManagement';

  const SellerOrderManagementScreen({super.key});

  @override
  State<SellerOrderManagementScreen> createState() =>
      _SellerOrderManagementScreenState();
}

class _SellerOrderManagementScreenState
    extends State<SellerOrderManagementScreen> {
  int _selectedTab = 0; // 0: Pending, 1: Processing, 2: Completed, 3: Cancelled
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  String? _sellerId;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadOrders();
  }

  Future<void> _initializeAndLoadOrders() async {
    try {
      // Get current seller ID
      _sellerId = SellerService.getCurrentUserId();
      print('🏪 Current seller ID: $_sellerId');

      if (_sellerId == null) {
        print('❌ No seller ID found');
        setState(() {
          _error = 'No seller found. Please login again.';
          _isLoading = false;
        });
        return;
      }

      await _loadOrders();
    } catch (e) {
      print('❌ Error in _initializeAndLoadOrders: $e');
      setState(() {
        _error = 'Failed to initialize: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('📱 Loading orders for seller: $_sellerId');
      final orders = await OrderService.getOrdersBySellerId(_sellerId!);
      print('📦 Loaded ${orders.length} orders in order management screen');

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading orders in order management: $e');
      setState(() {
        _error = 'Failed to load orders: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Order> _getFilteredOrders() {
    switch (_selectedTab) {
      case 0:
        return _orders
            .where((order) => order.status == OrderStatus.pending)
            .toList();
      case 1:
        return _orders
            .where((order) => order.status == OrderStatus.processing)
            .toList();
      case 2:
        return _orders
            .where((order) => order.status == OrderStatus.completed)
            .toList();
      case 3:
        return _orders
            .where((order) => order.status == OrderStatus.cancelled)
            .toList();
      default:
        return [];
    }
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Updating order...'),
            ],
          ),
        ),
      );

      await OrderService.updateOrderStatus(order.id, newStatus);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message with specific status
      String statusMessage;
      switch (newStatus) {
        case OrderStatus.processing:
          statusMessage = 'Order accepted and moved to processing';
          break;
        case OrderStatus.completed:
          statusMessage = 'Order marked as completed';
          break;
        case OrderStatus.cancelled:
          statusMessage = 'Order cancelled successfully';
          break;
        default:
          statusMessage = 'Order status updated successfully';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusMessage),
          backgroundColor: newStatus == OrderStatus.cancelled
              ? Colors.red
              : AppTheme.lightGreen,
          duration: const Duration(seconds: 3),
        ),
      );

      // Reload orders to reflect changes
      await _loadOrders();
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        navBarColor: AppTheme.tertiaryOrange,
      ),
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        //title: const LogoWidget(),
        backgroundColor: AppTheme.tertiaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationsScreen(userRole: UserRole.seller, userId: ''),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Order Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.paleWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildOrderTab('Pending', 0),
                _buildOrderTab('Processing', 1),
                _buildOrderTab('Completed', 2),
                _buildOrderTab('Cancelled', 3),
              ],
            ),
          ),

          // Order List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.paleWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildOrderList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOrderTab(String title, int index) {
    final filteredOrders = _getFilteredOrders();
    final count = index == _selectedTab
        ? filteredOrders.length
        : _orders
              .where(
                (order) =>
                    {
                      0: OrderStatus.pending,
                      1: OrderStatus.processing,
                      2: OrderStatus.completed,
                    }[index] ==
                    order.status,
              )
              .length;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _selectedTab == index
                ? AppTheme.primaryOrange
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _selectedTab == index
                        ? Colors.white
                        : AppTheme.textSecondary,
                  ),
                ),
                if (!_isLoading)
                  Text(
                    '($count)',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedTab == index
                          ? Colors.white70
                          : AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
          ],
        ),
      );
    }

    final filteredOrders = _getFilteredOrders();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_getOrderStatusText()} orders',
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id.substring(0, 8)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                _formatTime(order.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Customer: ${order.name}',
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Phone: ${order.phone}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                'UGX ${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Payment Information
          Row(
            children: [
              Icon(
                _getPaymentIcon(order.paymentMethod ?? 'Cash on Delivery'),
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Payment: ${order.paymentMethod ?? 'Cash on Delivery'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(
                    order.paymentStatus,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getPaymentStatusText(order.paymentStatus),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getPaymentStatusColor(order.paymentStatus),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${order.notes}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(order.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (_canUpdateStatus(order.status) ||
                  _canCancelOrder(order.status))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_canCancelOrder(order.status))
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => _showCancelOrderDialog(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (_canUpdateStatus(order.status) &&
                        _canCancelOrder(order.status))
                      const SizedBox(width: 8),
                    if (_canUpdateStatus(order.status))
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => _showStatusUpdateDialog(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getActionButtonColor(
                              order.status,
                            ),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: Text(
                            _getActionButtonText(order.status),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canUpdateStatus(OrderStatus status) {
    return status == OrderStatus.pending || status == OrderStatus.processing;
  }

  bool _canCancelOrder(OrderStatus status) {
    return status == OrderStatus.pending;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.primaryOrange;
      case OrderStatus.accepted:
      case OrderStatus.processing:
        return AppTheme.selectedBlue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.completed:
      case OrderStatus.delivered:
        return AppTheme.lightGreen;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }

  Color _getActionButtonColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.lightGreen;
      case OrderStatus.processing:
        return AppTheme.selectedBlue;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getActionButtonText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Accept Order';
      case OrderStatus.processing:
        return 'Mark Complete';
      default:
        return 'Update';
    }
  }

  void _showStatusUpdateDialog(Order order) {
    String actionText;
    String confirmText;
    OrderStatus newStatus;

    switch (order.status) {
      case OrderStatus.pending:
        actionText = 'Accept Order';
        confirmText =
            'Are you sure you want to accept this order? This will move it to processing.';
        newStatus = OrderStatus.processing;
        break;
      case OrderStatus.processing:
        actionText = 'Mark Complete';
        confirmText = 'Are you sure you want to mark this order as completed?';
        newStatus = OrderStatus.completed;
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(actionText),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(confirmText),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Customer: ${order.name}'),
                    Text('Amount: UGX ${order.totalAmount.toStringAsFixed(0)}'),
                    Text('Items: ${order.items.length}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateOrderStatus(order, newStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getActionButtonColor(order.status),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(actionText),
            ),
          ],
        );
      },
    );
  }

  void _showCancelOrderDialog(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Cancel Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to cancel this order? This action cannot be undone.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Customer: ${order.name}'),
                    Text('Amount: UGX ${order.totalAmount.toStringAsFixed(0)}'),
                    Text('Items: ${order.items.length}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Order'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateOrderStatus(order, OrderStatus.cancelled);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel Order',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _getOrderStatusText() {
    switch (_selectedTab) {
      case 0:
        return 'pending';
      case 1:
        return 'processing';
      case 2:
        return 'completed';
      case 3:
        return 'cancelled';
      default:
        return '';
    }
  }

  // Payment-related helper methods
  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'mobile money':
        return Icons.phone_android;
      case 'bank transfer':
        return Icons.account_balance;
      case 'card payment':
        return Icons.credit_card;
      case 'cash on delivery':
      default:
        return Icons.money;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}
