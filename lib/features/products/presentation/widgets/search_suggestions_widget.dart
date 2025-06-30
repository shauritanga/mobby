import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/product_providers_setup.dart';

class SearchSuggestionsWidget extends ConsumerWidget {
  final String query;
  final ValueChanged<String> onSuggestionSelected;
  final int maxSuggestions;

  const SearchSuggestionsWidget({
    super.key,
    required this.query,
    required this.onSuggestionSelected,
    this.maxSuggestions = 8,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) {
      return const SizedBox.shrink();
    }

    final suggestions = ref.watch(searchSuggestionsForQueryProvider(query));
    
    return suggestions.when(
      data: (suggestionList) => _buildSuggestionsList(context, suggestionList),
      loading: () => _buildLoadingSuggestions(context),
      error: (error, stack) => _buildErrorSuggestions(context),
    );
  }

  Widget _buildSuggestionsList(BuildContext context, List<String> suggestions) {
    if (suggestions.isEmpty) {
      return _buildNoSuggestions(context);
    }

    final limitedSuggestions = suggestions.take(maxSuggestions).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: limitedSuggestions.length + 1, // +1 for "Search for" option
        separatorBuilder: (context, index) => Divider(
          height: 1.h,
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Search for" option
            return _buildSearchForOption(context);
          }
          
          final suggestion = limitedSuggestions[index - 1];
          return _buildSuggestionTile(context, suggestion);
        },
      ),
    );
  }

  Widget _buildSearchForOption(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.search,
          size: 20.sp,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          children: [
            const TextSpan(text: 'Search for '),
            TextSpan(
              text: '"$query"',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
      onTap: () => onSuggestionSelected(query),
      dense: true,
    );
  }

  Widget _buildSuggestionTile(BuildContext context, String suggestion) {
    // Highlight matching part
    final lowerQuery = query.toLowerCase();
    final lowerSuggestion = suggestion.toLowerCase();
    final matchIndex = lowerSuggestion.indexOf(lowerQuery);
    
    return ListTile(
      leading: Icon(
        Icons.history,
        size: 20.sp,
        color: Theme.of(context).hintColor,
      ),
      title: matchIndex >= 0
          ? _buildHighlightedText(context, suggestion, matchIndex, query.length)
          : Text(
              suggestion,
              style: TextStyle(fontSize: 16.sp),
            ),
      trailing: GestureDetector(
        onTap: () {
          // Fill search bar with suggestion without searching
          onSuggestionSelected(suggestion);
        },
        child: Icon(
          Icons.call_made,
          size: 16.sp,
          color: Theme.of(context).hintColor,
        ),
      ),
      onTap: () => onSuggestionSelected(suggestion),
      dense: true,
    );
  }

  Widget _buildHighlightedText(
    BuildContext context,
    String text,
    int matchIndex,
    int matchLength,
  ) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16.sp,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        children: [
          if (matchIndex > 0)
            TextSpan(text: text.substring(0, matchIndex)),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + matchLength),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          if (matchIndex + matchLength < text.length)
            TextSpan(text: text.substring(matchIndex + matchLength)),
        ],
      ),
    );
  }

  Widget _buildLoadingSuggestions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 5,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(
            Icons.search,
            size: 20.sp,
            color: Theme.of(context).hintColor.withOpacity(0.5),
          ),
          title: Container(
            height: 16.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          dense: true,
        ),
      ),
    );
  }

  Widget _buildErrorSuggestions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 32.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 8.h),
          Text(
            'Failed to load suggestions',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 8.h),
          _buildSearchForOption(context),
        ],
      ),
    );
  }

  Widget _buildNoSuggestions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildSearchForOption(context),
          SizedBox(height: 16.h),
          Text(
            'No suggestions found',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class PopularSearchSuggestions extends StatelessWidget {
  final ValueChanged<String> onSuggestionSelected;
  final List<String> popularSearches;

  const PopularSearchSuggestions({
    super.key,
    required this.onSuggestionSelected,
    required this.popularSearches,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: popularSearches.map((search) {
              return GestureDetector(
                onTap: () => onSuggestionSelected(search),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        search,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).primaryColor,
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
      ),
    );
  }
}

class CategorySuggestions extends StatelessWidget {
  final String query;
  final ValueChanged<String> onCategorySelected;
  final List<dynamic> categories;

  const CategorySuggestions({
    super.key,
    required this.query,
    required this.onCategorySelected,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    // Filter categories that match the query
    final matchingCategories = categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase());
    }).take(3).toList();

    if (matchingCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          SizedBox(height: 12.h),
          ...matchingCategories.map((category) {
            return ListTile(
              leading: Icon(
                Icons.category,
                size: 20.sp,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                category.name,
                style: TextStyle(fontSize: 16.sp),
              ),
              subtitle: category.productCount != null
                  ? Text('${category.productCount} products')
                  : null,
              onTap: () => onCategorySelected(category.name),
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }
}
