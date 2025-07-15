// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import '../models/product.dart';
import './notification_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../Theme/app_theme.dart';
import '../widgets/bottom_nav_bar2.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/carousel.dart';
import '../widgets/carousel_tile_card.dart';
import '../widgets/product_card.dart';
import './product_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/HomePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  bool isSuggestedSelected = true;
  String? userRole;

  List<List<Product>> getCarouselProducts() {
    if (isSuggestedSelected) {
      return [
        [
          Product(
            name: 'Study Setup',
            description: 'Complete study setup for students',
            ownerId: '1',
            priceAndDiscount: 'Ugx120,000',
            originalPrice: 'Ugx150,000',
            condition: 'New',
            location: 'Kikoni',
            rating: 4.5,
            imageUrl: 'lib/products/study_table.jpeg',
          ),
          Product(
            name: 'Laptop Setup',
            description: 'Perfect for remote work',
            ownerId: '2',
            priceAndDiscount: 'Ugx80,000',
            originalPrice: 'Ugx100,000',
            condition: 'Used',
            location: 'Campus',
            rating: 4.0,
            imageUrl: 'lib/products/macbook2.jpg',
          ),
          Product(
            name: 'Reading Corner',
            description: 'Cozy reading space essentials',
            ownerId: '3',
            priceAndDiscount: 'Ugx95,000',
            originalPrice: 'Ugx120,000',
            condition: 'New',
            location: 'Library',
            rating: 4.2,
            imageUrl: 'lib/products/studytable.jpg',
          ),
        ],
        [
          Product(
            name: 'Cup Board',
            description: 'Spacious cup board',
            ownerId: '4',
            priceAndDiscount: 'Ugx80,000',
            originalPrice: 'Ugx150,000',
            condition: 'Used',
            location: 'Africa hall',
            rating: 4.0,
            imageUrl: 'lib/products/cup_board.jpg',
          ),
          Product(
            name: 'Dining Set',
            description: 'A beautiful dining set for your home',
            ownerId: '5',
            priceAndDiscount: 'Ugx120,000',
            originalPrice: 'Ugx250,000',
            condition: 'New',
            location: 'Kikoni',
            rating: 4.5,
            imageUrl: 'lib/products/dinning_set.jpeg',
          ),
          Product(
            name: 'CS Textbook',
            description: 'Essential textbook for CS students',
            ownerId: '6',
            priceAndDiscount: 'Ugx65,000',
            originalPrice: 'Ugx80,000',
            condition: 'New',
            location: 'Kasubi',
            rating: 4.2,
            imageUrl: 'lib/products/cs_book.jpeg',
          ),
        ],
      ];
    } else {
      return [
        [
          Product(
            name: 'Modern Desk',
            description: 'Trending workspace solution',
            ownerId: '1',
            priceAndDiscount: 'Ugx150,000',
            originalPrice: 'Ugx200,000',
            condition: 'New',
            location: 'Wandegeya',
            rating: 4.8,
            imageUrl: 'lib/images/Cooling_fan.jpg',
          ),
          Product(
            name: 'Entertainment Setup',
            description: 'Complete entertainment system',
            ownerId: '2',
            priceAndDiscount: 'Ugx250,000',
            originalPrice: 'Ugx300,000',
            condition: 'New',
            location: 'Campus',
            rating: 4.7,
            imageUrl: 'lib/products/tv_screen.jpg',
          ),
          Product(
            name: 'Student Backpack',
            description: 'Trendy and spacious backpack',
            ownerId: '3',
            priceAndDiscount: 'Ugx45,000',
            originalPrice: 'Ugx60,000',
            condition: 'New',
            location: 'Kikoni',
            rating: 4.5,
            imageUrl: 'lib/products/back bag.jpeg',
          ),
        ],
        [
          Product(
            name: 'Macbook Pro',
            description: 'Powerful laptop for developers',
            ownerId: '4',
            priceAndDiscount: 'Ugx3,500,000',
            originalPrice: 'Ugx4,000,000',
            condition: 'Used',
            location: 'Wandegeya',
            rating: 4.8,
            imageUrl: 'lib/products/macbook.jpg',
          ),
          Product(
            name: 'Couch',
            description: 'Comfortable couch for your living room',
            ownerId: '5',
            priceAndDiscount: 'Ugx250,000',
            originalPrice: 'Ugx400,000',
            condition: 'Used',
            location: 'Kikoni',
            rating: 4.3,
            imageUrl: 'lib/products/couch.jpg',
          ),
          Product(
            name: 'Reading Lamp',
            description: 'Bright lamp for night study',
            ownerId: '6',
            priceAndDiscount: 'Ugx30,000',
            originalPrice: 'Ugx50,000',
            condition: 'New',
            location: 'Hostel',
            rating: 4.6,
            imageUrl: 'lib/products/reading_lamp.jpg',
          ),
        ],
      ];
    }
  }

  void _onTab(int index) {
    if (selectedIndex != index) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  //initial link up
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role');
    });
  }

  //till here guys

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carouselProducts = getCarouselProducts();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: (userRole == 'option2')
          ? BottomNavBar(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            )
          : (userRole == 'option1')
          ? BottomNavBar2(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            )
          : null,

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFFDE7A6),
            expandedHeight: 120,
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
                  top: 10,
                  left: 16,
                  right: 16,
                  bottom: 4,
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
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSuggestedSelected
                                ? AppTheme.coffeeBrown
                                : AppTheme.coffeeBrown.withOpacity(0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              isSuggestedSelected = true;
                            });
                          },
                          child: const Text(
                            'suggested for you',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isSuggestedSelected
                                ? AppTheme.coffeeBrown
                                : AppTheme.coffeeBrown.withOpacity(0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              isSuggestedSelected = false;
                            });
                          },
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
            leading: null,
            actions: [
              Builder(
                builder: (context) {
                  final settings = context
                      .dependOnInheritedWidgetOfExactType<
                        FlexibleSpaceBarSettings
                      >();
                  final double t =
                      settings == null ||
                          settings.maxExtent == settings.minExtent
                      ? 1.0
                      : (settings.currentExtent - settings.minExtent) /
                            (settings.maxExtent - settings.minExtent);
                  if (t < 0.5) {
                    return IconButton(
                      icon: Icon(
                        _showSearch ? Icons.close : Icons.search,
                        color: AppTheme.textPrimary,
                      ),
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
                  Navigator.pushNamed(context, '/NotificationScreen');
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final settings = context
                    .dependOnInheritedWidgetOfExactType<
                      FlexibleSpaceBarSettings
                    >();
                final double t =
                    settings == null || settings.maxExtent == settings.minExtent
                    ? 1.0
                    : (settings.currentExtent - settings.minExtent) /
                          (settings.maxExtent - settings.minExtent);
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Carousel(
                items: carouselProducts.map((group) {
                  return CarouselTileCard(
                    leftImage: group[0].imageUrl,
                    centerImage: group[1].imageUrl,
                    rightImage: group[2].imageUrl,
                    onImageTap: (imagePath) {
                      final product = group.firstWhere(
                        (p) => p.imageUrl == imagePath,
                        orElse: () => group[0],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailsPage(product: product),
                        ),
                      );
                    },
                  );
                }).toList(),
                height: 180,
                borderRadius: 20,
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
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final List<Product> allProducts = [
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
                    description: 'Essential textbook for CS students',
                    ownerId: '3',
                    priceAndDiscount: 'Ugx65,000',
                    originalPrice: 'Ugx80,000',
                    condition: 'New',
                    location: 'Kasubi',
                    rating: 4.2,
                    imageUrl: 'lib/products/cs_book.jpeg',
                  ),
                  Product(
                    name: 'Study Table',
                    description: 'Perfect for studying',
                    ownerId: '4',
                    priceAndDiscount: 'Ugx90,000',
                    originalPrice: 'Ugx120,000',
                    condition: 'Used',
                    location: 'Kikoni',
                    rating: 4.1,
                    imageUrl: 'lib/products/study_table.jpeg',
                  ),
                  Product(
                    name: 'Back Bag',
                    description: 'Stylish and durable',
                    ownerId: '5',
                    priceAndDiscount: 'Ugx45,000',
                    originalPrice: 'Ugx70,000',
                    condition: 'New',
                    location: 'Nkrumah',
                    rating: 4.4,
                    imageUrl: 'lib/products/back bag.jpeg',
                  ),
                  Product(
                    name: 'TV Screen',
                    description: 'High definition TV screen',
                    ownerId: '6',
                    priceAndDiscount: 'Ugx300,000',
                    originalPrice: 'Ugx400,000',
                    condition: 'New',
                    location: 'Campus',
                    rating: 4.7,
                    imageUrl: 'lib/products/tv_screen.jpg',
                  ),
                  Product(
                    name: 'Water Bottle',
                    description: 'water bottle for daily use',
                    ownerId: '7',
                    priceAndDiscount: 'Ugx15,000',
                    originalPrice: 'Ugx30,000',
                    condition: 'Used',
                    location: 'Kikoni',
                    rating: 4.3,
                    imageUrl: 'lib/products/waterbottle.jpg',
                  ),
                  Product(
                    name: 'Smart Watch',
                    description: 'A smart watch for daily use',
                    ownerId: '8',
                    priceAndDiscount: 'Ugx30,000',
                    originalPrice: 'Ugx50,000',
                    condition: 'New',
                    location: 'Hostel',
                    rating: 4.6,
                    imageUrl: 'lib/products/wraist_watch.jpg',
                  ),
                  Product(
                    name: 'Fashion shoes',
                    description: 'Stylish and comfortable shoes',
                    ownerId: '9',
                    priceAndDiscount: 'Ugx35,000',
                    originalPrice: 'Ugx90,000',
                    condition: 'Used',
                    location: 'Wandegeya',
                    rating: 4.8,
                    imageUrl: 'lib/products/high hills.jpg',
                  ),
                  Product(
                    name: 'Study Table 2',
                    description: 'Modern study table',
                    ownerId: '10',
                    priceAndDiscount: 'Ugx110,000',
                    originalPrice: 'Ugx130,000',
                    condition: 'New',
                    location: 'Hostel',
                    rating: 4.3,
                    imageUrl: 'lib/products/studytable.jpg',
                  ),
                ];

                if (index >= allProducts.length) return null;
                final product = allProducts[index];

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
              }, childCount: 10),
            ),
          ),
        ],
      ),
    );
  }
}
