import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../services/enhanced_product_service.dart';
import '../widgets/ml_search_suggestions.dart';
import '../../widgets/product_card.dart';
import '../../Theme/app_theme.dart';

class EnhancedSearchScreen extends StatefulWidget {
  final String? initialQuery;
  final List<Product>? initialResults;

  const EnhancedSearchScreen({
    super.key,
    this.initialQuery,
    this.initialResults,
  });

  @override
  State<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Product> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  String _currentQuery = '';
  
  // Filter states
  String? _selectedCategory;
  double _minPrice = 0;
  double _maxPrice = 1000000;
  String _sortBy = 'relevance';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_onSearchChanged);
    
    // Initialize with provided data
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _currentQuery = widget.initialQuery!;
    }
    
    if (widget.initialResults != null) {
      _searchResults = widget.initialResults!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    // Load recent searches from shared preferences
    // This is a placeholder - implement with SharedPreferences
    _recentSearches = ['laptop', 'phone', 'books', 'furniture'];
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _currentQuery = query;
      _showSuggestions = query.isNotEmpty;
    });
  }

  Future<void> _performSearch(String query) async {
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
        filters: {
          'category': _selectedCategory,
          'min_price': _minPrice,
          'max_price': _maxPrice,
        },
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // Add to recent searches
      if (!_recentSearches.contains(query)) {
        setState(() {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 10) {
            _recentSearches.removeLast();
          }
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _onSuggestionSelected(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  void _onRecentSearchSelected(String search) {
    _searchController.text = search;
    _performSearch(search);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showSuggestions = false;
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = null;
                          _minPrice = 0;
                          _maxPrice = 1000000;
                          _sortBy = 'relevance';
                        });
                        Navigator.pop(context);
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      },
                      child: const Text('Clear'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategoryFilter(),
                const SizedBox(height: 20),
                _buildPriceFilter(),
                const SizedBox(height: 20),
                _buildSortFilter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Electronics', 'Books', 'Furniture', 'Clothing'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category || 
                             (_selectedCategory == null && category == 'All');
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 1000000,
          divisions: 100,
          labels: RangeLabels(
            'UGX ${_minPrice.toStringAsFixed(0)}',
            'UGX ${_maxPrice.toStringAsFixed(0)}',
          ),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSortFilter() {
    final sortOptions = [
      {'value': 'relevance', 'label': 'Relevance'},
      {'value': 'price_low', 'label': 'Price: Low to High'},
      {'value': 'price_high', 'label': 'Price: High to Low'},
      {'value': 'date', 'label': 'Newest First'},
      {'value': 'popularity', 'label': 'Most Popular'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...sortOptions.map((option) {
          return RadioListTile<String>(
            title: Text(option['label']!),
            value: option['value']!,
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search products...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: _currentQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
            onSubmitted: _performSearch,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search suggestions
          if (_showSuggestions)
            MLSearchSuggestions(
              partialQuery: _currentQuery,
              onSuggestionSelected: _onSuggestionSelected,
              showSuggestions: _showSuggestions,
            ),
          
          // Recent searches (when no query and no results)
          if (!_showSuggestions && _searchResults.isEmpty && _recentSearches.isNotEmpty)
            _buildRecentSearches(),
          
          // Search results
          Expanded(
            child: _isSearching
                ? _buildLoadingState()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return FilterChip(
                label: Text(search),
                onSelected: (selected) => _onRecentSearchSelected(search),
                backgroundColor: Colors.grey[100],
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeRecentSearch(search),
                deleteIconColor: Colors.grey[600],
                selected: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Searching...'),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && _currentQuery.isNotEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Try different keywords or filters',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
    );
  }
} 