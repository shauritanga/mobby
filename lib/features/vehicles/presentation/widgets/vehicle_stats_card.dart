import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/vehicle_providers.dart';

/// Vehicle stats card widget for displaying vehicle statistics
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleStatsCard extends ConsumerWidget {
  final String userId;

  const VehicleStatsCard({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(vehicleStatisticsProvider(userId));

    return statisticsAsync.when(
      data: (statistics) => _buildStatsCard(context, statistics),
      loading: () => _buildLoadingCard(context),
      error: (error, stack) => _buildErrorCard(context),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    Map<String, dynamic> statistics,
  ) {
    final totalVehicles = statistics['totalVehicles'] as int? ?? 0;
    final activeVehicles = statistics['activeVehicles'] as int? ?? 0;
    final expiredDocuments = statistics['expiredDocuments'] as int? ?? 0;
    final expiringSoonDocuments =
        statistics['expiringSoonDocuments'] as int? ?? 0;
    final totalMaintenanceCost =
        statistics['totalMaintenanceCost'] as double? ?? 0.0;
    final averageVehicleAge = statistics['averageVehicleAge'] as double? ?? 0.0;

    return Card(
      elevation: 1, // Reduced for Material 3 style
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Overview',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),

            SizedBox(height: 16.h),

            // Main Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.directions_car,
                    totalVehicles.toString(),
                    'Total Vehicles',
                    Theme.of(context).primaryColor,
                  ),
                ),

                Container(
                  width: 1,
                  height: 40.h,
                  color: Theme.of(context).dividerColor,
                ),

                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.check_circle,
                    activeVehicles.toString(),
                    'Active',
                    Colors.green,
                  ),
                ),

                Container(
                  width: 1,
                  height: 40.h,
                  color: Theme.of(context).dividerColor,
                ),

                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.warning,
                    (expiredDocuments + expiringSoonDocuments).toString(),
                    'Alerts',
                    expiredDocuments > 0 ? Colors.red : Colors.orange,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Additional Stats
            Row(
              children: [
                Expanded(
                  child: _buildDetailStat(
                    context,
                    'Avg. Age',
                    '${averageVehicleAge.toStringAsFixed(1)} years',
                    Icons.schedule,
                  ),
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: _buildDetailStat(
                    context,
                    'Total Maintenance',
                    _formatCurrency(totalMaintenanceCost),
                    Icons.build,
                  ),
                ),
              ],
            ),

            if (expiredDocuments > 0 || expiringSoonDocuments > 0) ...[
              SizedBox(height: 12.h),

              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16.sp, color: Colors.orange),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _getAlertMessage(
                          expiredDocuments,
                          expiringSoonDocuments,
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 20.sp, color: color),
        ),

        SizedBox(height: 8.h),

        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        SizedBox(height: 2.h),

        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Theme.of(context).primaryColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: 1, // Reduced for Material 3 style
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Overview',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),

            SizedBox(height: 16.h),

            Row(
              children: [
                Expanded(child: _buildLoadingStatItem(context)),
                Container(
                  width: 1,
                  height: 40.h,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(child: _buildLoadingStatItem(context)),
                Container(
                  width: 1,
                  height: 40.h,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(child: _buildLoadingStatItem(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStatItem(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 30.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          width: 50.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Card(
      elevation: 1, // Reduced for Material 3 style
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 32.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 8.h),
            Text(
              'Failed to load statistics',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount == 0) return 'TZS 0';

    final formatter = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return 'TZS $formatter';
  }

  String _getAlertMessage(int expired, int expiringSoon) {
    if (expired > 0 && expiringSoon > 0) {
      return '$expired document${expired > 1 ? 's' : ''} expired, $expiringSoon expiring soon';
    } else if (expired > 0) {
      return '$expired document${expired > 1 ? 's' : ''} expired';
    } else if (expiringSoon > 0) {
      return '$expiringSoon document${expiringSoon > 1 ? 's' : ''} expiring soon';
    }
    return '';
  }
}
