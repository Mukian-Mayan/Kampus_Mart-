import 'package:flutter/material.dart';
import '../models/product.dart';
import '../Theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../services/product_service.dart';
import '../ml/services/enhanced_product_service.dart';
import '../screens/product_details_page.dart';

class MoreProductsBottomSheet extends StatelessWidget {
  final String title;
  final bool isSuggestedSelected;
  final Function(Product) onProductTap;

  const MoreProductsBottomSheet({
    super.key,
    required this.title,
    required this.isSuggestedSelected,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          const Divider(height: 1),
          // Content
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _loadMoreProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _buildErrorState();
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final products = snapshot.data!;
                return _buildProductGrid(context, products);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.tertiaryOrange,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No more products available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
        mainAxisExtent: 260, // Same as homepage
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
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

            // Close bottom sheet and navigate to product details
            Navigator.of(context).pop();
            onProductTap(product);
          },
        );
      },
    );
  }

  // Load more products based on current tab
  Future<List<Product>> _loadMoreProducts() async {
    try {
      if (isSuggestedSelected) {
        print('Loading more suggested products...');
        final products =
            await EnhancedProductService.getPersonalizedRecommendations(
              limit: 20, // Load more products
            );
        print('Loaded ${products.length} more suggested products');
        return products;
      } else {
        print('Loading more trending products...');
        final products = await EnhancedProductService.getTrendingProducts(
          limit: 20, // Load more products
        );
        print('Loaded ${products.length} more trending products');
        return products;
      }
    } catch (e) {
      print('Error loading more products: $e');
      // Fallback to regular products
      final fallbackProducts = await ProductService.getAllProducts();
      return fallbackProducts.take(20).toList();
    }
  }
}

// Helper function to show the bottom sheet
class MoreProductsBottomSheetHelper {
  static void show({
    required BuildContext context,
    required String title,
    required bool isSuggestedSelected,
    required Function(Product) onProductTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return MoreProductsBottomSheet(
          title: title,
          isSuggestedSelected: isSuggestedSelected,
          onProductTap: onProductTap,
        );
      },
    );
  }
} 