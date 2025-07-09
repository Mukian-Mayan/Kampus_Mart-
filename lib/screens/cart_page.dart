import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/chats_screen.dart';
import 'package:kampusmart2/screens/home_page.dart';
import 'package:kampusmart2/screens/message_screen.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/screens/settings_page.dart';
import 'package:kampusmart2/screens/user_profile_page.dart';
import '../models/product.dart';
import "../screens/product_details_page.dart";

final List<Product> products = [
  Product(
    name: 'Apple iPhone 15',
    description: 'Latest iPhone with A16 Bionic chip',
    ownerId: 'user123',
    priceAndDiscount: '2,999,000 UGX (10% off)',
    rating: 5,
    imageUrl: '',
    bestOffer: true,
  ),
  Product(
    name: 'Samsung Galaxy S24',
    description: 'Flagship Android phone',
    ownerId: 'user456',
    priceAndDiscount: '2,499,000 UGX (5% off)',
    rating: 4,
    imageUrl: '',
    bestOffer: false,
  ),
  Product(
    name: 'Sony WH-1000XM5',
    description: 'Noise Cancelling Headphones',
    ownerId: 'user789',
    priceAndDiscount: '399,000 UGX (15% off)',
    rating: 5,
    imageUrl: '',
    bestOffer: true,
  ),
  Product(
    name: 'Dell XPS 13',
    description: 'Ultra portable laptop',
    ownerId: 'user321',
    priceAndDiscount: '1,199,000 UGX (8% off)',
    rating: 4,
    imageUrl: '',
    bestOffer: false,
  ),
];

class CartPage extends StatefulWidget {
  static const String  routeName = '/Cart';
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<int> quantities = List.filled(products.length, 1);
  final List<double> ratings = products.map((p) => p.rating).toList();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products
        .asMap()
        .entries
        .where((entry) {
          final product = entry.value;
          final query = searchQuery.toLowerCase();
          return product.name.toLowerCase().contains(query) ||
                 product.description.toLowerCase().contains(query);
        })
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(userRole: UserRole.buyer),),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'search to add more to cart',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: filteredProducts.length,
              itemBuilder: (context, filteredIndex) {
                final entry = filteredProducts[filteredIndex];
                final index = entry.key;
                final product = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.05 * 255).toInt()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 90,
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD39E6A),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD39E6A),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.priceAndDiscount,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE082),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove, size: 18, color: Color(0xFFD39E6A)),
                                            onPressed: () {
                                              setState(() {
                                                if (quantities[index] > 1) quantities[index]--;
                                              });
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          Text(
                                            quantities[index].toString(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add, size: 18, color: Color(0xFFD39E6A)),
                                            onPressed: () {
                                              setState(() {
                                                quantities[index]++;
                                              });
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD39E6A),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: List.generate(5, (star) => GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              ratings[index] = star + 1;
                                            });
                                          },
                                          child: Icon(
                                            Icons.star,
                                            color: star < ratings[index] ? Colors.white : Colors.white24,
                                            size: 20,
                                          ),
                                        )),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD39E6A),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductDetailsPage(product: product),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Details',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF3CD),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black, size: 32),
              onPressed: ()=> Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
                ),
            ),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.black, size: 32),
              onPressed: ()=> Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartPage(),),
            ),
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black, size: 32),
              onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),),
            ),
            ),
            IconButton(
              icon: const Icon(Icons.message, color: Colors.black, size: 32),
              onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                                builder: (context) => const MessageScreen(userName: '',),
                ),
            ),
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.black, size: 32),
              onPressed: ()=> Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserProfilePage(),),
            ),
            ),
          ],
        ),
      ),
    );
  }
} 