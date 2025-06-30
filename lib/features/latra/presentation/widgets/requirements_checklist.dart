import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../screens/license_application_screen.dart';

/// Requirements Checklist widget for license applications
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class RequirementsChecklist extends StatelessWidget {
  final LicenseType licenseType;
  final List<String> completedRequirements;
  final Function(String) onRequirementCompleted;
  final Function(String) onRequirementUncompleted;

  const RequirementsChecklist({
    super.key,
    required this.licenseType,
    required this.completedRequirements,
    required this.onRequirementCompleted,
    required this.onRequirementUncompleted,
  });

  @override
  Widget build(BuildContext context) {
    final requirements = _getRequirements(licenseType);
    final completionPercentage = completedRequirements.length / requirements.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with progress
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requirements Checklist',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Complete all requirements before submitting',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Progress indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: completionPercentage == 1.0 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: completionPercentage == 1.0 
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
              child: Text(
                '${completedRequirements.length}/${requirements.length}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: completionPercentage == 1.0 
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

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
            widthFactor: completionPercentage,
            child: Container(
              decoration: BoxDecoration(
                color: completionPercentage == 1.0 
                    ? AppColors.success
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // Requirements list
        Column(
          children: requirements.map((requirement) => _buildRequirementItem(requirement)).toList(),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(RequirementItem requirement) {
    final isCompleted = completedRequirements.contains(requirement.id);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          if (isCompleted) {
            onRequirementUncompleted(requirement.id);
          } else {
            onRequirementCompleted(requirement.id);
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isCompleted 
                ? AppColors.success.withOpacity(0.1) 
                : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isCompleted ? AppColors.success : AppColors.border,
              width: isCompleted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: isCompleted ? AppColors.success : AppColors.border,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16.w,
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              
              // Requirement icon
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  requirement.icon,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 16.w),
              
              // Requirement details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requirement.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isCompleted 
                            ? AppColors.success 
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (requirement.description.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        requirement.description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (requirement.isRequired) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<RequirementItem> _getRequirements(LicenseType licenseType) {
    switch (licenseType) {
      case LicenseType.learnerPermit:
        return [
          RequirementItem(
            id: 'age_18',
            title: 'Minimum Age (18 years)',
            description: 'Must be at least 18 years old',
            icon: Icons.cake,
            isRequired: true,
          ),
          RequirementItem(
            id: 'medical_certificate',
            title: 'Medical Certificate',
            description: 'Valid medical certificate from approved doctor',
            icon: Icons.medical_services,
            isRequired: true,
          ),
          RequirementItem(
            id: 'theory_test',
            title: 'Theory Test',
            description: 'Pass the written theory examination',
            icon: Icons.quiz,
            isRequired: true,
          ),
          RequirementItem(
            id: 'eye_test',
            title: 'Eye Test',
            description: 'Pass vision and eye examination',
            icon: Icons.visibility,
            isRequired: true,
          ),
          RequirementItem(
            id: 'application_fee',
            title: 'Application Fee',
            description: 'Pay required application fee',
            icon: Icons.payment,
            isRequired: true,
          ),
        ];
      
      case LicenseType.classA:
      case LicenseType.classB:
      case LicenseType.classC:
        return [
          RequirementItem(
            id: 'learner_permit',
            title: 'Valid Learner Permit',
            description: 'Must have valid learner permit for at least 6 months',
            icon: Icons.credit_card,
            isRequired: true,
          ),
          RequirementItem(
            id: 'practical_test',
            title: 'Practical Driving Test',
            description: 'Pass the practical driving examination',
            icon: Icons.directions_car,
            isRequired: true,
          ),
          RequirementItem(
            id: 'medical_certificate',
            title: 'Medical Certificate',
            description: 'Valid medical certificate',
            icon: Icons.medical_services,
            isRequired: true,
          ),
          RequirementItem(
            id: 'driving_experience',
            title: 'Driving Experience',
            description: 'Minimum 6 months driving experience',
            icon: Icons.schedule,
            isRequired: true,
          ),
          RequirementItem(
            id: 'theory_knowledge',
            title: 'Theory Knowledge',
            description: 'Demonstrate traffic rules knowledge',
            icon: Icons.school,
            isRequired: true,
          ),
          RequirementItem(
            id: 'vehicle_inspection',
            title: 'Vehicle Inspection',
            description: 'Vehicle safety and roadworthiness check',
            icon: Icons.build,
            isRequired: true,
          ),
          RequirementItem(
            id: 'application_fee',
            title: 'License Fee',
            description: 'Pay required license fee',
            icon: Icons.payment,
            isRequired: true,
          ),
        ];
      
      case LicenseType.motorcycle:
        return [
          RequirementItem(
            id: 'age_16',
            title: 'Minimum Age (16 years)',
            description: 'Must be at least 16 years old',
            icon: Icons.cake,
            isRequired: true,
          ),
          RequirementItem(
            id: 'medical_certificate',
            title: 'Medical Certificate',
            description: 'Valid medical certificate',
            icon: Icons.medical_services,
            isRequired: true,
          ),
          RequirementItem(
            id: 'theory_test',
            title: 'Theory Test',
            description: 'Pass motorcycle theory test',
            icon: Icons.quiz,
            isRequired: true,
          ),
          RequirementItem(
            id: 'practical_test',
            title: 'Practical Test',
            description: 'Pass motorcycle practical test',
            icon: Icons.two_wheeler,
            isRequired: true,
          ),
          RequirementItem(
            id: 'safety_course',
            title: 'Safety Course',
            description: 'Complete motorcycle safety course',
            icon: Icons.security,
            isRequired: true,
          ),
          RequirementItem(
            id: 'application_fee',
            title: 'License Fee',
            description: 'Pay required license fee',
            icon: Icons.payment,
            isRequired: true,
          ),
        ];
      
      case LicenseType.commercial:
        return [
          RequirementItem(
            id: 'class_b_license',
            title: 'Class B License',
            description: 'Must have valid Class B license for 2+ years',
            icon: Icons.credit_card,
            isRequired: true,
          ),
          RequirementItem(
            id: 'commercial_medical',
            title: 'Commercial Medical',
            description: 'Enhanced medical certificate for commercial drivers',
            icon: Icons.medical_services,
            isRequired: true,
          ),
          RequirementItem(
            id: 'experience_certificate',
            title: 'Experience Certificate',
            description: 'Proof of commercial driving experience',
            icon: Icons.work,
            isRequired: true,
          ),
          RequirementItem(
            id: 'commercial_theory',
            title: 'Commercial Theory Test',
            description: 'Pass commercial vehicle theory test',
            icon: Icons.quiz,
            isRequired: true,
          ),
          RequirementItem(
            id: 'commercial_practical',
            title: 'Commercial Practical Test',
            description: 'Pass commercial vehicle practical test',
            icon: Icons.local_shipping,
            isRequired: true,
          ),
          RequirementItem(
            id: 'background_check',
            title: 'Background Check',
            description: 'Clean driving record verification',
            icon: Icons.verified_user,
            isRequired: true,
          ),
          RequirementItem(
            id: 'training_certificate',
            title: 'Training Certificate',
            description: 'Commercial driver training completion',
            icon: Icons.school,
            isRequired: true,
          ),
          RequirementItem(
            id: 'commercial_fee',
            title: 'Commercial License Fee',
            description: 'Pay commercial license fee',
            icon: Icons.payment,
            isRequired: true,
          ),
        ];
    }
  }
}

/// Requirement item data class
class RequirementItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isRequired;

  const RequirementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isRequired = false,
  });
}
