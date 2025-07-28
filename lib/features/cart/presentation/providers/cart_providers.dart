import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_item_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/apply_coupon_usecase.dart';
import '../../domain/usecases/watch_cart_usecase.dart';
import '../../data/datasources/cart_local_datasource.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';

// Data source providers
final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  return CartRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  return CartLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

// Repository provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    remoteDataSource: ref.read(cartRemoteDataSourceProvider),
    localDataSource: ref.read(cartLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use case providers
final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  return AddToCartUseCase(ref.read(cartRepositoryProvider));
});

final removeFromCartUseCaseProvider = Provider<RemoveFromCartUseCase>((ref) {
  return RemoveFromCartUseCase(ref.read(cartRepositoryProvider));
});

final updateCartItemUseCaseProvider = Provider<UpdateCartItemUseCase>((ref) {
  return UpdateCartItemUseCase(ref.read(cartRepositoryProvider));
});

final getCartUseCaseProvider = Provider<GetCartUseCase>((ref) {
  return GetCartUseCase(ref.read(cartRepositoryProvider));
});

final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  return ClearCartUseCase(ref.read(cartRepositoryProvider));
});

final applyCouponUseCaseProvider = Provider<ApplyCouponUseCase>((ref) {
  return ApplyCouponUseCase(ref.read(cartRepositoryProvider));
});

final watchCartUseCaseProvider = Provider<WatchCartUseCase>((ref) {
  return WatchCartUseCase(ref.read(cartRepositoryProvider));
});

// Main cart provider - gets cart for current user
final userCartProvider = FutureProvider<Cart>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) {
    throw Exception('User not authenticated');
  }

  final getCartUseCase = ref.read(getCartUseCaseProvider);
  final result = await getCartUseCase(GetCartParams(userId: currentUser.id));

  return result.fold(
    (failure) => throw Exception(failure.message),
    (cart) => cart,
  );
});

// Cart stream provider - watches cart changes for current user
final userCartStreamProvider = StreamProvider<Cart>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) {
    return Stream.error('User not authenticated');
  }

  final watchCartUseCase = ref.read(watchCartUseCaseProvider);
  return watchCartUseCase(currentUser.id);
});

// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cartAsync = ref.watch(userCartProvider);
  return cartAsync.when(
    data: (cart) => cart.itemCount,
    loading: () => 0,
    error: (error, stack) => 0,
  );
});

// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  final cartAsync = ref.watch(userCartProvider);
  return cartAsync.when(
    data: (cart) => cart.total,
    loading: () => 0.0,
    error: (error, stack) => 0.0,
  );
});

// Cart actions extension
extension CartActions on WidgetRef {
  Future<void> addToCart(Product product, int quantity) async {
    final currentUser = read(currentUserProvider).value;
    if (currentUser == null) return;

    final addToCartUseCase = read(addToCartUseCaseProvider);
    final result = await addToCartUseCase(
      AddToCartParams(
        userId: currentUser.id,
        product: product,
        quantity: quantity,
      ),
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (cart) => invalidate(userCartProvider),
    );
  }

  Future<void> removeFromCart(String itemId) async {
    final currentUser = read(currentUserProvider).value;
    if (currentUser == null) return;

    final removeFromCartUseCase = read(removeFromCartUseCaseProvider);
    final result = await removeFromCartUseCase(
      RemoveFromCartParams(userId: currentUser.id, itemId: itemId),
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (cart) => invalidate(userCartProvider),
    );
  }

  Future<void> updateCartItemQuantity(String itemId, int quantity) async {
    final currentUser = read(currentUserProvider).value;
    if (currentUser == null) return;

    final updateCartItemUseCase = read(updateCartItemUseCaseProvider);
    final result = await updateCartItemUseCase(
      UpdateCartItemParams(
        userId: currentUser.id,
        itemId: itemId,
        quantity: quantity,
      ),
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (cart) => invalidate(userCartProvider),
    );
  }

  Future<void> clearCart() async {
    final currentUser = read(currentUserProvider).value;
    if (currentUser == null) return;

    final clearCartUseCase = read(clearCartUseCaseProvider);
    final result = await clearCartUseCase(
      ClearCartParams(userId: currentUser.id),
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (cart) => invalidate(userCartProvider),
    );
  }

  Future<void> applyCoupon(String couponCode) async {
    final currentUser = read(currentUserProvider).value;
    if (currentUser == null) return;

    final applyCouponUseCase = read(applyCouponUseCaseProvider);
    final result = await applyCouponUseCase(
      ApplyCouponParams(userId: currentUser.id, couponCode: couponCode),
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (cart) => invalidate(userCartProvider),
    );
  }

  Future<void> removeCoupon() async {
    final currentUser = read(currentUserProvider).value;
    if (currentUser == null) return;

    final cartRepository = read(cartRepositoryProvider);
    final result = await cartRepository.removeCoupon(currentUser.id);

    result.fold(
      (failure) => throw Exception(failure.message),
      (cart) => invalidate(userCartProvider),
    );
  }

  Future<void> saveForLater(String itemId) async {
    final currentUser = read(currentUserProvider).value;
    if (currentUser == null) return;

    final cartRepository = read(cartRepositoryProvider);
    final result = await cartRepository.saveForLater(currentUser.id, itemId);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => invalidate(userCartProvider),
    );
  }

  Future<void> saveAllForLater() async {
    final currentUser = read(currentUserProvider).value;
    if (currentUser == null) return;

    final cartRepository = read(cartRepositoryProvider);
    final result = await cartRepository.saveAllForLater(currentUser.id);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => invalidate(userCartProvider),
    );
  }

  // Analytics tracking methods
  void trackCheckoutInitiated(Cart cart) {
    // In a real app, this would track analytics
    print(
      'Checkout initiated with ${cart.items.length} items, total: ${cart.total}',
    );
  }

  void trackPartialCheckout(Cart cart) {
    // In a real app, this would track analytics
    print(
      'Partial checkout with ${cart.items.length} items, total: ${cart.total}',
    );
  }

  void addRecommendedToCart(String productId) {
    // In a real app, this would fetch the product and add it to cart
    print('Adding recommended product $productId to cart');
  }
}
