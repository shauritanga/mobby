import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_search_result.dart';
import '../widgets/product_card.dart';
import '../providers/product_providers_setup.dart';

class SearchResultsWidget extends ConsumerStatefulWidget {
  final ProductSearchResult searchResult;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onWishlistTap;
  final bool isGridView;

  const SearchResultsWidget({
    super.key,
    required this.searchResult,
    required this.onProductTap,
    required this.onWishlistTap,
    this.isGridView = true,
  });

  @override
  ConsumerState<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends ConsumerState<SearchResultsWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreResults();
      }
    });
  }

  void _loadMoreResults() {
    if (_isLoadingMore || !widget.searchResult.hasNextPage) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    ref.read(filterStateProvider.notifier).nextPage();
    
    // Reset loading state after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Results header
        _buildResultsHeader(),
        
        // Results grid/list
        Expanded(
          child: widget.isGridView 
              ? _buildGridView() 
              : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildResultsHeader() {
    final searchQuery = ref.watch(searchStateProvider);
    
    return Container(
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search query and results count
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    children: [
                      const TextSpan(text: 'Results for '),
                      TextSpan(
                        text: '"$searchQuery"',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // View toggle
              _buildViewToggle(),
            ],
          ),
          
          SizedBox(height: 4.h),
          
          // Results count and pagination info
          Text(
            '${widget.searchResult.totalCount} products found',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
          
          if (widget.searchResult.totalPages > 1) ...[
            SizedBox(height: 4.h),
            Text(
              'Page ${widget.searchResult.currentPage} of ${widget.searchResult.totalPages}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewToggleButton(
            icon: Icons.grid_view,
            isSelected: widget.isGridView,
            onTap: () => _toggleView(true),
          ),
          _buildViewToggleButton(
            icon: Icons.view_list,
            isSelected: !widget.isGridView,
            onTap: () => _toggleView(false),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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

  Widget _buildGridView() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(searchResultsProvider);
        await ref.read(searchResultsProvider.future);
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < widget.searchResult.products.length) {
                    final product = widget.searchResult.products[index];
                    return ProductCard(
                      product: product,
                      isGridView: true,
                      onTap: () => widget.onProductTap(product),
                      onWishlistTap: () => widget.onWishlistTap(product),
                    );
                  } else {
                    return _buildLoadMoreIndicator();
                  }
                },
                childCount: widget.searchResult.products.length + 
                    (widget.searchResult.hasNextPage ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(searchResultsProvider);
        await ref.read(searchResultsProvider.future);
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < widget.searchResult.products.length) {
                    final product = widget.searchResult.products[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: ProductCard(
                        product: product,
                        isGridView: false,
                        onTap: () => widget.onProductTap(product),
                        onWishlistTap: () => widget.onWishlistTap(product),
                      ),
                    );
                  } else {
                    return _buildLoadMoreIndicator();
                  }
                },
                childCount: widget.searchResult.products.length + 
                    (widget.searchResult.hasNextPage ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (!widget.searchResult.hasNextPage) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _loadMoreResults,
                child: const Text('Load More'),
              ),
      ),
    );
  }

  void _toggleView(bool isGridView) {
    // This would typically update a provider or call a parent callback
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isGridView ? 'Switched to grid view' : 'Switched to list view',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class SearchResultsHeader extends StatelessWidget {
  final String searchQuery;
  final int totalResults;
  final int currentPage;
  final int totalPages;
  final bool hasFilters;
  final VoidCallback? onClearFilters;

  const SearchResultsHeader({
    super.key,
    required this.searchQuery,
    required this.totalResults,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasFilters = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search query
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              children: [
                const TextSpan(text: 'Results for '),
                TextSpan(
                  text: '"$searchQuery"',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 4.h),
          
          // Results info
          Row(
            children: [
              Text(
                '$totalResults products found',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
              
              if (totalPages > 1) ...[
                Text(
                  ' • Page $currentPage of $totalPages',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
              
              if (hasFilters) ...[
                const Spacer(),
                TextButton(
                  onPressed: onClearFilters,
                  child: Text(
                    'Clear Filters',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class SearchResultsEmpty extends StatelessWidget {
  final String searchQuery;
  final bool hasFilters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onTryDifferentSearch;

  const SearchResultsEmpty({
    super.key,
    required this.searchQuery,
    this.hasFilters = false,
    this.onClearFilters,
    this.onTryDifferentSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty illustration
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
            
            // Title
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
              hasFilters
                  ? 'Try removing some filters or using different keywords'
                  : 'Try different keywords or check your spelling',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).hintColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Action buttons
            if (hasFilters && onClearFilters != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onClearFilters,
                  child: const Text('Clear Filters'),
                ),
              ),
              
              SizedBox(height: 12.h),
            ],
            
            if (onTryDifferentSearch != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onTryDifferentSearch,
                  child: const Text('Try Different Search'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
