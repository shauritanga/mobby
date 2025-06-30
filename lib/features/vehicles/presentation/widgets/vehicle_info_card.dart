import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/vehicle.dart';

/// Vehicle info card widget for displaying detailed vehicle information
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleInfoCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleInfoCard({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Basic Information Section
            _buildInfoSection(
              context,
              'Basic Information',
              [
                _InfoItem('Make', vehicle.make),
                _InfoItem('Model', vehicle.model),
                _InfoItem('Year', vehicle.year.toString()),
                _InfoItem('Color', vehicle.color),
                _InfoItem('Type', vehicle.type.displayName),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Engine & Performance Section
            _buildInfoSection(
              context,
              'Engine & Performance',
              [
                _InfoItem('Fuel Type', vehicle.fuelType.displayName),
                _InfoItem('Transmission', vehicle.transmission.displayName),
                if (vehicle.mileage != null)
                  _InfoItem('Mileage', '${_formatMileage(vehicle.mileage!)} km'),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Registration Information Section
            _buildInfoSection(
              context,
              'Registration Information',
              [
                _InfoItem('Plate Number', vehicle.plateNumber),
                _InfoItem('Engine Number', vehicle.engineNumber),
                _InfoItem('Chassis Number', vehicle.chassisNumber),
                if (vehicle.vin?.isNotEmpty == true)
                  _InfoItem('VIN', vehicle.vin!),
                if (vehicle.registrationNumber?.isNotEmpty == true)
                  _InfoItem('Registration Number', vehicle.registrationNumber!),
              ],
            ),
            
            if (vehicle.registrationDate != null ||
                vehicle.insuranceExpiry != null ||
                vehicle.inspectionExpiry != null) ...[
              SizedBox(height: 16.h),
              
              // Important Dates Section
              _buildInfoSection(
                context,
                'Important Dates',
                [
                  if (vehicle.registrationDate != null)
                    _InfoItem(
                      'Registration Date',
                      _formatDate(vehicle.registrationDate!),
                    ),
                  if (vehicle.insuranceExpiry != null)
                    _InfoItem(
                      'Insurance Expiry',
                      _formatDate(vehicle.insuranceExpiry!),
                      isExpiry: true,
                      isExpired: vehicle.isInsuranceExpired,
                    ),
                  if (vehicle.inspectionExpiry != null)
                    _InfoItem(
                      'Inspection Expiry',
                      _formatDate(vehicle.inspectionExpiry!),
                      isExpiry: true,
                      isExpired: vehicle.isInspectionExpired,
                    ),
                ],
              ),
            ],
            
            SizedBox(height: 16.h),
            
            // Vehicle Status Section
            _buildInfoSection(
              context,
              'Status Information',
              [
                _InfoItem('Status', vehicle.status.displayName),
                _InfoItem('Age', '${vehicle.age} years'),
                _InfoItem('Added', _formatDate(vehicle.createdAt)),
                if (vehicle.updatedAt != vehicle.createdAt)
                  _InfoItem('Last Updated', _formatDate(vehicle.updatedAt)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<_InfoItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              
              return Column(
                children: [
                  _buildInfoRow(context, item),
                  if (index < items.length - 1) ...[
                    SizedBox(height: 8.h),
                    Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, _InfoItem item) {
    Color? valueColor;
    Widget? statusIcon;

    if (item.isExpiry && item.isExpired != null) {
      if (item.isExpired!) {
        valueColor = Colors.red;
        statusIcon = Icon(
          Icons.error,
          size: 16.sp,
          color: Colors.red,
        );
      } else {
        valueColor = Colors.green;
        statusIcon = Icon(
          Icons.check_circle,
          size: 16.sp,
          color: Colors.green,
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        
        SizedBox(width: 8.w),
        
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              if (statusIcon != null) ...[
                SizedBox(width: 4.w),
                statusIcon,
              ],
            ],
          ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoItem {
  final String label;
  final String value;
  final bool isExpiry;
  final bool? isExpired;

  _InfoItem(
    this.label,
    this.value, {
    this.isExpiry = false,
    this.isExpired,
  });
}
