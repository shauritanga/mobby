import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CartErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final String? customTitle;
  final String? customMessage;

  const CartErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onGoBack,
    this.customTitle,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error illustration
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50.sp,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Title
            Text(
              customTitle ?? 'Cart Error',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Error message
            Text(
              customMessage ?? 'Failed to load your cart. Please try again.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).hintColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Technical error details (collapsible)
            ExpansionTile(
              title: Text(
                'Error Details',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).hintColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 32.h),
            
            // Action buttons
            Column(
              children: [
                // Retry button
                if (onRetry != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: Icon(Icons.refresh, size: 20.sp),
                      label: Text(
                        'Try Again',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                
                SizedBox(height: 12.h),
                
                // Go back button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onGoBack ?? () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, size: 20.sp),
                    label: Text(
                      'Go Back',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                // Browse products button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/products'),
                    icon: Icon(Icons.shopping_bag, size: 20.sp),
                    label: Text(
                      'Browse Products',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Help section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 20.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Need Help?',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  Text(
                    'If the problem persists, please contact our support team for assistance.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.3,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _contactSupport(context),
                          icon: Icon(Icons.support_agent, size: 16.sp),
                          label: const Text('Contact Support'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 8.w),
                      
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reportBug(context),
                          icon: Icon(Icons.bug_report, size: 16.sp),
                          label: const Text('Report Bug'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('You can reach our support team via email at support@mobby.com or call +255 123 456 789'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _reportBug(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Help us improve by reporting this issue:'),
            const SizedBox(height: 8),
            Text(
              'Error: ${error.length > 100 ? '${error.substring(0, 100)}...' : error}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement bug reporting
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report sent. Thank you!'),
                ),
              );
            },
            child: const Text('Send Report'),
          ),
        ],
      ),
    );
  }
}

class CartNetworkError extends StatelessWidget {
  final VoidCallback? onRetry;

  const CartNetworkError({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CartErrorWidget(
      error: 'Network connection failed',
      customTitle: 'Connection Error',
      customMessage: 'Please check your internet connection and try again.',
      onRetry: onRetry,
    );
  }
}

class CartServerError extends StatelessWidget {
  final VoidCallback? onRetry;

  const CartServerError({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CartErrorWidget(
      error: 'Server temporarily unavailable',
      customTitle: 'Server Error',
      customMessage: 'Our servers are experiencing issues. Please try again in a few moments.',
      onRetry: onRetry,
    );
  }
}

class CartSyncError extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onClearCache;

  const CartSyncError({
    super.key,
    this.onRetry,
    this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sync_problem,
              size: 80.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              'Cart Sync Issue',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            Text(
              'Your cart couldn\'t be synchronized. Some items might be outdated.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Again'),
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onClearCache,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Cache'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
