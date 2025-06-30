import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../screens/license_application_screen.dart';

/// License Type Selector widget for license applications
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LicenseTypeSelector extends StatelessWidget {
  final LicenseType? selectedType;
  final Function(LicenseType) onTypeSelected;

  const LicenseTypeSelector({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'License Type',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Select the type of driving license you want to apply for',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        
        Column(
          children: LicenseType.values.map((type) => _buildLicenseTypeCard(type)).toList(),
        ),
      ],
    );
  }

  Widget _buildLicenseTypeCard(LicenseType type) {
    final isSelected = selectedType == type;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => onTypeSelected(type),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
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
              // License Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getLicenseIcon(type),
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              
              // License Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      type.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    
                    // Requirements count
                    Row(
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 16.w,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${_getRequirementsCount(type)} requirements',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Selection Indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24.w,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getLicenseIcon(LicenseType type) {
    switch (type) {
      case LicenseType.learnerPermit:
        return Icons.school;
      case LicenseType.classA:
        return Icons.local_shipping;
      case LicenseType.classB:
        return Icons.directions_car;
      case LicenseType.classC:
        return Icons.directions_car;
      case LicenseType.motorcycle:
        return Icons.two_wheeler;
      case LicenseType.commercial:
        return Icons.business;
    }
  }

  int _getRequirementsCount(LicenseType type) {
    switch (type) {
      case LicenseType.learnerPermit:
        return 5; // Age, medical, theory test, etc.
      case LicenseType.classA:
      case LicenseType.classB:
      case LicenseType.classC:
        return 7; // Learner permit, practical test, etc.
      case LicenseType.motorcycle:
        return 6; // Medical, theory, practical test, etc.
      case LicenseType.commercial:
        return 8; // Experience, additional medical, etc.
    }
  }
}
