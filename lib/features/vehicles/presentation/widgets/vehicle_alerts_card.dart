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
        final expiredDocs = alerts['expiredDocuments'] ?? [];
        final expiringSoonDocs = alerts['expiringSoonDocuments'] ?? [];
        final overdueMaintenance = alerts['overdueMaintenance'] ?? [];

        final hasAlerts =
            expiredDocs.isNotEmpty ||
            expiringSoonDocs.isNotEmpty ||
            overdueMaintenance.isNotEmpty;

        if (!hasAlerts) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade50,
                  Colors.red.shade50.withValues(alpha: 0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.withValues(alpha: 0.2),
                              Colors.orange.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          size: 24.sp,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attention Required',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange.shade800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Items need your attention',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.orange.shade700.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: TextButton(
                          onPressed: () => context.push('/vehicles/alerts'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
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
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 20.sp, color: color),
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: color.withValues(alpha: 0.8),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.sp,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
