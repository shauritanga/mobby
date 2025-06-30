import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Profile quick actions widget for common user actions
/// Following specifications from FEATURES_DOCUMENTATION.md
class ProfileQuickActions extends StatelessWidget {
  final VoidCallback? onAddAddress;
  final VoidCallback? onAddPaymentMethod;
  final VoidCallback? onViewOrders;
  final VoidCallback? onContactSupport;
  final VoidCallback? onAddVehicle;
  final VoidCallback? onViewVehicles;

  const ProfileQuickActions({
    super.key,
    this.onAddAddress,
    this.onAddPaymentMethod,
    this.onViewOrders,
    this.onContactSupport,
    this.onAddVehicle,
    this.onViewVehicles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),

          SizedBox(height: 16.h),

          // Action Buttons Grid
          Row(
            children: [
              // Add Vehicle
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  icon: Icons.directions_car,
                  label: 'Add Vehicle',
                  color: Colors.blue,
                  onTap: onAddVehicle,
                ),
              ),

              SizedBox(width: 12.w),

              // View Vehicles
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  icon: Icons.garage,
                  label: 'My Vehicles',
                  color: Colors.green,
                  onTap: onViewVehicles,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              // Add Address
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  icon: Icons.add_location,
                  label: 'Add Address',
                  color: Colors.orange,
                  onTap: onAddAddress,
                ),
              ),

              SizedBox(width: 12.w),

              // View Orders
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  icon: Icons.shopping_bag,
                  label: 'My Orders',
                  color: Colors.purple,
                  onTap: onViewOrders,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 20.sp, color: color),
              ),

              SizedBox(height: 8.h),

              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
