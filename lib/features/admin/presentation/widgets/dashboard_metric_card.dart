import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/metric.dart';

class DashboardMetricCard extends StatelessWidget {
  final Metric metric;

  const DashboardMetricCard({super.key, required this.metric});

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
                Icon(
                  _getMetricIcon(),
                  size: 24.r,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    metric.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              _formatValue(metric.value),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (metric.change != null) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    metric.change! >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 16.r,
                    color: metric.change! >= 0 ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${metric.change! >= 0 ? '+' : ''}${metric.change!.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: metric.change! >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getMetricIcon() {
    switch (metric.type) {
      case MetricType.users:
        return Icons.people;
      case MetricType.orders:
        return Icons.shopping_cart;
      case MetricType.revenue:
        return Icons.attach_money;
      case MetricType.products:
        return Icons.inventory;
      case MetricType.categories:
        return Icons.category;
      case MetricType.insurance:
        return Icons.security;
      case MetricType.vehicles:
        return Icons.directions_car;
      case MetricType.performance:
        return Icons.speed;
      case MetricType.engagement:
        return Icons.favorite;
      case MetricType.conversion:
        return Icons.trending_up;
      case MetricType.retention:
        return Icons.repeat;
      case MetricType.satisfaction:
        return Icons.star;
      case MetricType.growth:
        return Icons.show_chart;
      case MetricType.traffic:
        return Icons.traffic;
      case MetricType.bounce:
        return Icons.exit_to_app;
      case MetricType.session:
        return Icons.access_time;
      case MetricType.pageViews:
        return Icons.visibility;
      case MetricType.downloads:
        return Icons.download;
      case MetricType.signups:
        return Icons.person_add;
      case MetricType.churn:
        return Icons.person_remove;
      case MetricType.ltv:
        return Icons.account_balance_wallet;
      case MetricType.cac:
        return Icons.campaign;
      case MetricType.mrr:
        return Icons.autorenew;
      case MetricType.arr:
        return Icons.calendar_today;
      case MetricType.nps:
        return Icons.thumb_up;
      case MetricType.csat:
        return Icons.sentiment_satisfied;
      case MetricType.ces:
        return Icons.support_agent;
      case MetricType.other:
        return Icons.analytics;
    }
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value == value.roundToDouble()) {
      return value.round().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }
}
