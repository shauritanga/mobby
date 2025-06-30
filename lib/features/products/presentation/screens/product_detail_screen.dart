import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../providers/product_providers_setup.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_specifications_section.dart';
import '../widgets/product_reviews_section.dart';
import '../widgets/related_products_section.dart';
import '../widgets/product_actions_section.dart';
import '../widgets/product_detail_app_bar.dart';
import '../widgets/product_loading_detail.dart';
import '../widgets/product_error_widget.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  bool _showFloatingActionButton = false;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupScrollListener();
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

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));

    return Scaffold(
      body: productAsync.when(
        data: (product) => product != null
            ? _buildProductDetail(product)
            : _buildProductNotFound(),
        loading: () => const ProductLoadingDetail(),
        error: (error, stack) => ProductErrorWidget(
          error: error.toString(),
          onRetry: () => ref.invalidate(productProvider(widget.productId)),
          onGoBack: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: _showFloatingActionButton
          ? _buildFloatingActionButton()
          : null,
    );
  }

  Widget _buildProductDetail(Product product) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar with product images
        ProductDetailAppBar(
          product: product,
          selectedImageIndex: _selectedImageIndex,
          onImageChanged: (index) {
            setState(() {
              _selectedImageIndex = index;
            });
          },
          onWishlistTap: () => _toggleWishlist(product),
          onShareTap: () => _shareProduct(product),
        ),

        // Product content
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Product info section
              ProductInfoSection(
                product: product,
                onBrandTap: () => _navigateToBrand(product.brandId),
                onCategoryTap: () => _navigateToCategory(product.categoryId),
              ),

              // Product actions (Add to Cart, Buy Now, etc.)
              ProductActionsSection(
                product: product,
                onAddToCart: () => _addToCart(product),
                onBuyNow: () => _buyNow(product),
                onWishlistTap: () => _toggleWishlist(product),
              ),

              SizedBox(height: 16.h),

              // Tabbed content
              _buildTabbedContent(product),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabbedContent(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(text: 'Details'),
                Tab(text: 'Reviews (${product.reviewCount})'),
                Tab(text: 'Related'),
              ],
            ),
          ),

          // Tab content
          SizedBox(
            height: 600.h, // Fixed height for tab content
            child: TabBarView(
              controller: _tabController,
              children: [
                // Specifications tab
                ProductSpecificationsSection(
                  product: product,
                  onCompatibilityCheck: () => _checkCompatibility(product),
                ),

                // Reviews tab
                ProductReviewsSection(
                  productId: product.id,
                  onWriteReview: () => _writeReview(product),
                ),

                // Related products tab
                RelatedProductsSection(
                  productId: product.id,
                  onProductTap: (relatedProduct) =>
                      _navigateToProduct(relatedProduct.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final productAsync = ref.watch(productProvider(widget.productId));

    return productAsync.when(
      data: (product) => product != null
          ? FloatingActionButton.extended(
              onPressed: () => _addToCart(product),
              icon: const Icon(Icons.shopping_cart),
              label: Text('Add to Cart', style: TextStyle(fontSize: 16.sp)),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildProductNotFound() {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Not Found')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80.sp,
                color: Theme.of(context).hintColor,
              ),

              SizedBox(height: 24.h),

              Text(
                'Product Not Found',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
              ),

              SizedBox(height: 8.h),

              Text(
                'The product you\'re looking for doesn\'t exist or has been removed.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              ElevatedButton(
                onPressed: () => context.go('/products'),
                child: const Text('Browse Products'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action methods
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

  void _shareProduct(Product product) {
    // Implement product sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${product.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToCart(Product product) {
    if (product.isOutOfStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This product is out of stock'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Add to cart logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  void _buyNow(Product product) {
    if (product.isOutOfStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This product is out of stock'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Navigate to checkout with this product
    context.push('/checkout?productId=${product.id}');
  }

  void _navigateToBrand(String brandId) {
    context.push('/products?brandId=$brandId');
  }

  void _navigateToCategory(String categoryId) {
    context.push('/products?categoryId=$categoryId');
  }

  void _navigateToProduct(String productId) {
    context.push('/products/$productId');
  }

  void _checkCompatibility(Product product) {
    // Show compatibility checker dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vehicle Compatibility'),
        content: const Text(
          'Enter your vehicle details to check if this product is compatible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to compatibility checker
              context.push('/compatibility?productId=${product.id}');
            },
            child: const Text('Check Compatibility'),
          ),
        ],
      ),
    );
  }

  void _writeReview(Product product) {
    // Navigate to write review screen
    context.push('/products/${product.id}/write-review');
  }
}
