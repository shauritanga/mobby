import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/campaign.dart';

class CampaignStatsCard extends StatelessWidget {
  final CampaignStats stats;
  final bool isLoading;

  const CampaignStatsCard({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: theme.colorScheme.primary,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Campaign Statistics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Sent',
                  '${stats.totalSent}',
                  Icons.send,
                  Colors.blue,
                  theme,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Delivered',
                  '${stats.delivered}',
                  Icons.check_circle,
                  Colors.green,
                  theme,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Opened',
                  '${stats.opened}',
                  Icons.mark_email_read,
                  Colors.orange,
                  theme,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Clicked',
                  '${stats.clicked}',
                  Icons.touch_app,
                  Colors.purple,
                  theme,
                ),
              ),
            ],
          ),
          if (stats.failed > 0) ...[
            SizedBox(height: 12.h),
            _buildStatItem(
              'Failed',
              '${stats.failed}',
              Icons.error,
              Colors.red,
              theme,
              fullWidth: true,
            ),
          ],
          SizedBox(height: 16.h),
          // Performance rates
          _buildPerformanceSection(theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme, {
    bool fullWidth = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: fullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 20.w),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: color, size: 24.w),
                SizedBox(height: 8.h),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildPerformanceSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Rates',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        _buildRateItem(
          'Delivery Rate',
          stats.deliveryRate,
          Colors.green,
          theme,
        ),
        SizedBox(height: 8.h),
        _buildRateItem(
          'Open Rate',
          stats.openRate,
          Colors.orange,
          theme,
        ),
        SizedBox(height: 8.h),
        _buildRateItem(
          'Click Rate',
          stats.clickRate,
          Colors.purple,
          theme,
        ),
      ],
    );
  }

  Widget _buildRateItem(
    String label,
    double rate,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${rate.toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        LinearProgressIndicator(
          value: rate / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
