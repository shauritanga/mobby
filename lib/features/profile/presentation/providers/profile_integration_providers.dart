import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../vehicles/presentation/providers/vehicle_providers.dart';
import '../../../products/domain/entities/wishlist.dart';
import '../../../products/presentation/providers/user_product_providers.dart'
    as user_products;
import 'profile_providers.dart';

/// Profile integration providers for connecting profile with other features
/// Following specifications from FEATURES_DOCUMENTATION.md - Integrate profile functionality
/// with existing features like wishlist, cart, and user-specific data

// User-specific wishlist provider (returns product IDs)
final userWishlistProvider = FutureProvider<List<String>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return [];

  // Get wishlist products and extract IDs
  final wishlistProducts = await ref.watch(
    user_products.wishlistProductsProvider(currentUser.id).future,
  );
  return wishlistProducts.map((product) => product.id).toList();
});

// User wishlist with full product data (returns Wishlist object)
final userWishlistWithProductsProvider = FutureProvider<Wishlist>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) {
    return Wishlist(
      id: 'empty',
      userId: '',
      products: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Get wishlist products directly from the user product provider
  final wishlistProducts = await ref.watch(
    user_products.wishlistProductsProvider(currentUser.id).future,
  );

  return Wishlist(
    id: 'wishlist_${currentUser.id}',
    userId: currentUser.id,
    products: wishlistProducts,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
});

// User-specific cart provider
final userCartSummaryProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return {};

  // Get cart data for the current user
  final cartState = ref.watch(userCartProvider);
  return cartState.when(
    data: (cart) => {
      'items': cart.items,
      'total': cart.total,
      'itemCount': cart.itemCount,
    },
    loading: () => {},
    error: (error, stack) => {},
  );
});

// User-specific recently viewed products
final userRecentlyViewedProvider = FutureProvider<List<String>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return [];

  // Get recently viewed products and extract IDs
  final recentlyViewedProducts = await ref.watch(
    user_products.recentlyViewedProductsProvider(currentUser.id).future,
  );
  return recentlyViewedProducts.map((product) => product.id).toList();
});

// User profile completion status
final profileCompletionStatusProvider = Provider<Map<String, bool>>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) {
    return {
      'hasProfile': false,
      'hasAddress': false,
      'hasPaymentMethod': false,
      'hasVerifiedEmail': false,
      'hasPhoneNumber': false,
    };
  }

  final userAddressesAsync = ref.watch(userAddressesProvider(currentUser.id));
  final userPaymentMethodsAsync = ref.watch(
    userPaymentMethodsProvider(currentUser.id),
  );

  return {
    'hasProfile': currentUser.displayName?.isNotEmpty == true,
    'hasAddress': userAddressesAsync.when(
      data: (addresses) => addresses.isNotEmpty,
      loading: () => false,
      error: (error, stack) => false,
    ),
    'hasPaymentMethod': userPaymentMethodsAsync.when(
      data: (methods) => methods.isNotEmpty,
      loading: () => false,
      error: (error, stack) => false,
    ),
    'hasVerifiedEmail': currentUser.isEmailVerified,
    'hasPhoneNumber': currentUser.phoneNumber?.isNotEmpty == true,
  };
});

// User onboarding status
final userOnboardingStatusProvider = Provider<Map<String, bool>>((ref) {
  final completionStatus = ref.watch(profileCompletionStatusProvider);
  final currentUser = ref.watch(currentUserProvider).value;

  // Check if user has used wishlist
  bool wishlistUsed = false;
  if (currentUser != null) {
    final wishlistAsync = ref.watch(userWishlistProvider);
    wishlistUsed = wishlistAsync.when(
      data: (wishlist) => wishlist.isNotEmpty,
      loading: () => false,
      error: (error, stack) => false,
    );
  }

  return {
    'profileSetup': completionStatus['hasProfile'] == true,
    'addressAdded': completionStatus['hasAddress'] == true,
    'paymentAdded': completionStatus['hasPaymentMethod'] == true,
    'emailVerified': completionStatus['hasVerifiedEmail'] == true,
    'phoneAdded': completionStatus['hasPhoneNumber'] == true,
    'firstOrderPlaced':
        false, // Will be implemented when order system is available
    'wishlistUsed': wishlistUsed,
  };
});

// User activity summary
final userActivitySummaryProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return {};

  final addresses = await ref.watch(
    userAddressesProvider(currentUser.id).future,
  );
  final paymentMethods = await ref.watch(
    userPaymentMethodsProvider(currentUser.id).future,
  );
  final wishlist = await ref.watch(userWishlistProvider.future);
  final recentlyViewed = await ref.watch(userRecentlyViewedProvider.future);

  // Get vehicle-related data
  final vehicles = await ref.watch(userVehiclesProvider(currentUser.id).future);
  final expiredDocuments = await ref.watch(expiredDocumentsProvider.future);
  final expiringSoonDocuments = await ref.watch(
    expiringSoonDocumentsProvider.future,
  );

  return {
    'addressCount': addresses.length,
    'paymentMethodCount': paymentMethods.length,
    'wishlistCount': wishlist.length,
    'recentlyViewedCount': recentlyViewed.length,
    'vehicleCount': vehicles.length,
    'expiredDocumentsCount': expiredDocuments.length,
    'expiringSoonDocumentsCount': expiringSoonDocuments.length,
    'orderCount': 0, // Will be implemented when order system is available
    'reviewCount': 0, // Will be implemented when review system is available
    'memberSince': currentUser.createdAt,
    'lastActive': currentUser.updatedAt ?? currentUser.createdAt,
  };
});

// User preferences for shopping
final userShoppingPreferencesProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return {};

  final preferences = await ref.watch(
    userPreferencesProvider(currentUser.id).future,
  );

  return {
    'currency': preferences.currency,
    'language': preferences.language,
    'favoriteCategories': preferences.favoriteCategories,
    'preferredBrands': preferences.preferredBrands,
    'defaultAddressId': preferences.defaultAddressId,
    'defaultPaymentMethodId': preferences.defaultPaymentMethodId,
    'notificationPreferences': preferences.notificationPreferences,
  };
});

// User dashboard data
final userDashboardDataProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return {};

  final activitySummary = await ref.watch(userActivitySummaryProvider.future);
  final shoppingPreferences = await ref.watch(
    userShoppingPreferencesProvider.future,
  );
  final onboardingStatus = ref.watch(userOnboardingStatusProvider);
  final completionStatus = ref.watch(profileCompletionStatusProvider);

  // Calculate profile completion percentage
  final completedItems = completionStatus.values.where((v) => v == true).length;
  final totalItems = completionStatus.length;
  final completionPercentage = (completedItems / totalItems * 100).round();

  return {
    'user': {
      'id': currentUser.id,
      'name': currentUser.displayName ?? 'User',
      'email': currentUser.email,
      'photoUrl': currentUser.photoUrl,
      'isEmailVerified': currentUser.isEmailVerified,
      'memberSince': currentUser.createdAt,
    },
    'activity': activitySummary,
    'preferences': shoppingPreferences,
    'onboarding': onboardingStatus,
    'completion': {
      'percentage': completionPercentage,
      'status': completionStatus,
    },
    'quickActions': _getQuickActions(completionStatus, onboardingStatus),
    'recommendations': _getRecommendations(completionStatus, activitySummary),
  };
});

// Helper function to get quick actions based on user status
List<Map<String, dynamic>> _getQuickActions(
  Map<String, bool> completionStatus,
  Map<String, bool> onboardingStatus,
) {
  final actions = <Map<String, dynamic>>[];

  if (completionStatus['hasAddress'] != true) {
    actions.add({
      'type': 'add_address',
      'title': 'Add Address',
      'subtitle': 'Add your delivery address',
      'icon': 'add_location',
      'route': '/profile/addresses/add',
      'priority': 'high',
    });
  }

  if (completionStatus['hasPaymentMethod'] != true) {
    actions.add({
      'type': 'add_payment',
      'title': 'Add Payment Method',
      'subtitle': 'Add a payment method for easy checkout',
      'icon': 'add_card',
      'route': '/profile/payment-methods/add',
      'priority': 'high',
    });
  }

  if (completionStatus['hasVerifiedEmail'] != true) {
    actions.add({
      'type': 'verify_email',
      'title': 'Verify Email',
      'subtitle': 'Verify your email address',
      'icon': 'mark_email_read',
      'route': '/profile/verify-email',
      'priority': 'medium',
    });
  }

  if (!onboardingStatus['firstOrderPlaced']!) {
    actions.add({
      'type': 'browse_products',
      'title': 'Browse Products',
      'subtitle': 'Explore automotive parts and accessories',
      'icon': 'shopping_cart',
      'route': '/products',
      'priority': 'medium',
    });
  }

  // Vehicle-related quick actions
  actions.add({
    'type': 'add_vehicle',
    'title': 'Add Vehicle',
    'subtitle': 'Register your vehicle for better service',
    'icon': 'directions_car',
    'route': '/vehicles/add',
    'priority': 'medium',
  });

  actions.add({
    'type': 'vehicle_documents',
    'title': 'Vehicle Documents',
    'subtitle': 'Manage your vehicle documents',
    'icon': 'description',
    'route': '/vehicles',
    'priority': 'low',
  });

  return actions;
}

// Helper function to get recommendations based on user data
List<Map<String, dynamic>> _getRecommendations(
  Map<String, bool> completionStatus,
  Map<String, dynamic> activitySummary,
) {
  final recommendations = <Map<String, dynamic>>[];

  if (activitySummary['wishlistCount'] == 0) {
    recommendations.add({
      'type': 'use_wishlist',
      'title': 'Save Items to Wishlist',
      'subtitle': 'Keep track of products you like',
      'action': 'Learn More',
    });
  }

  if (activitySummary['orderCount'] == 0) {
    recommendations.add({
      'type': 'first_order',
      'title': 'Place Your First Order',
      'subtitle': 'Get started with automotive shopping',
      'action': 'Shop Now',
    });
  }

  if (activitySummary['reviewCount'] == 0 &&
      activitySummary['orderCount'] > 0) {
    recommendations.add({
      'type': 'write_review',
      'title': 'Write Product Reviews',
      'subtitle': 'Help other customers with your experience',
      'action': 'Write Review',
    });
  }

  return recommendations;
}

// Profile sync provider for keeping data in sync
final profileSyncProvider = Provider<Future<void>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return;

  // Refresh all profile-related data
  ref.invalidate(userProfileProvider(currentUser.id));
  ref.invalidate(userAddressesProvider(currentUser.id));
  ref.invalidate(userPaymentMethodsProvider(currentUser.id));
  ref.invalidate(userPreferencesProvider(currentUser.id));
  ref.invalidate(userWishlistProvider);
  ref.invalidate(userRecentlyViewedProvider);
});

// Profile analytics provider
final profileAnalyticsProvider =
    Provider.family<Future<void>, Map<String, dynamic>>((ref, event) async {
      final currentUser = ref.watch(currentUserProvider).value;
      if (currentUser == null) return;

      // Track profile-related events
      final repository = ref.watch(profileRepositoryProvider);
      await repository.trackPreferenceChange(
        currentUser.id,
        event['type'] ?? 'unknown',
        event['data'],
      );
    });
