import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/wishlist.dart';
import '../providers/product_providers_setup.dart';
import '../providers/simple_providers.dart';
import '../widgets/wishlist_header.dart';
import '../widgets/wishlist_filter_bar.dart';
import '../widgets/wishlist_product_card.dart';
import '../widgets/wishlist_empty_state.dart';
import '../widgets/wishlist_loading_grid.dart';
import '../widgets/product_error_widget.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  bool _isGridView = true;
  bool _isSelectionMode = false;
  Set<String> _selectedProductIds = {};
  bool _showFloatingActionButton = false;

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
    final wishlistAsync = ref.watch(userWishlistProvider('current_user_id'));

    return Scaffold(
      appBar: _buildAppBar(context),
      body: wishlistAsync.when(
        data: (wishlist) => _buildWishlistContent(wishlist),
        loading: () => const WishlistLoadingGrid(),
        error: (error, stack) => ProductErrorWidget(
          error: error.toString(),
          onRetry: () =>
              ref.invalidate(userWishlistProvider('current_user_id')),
          customTitle: 'Failed to load wishlist',
        ),
      ),
      floatingActionButton: _showFloatingActionButton
          ? _buildFloatingActionButton()
          : null,
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBottomBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        _isSelectionMode
            ? '${_selectedProductIds.length} selected'
            : 'My Wishlist',
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (_isSelectionMode) ...[
          IconButton(icon: const Icon(Icons.select_all), onPressed: _selectAll),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitSelectionMode,
          ),
        ] else ...[
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'select',
                child: ListTile(
                  leading: Icon(Icons.checklist),
                  title: Text('Select Items'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Wishlist'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear Wishlist'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildWishlistContent(Wishlist wishlist) {
    if (wishlist.products.isEmpty) {
      return const WishlistEmptyState();
    }

    return Column(
      children: [
        // Wishlist header with stats
        WishlistHeader(
          wishlist: wishlist,
          onShareTap: () => _shareWishlist(wishlist),
          onClearTap: () => _clearWishlist(),
        ),

        // Filter bar
        WishlistFilterBar(
          onFilterChanged: () => setState(() {}),
          onViewToggle: _toggleView,
          isGridView: _isGridView,
        ),

        // Tabbed content
        Container(
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
              Tab(text: 'All Items'),
              Tab(text: 'Available'),
              Tab(text: 'On Sale'),
            ],
          ),
        ),

        // Products content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllItems(wishlist.products),
              _buildAvailableItems(wishlist.products),
              _buildOnSaleItems(wishlist.products),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllItems(List<Product> products) {
    return _buildProductsList(products);
  }

  Widget _buildAvailableItems(List<Product> products) {
    final availableProducts = products.where((p) => p.isInStock).toList();
    return _buildProductsList(availableProducts);
  }

  Widget _buildOnSaleItems(List<Product> products) {
    final onSaleProducts = products.where((p) => p.isOnSale).toList();
    return _buildProductsList(onSaleProducts);
  }

  Widget _buildProductsList(List<Product> products) {
    if (products.isEmpty) {
      return _buildEmptyTab();
    }

    if (_isGridView) {
      return GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return WishlistProductCard(
            product: product,
            isGridView: true,
            isSelectionMode: _isSelectionMode,
            isSelected: _selectedProductIds.contains(product.id),
            onTap: () => _handleProductTap(product),
            onWishlistTap: () => _removeFromWishlist(product),
            onSelectionChanged: (selected) =>
                _handleSelectionChanged(product.id, selected),
            onAddToCart: () => _addToCart(product),
          );
        },
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: WishlistProductCard(
              product: product,
              isGridView: false,
              isSelectionMode: _isSelectionMode,
              isSelected: _selectedProductIds.contains(product.id),
              onTap: () => _handleProductTap(product),
              onWishlistTap: () => _removeFromWishlist(product),
              onSelectionChanged: (selected) =>
                  _handleSelectionChanged(product.id, selected),
              onAddToCart: () => _addToCart(product),
            ),
          );
        },
      );
    }
  }

  Widget _buildEmptyTab() {
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
              'No items in this category',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Items matching this filter will appear here',
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

  Widget _buildSelectionBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedProductIds.isNotEmpty
                    ? () => _removeSelectedFromWishlist()
                    : null,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedProductIds.isNotEmpty
                    ? () => _addSelectedToCart()
                    : null,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to Cart'),
              ),
            ),
          ],
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
      case 'select':
        _enterSelectionMode();
        break;
      case 'share':
        _shareWishlist(null);
        break;
      case 'clear':
        _clearWishlist();
        break;
    }
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedProductIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedProductIds.clear();
    });
  }

  void _selectAll() {
    final wishlistAsync = ref.read(userWishlistProvider('current_user_id'));
    wishlistAsync.whenData((wishlist) {
      setState(() {
        _selectedProductIds = wishlist.products.map((p) => p.id).toSet();
      });
    });
  }

  void _handleProductTap(Product product) {
    if (_isSelectionMode) {
      _handleSelectionChanged(
        product.id,
        !_selectedProductIds.contains(product.id),
      );
    } else {
      _navigateToProduct(product);
    }
  }

  void _handleSelectionChanged(String productId, bool selected) {
    setState(() {
      if (selected) {
        _selectedProductIds.add(productId);
      } else {
        _selectedProductIds.remove(productId);
      }
    });
  }

  void _navigateToProduct(Product product) {
    // Track product view from wishlist
    ref.viewProduct(product.id);

    // Navigate to product detail
    context.push('/products/${product.id}');
  }

  void _removeFromWishlist(Product product) {
    ref.removeFromWishlist('current_user_id', product.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} removed from wishlist'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ref.addToWishlist('current_user_id', product.id),
        ),
      ),
    );
  }

  void _removeSelectedFromWishlist() {
    for (final productId in _selectedProductIds) {
      ref.removeFromWishlist('current_user_id', productId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedProductIds.length} items removed from wishlist',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    _exitSelectionMode();
  }

  void _addToCart(Product product) {
    ref.addToCart(product, 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  void _addSelectedToCart() {
    final wishlistAsync = ref.read(userWishlistProvider('current_user_id'));
    wishlistAsync.whenData((wishlist) {
      final selectedProducts = wishlist.products
          .where((p) => _selectedProductIds.contains(p.id))
          .toList();

      for (final product in selectedProducts) {
        ref.addToCart(product, 1);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedProducts.length} items added to cart'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () => context.push('/cart'),
          ),
        ),
      );
    });

    _exitSelectionMode();
  }

  void _shareWishlist(Wishlist? wishlist) {
    // Share wishlist functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Wishlist'),
        content: const Text('Share your wishlist with friends and family'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement share functionality
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _clearWishlist() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text(
          'Are you sure you want to remove all items from your wishlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.clearWishlist('current_user_id');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wishlist cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
