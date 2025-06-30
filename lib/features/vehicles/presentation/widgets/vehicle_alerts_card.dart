import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/vehicle_providers.dart';

/// Vehicle alerts card widget for displaying vehicle alerts
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleAlertsCard extends ConsumerWidget {
  const VehicleAlertsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(vehicleAlertsProvider);

    return alertsAsync.when(
      data: (alerts) {
        final expiredDocs = alerts['expiredDocuments'] as List? ?? [];
        final expiringSoonDocs = alerts['expiringSoonDocuments'] as List? ?? [];
        final overdueMaintenance = alerts['overdueMaintenance'] as List? ?? [];

        final hasAlerts = expiredDocs.isNotEmpty || 
                         expiringSoonDocs.isNotEmpty || 
                         overdueMaintenance.isNotEmpty;

        if (!hasAlerts) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 20.sp,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Attention Required',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push('/vehicles/alerts'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  if (expiredDocs.isNotEmpty)
                    _buildAlertItem(
                      context,
                      Icons.error,
                      'Expired Documents',
                      '${expiredDocs.length} document${expiredDocs.length > 1 ? 's' : ''} expired',
                      Colors.red,
                      () => context.push('/vehicles/documents/expired'),
                    ),
                  
                  if (expiringSoonDocs.isNotEmpty) ...[
                    if (expiredDocs.isNotEmpty) SizedBox(height: 8.h),
                    _buildAlertItem(
                      context,
                      Icons.schedule,
                      'Documents Expiring Soon',
                      '${expiringSoonDocs.length} document${expiringSoonDocs.length > 1 ? 's' : ''} expiring within 30 days',
                      Colors.orange,
                      () => context.push('/vehicles/documents/expiring-soon'),
                    ),
                  ],
                  
                  if (overdueMaintenance.isNotEmpty) ...[
                    if (expiredDocs.isNotEmpty || expiringSoonDocs.isNotEmpty) 
                      SizedBox(height: 8.h),
                    _buildAlertItem(
                      context,
                      Icons.build,
                      'Overdue Maintenance',
                      '${overdueMaintenance.length} maintenance task${overdueMaintenance.length > 1 ? 's' : ''} overdue',
                      Colors.amber,
                      () => context.push('/vehicles/maintenance/overdue'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildAlertItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                icon,
                size: 16.sp,
                color: color,
              ),
            ),
            
            SizedBox(width: 12.w),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: color.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
