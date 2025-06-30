import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/vehicle_operations_providers.dart';

/// Vehicle filter bar widget for filtering vehicles
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleFilterBar extends ConsumerWidget {
  const VehicleFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(vehicleFilterStateProvider);

    if (!filterState.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 16.sp,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 4.w),
              Text(
                'Active Filters',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(vehicleFilterStateProvider.notifier).clearFilters();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              if (filterState.selectedType != null)
                _buildFilterChip(
                  context,
                  ref,
                  'Type: ${filterState.selectedType!.displayName}',
                  () => ref
                      .read(vehicleFilterStateProvider.notifier)
                      .setVehicleType(null),
                ),

              if (filterState.selectedStatus != null)
                _buildFilterChip(
                  context,
                  ref,
                  'Status: ${filterState.selectedStatus!.displayName}',
                  () => ref
                      .read(vehicleFilterStateProvider.notifier)
                      .setVehicleStatus(null),
                ),

              if (filterState.selectedFuelType != null)
                _buildFilterChip(
                  context,
                  ref,
                  'Fuel: ${filterState.selectedFuelType!.displayName}',
                  () => ref
                      .read(vehicleFilterStateProvider.notifier)
                      .setFuelType(null),
                ),

              if (filterState.searchQuery?.isNotEmpty == true)
                _buildFilterChip(
                  context,
                  ref,
                  'Search: "${filterState.searchQuery}"',
                  () => ref
                      .read(vehicleFilterStateProvider.notifier)
                      .setSearchQuery(null),
                ),

              if (filterState.showExpiredDocuments)
                _buildFilterChip(
                  context,
                  ref,
                  'Expired Documents',
                  () => ref
                      .read(vehicleFilterStateProvider.notifier)
                      .setShowExpiredDocuments(false),
                ),

              if (filterState.showOverdueMaintenance)
                _buildFilterChip(
                  context,
                  ref,
                  'Overdue Maintenance',
                  () => ref
                      .read(vehicleFilterStateProvider.notifier)
                      .setShowOverdueMaintenance(false),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    VoidCallback onRemove,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14.sp,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
