import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../../products/domain/entities/product.dart';

// Mock cart data for development
final _mockCarts = <String, Cart>{};

// Cart providers
final userCartProvider = FutureProvider.family<Cart, String>((ref, userId) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Return existing cart or create empty cart
  return _mockCarts[userId] ?? Cart(
    id: 'cart_$userId',
    userId: userId,
    items: [],
    subtotal: 0.0,
    total: 0.0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
});

// Cart actions (these would normally be in a repository/service)
extension CartActions on WidgetRef {
  void addToCart(String userId, Product product, int quantity) {
    final currentCart = _mockCarts[userId] ?? Cart(
      id: 'cart_$userId',
      userId: userId,
      items: [],
      subtotal: 0.0,
      total: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final existingItemIndex = currentCart.items.indexWhere((item) => item.product.id == product.id);
    
    List<CartItem> updatedItems;
    if (existingItemIndex >= 0) {
      // Update existing item quantity
      updatedItems = List.from(currentCart.items);
      updatedItems[existingItemIndex] = updatedItems[existingItemIndex].copyWith(
        quantity: updatedItems[existingItemIndex].quantity + quantity,
        updatedAt: DateTime.now(),
      );
    } else {
      // Add new item
      updatedItems = [
        ...currentCart.items,
        CartItem(
          id: 'item_${DateTime.now().millisecondsSinceEpoch}',
          product: product,
          quantity: quantity,
          addedAt: DateTime.now(),
        ),
      ];
    }

    final updatedCart = Cart.calculateTotals(currentCart.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    ));

    _mockCarts[userId] = updatedCart;
    invalidate(userCartProvider(userId));
  }

  void removeFromCart(String userId, String itemId) {
    final currentCart = _mockCarts[userId];
    if (currentCart == null) return;

    final updatedItems = currentCart.items.where((item) => item.id != itemId).toList();
    final updatedCart = Cart.calculateTotals(currentCart.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    ));

    _mockCarts[userId] = updatedCart;
    invalidate(userCartProvider(userId));
  }

  void updateCartItemQuantity(String userId, String itemId, int quantity) {
    final currentCart = _mockCarts[userId];
    if (currentCart == null) return;

    final updatedItems = currentCart.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity, updatedAt: DateTime.now());
      }
      return item;
    }).toList();

    final updatedCart = Cart.calculateTotals(currentCart.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    ));

    _mockCarts[userId] = updatedCart;
    invalidate(userCartProvider(userId));
  }

  void clearCart(String userId) {
    final currentCart = _mockCarts[userId];
    if (currentCart == null) return;

    final updatedCart = currentCart.copyWith(
      items: [],
      subtotal: 0.0,
      discount: 0.0,
      couponDiscount: 0.0,
      total: 0.0,
      appliedCoupon: null,
      updatedAt: DateTime.now(),
    );

    _mockCarts[userId] = updatedCart;
    invalidate(userCartProvider(userId));
  }

  void applyCoupon(String userId, String couponCode) {
    final currentCart = _mockCarts[userId];
    if (currentCart == null) return;

    // Mock coupon validation and discount calculation
    double couponDiscount = 0.0;
    switch (couponCode.toUpperCase()) {
      case 'SAVE10':
        couponDiscount = currentCart.subtotal * 0.1; // 10% discount
        break;
      case 'SAVE5000':
        couponDiscount = 5000.0; // Fixed 5000 TZS discount
        break;
      case 'FREESHIP':
        // This would be handled in shipping calculation
        break;
    }

    final updatedCart = Cart.calculateTotals(currentCart.copyWith(
      couponDiscount: couponDiscount,
      appliedCoupon: couponCode,
      updatedAt: DateTime.now(),
    ));

    _mockCarts[userId] = updatedCart;
    invalidate(userCartProvider(userId));
  }

  void removeCoupon(String userId) {
    final currentCart = _mockCarts[userId];
    if (currentCart == null) return;

    final updatedCart = Cart.calculateTotals(currentCart.copyWith(
      couponDiscount: 0.0,
      appliedCoupon: null,
      updatedAt: DateTime.now(),
    ));

    _mockCarts[userId] = updatedCart;
    invalidate(userCartProvider(userId));
  }

  void saveForLater(String userId, String itemId) {
    // Mock implementation - in real app, this would move item to saved items
    removeFromCart(userId, itemId);
  }

  void saveAllForLater(String userId) {
    // Mock implementation - in real app, this would move all items to saved items
    clearCart(userId);
  }

  void addRecommendedToCart(String userId, String productId) {
    // Mock implementation - in real app, this would fetch product and add to cart
    // For now, just simulate adding a product
  }

  // Analytics methods
  void trackCheckoutInitiated(String userId, Cart cart) {
    // Mock analytics tracking
    print('Checkout initiated: User $userId, Cart total: ${cart.total}');
  }

  void trackPartialCheckout(String userId, Cart cart) {
    // Mock analytics tracking
    print('Partial checkout: User $userId, Selected items: ${cart.items.length}');
  }
}
