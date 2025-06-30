import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WishlistFilterBar extends ConsumerWidget {
  final VoidCallback? onFilterChanged;
  final VoidCallback? onViewToggle;
  final bool isGridView;

  const WishlistFilterBar({
    super.key,
    this.onFilterChanged,
    this.onViewToggle,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Main filter bar
          Row(
            children: [
              // Sort button
              Expanded(
                child: _buildSortButton(context, ref),
              ),
              
              SizedBox(width: 12.w),
              
              // Filter button
              Expanded(
                child: _buildFilterButton(context, ref),
              ),
              
              SizedBox(width: 12.w),
              
              // View toggle
              _buildViewToggle(context),
            ],
          ),
          
          // Quick filter chips
          SizedBox(height: 8.h),
          _buildQuickFilterChips(context, ref),
        ],
      ),
    );
  }

  Widget _buildSortButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _showSortBottomSheet(context),
      icon: Icon(
        Icons.sort,
        size: 20.sp,
        color: Theme.of(context).hintColor,
      ),
      label: Text(
        'Sort',
        style: TextStyle(
          fontSize: 14.sp,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _showFilterBottomSheet(context),
      icon: Icon(
        Icons.filter_list,
        size: 20.sp,
        color: Theme.of(context).hintColor,
      ),
      label: Text(
        'Filter',
        style: TextStyle(
          fontSize: 14.sp,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewToggleButton(
            context,
            Icons.grid_view,
            true,
            isGridView,
          ),
          _buildViewToggleButton(
            context,
            Icons.view_list,
            false,
            !isGridView,
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(
    BuildContext context,
    IconData icon,
    bool isGrid,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        if ((isGrid && !isGridView) || (!isGrid && isGridView)) {
          onViewToggle?.call();
        }
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isSelected 
              ? Colors.white 
              : Theme.of(context).hintColor,
        ),
      ),
    );
  }

  Widget _buildQuickFilterChips(BuildContext context, WidgetRef ref) {
    final quickFilters = [
      WishlistQuickFilter('Available', Icons.check_circle, () {
        // Filter by available items
        onFilterChanged?.call();
      }, false),
      
      WishlistQuickFilter('On Sale', Icons.local_offer, () {
        // Filter by on sale items
        onFilterChanged?.call();
      }, false),
      
      WishlistQuickFilter('Price: Low to High', Icons.arrow_upward, () {
        // Sort by price ascending
        onFilterChanged?.call();
      }, false),
      
      WishlistQuickFilter('Recently Added', Icons.access_time, () {
        // Sort by recently added
        onFilterChanged?.call();
      }, false),
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: quickFilters.map((filter) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: filter.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: filter.isSelected 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: filter.isSelected 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter.icon,
                      size: 14.sp,
                      color: filter.isSelected 
                          ? Colors.white 
                          : Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      filter.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: filter.isSelected 
                            ? Colors.white 
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Sort Wishlist',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            ...['Recently Added', 'Name A-Z', 'Name Z-A', 'Price: Low to High', 'Price: High to Low', 'Brand']
                .map((option) => ListTile(
                  title: Text(option),
                  onTap: () {
                    Navigator.of(context).pop();
                    onFilterChanged?.call();
                  },
                )),
            
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Text(
                    'Filter Wishlist',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onFilterChanged?.call();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Availability filter
                    Text(
                      'Availability',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    CheckboxListTile(
                      title: const Text('In Stock'),
                      value: false,
                      onChanged: (value) {},
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    CheckboxListTile(
                      title: const Text('Out of Stock'),
                      value: false,
                      onChanged: (value) {},
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Price filter
                    Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    CheckboxListTile(
                      title: const Text('On Sale'),
                      value: false,
                      onChanged: (value) {},
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Brand filter
                    Text(
                      'Brand',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    ...['Toyota', 'Honda', 'Nissan', 'Mazda']
                        .map((brand) => CheckboxListTile(
                          title: Text(brand),
                          value: false,
                          onChanged: (value) {},
                          contentPadding: EdgeInsets.zero,
                        )),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  
                  SizedBox(width: 12.w),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onFilterChanged?.call();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WishlistQuickFilter {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  WishlistQuickFilter(this.label, this.icon, this.onTap, this.isSelected);
}
