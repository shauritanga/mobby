import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_filter.dart';
import '../providers/product_providers_setup.dart';
import 'quick_filter_chips.dart';

class SearchFiltersWidget extends ConsumerStatefulWidget {
  final VoidCallback? onFiltersChanged;

  const SearchFiltersWidget({
    super.key,
    this.onFiltersChanged,
  });

  @override
  ConsumerState<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends ConsumerState<SearchFiltersWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = ref.hasActiveFilters();
    final activeFilterCount = ref.getActiveFilterCount();
    
    return Container(
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
          // Filter header
          _buildFilterHeader(hasActiveFilters, activeFilterCount),
          
          // Quick filters (always visible)
          QuickFilterChips(
            onFilterSelected: (filter) {
              widget.onFiltersChanged?.call();
            },
          ),
          
          // Expandable advanced filters
          if (_isExpanded) _buildAdvancedFilters(),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(bool hasActiveFilters, int activeFilterCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // Filter status
          if (hasActiveFilters) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 14.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '$activeFilterCount active',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 8.w),
            
            // Clear all button
            TextButton(
              onPressed: () {
                ref.clearAllFilters();
                widget.onFiltersChanged?.call();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ] else ...[
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
          ],
          
          const Spacer(),
          
          // Expand/collapse button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 20.sp,
            ),
            label: Text(
              _isExpanded ? 'Less' : 'More',
              style: TextStyle(fontSize: 14.sp),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              minimumSize: Size.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 14.sp),
            tabs: const [
              Tab(text: 'Categories'),
              Tab(text: 'Price'),
              Tab(text: 'Rating'),
              Tab(text: 'Brands'),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Tab content
          SizedBox(
            height: 120.h,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryFilters(),
                _buildPriceFilters(),
                _buildRatingFilters(),
                _buildBrandFilters(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return CategoryFilterChips(
      onCategorySelected: (categoryId) {
        widget.onFiltersChanged?.call();
      },
    );
  }

  Widget _buildPriceFilters() {
    return Column(
      children: [
        PriceRangeChips(
          onPriceRangeSelected: (range) {
            widget.onFiltersChanged?.call();
          },
        ),
        
        SizedBox(height: 16.h),
        
        // Custom price range slider
        _buildCustomPriceRange(),
      ],
    );
  }

  Widget _buildCustomPriceRange() {
    final currentFilter = ref.watch(filterStateProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Range (TZS)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        RangeSlider(
          values: RangeValues(
            currentFilter.priceRange.minPrice ?? 0,
            currentFilter.priceRange.maxPrice ?? 1000000,
          ),
          min: 0,
          max: 1000000,
          divisions: 20,
          labels: RangeLabels(
            'TZS ${_formatPrice(currentFilter.priceRange.minPrice ?? 0)}',
            'TZS ${_formatPrice(currentFilter.priceRange.maxPrice ?? 1000000)}',
          ),
          onChanged: (values) {
            ref.read(filterStateProvider.notifier).updatePriceRange(
              values.start,
              values.end,
            );
          },
          onChangeEnd: (values) {
            widget.onFiltersChanged?.call();
          },
        ),
      ],
    );
  }

  Widget _buildRatingFilters() {
    final currentFilter = ref.watch(filterStateProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Wrap(
          spacing: 8.w,
          children: [1.0, 2.0, 3.0, 4.0, 4.5].map((rating) {
            final isSelected = currentFilter.minRating == rating;
            
            return GestureDetector(
              onTap: () {
                ref.read(filterStateProvider.notifier).updateMinRating(
                  isSelected ? null : rating,
                );
                widget.onFiltersChanged?.call();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 14.sp,
                      color: isSelected ? Colors.white : Colors.amber,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '$rating+',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isSelected 
                            ? Colors.white 
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBrandFilters() {
    final brands = ref.watch(brandsProvider);
    final currentFilter = ref.watch(filterStateProvider);
    
    return brands.when(
      data: (brandList) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Brands',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: brandList.take(10).map((brand) {
                  final isSelected = currentFilter.brandIds.contains(brand.id);
                  
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        ref.read(filterStateProvider.notifier).removeBrandId(brand.id);
                      } else {
                        ref.read(filterStateProvider.notifier).addBrandId(brand.id);
                      }
                      widget.onFiltersChanged?.call();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Text(
                        brand.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected 
                              ? Colors.white 
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Failed to load brands',
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toInt()}K';
    }
    return price.toInt().toString();
  }
}
