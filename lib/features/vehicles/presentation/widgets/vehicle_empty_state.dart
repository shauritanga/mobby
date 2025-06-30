import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Vehicle empty state widget for when no vehicles are found
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleEmptyState extends StatelessWidget {
  final VoidCallback? onAddVehicle;
  final VoidCallback? onRefresh;
  final String? title;
  final String? subtitle;
  final String? actionText;

  const VehicleEmptyState({
    super.key,
    this.onAddVehicle,
    this.onRefresh,
    this.title,
    this.subtitle,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car,
                size: 60.sp,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Title
            Text(
              title ?? 'No Vehicles Yet',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Subtitle
            Text(
              subtitle ?? 'Add your first vehicle to get started with vehicle management and tracking.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Action Buttons
            Column(
              children: [
                if (onAddVehicle != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAddVehicle,
                      icon: const Icon(Icons.add),
                      label: Text(actionText ?? 'Add Your First Vehicle'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                
                if (onAddVehicle != null && onRefresh != null)
                  SizedBox(height: 12.h),
                
                if (onRefresh != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Help Text
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Getting Started',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Text(
                    'With vehicle management, you can:\n'
                    '• Track vehicle documents and renewals\n'
                    '• Manage maintenance schedules\n'
                    '• Store vehicle photos and information\n'
                    '• Get alerts for important dates',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
