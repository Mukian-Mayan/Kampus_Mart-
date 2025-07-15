// Fixed Notification Service
// ignore_for_file: unused_import, unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../services/firebase_base_service.dart';

class NotificationService extends FirebaseService {
  static const String _collection = 'notifications';
  static final Uuid _uuid = Uuid();

  // Send notification
  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId = _uuid.v4();
      
      // Use the public getter from FirebaseService
      await FirebaseService.firestore.collection(_collection).doc(notificationId).set({
        'id': notificationId,
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': DateTime.now(),
        'data': data ?? {},
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  // Get user notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications({String? userId}) async {
    try {
      final String targetUserId = userId ?? FirebaseService.currentUserId!;
      
      final querySnapshot = await FirebaseService.firestore
          .collection(_collection)
          .where('userId', isEqualTo: targetUserId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await FirebaseService.firestore.collection(_collection).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}