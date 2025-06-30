import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentActivitiesCard extends StatelessWidget {
  const RecentActivitiesCard({super.key});

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
            Row(
              children: [
                Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showSnackBar(context, 'View All Activities'),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ..._getMockActivities().map((activity) => _buildActivityItem(context, activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: activity['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              activity['icon'],
              size: 20.r,
              color: activity['color'],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  activity['description'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  activity['time'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockActivities() {
    return [
      {
        'icon': Icons.shopping_cart,
        'color': Colors.green,
        'title': 'New Order Received',
        'description': 'Order #12345 from John Doe',
        'time': '2 minutes ago',
      },
      {
        'icon': Icons.person_add,
        'color': Colors.blue,
        'title': 'New User Registration',
        'description': 'Jane Smith joined the platform',
        'time': '15 minutes ago',
      },
      {
        'icon': Icons.inventory,
        'color': Colors.orange,
        'title': 'Product Updated',
        'description': 'iPhone 15 Pro stock updated',
        'time': '1 hour ago',
      },
      {
        'icon': Icons.payment,
        'color': Colors.purple,
        'title': 'Payment Processed',
        'description': 'Payment of TZS 150,000 received',
        'time': '2 hours ago',
      },
      {
        'icon': Icons.support_agent,
        'color': Colors.red,
        'title': 'Support Ticket',
        'description': 'New ticket #789 created',
        'time': '3 hours ago',
      },
    ];
  }

  void _showSnackBar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action feature coming soon')),
    );
  }
}
