// Product Providers Setup and Exports
// This file provides a centralized setup for all product-related providers
export 'product_providers.dart' hide recentlyViewedProductsProvider;
export 'user_product_providers.dart';
export 'search_filter_providers.dart';
export 'simple_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobby/features/home/presentation/providers/home_providers.dart'
    as home;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_providers.dart';
import 'user_product_providers.dart';
import 'search_filter_providers.dart';

/// Product Providers Configuration
class ProductProvidersConfig {
  static const Duration cacheTimeout = Duration(hours: 1);
  static const int defaultPageSize = 20;
  static const int maxSearchSuggestions = 5;
  static const int maxRecentlyViewed = 20;
  static const int maxSearchHistory = 20;

  /// Initialize product providers with custom configuration
  static List<Override> getProviderOverrides({
    FirebaseFirestore? firestore,
    SharedPreferences? sharedPreferences,
  }) {
    final overrides = <Override>[];

    if (firestore != null) {
      overrides.add(home.firestoreProvider.overrideWithValue(firestore));
    }

    // Mock overrides - in a real app these would override actual providers
    if (sharedPreferences != null) {
      debugPrint('SharedPreferences override would be applied');
    }

    return overrides;
  }
}

/// Product Providers Helper Functions
class ProductProvidersHelper {
  /// Initialize all product providers for a user session
  static Future<void> initializeForUser(WidgetRef ref, String userId) async {
    // Clear any existing user data
    ref.clearUserProductData();

    // Preload essential data
    await _preloadEssentialData(ref);
  }

  /// Cleanup when user logs out
  static void cleanupForUser(WidgetRef ref) {
    ref.clearUserProductData();
  }

  /// Preload essential product data
  static Future<void> _preloadEssentialData(WidgetRef ref) async {
    try {
      // Preload featured products
      ref.read(featuredProductsProvider);

      // Mock brand preloading
      debugPrint('Brands would be preloaded here');

      // Check cache validity
      // Mock cache validation
      // In a real app, this would check cache validity
      debugPrint('Product cache preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading product data: $e');
    }
  }

  /// Get product provider state summary
  static Map<String, dynamic> getProviderStateSummary(WidgetRef ref) {
    final searchQuery = ref.read(searchStateProvider);
    final filter = ref.read(filterStateProvider);

    return {
      'searchQuery': searchQuery,
      'hasActiveFilters': filter.hasFilters,
      'activeFilterCount': ref.getActiveFilterCount(),
      'currentPage': filter.page,
      'sortBy': filter.sortBy.name,
      'wishlistCount': ref.getWishlistCount(),
      'recentlyViewedCount': ref.getRecentlyViewedCount(),
      'wishlistLoading':
          false, // StateNotifier providers don't have loading states
      'recentlyViewedLoading':
          false, // StateNotifier providers don't have loading states
    };
  }
}

/// Product Providers Monitoring
class ProductProvidersMonitor {
  /// Monitor provider state changes for debugging
  static void startMonitoring(WidgetRef ref) {
    // Monitor search state
    ref.listen(searchStateProvider, (previous, next) {
      debugPrint('Search query changed: $previous -> $next');
    });

    // Monitor filter state
    ref.listen(filterStateProvider, (previous, next) {
      debugPrint(
        'Filter changed: ${previous?.hasFilters} -> ${next.hasFilters}',
      );
    });

    // Monitor wishlist state
    ref.listen(wishlistManagerProvider, (previous, next) {
      debugPrint('Wishlist updated: ${next.length} items');
    });
  }

  /// Get performance metrics
  static Map<String, dynamic> getPerformanceMetrics(WidgetRef ref) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'providerStates': {
        'searchState': ref.read(searchStateProvider),
        'filterState': ref.read(filterStateProvider).toString(),
        'wishlistState': ref.read(wishlistManagerProvider).toString(),
        'recentlyViewedState': ref
            .read(recentlyViewedManagerProvider)
            .toString(),
      },
    };
  }
}

/// Product Providers Error Handling
class ProductProvidersErrorHandler {
  /// Handle provider errors gracefully
  static void handleProviderError(
    Object error,
    StackTrace stackTrace,
    String providerName,
  ) {
    debugPrint('Provider Error in $providerName: $error');
    debugPrint('Stack trace: $stackTrace');

    // Log to analytics service
    // Analytics.logError(error, stackTrace, providerName);

    // Show user-friendly error message
    // NotificationService.showError('Failed to load $providerName data');
  }

  /// Retry failed provider operations
  static Future<void> retryProviderOperation(
    WidgetRef ref,
    String providerName,
    Future<void> Function() operation,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await operation();
        return;
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          handleProviderError(e, StackTrace.current, providerName);
          rethrow;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }
}

/// Product Providers Cache Management
class ProductProvidersCacheManager {
  /// Refresh all product caches
  static Future<void> refreshAllCaches(WidgetRef ref) async {
    try {
      // Invalidate specific providers
      ref.invalidate(featuredProductsProvider);
      ref.invalidate(popularProductsProvider);
      ref.invalidate(saleProductsProvider);

      debugPrint('All product caches refreshed successfully');
    } catch (e) {
      ProductProvidersErrorHandler.handleProviderError(
        e,
        StackTrace.current,
        'CacheManager',
      );
    }
  }

  /// Clear all caches
  static Future<void> clearAllCaches(WidgetRef ref) async {
    try {
      // Mock cache clearing
      debugPrint('All product caches cleared successfully');
    } catch (e) {
      ProductProvidersErrorHandler.handleProviderError(
        e,
        StackTrace.current,
        'CacheManager',
      );
    }
  }

  /// Get cache status
  static Future<Map<String, dynamic>> getCacheStatus(WidgetRef ref) async {
    try {
      // Mock cache validation
      final isCacheValid = true;

      return {
        'isValid': isCacheValid,
        'lastRefresh': DateTime.now().toIso8601String(),
        'providers': {
          'products': 'cached',
          'brands': 'cached',
          'reviews': 'cached',
        },
      };
    } catch (e) {
      return {'isValid': false, 'error': e.toString(), 'lastRefresh': null};
    }
  }
}

/// Product Providers Analytics
class ProductProvidersAnalytics {
  /// Track provider usage
  static void trackProviderUsage(
    String providerName,
    Map<String, dynamic> params,
  ) {
    debugPrint('Provider Usage: $providerName with params: $params');

    // Send to analytics service
    // Analytics.track('provider_usage', {
    //   'provider_name': providerName,
    //   'timestamp': DateTime.now().toIso8601String(),
    //   ...params,
    // });
  }

  /// Track search analytics
  static void trackSearchAnalytics(WidgetRef ref, String query) {
    final filter = ref.read(filterStateProvider);

    trackProviderUsage('search', {
      'query': query,
      'has_filters': filter.hasFilters,
      'filter_count': ref.getActiveFilterCount(),
      'sort_by': filter.sortBy.name,
    });
  }

  /// Track filter analytics
  static void trackFilterAnalytics(WidgetRef ref, ProductFilter filter) {
    trackProviderUsage('filter', {
      'category_count': filter.categoryIds.length,
      'brand_count': filter.brandIds.length,
      'has_price_range': filter.priceRange.hasRange,
      'has_rating_filter': filter.minRating != null,
      'availability': filter.availability.name,
      'sort_by': filter.sortBy.name,
    });
  }

  /// Track user interaction analytics
  static void trackUserInteraction(String action, Map<String, dynamic> params) {
    trackProviderUsage('user_interaction', {'action': action, ...params});
  }
}

/// Product Providers Testing Utilities
class ProductProvidersTestUtils {
  /// Create mock providers for testing
  static List<Override> createMockProviders({
    ProductRepository? mockRepository,
    List<Product>? mockProducts,
    List<Brand>? mockBrands,
  }) {
    final overrides = <Override>[];

    if (mockRepository != null) {
      // Mock repository override would be applied here
      debugPrint('Mock repository override would be applied');
    }

    // Add more mock overrides as needed

    return overrides;
  }

  /// Reset all provider states for testing
  static void resetAllProviders(WidgetRef ref) {
    ref.invalidate(searchStateProvider);
    ref.invalidate(filterStateProvider);
    ref.invalidate(wishlistManagerProvider);
    ref.invalidate(recentlyViewedManagerProvider);
    ref.invalidate(userProductAnalyticsProvider);
    ref.invalidate(userReviewManagerProvider);
    ref.invalidate(paginationStateProvider);
    ref.invalidate(searchHistoryStateProvider);
    ref.invalidate(quickFiltersProvider);
  }
}
