import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/product_providers_setup.dart';

class SearchHistoryWidget extends ConsumerWidget {
  final ValueChanged<String> onHistoryItemSelected;
  final VoidCallback onClearHistory;
  final int maxItems;

  const SearchHistoryWidget({
    super.key,
    required this.onHistoryItemSelected,
    required this.onClearHistory,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchHistory = ref.watch(searchHistoryStateProvider);

    return _buildHistoryList(context, ref, searchHistory);
  }

  Widget _buildHistoryList(
    BuildContext context,
    WidgetRef ref,
    List<String> history,
  ) {
    if (history.isEmpty) {
      return _buildEmptyHistory(context);
    }

    final limitedHistory = history.take(maxItems).toList();

    return Column(
      children: [
        // Header with clear button
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showClearHistoryDialog(context, ref),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),

        // History list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: limitedHistory.length,
            separatorBuilder: (context, index) => Divider(
              height: 1.h,
              color: Theme.of(context).dividerColor.withOpacity(0.5),
            ),
            itemBuilder: (context, index) {
              final query = limitedHistory[index];
              return _buildHistoryTile(context, ref, query, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTile(
    BuildContext context,
    WidgetRef ref,
    String query,
    int index,
  ) {
    return ListTile(
      leading: Icon(
        Icons.history,
        size: 20.sp,
        color: Theme.of(context).hintColor,
      ),
      title: Text(
        query,
        style: TextStyle(
          fontSize: 16.sp,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        _getTimeAgo(index), // Mock time - in real app, store timestamps
        style: TextStyle(fontSize: 12.sp, color: Theme.of(context).hintColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fill search bar button
          GestureDetector(
            onTap: () => onHistoryItemSelected(query),
            child: Container(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.call_made,
                size: 16.sp,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),

          // Remove from history button
          GestureDetector(
            onTap: () => _removeHistoryItem(ref, query),
            child: Container(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.close,
                size: 16.sp,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
      onTap: () => onHistoryItemSelected(query),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildEmptyHistory(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 40.sp,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              'No recent searches',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Your search history will appear here',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingHistory(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 120.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              const Spacer(),
              Container(
                width: 60.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Loading items
          ...List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).hintColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 80.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).hintColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorHistory(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Theme.of(context).colorScheme.error,
            ),

            SizedBox(height: 16.h),

            Text(
              'Failed to load search history',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History'),
        content: const Text(
          'Are you sure you want to clear all your search history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(searchHistoryStateProvider.notifier).clearHistory();
              onClearHistory();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _removeHistoryItem(WidgetRef ref, String query) {
    ref.read(searchHistoryStateProvider.notifier).removeSearch(query);
  }

  String _getTimeAgo(int index) {
    // Mock time calculation - in real app, use actual timestamps
    final hours = [1, 3, 5, 8, 12, 24, 48, 72, 96, 120];
    if (index < hours.length) {
      final hour = hours[index];
      if (hour < 24) {
        return '${hour}h ago';
      } else {
        final days = (hour / 24).floor();
        return '${days}d ago';
      }
    }
    return '1w ago';
  }
}

class SearchHistoryChips extends ConsumerWidget {
  final ValueChanged<String> onHistoryItemSelected;
  final int maxItems;

  const SearchHistoryChips({
    super.key,
    required this.onHistoryItemSelected,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchHistory = ref.watch(searchHistoryStateProvider);

    if (searchHistory.isEmpty) return const SizedBox.shrink();

    final limitedHistory = searchHistory.take(maxItems).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).hintColor,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: limitedHistory.map((query) {
              return GestureDetector(
                onTap: () => onHistoryItemSelected(query),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 14.sp,
                        color: Theme.of(context).hintColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        query,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
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
