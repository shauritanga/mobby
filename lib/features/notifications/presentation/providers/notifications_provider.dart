import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_user_notifications.dart';
import '../../domain/usecases/send_notification.dart';

// State classes
class NotificationsState {
  final List<Notification> notifications;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final int unreadCount;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<Notification>? notifications,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationFilters {
  final NotificationType? type;
  final NotificationStatus? status;
  final String? searchQuery;

  const NotificationFilters({
    this.type,
    this.status,
    this.searchQuery,
  });

  NotificationFilters copyWith({
    NotificationType? type,
    NotificationStatus? status,
    String? searchQuery,
  }) {
    return NotificationFilters(
      type: type ?? this.type,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Notifications Provider
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final GetUserNotifications _getUserNotifications;
  final MarkNotificationAsRead _markAsRead;
  final MarkAllNotificationsAsRead _markAllAsRead;
  final GetUnreadCount _getUnreadCount;
  final DeleteNotification _deleteNotification;

  NotificationsNotifier({
    required GetUserNotifications getUserNotifications,
    required MarkNotificationAsRead markAsRead,
    required MarkAllNotificationsAsRead markAllAsRead,
    required GetUnreadCount getUnreadCount,
    required DeleteNotification deleteNotification,
  })  : _getUserNotifications = getUserNotifications,
        _markAsRead = markAsRead,
        _markAllAsRead = markAllAsRead,
        _getUnreadCount = getUnreadCount,
        _deleteNotification = deleteNotification,
        super(const NotificationsState());

  String? _currentUserId;
  NotificationFilters _filters = const NotificationFilters();

  Future<void> loadNotifications(String userId, {bool refresh = false}) async {
    if (_currentUserId != userId || refresh) {
      _currentUserId = userId;
      state = state.copyWith(
        notifications: [],
        currentPage: 1,
        hasMore: true,
        error: null,
      );
    }

    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _getUserNotifications(GetUserNotificationsParams(
        userId: userId,
        page: state.currentPage,
        limit: 20,
        type: _filters.type,
        status: _filters.status,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (notifications) {
          final allNotifications = state.currentPage == 1
              ? notifications
              : [...state.notifications, ...notifications];

          state = state.copyWith(
            notifications: allNotifications,
            isLoading: false,
            hasMore: notifications.length == 20,
            currentPage: state.currentPage + 1,
            error: null,
          );
        },
      );

      // Also load unread count
      await _loadUnreadCount(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final result = await _markAsRead(MarkNotificationAsReadParams(
        notificationId: notificationId,
      ));

      result.fold(
        (failure) {
          // Handle error
        },
        (_) {
          // Update local state
          final updatedNotifications = state.notifications.map((notification) {
            if (notification.id == notificationId) {
              return notification.copyWith(
                status: NotificationStatus.read,
                readAt: DateTime.now(),
              );
            }
            return notification;
          }).toList();

          state = state.copyWith(
            notifications: updatedNotifications,
            unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
          );
        },
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final result = await _markAllAsRead(MarkAllNotificationsAsReadParams(
        userId: userId,
      ));

      result.fold(
        (failure) {
          // Handle error
        },
        (_) {
          // Update local state
          final updatedNotifications = state.notifications.map((notification) {
            if (notification.status != NotificationStatus.read) {
              return notification.copyWith(
                status: NotificationStatus.read,
                readAt: DateTime.now(),
              );
            }
            return notification;
          }).toList();

          state = state.copyWith(
            notifications: updatedNotifications,
            unreadCount: 0,
          );
        },
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final result = await _deleteNotification(DeleteNotificationParams(
        notificationId: notificationId,
      ));

      result.fold(
        (failure) {
          // Handle error
        },
        (_) {
          // Remove from local state
          final updatedNotifications = state.notifications
              .where((notification) => notification.id != notificationId)
              .toList();

          state = state.copyWith(notifications: updatedNotifications);
        },
      );
    } catch (e) {
      // Handle error
    }
  }

  void updateFilters(NotificationFilters filters) {
    _filters = filters;
    if (_currentUserId != null) {
      loadNotifications(_currentUserId!, refresh: true);
    }
  }

  Future<void> _loadUnreadCount(String userId) async {
    try {
      final result = await _getUnreadCount(GetUnreadCountParams(userId: userId));
      result.fold(
        (failure) {
          // Handle error silently
        },
        (count) {
          state = state.copyWith(unreadCount: count);
        },
      );
    } catch (e) {
      // Handle error silently
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Send Notification Provider
class SendNotificationState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const SendNotificationState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  SendNotificationState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return SendNotificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class SendNotificationNotifier extends StateNotifier<SendNotificationState> {
  final SendNotification _sendNotification;
  final SendBulkNotification _sendBulkNotification;

  SendNotificationNotifier({
    required SendNotification sendNotification,
    required SendBulkNotification sendBulkNotification,
  })  : _sendNotification = sendNotification,
        _sendBulkNotification = sendBulkNotification,
        super(const SendNotificationState());

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    List<NotificationChannel> channels = const [NotificationChannel.push],
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    String? actionText,
    DateTime? scheduledAt,
    String? campaignId,
    String? templateId,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final result = await _sendNotification(SendNotificationParams(
        userId: userId,
        title: title,
        body: body,
        type: type,
        priority: priority,
        channels: channels,
        data: data,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
        actionText: actionText,
        scheduledAt: scheduledAt,
        campaignId: campaignId,
        templateId: templateId,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (notification) {
          state = state.copyWith(
            isLoading: false,
            successMessage: scheduledAt != null
                ? 'Notification scheduled successfully'
                : 'Notification sent successfully',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendBulkNotification({
    required List<String> userIds,
    required String title,
    required String body,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    List<NotificationChannel> channels = const [NotificationChannel.push],
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    String? actionText,
    DateTime? scheduledAt,
    String? campaignId,
    String? templateId,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final result = await _sendBulkNotification(SendBulkNotificationParams(
        userIds: userIds,
        title: title,
        body: body,
        type: type,
        priority: priority,
        channels: channels,
        data: data,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
        actionText: actionText,
        scheduledAt: scheduledAt,
        campaignId: campaignId,
        templateId: templateId,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (notifications) {
          state = state.copyWith(
            isLoading: false,
            successMessage: scheduledAt != null
                ? 'Bulk notifications scheduled successfully'
                : 'Bulk notifications sent successfully',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}
