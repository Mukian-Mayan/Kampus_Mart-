// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/payment_transactions.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'product_details_page.dart';

// Remove the local products list and use the static cart from ProductDetailsPage
// final List<Product> products = [
//   Product(
//     name: 'Apple iPhone 15',
//     description: 'Latest iPhone with A16 Bionic chip',
//     ownerId: 'user123',
//     priceAndDiscount: '2,999,000 UGX (10% off)',
//     originalPrice: '3,300,000 UGX',
//     condition: 'New',
//     location: 'Kampala',
//     rating: 5,
//     imageUrl: '',
//     bestOffer: true,
//   ),
//   Product(
//     name: 'Samsung Galaxy S24',
//     description: 'Flagship Android phone',
//     ownerId: 'user456',
//     priceAndDiscount: '2,499,000 UGX (5% off)',
//     originalPrice: '2,700,000 UGX',
//     condition: 'New',
//     location: 'Entebbe',
//     rating: 4,
//     imageUrl: '',
//     bestOffer: false,
//   ),
//   Product(
//     name: 'Sony WH-1000XM5',
//     description: 'Noise Cancelling Headphones',
//     ownerId: 'user789',
//     priceAndDiscount: '399,000 UGX (15% off)',
//     originalPrice: '470,000 UGX',
//     condition: 'New',
//     location: 'Wandegeya',
//     rating: 5,
//     imageUrl: '',
//     bestOffer: true,
//   ),
//   Product(
//     name: 'Dell XPS 13',
//     description: 'Ultra portable laptop',
//     ownerId: 'user321',
//     priceAndDiscount: '1,199,000 UGX (8% off)',
//     originalPrice: '1,300,000 UGX',
//     condition: 'Used',
//     location: 'Kikoni',
//     rating: 4,
//     imageUrl: '',
//     bestOffer: false,
//   ),
// ];

class CartPage extends StatefulWidget {
  static const String routeName = '/Cart';
   final UserRole userRole;
  const CartPage({super.key, required this.userRole});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? userRole;
  int selectedIndex = 1;

  // Use the static cart from ProductDetailsPage
  List<Product> get products => ProductDetailsPage.cart;
  final List<int> quantities = [];
  final List<double> ratings = [];
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
  void initState() {
    super.initState();
    // Initialize quantities and ratings for each product in the cart
    quantities.addAll(List.filled(products.length, 1));
    ratings.addAll(products.map((p) => p.rating));
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role');
    });
  }

  //till here guys

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
      // In cart_page.dart, update the build method's bottomNavigationBar section:
      // Update the bottomNavigationBar section to match home_page.dart
bottomNavigationBar: widget.userRole == UserRole.seller
    ? BottomNavBar2(
        selectedIndex: selectedIndex,
        navBarColor: AppTheme.tertiaryOrange,
      )
    : BottomNavBar(
        selectedIndex: selectedIndex,
        navBarColor: AppTheme.tertiaryOrange,
      ),
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Cart',
          style: AppTheme.titleStyle.copyWith(
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationsScreen(userRole: UserRole.buyer, userId: FirebaseAuth.instance.currentUser?.uid ?? '',),
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
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 60,
                          color: AppTheme.borderGrey,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'You have no items in your cart',
                          style: AppTheme.titleStyle.copyWith(
                            fontSize: 20,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, filteredIndex) {
                      final entry = filteredProducts[filteredIndex];
                      final index = entry.key;
                      final product = entry.value;

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: product.imageUrl.isNotEmpty
                                    ? (product.imageUrl.startsWith('http')
                                          ? Image.network(
                                              product.imageUrl,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    width: 70,
                                                    height: 70,
                                                    color: AppTheme.lightGrey,
                                                    child: Icon(
                                                      Icons
                                                          .shopping_bag_outlined,
                                                      color: AppTheme
                                                          .textSecondary,
                                                      size: 32,
                                                    ),
                                                  ),
                                            )
                                          : Image.asset(
                                              product.imageUrl,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    width: 70,
                                                    height: 70,
                                                    color: AppTheme.lightGrey,
                                                    child: Icon(
                                                      Icons
                                                          .shopping_bag_outlined,
                                                      color: AppTheme
                                                          .textSecondary,
                                                      size: 32,
                                                    ),
                                                  ),
                                            ))
                                    : Container(
                                        width: 70,
                                        height: 70,
                                        color: AppTheme.lightGrey,
                                        child: Icon(
                                          Icons.shopping_bag_outlined,
                                          color: AppTheme.textSecondary,
                                          size: 32,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Product Details and Controls (left)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: AppTheme.titleStyle.copyWith(
                                        fontSize: 20, // Increased size
                                        fontWeight: FontWeight.bold, // Bold
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      product.priceAndDiscount,
                                      style: AppTheme.subtitleStyle.copyWith(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Quantity Controls (smaller)
                                        Container(
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppTheme.tertiaryOrange,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 14,
                                                ),
                                                onPressed: () => _updateQuantity(
                                                  index,
                                                  false,
                                                ),
                                                padding: const EdgeInsets.all(0),
                                                constraints: const BoxConstraints(
                                                  minWidth: 24,
                                                  minHeight: 24,
                                                ),
                                                color: Colors.black,
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                    ),
                                                child: Text(
                                                  quantities[index].toString(),
                                                  style: AppTheme.chipTextStyle
                                                      .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 14,
                                                ),
                                                onPressed: () => _updateQuantity(
                                                  index,
                                                  true,
                                                ),
                                                padding: const EdgeInsets.all(0),
                                                constraints: const BoxConstraints(
                                                  minWidth: 24,
                                                  minHeight: 24,
                                                ),
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        // Only Remove button (right)
                                        SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                ProductDetailsPage.cart.remove(
                                                  product,
                                                );
                                                quantities.removeAt(index);
                                                ratings.removeAt(index);
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Removed ${product.name} from cart.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 40,
                                              minHeight: 40,
                                            ),
                                            tooltip: 'Remove',
                                          ),
                                        ),
                                      ],
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
      
    );
  }
}
