import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductEmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onBrowseAll;
  final String? customMessage;
  final String? customSubtitle;

  const ProductEmptyState({
    super.key,
    required this.hasFilters,
    this.onClearFilters,
    this.onBrowseAll,
    this.customMessage,
    this.customSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.search_off : Icons.inventory_2_outlined,
                size: 60.sp,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Main message
            Text(
              customMessage ?? _getMainMessage(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Subtitle
            Text(
              customSubtitle ?? _getSubtitle(),
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).hintColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Action buttons
            if (hasFilters) ...[
              // Clear filters button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onClearFilters,
                  icon: Icon(Icons.clear_all, size: 20.sp),
                  label: Text(
                    'Clear All Filters',
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
              
              // Browse all button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onBrowseAll,
                  icon: Icon(Icons.explore, size: 20.sp),
                  label: Text(
                    'Browse All Products',
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
            ] else ...[
              // Browse all button (primary when no filters)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onBrowseAll,
                  icon: Icon(Icons.explore, size: 20.sp),
                  label: Text(
                    'Browse All Products',
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
            ],
            
            SizedBox(height: 24.h),
            
            // Suggestions
            _buildSuggestions(context),
          ],
        ),
      ),
    );
  }

  String _getMainMessage() {
    if (hasFilters) {
      return 'No products found';
    } else {
      return 'No products available';
    }
  }

  String _getSubtitle() {
    if (hasFilters) {
      return 'Try adjusting your search criteria or clearing some filters to see more results.';
    } else {
      return 'We\'re working on adding more products to our catalog. Check back soon!';
    }
  }

  Widget _buildSuggestions(BuildContext context) {
    final suggestions = hasFilters 
        ? [
            'Try different keywords',
            'Remove some filters',
            'Check spelling',
            'Use broader search terms',
          ]
        : [
            'Browse categories',
            'Check featured products',
            'View popular items',
            'Explore brands',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions:',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        ...suggestions.map((suggestion) => Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6.sp,
                color: Theme.of(context).hintColor,
              ),
              SizedBox(width: 8.w),
              Text(
                suggestion,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class ProductSearchEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;
  final VoidCallback? onBrowseCategories;

  const ProductSearchEmptyState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
    this.onBrowseCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Search illustration
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 60.sp,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Main message
            Text(
              'No results for "$searchQuery"',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Subtitle
            Text(
              'We couldn\'t find any products matching your search. Try different keywords or browse our categories.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).hintColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onClearSearch,
                icon: Icon(Icons.clear, size: 20.sp),
                label: Text(
                  'Clear Search',
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
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onBrowseCategories,
                icon: Icon(Icons.category, size: 20.sp),
                label: Text(
                  'Browse Categories',
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
            
            SizedBox(height: 24.h),
            
            // Search tips
            _buildSearchTips(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTips(BuildContext context) {
    final tips = [
      'Check your spelling',
      'Try more general terms',
      'Use different keywords',
      'Browse by category instead',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search tips:',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        ...tips.map((tip) => Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 14.sp,
                color: Theme.of(context).hintColor,
              ),
              SizedBox(width: 8.w),
              Text(
                tip,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
