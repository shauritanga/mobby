import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_search_result.dart';
import '../providers/product_providers_setup.dart';
import '../widgets/product_card.dart';
import '../widgets/product_list_app_bar.dart';
import '../widgets/product_filter_bottom_sheet.dart';
import '../widgets/product_sort_bottom_sheet.dart';
import '../widgets/product_loading_grid.dart';
import '../widgets/product_empty_state.dart';
import '../widgets/product_error_widget.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? brandId;
  final String? searchQuery;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.brandId,
    this.searchQuery,
  });

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize filters based on route parameters
      if (widget.categoryId != null) {
        ref.read(filterStateProvider.notifier).updateCategoryIds([
          widget.categoryId!,
        ]);
      }

      if (widget.brandId != null) {
        ref.read(filterStateProvider.notifier).updateBrandIds([
          widget.brandId!,
        ]);
      }

      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        ref.read(searchStateProvider.notifier).updateQuery(widget.searchQuery!);
      }
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreProducts();
      }
    });
  }

  void _loadMoreProducts() {
    final searchResults = ref.read(searchResultsProvider);

    searchResults.whenData((result) {
      if ((result as ProductSearchResult).hasNextPage) {
        ref.read(filterStateProvider.notifier).nextPage();
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductFilterBottomSheet(),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductSortBottomSheet(),
    );
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final currentFilter = ref.watch(filterStateProvider);
    final searchQuery = ref.watch(searchStateProvider);
    final hasActiveFilters = ref.hasActiveFilters();
    final activeFilterCount = ref.getActiveFilterCount();

    return Scaffold(
      appBar: ProductListAppBar(
        title: _getScreenTitle(),
        searchQuery: searchQuery,
        onSearchChanged: (query) =>
            ref.read(userProductAnalyticsProvider.notifier).trackSearch(query),
        onSearchClear: () => ref.clearSearch(),
        isGridView: _isGridView,
        onToggleView: _toggleViewMode,
      ),
      body: Column(
        children: [
          // Filter and Sort Bar
          _buildFilterSortBar(
            hasActiveFilters,
            activeFilterCount,
            currentFilter,
          ),

          // Product List/Grid
          Expanded(
            child: searchResults.when(
              data: (result) =>
                  _buildProductList(result as ProductSearchResult),
              loading: () => ProductLoadingGrid(isGridView: _isGridView),
              error: (error, stack) => ProductErrorWidget(
                error: error.toString(),
                onRetry: () => ref.invalidate(searchResultsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getScreenTitle() {
    if (widget.categoryId != null) {
      return 'Category Products';
    } else if (widget.brandId != null) {
      return 'Brand Products';
    } else if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      return 'Search Results';
    } else {
      return 'All Products';
    }
  }

  Widget _buildFilterSortBar(
    bool hasActiveFilters,
    int activeFilterCount,
    ProductFilter currentFilter,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Filter Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showFilterBottomSheet,
              icon: Icon(
                Icons.filter_list,
                size: 20.sp,
                color: hasActiveFilters ? Theme.of(context).primaryColor : null,
              ),
              label: Text(
                hasActiveFilters ? 'Filters ($activeFilterCount)' : 'Filters',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: hasActiveFilters
                      ? Theme.of(context).primaryColor
                      : null,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: hasActiveFilters
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Sort Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showSortBottomSheet,
              icon: Icon(Icons.sort, size: 20.sp),
              label: Text(
                _getSortLabel(currentFilter.sortBy),
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Clear Filters Button (if active)
          if (hasActiveFilters)
            IconButton(
              onPressed: () => ref.clearAllFilters(),
              icon: Icon(
                Icons.clear,
                size: 20.sp,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: 'Clear all filters',
            ),
        ],
      ),
    );
  }

  String _getSortLabel(SortOption sortBy) {
    switch (sortBy) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceAsc:
        return 'Price: Low to High';
      case SortOption.priceDesc:
        return 'Price: High to Low';
      case SortOption.ratingDesc:
        return 'Highest Rated';
      case SortOption.newest:
        return 'Newest';
      case SortOption.popular:
        return 'Most Popular';
      case SortOption.nameAsc:
        return 'Name: A-Z';
      case SortOption.nameDesc:
        return 'Name: Z-A';
    }
  }

  Widget _buildProductList(ProductSearchResult result) {
    if (result.products.isEmpty) {
      return ProductEmptyState(
        hasFilters: ref.hasActiveFilters(),
        onClearFilters: () => ref.clearAllFilters(),
        onBrowseAll: () {
          ref.clearAllFilters();
          context.go('/products');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(searchResultsProvider);
        await ref.read(searchResultsProvider.future);
      },
      child: _isGridView ? _buildGridView(result) : _buildListView(result),
    );
  }

  Widget _buildGridView(ProductSearchResult result) {
    return CustomScrollView(
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
                if (index < result.products.length) {
                  return ProductCard(
                    product: result.products[index],
                    isGridView: true,
                    onTap: () => _navigateToProduct(result.products[index]),
                    onWishlistTap: () =>
                        _toggleWishlist(result.products[index]),
                  );
                } else {
                  return _buildLoadMoreIndicator(result);
                }
              },
              childCount: result.products.length + (result.hasNextPage ? 1 : 0),
            ),
          ),
        ),

        // Pagination Info
        SliverToBoxAdapter(child: _buildPaginationInfo(result)),
      ],
    );
  }

  Widget _buildListView(ProductSearchResult result) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < result.products.length) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: ProductCard(
                      product: result.products[index],
                      isGridView: false,
                      onTap: () => _navigateToProduct(result.products[index]),
                      onWishlistTap: () =>
                          _toggleWishlist(result.products[index]),
                    ),
                  );
                } else {
                  return _buildLoadMoreIndicator(result);
                }
              },
              childCount: result.products.length + (result.hasNextPage ? 1 : 0),
            ),
          ),
        ),

        // Pagination Info
        SliverToBoxAdapter(child: _buildPaginationInfo(result)),
      ],
    );
  }

  Widget _buildLoadMoreIndicator(ProductSearchResult result) {
    if (!result.hasNextPage) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildPaginationInfo(ProductSearchResult result) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(
            'Showing ${result.products.length} of ${result.totalCount} products',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),

          if (result.totalPages > 1) ...[
            SizedBox(height: 8.h),
            Text(
              'Page ${result.currentPage} of ${result.totalPages}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToProduct(Product product) {
    // Track product view
    ref.viewProduct(product.id);

    // Navigate to product detail
    context.push('/products/${product.id}');
  }

  void _toggleWishlist(Product product) {
    ref.toggleWishlist(product.id);

    // Show snackbar feedback
    final isInWishlist = ref.isProductInWishlist(product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isInWishlist ? 'Added to wishlist' : 'Removed from wishlist',
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Wishlist',
          onPressed: () => context.push('/wishlist'),
        ),
      ),
    );
  }
}
