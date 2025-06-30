import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_status.dart';

/// Status Timeline widget for displaying application progress
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class StatusTimeline extends StatelessWidget {
  final List<LATRAStatus> statusList;
  final Function(LATRAStatus)? onStatusTap;

  const StatusTimeline({
    super.key,
    required this.statusList,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    if (statusList.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        for (int i = 0; i < statusList.length; i++)
          _buildTimelineItem(
            statusList[i],
            isFirst: i == 0,
            isLast: i == statusList.length - 1,
          ),
      ],
    );
  }

  Widget _buildTimelineItem(
    LATRAStatus status, {
    required bool isFirst,
    required bool isLast,
  }) {
    final statusColor = AppColors.getStatusColor(status.type.name);
    final isLatest = isFirst;

    return InkWell(
      onTap: onStatusTap != null ? () => onStatusTap!(status) : null,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                // Timeline dot
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: isLatest ? statusColor : statusColor.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isLatest
                      ? Icon(
                          _getStatusIcon(status.type),
                          color: Colors.white,
                          size: 12.w,
                        )
                      : null,
                ),
                
                // Timeline line
                if (!isLast)
                  Container(
                    width: 2.w,
                    height: 40.h,
                    color: AppColors.border,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                  ),
              ],
            ),
            
            SizedBox(width: 16.w),
            
            // Status content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          status.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: isLatest ? FontWeight.bold : FontWeight.w600,
                            color: isLatest ? statusColor : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          status.type.displayName,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Status description
                  Text(
                    status.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  // Additional details
                  if (status.details != null && status.details!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        status.details!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 8.h),
                  
                  // Timestamp and officer info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.textSecondary,
                        size: 14.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatTimestamp(status.timestamp),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      if (status.officerName != null) ...[
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 14.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          status.officerName!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  if (status.officeLocation != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.textSecondary,
                          size: 14.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          status.officeLocation!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Action required indicator
                  if (status.requiresAction && isLatest) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: AppColors.warning,
                            size: 16.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Action Required',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            color: AppColors.textSecondary,
            size: 48.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Status Updates',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Status updates will appear here as your application progresses through the LATRA system.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(LATRAStatusType type) {
    switch (type) {
      case LATRAStatusType.submitted:
        return Icons.send;
      case LATRAStatusType.received:
        return Icons.inbox;
      case LATRAStatusType.underReview:
        return Icons.search;
      case LATRAStatusType.documentsRequired:
        return Icons.upload_file;
      case LATRAStatusType.paymentRequired:
        return Icons.payment;
      case LATRAStatusType.appointmentRequired:
        return Icons.event;
      case LATRAStatusType.processed:
        return Icons.check_circle_outline;
      case LATRAStatusType.approved:
        return Icons.check_circle;
      case LATRAStatusType.rejected:
        return Icons.cancel;
      case LATRAStatusType.cancelled:
        return Icons.block;
      case LATRAStatusType.completed:
        return Icons.done_all;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
