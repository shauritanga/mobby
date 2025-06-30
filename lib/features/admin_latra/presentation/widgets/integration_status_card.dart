import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/verification_status.dart';

class IntegrationStatusCard extends StatelessWidget {
  final IntegrationStatus status;
  final VoidCallback onTap;
  final VoidCallback onTest;
  final VoidCallback onViewEvents;

  const IntegrationStatusCard({
    super.key,
    required this.status,
    required this.onTap,
    required this.onTest,
    required this.onViewEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Icon(
                    _getServiceIcon(),
                    size: 24.r,
                    color: _getHealthColor(),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.serviceName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Last check: ${DateFormat('MMM dd, HH:mm').format(status.lastCheck)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildHealthBadge(context),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      context,
                      'Response Time',
                      '${status.responseTime}ms',
                      Icons.speed,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildMetric(
                      context,
                      'Events',
                      '${status.recentEvents.length}',
                      Icons.event_note,
                    ),
                  ),
                ],
              ),
              
              if (status.errorMessage != null) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16.r,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          status.errorMessage!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              SizedBox(height: 16.h),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTest,
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Test'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewEvents,
                      icon: const Icon(Icons.event_note, size: 16),
                      label: const Text('Events'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon() {
    if (status.serviceName.toLowerCase().contains('latra')) {
      return Icons.account_balance;
    } else if (status.serviceName.toLowerCase().contains('verification')) {
      return Icons.verified;
    } else {
      return Icons.cloud;
    }
  }

  Color _getHealthColor() {
    switch (status.health) {
      case IntegrationHealth.healthy:
        return Colors.green;
      case IntegrationHealth.warning:
        return Colors.orange;
      case IntegrationHealth.down:
        return Colors.red;
      case IntegrationHealth.unknown:
        return Colors.grey;
    }
  }

  Widget _buildHealthBadge(BuildContext context) {
    final color = _getHealthColor();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            status.health.displayName,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14.r,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
