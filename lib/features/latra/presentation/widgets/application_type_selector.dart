import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_application.dart';
import '../providers/latra_providers.dart';

/// Application Type Selector widget for LATRA registration
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class ApplicationTypeSelector extends ConsumerWidget {
  final LATRAApplicationType? selectedType;
  final Function(LATRAApplicationType) onTypeSelected;
  final String? error;

  const ApplicationTypeSelector({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
    this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationTypesAsync = ref.watch(availableApplicationTypesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Type',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Select the type of LATRA application you want to submit',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        
        applicationTypesAsync.when(
          data: (types) => _buildTypeSelector(types),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        ),

        if (error != null) ...[
          SizedBox(height: 8.h),
          Text(
            error!,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeSelector(List<LATRAApplicationType> types) {
    return Column(
      children: types.map((type) => _buildTypeCard(type)).toList(),
    );
  }

  Widget _buildTypeCard(LATRAApplicationType type) {
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
              // Type Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getTypeIcon(type),
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              
              // Type Information
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
                      _getTypeDescription(type),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    
                    // Fee Display
                    Consumer(
                      builder: (context, ref, child) {
                        final feeAsync = ref.watch(applicationFeeProvider(type));
                        return feeAsync.when(
                          data: (fee) => Text(
                            'Fee: ${_formatCurrency(fee)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.success,
                            ),
                          ),
                          loading: () => Text(
                            'Loading fee...',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          error: (error, stack) => Text(
                            'Fee unavailable',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.error,
                            ),
                          ),
                        );
                      },
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

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 32.w,
          ),
          SizedBox(height: 8.h),
          Text(
            'Failed to load application types',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            errorMessage,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(LATRAApplicationType type) {
    switch (type) {
      case LATRAApplicationType.vehicleRegistration:
        return Icons.app_registration;
      case LATRAApplicationType.licenseRenewal:
        return Icons.refresh;
      case LATRAApplicationType.ownershipTransfer:
        return Icons.swap_horiz;
      case LATRAApplicationType.duplicateRegistration:
        return Icons.content_copy;
      case LATRAApplicationType.temporaryPermit:
        return Icons.schedule;
    }
  }

  String _getTypeDescription(LATRAApplicationType type) {
    switch (type) {
      case LATRAApplicationType.vehicleRegistration:
        return 'Register a new vehicle with LATRA authorities';
      case LATRAApplicationType.licenseRenewal:
        return 'Renew your existing vehicle registration license';
      case LATRAApplicationType.ownershipTransfer:
        return 'Transfer vehicle ownership to another person';
      case LATRAApplicationType.duplicateRegistration:
        return 'Get a duplicate copy of your registration certificate';
      case LATRAApplicationType.temporaryPermit:
        return 'Apply for a temporary driving permit';
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'TZS ${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return 'TZS ${amount.toStringAsFixed(0)}';
    }
  }
}
