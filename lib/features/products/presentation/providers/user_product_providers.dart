import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import 'product_providers.dart';

// Simple mock providers for user-specific product data
final wishlistProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  userId,
) async {
  final products = ref.watch(mockProductsProvider);
  await Future.delayed(const Duration(milliseconds: 300));
  // Return first product as mock wishlist item
  return products.take(1).toList();
});

final isInWishlistProvider =
    FutureProvider.family<bool, ({String userId, String productId})>((
      ref,
      params,
    ) async {
      await Future.delayed(const Duration(milliseconds: 100));
      // Mock: return true for first product
      return params.productId == '1';
    });

final recentlyViewedProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, userId) async {
      final products = ref.watch(mockProductsProvider);
      await Future.delayed(const Duration(milliseconds: 300));
      // Return all products as recently viewed
      return products;
    });

// Simple wishlist state notifier
class WishlistManager extends StateNotifier<Set<String>> {
  WishlistManager() : super(<String>{});

  void addToWishlist(String productId) {
    state = {...state, productId};
  }

  void removeFromWishlist(String productId) {
    state = state.where((id) => id != productId).toSet();
  }

  void toggleWishlist(String productId) {
    if (state.contains(productId)) {
      removeFromWishlist(productId);
    } else {
      addToWishlist(productId);
    }
  }

  bool isInWishlist(String productId) {
    return state.contains(productId);
  }

  void clearWishlist() {
    state = <String>{};
  }
}

final wishlistManagerProvider =
    StateNotifierProvider<WishlistManager, Set<String>>((ref) {
      return WishlistManager();
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

  /// Add product to wishlist with optimistic updates
  void toggleWishlist(String productId) {
    read(wishlistManagerProvider.notifier).toggleWishlist(productId);
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
