import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';
import '../entities/user_preferences.dart';
import '../entities/address.dart';
import '../entities/payment_method.dart';

/// Profile integration service for coordinating profile with other features
/// Following specifications from FEATURES_DOCUMENTATION.md - Integrate profile functionality
/// with existing features like wishlist, cart, and user-specific data
class ProfileIntegrationService {
  final ProfileRepository profileRepository;

  ProfileIntegrationService({required this.profileRepository});

  /// Sync user preferences with app state
  Future<Either<Failure, void>> syncUserPreferences(String userId) async {
    try {
      final preferencesResult = await profileRepository.getUserPreferences(
        userId,
      );

      return preferencesResult.fold((failure) => Left(failure), (
        preferences,
      ) async {
        // Apply preferences to app state
        await _applyLanguagePreference(preferences.language);
        await _applyCurrencyPreference(preferences.currency);
        await _applyThemePreference(preferences.theme);
        await _applyNotificationPreferences(preferences);

        return const Right(null);
      });
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get user's default shipping address
  Future<Either<Failure, Address?>> getDefaultShippingAddress(
    String userId,
  ) async {
    final addressesResult = await profileRepository.getUserAddresses(userId);

    return addressesResult.fold((failure) => Left(failure), (addresses) {
      final defaultAddress = addresses
          .where((addr) => addr.isDefault)
          .firstOrNull;
      return Right(defaultAddress);
    });
  }

  /// Get user's default payment method
  Future<Either<Failure, PaymentMethod?>> getDefaultPaymentMethod(
    String userId,
  ) async {
    final paymentMethodsResult = await profileRepository.getUserPaymentMethods(
      userId,
    );

    return paymentMethodsResult.fold((failure) => Left(failure), (methods) {
      final defaultMethod = methods
          .where((method) => method.isDefault)
          .firstOrNull;
      return Right(defaultMethod);
    });
  }

  /// Calculate profile completion score
  Future<Either<Failure, double>> calculateProfileCompletion(
    String userId,
  ) async {
    try {
      // Get user profile
      final userResult = await profileRepository.getUserProfile(userId);
      if (userResult.isLeft()) {
        return Left(userResult.fold((l) => l, (r) => throw Exception()));
      }
      final user = userResult.getOrElse(() => throw Exception());

      if (user == null) {
        return const Right(0.0);
      }

      // Get addresses
      final addressesResult = await profileRepository.getUserAddresses(userId);
      final addresses = addressesResult.getOrElse(() => []);

      // Get payment methods
      final paymentMethodsResult = await profileRepository
          .getUserPaymentMethods(userId);
      final paymentMethods = paymentMethodsResult.getOrElse(() => []);

      // Get preferences
      final preferencesResult = await profileRepository.getUserPreferences(
        userId,
      );
      final preferences = preferencesResult.getOrElse(
        () => UserPreferences(userId: userId, createdAt: DateTime.now()),
      );

      // Calculate completion score
      double score = 0.0;
      int totalFields = 8;

      // Basic profile fields (4 points)
      if (user.displayName?.isNotEmpty == true) score += 1;
      if (user.email.isNotEmpty) score += 1;
      if (user.phoneNumber?.isNotEmpty == true) score += 1;
      if (user.photoUrl?.isNotEmpty == true) score += 1;

      // Address (1 point)
      if (addresses.isNotEmpty) score += 1;

      // Payment method (1 point)
      if (paymentMethods.isNotEmpty) score += 1;

      // Email verification (1 point)
      if (user.isEmailVerified) score += 1;

      // Preferences setup (1 point)
      if (preferences.favoriteCategories.isNotEmpty ||
          preferences.preferredBrands.isNotEmpty)
        score += 1;

      return Right(score / totalFields);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get user onboarding status
  Future<Either<Failure, Map<String, bool>>> getUserOnboardingStatus(
    String userId,
  ) async {
    try {
      final completionResult = await calculateProfileCompletion(userId);
      if (completionResult.isLeft()) {
        return Left(completionResult.fold((l) => l, (r) => throw Exception()));
      }

      final userResult = await profileRepository.getUserProfile(userId);
      final user = userResult.getOrElse(() => null);

      final addressesResult = await profileRepository.getUserAddresses(userId);
      final addresses = addressesResult.getOrElse(() => []);

      final paymentMethodsResult = await profileRepository
          .getUserPaymentMethods(userId);
      final paymentMethods = paymentMethodsResult.getOrElse(() => []);

      return Right({
        'profileCreated': user != null,
        'emailVerified': user?.isEmailVerified ?? false,
        'phoneAdded': user?.phoneNumber?.isNotEmpty == true,
        'photoAdded': user?.photoUrl?.isNotEmpty == true,
        'addressAdded': addresses.isNotEmpty,
        'paymentMethodAdded': paymentMethods.isNotEmpty,
        'preferencesSet': false, // TODO: Implement preferences checking
        'firstOrderPlaced': false, // TODO: Implement order checking
        'wishlistUsed': false, // TODO: Implement wishlist checking
        'reviewWritten': false, // TODO: Implement review checking
      });
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get personalized recommendations for the user
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getPersonalizedRecommendations(String userId) async {
    try {
      final onboardingResult = await getUserOnboardingStatus(userId);
      if (onboardingResult.isLeft()) {
        return Left(onboardingResult.fold((l) => l, (r) => throw Exception()));
      }

      final onboardingStatus = onboardingResult.getOrElse(() => {});
      final recommendations = <Map<String, dynamic>>[];

      // Profile completion recommendations
      if (onboardingStatus['emailVerified'] != true) {
        recommendations.add({
          'type': 'verify_email',
          'priority': 'high',
          'title': 'Verify Your Email',
          'description':
              'Verify your email to secure your account and receive important updates.',
          'action': 'Verify Now',
          'route': '/profile/verify-email',
        });
      }

      if (onboardingStatus['addressAdded'] != true) {
        recommendations.add({
          'type': 'add_address',
          'priority': 'high',
          'title': 'Add Delivery Address',
          'description': 'Add your address to enable fast and easy delivery.',
          'action': 'Add Address',
          'route': '/profile/addresses/add',
        });
      }

      if (onboardingStatus['paymentMethodAdded'] != true) {
        recommendations.add({
          'type': 'add_payment',
          'priority': 'medium',
          'title': 'Add Payment Method',
          'description': 'Add a payment method for quick and secure checkout.',
          'action': 'Add Payment',
          'route': '/profile/payment-methods/add',
        });
      }

      // Shopping recommendations
      if (onboardingStatus['firstOrderPlaced'] != true) {
        recommendations.add({
          'type': 'first_order',
          'priority': 'medium',
          'title': 'Place Your First Order',
          'description':
              'Explore our automotive parts and place your first order.',
          'action': 'Shop Now',
          'route': '/products',
        });
      }

      if (onboardingStatus['wishlistUsed'] != true) {
        recommendations.add({
          'type': 'use_wishlist',
          'priority': 'low',
          'title': 'Save Items to Wishlist',
          'description': 'Keep track of products you\'re interested in.',
          'action': 'Learn More',
          'route': '/wishlist',
        });
      }

      return Right(recommendations);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Update user activity tracking
  Future<Either<Failure, void>> trackUserActivity(
    String userId,
    String activity,
    Map<String, dynamic> data,
  ) async {
    try {
      await profileRepository.trackPreferenceChange(userId, activity, data);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Sync profile data across features
  Future<Either<Failure, void>> syncProfileData(String userId) async {
    try {
      // Refresh profile cache
      await profileRepository.refreshProfileCache(userId);

      // TODO: Sync with other features
      // - Update cart with user preferences
      // - Sync wishlist data
      // - Update recently viewed products
      // - Sync notification preferences

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // Private helper methods
  Future<void> _applyLanguagePreference(String language) async {
    // TODO: Apply language preference to app
  }

  Future<void> _applyCurrencyPreference(String currency) async {
    // TODO: Apply currency preference to app
  }

  Future<void> _applyThemePreference(String theme) async {
    // TODO: Apply theme preference to app
  }

  Future<void> _applyNotificationPreferences(
    UserPreferences preferences,
  ) async {
    // TODO: Apply notification preferences to app
  }
}
