// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/screens/notification_screen.dart'
    as notification_screen;
import 'package:kampusmart2/screens/payment_transactions.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_model.dart';
import '../models/order.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';
import '../services/notifications_service.dart';

class CartPage extends StatefulWidget {
  static const String routeName = '/Cart';
  final UserRole userRole;
  const CartPage({super.key, required this.userRole});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? userRole;
  int selectedIndex = 1;
  final CartService _cartService = CartService();
  List<CartModel> cartItems = [];
  Map<String, Product> productsMap = {};
  bool isLoading = true;
  String searchQuery = '';
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadCartItems();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role');
    });
  }

  Future<void> _loadCartItems() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get cart items from Firebase
      final cartStream = _cartService.getUserCart();
      cartStream.listen((items) async {
        setState(() {
          cartItems = items;
        });

        // Load product details for each cart item
        await _loadProductDetails();
        _calculateTotal();

        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadProductDetails() async {
    for (var cartItem in cartItems) {
      try {
        final product = await ProductService.getProductById(cartItem.productId);
        if (product != null) {
          productsMap[cartItem.productId] = product;
        }
      } catch (e) {
        print('Error loading product ${cartItem.productId}: $e');
      }
    }
  }

  void _calculateTotal() {
    totalAmount = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  Future<void> _updateQuantity(CartModel cartItem, bool increment) async {
    try {
      final product = productsMap[cartItem.productId];
      int newQuantity = cartItem.quantity;

      if (increment) {
        // Check if we can increment (stock validation)
        if (product != null && product.stock != null) {
          if (newQuantity >= product.stock!) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Only ${product.stock} items available in stock'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
        }
        newQuantity++;
      } else {
        if (newQuantity > 1) {
          newQuantity--;
        } else {
          return; // Don't allow quantity to go below 1
        }
      }

      await _cartService.updateCartItemQuantity(cartItem.id, newQuantity);

      // Update local state immediately for better UX
      setState(() {
        final index = cartItems.indexWhere((item) => item.id == cartItem.id);
        if (index != -1) {
          cartItems[index] = cartItem.copyWith(quantity: newQuantity);
        }
        _calculateTotal();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating quantity: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeFromCart(CartModel cartItem) async {
    try {
      await _cartService.removeFromCart(cartItem.id);

      setState(() {
        cartItems.removeWhere((item) => item.id == cartItem.id);
        productsMap.remove(cartItem.productId);
        _calculateTotal();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${cartItem.productName} from cart'),
          backgroundColor: AppTheme.lightGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate stock availability before placing order
    for (var cartItem in cartItems) {
      final product = productsMap[cartItem.productId];
      if (product != null && product.stock != null) {
        if (cartItem.quantity > product.stock!) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${cartItem.productName} has only ${product.stock} items in stock. Please update your cart.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }
      }
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to place an order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate directly to payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentTransactions(
          totalAmount: totalAmount,
          cartItems: cartItems,
          productsMap: productsMap,
        ),
      ),
    );
  }

  Future<Order> _createSingleOrder(
    User currentUser,
    String paymentMethod,
  ) async {
    // Group cart items by seller and take the first seller for now
    // (You might want to handle multiple sellers differently)
    Map<String, List<CartModel>> itemsBySeller = {};
    for (var cartItem in cartItems) {
      final product = productsMap[cartItem.productId];
      if (product != null) {
        final sellerId = product.ownerId;
        if (!itemsBySeller.containsKey(sellerId)) {
          itemsBySeller[sellerId] = [];
        }
        itemsBySeller[sellerId]!.add(cartItem);
      }
    }

    // For now, create order with the first seller's items
    // TODO: Handle multiple sellers properly
    final firstSeller = itemsBySeller.entries.first;
    final sellerId = firstSeller.key;
    final sellerItems = firstSeller.value;

    // Convert cart items to order items
    List<OrderItem> orderItems = sellerItems.map((cartItem) {
      return OrderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: cartItem.productId,
        productName: cartItem.productName,
        productImage: cartItem.productImage ?? '',
        price: cartItem.price,
        quantity: cartItem.quantity,
        subtotal: cartItem.price * cartItem.quantity,
      );
    }).toList();

    double subtotal = orderItems.fold(0.0, (sum, item) => sum + item.subtotal);
    double deliveryFee = 5000.0; // Fixed delivery fee

    // Create delivery address (placeholder - you might want to get this from user)
    DeliveryAddress deliveryAddress = DeliveryAddress(
      street: 'Default Street',
      city: 'Kampala',
      state: 'Central',
      postalCode: '00000',
      country: 'Uganda',
    );

    final order = await OrderService.createOrder(
      buyerId: currentUser.uid,
      name: currentUser.displayName ?? 'Customer',
      email: currentUser.email ?? '',
      phone: currentUser.phoneNumber ?? '',
      sellerId: sellerId,
      items: orderItems,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      notes: 'Order placed from app',
    );

    return order;
  }

  Future<void> _completeOrderProcess() async {
    // Update product stock and send notifications
    for (var cartItem in cartItems) {
      final product = productsMap[cartItem.productId];
      if (product != null && product.stock != null) {
        final newStock = (product.stock! - cartItem.quantity)
            .clamp(0, double.infinity)
            .toInt();
        try {
          await ProductService.updateProductStockForOrder(
            productId: cartItem.productId,
            newStock: newStock,
          );

          // Send low stock alert if needed
          if (newStock <= 5 && newStock > 0) {
            await NotificationService.sendLowStockAlert(
              sellerId: product.ownerId,
              productName: cartItem.productName,
              remainingStock: newStock,
            );
          }
        } catch (e) {
          print('Error updating product stock: $e');
        }
      }
    }

    // Clear the cart
    await _cartService.clearCart();

    Navigator.of(context).pop(); // Close loading dialog

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been placed successfully. You will receive notifications about the status.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    // Clear local cart state
    setState(() {
      cartItems.clear();
      totalAmount = 0.0;
    });
  }

  void _onOrderPaymentSuccess() {
    // Clear the cart and show success
    _cartService.clearCart();

    // Clear local cart state
    setState(() {
      cartItems.clear();
      totalAmount = 0.0;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed and payment processed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<String?> _showPaymentMethodDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.payment, color: AppTheme.primaryOrange),
              SizedBox(width: 8),
              Text(
                'Select Payment Method',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose how you would like to pay for your order:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildPaymentOption(
                'Cash on Delivery',
                Icons.money,
                'Pay when your order is delivered',
                () => Navigator.of(context).pop('Cash on Delivery'),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                'Mobile Money',
                Icons.phone_android,
                'Pay via MTN Mobile Money or Airtel Money',
                () => Navigator.of(context).pop('Mobile Money'),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                'Bank Transfer',
                Icons.account_balance,
                'Transfer money directly to seller account',
                () => Navigator.of(context).pop('Bank Transfer'),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                'Card Payment',
                Icons.credit_card,
                'Pay with your debit or credit card',
                () => Navigator.of(context).pop('Card Payment'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentOption(
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryOrange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCartItems = cartItems.where((cartItem) {
      final query = searchQuery.toLowerCase();
      return cartItem.productName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.paleWhite,
      bottomNavigationBar: widget.userRole == UserRole.seller
          ? BottomNavBar2(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            )
          : BottomNavBar(
              selectedIndex: selectedIndex,
              navBarColor: AppTheme.tertiaryOrange,
            ),
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Cart',
          style: AppTheme.titleStyle.copyWith(
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => notification_screen.NotificationsScreen(
                  userRole: UserRole.buyer,
                  userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search cart items',
                hintStyle: AppTheme.subtitleStyle,
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
            ),
          ),

          // Cart Items
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryOrange,
                      ),
                    ),
                  )
                : cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 60,
                          color: AppTheme.borderGrey,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'You have no items in your cart',
                          style: AppTheme.titleStyle.copyWith(
                            fontSize: 20,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: filteredCartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = filteredCartItems[index];
                      final product = productsMap[cartItem.productId];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child:
                                    cartItem.productImage != null &&
                                        cartItem.productImage!.isNotEmpty
                                    ? (cartItem.productImage!.startsWith('http')
                                          ? Image.network(
                                              cartItem.productImage!,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    width: 70,
                                                    height: 70,
                                                    color: AppTheme.lightGrey,
                                                    child: Icon(
                                                      Icons
                                                          .shopping_bag_outlined,
                                                      color: AppTheme
                                                          .textSecondary,
                                                      size: 32,
                                                    ),
                                                  ),
                                            )
                                          : Image.asset(
                                              cartItem.productImage!,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    width: 70,
                                                    height: 70,
                                                    color: AppTheme.lightGrey,
                                                    child: Icon(
                                                      Icons
                                                          .shopping_bag_outlined,
                                                      color: AppTheme
                                                          .textSecondary,
                                                      size: 32,
                                                    ),
                                                  ),
                                            ))
                                    : Container(
                                        width: 70,
                                        height: 70,
                                        color: AppTheme.lightGrey,
                                        child: Icon(
                                          Icons.shopping_bag_outlined,
                                          color: AppTheme.textSecondary,
                                          size: 32,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),

                              // Product Details and Controls
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.productName,
                                      style: AppTheme.titleStyle.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),

                                    Row(
                                      children: [
                                        Text(
                                          'UGX ${cartItem.price.toStringAsFixed(0)}',
                                          style: AppTheme.subtitleStyle
                                              .copyWith(
                                                fontSize: 14,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (product?.stock != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            '(${product!.stock} in stock)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: product.stock! <= 5
                                                  ? Colors.red
                                                  : AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),

                                    const SizedBox(height: 8),
                                    Text(
                                      'Total: UGX ${(cartItem.price * cartItem.quantity).toStringAsFixed(0)}',
                                      style: AppTheme.titleStyle.copyWith(
                                        fontSize: 16,
                                        color: AppTheme.primaryOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Quantity Controls
                                        Container(
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppTheme.tertiaryOrange,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 14,
                                                ),
                                                onPressed: () =>
                                                    _updateQuantity(
                                                      cartItem,
                                                      false,
                                                    ),
                                                padding: const EdgeInsets.all(
                                                  0,
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 24,
                                                      minHeight: 24,
                                                    ),
                                                color: Colors.black,
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                    ),
                                                child: Text(
                                                  cartItem.quantity.toString(),
                                                  style: AppTheme.chipTextStyle
                                                      .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 14,
                                                ),
                                                onPressed: () =>
                                                    _updateQuantity(
                                                      cartItem,
                                                      true,
                                                    ),
                                                padding: const EdgeInsets.all(
                                                  0,
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 24,
                                                      minHeight: 24,
                                                    ),
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),

                                        // Remove button
                                        SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: IconButton(
                                            onPressed: () =>
                                                _removeFromCart(cartItem),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 24,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 40,
                                              minHeight: 40,
                                            ),
                                            tooltip: 'Remove',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Total and Place Order Button
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'UGX ${totalAmount.toStringAsFixed(0)}',
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 20,
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _placeOrder,
                      child: Text(
                        'Place Order',
                        style: AppTheme.titleStyle.copyWith(
                          color: AppTheme.paleWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
