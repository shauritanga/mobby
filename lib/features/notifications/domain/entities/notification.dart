import 'package:equatable/equatable.dart';

enum NotificationType {
  order,
  payment,
  shipping,
  insurance,
  latra,
  system,
  marketing,
  reminder,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

enum NotificationStatus {
  pending,
  sent,
  delivered,
  read,
  failed,
}

enum NotificationChannel {
  push,
  email,
  sms,
  inApp,
}

class Notification extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationStatus status;
  final List<NotificationChannel> channels;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;
  final String? actionText;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String? campaignId;
  final String? templateId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.status,
    required this.channels,
    this.data,
    this.imageUrl,
    this.actionUrl,
    this.actionText,
    this.scheduledAt,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.campaignId,
    this.templateId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        type,
        priority,
        status,
        channels,
        data,
        imageUrl,
        actionUrl,
        actionText,
        scheduledAt,
        sentAt,
        deliveredAt,
        readAt,
        campaignId,
        templateId,
        metadata,
        createdAt,
        updatedAt,
      ];

  // Computed properties
  bool get isRead => readAt != null;
  bool get isDelivered => deliveredAt != null;
  bool get isSent => sentAt != null;
  bool get isScheduled => scheduledAt != null && scheduledAt!.isAfter(DateTime.now());
  bool get hasAction => actionUrl != null && actionText != null;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get priorityText {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  String get statusText {
    switch (status) {
      case NotificationStatus.pending:
        return 'Pending';
      case NotificationStatus.sent:
        return 'Sent';
      case NotificationStatus.delivered:
        return 'Delivered';
      case NotificationStatus.read:
        return 'Read';
      case NotificationStatus.failed:
        return 'Failed';
    }
  }

  String get typeText {
    switch (type) {
      case NotificationType.order:
        return 'Order';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.shipping:
        return 'Shipping';
      case NotificationType.insurance:
        return 'Insurance';
      case NotificationType.latra:
        return 'LATRA';
      case NotificationType.system:
        return 'System';
      case NotificationType.marketing:
        return 'Marketing';
      case NotificationType.reminder:
        return 'Reminder';
    }
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    NotificationStatus? status,
    List<NotificationChannel>? channels,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    String? actionText,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    String? campaignId,
    String? templateId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      channels: channels ?? this.channels,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      actionText: actionText ?? this.actionText,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      campaignId: campaignId ?? this.campaignId,
      templateId: templateId ?? this.templateId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
