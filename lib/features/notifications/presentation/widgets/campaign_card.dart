import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobby/features/notifications/notifications_feature.dart';
import '../../domain/entities/campaign.dart';
import '../providers/campaigns_provider.dart';

class CampaignCard extends ConsumerWidget {
  final Campaign campaign;
  final VoidCallback? onTap;
  final VoidCallback? onLaunch;
  final VoidCallback? onPause;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onTap,
    this.onLaunch,
    this.onPause,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsState = ref.watch(campaignStatsProvider(campaign.id));
    final stats = statsState.stats[campaign.id];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        elevation: 2,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            campaign.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    _buildStatusChip(theme),
                  ],
                ),
                SizedBox(height: 16.h),
                // Campaign details
                Row(
                  children: [
                    _buildDetailChip(
                      icon: Icons.category,
                      label: campaign.typeText,
                      theme: theme,
                    ),
                    SizedBox(width: 8.w),
                    _buildDetailChip(
                      icon: Icons.people,
                      label: campaign.audienceText,
                      theme: theme,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Channels
                Wrap(
                  spacing: 4.w,
                  children: campaign.channels.map((channel) {
                    return _buildChannelChip(channel, theme);
                  }).toList(),
                ),
                // Stats section
                if (stats != null) ...[
                  SizedBox(height: 16.h),
                  _buildStatsSection(stats, theme),
                ],
                SizedBox(height: 16.h),
                // Action buttons
                Row(
                  children: [
                    // Primary action button
                    if (campaign.isDraft)
                      ElevatedButton.icon(
                        onPressed: onLaunch,
                        icon: const Icon(Icons.launch, size: 16),
                        label: const Text('Launch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      )
                    else if (campaign.isActive)
                      ElevatedButton.icon(
                        onPressed: onPause,
                        icon: const Icon(Icons.pause, size: 16),
                        label: const Text('Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      )
                    else if (campaign.status == CampaignStatus.paused)
                      ElevatedButton.icon(
                        onPressed: onLaunch,
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: const Text('Resume'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    const Spacer(),
                    // Secondary actions
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                    ),
                    PopupMenuButton<String>(
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: ListTile(
                            leading: Icon(Icons.copy),
                            title: Text('Duplicate'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'analytics',
                          child: ListTile(
                            leading: Icon(Icons.analytics),
                            title: Text('View Analytics'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (!campaign.isActive)
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                // Dates
                SizedBox(height: 8.h),
                _buildDatesSection(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    Color color;
    IconData icon;

    switch (campaign.status) {
      case CampaignStatus.draft:
        color = Colors.grey;
        icon = Icons.edit;
        break;
      case CampaignStatus.scheduled:
        color = Colors.blue;
        icon = Icons.schedule;
        break;
      case CampaignStatus.active:
        color = Colors.green;
        icon = Icons.play_arrow;
        break;
      case CampaignStatus.paused:
        color = Colors.orange;
        icon = Icons.pause;
        break;
      case CampaignStatus.completed:
        color = Colors.teal;
        icon = Icons.check_circle;
        break;
      case CampaignStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.w, color: color),
          SizedBox(width: 4.w),
          Text(
            campaign.statusText,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: 4.w),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelChip(NotificationChannel channel, ThemeData theme) {
    IconData icon;
    String label;

    switch (channel) {
      case NotificationChannel.push:
        icon = Icons.notifications;
        label = 'Push';
        break;
      case NotificationChannel.email:
        icon = Icons.email;
        label = 'Email';
        break;
      case NotificationChannel.sms:
        icon = Icons.sms;
        label = 'SMS';
        break;
      case NotificationChannel.inApp:
        icon = Icons.app_registration;
        label = 'In-App';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: theme.colorScheme.primary),
          SizedBox(width: 2.w),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(CampaignStats stats, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Sent', '${stats.totalSent}', theme),
          _buildStatItem('Delivered', '${stats.delivered}', theme),
          _buildStatItem('Opened', '${stats.opened}', theme),
          _buildStatItem('Clicked', '${stats.clicked}', theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDatesSection(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14.w,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 4.w),
        Text(
          'Created ${_formatDate(campaign.createdAt)}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (campaign.launchedAt != null) ...[
          SizedBox(width: 16.w),
          Icon(
            Icons.launch,
            size: 14.w,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Text(
            'Launched ${_formatDate(campaign.launchedAt!)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'duplicate':
        // Handle duplicate
        break;
      case 'analytics':
        // Handle analytics
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}

// Provider definitions
final campaignStatsProvider =
    StateNotifierProvider.family<
      CampaignStatsNotifier,
      CampaignStatsState,
      String
    >((ref, campaignId) {
      final watchCampaignStats = ref.watch(getCampaignStatsProvider);
      return CampaignStatsNotifier(getCampaignStats: watchCampaignStats);
    });
