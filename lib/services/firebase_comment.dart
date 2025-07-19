// services/comment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a comment to a product
  static Future<void> addComment(String productId, String comment) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('products')
          .doc(productId)
          .collection('comments')
          .add({
        'comment': comment,
        'userId': user.uid,
        'userEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Get comments for a product
  static Stream<List<ProductComment>> getComments(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductComment.fromFirestore(doc);
      }).toList();
    });
  }

  // Like/Unlike a comment
  static Future<void> toggleCommentLike(String productId, String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final commentRef = _firestore
          .collection('products')
          .doc(productId)
          .collection('comments')
          .doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final commentDoc = await transaction.get(commentRef);
        if (!commentDoc.exists) throw Exception('Comment not found');

        final data = commentDoc.data()!;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        final currentLikes = data['likes'] ?? 0;

        if (likedBy.contains(user.uid)) {
          // Unlike
          likedBy.remove(user.uid);
          transaction.update(commentRef, {
            'likes': currentLikes - 1,
            'likedBy': likedBy,
          });
        } else {
          // Like
          likedBy.add(user.uid);
          transaction.update(commentRef, {
            'likes': currentLikes + 1,
            'likedBy': likedBy,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Delete a comment (only by owner)
  static Future<void> deleteComment(String productId, String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('products')
          .doc(productId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Add rating to a product
  static Future<void> addRating(String productId, double rating) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('products')
          .doc(productId)
          .collection('ratings')
          .doc(user.uid)
          .set({
        'rating': rating,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update product average rating
      await _updateProductAverageRating(productId);
    } catch (e) {
      throw Exception('Failed to add rating: $e');
    }
  }

  // Update product average rating
  static Future<void> _updateProductAverageRating(String productId) async {
    try {
      final ratingsSnapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('ratings')
          .get();

      if (ratingsSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (final doc in ratingsSnapshot.docs) {
        totalRating += doc.data()['rating'] ?? 0;
      }

      final averageRating = totalRating / ratingsSnapshot.docs.length;
      final totalRatings = ratingsSnapshot.docs.length;

      await _firestore.collection('products').doc(productId).update({
        'averageRating': averageRating,
        'totalRatings': totalRatings,
      });
    } catch (e) {
      throw Exception('Failed to update average rating: $e');
    }
  }

  // Get user's rating for a product
  static Future<double?> getUserRating(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('products')
          .doc(productId)
          .collection('ratings')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data()?['rating']?.toDouble();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// Comment model
class ProductComment {
  final String id;
  final String comment;
  final String userId;
  final String userEmail;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;

  ProductComment({
    required this.id,
    required this.comment,
    required this.userId,
    required this.userEmail,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
  });

  factory ProductComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductComment(
      id: doc.id,
      comment: data['comment'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }
}