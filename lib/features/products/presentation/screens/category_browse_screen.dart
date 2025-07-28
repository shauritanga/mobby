import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers_setup.dart';
import '../widgets/category_header_section.dart';
import '../widgets/subcategory_chips.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_loading_grid.dart';
import '../widgets/product_empty_state.dart';
import '../widgets/product_error_widget.dart';
import '../../../home/domain/entities/category.dart' as home;

class CategoryBrowseScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String? subcategoryId;

  const CategoryBrowseScreen({
    super.key,
    required this.categoryId,
    this.subcategoryId,
  });

  @override
  ConsumerState<CategoryBrowseScreen> createState() =>
      _CategoryBrowseScreenState();
}

class _CategoryBrowseScreenState extends ConsumerState<CategoryBrowseScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  bool _isGridView = true;
  bool _showFloatingActionButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupScrollListener();
    _initializeFilters();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final showFAB = _scrollController.offset > 200;
      if (showFAB != _showFloatingActionButton) {
        setState(() {
          _showFloatingActionButton = showFAB;
        });
      }
    });
  }

  void _initializeFilters() {
    // Initialize category filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(filterStateProvider.notifier).updateCategoryIds([
        widget.categoryId,
      ]);

      // Initialize subcategory if provided
      if (widget.subcategoryId != null) {
        // Mock implementation - would update filter state
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(categoryByIdProvider(widget.categoryId));

    return Scaffold(
      body: categoryAsync.when(
        data: (category) => category != null
            ? _buildCategoryContent(_convertToProductsCategory(category))
            : _buildCategoryNotFound(),
        loading: () => _buildLoadingScreen(),
        error: (error, stack) => _buildErrorScreen(error),
      ),
      floatingActionButton: _showFloatingActionButton
          ? _buildFloatingActionButton()
          : null,
    );
  }

  /// Converts a home Category to a products Category
  Category _convertToProductsCategory(home.Category homeCategory) {
    return Category(
      id: homeCategory.id,
      name: homeCategory.name,
      description: homeCategory.description,
      imageUrl: homeCategory.imageUrl,
      iconUrl: null, // Home category uses iconName, products uses iconUrl
      productCount: homeCategory.productCount,
      subcategories: null, // Will be populated separately if needed
      parentId: homeCategory.parentId,
      isActive: homeCategory.isActive,
      createdAt: homeCategory.createdAt,
      updatedAt: homeCategory.updatedAt,
    );
  }

  Widget _buildCategoryContent(Category category) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Category app bar
        SliverAppBar(
          expandedHeight: 200.h,
          pinned: true,
          backgroundColor: Theme.of(context).primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            background: CategoryHeaderSection(
              category: category,
              onSearchTap: () => _navigateToSearch(category.name),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list : Icons.grid_view,
                color: Colors.white,
              ),
              onPressed: _toggleView,
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => _navigateToSearch(category.name),
            ),
          ],
        ),

        // Subcategory chips
        if (category.subcategories?.isNotEmpty ?? false)
          SliverToBoxAdapter(
            child: SubcategoryChips(
              subcategories: category.subcategories ?? [],
              selectedSubcategoryId: widget.subcategoryId,
              onSubcategorySelected: _onSubcategorySelected,
            ),
          ),

        // Filter bar
        SliverToBoxAdapter(
          child: CategoryFilterBar(
            categoryId: widget.categoryId,
            onFilterChanged: () => setState(() {}),
          ),
        ),

        // Products content
        _buildProductsContent(),
      ],
    );
  }

  Widget _buildProductsContent() {
    final productsAsync = ref.watch(
      categoryProductsProvider(widget.categoryId),
    );

    return productsAsync.when(
      data: (products) => products.isNotEmpty
          ? _buildProductsList(products)
          : SliverToBoxAdapter(
              child: ProductEmptyState(
                hasFilters: ref.hasActiveFilters(),
                onClearFilters: () => ref.clearAllFilters(),
                onBrowseAll: () => context.go('/products'),
                customMessage: 'No products in this category',
                customSubtitle:
                    'Try browsing other categories or adjusting your filters',
              ),
            ),
      loading: () => SliverToBoxAdapter(
        child: ProductLoadingGrid(isGridView: _isGridView),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: ProductErrorWidget(
          error: error.toString(),
          onRetry: () =>
              ref.invalidate(categoryProductsProvider(widget.categoryId)),
          customTitle: 'Failed to load category products',
        ),
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
    if (_isGridView) {
      return SliverPadding(
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
              if (index < products.length) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  isGridView: true,
                  onTap: () => _navigateToProduct(product),
                  onWishlistTap: () => _toggleWishlist(product),
                );
              } else {
                return _buildLoadMoreIndicator();
              }
            },
            childCount: products.length + 1, // +1 for load more
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: EdgeInsets.all(16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < products.length) {
                final product = products[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ProductCard(
                    product: product,
                    isGridView: false,
                    onTap: () => _navigateToProduct(product),
                    onWishlistTap: () => _toggleWishlist(product),
                  ),
                );
              } else {
                return _buildLoadMoreIndicator();
              }
            },
            childCount: products.length + 1, // +1 for load more
          ),
        ),
      );
    }
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _scrollToTop(),
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.keyboard_arrow_up),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const ProductLoadingGrid(isGridView: true),
    );
  }

  Widget _buildErrorScreen(Object error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ProductErrorWidget(
        error: error.toString(),
        onRetry: () => ref.invalidate(categoryByIdProvider(widget.categoryId)),
        onGoBack: () => Navigator.of(context).pop(),
        customTitle: 'Failed to load category',
      ),
    );
  }

  Widget _buildCategoryNotFound() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Not Found'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 80.sp,
                color: Theme.of(context).hintColor,
              ),

              SizedBox(height: 24.h),

              Text(
                'Category Not Found',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
              ),

              SizedBox(height: 8.h),

              Text(
                'The category you\'re looking for doesn\'t exist or has been removed.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              ElevatedButton(
                onPressed: () => context.go('/products'),
                child: const Text('Browse All Products'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action methods
  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onSubcategorySelected(String? subcategoryId) {
    if (subcategoryId != null) {
      context.go(
        '/categories/${widget.categoryId}/subcategories/$subcategoryId',
      );
    } else {
      context.go('/categories/${widget.categoryId}');
    }
  }

  void _navigateToProduct(Product product) {
    // Track product view from category
    ref.viewProduct(product.id);

    // Navigate to product detail
    context.push('/products/${product.id}');
  }

  void _navigateToSearch(String query) {
    context.push('/search?q=$query');
  }

  void _toggleWishlist(Product product) {
    ref.toggleWishlist(product.id);

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
