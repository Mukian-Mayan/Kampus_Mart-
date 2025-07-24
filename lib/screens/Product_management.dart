// ignore_for_file: deprecated_member_use, file_names, use_super_parameters, unused_element

import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/screens/seller_add_product.dart';
import 'package:kampusmart2/services/product_service.dart';
import 'package:kampusmart2/models/product.dart';
import '../Theme/app_theme.dart';
import '../widgets/logo_widget.dart';

class SellerEditProductScreen extends StatelessWidget {
  final Product product;

  const SellerEditProductScreen({Key? key, required this.product})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${product.name}'),
        backgroundColor: AppTheme.tertiaryOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Product Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 20),
              // Implement your edit form fields here
              // This is a placeholder - replace with actual form fields
              Text('Product Name: ${product.name}'),
              Text('Price: ${product.price}'),
              // Add more fields as needed
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Save changes and return to previous screen
                  Navigator.pop(context, true);
                },
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SellerProductManagementScreen extends StatefulWidget {
  static const String routeName = '/SellerProductManagement';

  const SellerProductManagementScreen({super.key});

  @override
  State<SellerProductManagementScreen> createState() =>
      _SellerProductManagementScreenState();
}

class _SellerProductManagementScreenState
    extends State<SellerProductManagementScreen> {
  String _selectedFilterCategory = 'All';
  double _priceFilterRange = 200000;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      final products = await ProductService.getProductsBySeller(user.uid);

      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _error = 'Failed to load products: ${e.toString()}';
        _isLoading = false;
      });
      print('Error loading products: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesCategory =
            _selectedFilterCategory == 'All' ||
            (product.category != null &&
                product.category == _selectedFilterCategory);

        double productPrice = _extractPrice(product);
        final matchesPrice = productPrice <= _priceFilterRange;

        final matchesSearch =
            _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        return matchesCategory && matchesPrice && matchesSearch;
      }).toList();
    });
  }

  double _extractPrice(Product product) {
    if (product.price != null && product.price! > 0) {
      return product.price!;
    }

    if (product.originalPrice.isNotEmpty) {
      try {
        final priceStr = product.originalPrice
            .replaceAll('UGX', '')
            .replaceAll(',', '')
            .replaceAll(RegExp(r'[^0-9.]'), '');
        final price = double.tryParse(priceStr);
        if (price != null && price > 0) return price;
      } catch (e) {}
    }

    try {
      final priceStr = product.priceAndDiscount
          .replaceAll('UGX', '')
          .replaceAll(',', '')
          .replaceAll(RegExp(r'[^0-9.]'), '');
      final price = double.tryParse(priceStr);
      return price ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> _decrementSellerProductCount(String sellerId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final sellerRef = firestore.collection('sellers').doc(sellerId);

      await firestore.runTransaction((transaction) async {
        final sellerDoc = await transaction.get(sellerRef);

        if (sellerDoc.exists) {
          final currentStats =
              sellerDoc.data()?['stats'] as Map<String, dynamic>? ?? {};
          final currentCount =
              (currentStats['totalProducts'] as num?)?.toInt() ?? 0;

          // Ensure count doesn't go below 0
          final newCount = math.max(0, currentCount - 1);

          final updatedStats = {...currentStats, 'totalProducts': newCount};

          transaction.update(sellerRef, {
            'stats': updatedStats,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      print('Seller product count decremented successfully');
    } catch (e) {
      print('Error decrementing product count: $e');
      // Don't throw error here to avoid breaking the delete operation
    }
  }

  Future<void> _fixProductCount() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text('Fixing product count...')),
            ],
          ),
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ProductService.recalculateSellerProductCount(user.uid);
      }

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product count has been fixed successfully!'),
            backgroundColor: AppTheme.lightGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fix product count: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error fixing product count: $e');
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text('Deleting product...')),
            ],
          ),
        ),
      );

      await ProductService.deleteProduct(product.id);

      // Note: ProductService.deleteProduct already handles seller count decrement

      if (mounted) Navigator.of(context).pop();

      setState(() {
        _allProducts.removeWhere((p) => p.id == product.id);
        _applyFilters();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} deleted successfully'),
            backgroundColor: AppTheme.lightGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error deleting product: $e');
    }
  }

  List<String> _getAvailableCategories() {
    final categories = <String>{'All'};
    for (final product in _allProducts) {
      if (product.category != null && product.category!.isNotEmpty) {
        categories.add(product.category!);
      }
    }
    return categories.toList()..sort();
  }

  String _formatPrice(Product product) {
    double price = _extractPrice(product);
    if (price > 0) {
      return 'UGX ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }

    if (product.originalPrice.isNotEmpty &&
        !product.originalPrice.contains('100%')) {
      return product.originalPrice;
    }

    if (product.priceAndDiscount.isNotEmpty &&
        !product.priceAndDiscount.contains('100%')) {
      return product.priceAndDiscount;
    }

    return 'Price not set';
  }

  int _getStock(Product product) {
    return product.stock ?? 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const NotificationsScreen(userRole: UserRole.seller),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.textPrimary),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerAddProductScreen(),
                ),
              );

              if (result == true) {
                await _loadProducts();
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onSelected: (value) async {
              switch (value) {
                case 'refresh':
                  await _loadProducts();
                  break;
                case 'fix_count':
                  await _fixProductCount();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 16),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'fix_count',
                child: Row(
                  children: [
                    Icon(Icons.auto_fix_high, size: 16),
                    SizedBox(width: 8),
                    Text('Fix Product Count'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppTheme.paleWhite,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.paleWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterOptions(context),
                  ),
                ),
              ],
            ),
          ),

          if (_selectedFilterCategory != 'All' ||
              _priceFilterRange < 200000 ||
              _searchQuery.isNotEmpty)
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedFilterCategory != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(
                            _selectedFilterCategory,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: AppTheme.chipBackground,
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedFilterCategory = 'All';
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    if (_priceFilterRange < 200000)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(
                            'Under UGX ${_priceFilterRange.round()}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: AppTheme.chipBackground,
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _priceFilterRange = 200000;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    if (_searchQuery.isNotEmpty)
                      Chip(
                        label: Text(
                          'Search: $_searchQuery',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppTheme.chipBackground,
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                          _applyFilters();
                        },
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.paleWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildProductList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your products...',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
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
                onPressed: _loadProducts,
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

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _allProducts.isEmpty ? Icons.inventory : Icons.search_off,
                size: 60,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _allProducts.isEmpty ? 'No products yet' : 'No products found',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _allProducts.isEmpty
                    ? 'Start by adding your first product'
                    : 'Try adjusting your filters or search',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.borderGrey.withOpacity(0.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image,
                                  color: AppTheme.textSecondary,
                                );
                              },
                            )
                          : const Icon(
                              Icons.image,
                              color: AppTheme.textSecondary,
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.category != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            product.category!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(product),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  SizedBox(
                    width: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_getStock(product)} in stock',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.lightGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'details':
                          _showProductDetails(context, product);
                          break;
                        case 'edit':
                          _editProduct(product);
                          break;
                        case 'delete':
                          await _deleteProduct(product);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info, size: 16),
                            SizedBox(width: 8),
                            Text('Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerEditProductScreen(product: product),
      ),
    );

    if (result == true) {
      await _loadProducts();
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.paleWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.borderGrey,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const Text(
                    'Filter Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _getAvailableCategories().map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _selectedFilterCategory == category,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedFilterCategory = category;
                              });
                            },
                            selectedColor: AppTheme.tertiaryOrange,
                            labelStyle: TextStyle(
                              color: _selectedFilterCategory == category
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _priceFilterRange,
                    min: 0,
                    max: 500000,
                    divisions: 25,
                    label: 'UGX ${_priceFilterRange.round()}',
                    onChanged: (value) {
                      setModalState(() {
                        _priceFilterRange = value;
                      });
                    },
                    activeColor: AppTheme.tertiaryOrange,
                    inactiveColor: AppTheme.borderGrey,
                  ),
                  Text(
                    'Max: UGX ${_priceFilterRange.round()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetFilters();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.borderGrey,
                            foregroundColor: AppTheme.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Reset Filters'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _applyFilters();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.tertiaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedFilterCategory = 'All';
      _priceFilterRange = 200000;
      _searchQuery = '';
      _searchController.clear();
    });
    _applyFilters();
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppTheme.paleWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.borderGrey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.borderGrey.withOpacity(0.2),
                ),
                child: product.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: AppTheme.textSecondary,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        size: 50,
                        color: AppTheme.textSecondary,
                      ),
              ),

              const SizedBox(height: 20),

              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _formatPrice(product),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryOrange,
                ),
              ),

              const SizedBox(height: 16),

              if (product.category != null) ...[
                Text(
                  'Category: ${product.category}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              Text(
                'Condition: ${product.condition}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Location: ${product.location}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _deleteProduct(product);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editProduct(product);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
