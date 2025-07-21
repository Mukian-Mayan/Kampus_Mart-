// sellers_dashboard.dart - Updated with services integration
// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/Product_management.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/screens/order_management.dart';
import '../Theme/app_theme.dart';
import '../widgets/profile_pic_widget.dart';
import '../widgets/logo_widget.dart';
import '../models/seller.dart';
import '../services/seller_service.dart';
import 'seller_add_product.dart';
import 'seller_sales_tracking.dart';

class SellerDashboardScreen extends StatefulWidget {
  static const String routeName = '/SellerDashboard';

  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  Seller? seller;
  Map<String, dynamic>? dashboardStats;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSellerData();
  }

  Future<void> _loadSellerData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Get current seller
      final currentSeller = await SellerService.getCurrentSeller();
      if (currentSeller == null) {
        setState(() {
          error = 'No seller found. Please login again.';
          isLoading = false;
        });
        return;
      }

      // Get dashboard stats
      final stats = await SellerService.getSellerDashboardStats(
        currentSeller.id,
      );

      setState(() {
        seller = currentSeller;
        dashboardStats = stats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load seller data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadSellerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationsScreen(userRole: UserRole.seller),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (seller == null) {
      return const Center(
        child: Text(
          'No seller data available',
          style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Seller Profile Section
            _buildProfileSection(),

            // Quick Stats Cards
            _buildStatsSection(),

            const SizedBox(height: 30),

            // Main Action Section
            _buildActionSection(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          ProfilePicWidget(
            imageUrl: seller!.profileImageUrl,
            onAddPressed: () {
              // Handle profile picture change
              _handleProfilePictureChange();
            },
            radius: 30,
            height: 60,
            width: 60,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller!.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  seller!.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: seller!.isVerified
                        ? AppTheme.lightGreen
                        : AppTheme.textSecondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    seller!.isVerified ? 'Verified Seller' : 'Unverified',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = seller!.stats;
    final orderStats = dashboardStats?['orderStats'] ?? {};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Products',
              stats.totalProducts.toString(),
              Icons.inventory_2,
              AppTheme.selectedBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Orders',
              stats.totalOrders.toString(),
              Icons.receipt_long,
              AppTheme.lightGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Revenue',
              'UGX ${(stats.totalRevenue / 1000).toStringAsFixed(0)}K',
              Icons.attach_money,
              AppTheme.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.paleWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Business Info
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.tertiaryOrange,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.tertiaryOrange.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.store_mall_directory,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            seller!.businessName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            seller!.businessDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 30),

          // Dashboard Actions
          _buildDashboardButton(
            context,
            'Add New Product',
            Icons.add_box,
            AppTheme.coffeeBrown,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SellerAddProductScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDashboardButton(
            context,
            'Sales Analytics',
            Icons.analytics,
            AppTheme.selectedBlue,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SellerSalesTrackingScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDashboardButton(
            context,
            'Manage Products',
            Icons.inventory,
            AppTheme.lightGreen,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SellerProductManagementScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDashboardButton(
            context,
            'Order Management',
            Icons.receipt_long,
            AppTheme.textSecondary,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SellerOrderManagementScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.paleWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _handleProfilePictureChange() {
    // Implement profile picture change logic
    // This would typically involve image picker and updating through SellerService
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture update feature coming soon'),
      ),
    );
  }
}
