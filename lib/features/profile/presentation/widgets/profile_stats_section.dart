import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Profile stats section showing user statistics
/// Following specifications from FEATURES_DOCUMENTATION.md
class ProfileStatsSection extends StatelessWidget {
  final int addressCount;
  final int paymentMethodCount;
  final int vehicleCount;
  final double profileCompletion;

  const ProfileStatsSection({
    super.key,
    required this.addressCount,
    required this.paymentMethodCount,
    required this.vehicleCount,
    required this.profileCompletion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
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
        children: [
          // First row
          Row(
            children: [
              // Vehicles
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.directions_car,
                  label: 'Vehicles',
                  value: vehicleCount.toString(),
                  color: Colors.blue,
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 40.h,
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),

              // Addresses
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.location_on,
                  label: 'Addresses',
                  value: addressCount.toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Second row
          Row(
            children: [
              // Payment Methods
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.payment,
                  label: 'Payment',
                  value: paymentMethodCount.toString(),
                  color: Colors.orange,
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 40.h,
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),

              // Profile Completion
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.person,
                  label: 'Profile',
                  value: '${(profileCompletion * 100).round()}%',
                  color: _getCompletionColor(profileCompletion),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        // Icon
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 20.sp, color: color),
        ),

        SizedBox(height: 8.h),

        // Value
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),

        SizedBox(height: 2.h),

        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getCompletionColor(double completion) {
    final percentage = (completion * 100).round();
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
