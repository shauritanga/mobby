import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_filter.dart';
import '../providers/product_providers_setup.dart';

class ProductSortBottomSheet extends ConsumerWidget {
  const ProductSortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(filterStateProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  'Sort By',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          Divider(height: 1.h),
          
          // Sort options
          ...SortOption.values.map((sortOption) {
            final isSelected = currentFilter.sortBy == sortOption;
            
            return ListTile(
              leading: Icon(
                _getSortIcon(sortOption),
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).hintColor,
              ),
              title: Text(
                _getSortLabel(sortOption),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              subtitle: Text(
                _getSortDescription(sortOption),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
              trailing: isSelected 
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () {
                ref.read(filterStateProvider.notifier).updateSortBy(sortOption);
                Navigator.of(context).pop();
              },
            );
          }),
          
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  IconData _getSortIcon(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.relevance:
        return Icons.search;
      case SortOption.priceAsc:
        return Icons.arrow_upward;
      case SortOption.priceDesc:
        return Icons.arrow_downward;
      case SortOption.ratingDesc:
        return Icons.star;
      case SortOption.newest:
        return Icons.new_releases;
      case SortOption.popular:
        return Icons.trending_up;
      case SortOption.nameAsc:
        return Icons.sort_by_alpha;
      case SortOption.nameDesc:
        return Icons.sort_by_alpha;
    }
  }

  String _getSortLabel(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceAsc:
        return 'Price: Low to High';
      case SortOption.priceDesc:
        return 'Price: High to Low';
      case SortOption.ratingDesc:
        return 'Highest Rated';
      case SortOption.newest:
        return 'Newest First';
      case SortOption.popular:
        return 'Most Popular';
      case SortOption.nameAsc:
        return 'Name: A to Z';
      case SortOption.nameDesc:
        return 'Name: Z to A';
    }
  }

  String _getSortDescription(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.relevance:
        return 'Best match for your search';
      case SortOption.priceAsc:
        return 'Show cheapest products first';
      case SortOption.priceDesc:
        return 'Show most expensive products first';
      case SortOption.ratingDesc:
        return 'Show best rated products first';
      case SortOption.newest:
        return 'Show recently added products first';
      case SortOption.popular:
        return 'Show most popular products first';
      case SortOption.nameAsc:
        return 'Sort alphabetically A to Z';
      case SortOption.nameDesc:
        return 'Sort alphabetically Z to A';
    }
  }
}

class QuickSortChips extends ConsumerWidget {
  const QuickSortChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(filterStateProvider);
    
    final quickSorts = [
      SortOption.relevance,
      SortOption.priceAsc,
      SortOption.priceDesc,
      SortOption.ratingDesc,
      SortOption.newest,
      SortOption.popular,
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: quickSorts.map((sortOption) {
          final isSelected = currentFilter.sortBy == sortOption;
          
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text(_getShortSortLabel(sortOption)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(filterStateProvider.notifier).updateSortBy(sortOption);
                }
              },
              avatar: Icon(
                _getSortIcon(sortOption),
                size: 16.sp,
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).hintColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getSortIcon(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.relevance:
        return Icons.search;
      case SortOption.priceAsc:
        return Icons.arrow_upward;
      case SortOption.priceDesc:
        return Icons.arrow_downward;
      case SortOption.ratingDesc:
        return Icons.star;
      case SortOption.newest:
        return Icons.new_releases;
      case SortOption.popular:
        return Icons.trending_up;
      case SortOption.nameAsc:
        return Icons.sort_by_alpha;
      case SortOption.nameDesc:
        return Icons.sort_by_alpha;
    }
  }

  String _getShortSortLabel(SortOption sortOption) {
    switch (sortOption) {
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
}
