import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_document.dart';

/// Document Filter Chips widget for filtering documents
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class DocumentFilterChips extends StatelessWidget {
  final LATRADocumentStatus? selectedStatus;
  final LATRADocumentType? selectedType;
  final bool showExpiredOnly;
  final bool showExpiringSoon;
  final Function(LATRADocumentStatus?) onStatusChanged;
  final Function(LATRADocumentType?) onTypeChanged;
  final Function(bool) onExpiredToggle;
  final Function(bool) onExpiringSoonToggle;

  const DocumentFilterChips({
    super.key,
    this.selectedStatus,
    this.selectedType,
    required this.showExpiredOnly,
    required this.showExpiringSoon,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onExpiredToggle,
    required this.onExpiringSoonToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status filters
          Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(null, 'All'),
                SizedBox(width: 8.w),
                ...LATRADocumentStatus.values.map((status) => 
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _buildStatusChip(status, status.displayName),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Type filters
          Text(
            'Filter by Type',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeChip(null, 'All Types'),
                SizedBox(width: 8.w),
                ...LATRADocumentType.values.map((type) => 
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _buildTypeChip(type, type.displayName),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Special filters
          Text(
            'Special Filters',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildToggleChip(
                'Expired Only',
                showExpiredOnly,
                onExpiredToggle,
                AppColors.error,
              ),
              SizedBox(width: 8.w),
              _buildToggleChip(
                'Expiring Soon',
                showExpiringSoon,
                onExpiringSoonToggle,
                AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(LATRADocumentStatus? status, String label) {
    final isSelected = selectedStatus == status;
    final color = status != null 
        ? AppColors.getDocumentStatusColor(status.name)
        : AppColors.primary;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : color,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        onStatusChanged(selected ? status : null);
      },
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  Widget _buildTypeChip(LATRADocumentType? type, String label) {
    final isSelected = selectedType == type;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.primary,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        onTypeChanged(selected ? type : null);
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  Widget _buildToggleChip(
    String label,
    bool isSelected,
    Function(bool) onToggle,
    Color color,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : color,
        ),
      ),
      selected: isSelected,
      onSelected: onToggle,
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }
}
