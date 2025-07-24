// ignore_for_file: deprecated_member_use, unused_import, duplicate_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/services/notificaations_service.dart' show NotificationService;
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/widgets/profile_pic_widget.dart';
import '../models/product.dart';
import '../Theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/message_screen.dart'; // Added import for MessageScreen
import '../screens/chats_screen.dart'; // Added import for ChatsScreen
import '../models/seller.dart'; // Added import for Seller
import '../services/seller_service.dart'; // Added import for SellerService
import '../services/firebase_comment.dart';
import '../services/firebase_rating.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  // Simple in-memory cart for demo (public static)
  static final List<Product> cart = [];

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  double rating = 0.0;
  double? userRating;
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
  final RatingService _ratingService = RatingService();
  Seller? seller;
  bool isLoadingSeller = true;

  @override
  void initState() {
    super.initState();
    _loadSellerInfo();
    _loadUserRating();
  }

  Future<void> _loadSellerInfo() async {
    try {
      final sellerData = await SellerService.getSellerById(widget.product.ownerId);
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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
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
    setState(() {
      if (increment) {
        quantity++;
      } else {
        if (quantity > 1) quantity--;
      }
    });
  }

  void _addComment() async {
    if (_commentController.text.trim().isNotEmpty) {
      final comment = await _commentService.addComment(
        widget.product.id,
        _commentController.text.trim(),
      );
      
      if (comment != null) {
        _commentController.clear();
        // The UI will update automatically through the stream
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
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                              ),
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
                        final success = await _commentService.deleteComment(comment.id);
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
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

  // Helper method to build detail rows
  Widget _buildDetailRow({
    required String label,
    required String value,
    TextStyle? valueStyle,
    Widget? suffix,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120, // Increased width for labels
          child: Text(
            label + ':',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700, // Made bolder
              color: AppTheme.textPrimary, // Changed to primary color
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: valueStyle ?? TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.3, // Added line height for better readability
                  ),
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ),
      ],
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
                builder: (context) =>
                    NotificationsScreen(userRole: UserRole.buyer, userId: FirebaseAuth.instance.currentUser?.uid ?? '',),
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
              // Product Image with proper constraints
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
                            height: 300, // Increased height
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
                                itemBuilder: (context, index) => _buildImage(images[index]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
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
                      height: 300, // Increased height
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
              // (Search bar removed)
              // Product details section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      label: 'Description',
                      value: widget.product.description,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      label: 'Location',
                      value: widget.product.location,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      label: 'Condition',
                      value: widget.product.condition,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      label: 'Price',
                      value: widget.product.formattedDiscountedPrice,
                      valueStyle: const TextStyle(
                        color: Colors.green,
                          fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      suffix: widget.product.discountPercentage != null
                          ? Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            child: Text(
                                '${widget.product.discountPercentage!.round()}% off',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Seller Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSellerInfo(),
                    const SizedBox(height: 20),
                    // Rating section
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<double>(
                      stream: _ratingService.getAverageRating(widget.product.id),
                      builder: (context, snapshot) {
                        final avgRating = snapshot.data ?? 0.0;
                        return Row(
                          children: [
                            ...List.generate(5, (index) => Icon(
                              index < avgRating.round()
                                ? Icons.star
                                : Icons.star_border,
                              color: AppTheme.primaryOrange,
                              size: 24,
                            )),
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
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    if (userRating != null && userRating! > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Your rating: ${userRating!.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ),
                    const SizedBox(height: 24),
                    // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                              if (!ProductDetailsPage.cart.contains(widget.product)) {
                                  ProductDetailsPage.cart.add(widget.product);
                                  // Send notification
                                  NotificationService.sendCartReminder(
                                      userId: 'current_user_id', // Pass the actual user ID
                                      itemCount: ProductDetailsPage.cart.length,
          );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added ${widget.product.name} to cart!',
                                      ),
                                      backgroundColor: AppTheme.primaryOrange,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${widget.product.name} is already in your cart.',
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.shopping_cart_outlined),
                              label: Text(
                                'Add to Cart',
                                style: AppTheme.buttonTextStyle,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                vertical: 16,
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageScreen(
                                    userName: widget.product.ownerId,
                                    chatRoomId: '',
                                    otherParticipantName: seller?.name ?? '',
                                    otherParticipantId: widget.product.ownerId,
                                    productName: widget.product.name,
                                  ),
                                  ),
                                );
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
                                vertical: 16,
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
              // Comments Section at the bottom
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
                      // Add comment input
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
                      // Comments list
                      _buildCommentsList(),
                              ],
                            ),
                                  ),
                                ),
                              ],
                            ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 0, navBarColor: AppTheme.tertiaryOrange),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
