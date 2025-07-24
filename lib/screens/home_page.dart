// ignore_for_file: unused_field, dead_code, override_on_non_overriding_member, unused_local_variable

import 'package:flutter/material.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/register_page.dart';
import '../models/product.dart';
import './notification_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../Theme/app_theme.dart';
import '../widgets/bottom_nav_bar2.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/carousel.dart';
import '../widgets/carousel_tile_card.dart';
import '../widgets/product_card.dart';
import '../widgets/carousel_loading.dart';
import '../widgets/product_card_loading.dart';
import './product_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/fancy_app_bar.dart';
import './_fancy_app_bar_sliver_delegate.dart';
import 'dart:ui';
import '../services/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  final UserRole userRole;
  static const String routeName = '/HomePage';
  const HomePage({super.key, required this.userRole});

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

  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    _productsFuture = ProductService.getAllProducts();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role');
    });
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(
          userRole: widget.userRole,
          userId: FirebaseAuth.instance.currentUser?.uid,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: widget.userRole == UserRole.seller
          ? BottomNavBar2(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            )
          : BottomNavBar(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: FancyAppBarSliverDelegate(
              minExtent: 140, // Increased to prevent overflow
              maxExtent: 170,
              builder: (context, shrinkOffset, overlapsContent) {
                // Hide tabs and reduce height when scrolled past threshold (e.g. 60px)
                final bool showTabs = shrinkOffset < 60;
                final double appBarHeight = showTabs ? 170 : 140;
                return FancyAppBar(
                  tabs: const ['Suggested for you', 'Trending'],
                  selectedIndex: isSuggestedSelected ? 0 : 1,
                  onTabChanged: (index) {
                    setState(() {
                      isSuggestedSelected = index == 0;
                    });
                  },
                  title: '',
                  height: appBarHeight,
                  showTabs: showTabs,
                  customContent: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 16,
                        right: 8,
                        bottom: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: custom.SearchBar(
                                controller: _searchController,
                                hintText: 'Search products...',
                                isVisible: _showSearch,
                                onClose: _toggleSearch,
                                onChanged: (value) {
                                  // Implement search functionality
                                  setState(() {
                                    // Update search results
                                  });
                                },
                              ),
                            ),
                          ),
                          if (!_showSearch)
                            IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.black87,
                                size: 24,
                              ),
                              onPressed: _toggleSearch,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.black87,
                              size: 24,
                            ),
                            onPressed: _navigateToNotifications,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CarouselLoading();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading products',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final products = snapshot.data!;
                if (products.length < 3) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Carousel(
                    items: [products.sublist(0, 3)].map((group) {
                      return CarouselTileCard(
                        leftImage: group[0].imageUrl,
                        centerImage: group[1].imageUrl,
                        rightImage: group[2].imageUrl,
                        onImageTap: (imagePath) {
                          final product = group.firstWhere(
                            (p) => p.imageUrl == imagePath,
                            orElse: () => group[0],
                          );
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsPage(product: product),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                    height: 180,
                    borderRadius: 20,
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                          mainAxisExtent: 260,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const ProductCardLoading(),
                      childCount: 6, // Show 6 loading cards
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('Error loading products')),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('No products found')),
                  );
                }
                final products = snapshot.data!;
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                    mainAxisExtent: 260,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index >= products.length) return null;
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsPage(product: product),
                            ),
                          );
                        }
                      },
                    );
                  }, childCount: products.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
