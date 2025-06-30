import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_search_result.dart';
import '../providers/product_providers_setup.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_suggestions_widget.dart';
import '../widgets/search_history_widget.dart';
import '../widgets/search_results_widget.dart';
import '../widgets/search_filters_widget.dart';
import '../widgets/quick_filter_chips.dart';
import '../widgets/product_card.dart';
import '../widgets/product_loading_grid.dart';
import '../widgets/product_empty_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;

  bool _showSuggestions = false;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize with query if provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _isSearchActive = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(searchStateProvider.notifier)
            .updateQuery(widget.initialQuery!);
      });
    }

    _setupSearchListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      final query = _searchController.text;
      setState(() {
        _showSuggestions = query.isNotEmpty && _searchFocusNode.hasFocus;
      });

      // Update search suggestions
      if (query.isNotEmpty) {
        ref.read(searchStateProvider.notifier).updateQuery(query);
      }
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions =
            _searchController.text.isNotEmpty && _searchFocusNode.hasFocus;
      });
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearchActive = true;
      _showSuggestions = false;
    });

    _searchFocusNode.unfocus();
    ref.read(searchStateProvider.notifier).updateQuery(query.trim());
    ref.read(searchHistoryStateProvider.notifier).addSearch(query.trim());
  }

  void _clearSearch() {
    setState(() {
      _isSearchActive = false;
      _showSuggestions = false;
    });

    _searchController.clear();
    ref.read(searchStateProvider.notifier).clearSearch();
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  void _selectHistoryItem(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchStateProvider);
    final hasActiveFilters = ref.hasActiveFilters();

    return Scaffold(
      appBar: AppBar(
        title: SearchBarWidget(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onSubmitted: _performSearch,
          onClear: _clearSearch,
          hintText: 'Search spare parts, accessories...',
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          // Quick filters (when search is active)
          if (_isSearchActive && !_showSuggestions) ...[
            QuickFilterChips(
              onFilterSelected: (filter) {
                ref.read(filterStateProvider.notifier).updateFilter(filter);
              },
            ),

            // Active filters indicator
            if (hasActiveFilters)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 16.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${ref.getActiveFilterCount()} filters active',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => ref.clearAllFilters(),
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],

          // Main content
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_showSuggestions) {
      return _buildSuggestionsView();
    } else if (_isSearchActive) {
      return _buildSearchResults();
    } else {
      return _buildSearchHome();
    }
  }

  Widget _buildSuggestionsView() {
    return SearchSuggestionsWidget(
      query: _searchController.text,
      onSuggestionSelected: _selectSuggestion,
    );
  }

  Widget _buildSearchResults() {
    final searchResults = ref.watch(searchResultsProvider);

    return searchResults.when(
      data: (ProductSearchResult result) {
        if (result.products.isEmpty) {
          return ProductEmptyState(
            hasFilters: ref.hasActiveFilters(),
            onClearFilters: () => ref.clearAllFilters(),
            onBrowseAll: () {
              _clearSearch();
              context.go('/products');
            },
            customMessage: 'No results found',
            customSubtitle: 'Try different keywords or adjust your filters',
          );
        }

        return SearchResultsWidget(
          searchResult: result,
          onProductTap: (product) => _navigateToProduct(product),
          onWishlistTap: (product) => _toggleWishlist(product),
        );
      },
      loading: () => const ProductLoadingGrid(isGridView: true),
      error: (error, stack) => Center(
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
              'Search failed',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => ref.invalidate(searchResultsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHome() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Recent'),
              Tab(text: 'Popular'),
              Tab(text: 'Categories'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Recent searches
                SearchHistoryWidget(
                  onHistoryItemSelected: _selectHistoryItem,
                  onClearHistory: () {
                    ref
                        .read(searchHistoryStateProvider.notifier)
                        .clearHistory();
                  },
                ),

                // Popular searches
                _buildPopularSearches(),

                // Categories
                _buildCategoriesGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSearches() {
    // Mock popular searches - in real app, this would come from analytics
    final popularSearches = [
      'brake pads',
      'engine oil',
      'air filter',
      'spark plugs',
      'battery',
      'tires',
      'headlights',
      'windshield wipers',
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: popularSearches.length,
      itemBuilder: (context, index) {
        final search = popularSearches[index];
        return ListTile(
          leading: Icon(
            Icons.trending_up,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(search),
          subtitle: Text('Popular search'),
          onTap: () => _selectSuggestion(search),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = ref.watch(categoriesProvider);

    return categories.when(
      data: (categoryList) => GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          final category = categoryList[index];
          return Card(
            child: InkWell(
              onTap: () {
                context.push('/products?categoryId=${category.id}');
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category,
                    size: 32.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${category.productCount} items',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Failed to load categories: $error')),
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

    // Show feedback
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
