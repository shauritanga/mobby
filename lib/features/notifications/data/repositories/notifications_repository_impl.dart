import '../../domain/entities/notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Notification>> getUserNotifications(
    String userId, {
    int page = 1,
    int limit = 20,
    NotificationType? type,
    NotificationStatus? status,
  }) async {
    final notifications = await remoteDataSource.getUserNotifications(
      userId,
      page: page,
      limit: limit,
      type: type,
      status: status,
    );
    return notifications.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Notification?> getNotification(String notificationId) async {
    final notification = await remoteDataSource.getNotification(notificationId);
    return notification?.toEntity();
  }

  @override
  Future<Notification> createNotification(Notification notification) async {
    final notificationModel = NotificationModel.fromEntity(notification);
    final createdModel = await remoteDataSource.createNotification(notificationModel);
    return createdModel.toEntity();
  }

  @override
  Future<Notification> updateNotification(Notification notification) async {
    final notificationModel = NotificationModel.fromEntity(notification);
    final updatedModel = await remoteDataSource.updateNotification(notificationModel);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await remoteDataSource.deleteNotification(notificationId);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await remoteDataSource.markAllAsRead(userId);
  }

  @override
  Future<void> markAsDelivered(String notificationId) async {
    await remoteDataSource.markAsDelivered(notificationId);
  }

  @override
  Future<void> sendNotification(String notificationId) async {
    await remoteDataSource.sendNotification(notificationId);
  }

  @override
  Future<void> scheduleNotification(String notificationId, DateTime scheduledAt) async {
    await remoteDataSource.scheduleNotification(notificationId, scheduledAt);
  }

  @override
  Future<void> cancelScheduledNotification(String notificationId) async {
    await remoteDataSource.cancelScheduledNotification(notificationId);
  }

  @override
  Future<void> sendBulkNotifications(List<String> notificationIds) async {
    await remoteDataSource.sendBulkNotifications(notificationIds);
  }

  @override
  Future<void> deleteBulkNotifications(List<String> notificationIds) async {
    await remoteDataSource.deleteBulkNotifications(notificationIds);
  }

  @override
  Future<Map<String, int>> getNotificationStats(String userId) async {
    return await remoteDataSource.getNotificationStats(userId);
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return await remoteDataSource.getUnreadCount(userId);
  }

  @override
  Future<List<Notification>> searchNotifications(
    String userId,
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final notifications = await remoteDataSource.searchNotifications(
      userId,
      query,
      page: page,
      limit: limit,
    );
    return notifications.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Notification>> getNotificationsByType(
    String userId,
    NotificationType type, {
    int page = 1,
    int limit = 20,
  }) async {
    final notifications = await remoteDataSource.getUserNotifications(
      userId,
      page: page,
      limit: limit,
      type: type,
    );
    return notifications.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Notification>> getNotificationsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    int page = 1,
    int limit = 20,
  }) async {
    // This would require additional implementation in the data source
    // For now, we'll get all notifications and filter locally
    final notifications = await remoteDataSource.getUserNotifications(
      userId,
      page: page,
      limit: limit * 2, // Get more to account for filtering
    );
    
    final filtered = notifications
        .where((notification) =>
            notification.createdAt.isAfter(startDate) &&
            notification.createdAt.isBefore(endDate))
        .take(limit)
        .toList();
    
    return filtered.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<Notification> watchNotifications(String userId) {
    return remoteDataSource.watchNotifications(userId).map(
          (model) => model.toEntity(),
        );
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return remoteDataSource.watchUnreadCount(userId);
  }

  @override
  Future<void> registerDeviceToken(String userId, String token) async {
    await remoteDataSource.registerDeviceToken(userId, token);
  }

  @override
  Future<void> unregisterDeviceToken(String userId, String token) async {
    await remoteDataSource.unregisterDeviceToken(userId, token);
  }

  @override
  Future<Map<String, bool>> getNotificationPreferences(String userId) async {
    return await remoteDataSource.getNotificationPreferences(userId);
  }

  @override
  Future<void> updateNotificationPreferences(
    String userId,
    Map<String, bool> preferences,
  ) async {
    await remoteDataSource.updateNotificationPreferences(userId, preferences);
  }
}
