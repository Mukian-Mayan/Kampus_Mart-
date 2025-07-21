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
import '../widgets/fancy_app_bar.dart';
import './_fancy_app_bar_sliver_delegate.dart';
import '../widgets/my_button1.dart';
import 'dart:ui';

class HomePage extends StatefulWidget {
  static const String routeName = '/HomePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _visibleCarouselGroups = 1;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  int selectedIndex = 0;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  bool isSuggestedSelected = true;
  String? userRole;

  List<List<Product>> getCarouselProducts() {
    List<List<Product>> allGroups = isSuggestedSelected
      ? [
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
        ]
      : [
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
    return allGroups.take(_visibleCarouselGroups).toList();
  }

  void _onTab(int index) {
    if (selectedIndex != index) {
      setState(() {
        selectedIndex = index;
        _visibleCarouselGroups = 1; // Reset when switching tabs
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset visible groups if needed when widget updates
    _visibleCarouselGroups = 1;
  }

  @override
  Widget build(BuildContext context) {
    final carouselProducts = getCarouselProducts();
    final bool searchBarVisible = _showSearch;
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
      body: Stack(
        children: [
          // Glassy background layer
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  color: const Color(0xCCFCFCFC), // semi-transparent pale white
                ),
              ),
            ),
          ),
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Collapsible FancyAppBar using SliverPersistentHeader
              SliverPersistentHeader(
                pinned: true,
                delegate: FancyAppBarSliverDelegate(
                  minExtent: searchBarVisible ? 80 + 40 : 80,
                  maxExtent: searchBarVisible ? 110 + 40 : 110,
                  builder: (context, shrinkOffset, overlapsContent) {
                    final double minH = 56; // Minimal app bar height
                    final double maxH = searchBarVisible ? 110 + 40 : 110;
                    // Use scroll offset for shrinking
                    double hideTabsStart = 12 + 180 + 12 + 30 + 4; // 238: padding + carousel + padding + More button + padding
                    double hideTabsEnd = hideTabsStart + 40; // Range for animation
                    double tabVisibility = 1.0;
                    double appBarHeight = maxH;
                    if (_scrollOffset > hideTabsStart) {
                      double t = ((_scrollOffset - hideTabsStart) / (hideTabsEnd - hideTabsStart)).clamp(0.0, 1.0);
                      tabVisibility = 1.0 - t;
                      appBarHeight = maxH - (maxH - minH) * t;
                    }
                    return SizedBox(
                      height: appBarHeight,
                      child: FancyAppBar(
                        tabs: const ['suggested for you', 'trending'],
                        selectedIndex: isSuggestedSelected ? 0 : 1,
                        onTabChanged: (index) {
                          setState(() {
                            isSuggestedSelected = index == 0;
                          });
                        },
                        title: '',
                        trailing: !_showSearch
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.search, color: AppTheme.textPrimary),
                                  onPressed: () {
                                    setState(() {
                                      _showSearch = true;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary),
                                  onPressed: () {
                                    Navigator.pushNamed(context, NotificationsScreen.routeName);
                                  },
                                ),
                              ],
                            )
                          : null,
                        customContent: _showSearch
                          ? Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: custom.SearchBar(
                                      controller: _searchController,
                                      onChanged: (value) {
                                        // Optionally handle search logic here
                                      },
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.black87),
                                        onPressed: () {
                                          setState(() {
                                            _showSearch = false;
                                            _searchController.clear();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
                                  onPressed: () {
                                    Navigator.pushNamed(context, NotificationsScreen.routeName);
                                  },
                                ),
                              ],
                            )
                          : null,
                        height: appBarHeight,
                        tabVisibility: tabVisibility,
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
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
                    Padding(
                      padding: const EdgeInsets.only(right: 24, bottom: 4),
                      child: SizedBox(
                        height: 30,
                        child: MyButton1(
                          height: 30,
                          width: 120,
                          fontSize: 13,
                          text: isSuggestedSelected ? 'More suggested' : 'More trending',
                          pad: 0,
                          onTap: () {
                            final allGroups = isSuggestedSelected
                                ? [
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
                                  ]
                                : [
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
                            final allProducts = allGroups.expand((g) => g).toList();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (context) => FractionallySizedBox(
                                heightFactor: 0.5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                      child: Text(
                                        isSuggestedSelected ? 'More suggested products' : 'More trending products',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: GridView.builder(
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 12,
                                            crossAxisSpacing: 12,
                                            childAspectRatio: 0.85,
                                          ),
                                          itemCount: allProducts.length,
                                          itemBuilder: (context, index) {
                                            final product = allProducts[index];
                                            return ProductCard(
                                              product: product,
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ProductDetailsPage(product: product),
                                                  ),
                                                );
                                              },
                                            );
                                          },
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
                    ),
                  ],
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
        ],
      ),
    );
  }
}