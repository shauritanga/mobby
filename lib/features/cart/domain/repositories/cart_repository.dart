import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';

/// Repository interface for cart operations
abstract class CartRepository {
  /// Get the cart for a specific user
  /// Returns a [Cart] entity or a [Failure]
  Future<Either<Failure, Cart>> getUserCart(String userId);

  /// Add a product to the user's cart
  /// Returns the updated [Cart] or a [Failure]
  Future<Either<Failure, Cart>> addToCart(
    String userId,
    Product product,
    int quantity,
  );

  /// Remove an item from the user's cart
  /// Returns the updated [Cart] or a [Failure]
  Future<Either<Failure, Cart>> removeFromCart(
    String userId,
    String itemId,
  );

  /// Update the quantity of an item in the cart
  /// Returns the updated [Cart] or a [Failure]
  Future<Either<Failure, Cart>> updateCartItemQuantity(
    String userId,
    String itemId,
    int quantity,
  );

  /// Clear all items from the user's cart
  /// Returns the empty [Cart] or a [Failure]
  Future<Either<Failure, Cart>> clearCart(String userId);

  /// Apply a coupon to the cart
  /// Returns the updated [Cart] with discount or a [Failure]
  Future<Either<Failure, Cart>> applyCoupon(
    String userId,
    String couponCode,
  );

  /// Remove a coupon from the cart
  /// Returns the updated [Cart] without discount or a [Failure]
  Future<Either<Failure, Cart>> removeCoupon(String userId);

  /// Save cart items for later
  /// Returns a [Unit] to indicate success or a [Failure]
  Future<Either<Failure, Unit>> saveForLater(
    String userId,
    String itemId,
  );

  /// Save all cart items for later
  /// Returns a [Unit] to indicate success or a [Failure]
  Future<Either<Failure, Unit>> saveAllForLater(String userId);

  /// Get a stream of cart updates for a specific user
  /// Returns a [Stream] of [Cart] entities
  Stream<Cart> watchUserCart(String userId);

  /// Synchronize local cart with remote cart
  /// Returns the synchronized [Cart] or a [Failure]
  Future<Either<Failure, Cart>> syncCart(String userId);
}
