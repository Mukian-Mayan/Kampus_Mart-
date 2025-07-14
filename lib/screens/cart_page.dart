// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/payment_transactions.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import '../models/product.dart';
import "../screens/product_details_page.dart";

final List<Product> products = [
  Product(
    name: 'Apple iPhone 15',
    description: 'Latest iPhone with A16 Bionic chip',
    ownerId: 'user123',
    priceAndDiscount: '2,999,000 UGX (10% off)',
    originalPrice: '3,300,000 UGX',
    condition: 'New',
    location: 'Kampala',
    rating: 5,
    imageUrl: '',
    bestOffer: true,
  ),
  Product(
    name: 'Samsung Galaxy S24',
    description: 'Flagship Android phone',
    ownerId: 'user456',
    priceAndDiscount: '2,499,000 UGX (5% off)',
    originalPrice: '2,700,000 UGX',
    condition: 'New',
    location: 'Entebbe',
    rating: 4,
    imageUrl: '',
    bestOffer: false,
  ),
  Product(
    name: 'Sony WH-1000XM5',
    description: 'Noise Cancelling Headphones',
    ownerId: 'user789',
    priceAndDiscount: '399,000 UGX (15% off)',
    originalPrice: '470,000 UGX',
    condition: 'New',
    location: 'Wandegeya',
    rating: 5,
    imageUrl: '',
    bestOffer: true,
  ),
  Product(
    name: 'Dell XPS 13',
    description: 'Ultra portable laptop',
    ownerId: 'user321',
    priceAndDiscount: '1,199,000 UGX (8% off)',
    originalPrice: '1,300,000 UGX',
    condition: 'Used',
    location: 'Kikoni',
    rating: 4,
    imageUrl: '',
    bestOffer: false,
  ),
];

class CartPage extends StatefulWidget {
  static const String routeName = '/Cart';
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<int> quantities = List.filled(products.length, 1);
  final List<double> ratings = products.map((p) => p.rating).toList();
  String searchQuery = '';

  void _updateQuantity(int index, bool increment) {
    setState(() {
      if (increment) {
        quantities[index]++;
      } else {
        if (quantities[index] > 1) quantities[index]--;
      }
    });
  }

  void _updateRating(int index, double rating) {
    setState(() {
      ratings[index] = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.asMap().entries.where((entry) {
      final product = entry.value;
      final query = searchQuery.toLowerCase();
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.paleWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.paleWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Cart',
          style: AppTheme.titleStyle.copyWith(fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const NotificationsScreen(userRole: UserRole.buyer),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search to add more to cart',
                hintStyle: AppTheme.subtitleStyle,
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
            ),
          ),
          // Cart Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: filteredProducts.length,
              itemBuilder: (context, filteredIndex) {
                final entry = filteredProducts[filteredIndex];
                final index = entry.key;
                final product = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiaryOrange,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: AppTheme.textSecondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryOrange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.name,
                                  style: AppTheme.chipTextStyle.copyWith(
                                    color: AppTheme.paleWhite,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Price
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.coffeeBrown,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.priceAndDiscount,
                                  style: AppTheme.subtitleStyle.copyWith(
                                    color: AppTheme.paleWhite,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Controls Row
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    // Quantity Controls
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryOrange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove,
                                              size: 16,
                                            ),
                                            onPressed: () =>
                                                _updateQuantity(index, false),
                                            padding: const EdgeInsets.all(2),
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            color: AppTheme.paleWhite,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ),
                                            child: Text(
                                              quantities[index].toString(),
                                              style: AppTheme.chipTextStyle
                                                  .copyWith(
                                                    color: AppTheme.paleWhite,
                                                    fontSize: 12,
                                                  ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add,
                                              size: 16,
                                            ),
                                            onPressed: () =>
                                                _updateQuantity(index, true),
                                            padding: const EdgeInsets.all(2),
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            color: AppTheme.paleWhite,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Rating
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.deepOrange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          5,
                                          (star) => GestureDetector(
                                            onTap: () => _updateRating(
                                              index,
                                              star + 1.0,
                                            ),
                                            child: Icon(
                                              Icons.star,
                                              color: star < ratings[index]
                                                  ? AppTheme.paleWhite
                                                  : AppTheme.paleWhite
                                                        .withOpacity(0.3),
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Details Button
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailsPage(
                                                  product: product,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.deepBlue,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'Details',
                                          style: AppTheme.chipTextStyle
                                              .copyWith(
                                                color: AppTheme.paleWhite,
                                                fontSize: 11,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Proceed to Payment Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentTransactions(),
                  ),
                );
              },
              child: Text(
                'Proceed to Payment',
                style: AppTheme.titleStyle.copyWith(
                  color: AppTheme.paleWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1,navBarColor: AppTheme.tertiaryOrange),
    );
  }
}
