import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../services/enhanced_product_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_card_loading.dart';
import '../../Theme/app_theme.dart';

class ProductRecommendations extends StatefulWidget {
  final String? category;
  final int limit;
  final String title;
  final bool showTitle;
  final VoidCallback? onViewAllPressed;

  const ProductRecommendations({
    super.key,
    this.category,
    this.limit = 10,
    this.title = 'Recommended for you',
    this.showTitle = true,
    this.onViewAllPressed,
  });

  @override
  State<ProductRecommendations> createState() => _ProductRecommendationsState();
}

class _ProductRecommendationsState extends State<ProductRecommendations> {
  late Future<List<Product>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    _recommendationsFuture = EnhancedProductService.getPersonalizedRecommendations(
      limit: widget.limit,
      category: widget.category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (widget.onViewAllPressed != null)
                  TextButton(
                    onPressed: widget.onViewAllPressed,
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        FutureBuilder<List<Product>>(
          future: _recommendationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            } else if (snapshot.hasError) {
              return _buildErrorState();
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final products = snapshot.data!;
            return _buildProductsList(products);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ProductCardLoading(),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.grey,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Failed to load recommendations',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.recommend,
              color: Colors.grey,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'No recommendations yet',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              'Browse more products to get personalized recommendations',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ProductCard(
              product: product,
              onTap: () {
                // Record interaction for ML
                EnhancedProductService.clickProduct(productId: product.id);
                // Navigate to product details
                Navigator.pushNamed(
                  context,
                  '/product-details',
                  arguments: product,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class TrendingProducts extends StatefulWidget {
  final String? category;
  final int limit;
  final String timeFrame;
  final bool showTitle;

  const TrendingProducts({
    super.key,
    this.category,
    this.limit = 10,
    this.timeFrame = 'week',
    this.showTitle = true,
  });

  @override
  State<TrendingProducts> createState() => _TrendingProductsState();
}

class _TrendingProductsState extends State<TrendingProducts> {
  late Future<List<Product>> _trendingFuture;

  @override
  void initState() {
    super.initState();
    _loadTrendingProducts();
  }

  void _loadTrendingProducts() {
    _trendingFuture = EnhancedProductService.getTrendingProducts(
      limit: widget.limit,
      category: widget.category,
      timeFrame: widget.timeFrame,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppTheme.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trending ${_getTimeFrameText()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        FutureBuilder<List<Product>>(
          future: _trendingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            } else if (snapshot.hasError) {
              return _buildErrorState();
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final products = snapshot.data!;
            return _buildProductsList(products);
          },
        ),
      ],
    );
  }

  String _getTimeFrameText() {
    switch (widget.timeFrame) {
      case 'day':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      default:
        return 'Now';
    }
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ProductCardLoading(),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.grey,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Failed to load trending products',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              color: Colors.grey,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'No trending products',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ProductCard(
              product: product,
              onTap: () {
                // Record interaction for ML
                EnhancedProductService.clickProduct(productId: product.id);
                // Navigate to product details
                Navigator.pushNamed(
                  context,
                  '/product-details',
                  arguments: product,
                );
              },
            ),
          );
        },
      ),
    );
  }
} 