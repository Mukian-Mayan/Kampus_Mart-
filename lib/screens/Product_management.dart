

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/seller_add_product.dart';
import '../Theme/app_theme.dart';
import '../widgets/logo_widget.dart';

class SellerProductManagementScreen extends StatefulWidget {
  static const String routeName = '/SellerProductManagement';

  const SellerProductManagementScreen({super.key});

  @override
  State<SellerProductManagementScreen> createState() => _SellerProductManagementScreenState();
}

class _SellerProductManagementScreenState extends State<SellerProductManagementScreen> {
  // Filter-related state variables
  String _selectedFilterCategory = 'All';
  double _priceFilterRange = 100000;
  String _searchQuery = '';

  // Mock product data
  final List<Map<String, dynamic>> products = [
    {
      'id': 'KM-001',
      'name': ' T-Shirt',
      'category': 'Clothing',
      'price': 25000,
      'stock': 42,
      'image': 'assets/tshirt.png',
      'description': 'Comfortable cotton t-shirt with Kampusmart logo',
    },
    {
      'id': 'KM-002',
      'name': 'Hoodie',
      'category': 'Clothing',
      'price': 55000,
      'stock': 18,
      'image': 'assets/hoodie.png',
      'description': 'Warm hoodie perfect for campus life',
    },
    {
      'id': 'KM-003',
      'name': ' Notebook',
      'category': 'Stationery',
      'price': 10000,
      'stock': 75,
      'image': 'assets/notebook.png',
      'description': 'Durable notebook for all your academic needs',
    },
    {
      'id': 'KM-004',
      'name': 'Wireless Earbuds',
      'category': 'Electronics',
      'price': 120000,
      'stock': 15,
      'image': 'assets/earbuds.png',
      'description': 'High-quality wireless earbuds with noise cancellation',
    },
    {
      'id': 'KM-005',
      'name': 'table',
      'category': 'Furniture',
      'price': 5000,
      'stock': 2,
      'image': 'assets/furniture.png',
      'description': 'Boost your energy with this refreshing drink',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Apply filters to products
    final filteredProducts = products.where((product) {
      final matchesCategory = _selectedFilterCategory == 'All' || 
                            product['category'] == _selectedFilterCategory;
      final matchesPrice = product['price'] <= _priceFilterRange;
      final matchesSearch = _searchQuery.isEmpty || 
                          product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesCategory && matchesPrice && matchesSearch;
    }).toList();

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
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.textPrimary),
            onPressed: () =>Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SellerAddProductScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppTheme.paleWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.paleWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      _showFilterOptions(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Filter indicators
          if (_selectedFilterCategory != 'All' || _priceFilterRange < 100000)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (_selectedFilterCategory != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedFilterCategory),
                        backgroundColor: AppTheme.chipBackground,
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedFilterCategory = 'All';
                          });
                        },
                      ),
                    ),
                  if (_priceFilterRange < 100000)
                    Chip(
                      label: Text('Under UGX ${_priceFilterRange.round()}'),
                      backgroundColor: AppTheme.chipBackground,
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _priceFilterRange = 100000;
                        });
                      },
                    ),
                ],
              ),
            ),
          
          // Product List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.paleWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: AppTheme.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters or search',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.borderGrey.withOpacity(0.2),
                              backgroundImage: AssetImage(product['image']),
                            ),
                            title: Text(
                              product['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['category'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'UGX ${product['price']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${product['stock']} in stock',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product['stock'] > 0
                                        ? AppTheme.lightGreen.withOpacity(0.2)
                                        : AppTheme.deepOrange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    product['stock'] > 0 ? 'Available' : 'Out of stock',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: product['stock'] > 0
                                          ? AppTheme.lightGreen
                                          : AppTheme.deepOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              _showProductDetails(context, product);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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
                  
                  // Category Filter
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Clothing', 'Electronics', 'Stationery', 'Food'].map((category) {
                      return ChoiceChip(
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
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Price Range Filter
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
                    max: 200000,
                    divisions: 10,
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
                  
                  // Action Buttons
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
                            setState(() {});
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
      _priceFilterRange = 100000;
      _searchQuery = '';
    });
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
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
              // ... (keep your existing product details implementation)
            ],
          ),
        );
      },
    );
  }
}