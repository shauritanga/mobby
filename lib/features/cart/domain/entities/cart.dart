import 'cart_item.dart';

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double couponDiscount;
  final double shippingCost;
  final double tax;
  final double total;
  final String? appliedCoupon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? estimatedDelivery;

  const Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.couponDiscount = 0.0,
    this.shippingCost = 0.0,
    this.tax = 0.0,
    required this.total,
    this.appliedCoupon,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedDelivery,
  });

  Cart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? couponDiscount,
    double? shippingCost,
    double? tax,
    double? total,
    String? appliedCoupon,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? estimatedDelivery,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }

  // Helper getters
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);
  
  double get totalSavings => discount + couponDiscount;
  
  bool get isEmpty => items.isEmpty;
  
  bool get isNotEmpty => items.isNotEmpty;

  // Calculate totals
  static Cart calculateTotals(Cart cart) {
    final subtotal = cart.items.fold<double>(0, (sum, item) => sum + (item.product.price * item.quantity));
    
    // Calculate shipping (free over 50,000 TZS)
    final shippingCost = subtotal >= 50000 ? 0.0 : 5000.0;
    
    // Calculate tax (18% VAT)
    final tax = subtotal * 0.18;
    
    // Calculate total
    final total = subtotal - cart.discount - cart.couponDiscount + shippingCost + tax;
    
    return cart.copyWith(
      subtotal: subtotal,
      shippingCost: shippingCost,
      tax: tax,
      total: total,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cart && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Cart(id: $id, userId: $userId, itemCount: $itemCount, total: $total)';
  }
}
