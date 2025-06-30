import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/latra_integration_service.dart';
import '../../domain/entities/latra_status.dart';
import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_document.dart';

/// LATRA Notification Providers for managing LATRA-related notifications
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature

/// Provider for LATRA notifications
final latraNotificationsProvider =
    FutureProvider.family<List<LATRANotification>, String>((ref, userId) async {
      final integrationService = ref.read(latraIntegrationServiceProvider);
      return integrationService.getLATRANotifications(userId);
    });

/// Provider for unread LATRA notifications count
final unreadLATRANotificationsProvider = FutureProvider.family<int, String>((
  ref,
  userId,
) async {
  final notifications = await ref.read(
    latraNotificationsProvider(userId).future,
  );
  return notifications.where((notification) => !notification.isRead).length;
});

/// Provider for LATRA notification actions
final latraNotificationActionsProvider = Provider<LATRANotificationActions>((
  ref,
) {
  return LATRANotificationActions(ref);
});

/// LATRA Notification Actions class
class LATRANotificationActions {
  final Ref _ref;

  LATRANotificationActions(this._ref);

  /// Create notification for status update
  Future<void> createStatusNotification(
    String userId,
    LATRAStatus status,
    LATRAApplication application,
  ) async {
    final integrationService = _ref.read(latraIntegrationServiceProvider);
    await integrationService.createLATRANotification(
      userId,
      status,
      application,
    );

    // Refresh notifications
    _ref.invalidate(latraNotificationsProvider(userId));
    _ref.invalidate(unreadLATRANotificationsProvider(userId));
  }

  /// Create notification for document expiry
  Future<void> createDocumentExpiryNotification(
    String userId,
    LATRADocument document,
  ) async {
    final notification = LATRANotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      applicationId: document.applicationId,
      statusType: LATRAStatusType.documentsRequired,
      title: document.isExpired ? 'Document Expired' : 'Document Expiring Soon',
      message: document.isExpired
          ? '${document.title} has expired and needs renewal'
          : '${document.title} will expire on ${_formatDate(document.expiryDate!)}',
      timestamp: DateTime.now(),
      isRead: false,
      requiresAction: true,
      actionType: 'renew_document',
    );

    await _storeNotification(notification);

    // Refresh notifications
    _ref.invalidate(latraNotificationsProvider(userId));
    _ref.invalidate(unreadLATRANotificationsProvider(userId));
  }

  /// Create notification for application approval
  Future<void> createApprovalNotification(
    String userId,
    LATRAApplication application,
  ) async {
    final notification = LATRANotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      applicationId: application.id,
      statusType: LATRAStatusType.approved,
      title: 'Application Approved!',
      message:
          'Your ${application.title} has been approved. You can now collect your certificate.',
      timestamp: DateTime.now(),
      isRead: false,
      requiresAction: true,
      actionType: 'collect_certificate',
    );

    await _storeNotification(notification);

    // Refresh notifications
    _ref.invalidate(latraNotificationsProvider(userId));
    _ref.invalidate(unreadLATRANotificationsProvider(userId));
  }

  /// Create notification for document upload requirement
  Future<void> createDocumentRequiredNotification(
    String userId,
    LATRAApplication application,
    List<String> requiredDocuments,
  ) async {
    final notification = LATRANotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      applicationId: application.id,
      statusType: LATRAStatusType.documentsRequired,
      title: 'Documents Required',
      message:
          'Your ${application.title} requires additional documents: ${requiredDocuments.join(', ')}',
      timestamp: DateTime.now(),
      isRead: false,
      requiresAction: true,
      actionType: 'upload_documents',
    );

    await _storeNotification(notification);

    // Refresh notifications
    _ref.invalidate(latraNotificationsProvider(userId));
    _ref.invalidate(unreadLATRANotificationsProvider(userId));
  }

  /// Create notification for payment requirement
  Future<void> createPaymentRequiredNotification(
    String userId,
    LATRAApplication application,
    double amount,
  ) async {
    final notification = LATRANotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      applicationId: application.id,
      statusType: LATRAStatusType.paymentRequired,
      title: 'Payment Required',
      message:
          'Your ${application.title} requires payment of TZS ${amount.toStringAsFixed(0)}',
      timestamp: DateTime.now(),
      isRead: false,
      requiresAction: true,
      actionType: 'make_payment',
    );

    await _storeNotification(notification);

    // Refresh notifications
    _ref.invalidate(latraNotificationsProvider(userId));
    _ref.invalidate(unreadLATRANotificationsProvider(userId));
  }

  /// Create notification for appointment requirement
  Future<void> createAppointmentRequiredNotification(
    String userId,
    LATRAApplication application,
  ) async {
    final notification = LATRANotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      applicationId: application.id,
      statusType: LATRAStatusType.appointmentRequired,
      title: 'Appointment Required',
      message:
          'Your ${application.title} requires an appointment for verification or testing',
      timestamp: DateTime.now(),
      isRead: false,
      requiresAction: true,
      actionType: 'book_appointment',
    );

    await _storeNotification(notification);

    // Refresh notifications
    _ref.invalidate(latraNotificationsProvider(userId));
    _ref.invalidate(unreadLATRANotificationsProvider(userId));
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId, String userId) async {
    // Implementation would mark notification as read in database

    // Refresh notifications
    _ref.invalidate(latraNotificationsProvider(userId));
    _ref.invalidate(unreadLATRANotificationsProvider(userId));
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    // Implementation would mark all notifications as read in database

    // Refresh notifications
    _ref.invalidate(latraNotificationsProvider(userId));
    _ref.invalidate(unreadLATRANotificationsProvider(userId));
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId, String userId) async {
    // Implementation would delete notification from database

    // Refresh notifications
    _ref.invalidate(latraNotificationsProvider(userId));
    _ref.invalidate(unreadLATRANotificationsProvider(userId));
  }

  /// Check for pending notifications and create them
  Future<void> checkAndCreatePendingNotifications(String userId) async {
    final integrationService = _ref.read(latraIntegrationServiceProvider);

    // Check for document expiry
    await integrationService.checkDocumentExpiry(userId);

    // Refresh notifications
    _ref.invalidate(latraNotificationsProvider(userId));
    _ref.invalidate(unreadLATRANotificationsProvider(userId));
  }

  /// Get notification priority
  NotificationPriority getNotificationPriority(LATRANotification notification) {
    switch (notification.statusType) {
      case LATRAStatusType.approved:
        return NotificationPriority.high;
      case LATRAStatusType.rejected:
        return NotificationPriority.high;
      case LATRAStatusType.paymentRequired:
        return NotificationPriority.high;
      case LATRAStatusType.documentsRequired:
        return NotificationPriority.medium;
      case LATRAStatusType.appointmentRequired:
        return NotificationPriority.medium;
      default:
        return NotificationPriority.low;
    }
  }

  /// Get notification category
  NotificationCategory getNotificationCategory(LATRANotification notification) {
    if (notification.requiresAction) {
      return NotificationCategory.actionRequired;
    } else if (notification.statusType == LATRAStatusType.approved ||
        notification.statusType == LATRAStatusType.completed) {
      return NotificationCategory.success;
    } else if (notification.statusType == LATRAStatusType.rejected) {
      return NotificationCategory.error;
    } else {
      return NotificationCategory.info;
    }
  }

  /// Helper methods
  Future<void> _storeNotification(LATRANotification notification) async {
    // Implementation would store notification in database
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Notification priority enumeration
enum NotificationPriority { low, medium, high }

/// Notification category enumeration
enum NotificationCategory { info, success, warning, error, actionRequired }

/// Provider for notification settings
final latraNotificationSettingsProvider =
    StateNotifierProvider<
      LATRANotificationSettingsNotifier,
      LATRANotificationSettings
    >((ref) {
      return LATRANotificationSettingsNotifier();
    });

/// LATRA Notification Settings
class LATRANotificationSettings {
  final bool statusUpdates;
  final bool documentExpiry;
  final bool paymentReminders;
  final bool appointmentReminders;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;

  const LATRANotificationSettings({
    this.statusUpdates = true,
    this.documentExpiry = true,
    this.paymentReminders = true,
    this.appointmentReminders = true,
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.smsNotifications = false,
  });

  LATRANotificationSettings copyWith({
    bool? statusUpdates,
    bool? documentExpiry,
    bool? paymentReminders,
    bool? appointmentReminders,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
  }) {
    return LATRANotificationSettings(
      statusUpdates: statusUpdates ?? this.statusUpdates,
      documentExpiry: documentExpiry ?? this.documentExpiry,
      paymentReminders: paymentReminders ?? this.paymentReminders,
      appointmentReminders: appointmentReminders ?? this.appointmentReminders,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
    );
  }
}

/// LATRA Notification Settings Notifier
class LATRANotificationSettingsNotifier
    extends StateNotifier<LATRANotificationSettings> {
  LATRANotificationSettingsNotifier()
    : super(const LATRANotificationSettings());

  void updateStatusUpdates(bool enabled) {
    state = state.copyWith(statusUpdates: enabled);
  }

  void updateDocumentExpiry(bool enabled) {
    state = state.copyWith(documentExpiry: enabled);
  }

  void updatePaymentReminders(bool enabled) {
    state = state.copyWith(paymentReminders: enabled);
  }

  void updateAppointmentReminders(bool enabled) {
    state = state.copyWith(appointmentReminders: enabled);
  }

  void updatePushNotifications(bool enabled) {
    state = state.copyWith(pushNotifications: enabled);
  }

  void updateEmailNotifications(bool enabled) {
    state = state.copyWith(emailNotifications: enabled);
  }

  void updateSmsNotifications(bool enabled) {
    state = state.copyWith(smsNotifications: enabled);
  }
}
