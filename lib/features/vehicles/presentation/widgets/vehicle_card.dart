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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(
              context,
            ).colorScheme.surfaceContainer.withValues(alpha: 0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Header
                Row(
                  children: [
                    // Vehicle Image with enhanced styling
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            Theme.of(context).colorScheme.secondaryContainer
                                .withValues(alpha: 0.2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
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

                    SizedBox(width: 16.w),

                    // Vehicle Info with enhanced styling
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
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              _buildStatusChip(context),
                            ],
                          ),

                          SizedBox(height: 6.h),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              vehicle.plateNumber,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          SizedBox(height: 6.h),

                          Row(
                            children: [
                              _buildInfoChip(
                                context,
                                Icons.palette_outlined,
                                vehicle.color,
                              ),
                              SizedBox(width: 6.w),
                              _buildInfoChip(
                                context,
                                Icons.local_gas_station_outlined,
                                vehicle.fuelType.displayName,
                              ),
                            ],
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

                SizedBox(height: 16.h),

                // Vehicle Details with enhanced styling
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildDetailItem(
                        context,
                        Icons.calendar_today_outlined,
                        'Year',
                        vehicle.year.toString(),
                      ),
                      Container(
                        width: 1,
                        height: 32.h,
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                      _buildDetailItem(
                        context,
                        Icons.speed_outlined,
                        'Mileage',
                        vehicle.mileage != null
                            ? '${_formatMileage(vehicle.mileage!)} km'
                            : 'N/A',
                      ),
                      Container(
                        width: 1,
                        height: 32.h,
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                      _buildDetailItem(
                        context,
                        Icons.category_outlined,
                        'Type',
                        vehicle.type.displayName,
                      ),
                    ],
                  ),
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

                SizedBox(height: 16.h),

                // Action Buttons with enhanced styling
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: OutlinedButton.icon(
                          onPressed: onViewDocuments,
                          icon: Icon(Icons.description_outlined, size: 16.sp),
                          label: const Text('Docs'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: OutlinedButton.icon(
                          onPressed: onViewMaintenance,
                          icon: Icon(Icons.build_outlined, size: 16.sp),
                          label: const Text('Service'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'View',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 3.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.3),
            Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Icon(
        Icons.directions_car,
        size: 36.sp,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (vehicle.status) {
      case VehicleStatus.active:
        backgroundColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green.shade700;
        text = 'Active';
        icon = Icons.check_circle;
        break;
      case VehicleStatus.inactive:
        backgroundColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey.shade700;
        text = 'Inactive';
        icon = Icons.pause_circle;
        break;
      case VehicleStatus.sold:
        backgroundColor = Colors.blue.withValues(alpha: 0.15);
        textColor = Colors.blue.shade700;
        text = 'Sold';
        icon = Icons.sell;
        break;
      case VehicleStatus.scrapped:
        backgroundColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red.shade700;
        text = 'Scrapped';
        icon = Icons.delete_forever;
        break;
      case VehicleStatus.stolen:
        backgroundColor = Colors.purple.withValues(alpha: 0.15);
        textColor = Colors.purple.shade700;
        text = 'Stolen';
        icon = Icons.warning;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
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
