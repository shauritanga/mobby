import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_filter.dart';
import '../providers/product_providers_setup.dart';
import '../../../home/presentation/providers/home_providers.dart';

class QuickFilterChips extends ConsumerWidget {
  final ValueChanged<ProductFilter>? onFilterSelected;
  final bool showTitle;

  const QuickFilterChips({
    super.key,
    this.onFilterSelected,
    this.showTitle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickFilters = ref.watch(quickFiltersProvider);
    final currentFilter = ref.watch(filterStateProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Text(
              'Quick Filters',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            SizedBox(height: 8.h),
          ],

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // All products chip (clear filters)
                _buildFilterChip(
                  context,
                  label: 'All',
                  icon: Icons.apps,
                  isSelected: !_hasAnyQuickFilter(currentFilter),
                  onTap: () {
                    ref
                        .read(filterStateProvider.notifier)
                        .updateFilter(const ProductFilter());
                    onFilterSelected?.call(const ProductFilter());
                  },
                ),

                SizedBox(width: 8.w),

                // Quick filter chips
                ...quickFilters.entries.map((entry) {
                  final filterName = entry.key;
                  final filter = entry.value;
                  final isSelected = _isFilterSelected(
                    currentFilter,
                    filterName,
                  );

                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _buildFilterChip(
                      context,
                      label: _getFilterLabel(filterName),
                      icon: _getFilterIcon(filterName),
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          // Deselect current filter
                          ref
                              .read(filterStateProvider.notifier)
                              .updateFilter(const ProductFilter());
                          onFilterSelected?.call(const ProductFilter());
                        } else {
                          // Apply new filter
                          ref
                              .read(filterStateProvider.notifier)
                              .updateFilter(filter);
                          onFilterSelected?.call(filter);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(String filterName) {
    switch (filterName) {
      case 'featured':
        return 'Featured';
      case 'on_sale':
        return 'On Sale';
      case 'high_rated':
        return 'Top Rated';
      case 'in_stock':
        return 'In Stock';
      case 'price_low_high':
        return 'Price: Low';
      case 'newest':
        return 'New';
      case 'popular':
        return 'Popular';
      default:
        return filterName.replaceAll('_', ' ').toUpperCase();
    }
  }

  IconData _getFilterIcon(String filterName) {
    switch (filterName) {
      case 'featured':
        return Icons.star;
      case 'on_sale':
        return Icons.local_offer;
      case 'high_rated':
        return Icons.thumb_up;
      case 'in_stock':
        return Icons.inventory;
      case 'price_low_high':
        return Icons.arrow_upward;
      case 'newest':
        return Icons.new_releases;
      case 'popular':
        return Icons.trending_up;
      default:
        return Icons.filter_alt;
    }
  }

  bool _hasAnyQuickFilter(ProductFilter filter) {
    return filter.isFeatured == true ||
        filter.isOnSale == true ||
        filter.minRating != null ||
        filter.availability == ProductAvailability.inStock ||
        filter.sortBy != SortOption.relevance;
  }

  bool _isFilterSelected(ProductFilter currentFilter, String filterName) {
    switch (filterName) {
      case 'featured':
        return currentFilter.isFeatured == true;
      case 'on_sale':
        return currentFilter.isOnSale == true;
      case 'high_rated':
        return currentFilter.minRating == 4.0;
      case 'in_stock':
        return currentFilter.availability == ProductAvailability.inStock;
      case 'price_low_high':
        return currentFilter.sortBy == SortOption.priceAsc;
      case 'newest':
        return currentFilter.sortBy == SortOption.newest;
      case 'popular':
        return currentFilter.sortBy == SortOption.popular;
      default:
        return false;
    }
  }
}

class CategoryFilterChips extends ConsumerWidget {
  final ValueChanged<String>? onCategorySelected;
  final bool showTitle;

  const CategoryFilterChips({
    super.key,
    this.onCategorySelected,
    this.showTitle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final currentFilter = ref.watch(filterStateProvider);

    return categories.when(
      data: (categoryList) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              SizedBox(height: 8.h),
            ],

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // All categories chip
                  _buildCategoryChip(
                    context,
                    label: 'All',
                    icon: Icons.apps,
                    isSelected: currentFilter.categoryIds.isEmpty,
                    onTap: () {
                      ref
                          .read(filterStateProvider.notifier)
                          .updateCategoryIds([]);
                      onCategorySelected?.call('');
                    },
                  ),

                  SizedBox(width: 8.w),

                  // Category chips
                  ...categoryList.take(8).map((category) {
                    final isSelected = currentFilter.categoryIds.contains(
                      category.id,
                    );

                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: _buildCategoryChip(
                        context,
                        label: category.name,
                        icon: Icons.category,
                        isSelected: isSelected,
                        onTap: () {
                          if (isSelected) {
                            ref
                                .read(filterStateProvider.notifier)
                                .removeCategoryId(category.id);
                          } else {
                            ref
                                .read(filterStateProvider.notifier)
                                .addCategoryId(category.id);
                          }
                          onCategorySelected?.call(category.id);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => _buildLoadingChips(context),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
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
              icon,
              size: 16.sp,
              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingChips(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Container(
                width: 80.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PriceRangeChips extends ConsumerWidget {
  final ValueChanged<PriceRange>? onPriceRangeSelected;

  const PriceRangeChips({super.key, this.onPriceRangeSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(filterStateProvider);

    final priceRanges = [
      PriceRange(minPrice: 0, maxPrice: 50000), // Under 50K TZS
      PriceRange(minPrice: 50000, maxPrice: 100000), // 50K - 100K TZS
      PriceRange(minPrice: 100000, maxPrice: 250000), // 100K - 250K TZS
      PriceRange(minPrice: 250000, maxPrice: 500000), // 250K - 500K TZS
      PriceRange(minPrice: 500000, maxPrice: null), // Above 500K TZS
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // All prices chip
            _buildPriceChip(
              context,
              label: 'All Prices',
              isSelected:
                  currentFilter.priceRange.minPrice == null &&
                  currentFilter.priceRange.maxPrice == null,
              onTap: () {
                ref
                    .read(filterStateProvider.notifier)
                    .updatePriceRange(null, null);
                onPriceRangeSelected?.call(const PriceRange());
              },
            ),

            SizedBox(width: 8.w),

            // Price range chips
            ...priceRanges.map((range) {
              final isSelected = _isPriceRangeSelected(
                currentFilter.priceRange,
                range,
              );

              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _buildPriceChip(
                  context,
                  label: _getPriceRangeLabel(range),
                  isSelected: isSelected,
                  onTap: () {
                    ref
                        .read(filterStateProvider.notifier)
                        .updatePriceRange(range.minPrice, range.maxPrice);
                    onPriceRangeSelected?.call(range);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  String _getPriceRangeLabel(PriceRange range) {
    if (range.maxPrice == null) {
      return 'TZS ${_formatPrice(range.minPrice!)}+';
    } else {
      return 'TZS ${_formatPrice(range.minPrice!)} - ${_formatPrice(range.maxPrice!)}';
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toInt()}K';
    }
    return price.toInt().toString();
  }

  bool _isPriceRangeSelected(PriceRange currentRange, PriceRange targetRange) {
    return currentRange.minPrice == targetRange.minPrice &&
        currentRange.maxPrice == targetRange.maxPrice;
  }
}
