import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final String? customTitle;
  final String? customMessage;

  const ProductErrorWidget({
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
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60.sp,
                color: Theme.of(context).colorScheme.error.withOpacity(0.6),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Error title
            Text(
              customTitle ?? 'Something went wrong',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Error message
            Text(
              customMessage ?? _getErrorMessage(),
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).hintColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 24.h),
            
            // Error details (collapsible)
            _buildErrorDetails(context),
            
            SizedBox(height: 32.h),
            
            // Action buttons
            if (onRetry != null) ...[
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
            ],
            
            if (onGoBack != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onGoBack,
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
          ],
        ),
      ),
    );
  }

  String _getErrorMessage() {
    if (error.toLowerCase().contains('network') || 
        error.toLowerCase().contains('connection')) {
      return 'Please check your internet connection and try again.';
    } else if (error.toLowerCase().contains('timeout')) {
      return 'The request took too long. Please try again.';
    } else if (error.toLowerCase().contains('server')) {
      return 'Our servers are experiencing issues. Please try again later.';
    } else {
      return 'We encountered an unexpected error. Please try again.';
    }
  }

  Widget _buildErrorDetails(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text(
          'Error Details',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).hintColor,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.2),
              ),
            ),
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductNetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onGoOffline;

  const ProductNetworkErrorWidget({
    super.key,
    this.onRetry,
    this.onGoOffline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Network error illustration
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off,
                size: 60.sp,
                color: Colors.orange.withOpacity(0.6),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Title
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Message
            Text(
              'Please check your internet connection and try again, or browse cached products offline.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).hintColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Action buttons
            if (onRetry != null) ...[
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
            ],
            
            if (onGoOffline != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onGoOffline,
                  icon: Icon(Icons.offline_bolt, size: 20.sp),
                  label: Text(
                    'Browse Offline',
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
      ),
    );
  }
}

class ProductLoadingErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ProductLoadingErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 32.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            'Failed to load products',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          
          SizedBox(height: 4.h),
          
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (onRetry != null) ...[
            SizedBox(height: 12.h),
            
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 16.sp),
              label: Text(
                'Retry',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
