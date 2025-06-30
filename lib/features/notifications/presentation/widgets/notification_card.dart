import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/notification.dart' as domain;

class NotificationCard extends StatelessWidget {
  final domain.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: isRead
            ? theme.colorScheme.surface
            : theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        elevation: isRead ? 1 : 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Type icon
                    _buildTypeIcon(theme),
                    SizedBox(width: 12.w),
                    // Title and metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              _buildPriorityChip(theme),
                              SizedBox(width: 8.w),
                              Text(
                                notification.timeAgo,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              _buildStatusChip(theme),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Actions menu
                    PopupMenuButton<String>(
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => [
                        if (!isRead)
                          const PopupMenuItem(
                            value: 'mark_read',
                            child: ListTile(
                              leading: Icon(Icons.mark_email_read),
                              title: Text('Mark as read'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Body text
                Text(
                  notification.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isRead
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                // Image if present
                if (notification.imageUrl != null) ...[
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      notification.imageUrl!,
                      height: 120.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120.h,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                // Action button if present
                if (notification.hasAction) ...[
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.open_in_new),
                      label: Text(notification.actionText ?? 'View'),
                    ),
                  ),
                ],
                // Channels indicator
                if (notification.channels.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 4.w,
                    children: notification.channels.map((channel) {
                      return _buildChannelChip(channel, theme);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(ThemeData theme) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case domain.NotificationType.order:
        icon = Icons.shopping_bag;
        color = Colors.blue;
        break;
      case domain.NotificationType.payment:
        icon = Icons.payment;
        color = Colors.green;
        break;
      case domain.NotificationType.shipping:
        icon = Icons.local_shipping;
        color = Colors.orange;
        break;
      case domain.NotificationType.insurance:
        icon = Icons.security;
        color = Colors.purple;
        break;
      case domain.NotificationType.latra:
        icon = Icons.directions_car;
        color = Colors.teal;
        break;
      case domain.NotificationType.system:
        icon = Icons.settings;
        color = Colors.grey;
        break;
      case domain.NotificationType.marketing:
        icon = Icons.campaign;
        color = Colors.pink;
        break;
      case domain.NotificationType.reminder:
        icon = Icons.alarm;
        color = Colors.amber;
        break;
    }

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: color, size: 20.w),
    );
  }

  Widget _buildPriorityChip(ThemeData theme) {
    Color color;
    switch (notification.priority) {
      case domain.NotificationPriority.low:
        color = Colors.grey;
        break;
      case domain.NotificationPriority.normal:
        color = Colors.blue;
        break;
      case domain.NotificationPriority.high:
        color = Colors.orange;
        break;
      case domain.NotificationPriority.urgent:
        color = Colors.red;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        notification.priorityText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    Color color;
    switch (notification.status) {
      case domain.NotificationStatus.pending:
        color = Colors.grey;
        break;
      case domain.NotificationStatus.sent:
        color = Colors.blue;
        break;
      case domain.NotificationStatus.delivered:
        color = Colors.green;
        break;
      case domain.NotificationStatus.read:
        color = Colors.teal;
        break;
      case domain.NotificationStatus.failed:
        color = Colors.red;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        notification.statusText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildChannelChip(
    domain.NotificationChannel channel,
    ThemeData theme,
  ) {
    IconData icon;
    switch (channel) {
      case domain.NotificationChannel.push:
        icon = Icons.notifications;
        break;
      case domain.NotificationChannel.email:
        icon = Icons.email;
        break;
      case domain.NotificationChannel.sms:
        icon = Icons.sms;
        break;
      case domain.NotificationChannel.inApp:
        icon = Icons.app_registration;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Icon(icon, size: 12.w, color: theme.colorScheme.onSurfaceVariant),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_read':
        onMarkAsRead?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}
