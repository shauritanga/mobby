import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/vehicle_providers.dart';
import '../../domain/entities/maintenance_record.dart';

/// Vehicle maintenance summary widget for displaying maintenance overview
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleMaintenanceSummary extends ConsumerWidget {
  final String vehicleId;

  const VehicleMaintenanceSummary({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceAsync = ref.watch(vehicleMaintenanceRecordsProvider(vehicleId));

    return maintenanceAsync.when(
      data: (records) => _buildMaintenanceList(context, records),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildMaintenanceList(BuildContext context, List<MaintenanceRecord> records) {
    if (records.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort records by date (newest first)
    final sortedRecords = List<MaintenanceRecord>.from(records)
      ..sort((a, b) => b.serviceDate.compareTo(a.serviceDate));

    // Calculate total cost
    final totalCost = records.fold<double>(0.0, (sum, record) => sum + record.cost);

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Summary Stats
        _buildSummaryStats(context, records, totalCost),
        
        SizedBox(height: 16.h),
        
        // Recent Maintenance Header
        Row(
          children: [
            Text(
              'Recent Maintenance',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/vehicles/$vehicleId/maintenance'),
              child: const Text('View All'),
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        // Maintenance Records (show latest 5)
        ...sortedRecords.take(5).map((record) => 
          _buildMaintenanceItem(context, record)
        ).toList(),
        
        SizedBox(height: 16.h),
        
        // Add Maintenance Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/vehicles/$vehicleId/maintenance/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Maintenance Record'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(BuildContext context, List<MaintenanceRecord> records, double totalCost) {
    final totalRecords = records.length;
    final thisYearRecords = records.where((r) => 
      r.serviceDate.year == DateTime.now().year
    ).length;
    final avgCost = totalRecords > 0 ? totalCost / totalRecords : 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  Icons.build,
                  totalRecords.toString(),
                  'Total Records',
                  Colors.orange,
                ),
              ),
              
              Container(
                width: 1,
                height: 40.h,
                color: Theme.of(context).dividerColor,
              ),
              
              Expanded(
                child: _buildStatItem(
                  context,
                  Icons.calendar_today,
                  thisYearRecords.toString(),
                  'This Year',
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  Icons.attach_money,
                  _formatCurrency(totalCost),
                  'Total Cost',
                  Colors.green,
                ),
              ),
              
              Container(
                width: 1,
                height: 40.h,
                color: Theme.of(context).dividerColor,
              ),
              
              Expanded(
                child: _buildStatItem(
                  context,
                  Icons.trending_up,
                  _formatCurrency(avgCost),
                  'Avg Cost',
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: color),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMaintenanceItem(BuildContext context, MaintenanceRecord record) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: _getMaintenanceTypeColor(record.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            _getMaintenanceTypeIcon(record.type),
            size: 20.sp,
            color: _getMaintenanceTypeColor(record.type),
          ),
        ),
        title: Text(
          record.title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.type.displayName,
              style: TextStyle(
                fontSize: 12.sp,
                color: _getMaintenanceTypeColor(record.type),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '${_formatDate(record.serviceDate)} • ${_formatCurrency(record.cost)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 12.sp,
          color: Theme.of(context).hintColor,
        ),
        onTap: () => context.push('/vehicles/$vehicleId/maintenance/${record.id}'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build,
            size: 64.sp,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Maintenance Records',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Keep track of your vehicle maintenance and service history',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => context.push('/vehicles/$vehicleId/maintenance/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add First Record'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load maintenance records',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getMaintenanceTypeColor(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange:
        return Colors.amber;
      case MaintenanceType.tireRotation:
        return Colors.brown;
      case MaintenanceType.brakeService:
        return Colors.red;
      case MaintenanceType.engineService:
        return Colors.blue;
      case MaintenanceType.transmission:
        return Colors.purple;
      case MaintenanceType.electrical:
        return Colors.orange;
      case MaintenanceType.bodywork:
        return Colors.green;
      case MaintenanceType.inspection:
        return Colors.teal;
      case MaintenanceType.other:
        return Colors.grey;
    }
  }

  IconData _getMaintenanceTypeIcon(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange:
        return Icons.opacity;
      case MaintenanceType.tireRotation:
        return Icons.tire_repair;
      case MaintenanceType.brakeService:
        return Icons.disc_full;
      case MaintenanceType.engineService:
        return Icons.settings;
      case MaintenanceType.transmission:
        return Icons.settings_applications;
      case MaintenanceType.electrical:
        return Icons.electrical_services;
      case MaintenanceType.bodywork:
        return Icons.car_repair;
      case MaintenanceType.inspection:
        return Icons.verified;
      case MaintenanceType.other:
        return Icons.build;
    }
  }

  String _formatCurrency(double amount) {
    if (amount == 0) return 'TZS 0';
    
    final formatter = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    
    return 'TZS $formatter';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
