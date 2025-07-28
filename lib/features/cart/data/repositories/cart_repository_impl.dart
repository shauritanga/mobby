import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../datasources/cart_remote_datasource.dart';
import '../models/cart_model.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Cart>> getUserCart(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        // Try to get from remote first
        final remoteCart = await remoteDataSource.getCart(userId);
        if (remoteCart != null) {
          // Cache the remote cart
          await localDataSource.cacheCart(userId, remoteCart);
          return Right(remoteCart);
        }
      }

      // Fallback to local cache
      final localCart = await localDataSource.getCachedCart(userId);
      if (localCart != null) {
        return Right(localCart);
      }

      // Return empty cart if none exists
      final emptyCart = CartModel.empty(userId);
      await localDataSource.cacheCart(userId, emptyCart);
      return Right(emptyCart);
    } catch (e) {
      return Left(ServerFailure('Failed to get cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cart>> addToCart(
    String userId,
    Product product,
    int quantity,
  ) async {
    try {
      // Get current cart
      final cartResult = await getUserCart(userId);
      if (cartResult.isLeft()) {
        return cartResult;
      }

      final currentCart =
          cartResult.getOrElse(() => CartModel.empty(userId)) as CartModel;

      // Check if product already exists in cart
      final existingItemIndex = currentCart.items.indexWhere(
        (item) => item.product.id == product.id,
      );

      List<CartItemModel> updatedItems = List.from(
        currentCart.items.cast<CartItemModel>(),
      );

      if (existingItemIndex != -1) {
        // Update existing item quantity
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] =
            existingItem.copyWith(
                  quantity: existingItem.quantity + quantity,
                  updatedAt: DateTime.now(),
                )
                as CartItemModel;
      } else {
        // Add new item
        final newItem = CartItemModel(
          id: const Uuid().v4(),
          product: product as ProductModel,
          quantity: quantity,
          addedAt: DateTime.now(),
        );
        updatedItems.add(newItem);
      }

      // Create updated cart
      final updatedCart =
          currentCart.copyWith(
                items: updatedItems.cast<CartItem>(),
                updatedAt: DateTime.now(),
              )
              as CartModel;

      // Recalculate totals
      final finalCart = CartModel.calculateTotals(updatedCart);

      // Save to cache
      await localDataSource.cacheCart(userId, finalCart);

      // Save to remote if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.saveCart(userId, finalCart);
        } catch (e) {
          print('Failed to sync cart to remote: $e');
          // Continue with local operation
        }
      }

      return Right(finalCart);
    } catch (e) {
      return Left(ServerFailure('Failed to add to cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeFromCart(
    String userId,
    String itemId,
  ) async {
    try {
      // Get current cart
      final cartResult = await getUserCart(userId);
      if (cartResult.isLeft()) {
        return cartResult;
      }

      final currentCart =
          cartResult.getOrElse(() => CartModel.empty(userId)) as CartModel;

      // Remove item
      final updatedItems = currentCart.items
          .cast<CartItemModel>()
          .where((item) => item.id != itemId)
          .toList();

      // Create updated cart
      final updatedCart =
          currentCart.copyWith(
                items: updatedItems.cast<CartItem>(),
                updatedAt: DateTime.now(),
              )
              as CartModel;

      // Recalculate totals
      final finalCart = CartModel.calculateTotals(updatedCart);

      // Save to cache
      await localDataSource.cacheCart(userId, finalCart);

      // Save to remote if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.saveCart(userId, finalCart);
        } catch (e) {
          print('Failed to sync cart to remote: $e');
        }
      }

      return Right(finalCart);
    } catch (e) {
      return Left(ServerFailure('Failed to remove from cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cart>> updateCartItemQuantity(
    String userId,
    String itemId,
    int quantity,
  ) async {
    try {
      if (quantity <= 0) {
        return removeFromCart(userId, itemId);
      }

      // Get current cart
      final cartResult = await getUserCart(userId);
      if (cartResult.isLeft()) {
        return cartResult;
      }

      final currentCart =
          cartResult.getOrElse(() => CartModel.empty(userId)) as CartModel;

      // Update item quantity
      final updatedItems = currentCart.items.cast<CartItemModel>().map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: quantity, updatedAt: DateTime.now())
              as CartItemModel;
        }
        return item;
      }).toList();

      // Create updated cart
      final updatedCart =
          currentCart.copyWith(
                items: updatedItems.cast<CartItem>(),
                updatedAt: DateTime.now(),
              )
              as CartModel;

      // Recalculate totals
      final finalCart = CartModel.calculateTotals(updatedCart);

      // Save to cache
      await localDataSource.cacheCart(userId, finalCart);

      // Save to remote if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.saveCart(userId, finalCart);
        } catch (e) {
          print('Failed to sync cart to remote: $e');
        }
      }

      return Right(finalCart);
    } catch (e) {
      return Left(ServerFailure('Failed to update cart item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cart>> clearCart(String userId) async {
    try {
      final emptyCart = CartModel.empty(userId);

      // Save to cache
      await localDataSource.cacheCart(userId, emptyCart);

      // Save to remote if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.saveCart(userId, emptyCart);
        } catch (e) {
          print('Failed to sync cart to remote: $e');
        }
      }

      return Right(emptyCart);
    } catch (e) {
      return Left(ServerFailure('Failed to clear cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cart>> applyCoupon(
    String userId,
    String couponCode,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final updatedCart = await remoteDataSource.applyCoupon(
          userId,
          couponCode,
        );
        await localDataSource.cacheCart(userId, updatedCart);
        return Right(updatedCart);
      } else {
        return Left(NetworkFailure('No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to apply coupon: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeCoupon(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        final updatedCart = await remoteDataSource.removeCoupon(userId);
        await localDataSource.cacheCart(userId, updatedCart);
        return Right(updatedCart);
      } else {
        return Left(NetworkFailure('No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to remove coupon: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveForLater(
    String userId,
    String itemId,
  ) async {
    try {
      // For now, just remove from cart
      // In a real app, this would move to a "saved for later" collection
      await removeFromCart(userId, itemId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to save for later: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveAllForLater(String userId) async {
    try {
      // For now, just clear cart
      // In a real app, this would move all items to "saved for later"
      await clearCart(userId);
      return const Right(unit);
    } catch (e) {
      return Left(
        ServerFailure('Failed to save all for later: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Cart> watchUserCart(String userId) {
    try {
      // Create a StreamController to manage the cart stream
      final controller = StreamController<Cart>();

      // Initial load from local cache
      localDataSource.getCachedCart(userId).then((localCart) {
        if (!controller.isClosed) {
          controller.add(localCart ?? CartModel.empty(userId));
        }
      });

      // Check network connectivity
      networkInfo.isConnected.then((isConnected) {
        if (isConnected) {
          // If connected, subscribe to remote updates
          final subscription = remoteDataSource
              .watchCart(userId)
              .listen(
                (remoteCart) {
                  if (remoteCart != null && !controller.isClosed) {
                    // Cache the remote cart locally
                    localDataSource.cacheCart(userId, remoteCart);
                    controller.add(remoteCart);
                  }
                },
                onError: (_) {
                  // On error, do nothing (we already added local cache data)
                },
              );

          // Clean up subscription when controller is closed
          controller.onCancel = () {
            subscription.cancel();
          };
        }
      });

      return controller.stream;
    } catch (e) {
      return Stream.value(CartModel.empty(userId));
    }
  }

  @override
  Future<Either<Failure, Cart>> syncCart(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        final localCart = await localDataSource.getCachedCart(userId);
        if (localCart != null) {
          final syncedCart = await remoteDataSource.saveCart(userId, localCart);
          await localDataSource.cacheCart(userId, syncedCart);
          return Right(syncedCart);
        }
      }
      return Left(NetworkFailure('No internet connection or no local cart'));
    } catch (e) {
      return Left(ServerFailure('Failed to sync cart: ${e.toString()}'));
    }
  }
}
