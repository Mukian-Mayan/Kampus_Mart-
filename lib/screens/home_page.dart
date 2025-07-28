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
import '../ml/services/enhanced_product_service.dart';
import '../ml/widgets/ml_search_suggestions.dart';
import '../ml/screens/enhanced_search_screen.dart';
import '../widgets/more_products_bottom_sheet.dart';

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

  // ML Search states
  List<Product> _searchResults = [];
  List<String> _searchSuggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  String _currentQuery = '';

  // ML Carousel states
  List<Product> _suggestedProducts = [];
  List<Product> _trendingProducts = [];
  bool _isLoadingSuggested = false;
  bool _isLoadingTrending = false;

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

    // Load suggested products on app start (since it's the default tab)
    _loadSuggestedProducts();
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
      if (!_showSearch) {
        _showSuggestions = false;
        _searchController.clear();
      }
    });
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    setState(() {
      _currentQuery = query;
      _showSuggestions = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      _loadSearchSuggestions(query);
    } else {
      setState(() {
        _searchSuggestions.clear();
        _showSuggestions = false;
      });
    }
  }

  Future<void> _loadSearchSuggestions(String query) async {
    try {
      final suggestions = await EnhancedProductService.getSearchSuggestions(
        partialQuery: query,
        limit: 5,
      );
      setState(() {
        _searchSuggestions = suggestions;
      });
    } catch (e) {
      print('Error loading search suggestions: $e');
    }
  }

  Future<void> _performMLSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _showSuggestions = false;
    });

    try {
      // Record search interaction for ML
      await EnhancedProductService.recordUserInteraction(
        productId: 'search',
        interactionType: 'search',
        metadata: {'query': query},
      );

      // Perform enhanced search
      final results = await EnhancedProductService.enhancedSearch(
        query: query,
        limit: 50,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // Navigate to search results
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedSearchScreen(
              initialQuery: query,
              initialResults: results,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      print('Error performing ML search: $e');

      // Fallback to regular search
      try {
        final fallbackResults = await ProductService.searchProducts(query);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnhancedSearchScreen(
                initialQuery: query,
                initialResults: fallbackResults,
              ),
            ),
          );
        }
      } catch (fallbackError) {
        print('Fallback search also failed: $fallbackError');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Search failed: $fallbackError'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _onSuggestionSelected(String suggestion) {
    _searchController.text = suggestion;
    _performMLSearch(suggestion);
  }

  // Load suggested products from ML API
  Future<void> _loadSuggestedProducts() async {
    if (_suggestedProducts.isNotEmpty) return; // Already loaded

    setState(() {
      _isLoadingSuggested = true;
    });

    try {
      print('🔄 Loading suggested products from ML API...');
      final products =
          await EnhancedProductService.getPersonalizedRecommendations(limit: 6);

      // Filter out of stock products
      final inStockProducts = products.where((product) {
        return product.stock == null || product.stock! > 0;
      }).toList();

      print(
        '✅ Loaded ${inStockProducts.length} in-stock suggested products from ML API',
      );
      setState(() {
        _suggestedProducts = inStockProducts;
        _isLoadingSuggested = false;
      });
    } catch (e) {
      print('❌ Error loading suggested products: $e');
      setState(() {
        _isLoadingSuggested = false;
      });
      // Fallback to regular products
      print('🔄 Falling back to regular products...');
      final fallbackProducts = await ProductService.getAllProducts();
      final inStockFallbackProducts = fallbackProducts
          .where((product) {
            return product.stock == null || product.stock! > 0;
          })
          .take(6)
          .toList();
      setState(() {
        _suggestedProducts = inStockFallbackProducts;
      });
      print('✅ Loaded ${_suggestedProducts.length} in-stock fallback products');
    }
  }

  // Load trending products from ML API
  Future<void> _loadTrendingProducts() async {
    if (_trendingProducts.isNotEmpty) return; // Already loaded

    setState(() {
      _isLoadingTrending = true;
    });

    try {
      print('Loading trending products from ML API...');
      final products = await EnhancedProductService.getTrendingProducts(
        limit: 10,
      );

      // Filter out of stock products
      final inStockProducts = products.where((product) {
        return product.stock == null || product.stock! > 0;
      }).toList();

      print(
        'Loaded ${inStockProducts.length} in-stock trending products from ML API',
      );
      setState(() {
        _trendingProducts = inStockProducts;
        _isLoadingTrending = false;
      });
    } catch (e) {
      print('Error loading trending products: $e');
      setState(() {
        _isLoadingTrending = false;
      });
      // Fallback to regular products
      print('Falling back to regular products...');
      final fallbackProducts = await ProductService.getAllProducts();
      final inStockFallbackProducts = fallbackProducts
          .where((product) {
            return product.stock == null || product.stock! > 0;
          })
          .take(6)
          .toList();
      setState(() {
        _trendingProducts = inStockFallbackProducts;
      });
      print('Loaded ${_trendingProducts.length} in-stock fallback products');
    }
  }

  // Show more products in a bottom sheet that covers half the screen
  void _showMoreProducts(BuildContext context, List<Product> currentProducts) {
    final title = isSuggestedSelected
        ? 'More Suggested Products'
        : 'More Trending Products';

    MoreProductsBottomSheetHelper.show(
      context: context,
      title: title,
      isSuggestedSelected: isSuggestedSelected,
      onProductTap: (product) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(product: product),
            ),
          );
        }
      },
    );
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
              minExtent: 130, 
              maxExtent: 170,
              builder: (context, shrinkOffset, overlapsContent) {
                final bool showTabs = shrinkOffset < 60;
                final double appBarHeight = showTabs ? 170 : 130;
                return FancyAppBar(
                  tabs: const ['Suggested for you', 'Trending'],
                  selectedIndex: isSuggestedSelected ? 0 : 1,
                  onTabChanged: (index) {
                    setState(() {
                      isSuggestedSelected = index == 0;
                    });

                    // Load appropriate products based on selected tab
                    if (index == 0) {
                      // Suggested for you tab
                      _loadSuggestedProducts();
                    } else {
                      // Trending tab
                      _loadTrendingProducts();
                    }
                  },
                  title: '',
                  height: appBarHeight,
                  showTabs: showTabs,
                  customContent: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                        left: 16,
                        right: 8,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  custom.SearchBar(
                                    controller: _searchController,
                                    hintText: 'Search products...',
                                    isVisible: _showSearch,
                                    onClose: _toggleSearch,
                                    onChanged: _onSearchChanged,
                                    onSubmitted: _performMLSearch,
                                  ),
                                  if (_showSuggestions &&
                                      _searchSuggestions.isNotEmpty)
                                    Positioned(
                                      top: 45,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: _searchSuggestions.map((
                                            suggestion,
                                          ) {
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.search,
                                                size: 16,
                                              ),
                                              title: Text(
                                                suggestion,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              onTap: () =>
                                                  _onSuggestionSelected(
                                                    suggestion,
                                                  ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                ],
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EnhancedSearchScreen(),
                                  ),
                                );
                              },
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.black87,
                              size: 24,
                            ),
                            onPressed: _navigateToNotifications,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
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
            child: Builder(
              builder: (context) {
                // Determine which products to show based on selected tab
                List<Product> displayProducts = [];
                bool isLoading = false;

                if (isSuggestedSelected) {
                  // Show suggested products
                  if (_suggestedProducts.isEmpty && !_isLoadingSuggested) {
                    // Load suggested products on first tab selection
                    _loadSuggestedProducts();
                  }
                  displayProducts = _suggestedProducts;
                  isLoading = _isLoadingSuggested;
                } else {
                  // Show trending products
                  if (_trendingProducts.isEmpty && !_isLoadingTrending) {
                    // Load trending products on first tab selection
                    _loadTrendingProducts();
                  }
                  displayProducts = _trendingProducts;
                  isLoading = _isLoadingTrending;
                }

                if (isLoading) {
                  return const CarouselLoading();
                }

                if (displayProducts.isEmpty) {
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
                            isSuggestedSelected
                                ? 'No suggested products'
                                : 'No trending products',
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

                if (displayProducts.length < 3) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Stack(
                    children: [
                      Carousel(
                        items: [displayProducts.sublist(0, 3)].map((group) {
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
                      // View More button positioned at bottom right
                      Positioned(
                        bottom:
                            12, // Increased spacing between carousel and button
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.suggestedTabBrown,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _showMoreProducts(context, displayProducts);
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'View More',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                // Filter out products that are out of stock
                final inStockProducts = products.where((product) {
                  // Show product if stock is null (not specified) or greater than 0
                  return product.stock == null || product.stock! > 0;
                }).toList();

                if (inStockProducts.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No products in stock',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                    mainAxisExtent: 260,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index >= inStockProducts.length) return null;
                    final product = inStockProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () async {
                        // Record product view interaction for ML
                        try {
                          await EnhancedProductService.recordUserInteraction(
                            productId: product.id,
                            interactionType: 'view',
                            metadata: {
                              'product_name': product.name,
                              'category': product.category ?? 'general',
                            },
                          );
                        } catch (e) {
                          print('Error recording product view: $e');
                        }

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
                  }, childCount: inStockProducts.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
