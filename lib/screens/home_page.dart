// ignore_for_file: unused_field, dead_code

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
import '../data/products_data.dart';

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
    if (isSuggestedSelected) {
      return suggestedCarouselProducts;
    } else {
      return trendingCarouselProducts;
    }
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
                          width: 70,
                          fontSize: 13,
                          text: 'More',
                          pad: 0,
                          onTap: () {
                            final allGroups = isSuggestedSelected
                                ? suggestedCarouselProducts
                                : trendingCarouselProducts;
                            final allProducts = allGroups.expand((g) => g).toList();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (context) => FractionallySizedBox(
                                heightFactor: 0.5,
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
                    final List<Product> allProducts = allGridProducts;

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