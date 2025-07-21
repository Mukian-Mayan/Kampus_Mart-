// ignore_for_file: deprecated_member_use, unused_import, duplicate_import

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/widgets/profile_pic_widget.dart';
import '../models/product.dart';
import '../Theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/message_screen.dart'; // Added import for MessageScreen
import '../screens/chats_screen.dart'; // Added import for ChatsScreen

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
  List<String> comments = [
    'Great product! Highly recommend.',
    'Good value for the price.',
    'Not what I expected.',
    'Would buy again.',
  ];
  final TextEditingController _commentController = TextEditingController();

  void _updateQuantity(bool increment) {
    setState(() {
      if (increment) {
        quantity++;
      } else {
        if (quantity > 1) quantity--;
      }
    });
  }

  void _updateRating(double newRating) {
    setState(() {
      rating = newRating;
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        comments.insert(0, _commentController.text.trim());
        _commentController.clear();
      });
      // Removed Navigator.pop(context); so the input stays open
    }
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.paleWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Comments',
                  style: AppTheme.titleStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 16),
                // Add comment section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 100, // Limit height to prevent overflow
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
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: AppTheme.subtitleStyle.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addComment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Add Comment',
                              style: AppTheme.chipTextStyle.copyWith(
                                color: AppTheme.paleWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Comments list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.tertiaryOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfilePicWidget(
                              imageUrl: null, // Default profile image
                              radius: 16,
                              height: 32,
                              width: 32,
                              onAddPressed: null, // No camera icon for comments
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                comments[index],
                                style: AppTheme.subtitleStyle.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
                builder: (context) =>
                    const NotificationsScreen(userRole: UserRole.buyer),
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
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGrey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: images.length,
                                onPageChanged: (index) =>
                                    setState(() => _currentPage = index),
                                itemBuilder: (context, index) => Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 80,
                                      color: AppTheme.textSecondary,
                                    );
                                  },
                                ),
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
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: images.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 80,
                                    color: AppTheme.textSecondary,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.shopping_bag_outlined,
                              size: 80,
                              color: AppTheme.textSecondary,
                            ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              // (Search bar removed)
              // Product Details Card
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
                      // Product Name
                      Text(
                        widget.product.name,
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        widget.product.description,
                        style: AppTheme.subtitleStyle,
                      ),
                      const SizedBox(height: 10),
                      // Cost
                      Text(
                        widget.product.priceAndDiscount,
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Condition and Location
                      Row(
                        children: [
                          Text(
                            'Condition: ',
                            style: AppTheme.subtitleStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.product.condition,
                            style: AppTheme.subtitleStyle,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Location: ',
                            style: AppTheme.subtitleStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.product.location,
                            style: AppTheme.subtitleStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Seller Info
                      Row(
                        children: [
                          ProfilePicWidget(
                            imageUrl: null,
                            radius: 14,
                            height: 28,
                            width: 28,
                            onAddPressed: null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Seller: ${widget.product.ownerId}',
                              style: AppTheme.subtitleStyle.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Rating
                      Row(
                        children: [
                          Text('Rating:', style: AppTheme.chipTextStyle),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      // (Comment button removed; comments section is now only at the bottom)
                      const SizedBox(height: 18),
                      // Action Buttons in One Row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (!ProductDetailsPage.cart.contains(
                                  widget.product,
                                )) {
                                  ProductDetailsPage.cart.add(widget.product);
                                  // Send notification
                                  NotificationsScreen.addBuyerNotification(
                                    NotificationModel(
                                      id: DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                      title: 'Item Added to Cart',
                                      message:
                                          'You added ${widget.product.name} to your cart.',
                                      type: NotificationType.cartReminder,
                                      timestamp: DateTime.now(),
                                      userRole: UserRole.buyer,
                                    ),
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageScreen(
                                      userName: widget.product.ownerId, chatRoomId: '', otherParticipantName: '', otherParticipantId: '', productName: '',
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
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
                                  child: Text(
                                    comments[index],
                                    style: AppTheme.subtitleStyle.copyWith(
                                      color: AppTheme.textPrimary,
                                    ),
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
