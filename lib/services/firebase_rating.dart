import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Rating {
  final String id;
  final String productId;
  final String userId;
  final double value;
  final DateTime timestamp;

  Rating({
    required this.id,
    required this.productId,
    required this.userId,
    required this.value,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'value': value,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      value: (map['value'] as num).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add or update a user's rating for a product
  Future<void> setRating(String productId, double value) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in to rate');
    final query = await _firestore
        .collection('ratings')
        .where('productId', isEqualTo: productId)
        .where('userId', isEqualTo: user.uid)
        .get();
    if (query.docs.isNotEmpty) {
      // Update existing rating
      final doc = query.docs.first.reference;
      await doc.update({
        'value': value,
        'timestamp': Timestamp.now(),
      });
    } else {
      // Add new rating
      final docRef = _firestore.collection('ratings').doc();
      final rating = Rating(
        id: docRef.id,
        productId: productId,
        userId: user.uid,
        value: value,
        timestamp: DateTime.now(),
      );
      await docRef.set(rating.toMap());
    }
  }

  // Get the average rating for a product
  Stream<double> getAverageRating(String productId) {
    return _firestore
        .collection('ratings')
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0.0;
          final ratings = snapshot.docs
              .map((doc) => Rating.fromMap(doc.data()))
              .toList();
          final sum = ratings.fold(0.0, (prev, r) => prev + r.value);
          return sum / ratings.length;
        });
  }

  // Get the current user's rating for a product
  Future<double?> getUserRating(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final query = await _firestore
        .collection('ratings')
        .where('productId', isEqualTo: productId)
        .where('userId', isEqualTo: user.uid)
        .get();
    if (query.docs.isNotEmpty) {
      return (query.docs.first.data()['value'] as num).toDouble();
    }
    return null;
  }
} 