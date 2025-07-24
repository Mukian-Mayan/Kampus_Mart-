// services/comment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Comment {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userEmail;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  String get displayName {
    if (userName.isNotEmpty) return userName;
    if (userEmail.isNotEmpty) {
      // Extract name from email (e.g., "john.doe@email.com" -> "John Doe")
      final emailName = userEmail.split('@')[0];
      return emailName.split('.').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
      ).join(' ');
    }
    return 'User';
  }
}

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new comment
  Future<Comment?> addComment(String productId, String text) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to comment');
      }

      final docRef = _firestore.collection('comments').doc();
      final now = DateTime.now();

      // Get user display name or email
      String userName = user.displayName ?? '';
      String userEmail = user.email ?? '';

      final comment = Comment(
        id: docRef.id,
        productId: productId,
        userId: user.uid,
        userName: userName,
        userEmail: userEmail,
        text: text,
        timestamp: now,
      );

      await docRef.set(comment.toMap());
      return comment;
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }

  // Get comments for a product
  Stream<List<Comment>> getCommentsForProduct(String productId) {
    return _firestore
        .collection('comments')
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          final comments = snapshot.docs
              .map((doc) => Comment.fromMap(doc.data()))
              .toList();
          
          // Sort comments by timestamp in memory
          comments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return comments;
        });
  }

  // Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to delete comments');
      }

      final commentDoc = await _firestore
          .collection('comments')
          .doc(commentId)
          .get();

      if (!commentDoc.exists) {
        return false;
      }

      final comment = Comment.fromMap(commentDoc.data()!);
      if (comment.userId != user.uid) {
        throw Exception('Users can only delete their own comments');
      }

      await _firestore.collection('comments').doc(commentId).delete();
      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }
}