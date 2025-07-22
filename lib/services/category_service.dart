// services/category_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update product count for a specific category
  static Future<void> updateCategoryProductCount(String categoryId) async {
    try {
      // Get the current count of products in this category
      final QuerySnapshot productSnapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true) // Only count active products
          .get();

      final int currentProductCount = productSnapshot.docs.length;

      // Update the category document with the new count
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .update({'productCount': currentProductCount});

      print('Updated category $categoryId product count to $currentProductCount');
    } catch (e) {
      print('Error updating category product count: $e');
      throw e;
    }
  }

  /// Increment product count for a category (when adding a product)
  static Future<void> incrementCategoryProductCount(String categoryId) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .update({'productCount': FieldValue.increment(1)});
      
      print('Incremented product count for category $categoryId');
    } catch (e) {
      print('Error incrementing category product count: $e');
      throw e;
    }
  }

  /// Decrement product count for a category (when removing a product)
  static Future<void> decrementCategoryProductCount(String categoryId) async {
    try {
      // First check current count to avoid negative values
      final DocumentSnapshot categoryDoc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (categoryDoc.exists) {
        final data = categoryDoc.data() as Map<String, dynamic>;
        final currentCount = data['productCount'] as int? ?? 0;
        
        if (currentCount > 0) {
          await _firestore
              .collection('categories')
              .doc(categoryId)
              .update({'productCount': FieldValue.increment(-1)});
          
          print('Decremented product count for category $categoryId');
        } else {
          print('Category $categoryId already has 0 products, not decrementing');
        }
      }
    } catch (e) {
      print('Error decrementing category product count: $e');
      throw e;
    }
  }

  /// Batch update all category product counts (useful for data migration or fixing inconsistencies)
  static Future<void> recalculateAllCategoryProductCounts() async {
    try {
      // Get all categories
      final QuerySnapshot categoriesSnapshot = await _firestore
          .collection('categories')
          .get();

      final WriteBatch batch = _firestore.batch();

      for (final categoryDoc in categoriesSnapshot.docs) {
        final categoryId = categoryDoc.id;
        
        // Count products for this category
        final QuerySnapshot productSnapshot = await _firestore
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .where('isActive', isEqualTo: true)
            .get();

        final int productCount = productSnapshot.docs.length;

        // Add to batch update
        batch.update(categoryDoc.reference, {'productCount': productCount});
      }

      // Commit all updates
      await batch.commit();
      print('Successfully recalculated all category product counts');
    } catch (e) {
      print('Error recalculating category product counts: $e');
      throw e;
    }
  }

  /// Get category with updated product count
  static Future<DocumentSnapshot> getCategoryWithUpdatedCount(String categoryId) async {
    try {
      // Update the count first
      await updateCategoryProductCount(categoryId);
      
      // Then return the updated document
      return await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();
    } catch (e) {
      print('Error getting category with updated count: $e');
      throw e;
    }
  }
}