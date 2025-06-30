import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_status.dart';

/// Next Steps Card widget for guiding users on what to do next
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class NextStepsCard extends StatelessWidget {
  final LATRAApplication application;
  final LATRAStatus currentStatus;
  final Function(String) onActionTap;

  const NextStepsCard({
    super.key,
    required this.application,
    required this.currentStatus,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final nextSteps = _getNextSteps();
    
    if (nextSteps.isEmpty) {
      return _buildNoActionRequiredCard();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.directions,
                color: AppColors.primary,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Next Steps',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Steps list
          ...nextSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return _buildStepItem(step, index + 1);
          }),
          
          SizedBox(height: 16.h),
          
          // Estimated timeline
          if (_getEstimatedTimeline().isNotEmpty)
            _buildTimelineInfo(),
        ],
      ),
    );
  }

  Widget _buildStepItem(NextStep step, int stepNumber) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: step.isUrgent ? AppColors.warning : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Step content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    
                    if (step.isUrgent)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Urgent',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 4.h),
                
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                if (step.deadline != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: step.isUrgent ? AppColors.warning : AppColors.textSecondary,
                        size: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Deadline: ${_formatDate(step.deadline!)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: step.isUrgent ? AppColors.warning : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (step.actionId != null) ...[
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () => onActionTap(step.actionId!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: step.isUrgent ? AppColors.warning : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      step.actionText ?? 'Take Action',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineInfo() {
    final timeline = _getEstimatedTimeline();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: AppColors.info,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Estimated Timeline',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            timeline,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActionRequiredCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 48.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Action Required',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _getNoActionMessage(),
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

  List<NextStep> _getNextSteps() {
    switch (currentStatus.type) {
      case LATRAStatusType.documentsRequired:
        return [
          NextStep(
            title: 'Upload Required Documents',
            description: 'Submit the missing documents to continue processing your application.',
            actionId: 'upload_documents',
            actionText: 'Upload Now',
            isUrgent: true,
            deadline: DateTime.now().add(const Duration(days: 7)),
          ),
        ];
      
      case LATRAStatusType.paymentRequired:
        return [
          NextStep(
            title: 'Complete Payment',
            description: 'Pay the required fees to proceed with your application.',
            actionId: 'make_payment',
            actionText: 'Pay Now',
            isUrgent: true,
            deadline: DateTime.now().add(const Duration(days: 14)),
          ),
        ];
      
      case LATRAStatusType.appointmentRequired:
        return [
          NextStep(
            title: 'Book Appointment',
            description: 'Schedule your appointment for the practical test or document verification.',
            actionId: 'book_appointment',
            actionText: 'Book Now',
            isUrgent: false,
          ),
        ];
      
      case LATRAStatusType.underReview:
        return [
          NextStep(
            title: 'Wait for Review',
            description: 'Your application is being reviewed by LATRA officials. No action required.',
            isUrgent: false,
          ),
        ];
      
      case LATRAStatusType.processed:
        return [
          NextStep(
            title: 'Collect Certificate',
            description: 'Your application has been approved. Visit the LATRA office to collect your certificate.',
            actionId: 'contact_support',
            actionText: 'Get Directions',
            isUrgent: false,
          ),
        ];
      
      default:
        return [];
    }
  }

  String _getEstimatedTimeline() {
    switch (currentStatus.type) {
      case LATRAStatusType.documentsRequired:
        return 'Processing will resume within 2-3 business days after document submission.';
      case LATRAStatusType.paymentRequired:
        return 'Processing will continue within 1-2 business days after payment confirmation.';
      case LATRAStatusType.appointmentRequired:
        return 'Appointment slots are typically available within 1-2 weeks.';
      case LATRAStatusType.underReview:
        return 'Review process typically takes 5-10 business days.';
      case LATRAStatusType.processed:
        return 'Certificate is ready for collection during office hours.';
      default:
        return '';
    }
  }

  String _getNoActionMessage() {
    switch (currentStatus.type) {
      case LATRAStatusType.approved:
        return 'Your application has been approved! You can now use your new registration.';
      case LATRAStatusType.completed:
        return 'Your application process is complete. Thank you for using LATRA services.';
      case LATRAStatusType.rejected:
        return 'Your application was not approved. Contact support for more information.';
      case LATRAStatusType.cancelled:
        return 'This application has been cancelled.';
      default:
        return 'Your application is being processed. We\'ll notify you when action is required.';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Next step data class
class NextStep {
  final String title;
  final String description;
  final String? actionId;
  final String? actionText;
  final bool isUrgent;
  final DateTime? deadline;

  const NextStep({
    required this.title,
    required this.description,
    this.actionId,
    this.actionText,
    this.isUrgent = false,
    this.deadline,
  });
}
