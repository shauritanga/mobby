import '../entities/notification.dart';

abstract class NotificationsRepository {
  // Notification CRUD operations
  Future<List<Notification>> getUserNotifications(
    String userId, {
    int page = 1,
    int limit = 20,
    NotificationType? type,
    NotificationStatus? status,
  });

  Future<Notification?> getNotification(String notificationId);

  Future<Notification> createNotification(Notification notification);

  Future<Notification> updateNotification(Notification notification);

  Future<void> deleteNotification(String notificationId);

  // Notification actions
  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);

  Future<void> markAsDelivered(String notificationId);

  Future<void> sendNotification(String notificationId);

  Future<void> scheduleNotification(
    String notificationId,
    DateTime scheduledAt,
  );

  Future<void> cancelScheduledNotification(String notificationId);

  // Bulk operations
  Future<void> sendBulkNotifications(List<String> notificationIds);

  Future<void> deleteBulkNotifications(List<String> notificationIds);

  // Statistics
  Future<Map<String, int>> getNotificationStats(String userId);

  Future<int> getUnreadCount(String userId);

  // Search and filter
  Future<List<Notification>> searchNotifications(
    String userId,
    String query, {
    int page = 1,
    int limit = 20,
  });

  Future<List<Notification>> getNotificationsByType(
    String userId,
    NotificationType type, {
    int page = 1,
    int limit = 20,
  });

  Future<List<Notification>> getNotificationsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    int page = 1,
    int limit = 20,
  });

  // Real-time updates
  Stream<Notification> watchNotifications(String userId);

  Stream<int> watchUnreadCount(String userId);

  // Device token management for push notifications
  Future<void> registerDeviceToken(String userId, String token);

  Future<void> unregisterDeviceToken(String userId, String token);

  // Notification preferences
  Future<Map<String, bool>> getNotificationPreferences(String userId);

  Future<void> updateNotificationPreferences(
    String userId,
    Map<String, bool> preferences,
  );
}
