import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_status.dart';
import '../../domain/entities/latra_document.dart';

/// Status Indicator widget for displaying various LATRA status types
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class StatusIndicator extends StatelessWidget {
  final dynamic
  status; // Can be LATRAApplicationStatus, LATRAStatusType, or LATRADocumentStatus
  final String? customText;
  final StatusIndicatorSize size;
  final bool showIcon;
  final bool showText;
  final VoidCallback? onTap;

  const StatusIndicator({
    super.key,
    required this.status,
    this.customText,
    this.size = StatusIndicatorSize.medium,
    this.showIcon = true,
    this.showText = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData();

    Widget indicator = Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: _getVerticalPadding(),
      ),
      decoration: BoxDecoration(
        color: statusData.backgroundColor,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: Border.all(color: statusData.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              statusData.icon,
              color: statusData.iconColor,
              size: _getIconSize(),
            ),
            if (showText) SizedBox(width: _getIconTextSpacing()),
          ],
          if (showText)
            Text(
              customText ?? statusData.text,
              style: TextStyle(
                fontSize: _getTextSize(),
                fontWeight: FontWeight.w600,
                color: statusData.textColor,
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      indicator = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: indicator,
      );
    }

    return indicator;
  }

  StatusData _getStatusData() {
    if (status is LATRAApplicationStatus) {
      return _getApplicationStatusData(status as LATRAApplicationStatus);
    } else if (status is LATRAStatusType) {
      return _getStatusTypeData(status as LATRAStatusType);
    } else if (status is LATRADocumentStatus) {
      return _getDocumentStatusData(status as LATRADocumentStatus);
    } else {
      return StatusData(
        text: status.toString(),
        icon: Icons.help,
        backgroundColor: AppColors.textSecondary.withOpacity(0.1),
        borderColor: AppColors.textSecondary,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textSecondary,
      );
    }
  }

  StatusData _getApplicationStatusData(LATRAApplicationStatus status) {
    switch (status) {
      case LATRAApplicationStatus.draft:
        return StatusData(
          text: 'Draft',
          icon: Icons.edit,
          backgroundColor: AppColors.textSecondary.withOpacity(0.1),
          borderColor: AppColors.textSecondary,
          iconColor: AppColors.textSecondary,
          textColor: AppColors.textSecondary,
        );
      case LATRAApplicationStatus.submitted:
        return StatusData(
          text: 'Submitted',
          icon: Icons.send,
          backgroundColor: AppColors.info.withOpacity(0.1),
          borderColor: AppColors.info,
          iconColor: AppColors.info,
          textColor: AppColors.info,
        );
      case LATRAApplicationStatus.pending:
        return StatusData(
          text: 'Pending',
          icon: Icons.pending,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case LATRAApplicationStatus.underReview:
        return StatusData(
          text: 'Under Review',
          icon: Icons.search,
          backgroundColor: AppColors.info.withOpacity(0.1),
          borderColor: AppColors.info,
          iconColor: AppColors.info,
          textColor: AppColors.info,
        );
      case LATRAApplicationStatus.documentsRequired:
        return StatusData(
          text: 'Documents Required',
          icon: Icons.upload_file,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case LATRAApplicationStatus.approved:
        return StatusData(
          text: 'Approved',
          icon: Icons.check_circle,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.success,
        );
      case LATRAApplicationStatus.completed:
        return StatusData(
          text: 'Completed',
          icon: Icons.done_all,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.success,
        );
      case LATRAApplicationStatus.rejected:
        return StatusData(
          text: 'Rejected',
          icon: Icons.cancel,
          backgroundColor: AppColors.error.withOpacity(0.1),
          borderColor: AppColors.error,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        );
      case LATRAApplicationStatus.cancelled:
        return StatusData(
          text: 'Cancelled',
          icon: Icons.block,
          backgroundColor: AppColors.textSecondary.withOpacity(0.1),
          borderColor: AppColors.textSecondary,
          iconColor: AppColors.textSecondary,
          textColor: AppColors.textSecondary,
        );
    }
  }

  StatusData _getStatusTypeData(LATRAStatusType status) {
    switch (status) {
      case LATRAStatusType.submitted:
        return StatusData(
          text: 'Submitted',
          icon: Icons.send,
          backgroundColor: AppColors.info.withOpacity(0.1),
          borderColor: AppColors.info,
          iconColor: AppColors.info,
          textColor: AppColors.info,
        );
      case LATRAStatusType.received:
        return StatusData(
          text: 'Received',
          icon: Icons.inbox,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          borderColor: AppColors.primary,
          iconColor: AppColors.primary,
          textColor: AppColors.primary,
        );
      case LATRAStatusType.underReview:
        return StatusData(
          text: 'Under Review',
          icon: Icons.search,
          backgroundColor: AppColors.info.withOpacity(0.1),
          borderColor: AppColors.info,
          iconColor: AppColors.info,
          textColor: AppColors.info,
        );
      case LATRAStatusType.documentsRequired:
        return StatusData(
          text: 'Documents Required',
          icon: Icons.upload_file,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case LATRAStatusType.paymentRequired:
        return StatusData(
          text: 'Payment Required',
          icon: Icons.payment,
          backgroundColor: AppColors.error.withOpacity(0.1),
          borderColor: AppColors.error,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        );
      case LATRAStatusType.appointmentRequired:
        return StatusData(
          text: 'Appointment Required',
          icon: Icons.event,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case LATRAStatusType.processed:
        return StatusData(
          text: 'Processed',
          icon: Icons.check_circle_outline,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.success,
        );
      case LATRAStatusType.approved:
        return StatusData(
          text: 'Approved',
          icon: Icons.check_circle,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.success,
        );
      case LATRAStatusType.rejected:
        return StatusData(
          text: 'Rejected',
          icon: Icons.cancel,
          backgroundColor: AppColors.error.withOpacity(0.1),
          borderColor: AppColors.error,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        );
      case LATRAStatusType.cancelled:
        return StatusData(
          text: 'Cancelled',
          icon: Icons.block,
          backgroundColor: AppColors.textSecondary.withOpacity(0.1),
          borderColor: AppColors.textSecondary,
          iconColor: AppColors.textSecondary,
          textColor: AppColors.textSecondary,
        );
      case LATRAStatusType.completed:
        return StatusData(
          text: 'Completed',
          icon: Icons.done_all,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.success,
        );
    }
  }

  StatusData _getDocumentStatusData(LATRADocumentStatus status) {
    switch (status) {
      case LATRADocumentStatus.pending:
        return StatusData(
          text: 'Pending',
          icon: Icons.pending,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case LATRADocumentStatus.verified:
        return StatusData(
          text: 'Verified',
          icon: Icons.verified,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.success,
        );
      case LATRADocumentStatus.uploaded:
        return StatusData(
          text: 'Uploaded',
          icon: Icons.upload_file,
          backgroundColor: AppColors.info.withOpacity(0.1),
          borderColor: AppColors.info,
          iconColor: AppColors.info,
          textColor: AppColors.info,
        );
      case LATRADocumentStatus.rejected:
        return StatusData(
          text: 'Rejected',
          icon: Icons.cancel,
          backgroundColor: AppColors.error.withOpacity(0.1),
          borderColor: AppColors.error,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        );
      case LATRADocumentStatus.expired:
        return StatusData(
          text: 'Expired',
          icon: Icons.error,
          backgroundColor: AppColors.error.withOpacity(0.1),
          borderColor: AppColors.error,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        );
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case StatusIndicatorSize.small:
        return 6.w;
      case StatusIndicatorSize.medium:
        return 8.w;
      case StatusIndicatorSize.large:
        return 12.w;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case StatusIndicatorSize.small:
        return 3.h;
      case StatusIndicatorSize.medium:
        return 4.h;
      case StatusIndicatorSize.large:
        return 6.h;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case StatusIndicatorSize.small:
        return 8.r;
      case StatusIndicatorSize.medium:
        return 12.r;
      case StatusIndicatorSize.large:
        return 16.r;
    }
  }

  double _getIconSize() {
    switch (size) {
      case StatusIndicatorSize.small:
        return 12.w;
      case StatusIndicatorSize.medium:
        return 16.w;
      case StatusIndicatorSize.large:
        return 20.w;
    }
  }

  double _getTextSize() {
    switch (size) {
      case StatusIndicatorSize.small:
        return 10.sp;
      case StatusIndicatorSize.medium:
        return 12.sp;
      case StatusIndicatorSize.large:
        return 14.sp;
    }
  }

  double _getIconTextSpacing() {
    switch (size) {
      case StatusIndicatorSize.small:
        return 4.w;
      case StatusIndicatorSize.medium:
        return 6.w;
      case StatusIndicatorSize.large:
        return 8.w;
    }
  }
}

/// Status indicator size enumeration
enum StatusIndicatorSize { small, medium, large }

/// Status data class
class StatusData {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  const StatusData({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}
