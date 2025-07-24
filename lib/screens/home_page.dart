// ignore_for_file: unused_field, dead_code, override_on_non_overriding_member, unused_local_variable

import 'package:flutter/material.dart';
import 'package:kampusmart2/models/user_role.dart';
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
import 'dart:ui';
import '../services/product_service.dart';

class HomePage extends StatefulWidget {
  final UserRole userRole;
  static const String routeName = '/HomePage';
  const HomePage({super.key, required this. userRole});
  

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
    final bool searchBarVisible = _showSearch;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: widget.userRole == UserRole.seller
          ? BottomNavBar2(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            )
          : BottomNavBar(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            ),
    
 
      

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
                child: FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error:  [31m${snapshot.error} [0m'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No products found.'));
                    }
                    final products = snapshot.data!;
                    // Carousel display (first 3 products as an example)
                    if (products.length < 3) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsPage(product: product),
                                ),
                              );
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
                padding: const EdgeInsets.only(
                  top: 8,
                  left: 0,
                  right: 0,
                  bottom: 16,
                ),
                sliver: FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(child: Center(child: Text('Error:  [31m${snapshot.error} [0m')));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SliverToBoxAdapter(child: Center(child: Text('No products found.')));
                    }
                    final products = snapshot.data!;
                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index >= products.length) return null;
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(product: product),
                              ),
                            );
                          },
                        );
                      }, childCount: products.length),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      );
  }
}