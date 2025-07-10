// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import '../Theme/app_theme.dart';
import '../widgets/logo_widget.dart';

class SellerOrderManagementScreen extends StatefulWidget {
  static const String routeName = '/SellerOrderManagement';

  const SellerOrderManagementScreen({super.key});

  @override
  State<SellerOrderManagementScreen> createState() => _SellerOrderManagementScreenState();
}

class _SellerOrderManagementScreenState extends State<SellerOrderManagementScreen> {
  int _selectedTab = 0; // 0: New, 1: Pending, 2: Solved

  // Mock order data
  final List<Map<String, dynamic>> newOrders = [
    {
      'id': '#KM-1001',
      'customer': 'Eron Nambirige',
      'items': 3,
      'amount': 45000,
      'time': '10 mins ago',
    },
    {
      'id': '#KM-1002',
      'customer': 'Malual Martin',
      'items': 5,
      'amount': 78000,
      'time': '25 mins ago',
    },
  ];

  final List<Map<String, dynamic>> pendingOrders = [
    {
      'id': '#KM-0998',
      'customer': 'Moen',
      'items': 2,
      'amount': 32000,
      'time': '2 hours ago',
    },
  ];

  final List<Map<String, dynamic>> solvedOrders = [
    {
      'id': '#KM-0995',
      'customer': 'Jollyne Flavia',
      'items': 4,
      'amount': 65000,
      'time': 'Yesterday',
    },
    {
      'id': '#KM-0996',
      'customer': 'Michael Francis',
      'items': 1,
      'amount': 15000,
      'time': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(selectedIndex: 1),
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        title: const LogoWidget(),
        backgroundColor: AppTheme.tertiaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
            onPressed: () =>Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsScreen(userRole: UserRole.seller),
              ),),
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
                _buildOrderTab('New', 0),
                _buildOrderTab('Pending', 1),
                _buildOrderTab('Solved', 2),
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
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _selectedTab == index ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    List<Map<String, dynamic>> currentOrders = [];
    
    if (_selectedTab == 0) {
      currentOrders = newOrders;
    } else if (_selectedTab == 1) {
      currentOrders = pendingOrders;
    } else {
      currentOrders = solvedOrders;
    }

    if (currentOrders.isEmpty) {
      return Center(
        child: Text(
          'No ${_getOrderStatusText()} orders',
          style: const TextStyle(
            fontSize: 18,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: currentOrders.length,
      itemBuilder: (context, index) {
        final order = currentOrders[index];
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
                    order['id'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    order['time'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Customer: ${order['customer']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order['items']} item${order['items'] > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    'UGX ${order['amount']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_selectedTab != 2) const SizedBox(height: 12),
              if (_selectedTab != 2)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle order action
                      if (_selectedTab == 0) {
                        // Accept new order
                        setState(() {
                          newOrders.removeAt(index);
                          pendingOrders.add(order);
                        });
                      } else {
                        // Mark as solved
                        setState(() {
                          pendingOrders.removeAt(index);
                          solvedOrders.add(order);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 0 ? AppTheme.lightGreen : AppTheme.selectedBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      _selectedTab == 0 ? 'Accept Order' : 'Mark as Solved',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getOrderStatusText() {
    switch (_selectedTab) {
      case 0:
        return 'new';
      case 1:
        return 'pending';
      case 2:
        return 'solved';
      default:
        return '';
    }
  }
}