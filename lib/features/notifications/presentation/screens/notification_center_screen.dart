import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobby/features/notifications/notifications_feature.dart'
    hide notificationsProvider;
import '../../domain/entities/notification.dart' as domain;
import '../widgets/notification_filter_sheet.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = 'current_user_id'; // This should come from auth

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationsProvider.notifier)
          .loadNotifications(_currentUserId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref
          .read(notificationsProvider.notifier)
          .loadNotifications(_currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Unread count badge
          if (notificationsState.unreadCount > 0)
            Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${notificationsState.unreadCount}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
          // Mark all as read button
          if (notificationsState.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: () => _markAllAsRead(),
            ),
          // More options
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Notification Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshNotifications(),
        child: _buildBody(notificationsState, theme),
      ),
    );
  }

  Widget _buildBody(NotificationsState state, ThemeData theme) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
      return _buildErrorState(state.error!, theme);
    }

    if (state.notifications.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        // Quick stats
        _buildQuickStats(state, theme),
        // Notifications list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final notification = state.notifications[index];
              return NotificationCard(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onMarkAsRead: () => _markAsRead(notification.id),
                onDelete: () => _deleteNotification(notification.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(NotificationsState state, ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total',
            '${state.notifications.length}',
            Icons.notifications,
            theme,
          ),
          _buildStatItem(
            'Unread',
            '${state.unreadCount}',
            Icons.mark_email_unread,
            theme,
          ),
          _buildStatItem(
            'Today',
            '${_getTodayCount(state.notifications)}',
            Icons.today,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        SizedBox(height: 4.h),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load notifications',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _refreshNotifications(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64.w,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              'No notifications yet',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'When you receive notifications, they\'ll appear here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _refreshNotifications(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const NotificationFilterSheet(),
    );
  }

  void _handleNotificationTap(domain.Notification notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Handle action URL if present
    if (notification.hasAction) {
      // Navigate to action URL or handle action
      // This would typically use a router or navigation service
    }
  }

  void _markAsRead(String notificationId) {
    ref.read(notificationsProvider.notifier).markAsRead(notificationId);
  }

  void _markAllAsRead() {
    ref.read(notificationsProvider.notifier).markAllAsRead(_currentUserId);
  }

  void _deleteNotification(String notificationId) {
    ref.read(notificationsProvider.notifier).deleteNotification(notificationId);
  }

  Future<void> _refreshNotifications() async {
    await ref
        .read(notificationsProvider.notifier)
        .loadNotifications(_currentUserId, refresh: true);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _refreshNotifications();
        break;
      case 'settings':
        // Navigate to notification settings
        break;
    }
  }

  int _getTodayCount(List<domain.Notification> notifications) {
    final today = DateTime.now();
    return notifications.where((notification) {
      return notification.createdAt.year == today.year &&
          notification.createdAt.month == today.month &&
          notification.createdAt.day == today.day;
    }).length;
  }
}

// Provider definitions (these would typically be in a separate file)
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
      return NotificationsNotifier(
        getUserNotifications: ref.watch(getUserNotificationsProvider),
        markAsRead: ref.watch(markNotificationAsReadProvider),
        markAllAsRead: ref.watch(markAllNotificationsAsReadProvider),
        getUnreadCount: ref.watch(getUnreadCountProvider),
        deleteNotification: ref.watch(deleteNotificationProvider),
      );
    });
