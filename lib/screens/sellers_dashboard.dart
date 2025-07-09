// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/Product_management.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/screens/order_management.dart';
import '../Theme/app_theme.dart';
import '../widgets/profile_pic_widget.dart';
import '../widgets/logo_widget.dart';
import 'seller_add_product.dart';
import 'seller_sales_tracking.dart';

class SellerDashboardScreen extends StatefulWidget {
  static const String routeName = '/SellerDashboard';

  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  // Mock seller data
  final String sellerName = "Samara Sandra";
  final String sellerEmail = "samara.seller@kmart.com";
  final String? sellerProfilePic = null; // Can be null for default
  final int totalProducts = 24;
  final int totalSales = 156;
  final double todaysRevenue = 450000.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        title: const LogoWidget(), // Using LogoWidget here
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
              ),
            ),
            
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Seller Profile Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ProfilePicWidget(
                    imageUrl: sellerProfilePic,
                    onAddPressed: () {
                      // Handle profile picture change
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
                          sellerName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sellerEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Verified Seller',
                            style: TextStyle(
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
            ),

            // Quick Stats Cards
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Products',
                      totalProducts.toString(),
                      Icons.inventory_2,
                      AppTheme.selectedBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Sales',
                      totalSales.toString(),
                      Icons.trending_up,
                      AppTheme.lightGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Revenue',
                      'UGX ${(todaysRevenue / 1000).toStringAsFixed(0)}K',
                      Icons.attach_money,
                      AppTheme.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Main Action Section
            Container(
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
                  // Kmart Logo
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
                  
                  const Text(
                    'Manage Your Store',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add products, track sales, and grow your business',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
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
                    ()=> Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context)=> const SellerProductManagementScreen(),
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
                        builder: (context)=> const SellerOrderManagementScreen(),
                        ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}