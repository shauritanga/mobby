import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import 'product_providers.dart' as products;

// User-specific product data providers
final wishlistProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(products.productRepositoryProvider);
  return await repository.getWishlistProducts(userId);
});

final isInWishlistProvider =
    FutureProvider.family<bool, ({String userId, String productId})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(products.productRepositoryProvider);
      return await repository.isInWishlist(params.userId, params.productId);
    });

final recentlyViewedProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, userId) async {
      final repository = ref.watch(products.productRepositoryProvider);
      return await repository.getRecentlyViewedProducts(userId);
    });

// User's search history
final userSearchHistoryProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(products.productRepositoryProvider);
  return await repository.getSearchHistory();
});

// Check if products are in stock
final productsAvailabilityProvider =
    FutureProvider.family<Map<String, bool>, List<String>>((
      ref,
      productIds,
    ) async {
      final repository = ref.watch(products.productRepositoryProvider);
      return await repository.checkProductsAvailability(productIds);
    });

// Get products stock levels
final productsStockProvider =
    FutureProvider.family<Map<String, int>, List<String>>((
      ref,
      productIds,
    ) async {
      final repository = ref.watch(products.productRepositoryProvider);
      return await repository.getProductsStock(productIds);
    });

// Get multiple products by IDs (useful for cart, wishlist display)
final productsByIdsProvider =
    FutureProvider.family<List<Product>, List<String>>((ref, productIds) async {
      final repository = ref.watch(products.productRepositoryProvider);
      return await repository.getProductsByIds(productIds);
    });

// User action providers for wishlist operations
final addToWishlistProvider =
    Provider.family<Future<void>, ({String userId, String productId})>((
      ref,
      params,
    ) {
      final repository = ref.watch(products.productRepositoryProvider);
      return repository.addToWishlist(params.userId, params.productId);
    });

final removeFromWishlistProvider =
    Provider.family<Future<void>, ({String userId, String productId})>((
      ref,
      params,
    ) {
      final repository = ref.watch(products.productRepositoryProvider);
      return repository.removeFromWishlist(params.userId, params.productId);
    });

// User action providers for recently viewed
final addToRecentlyViewedProvider =
    Provider.family<Future<void>, ({String userId, String productId})>((
      ref,
      params,
    ) {
      final repository = ref.watch(products.productRepositoryProvider);
      return repository.addToRecentlyViewed(params.userId, params.productId);
    });

// Enhanced wishlist state notifier with repository integration
class WishlistManager extends StateNotifier<Set<String>> {
  final Ref ref;

  WishlistManager(this.ref) : super(<String>{});

  Future<void> addToWishlist(String userId, String productId) async {
    // Optimistically update local state
    state = {...state, productId};

    try {
      // Update repository
      await ref.read(
        addToWishlistProvider((userId: userId, productId: productId)),
      );
      // Invalidate wishlist provider to refresh data
      ref.invalidate(wishlistProductsProvider(userId));
    } catch (e) {
      // Revert optimistic update on error
      state = state.where((id) => id != productId).toSet();
      rethrow;
    }
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    // Optimistically update local state
    final previousState = state;
    state = state.where((id) => id != productId).toSet();

    try {
      // Update repository
      await ref.read(
        removeFromWishlistProvider((userId: userId, productId: productId)),
      );
      // Invalidate wishlist provider to refresh data
      ref.invalidate(wishlistProductsProvider(userId));
    } catch (e) {
      // Revert optimistic update on error
      state = previousState;
      rethrow;
    }
  }

  Future<void> toggleWishlist(String userId, String productId) async {
    if (state.contains(productId)) {
      await removeFromWishlist(userId, productId);
    } else {
      await addToWishlist(userId, productId);
    }
  }

  bool isInWishlist(String productId) {
    return state.contains(productId);
  }

  void clearWishlist() {
    state = <String>{};
  }

  // Backward compatible methods for local state management
  void addToWishlistLocal(String productId) {
    state = {...state, productId};
  }

  void removeFromWishlistLocal(String productId) {
    state = state.where((id) => id != productId).toSet();
  }

  void toggleWishlistLocal(String productId) {
    if (state.contains(productId)) {
      removeFromWishlistLocal(productId);
    } else {
      addToWishlistLocal(productId);
    }
  }

  // Load wishlist from repository
  Future<void> loadWishlist(String userId) async {
    try {
      final wishlistProducts = await ref.read(
        wishlistProductsProvider(userId).future,
      );
      state = wishlistProducts.map((product) => product.id).toSet();
    } catch (e) {
      // Handle error silently or log it
      state = <String>{};
    }
  }
}

final wishlistManagerProvider =
    StateNotifierProvider<WishlistManager, Set<String>>((ref) {
      return WishlistManager(ref);
    });

// Simple recently viewed state notifier
class RecentlyViewedManager extends StateNotifier<List<String>> {
  RecentlyViewedManager() : super(<String>[]);

  void addToRecentlyViewed(String productId) {
    final updatedList = [productId, ...state.where((id) => id != productId)];

    // Keep only last 20 items
    if (updatedList.length > 20) {
      updatedList.removeRange(20, updatedList.length);
    }

    state = updatedList;
  }

  void clearRecentlyViewed() {
    state = <String>[];
  }
}

final recentlyViewedManagerProvider =
    StateNotifierProvider<RecentlyViewedManager, List<String>>((ref) {
      return RecentlyViewedManager();
    });

// Simple analytics state notifier
class UserProductAnalytics extends StateNotifier<Map<String, dynamic>> {
  UserProductAnalytics()
    : super({
        'totalViews': 0,
        'totalSearches': 0,
        'favoriteCategories': <String>[],
        'favoriteBrands': <String>[],
      });

  void trackProductView(String productId) {
    final updatedAnalytics = Map<String, dynamic>.from(state);
    updatedAnalytics['totalViews'] = (updatedAnalytics['totalViews'] ?? 0) + 1;
    state = updatedAnalytics;
  }

  void trackSearch(String query) {
    final updatedAnalytics = Map<String, dynamic>.from(state);
    updatedAnalytics['totalSearches'] =
        (updatedAnalytics['totalSearches'] ?? 0) + 1;
    state = updatedAnalytics;
  }

  void clearAnalytics() {
    state = {
      'totalViews': 0,
      'totalSearches': 0,
      'favoriteCategories': <String>[],
      'favoriteBrands': <String>[],
    };
  }
}

final userProductAnalyticsProvider =
    StateNotifierProvider<UserProductAnalytics, Map<String, dynamic>>((ref) {
      return UserProductAnalytics();
    });

// Simple review manager
class UserReviewManager extends StateNotifier<List<String>> {
  UserReviewManager() : super(<String>[]);

  void addReview(String reviewId) {
    state = [reviewId, ...state];
  }

  void removeReview(String reviewId) {
    state = state.where((id) => id != reviewId).toList();
  }

  void clearUserReviews() {
    state = <String>[];
  }
}

final userReviewManagerProvider =
    StateNotifierProvider<UserReviewManager, List<String>>((ref) {
      return UserReviewManager();
    });

// Utility Extensions for User Product Providers
extension UserProductProvidersExtension on WidgetRef {
  /// Clear all user-specific data when user logs out
  void clearUserProductData() {
    read(wishlistManagerProvider.notifier).clearWishlist();
    read(recentlyViewedManagerProvider.notifier).clearRecentlyViewed();
    read(userProductAnalyticsProvider.notifier).clearAnalytics();
    read(userReviewManagerProvider.notifier).clearUserReviews();
  }

  /// Add product to wishlist with optimistic updates (backward compatible)
  void toggleWishlist(String productId) {
    // Use local state management for backward compatibility
    read(wishlistManagerProvider.notifier).toggleWishlistLocal(productId);
  }

  /// Add product to wishlist with repository integration
  Future<void> toggleWishlistWithUser(String userId, String productId) async {
    await read(
      wishlistManagerProvider.notifier,
    ).toggleWishlist(userId, productId);
  }

  /// Track product view with analytics
  void viewProduct(String productId) {
    read(userProductAnalyticsProvider.notifier).trackProductView(productId);
    read(recentlyViewedManagerProvider.notifier).addToRecentlyViewed(productId);
  }

  /// Track search with analytics
  void searchProducts(String query) {
    read(userProductAnalyticsProvider.notifier).trackSearch(query);
  }

  /// Check if product is in wishlist
  bool isProductInWishlist(String productId) {
    final wishlistState = read(wishlistManagerProvider);
    return wishlistState.contains(productId);
  }

  /// Get wishlist count
  int getWishlistCount() {
    final wishlistState = read(wishlistManagerProvider);
    return wishlistState.length;
  }

  /// Get recently viewed count
  int getRecentlyViewedCount() {
    final recentlyViewedState = read(recentlyViewedManagerProvider);
    return recentlyViewedState.length;
  }
}
