import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/brand.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers_setup.dart';
import '../providers/simple_providers.dart';
import '../widgets/brand_header_section.dart';
import '../widgets/brand_info_card.dart';
import '../widgets/brand_filter_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_loading_grid.dart';
import '../widgets/product_empty_state.dart';
import '../widgets/product_error_widget.dart';

class BrandBrowseScreen extends ConsumerStatefulWidget {
  final String brandId;

  const BrandBrowseScreen({super.key, required this.brandId});

  @override
  ConsumerState<BrandBrowseScreen> createState() => _BrandBrowseScreenState();
}

class _BrandBrowseScreenState extends ConsumerState<BrandBrowseScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  bool _isGridView = true;
  bool _showFloatingActionButton = false;
  bool _showBrandInfo = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final showInfo = _scrollController.offset < 100;

      if (showFAB != _showFloatingActionButton || showInfo != _showBrandInfo) {
        setState(() {
          _showFloatingActionButton = showFAB;
          _showBrandInfo = showInfo;
        });
      }
    });
  }

  void _initializeFilters() {
    // Initialize brand filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(filterStateProvider.notifier).updateBrandIds([widget.brandId]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandAsync = ref.watch(brandProvider(widget.brandId));

    return Scaffold(
      body: brandAsync.when(
        data: (brand) =>
            brand != null ? _buildBrandContent(brand) : _buildBrandNotFound(),
        loading: () => _buildLoadingScreen(),
        error: (error, stack) => _buildErrorScreen(error),
      ),
      floatingActionButton: _showFloatingActionButton
          ? _buildFloatingActionButton()
          : null,
    );
  }

  Widget _buildBrandContent(Brand brand) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Brand app bar
        SliverAppBar(
          expandedHeight: 250.h,
          pinned: true,
          backgroundColor: brand.primaryColor ?? Theme.of(context).primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              brand.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            background: BrandHeaderSection(
              brand: brand,
              onSearchTap: () => _navigateToSearch(brand.name),
              onFollowTap: () => _toggleFollowBrand(brand),
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
              onPressed: () => _navigateToSearch(brand.name),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share Brand'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: ListTile(
                    leading: Icon(Icons.report),
                    title: Text('Report Issue'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Brand info card (collapsible)
        if (_showBrandInfo)
          SliverToBoxAdapter(
            child: BrandInfoCard(
              brand: brand,
              onCategoryTap: _onCategoryTap,
              onContactTap: () => _contactBrand(brand),
            ),
          ),

        // Filter bar
        SliverToBoxAdapter(
          child: BrandFilterBar(
            brandId: widget.brandId,
            onFilterChanged: () => setState(() {}),
          ),
        ),

        // Tabbed content
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).hintColor,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'All Products'),
                Tab(text: 'Popular'),
                Tab(text: 'New Arrivals'),
              ],
            ),
          ),
        ),

        // Products content
        _buildProductsContent(),
      ],
    );
  }

  Widget _buildProductsContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAllProducts(),
          _buildPopularProducts(),
          _buildNewArrivals(),
        ],
      ),
    );
  }

  Widget _buildAllProducts() {
    final productsAsync = ref.watch(brandProductsProvider(widget.brandId));

    return productsAsync.when(
      data: (products) => products.isNotEmpty
          ? _buildProductsList(products)
          : ProductEmptyState(
              hasFilters: ref.hasActiveFilters(),
              onClearFilters: () => ref.clearAllFilters(),
              onBrowseAll: () => context.go('/products'),
              customMessage: 'No products from this brand',
              customSubtitle:
                  'Try browsing other brands or adjusting your filters',
            ),
      loading: () => ProductLoadingGrid(isGridView: _isGridView),
      error: (error, stack) => ProductErrorWidget(
        error: error.toString(),
        onRetry: () => ref.invalidate(brandProductsProvider(widget.brandId)),
        customTitle: 'Failed to load brand products',
      ),
    );
  }

  Widget _buildPopularProducts() {
    final productsAsync = ref.watch(
      brandPopularProductsProvider(widget.brandId),
    );

    return productsAsync.when(
      data: (products) => products.isNotEmpty
          ? _buildProductsList(products)
          : _buildEmptyTab(
              'No popular products',
              'Popular products will appear here',
            ),
      loading: () => ProductLoadingGrid(isGridView: _isGridView),
      error: (error, stack) => ProductErrorWidget(
        error: error.toString(),
        onRetry: () =>
            ref.invalidate(brandPopularProductsProvider(widget.brandId)),
        customTitle: 'Failed to load popular products',
      ),
    );
  }

  Widget _buildNewArrivals() {
    final productsAsync = ref.watch(brandNewArrivalsProvider(widget.brandId));

    return productsAsync.when(
      data: (products) => products.isNotEmpty
          ? _buildProductsList(products)
          : _buildEmptyTab('No new arrivals', 'New products will appear here'),
      loading: () => ProductLoadingGrid(isGridView: _isGridView),
      error: (error, stack) => ProductErrorWidget(
        error: error.toString(),
        onRetry: () => ref.invalidate(brandNewArrivalsProvider(widget.brandId)),
        customTitle: 'Failed to load new arrivals',
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
    if (_isGridView) {
      return GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            isGridView: true,
            onTap: () => _navigateToProduct(product),
            onWishlistTap: () => _toggleWishlist(product),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: products.length,
        itemBuilder: (context, index) {
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
        },
      );
    }
  }

  Widget _buildEmptyTab(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64.sp,
              color: Theme.of(context).hintColor,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
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
        onRetry: () => ref.invalidate(brandProvider(widget.brandId)),
        onGoBack: () => Navigator.of(context).pop(),
        customTitle: 'Failed to load brand',
      ),
    );
  }

  Widget _buildBrandNotFound() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Not Found'),
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
                Icons.business_outlined,
                size: 80.sp,
                color: Theme.of(context).hintColor,
              ),
              SizedBox(height: 24.h),
              Text(
                'Brand Not Found',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text(
                'The brand you\'re looking for doesn\'t exist or has been removed.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () => context.go('/brands'),
                child: const Text('Browse All Brands'),
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareBrand();
        break;
      case 'report':
        _reportBrand();
        break;
    }
  }

  void _onCategoryTap(String categoryId) {
    context.push('/categories/$categoryId');
  }

  void _navigateToProduct(Product product) {
    // Track product view from brand
    ref.viewProduct(product.id);

    // Navigate to product detail
    context.push('/products/${product.id}');
  }

  void _navigateToSearch(String query) {
    context.push('/search?q=$query&brandId=${widget.brandId}');
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

  void _toggleFollowBrand(Brand brand) {
    ref.toggleFollowBrand('current_user_id', brand.id);

    final isFollowing = ref.isBrandFollowed(brand.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFollowing ? 'Following ${brand.name}' : 'Unfollowed ${brand.name}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _contactBrand(Brand brand) {
    // Show contact options
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact ${brand.name}',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.h),
            if (brand.websiteUrl != null)
              ListTile(
                leading: const Icon(Icons.web),
                title: const Text('Visit Website'),
                onTap: () => _openWebsite(brand.websiteUrl!),
              ),
            if (brand.email != null)
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Send Email'),
                onTap: () => _sendEmail(brand.email!),
              ),
            if (brand.phone != null)
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Call'),
                onTap: () => _makeCall(brand.phone!),
              ),
          ],
        ),
      ),
    );
  }

  void _shareBrand() {
    // Share brand functionality
  }

  void _reportBrand() {
    // Report brand functionality
  }

  void _openWebsite(String url) {
    // Open website
  }

  void _sendEmail(String email) {
    // Send email
  }

  void _makeCall(String phone) {
    // Make phone call
  }
}
