import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_filter.dart';
import '../providers/product_providers_setup.dart';
import '../widgets/product_filter_bottom_sheet.dart';
import '../widgets/product_sort_bottom_sheet.dart';

class CategoryFilterBar extends ConsumerWidget {
  final String categoryId;
  final VoidCallback? onFilterChanged;

  const CategoryFilterBar({
    super.key,
    required this.categoryId,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(filterStateProvider);
    final hasActiveFilters = ref.hasActiveFilters();
    final activeFilterCount = ref.getActiveFilterCount();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Main filter bar
          Row(
            children: [
              // Filter button
              Expanded(
                child: _buildFilterButton(
                  context,
                  ref,
                  hasActiveFilters,
                  activeFilterCount,
                ),
              ),

              SizedBox(width: 12.w),

              // Sort button
              Expanded(
                child: _buildSortButton(context, ref, currentFilter.sortBy),
              ),

              SizedBox(width: 12.w),

              // View toggle
              _buildViewToggle(context, ref),
            ],
          ),

          // Active filters indicator
          if (hasActiveFilters) ...[
            SizedBox(height: 12.h),
            _buildActiveFiltersIndicator(context, ref, activeFilterCount),
          ],

          // Quick filter chips
          SizedBox(height: 8.h),
          _buildQuickFilterChips(context, ref),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    WidgetRef ref,
    bool hasActiveFilters,
    int activeFilterCount,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _showFilterBottomSheet(context),
      icon: Stack(
        children: [
          Icon(
            Icons.tune,
            size: 20.sp,
            color: hasActiveFilters
                ? Theme.of(context).primaryColor
                : Theme.of(context).hintColor,
          ),
          if (hasActiveFilters && activeFilterCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                child: Text(
                  activeFilterCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      label: Text(
        hasActiveFilters ? 'Filters ($activeFilterCount)' : 'Filters',
        style: TextStyle(
          fontSize: 14.sp,
          color: hasActiveFilters
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: hasActiveFilters
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
        ),
        backgroundColor: hasActiveFilters
            ? Theme.of(context).primaryColor.withOpacity(0.05)
            : null,
      ),
    );
  }

  Widget _buildSortButton(
    BuildContext context,
    WidgetRef ref,
    SortOption sortBy,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _showSortBottomSheet(context),
      icon: Icon(Icons.sort, size: 20.sp, color: Theme.of(context).hintColor),
      label: Text(
        _getSortLabel(sortBy),
        style: TextStyle(
          fontSize: 14.sp,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context, WidgetRef ref) {
    final isGridView = ref.watch(viewModeProvider) == ViewMode.grid;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewToggleButton(
            context,
            ref,
            Icons.grid_view,
            ViewMode.grid,
            isGridView,
          ),
          _buildViewToggleButton(
            context,
            ref,
            Icons.view_list,
            ViewMode.list,
            !isGridView,
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    ViewMode mode,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => ref.read(viewModeProvider.notifier).state = mode,
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
          color: isSelected ? Colors.white : Theme.of(context).hintColor,
        ),
      ),
    );
  }

  Widget _buildActiveFiltersIndicator(
    BuildContext context,
    WidgetRef ref,
    int activeFilterCount,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 8.w),
          Text(
            '$activeFilterCount filter${activeFilterCount > 1 ? 's' : ''} active',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              ref.clearAllFilters();
              onFilterChanged?.call();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChips(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(filterStateProvider);

    final quickFilters = [
      QuickFilter('Featured', Icons.star, () {
        ref
            .read(filterStateProvider.notifier)
            .updateFilter(
              currentFilter.copyWith(
                isFeatured: !(currentFilter.isFeatured ?? false),
              ),
            );
        onFilterChanged?.call();
      }, currentFilter.isFeatured == true),

      QuickFilter('On Sale', Icons.local_offer, () {
        ref
            .read(filterStateProvider.notifier)
            .updateFilter(
              currentFilter.copyWith(
                isOnSale: !(currentFilter.isOnSale ?? false),
              ),
            );
        onFilterChanged?.call();
      }, currentFilter.isOnSale == true),

      QuickFilter(
        'In Stock',
        Icons.inventory,
        () {
          final newAvailability =
              currentFilter.availability == ProductAvailability.inStock
              ? ProductAvailability.all
              : ProductAvailability.inStock;
          ref
              .read(filterStateProvider.notifier)
              .updateFilter(
                currentFilter.copyWith(availability: newAvailability),
              );
          onFilterChanged?.call();
        },
        currentFilter.availability == ProductAvailability.inStock,
      ),

      QuickFilter('Top Rated', Icons.thumb_up, () {
        final newRating = currentFilter.minRating == 4.0 ? null : 4.0;
        ref
            .read(filterStateProvider.notifier)
            .updateFilter(currentFilter.copyWith(minRating: newRating));
        onFilterChanged?.call();
      }, currentFilter.minRating == 4.0),
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

  String _getSortLabel(SortOption sortBy) {
    switch (sortBy) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceAsc:
        return 'Price ↑';
      case SortOption.priceDesc:
        return 'Price ↓';
      case SortOption.ratingDesc:
        return 'Rating';
      case SortOption.newest:
        return 'Newest';
      case SortOption.popular:
        return 'Popular';
      case SortOption.nameAsc:
        return 'A-Z';
      case SortOption.nameDesc:
        return 'Z-A';
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductFilterBottomSheet(),
    ).then((_) {
      onFilterChanged?.call();
    });
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductSortBottomSheet(),
    ).then((_) {
      onFilterChanged?.call();
    });
  }
}

class QuickFilter {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  QuickFilter(this.label, this.icon, this.onTap, this.isSelected);
}

// View mode provider
enum ViewMode { grid, list }

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);

class CategorySortChips extends ConsumerWidget {
  final VoidCallback? onSortChanged;

  const CategorySortChips({super.key, this.onSortChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(filterStateProvider);

    final sortOptions = [
      SortChip('Popular', SortOption.popular),
      SortChip('Price ↑', SortOption.priceAsc),
      SortChip('Price ↓', SortOption.priceDesc),
      SortChip('Rating', SortOption.ratingDesc),
      SortChip('Newest', SortOption.newest),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sortOptions.map((sortChip) {
            final isSelected = currentFilter.sortBy == sortChip.sortOption;

            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(filterStateProvider.notifier)
                      .updateSortBy(sortChip.sortOption);
                  onSortChanged?.call();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
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
                    sortChip.label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SortChip {
  final String label;
  final SortOption sortOption;

  SortChip(this.label, this.sortOption);
}
