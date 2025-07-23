// ignore_for_file: prefer_final_fields, deprecated_member_use, unnecessary_nullable_for_final_variable_declarations, unused_local_variable, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Theme/app_theme.dart';
import '../widgets/continue_button.dart';
import '../services/firebase_service.dart';
import 'package:flutter/foundation.dart';

class SellerAddProductScreen extends StatefulWidget {
  static const String routeName = '/AddProduct';

  const SellerAddProductScreen({super.key});

  @override
  State<SellerAddProductScreen> createState() => _SellerAddProductScreenState();
}

class _SellerAddProductScreenState extends State<SellerAddProductScreen> {
  // Firebase and Supabase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _locationController = TextEditingController();
  
  String? _selectedCategory;
  String _selectedCondition = 'New';
  List<File> _productImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  int _currentStep = 0;
  bool _bestOffer = false;

  // List of categories for the dropdown
  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Cuttery',
    'Sports',
    'Beauty',
    'Beddings',
    'Furniture',
    'Other'
  ];

  final List<String> _conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'Poor',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _originalPriceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _productImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty && mounted) {
        setState(() {
          _productImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    if (mounted) {
      setState(() {
        _productImages.removeAt(index);
      });
    }
  }

  // Main product submission method
  void _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      // Additional validation
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      if (_locationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a location')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });
      
      try {
        print('Starting product creation process...');
        
        // Get current user from Firebase
        final User? currentUser = _auth.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        print('Current user:  [38;5;2m${currentUser.uid} [0m');

        // Verify user is a seller
        final roleDoc = await _firestore
            .collection('user_roles')
            .doc(currentUser.uid)
            .get();

        if (!roleDoc.exists) {
          throw Exception('User role not found. Please contact support.');
        }

        final roleData = roleDoc.data();
        final userRole = roleData?['role'] as String?;

        if (userRole != 'seller') {
          throw Exception('Only sellers can create products. Current role: $userRole');
        }

        print('User verified as seller');

        // Upload images to Firebase Storage and get URLs
        List<String> imageUrls = [];
        if (_productImages.isNotEmpty) {
          for (File image in _productImages) {
            final url = await FirebaseService.uploadProductImage(image);
            imageUrls.add(url);
          }
        }

        // Create price and discount string
        String priceAndDiscount = _priceController.text.trim();
        if (_originalPriceController.text.trim().isNotEmpty) {
          final originalPrice = double.tryParse(_originalPriceController.text.trim()) ?? 0;
          final currentPrice = double.tryParse(_priceController.text.trim()) ?? 0;
          
          if (originalPrice > currentPrice && originalPrice > 0) {
            final discountPercent = ((originalPrice - currentPrice) / originalPrice * 100).round();
            priceAndDiscount = 'UGX ${_priceController.text} ($discountPercent% off)';
          } else {
            priceAndDiscount = 'UGX ${_priceController.text}';
          }
        } else {
          priceAndDiscount = 'UGX ${_priceController.text}';
        }

        // Create product data matching your Product model exactly
        final productData = {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'ownerId': currentUser.uid, // Your model uses ownerId
          'priceAndDiscount': priceAndDiscount,
          'originalPrice': _originalPriceController.text.trim().isEmpty 
              ? 'UGX ${_priceController.text}' 
              : 'UGX ${_originalPriceController.text}',
          'condition': _selectedCondition,
          'location': _locationController.text.trim(),
          'rating': 0.0,
          'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : 'https://via.placeholder.com/300x300?text=No+Image',
          'imageUrls': imageUrls,
          'bestOffer': _bestOffer,
          'category': _selectedCategory,
          'price': double.tryParse(_priceController.text.trim()),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          
          // Additional fields for compatibility
          'sellerId': currentUser.uid,
          'sellerEmail': currentUser.email,
          'isActive': true,
          'stock': int.tryParse(_stockController.text.trim()) ?? 0,
        };

        print('Product data: $productData');

        // Add product to Firestore
        final docRef = await _firestore.collection('products').add(productData);
        print('Product created with ID: ${docRef.id}');

        // Update seller stats
        await _updateSellerProductCount(currentUser.uid);
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Product Added Successfully!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${_nameController.text} is now live on Kmart'),
                        if (imageUrls.isEmpty) 
                          const Text(
                            'Note: Images could not be uploaded',
                            style: TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.lightGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        print('Error in product creation: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          String errorMessage = 'Error adding product: ${e.toString()}';
          
          // Provide specific error messages for common issues
          if (e.toString().contains('permission') || e.toString().contains('policy')) {
            errorMessage = 'Storage permission error. Please contact support or try again later.';
          } else if (e.toString().contains('network')) {
            errorMessage = 'Network error. Please check your internet connection.';
          } else if (e.toString().contains('authentication')) {
            errorMessage = 'Authentication error. Please log out and log back in.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  // Update seller product count in Firestore
  Future<void> _updateSellerProductCount(String sellerId) async {
    try {
      final sellerRef = _firestore.collection('sellers').doc(sellerId);
      
      await _firestore.runTransaction((transaction) async {
        final sellerDoc = await transaction.get(sellerRef);
        
        if (sellerDoc.exists) {
          final currentStats = sellerDoc.data()?['stats'] as Map<String, dynamic>? ?? {};
          final currentCount = (currentStats['totalProducts'] as num?)?.toInt() ?? 0;
          
          final updatedStats = {
            ...currentStats,
            'totalProducts': currentCount + 1,
          };
          
          transaction.update(sellerRef, {
            'stats': updatedStats,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
      
      print('Seller product count updated');
    } catch (e) {
      print('Error updating seller product count: $e');
      // Don't rethrow - product creation should still succeed
    }
  }
Future<void> _decrementSellerProductCount(String sellerId) async {
  try {
    final sellerRef = _firestore.collection('sellers').doc(sellerId);
    
    await _firestore.runTransaction((transaction) async {
      final sellerDoc = await transaction.get(sellerRef);
      
      if (sellerDoc.exists) {
        final currentStats = sellerDoc.data()?['stats'] as Map<String, dynamic>? ?? {};
        final currentCount = (currentStats['totalProducts'] as num?)?.toInt() ?? 0;
        
        // Ensure count doesn't go below 0
        final newCount = currentCount > 0 ? currentCount - 1 : 0;
        
        final updatedStats = {
          ...currentStats,
          'totalProducts': newCount,
        };
        
        transaction.update(sellerRef, {
          'stats': updatedStats,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
    
    print('Seller product count updated (decremented)');
  } catch (e) {
    print('Error decrementing seller product count: $e');
    // Don't rethrow - product deletion should still succeed
  }
}

  // Enhanced validation for current step
  
 // Enhanced validation for current step
bool _validateCurrentStep() {
  switch (_currentStep) {
    case 0:
      return _nameController.text.isNotEmpty &&
             _selectedCategory != null &&
             _originalPriceController.text.isNotEmpty && // Changed from _priceController
             _locationController.text.isNotEmpty &&
             _descriptionController.text.isNotEmpty &&
             _descriptionController.text.length >= 20 &&
             double.tryParse(_originalPriceController.text) != null; // Changed from _priceController
    case 1:
      return true; // Images are optional
    case 2:
      return true;
    default:
      return false;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBlue,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.paleWhite,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.store_mall_directory,
                size: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Add to Kmart',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.deepBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Enhanced Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.deepBlue,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStepIndicator(0, 'Details', Icons.info_outline),
                    _buildStepIndicator(1, 'Images', Icons.photo_camera),
                    _buildStepIndicator(2, 'Review', Icons.check_circle_outline),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (_currentStep + 1) / 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0) ..._buildDetailsStep(),
                      if (_currentStep == 1) ..._buildImagesStep(),
                      if (_currentStep == 2) ..._buildReviewStep(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Enhanced Navigation Buttons
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
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.deepBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: AppTheme.deepBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: GenericContinueButton(
                    onPressed: _isLoading ? () {} : () {
                      if (_currentStep < 2) {
                        if (_validateCurrentStep()) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please complete all required fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        _submitProduct();
                      }
                    },
                    text: _isLoading
                        ? 'Adding Product...'
                        : (_currentStep < 2 ? 'Next' : 'Add to Kmart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    bool isActive = _currentStep >= step;
    bool isCompleted = _currentStep > step;
    
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryOrange : Colors.white24,
            borderRadius: BorderRadius.circular(25),
            border: isActive ? null : Border.all(color: Colors.white54),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive ? Colors.white : Colors.white54,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.deepOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.deepOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Category*',
          prefixIcon: const Icon(Icons.category, color: AppTheme.deepOrange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a category';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConditionSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCondition,
        decoration: InputDecoration(
          labelText: 'Condition*',
          prefixIcon: const Icon(Icons.star_rate, color: AppTheme.deepOrange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: _conditions.map((condition) {
          return DropdownMenuItem<String>(
            value: condition,
            child: Text(condition),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCondition = value!;
          });
        },
      ),
    );
  }

  List<Widget> _buildDetailsStep() {
    return [
      Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.deepOrange, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Product Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Tell us about your product to help customers find it easily',
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      const SizedBox(height: 30),
      
      _buildFloatingTextField(
        controller: _nameController,
        label: 'Product Name*',
        icon: Icons.shopping_bag,
        hint: 'Enter a clear, descriptive name',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter product name';
          }
          if (value.length < 3) {
            return 'Product name must be at least 3 characters';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      
      _buildCategorySelector(),
      const SizedBox(height: 20),
      
      Row(
        children: [
          // Expanded(
          //   child: _buildFloatingTextField(
          //     controller: _priceController,
          //     label: 'Current Price (UGX)*',
          //     icon: Icons.attach_money,
          //     hint: 'Enter current price',
          //     keyboardType: TextInputType.number,
          //     validator: (value) {
          //       if (value == null || value.isEmpty) {
          //         return 'Please enter price';
          //       }
          //       if (double.tryParse(value) == null) {
          //         return 'Enter valid price';
          //       }
          //       return null;
          //     },
          //   ),
          //),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFloatingTextField(
              controller: _originalPriceController,
              label: 'PRICE (UGX)',
              icon: Icons.money_off,
              hint: '',
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      
      _buildConditionSelector(),
      const SizedBox(height: 20),
      
      _buildFloatingTextField(
        controller: _locationController,
        label: 'Location*',
        icon: Icons.location_on,
        hint: 'Enter product location',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter location';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      
      // Stock field (optional for this model)
      _buildFloatingTextField(
        controller: _stockController,
        label: 'Stock Quantity',
        icon: Icons.inventory,
        hint: 'Available units (optional)',
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 20),
      
      // Best Offer Switch
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.borderGrey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: AppTheme.deepOrange),
                const SizedBox(width: 12),
                const Text(
                  'Accept Best Offers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            Switch(
              value: _bestOffer,
              activeColor: AppTheme.primaryOrange,
              onChanged: (value) {
                setState(() {
                  _bestOffer = value;
                });
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      
      _buildFloatingTextField(
        controller: _descriptionController,
        label: 'Product Description*',
        icon: Icons.description,
        hint: 'Describe your product features, condition, etc.',
        maxLines: 4,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter description';
          }
          if (value.length < 20) {
            return 'Description should be at least 20 characters';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildImagesStep() {
    return [
      Row(
        children: [
          Icon(Icons.photo_camera, color: AppTheme.deepOrange, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Product Images',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Add high-quality images to showcase your product (optional)',
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      const SizedBox(height: 30),
      
      // Image Upload Area
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 200),
        decoration: BoxDecoration(
          color: AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderGrey, style: BorderStyle.solid, width: 2),
        ),
        child: _productImages.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 60,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Product Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add up to 5 images to show your product',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Single Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.deepOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickMultipleImages,
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: const Text('Multiple'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.selectedBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate grid based on available width
                    int crossAxisCount = constraints.maxWidth < 400 ? 2 : 3;
                    
                    return Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _productImages.length + (_productImages.length < 5 ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _productImages.length) {
                              return GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.chipBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.borderGrey),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 24,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Add More',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: kIsWeb
                                      ? NetworkImage(_productImages[index].path)
                                      : FileImage(_productImages[index]) as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_productImages.length} image${_productImages.length > 1 ? 's' : ''} selected',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    ];
  }

  List<Widget> _buildReviewStep() {
    return [
      Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppTheme.deepOrange, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Review & Confirm',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Review your product details before adding to Kmart',
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      const SizedBox(height: 30),

      // Product summary card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _nameController.text.isNotEmpty ? _nameController.text : 'Product Name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildReviewRow('Category', _selectedCategory ?? 'Not selected'),
            const SizedBox(height: 8),
            _buildReviewRow('Current Price', 'UGX ${_priceController.text.isNotEmpty ? _priceController.text : '0'}'),
            const SizedBox(height: 8),
            if (_originalPriceController.text.isNotEmpty)
              _buildReviewRow('Original Price', 'UGX ${_originalPriceController.text}'),
            const SizedBox(height: 8),
            _buildReviewRow('Condition', _selectedCondition),
            const SizedBox(height: 8),
            _buildReviewRow('Location', _locationController.text.isNotEmpty ? _locationController.text : 'Not specified'),
            const SizedBox(height: 8),
            if (_stockController.text.isNotEmpty)
              _buildReviewRow('Stock', '${_stockController.text} units'),
            const SizedBox(height: 8),
            _buildReviewRow('Best Offer', _bestOffer ? 'Accepted' : 'Not accepted'),
            const SizedBox(height: 12),
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _descriptionController.text.isNotEmpty ? _descriptionController.text : 'No description',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Images:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _productImages.isNotEmpty
                ? SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _productImages.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: kIsWeb
                              ? Image.network(_productImages[index].path, fit: BoxFit.cover)
                              : Image.file(_productImages[index], fit: BoxFit.cover),
                        );
                      },
                    ),
                  )
                : const Text(
                    'No images selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
          ],
        ),
      ),
    ];
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}