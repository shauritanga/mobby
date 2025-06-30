import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product.dart';

class ProductSpecificationsSection extends ConsumerWidget {
  final Product product;
  final VoidCallback? onCompatibilityCheck;

  const ProductSpecificationsSection({
    super.key,
    required this.product,
    this.onCompatibilityCheck,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          ...[
            _buildSectionTitle(context, 'Description'),
            SizedBox(height: 8.h),
            _buildDescription(context),
            SizedBox(height: 24.h),
          ],

          // Specifications
          if (product.specifications.isNotEmpty) ...[
            _buildSectionTitle(context, 'Specifications'),
            SizedBox(height: 8.h),
            _buildSpecifications(context),
            SizedBox(height: 24.h),
          ],

          // Compatibility
          _buildSectionTitle(context, 'Vehicle Compatibility'),
          SizedBox(height: 8.h),
          _buildCompatibilitySection(context),
          SizedBox(height: 24.h),

          // Features
          if (product.tags.isNotEmpty) ...[
            _buildSectionTitle(context, 'Features'),
            SizedBox(height: 8.h),
            _buildFeatures(context),
            SizedBox(height: 24.h),
          ],

          // Installation
          _buildSectionTitle(context, 'Installation & Maintenance'),
          SizedBox(height: 8.h),
          _buildInstallationInfo(context),
          SizedBox(height: 24.h),

          // Warranty
          _buildSectionTitle(context, 'Warranty & Support'),
          SizedBox(height: 8.h),
          _buildWarrantyInfo(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).textTheme.headlineSmall?.color,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        product.description,
        style: TextStyle(
          fontSize: 16.sp,
          height: 1.5,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildSpecifications(BuildContext context) {
    final specs = product.specifications;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: specs.entries.map((entry) {
          final isLast = entry == specs.entries.last;

          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.value.toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompatibilitySection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car,
                size: 24.sp,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                'Check Vehicle Compatibility',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Text(
            'Ensure this part fits your vehicle perfectly. Enter your vehicle details to check compatibility.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCompatibilityCheck,
              icon: Icon(Icons.search, size: 20.sp),
              label: Text(
                'Check Compatibility',
                style: TextStyle(fontSize: 16.sp),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Compatible vehicles (if available)
          if (product.compatibleVehicles.isNotEmpty) ...[
            Text(
              'Compatible with:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              children: product.compatibleVehicles.take(5).map((vehicle) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    vehicle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (product.compatibleVehicles.length > 5) ...[
              SizedBox(height: 4.h),
              Text(
                '+${product.compatibleVehicles.length - 5} more vehicles',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final features = product.tags;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 12.sp, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.4,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstallationInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            Icons.build,
            'Installation',
            'Professional installation recommended',
          ),

          SizedBox(height: 12.h),

          _buildInfoRow(
            context,
            Icons.schedule,
            'Installation Time',
            '1-2 hours',
          ),

          SizedBox(height: 12.h),

          _buildInfoRow(
            context,
            Icons.handyman,
            'Tools Required',
            'Basic hand tools',
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showInstallationGuide(context),
                  icon: Icon(Icons.description, size: 16.sp),
                  label: Text(
                    'Installation Guide',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _findInstaller(context),
                  icon: Icon(Icons.person_search, size: 16.sp),
                  label: Text(
                    'Find Installer',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantyInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            Icons.verified_user,
            'Warranty Period',
            product.warranty ?? '1 year manufacturer warranty',
          ),

          SizedBox(height: 12.h),

          _buildInfoRow(
            context,
            Icons.support_agent,
            'Support',
            '24/7 customer support available',
          ),

          SizedBox(height: 12.h),

          _buildInfoRow(
            context,
            Icons.assignment_return,
            'Return Policy',
            '30-day return policy',
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _contactSupport(context),
                  icon: Icon(Icons.support_agent, size: 16.sp),
                  label: Text(
                    'Contact Support',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewWarranty(context),
                  icon: Icon(Icons.description, size: 16.sp),
                  label: Text(
                    'Warranty Terms',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInstallationGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Installation Guide'),
        content: const Text(
          'Detailed installation instructions will be provided with the product. For complex installations, we recommend professional installation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Download or view installation guide
            },
            child: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  void _findInstaller(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find Professional Installer'),
        content: const Text(
          'We can help you find certified installers in your area. Would you like us to connect you with local professionals?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to installer finder
            },
            child: const Text('Find Installers'),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Support'),
              subtitle: const Text('+255 123 456 789'),
              onTap: () {
                Navigator.of(context).pop();
                // Make phone call
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@mobby.co.tz'),
              onTap: () {
                Navigator.of(context).pop();
                // Send email
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 24/7'),
              onTap: () {
                Navigator.of(context).pop();
                // Open live chat
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewWarranty(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warranty Terms'),
        content: const SingleChildScrollView(
          child: Text(
            'This product comes with a comprehensive manufacturer warranty. '
            'The warranty covers defects in materials and workmanship under normal use. '
            'Warranty does not cover damage due to misuse, accidents, or normal wear and tear.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Download warranty document
            },
            child: const Text('Download Terms'),
          ),
        ],
      ),
    );
  }
}
