// ignore_for_file: deprecated_member_use, unused_import, duplicate_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/services/notifications_service.dart'
    show NotificationService;
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/widgets/profile_pic_widget.dart';
import '../models/product.dart';
import '../Theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/message_screen.dart';
import '../screens/chats_screen.dart';
import '../services/chats_service.dart';
import '../models/chat_models.dart';
import '../models/seller.dart';
import '../services/seller_service.dart';
import '../services/firebase_comment.dart';
import '../services/firebase_rating.dart';
import '../ml/services/enhanced_product_service.dart';
import '../services/cart_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  double rating = 0.0;
  double? userRating;
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
  final RatingService _ratingService = RatingService();
  final CartService _cartService = CartService();
  Seller? seller;
  bool isLoadingSeller = true;
  bool _isAddingToCart = false;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    print('Product Details - Product: ${widget.product.name}');
    print('Product Details - Stock: ${widget.product.stock}');
    print('Product Details - Initial quantity: $quantity');
    _loadSellerInfo();
    _loadUserRating();
    _trackProductView();
  }

  void _trackProductView() async {
    // Track product view interaction with ML API
    try {
      await EnhancedProductService.recordUserInteraction(
        productId: widget.product.id,
        interactionType: 'view_details',
        metadata: {
          'product_name': widget.product.name,
          'category': widget.product.category ?? 'general',
          'price': widget.product.price?.toString() ?? '0',
          'source': 'product_details_page',
        },
      );
    } catch (e) {
      print('Error recording product view details interaction: $e');
    }
  }

  Future<void> _loadSellerInfo() async {
    try {
      final sellerData = await SellerService.getSellerById(
        widget.product.ownerId,
      );
      if (mounted) {
        setState(() {
          seller = sellerData;
          isLoadingSeller = false;
        });
      }
    } catch (e) {
      print('Error loading seller info: $e');
      if (mounted) {
        setState(() {
          isLoadingSeller = false;
        });
      }
    }
  }

  Future<void> _loadUserRating() async {
    final r = await _ratingService.getUserRating(widget.product.id);
    setState(() {
      userRating = r ?? 0.0;
      rating = userRating ?? 0.0;
    });
  }

  void _updateRating(double newRating) async {
    setState(() {
      rating = newRating;
    });
    await _ratingService.setRating(widget.product.id, newRating);
    
    // Track rating interaction with ML API
    try {
      await EnhancedProductService.recordUserInteraction(
        productId: widget.product.id,
        interactionType: 'rating',
        metadata: {
          'product_name': widget.product.name,
          'category': widget.product.category ?? 'general',
          'rating_value': newRating.toString(),
          'previous_rating': userRating?.toString() ?? '0',
        },
      );
    } catch (e) {
      print('Error recording rating interaction: $e');
    }
    
    _loadUserRating();
  }

  Widget _buildSellerInfo() {
    if (isLoadingSeller) {
      return Row(
        children: [
          ProfilePicWidget(
            imageUrl: null,
            radius: 14,
            height: 28,
            width: 28,
            onAddPressed: null,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Loading seller info...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      );
    }

    if (seller == null) {
      return Row(
        children: [
          ProfilePicWidget(
            imageUrl: null,
            radius: 14,
            height: 28,
            width: 28,
            onAddPressed: null,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Seller information not available',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        ProfilePicWidget(
          imageUrl: seller!.profileImageUrl,
          radius: 14,
          height: 28,
          width: 28,
          onAddPressed: null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seller!.businessName,
                style: AppTheme.subtitleStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'by ${seller!.name}',
                style: AppTheme.subtitleStyle.copyWith(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateQuantity(bool increment) {
    print(
      '_updateQuantity called: increment=$increment, current quantity=$quantity, stock=${widget.product.stock}',
    );
    setState(() {
      if (increment && quantity < (widget.product.stock ?? 0)) {
        quantity++;
        print('Quantity increased to: $quantity');
      } else if (!increment && quantity > 1) {
        quantity--;
        print('Quantity decreased to: $quantity');
      } else {
        print('Quantity not changed - out of bounds');
      }
    });
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add items to cart'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check stock availability first
    if (quantity > (widget.product.stock ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot add ${widget.product.name}. Only ${widget.product.stock} items available',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Add item to cart using the CartService
      await _cartService.addToCart(
        productId: widget.product.id,
        productName: widget.product.name,
        productImage: widget.product.imageUrl,
        price: widget.product.price ?? 0.0,
        quantity: quantity,
        sellerId: widget.product.ownerId,
        sellerName: 'Seller', // Product model doesn't have seller name
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${widget.product.name} to cart!'),
          backgroundColor: AppTheme.primaryOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  void _addComment() async {
    if (_commentController.text.trim().isNotEmpty) {
      final comment = await _commentService.addComment(
        widget.product.id,
        _commentController.text.trim(),
      );
      if (comment != null) {
        _commentController.clear();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add comment. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildCommentsList() {
    return StreamBuilder<List<Comment>>(
      stream: _commentService.getCommentsForProduct(widget.product.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading comments: ${snapshot.error}',
              style: TextStyle(color: Colors.red[300]),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data ?? [];
        if (comments.isEmpty) {
          return Center(
            child: Text(
              'No comments yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.borderGrey.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightGrey,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: AppTheme.borderGrey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.text,
                          style: AppTheme.subtitleStyle.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(comment.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (comment.userId == FirebaseAuth.instance.currentUser?.uid)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red[300],
                      onPressed: () async {
                        final success = await _commentService.deleteComment(
                          comment.id,
                        );
                        if (!success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to delete comment'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 80,
                color: Colors.grey,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 80,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTheme.chipTextStyle.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.subtitleStyle.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLavender,
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Product Details',
          style: AppTheme.titleStyle.copyWith(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsScreen(
                  userRole: UserRole.buyer,
                  userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  final images =
                      widget.product.imageUrls != null &&
                          widget.product.imageUrls!.isNotEmpty
                      ? widget.product.imageUrls!
                      : (widget.product.imageUrl.isNotEmpty
                            ? [widget.product.imageUrl]
                            : []);
                  if (images.length > 1) {
                    int _currentPage = 0;
                    final PageController _pageController = PageController();
                    return StatefulBuilder(
                      builder: (context, setState) => Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: images.length,
                                onPageChanged: (index) =>
                                    setState(() => _currentPage = index),
                                itemBuilder: (context, index) =>
                                    _buildImage(images[index]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: _currentPage == index ? 12 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? AppTheme.primaryOrange
                                      : AppTheme.lightGrey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: images.isNotEmpty
                            ? _buildImage(images.first)
                            : Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: AppTheme.paleWhite,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description,
                        style: AppTheme.subtitleStyle,
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.priceAndDiscount,
                            style: AppTheme.titleStyle.copyWith(
                              fontSize: 20,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.product.originalPrice.isNotEmpty &&
                              widget.product.originalPrice !=
                                  widget.product.priceAndDiscount)
                            Text(
                              'Original: ${widget.product.originalPrice}',
                              style: AppTheme.subtitleStyle.copyWith(
                                fontSize: 14,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          if (widget.product.price != null &&
                              widget.product.price! > 0)
                            Text(
                              'UGX ${widget.product.price!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: AppTheme.subtitleStyle.copyWith(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.verified_outlined,
                                    label: 'Condition',
                                    value: widget.product.condition,
                                    color:
                                        widget.product.condition
                                                .toLowerCase() ==
                                            'new'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.location_on_outlined,
                                    label: 'Location',
                                    value: widget.product.location,
                                    color: AppTheme.primaryOrange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.category_outlined,
                                    label: 'Category',
                                    value: widget.product.category ?? 'General',
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.inventory_outlined,
                                    label: 'Stock',
                                    value: widget.product.stock != null
                                        ? '${widget.product.stock} available'
                                        : 'In stock',
                                    color: (widget.product.stock ?? 1) > 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.product.bestOffer)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_offer,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Best Offer Available',
                                      style: AppTheme.chipTextStyle.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Quantity Selector
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.lightGrey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Quantity:',
                              style: AppTheme.subtitleStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.lightGrey,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    onPressed: quantity > 1
                                        ? () => _updateQuantity(false)
                                        : null,
                                    icon: const Icon(Icons.remove),
                                    iconSize: 18,
                                    color: quantity > 1
                                        ? AppTheme.primaryOrange
                                        : AppTheme.lightGrey,
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.lightGrey,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    onPressed:
                                        quantity < (widget.product.stock ?? 0)
                                        ? () => _updateQuantity(true)
                                        : null,
                                    icon: const Icon(Icons.add),
                                    iconSize: 18,
                                    color:
                                        quantity < (widget.product.stock ?? 0)
                                        ? AppTheme.primaryOrange
                                        : AppTheme.lightGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSellerInfo(),
                      const SizedBox(height: 14),
                      StreamBuilder<double>(
                        stream: _ratingService.getAverageRating(
                          widget.product.id,
                        ),
                        builder: (context, snapshot) {
                          final avgRating = snapshot.data ?? 0.0;
                          return Row(
                            children: [
                              Text('Rating:', style: AppTheme.chipTextStyle),
                              const SizedBox(width: 8),
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  index < avgRating.round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: AppTheme.primaryOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          5,
                          (index) => GestureDetector(
                            onTap: () => _updateRating(index + 1.0),
                            child: Icon(
                              Icons.star,
                              color: index < rating
                                  ? AppTheme.primaryOrange
                                  : AppTheme.lightGrey,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      if (userRating != null && userRating! > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Your rating: ${userRating!.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isAddingToCart ? null : _addToCart,
                              icon: _isAddingToCart
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.shopping_cart_outlined),
                              label: Text(
                                _isAddingToCart ? 'Adding...' : 'Add to Cart',
                                style: AppTheme.buttonTextStyle,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final currentUser =
                                    FirebaseAuth.instance.currentUser;
                                if (currentUser == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please log in to chat'),
                                    ),
                                  );
                                  return;
                                }

                                if (currentUser.uid == widget.product.ownerId) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'You cannot start a chat with yourself',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  final chatService = ChatService();
                                  final chatRoomId = await chatService
                                      .createOrGetChatRoom(
                                        sellerId: widget.product.ownerId,
                                        buyerId: currentUser.uid,
                                        productId: widget.product.id,
                                        productName: widget.product.name,
                                        productImageUrl:
                                            widget.product.imageUrl,
                                        productPrice: widget.product.price
                                            .toString(),
                                        productDescription:
                                            widget.product.description,
                                        sellerName: seller?.name ?? 'Seller',
                                        buyerName:
                                            currentUser.displayName ??
                                            'Unknown User',
                                      );

                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MessageScreen(
                                        chatRoomId: chatRoomId,
                                        otherParticipantName:
                                            seller?.name ?? 'Seller',
                                        otherParticipantId:
                                            widget.product.ownerId,
                                        productName: widget.product.name,
                                        productImageUrl:
                                            widget.product.imageUrl,
                                        userName:
                                            currentUser.displayName ??
                                            'Unknown User',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to start chat: $e'),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: Text(
                                'Chat Seller',
                                style: AppTheme.buttonTextStyle,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.lightGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comments',
                        style: AppTheme.titleStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.lightGrey,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppTheme.borderGrey.withOpacity(0.2),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: 'Add your comment...',
                                  hintStyle: AppTheme.subtitleStyle,
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                                minLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addComment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Add Comment',
                              style: AppTheme.chipTextStyle.copyWith(
                                color: AppTheme.paleWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildCommentsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        navBarColor: AppTheme.tertiaryOrange,
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
