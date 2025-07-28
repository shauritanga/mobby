import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_item_model.dart';

class CartModel extends Cart {
  const CartModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.subtotal,
    super.discount = 0.0,
    super.couponDiscount = 0.0,
    super.shippingCost = 0.0,
    super.tax = 0.0,
    required super.total,
    super.appliedCoupon,
    required super.createdAt,
    required super.updatedAt,
    super.estimatedDelivery,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      appliedCoupon: json['appliedCoupon'] as String?,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      estimatedDelivery: json['estimatedDelivery'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => (item as CartItemModel).toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'couponDiscount': couponDiscount,
      'shippingCost': shippingCost,
      'tax': tax,
      'total': total,
      'appliedCoupon': appliedCoupon,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'estimatedDelivery': estimatedDelivery,
    };
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.now();
  }

  @override
  CartModel copyWith({
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
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items?.cast<CartItemModel>() ?? this.items.cast<CartItemModel>(),
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

  /// Create an empty cart for a user
  factory CartModel.empty(String userId) {
    final now = DateTime.now();
    return CartModel(
      id: 'cart_$userId',
      userId: userId,
      items: [],
      subtotal: 0.0,
      total: 0.0,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Calculate totals for a cart
  static CartModel calculateTotals(CartModel cart) {
    final subtotal = cart.items.fold<double>(
      0,
      (total, item) => total + (item.product.price * item.quantity),
    );

    // Calculate shipping (free over 50,000 TZS)
    final shippingCost = subtotal >= 50000 ? 0.0 : 5000.0;

    // Calculate tax (18% VAT)
    final tax = subtotal * 0.18;

    // Calculate total
    final totalAmount =
        subtotal - cart.discount - cart.couponDiscount + shippingCost + tax;

    return cart.copyWith(
      subtotal: subtotal,
      shippingCost: shippingCost,
      tax: tax,
      total: totalAmount,
    );
  }
}
