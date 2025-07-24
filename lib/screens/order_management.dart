// order_management.dart - Updated with services integration
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import '../Theme/app_theme.dart';
import '../widgets/logo_widget.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/seller_service.dart';

class SellerOrderManagementScreen extends StatefulWidget {
  static const String routeName = '/SellerOrderManagement';

  const SellerOrderManagementScreen({super.key});

  @override
  State<SellerOrderManagementScreen> createState() => _SellerOrderManagementScreenState();
}

class _SellerOrderManagementScreenState extends State<SellerOrderManagementScreen> {
  int _selectedTab = 0; // 0: Pending, 1: Processing, 2: Completed
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
      if (_sellerId == null) {
        setState(() {
          _error = 'No seller found. Please login again.';
          _isLoading = false;
        });
        return;
      }

      await _loadOrders();
    } catch (e) {
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

      final orders = await OrderService.getOrdersBySellerId(_sellerId!);
      
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Order> _getFilteredOrders() {
    switch (_selectedTab) {
      case 0:
        return _orders.where((order) => order.status == OrderStatus.pending).toList();
      case 1:
        return _orders.where((order) => order.status == OrderStatus.processing).toList();
      case 2:
        return _orders.where((order) => order.status == OrderStatus.completed).toList();
      default:
        return [];
    }
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    try {
      await OrderService.updateOrderStatus(order.id, newStatus);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.id} updated successfully'),
          backgroundColor: AppTheme.lightGreen,
        ),
      );
      
      // Reload orders to reflect changes
      await _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: ${e.toString()}'),
          backgroundColor: Colors.red,
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
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsScreen(userRole: UserRole.seller, userId: '',),
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
    final count = index == _selectedTab ? filteredOrders.length : 
                  _orders.where((order) => {
                    0: OrderStatus.pending,
                    1: OrderStatus.processing,
                    2: OrderStatus.completed,
                  }[index] == order.status).length;

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
            color: _selectedTab == index ? AppTheme.primaryOrange : Colors.transparent,
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
                    color: _selectedTab == index ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
                if (!_isLoading)
                  Text(
                    '($count)',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedTab == index ? Colors.white70 : AppTheme.textSecondary,
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
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
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
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
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Phone: ${order.phone}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
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
              if (_canUpdateStatus(order.status))
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () => _handleOrderAction(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getActionButtonColor(order.status),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }

  bool _canUpdateStatus(OrderStatus status) {
    return status == OrderStatus.pending || status == OrderStatus.processing;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.primaryOrange;
      case OrderStatus.processing:
        return AppTheme.selectedBlue;
      case OrderStatus.completed:
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

  void _handleOrderAction(Order order) {
    OrderStatus newStatus;
    switch (order.status) {
      case OrderStatus.pending:
        newStatus = OrderStatus.processing;
        break;
      case OrderStatus.processing:
        newStatus = OrderStatus.completed;
        break;
      default:
        return;
    }

    _updateOrderStatus(order, newStatus);
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
      default:
        return '';
    }
  }
}