import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/vehicle.dart';

/// Vehicle card widget for displaying vehicle information
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDocuments;
  final VoidCallback? onViewMaintenance;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewDocuments,
    this.onViewMaintenance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1, // Reduced for Material 3 style
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Header
              Row(
                children: [
                  // Vehicle Image
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: vehicle.primaryImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: vehicle.primaryImageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  _buildPlaceholderImage(context),
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholderImage(context),
                            )
                          : _buildPlaceholderImage(context),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Vehicle Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                vehicle.displayName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.color,
                                ),
                              ),
                            ),
                            _buildStatusChip(context),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          vehicle.plateNumber,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),

                        SizedBox(height: 2.h),

                        Text(
                          '${vehicle.color} • ${vehicle.fuelType.displayName} • ${vehicle.transmission.displayName}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions Menu
                  PopupMenuButton<String>(
                    onSelected: _handleAction,
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      if (onViewDocuments != null)
                        const PopupMenuItem(
                          value: 'documents',
                          child: ListTile(
                            leading: Icon(Icons.description),
                            title: Text('Documents'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      if (onViewMaintenance != null)
                        const PopupMenuItem(
                          value: 'maintenance',
                          child: ListTile(
                            leading: Icon(Icons.build),
                            title: Text('Maintenance'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Vehicle Details
              Row(
                children: [
                  _buildDetailItem(
                    context,
                    Icons.calendar_today,
                    'Year',
                    vehicle.year.toString(),
                  ),
                  SizedBox(width: 16.w),
                  _buildDetailItem(
                    context,
                    Icons.speed,
                    'Mileage',
                    vehicle.mileage != null
                        ? '${_formatMileage(vehicle.mileage!)} km'
                        : 'N/A',
                  ),
                  SizedBox(width: 16.w),
                  _buildDetailItem(
                    context,
                    Icons.category,
                    'Type',
                    vehicle.type.displayName,
                  ),
                ],
              ),

              // Alert Indicators
              if (vehicle.hasExpiredDocuments) ...[
                SizedBox(height: 12.h),
                _buildAlertIndicator(
                  context,
                  Icons.warning,
                  'Has expired documents',
                  Colors.red,
                ),
              ],

              // Registration and Insurance Status
              if (vehicle.registrationDate != null ||
                  vehicle.insuranceExpiry != null) ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    if (vehicle.registrationDate != null)
                      Expanded(
                        child: _buildExpiryInfo(
                          context,
                          'Registration',
                          vehicle.isRegistrationExpired,
                          vehicle.registrationDate!,
                        ),
                      ),
                    if (vehicle.registrationDate != null &&
                        vehicle.insuranceExpiry != null)
                      SizedBox(width: 12.w),
                    if (vehicle.insuranceExpiry != null)
                      Expanded(
                        child: _buildExpiryInfo(
                          context,
                          'Insurance',
                          vehicle.isInsuranceExpired,
                          vehicle.insuranceExpiry!,
                        ),
                      ),
                  ],
                ),
              ],

              SizedBox(height: 12.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewDocuments,
                      icon: const Icon(Icons.description, size: 16),
                      label: const Text('Documents'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewMaintenance,
                      icon: const Icon(Icons.build, size: 16),
                      label: const Text('Maintenance'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    child: const Text('View'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.directions_car,
        size: 30.sp,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (vehicle.status) {
      case VehicleStatus.active:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        text = 'Active';
        break;
      case VehicleStatus.inactive:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        text = 'Inactive';
        break;
      case VehicleStatus.sold:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        text = 'Sold';
        break;
      case VehicleStatus.scrapped:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        text = 'Scrapped';
        break;
      case VehicleStatus.stolen:
        backgroundColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple;
        text = 'Stolen';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: Theme.of(context).hintColor),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertIndicator(
    BuildContext context,
    IconData icon,
    String message,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryInfo(
    BuildContext context,
    String label,
    bool isExpired,
    DateTime date,
  ) {
    final color = isExpired ? Colors.red : Colors.green;
    final status = isExpired ? 'Expired' : 'Valid';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Icon(
              isExpired ? Icons.error : Icons.check_circle,
              size: 12.sp,
              color: color,
            ),
            SizedBox(width: 4.w),
            Text(
              status,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatMileage(int mileage) {
    if (mileage >= 1000000) {
      return '${(mileage / 1000000).toStringAsFixed(1)}M';
    } else if (mileage >= 1000) {
      return '${(mileage / 1000).toStringAsFixed(1)}K';
    } else {
      return mileage.toString();
    }
  }

  void _handleAction(String action) {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'documents':
        onViewDocuments?.call();
        break;
      case 'maintenance':
        onViewMaintenance?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}
