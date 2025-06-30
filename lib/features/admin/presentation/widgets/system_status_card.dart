import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/system_status.dart';

class SystemStatusCard extends StatelessWidget {
  final SystemStatus systemStatus;

  const SystemStatusCard({super.key, required this.systemStatus});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(systemStatus.overallStatus),
                  size: 24.r,
                  color: _getStatusColor(systemStatus.overallStatus),
                ),
                SizedBox(width: 12.w),
                Text(
                  'System Status',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      systemStatus.overallStatus,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    systemStatus.overallStatusDisplayName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(systemStatus.overallStatus),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Services',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),
            ...systemStatus.services
                .take(3)
                .map(
                  (service) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          _getServiceStatusIcon(service.status),
                          size: 16.r,
                          color: _getServiceStatusColor(service.status),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            service.serviceName,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          '${service.responseTime}ms',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if (systemStatus.services.length > 3) ...[
              SizedBox(height: 4.h),
              Text(
                '+${systemStatus.services.length - 3} more services',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.healthy:
        return Icons.check_circle;
      case ServiceStatus.warning:
        return Icons.warning;
      case ServiceStatus.critical:
        return Icons.error;
      case ServiceStatus.down:
        return Icons.error;
      case ServiceStatus.maintenance:
        return Icons.build;
    }
  }

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.healthy:
        return Colors.green;
      case ServiceStatus.warning:
        return Colors.orange;
      case ServiceStatus.critical:
        return Colors.red;
      case ServiceStatus.down:
        return Colors.red;
      case ServiceStatus.maintenance:
        return Colors.blue;
    }
  }

  IconData _getServiceStatusIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.healthy:
        return Icons.check_circle_outline;
      case ServiceStatus.warning:
        return Icons.warning_amber;
      case ServiceStatus.critical:
        return Icons.error_outline;
      case ServiceStatus.down:
        return Icons.error_outline;
      case ServiceStatus.maintenance:
        return Icons.build_circle;
    }
  }

  Color _getServiceStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.healthy:
        return Colors.green;
      case ServiceStatus.warning:
        return Colors.orange;
      case ServiceStatus.critical:
        return Colors.red;
      case ServiceStatus.down:
        return Colors.red;
      case ServiceStatus.maintenance:
        return Colors.blue;
    }
  }
}
