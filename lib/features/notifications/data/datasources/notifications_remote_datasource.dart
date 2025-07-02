import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../../domain/entities/notification.dart';

abstract class NotificationsRemoteDataSource {
  Stream<NotificationModel> watchNotifications(String userId);
  Stream<int> watchUnreadCount(String userId);
  Future<List<NotificationModel>> getUserNotifications(
    String userId, {
    int page = 1,
    int limit = 20,
    NotificationType? type,
    NotificationStatus? status,
  });

  Future<NotificationModel?> getNotification(String notificationId);
  Future<NotificationModel> createNotification(NotificationModel notification);
  Future<NotificationModel> updateNotification(NotificationModel notification);
  Future<void> deleteNotification(String notificationId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> markAsDelivered(String notificationId);
  Future<void> sendNotification(String notificationId);
  Future<void> scheduleNotification(
    String notificationId,
    DateTime scheduledAt,
  );
  Future<void> cancelScheduledNotification(String notificationId);
  Future<void> sendBulkNotifications(List<String> notificationIds);
  Future<void> deleteBulkNotifications(List<String> notificationIds);
  Future<Map<String, int>> getNotificationStats(String userId);
  Future<int> getUnreadCount(String userId);
  Future<List<NotificationModel>> searchNotifications(
    String userId,
    String query, {
    int page = 1,
    int limit = 20,
  });
  Future<void> registerDeviceToken(String userId, String token);
  Future<void> unregisterDeviceToken(String userId, String token);
  Future<Map<String, bool>> getNotificationPreferences(String userId);
  Future<void> updateNotificationPreferences(
    String userId,
    Map<String, bool> preferences,
  );
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationsRemoteDataSourceImpl(this._firestore);

  @override
  Stream<NotificationModel> watchNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty
            ? NotificationModel.fromJson({
                'id': snapshot.docs.first.id,
                ...snapshot.docs.first.data(),
              })
            : throw Exception('No notifications found'));
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: NotificationStatus.unread.name)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }



  @override
  Future<List<NotificationModel>> getUserNotifications(
    String userId, {
    int page = 1,
    int limit = 20,
    NotificationType? type,
    NotificationStatus? status,
  }) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      final querySnapshot = await query.limit(limit).get();

      final notifications = querySnapshot.docs
          .map(
            (doc) => NotificationModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      return notifications;
    } catch (e) {
      throw Exception('Failed to fetch user notifications: $e');
    }
  }

  @override
  Future<NotificationModel?> getNotification(String notificationId) async {
    try {
      final doc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return NotificationModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch notification: $e');
    }
  }

  @override
  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    try {
      final notificationData = notification.toJson();
      notificationData.remove('id');

      final docRef = await _firestore
          .collection('notifications')
          .add(notificationData);

      final createdNotification = notification.copyWith(id: docRef.id);
      return createdNotification;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  @override
  Future<NotificationModel> updateNotification(
    NotificationModel notification,
  ) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .update(notification.toJson());

      return notification;
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': NotificationStatus.read.name,
        'readAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where(
            'status',
            whereIn: [
              NotificationStatus.pending.name,
              NotificationStatus.sent.name,
              NotificationStatus.delivered.name,
            ],
          )
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'status': NotificationStatus.read.name,
          'readAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> markAsDelivered(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': NotificationStatus.delivered.name,
        'deliveredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as delivered: $e');
    }
  }

  @override
  Future<void> sendNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': NotificationStatus.sent.name,
        'sentAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Here you would integrate with actual notification services
      // like Firebase Cloud Messaging, email service, SMS service, etc.
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  @override
  Future<void> scheduleNotification(
    String notificationId,
    DateTime scheduledAt,
  ) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Here you would integrate with a job scheduler or cloud function
      // to send the notification at the scheduled time
    } catch (e) {
      throw Exception('Failed to schedule notification: $e');
    }
  }

  @override
  Future<void> cancelScheduledNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'scheduledAt': null,
        'status': NotificationStatus.pending.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel scheduled notification: $e');
    }
  }

  @override
  Future<void> sendBulkNotifications(List<String> notificationIds) async {
    try {
      final batch = _firestore.batch();

      for (final notificationId in notificationIds) {
        final docRef = _firestore
            .collection('notifications')
            .doc(notificationId);
        batch.update(docRef, {
          'status': NotificationStatus.sent.name,
          'sentAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Here you would integrate with actual notification services
      // for bulk sending
    } catch (e) {
      throw Exception('Failed to send bulk notifications: $e');
    }
  }

  @override
  Future<void> deleteBulkNotifications(List<String> notificationIds) async {
    try {
      final batch = _firestore.batch();

      for (final notificationId in notificationIds) {
        final docRef = _firestore
            .collection('notifications')
            .doc(notificationId);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete bulk notifications: $e');
    }
  }

  @override
  Future<Map<String, int>> getNotificationStats(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final stats = <String, int>{
        'total': 0,
        'unread': 0,
        'read': 0,
        'sent': 0,
        'delivered': 0,
        'failed': 0,
      };

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String;

        stats['total'] = stats['total']! + 1;
        stats[status] = (stats[status] ?? 0) + 1;

        if (status != NotificationStatus.read.name) {
          stats['unread'] = stats['unread']! + 1;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get notification stats: $e');
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where(
            'status',
            whereIn: [
              NotificationStatus.pending.name,
              NotificationStatus.sent.name,
              NotificationStatus.delivered.name,
            ],
          )
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  @override
  Future<List<NotificationModel>> searchNotifications(
    String userId,
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simplified implementation
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit * 5) // Get more to filter locally
          .get();

      final notifications = querySnapshot.docs
          .map(
            (doc) => NotificationModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .where(
            (notification) =>
                notification.title.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                notification.body.toLowerCase().contains(query.toLowerCase()),
          )
          .skip((page - 1) * limit)
          .take(limit)
          .toList();

      return notifications;
    } catch (e) {
      throw Exception('Failed to search notifications: $e');
    }
  }

  @override
  Future<void> registerDeviceToken(String userId, String token) async {
    try {
      await _firestore.collection('deviceTokens').doc('$userId-$token').set({
        'userId': userId,
        'token': token,
        'platform': 'mobile', // You can detect platform
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to register device token: $e');
    }
  }

  @override
  Future<void> unregisterDeviceToken(String userId, String token) async {
    try {
      await _firestore
          .collection('deviceTokens')
          .doc('$userId-$token')
          .delete();
    } catch (e) {
      throw Exception('Failed to unregister device token: $e');
    }
  }

  @override
  Future<Map<String, bool>> getNotificationPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('notificationPreferences')
          .doc(userId)
          .get();

      if (!doc.exists) {
        // Return default preferences
        return {
          'push': true,
          'email': true,
          'sms': false,
          'marketing': true,
          'orders': true,
          'payments': true,
          'shipping': true,
          'insurance': true,
          'latra': true,
          'system': true,
        };
      }

      final data = doc.data()!;
      return Map<String, bool>.from(data);
    } catch (e) {
      throw Exception('Failed to get notification preferences: $e');
    }
  }

  @override
  Future<void> updateNotificationPreferences(
    String userId,
    Map<String, bool> preferences,
  ) async {
    try {
      await _firestore.collection('notificationPreferences').doc(userId).set({
        ...preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update notification preferences: $e');
    }
  }
}
