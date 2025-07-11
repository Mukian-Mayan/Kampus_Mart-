// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/widgets/search_bar.dart' as custom;
import 'package:kampusmart2/widgets/carousel.dart';
import 'package:kampusmart2/widgets/carousel_tile_card.dart';
// ignore: unused_import
import 'package:kampusmart2/widgets/product_vertical_list.dart';
import 'package:kampusmart2/models/product.dart';
import 'package:kampusmart2/widgets/product_card.dart';
import 'package:kampusmart2/screens/product_details_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/HomePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0; // 0: suggested, 1: trending
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  void _onTab(int index) {
    if (selectedIndex != index) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = [
      Product(
        name: 'Dining Set',
        description: 'A beautiful dining set for your home',
        ownerId: '1',
        priceAndDiscount: 'Ugx120,000',
        originalPrice: 'Ugx250,000',
        condition: 'New',
        location: 'Kikoni',
        rating: 4.5,
        imageUrl: 'lib/products/dinning_set.jpeg',
      ),
      Product(
        name: 'Cup Board',
        description: 'Spacious cup board',
        ownerId: '2',
        priceAndDiscount: 'Ugx80,000',
        originalPrice: 'Ugx150,000',
        condition: 'Used',
        location: 'Africa hall',
        rating: 4.0,
        imageUrl: 'lib/products/cup_board.jpg',
      ),
      Product(
        name: 'Computer Science Textbook',
        description: 'This a used textbook for computer science students',
        ownerId: '3',
        priceAndDiscount: 'Ugx65,000',
        originalPrice: 'Ugx80,000',
        condition: 'New',
        location: 'Kasubi',
        rating: 4.2,
        imageUrl: 'lib/products/cs_book.jpeg',
      ),
      Product(
        name: 'Lenovo PC',
        description: 'Powerful laptop for students',
        ownerId: '1',
        priceAndDiscount: 'Ugx1,200,000',
        originalPrice: 'Ugx1,500,000',
        condition: 'Used',
        location: 'Kikoni',
        rating: 4.1,
        imageUrl: 'lib/products/reading table.jpeg',
      ),
      Product(
        name: 'Macbook',
        description: 'Macbook Pro 2020',
        ownerId: '5',
        priceAndDiscount: 'Ugx800,000',
        originalPrice: 'Ugx1,000,000',
        condition: 'Premium used',
        location: 'Wandegeya',
        rating: 4.8,
        imageUrl: 'lib/products/macbook2.jpg',
      ),
      Product(
        name: 'TV',
        description: '50 inch Smart TV',
        ownerId: '6',
        priceAndDiscount: 'Ugx550,000',
        originalPrice: 'Ugx700,000',
        condition: 'New',
        location: 'Jinja',
        rating: 4.6,
        imageUrl: 'lib/products/tv.jpg',
      ),
      Product(
        name: 'Study Table',
        description: 'A strong table good for studying or working',
        ownerId: '1',
        priceAndDiscount: 'Ugx90,000',
        originalPrice: 'Ugx120,000',
        condition: 'Used',
        location: 'Wakiso',
        rating: 4.1,
        imageUrl: 'lib/products/reading table.jpeg',
      ),
      Product(
        name: 'Text Book',
        description: 'Computer Science Textbook',
        ownerId: '3',
        priceAndDiscount: 'Ugx65,000',
        originalPrice: 'Ugx80,000',
        condition: 'New',
        location: 'Mukono',
        rating: 4.2,
        imageUrl: 'lib/products/cs_book.jpeg',
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: BottomNavBar(selectedIndex: 0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFFDE7A6),
            expandedHeight: 210,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: _showSearch
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                  : null,
              background: Padding(
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'HOME',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w400,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.coffeeBrown.withOpacity(
                              0.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'more',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.coffeeBrown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'suggested for you',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.coffeeBrown.withOpacity(
                              0.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'trending',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary,
              ),
              onPressed: () {},
            ),
            actions: [
              Builder(
                builder: (context) {
                  final settings = context
                      .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
                  final double t =
                      settings == null || settings.maxExtent == settings.minExtent
                          ? 1.0
                          : (settings.currentExtent - settings.minExtent) /
                              (settings.maxExtent - settings.minExtent);
                  // Show search icon only when collapsed
                  if (t < 0.5) {
                    return IconButton(
                      icon: Icon(_showSearch ? Icons.close : Icons.search, color: AppTheme.textPrimary),
                      onPressed: () {
                        setState(() {
                          _showSearch = !_showSearch;
                          if (!_showSearch) _searchController.clear();
                        });
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder:(context)=>NotificationsScreen(userRole: UserRole.buyer),),);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final settings = context
                    .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
                final double t =
                    settings == null || settings.maxExtent == settings.minExtent
                        ? 1.0
                        : (settings.currentExtent - settings.minExtent) /
                            (settings.maxExtent - settings.minExtent);
                // Show search bar only when expanded
                if (t >= 0.5) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                    child: custom.SearchBar(),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Carousel(
                items: const [
                  CarouselTileCard(
                    leftImage: 'lib/images/couch.jpg',
                    centerImage: 'lib/images/Cooling_fan.jpg',
                    rightImage: 'lib/products/back bag.jpeg',
                  ),
                  CarouselTileCard(
                    leftImage: 'lib/images/Cooling_fan.png',
                    centerImage: 'lib/products/studytable.jpg',
                    rightImage: 'lib/products/study_table.jpeg',
                  ),
                  CarouselTileCard(
                    leftImage: 'lib/products/studytable.jpg',
                    centerImage: 'lib/products/macbook2.jpg',
                    rightImage: 'lib/products/tv_screen.jpg',
                  ),
                ],
                height: 120,
                borderRadius: 18,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: 8,
              left: 0,
              right: 0,
              bottom: 16,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.7,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailsPage(product: product),
                      ),
                    );
                  },
                );
              }, childCount: products.length),
            ),
          ),
        ],
      ),
    );
  }
}
