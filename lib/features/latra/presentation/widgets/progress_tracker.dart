import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_status.dart';

/// Progress Tracker widget for displaying LATRA application progress
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class ProgressTracker extends StatelessWidget {
  final LATRAApplication application;
  final List<LATRAStatus>? statusHistory;
  final ProgressTrackerStyle style;
  final bool showLabels;
  final bool showPercentage;
  final VoidCallback? onStepTap;

  const ProgressTracker({
    super.key,
    required this.application,
    this.statusHistory,
    this.style = ProgressTrackerStyle.horizontal,
    this.showLabels = true,
    this.showPercentage = true,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case ProgressTrackerStyle.horizontal:
        return _buildHorizontalTracker();
      case ProgressTrackerStyle.vertical:
        return _buildVerticalTracker();
      case ProgressTrackerStyle.circular:
        return _buildCircularTracker();
      case ProgressTrackerStyle.linear:
        return _buildLinearTracker();
    }
  }

  Widget _buildHorizontalTracker() {
    final steps = _getProgressSteps();
    final currentStepIndex = _getCurrentStepIndex();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPercentage) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Application Progress',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_getProgressPercentage()}%',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getStatusColor(application.status.name),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],

          // Progress steps
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                Expanded(
                  child: _buildHorizontalStep(
                    steps[i],
                    i,
                    currentStepIndex,
                    isLast: i == steps.length - 1,
                  ),
                ),
                if (i < steps.length - 1)
                  _buildHorizontalConnector(i < currentStepIndex),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTracker() {
    final steps = _getProgressSteps();
    final currentStepIndex = _getCurrentStepIndex();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPercentage) ...[
            Text(
              'Progress: ${_getProgressPercentage()}%',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.getStatusColor(application.status.name),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Progress steps
          for (int i = 0; i < steps.length; i++)
            _buildVerticalStep(
              steps[i],
              i,
              currentStepIndex,
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildCircularTracker() {
    final progress = _getProgress();
    final statusColor = AppColors.getStatusColor(application.status.name);

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Circular progress
          SizedBox(
            width: 120.w,
            height: 120.w,
            child: Stack(
              children: [
                // Background circle
                SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8.w,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.border),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8.w,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                // Center content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_getProgressPercentage()}%',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Status text
          Text(
            application.status.displayName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),

          if (showLabels) ...[
            SizedBox(height: 8.h),
            Text(
              _getStatusDescription(),
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinearTracker() {
    final progress = _getProgress();
    final statusColor = AppColors.getStatusColor(application.status.name);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_getProgressPercentage()}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Progress bar
          Container(
            width: double.infinity,
            height: 8.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),

          if (showLabels) ...[
            SizedBox(height: 8.h),
            Text(
              application.status.displayName,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHorizontalStep(
    ProgressStep step,
    int index,
    int currentStepIndex, {
    required bool isLast,
  }) {
    final isCompleted = index < currentStepIndex;
    final isCurrent = index == currentStepIndex;
    final color = isCompleted || isCurrent
        ? AppColors.getStatusColor(application.status.name)
        : AppColors.textSecondary;

    return Column(
      children: [
        // Step circle
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent ? color : Colors.white,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 16.w)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : color,
                    ),
                  ),
          ),
        ),

        if (showLabels) ...[
          SizedBox(height: 8.h),
          Text(
            step.title,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: isCompleted || isCurrent ? color : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildVerticalStep(
    ProgressStep step,
    int index,
    int currentStepIndex, {
    required bool isLast,
  }) {
    final isCompleted = index < currentStepIndex;
    final isCurrent = index == currentStepIndex;
    final color = isCompleted || isCurrent
        ? AppColors.getStatusColor(application.status.name)
        : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator column
        Column(
          children: [
            // Step circle
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent ? color : Colors.white,
                border: Border.all(color: color, width: 2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: 16.w)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.white : color,
                        ),
                      ),
              ),
            ),

            // Connector line
            if (!isLast)
              Container(
                width: 2.w,
                height: 40.h,
                color: isCompleted ? color : AppColors.border,
                margin: EdgeInsets.symmetric(vertical: 8.h),
              ),
          ],
        ),

        SizedBox(width: 16.w),

        // Step content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h, bottom: isLast ? 0 : 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isCompleted || isCurrent
                        ? color
                        : AppColors.textSecondary,
                  ),
                ),
                if (step.description != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    step.description!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalConnector(bool isCompleted) {
    return Container(
      width: 24.w,
      height: 2.h,
      color: isCompleted
          ? AppColors.getStatusColor(application.status.name)
          : AppColors.border,
      margin: EdgeInsets.only(bottom: showLabels ? 32.h : 0),
    );
  }

  List<ProgressStep> _getProgressSteps() {
    return [
      ProgressStep(
        title: 'Submitted',
        description: 'Application submitted to LATRA',
      ),
      ProgressStep(title: 'Review', description: 'Under review by officials'),
      ProgressStep(
        title: 'Processing',
        description: 'Documents being processed',
      ),
      ProgressStep(title: 'Completed', description: 'Application approved'),
    ];
  }

  int _getCurrentStepIndex() {
    switch (application.status) {
      case LATRAApplicationStatus.draft:
        return 0;
      case LATRAApplicationStatus.submitted:
        return 1;
      case LATRAApplicationStatus.pending:
        return 1;
      case LATRAApplicationStatus.underReview:
        return 2;
      case LATRAApplicationStatus.documentsRequired:
        return 1;
      case LATRAApplicationStatus.approved:
        return 4;
      case LATRAApplicationStatus.completed:
        return 4;
      case LATRAApplicationStatus.rejected:
        return 2;
      case LATRAApplicationStatus.cancelled:
        return 1;
    }
  }

  double _getProgress() {
    switch (application.status) {
      case LATRAApplicationStatus.draft:
        return 0.1;
      case LATRAApplicationStatus.submitted:
        return 0.25;
      case LATRAApplicationStatus.pending:
        return 0.3;
      case LATRAApplicationStatus.underReview:
        return 0.6;
      case LATRAApplicationStatus.documentsRequired:
        return 0.4;
      case LATRAApplicationStatus.approved:
        return 1.0;
      case LATRAApplicationStatus.completed:
        return 1.0;
      case LATRAApplicationStatus.rejected:
        return 0.8;
      case LATRAApplicationStatus.cancelled:
        return 0.2;
    }
  }

  int _getProgressPercentage() {
    return (_getProgress() * 100).toInt();
  }

  String _getStatusDescription() {
    switch (application.status) {
      case LATRAApplicationStatus.draft:
        return 'Application is being prepared';
      case LATRAApplicationStatus.submitted:
        return 'Application has been submitted';
      case LATRAApplicationStatus.pending:
        return 'Waiting for review';
      case LATRAApplicationStatus.underReview:
        return 'Being reviewed by officials';
      case LATRAApplicationStatus.documentsRequired:
        return 'Additional documents needed';
      case LATRAApplicationStatus.approved:
        return 'Application has been approved';
      case LATRAApplicationStatus.completed:
        return 'Application process completed';
      case LATRAApplicationStatus.rejected:
        return 'Application was not approved';
      case LATRAApplicationStatus.cancelled:
        return 'Application was cancelled';
    }
  }
}

/// Progress tracker style enumeration
enum ProgressTrackerStyle { horizontal, vertical, circular, linear }

/// Progress step data class
class ProgressStep {
  final String title;
  final String? description;
  final DateTime? timestamp;

  const ProgressStep({required this.title, this.description, this.timestamp});
}
