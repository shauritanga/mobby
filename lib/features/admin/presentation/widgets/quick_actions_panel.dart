import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            _buildActionButton(
              context,
              icon: Icons.add_business,
              label: 'Add Product',
              onTap: () => _showSnackBar(context, 'Add Product'),
            ),
            SizedBox(height: 8.h),
            _buildActionButton(
              context,
              icon: Icons.people_alt,
              label: 'Manage Users',
              onTap: () => _showSnackBar(context, 'Manage Users'),
            ),
            SizedBox(height: 8.h),
            _buildActionButton(
              context,
              icon: Icons.analytics,
              label: 'View Reports',
              onTap: () => _showSnackBar(context, 'View Reports'),
            ),
            SizedBox(height: 8.h),
            _buildActionButton(
              context,
              icon: Icons.settings,
              label: 'System Settings',
              onTap: () => _showSnackBar(context, 'System Settings'),
            ),
            SizedBox(height: 8.h),
            _buildActionButton(
              context,
              icon: Icons.backup,
              label: 'Backup Data',
              onTap: () => _showSnackBar(context, 'Backup Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.r,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.r,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action feature coming soon')),
    );
  }
}
