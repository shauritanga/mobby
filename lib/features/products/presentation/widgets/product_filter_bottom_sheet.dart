import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_filter.dart';
import '../providers/product_providers_setup.dart';

class ProductFilterBottomSheet extends ConsumerStatefulWidget {
  const ProductFilterBottomSheet({super.key});

  @override
  ConsumerState<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends ConsumerState<ProductFilterBottomSheet> {
  late ProductFilter _tempFilter;
  final RangeValues _priceRange = const RangeValues(0, 1000000); // TZS range

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(filterStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(brandsProvider);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          Divider(height: 1.h),
          
          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range Filter
                  _buildPriceRangeFilter(),
                  
                  SizedBox(height: 24.h),
                  
                  // Rating Filter
                  _buildRatingFilter(),
                  
                  SizedBox(height: 24.h),
                  
                  // Availability Filter
                  _buildAvailabilityFilter(),
                  
                  SizedBox(height: 24.h),
                  
                  // Brand Filter
                  brands.when(
                    data: (brandList) => _buildBrandFilter(brandList),
                    loading: () => _buildLoadingFilter('Brands'),
                    error: (error, stack) => _buildErrorFilter('Brands'),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Product Type Filters
                  _buildProductTypeFilters(),
                ],
              ),
            ),
          ),
          
          // Apply button
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range (TZS)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        RangeSlider(
          values: RangeValues(
            _tempFilter.priceRange.minPrice ?? 0,
            _tempFilter.priceRange.maxPrice ?? 1000000,
          ),
          min: 0,
          max: 1000000,
          divisions: 100,
          labels: RangeLabels(
            'TZS ${_formatPrice(_tempFilter.priceRange.minPrice ?? 0)}',
            'TZS ${_formatPrice(_tempFilter.priceRange.maxPrice ?? 1000000)}',
          ),
          onChanged: (values) {
            setState(() {
              _tempFilter = _tempFilter.copyWith(
                priceRange: PriceRange(
                  minPrice: values.start,
                  maxPrice: values.end,
                ),
              );
            });
          },
        ),
        
        Row(
          children: [
            Text(
              'TZS ${_formatPrice(_tempFilter.priceRange.minPrice ?? 0)}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor,
              ),
            ),
            const Spacer(),
            Text(
              'TZS ${_formatPrice(_tempFilter.priceRange.maxPrice ?? 1000000)}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        Wrap(
          spacing: 8.w,
          children: [1.0, 2.0, 3.0, 4.0, 4.5].map((rating) {
            final isSelected = _tempFilter.minRating == rating;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 14.sp,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 4.w),
                  Text('$rating+'),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempFilter = _tempFilter.copyWith(
                    minRating: selected ? rating : null,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        Wrap(
          spacing: 8.w,
          children: ProductAvailability.values.map((availability) {
            final isSelected = _tempFilter.availability == availability;
            return FilterChip(
              label: Text(_getAvailabilityLabel(availability)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempFilter = _tempFilter.copyWith(
                    availability: selected ? availability : ProductAvailability.all,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBrandFilter(List<dynamic> brands) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brands',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: brands.map((brand) {
            final isSelected = _tempFilter.brandIds.contains(brand.id);
            return FilterChip(
              label: Text(brand.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final currentBrands = List<String>.from(_tempFilter.brandIds);
                  if (selected) {
                    currentBrands.add(brand.id);
                  } else {
                    currentBrands.remove(brand.id);
                  }
                  _tempFilter = _tempFilter.copyWith(brandIds: currentBrands);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductTypeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Type',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        CheckboxListTile(
          title: const Text('Featured Products'),
          value: _tempFilter.isFeatured == true,
          onChanged: (value) {
            setState(() {
              _tempFilter = _tempFilter.copyWith(isFeatured: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        
        CheckboxListTile(
          title: const Text('On Sale'),
          value: _tempFilter.isOnSale == true,
          onChanged: (value) {
            setState(() {
              _tempFilter = _tempFilter.copyWith(isOnSale: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildLoadingFilter(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildErrorFilter(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Failed to load $title',
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  String _getAvailabilityLabel(ProductAvailability availability) {
    switch (availability) {
      case ProductAvailability.all:
        return 'All';
      case ProductAvailability.inStock:
        return 'In Stock';
      case ProductAvailability.outOfStock:
        return 'Out of Stock';
      case ProductAvailability.lowStock:
        return 'Low Stock';
    }
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _clearAllFilters() {
    setState(() {
      _tempFilter = const ProductFilter();
    });
  }

  void _applyFilters() {
    ref.read(filterStateProvider.notifier).updateFilter(_tempFilter);
    Navigator.of(context).pop();
  }
}
