import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_providers.dart';
import '../widgets/cart_header.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_loading_state.dart';
import '../widgets/cart_error_widget.dart';
import '../widgets/recommended_products.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  bool _isSelectionMode = false;
  Set<String> _selectedItemIds = {};
  bool _showFloatingActionButton = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
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
    final cartAsync = ref.watch(userCartProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: cartAsync.when(
        data: (cart) => _buildCartContent(cart),
        loading: () => const CartLoadingState(),
        error: (error, stack) => CartErrorWidget(
          error: error.toString(),
          onRetry: () => ref.invalidate(userCartProvider),
        ),
      ),
      floatingActionButton: _showFloatingActionButton
          ? _buildFloatingActionButton()
          : null,
      bottomNavigationBar: cartAsync.when(
        data: (cart) => cart.items.isNotEmpty
            ? _isSelectionMode
                  ? _buildSelectionBottomBar(cart)
                  : _buildCheckoutBottomBar(cart)
            : null,
        loading: () => null,
        error: (error, stack) => null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final cartAsync = ref.watch(userCartProvider);

    return AppBar(
      title: Text(
        _isSelectionMode
            ? '${_selectedItemIds.length} selected'
            : 'Shopping Cart',
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
          cartAsync.when(
            data: (cart) => cart.items.isNotEmpty
                ? PopupMenuButton<String>(
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
                        value: 'save',
                        child: ListTile(
                          leading: Icon(Icons.bookmark),
                          title: Text('Save for Later'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear',
                        child: ListTile(
                          leading: Icon(Icons.clear_all),
                          title: Text('Clear Cart'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }

  Widget _buildCartContent(Cart cart) {
    if (cart.items.isEmpty) {
      return const CartEmptyState();
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Cart header with summary
        SliverToBoxAdapter(
          child: CartHeader(
            cart: cart,
            onClearCart: () => _clearCart(),
            onSaveForLater: () => _saveAllForLater(),
          ),
        ),

        // Cart items
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = cart.items[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: CartItemCard(
                item: item,
                isSelectionMode: _isSelectionMode,
                isSelected: _selectedItemIds.contains(item.id),
                onTap: () => _handleItemTap(item),
                onQuantityChanged: (quantity) =>
                    _updateQuantity(item, quantity),
                onRemove: () => _removeItem(item),
                onSaveForLater: () => _saveForLater(item),
                onSelectionChanged: (selected) =>
                    _handleSelectionChanged(item.id, selected),
              ),
            );
          }, childCount: cart.items.length),
        ),

        // Cart summary
        SliverToBoxAdapter(
          child: CartSummary(
            cart: cart,
            onApplyCoupon: _applyCoupon,
            onRemoveCoupon: _removeCoupon,
          ),
        ),

        // Recommended products
        SliverToBoxAdapter(
          child: RecommendedProducts(
            cartItems: cart.items,
            onProductTap: _navigateToProduct,
            onAddToCart: _addRecommendedToCart,
          ),
        ),

        // Bottom spacing for checkout button
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _scrollToTop(),
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.keyboard_arrow_up),
    );
  }

  Widget _buildSelectionBottomBar(Cart cart) {
    final selectedItems = cart.items
        .where((item) => _selectedItemIds.contains(item.id))
        .toList();
    final selectedTotal = selectedItems.fold<double>(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selection summary
            Row(
              children: [
                Text(
                  '${selectedItems.length} items selected',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'TZS ${_formatPrice(selectedTotal)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectedItemIds.isNotEmpty
                        ? () => _removeSelectedItems()
                        : null,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectedItemIds.isNotEmpty
                        ? () => _saveSelectedForLater()
                        : null,
                    icon: const Icon(Icons.bookmark_outline),
                    label: const Text('Save'),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedItemIds.isNotEmpty
                        ? () => _checkoutSelected()
                        : null,
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBottomBar(Cart cart) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total summary
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total (${cart.items.length} items)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Text(
                      'TZS ${_formatPrice(cart.total)}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Checkout button
                ElevatedButton.icon(
                  onPressed: () => _proceedToCheckout(cart),
                  icon: Icon(Icons.shopping_cart_checkout, size: 20.sp),
                  label: Text('Checkout', style: TextStyle(fontSize: 16.sp)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                ),
              ],
            ),

            // Delivery info
            if (cart.estimatedDelivery != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.local_shipping, size: 16.sp, color: Colors.green),
                  SizedBox(width: 4.w),
                  Text(
                    'Estimated delivery: ${cart.estimatedDelivery}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.green),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Action methods
  void _handleMenuAction(String action) {
    switch (action) {
      case 'select':
        _enterSelectionMode();
        break;
      case 'save':
        _saveAllForLater();
        break;
      case 'clear':
        _clearCart();
        break;
    }
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedItemIds.clear();
    });
    _animationController.forward();
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItemIds.clear();
    });
    _animationController.reverse();
  }

  void _selectAll() {
    final cartAsync = ref.read(userCartProvider);
    cartAsync.whenData((cart) {
      setState(() {
        _selectedItemIds = cart.items.map((item) => item.id).toSet();
      });
    });
  }

  void _handleItemTap(CartItem item) {
    if (_isSelectionMode) {
      _handleSelectionChanged(item.id, !_selectedItemIds.contains(item.id));
    } else {
      _navigateToProduct(item.product.id);
    }
  }

  void _handleSelectionChanged(String itemId, bool selected) {
    setState(() {
      if (selected) {
        _selectedItemIds.add(itemId);
      } else {
        _selectedItemIds.remove(itemId);
      }
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _updateQuantity(CartItem item, int quantity) async {
    if (quantity <= 0) {
      _removeItem(item);
    } else {
      try {
        await ref.updateCartItemQuantity(item.id, quantity);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update quantity: $e')),
          );
        }
      }
    }
  }

  void _removeItem(CartItem item) async {
    try {
      await ref.removeFromCart(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.product.name} removed from cart'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => ref.addToCart(item.product, item.quantity),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
      }
    }
  }

  void _removeSelectedItems() async {
    final itemCount = _selectedItemIds.length;

    try {
      for (final itemId in _selectedItemIds) {
        await ref.removeFromCart(itemId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$itemCount items removed from cart'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      _exitSelectionMode();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove items: $e')));
      }
    }
  }

  void _saveForLater(CartItem item) async {
    try {
      await ref.saveForLater(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.product.name} saved for later'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save for later: $e')));
      }
    }
  }

  void _saveSelectedForLater() async {
    final itemCount = _selectedItemIds.length;

    try {
      for (final itemId in _selectedItemIds) {
        await ref.saveForLater(itemId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$itemCount items saved for later'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      _exitSelectionMode();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save items: $e')));
      }
    }
  }

  void _saveAllForLater() async {
    try {
      await ref.saveAllForLater();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All items saved for later'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save items: $e')));
      }
    }
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.clearCart();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cart cleared'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to clear cart: $e'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
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

  void _applyCoupon(String couponCode) async {
    try {
      await ref.applyCoupon(couponCode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to apply coupon: $e')));
      }
    }
  }

  void _removeCoupon() async {
    try {
      await ref.removeCoupon();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove coupon: $e')));
      }
    }
  }

  void _navigateToProduct(String productId) {
    context.push('/products/$productId');
  }

  void _addRecommendedToCart(String productId) {
    // Add recommended product to cart
    ref.addRecommendedToCart(productId);
  }

  void _proceedToCheckout(Cart cart) {
    // Track checkout initiation
    ref.trackCheckoutInitiated(cart);

    // Navigate to checkout
    context.push('/checkout');
  }

  void _checkoutSelected() {
    final cartAsync = ref.read(userCartProvider);
    cartAsync.whenData((cart) {
      final selectedItems = cart.items
          .where((item) => _selectedItemIds.contains(item.id))
          .toList();

      // Create temporary cart with selected items
      final selectedCart = cart.copyWith(items: selectedItems);

      // Track partial checkout
      ref.trackPartialCheckout(selectedCart);

      // Navigate to checkout with selected items
      context.push('/checkout?selectedItems=${_selectedItemIds.join(',')}');
    });

    _exitSelectionMode();
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
