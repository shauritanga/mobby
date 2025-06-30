import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Order filter chips widget for filtering orders
/// Following specifications from FEATURES_DOCUMENTATION.md
class OrderFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const OrderFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'All Orders', 'icon': Icons.list_alt},
      {'key': 'recent', 'label': 'Recent', 'icon': Icons.schedule},
      {'key': 'high_value', 'label': 'High Value', 'icon': Icons.trending_up},
      {'key': 'automotive', 'label': 'Auto Parts', 'icon': Icons.build},
    ];

    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['key'];
          
          return FilterChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter['icon'] as IconData,
                  size: 16.sp,
                  color: isSelected 
                      ? Colors.white 
                      : Theme.of(context).primaryColor,
                ),
                SizedBox(width: 4.w),
                Text(
                  filter['label'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                        ? Colors.white 
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            onSelected: (selected) {
              if (selected) {
                onFilterChanged(filter['key'] as String);
              }
            },
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            side: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}
