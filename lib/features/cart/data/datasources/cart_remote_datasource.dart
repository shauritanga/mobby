import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_model.dart';
import '../models/cart_item_model.dart';
import '../../../products/data/models/product_model.dart';

/// Remote data source for cart operations using Firestore
abstract class CartRemoteDataSource {
  /// Get cart from remote server
  Future<CartModel?> getCart(String userId);

  /// Save cart to remote server
  Future<CartModel> saveCart(String userId, CartModel cart);

  /// Delete cart from remote server
  Future<void> deleteCart(String userId);

  /// Get a stream of cart updates
  Stream<CartModel?> watchCart(String userId);

  /// Apply coupon to cart
  Future<CartModel> applyCoupon(String userId, String couponCode);

  /// Remove coupon from cart
  Future<CartModel> removeCoupon(String userId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore firestore;

  CartRemoteDataSourceImpl({required this.firestore});

  static const String _cartsCollection = 'carts';
  static const String _couponsCollection = 'coupons';

  @override
  Future<CartModel?> getCart(String userId) async {
    try {
      final doc = await firestore
          .collection(_cartsCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return CartModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting cart from remote: $e');
      throw Exception('Failed to get cart from server');
    }
  }

  @override
  Future<CartModel> saveCart(String userId, CartModel cart) async {
    try {
      final cartData = cart.toJson();
      cartData['updatedAt'] = FieldValue.serverTimestamp();

      await firestore
          .collection(_cartsCollection)
          .doc(userId)
          .set(cartData, SetOptions(merge: true));

      // Return cart with server timestamp
      final updatedCart = cart.copyWith(updatedAt: DateTime.now());
      return updatedCart;
    } catch (e) {
      print('Error saving cart to remote: $e');
      throw Exception('Failed to save cart to server');
    }
  }

  @override
  Future<void> deleteCart(String userId) async {
    try {
      await firestore
          .collection(_cartsCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      print('Error deleting cart from remote: $e');
      throw Exception('Failed to delete cart from server');
    }
  }

  @override
  Stream<CartModel?> watchCart(String userId) {
    try {
      return firestore
          .collection(_cartsCollection)
          .doc(userId)
          .snapshots()
          .map((doc) {
        if (doc.exists && doc.data() != null) {
          return CartModel.fromJson(doc.data()!);
        }
        return null;
      });
    } catch (e) {
      print('Error watching cart: $e');
      return Stream.value(null);
    }
  }

  @override
  Future<CartModel> applyCoupon(String userId, String couponCode) async {
    try {
      // First, validate the coupon
      final couponDoc = await firestore
          .collection(_couponsCollection)
          .doc(couponCode)
          .get();

      if (!couponDoc.exists) {
        throw Exception('Invalid coupon code');
      }

      final couponData = couponDoc.data()!;
      final isActive = couponData['isActive'] as bool? ?? false;
      final expiryDate = (couponData['expiryDate'] as Timestamp?)?.toDate();
      
      if (!isActive) {
        throw Exception('Coupon is not active');
      }

      if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
        throw Exception('Coupon has expired');
      }

      // Get current cart
      final currentCart = await getCart(userId);
      if (currentCart == null) {
        throw Exception('Cart not found');
      }

      // Calculate discount
      final discountType = couponData['discountType'] as String? ?? 'percentage';
      final discountValue = (couponData['discountValue'] as num?)?.toDouble() ?? 0.0;
      final minOrderAmount = (couponData['minOrderAmount'] as num?)?.toDouble() ?? 0.0;

      if (currentCart.subtotal < minOrderAmount) {
        throw Exception('Minimum order amount not met');
      }

      double couponDiscount = 0.0;
      if (discountType == 'percentage') {
        couponDiscount = currentCart.subtotal * (discountValue / 100);
      } else if (discountType == 'fixed') {
        couponDiscount = discountValue;
      }

      // Apply maximum discount limit if specified
      final maxDiscount = (couponData['maxDiscount'] as num?)?.toDouble();
      if (maxDiscount != null && couponDiscount > maxDiscount) {
        couponDiscount = maxDiscount;
      }

      // Update cart with coupon
      final updatedCart = currentCart.copyWith(
        appliedCoupon: couponCode,
        couponDiscount: couponDiscount,
        updatedAt: DateTime.now(),
      );

      // Recalculate totals
      final finalCart = CartModel.calculateTotals(updatedCart);

      // Save updated cart
      return await saveCart(userId, finalCart);
    } catch (e) {
      print('Error applying coupon: $e');
      throw Exception('Failed to apply coupon: ${e.toString()}');
    }
  }

  @override
  Future<CartModel> removeCoupon(String userId) async {
    try {
      // Get current cart
      final currentCart = await getCart(userId);
      if (currentCart == null) {
        throw Exception('Cart not found');
      }

      // Remove coupon
      final updatedCart = currentCart.copyWith(
        appliedCoupon: null,
        couponDiscount: 0.0,
        updatedAt: DateTime.now(),
      );

      // Recalculate totals
      final finalCart = CartModel.calculateTotals(updatedCart);

      // Save updated cart
      return await saveCart(userId, finalCart);
    } catch (e) {
      print('Error removing coupon: $e');
      throw Exception('Failed to remove coupon');
    }
  }
}
