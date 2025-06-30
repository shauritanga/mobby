import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../screens/license_application_screen.dart';

/// License Fee Display widget for license applications
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LicenseFeeDisplay extends StatelessWidget {
  final LicenseType licenseType;

  const LicenseFeeDisplay({
    super.key,
    required this.licenseType,
  });

  @override
  Widget build(BuildContext context) {
    final fees = _getLicenseFees(licenseType);
    final totalFee = fees.values.reduce((a, b) => a + b);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: AppColors.primary,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'License Fees',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // License type
          _buildFeeRow('License Type', licenseType.displayName),
          SizedBox(height: 8.h),
          
          // Fee breakdown
          ...fees.entries.map((entry) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _buildFeeRow(entry.key, _formatCurrency(entry.value)),
          )),
          
          SizedBox(height: 16.h),
          Divider(color: AppColors.primary.withOpacity(0.3)),
          SizedBox(height: 16.h),
          
          // Total Fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _formatCurrency(totalFee),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Payment Info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Fees are payable at the time of appointment. Bring exact amount or card for payment.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Map<String, double> _getLicenseFees(LicenseType licenseType) {
    switch (licenseType) {
      case LicenseType.learnerPermit:
        return {
          'Application Fee': 15000.0,
          'Theory Test Fee': 10000.0,
          'Medical Examination': 25000.0,
          'Processing Fee': 5000.0,
        };
      
      case LicenseType.classA:
        return {
          'License Fee': 50000.0,
          'Practical Test Fee': 30000.0,
          'Medical Certificate': 25000.0,
          'Processing Fee': 10000.0,
          'Card Production': 15000.0,
        };
      
      case LicenseType.classB:
        return {
          'License Fee': 40000.0,
          'Practical Test Fee': 25000.0,
          'Medical Certificate': 25000.0,
          'Processing Fee': 8000.0,
          'Card Production': 15000.0,
        };
      
      case LicenseType.classC:
        return {
          'License Fee': 35000.0,
          'Practical Test Fee': 20000.0,
          'Medical Certificate': 25000.0,
          'Processing Fee': 7000.0,
          'Card Production': 15000.0,
        };
      
      case LicenseType.motorcycle:
        return {
          'License Fee': 30000.0,
          'Practical Test Fee': 20000.0,
          'Theory Test Fee': 10000.0,
          'Medical Certificate': 25000.0,
          'Processing Fee': 5000.0,
          'Card Production': 15000.0,
        };
      
      case LicenseType.commercial:
        return {
          'License Fee': 75000.0,
          'Practical Test Fee': 50000.0,
          'Enhanced Medical': 40000.0,
          'Background Check': 20000.0,
          'Training Verification': 15000.0,
          'Processing Fee': 15000.0,
          'Card Production': 20000.0,
        };
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'TZS ${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return 'TZS ${amount.toStringAsFixed(0)}';
    }
  }
}
