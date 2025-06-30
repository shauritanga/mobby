import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/manage_addresses_usecase.dart';
import '../../domain/usecases/manage_payments_usecase.dart';
import '../../domain/services/profile_integration_service.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/user_preferences.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../../auth/domain/entities/user.dart' as auth;

/// Profile providers setup following Riverpod pattern
/// As specified in FEATURES_DOCUMENTATION.md

// Core dependencies
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Data sources
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return ProfileLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

// Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
    localDataSource: ref.watch(profileLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Use cases
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final getUserAddressesUseCaseProvider = Provider<GetUserAddressesUseCase>((
  ref,
) {
  return GetUserAddressesUseCase(ref.watch(profileRepositoryProvider));
});

final addAddressUseCaseProvider = Provider<AddAddressUseCase>((ref) {
  return AddAddressUseCase(ref.watch(profileRepositoryProvider));
});

final updateAddressUseCaseProvider = Provider<UpdateAddressUseCase>((ref) {
  return UpdateAddressUseCase(ref.watch(profileRepositoryProvider));
});

final deleteAddressUseCaseProvider = Provider<DeleteAddressUseCase>((ref) {
  return DeleteAddressUseCase(ref.watch(profileRepositoryProvider));
});

final setDefaultAddressUseCaseProvider = Provider<SetDefaultAddressUseCase>((
  ref,
) {
  return SetDefaultAddressUseCase(ref.watch(profileRepositoryProvider));
});

final getUserPaymentMethodsUseCaseProvider =
    Provider<GetUserPaymentMethodsUseCase>((ref) {
      return GetUserPaymentMethodsUseCase(ref.watch(profileRepositoryProvider));
    });

final addPaymentMethodUseCaseProvider = Provider<AddPaymentMethodUseCase>((
  ref,
) {
  return AddPaymentMethodUseCase(ref.watch(profileRepositoryProvider));
});

final updatePaymentMethodUseCaseProvider = Provider<UpdatePaymentMethodUseCase>(
  (ref) {
    return UpdatePaymentMethodUseCase(ref.watch(profileRepositoryProvider));
  },
);

final deletePaymentMethodUseCaseProvider = Provider<DeletePaymentMethodUseCase>(
  (ref) {
    return DeletePaymentMethodUseCase(ref.watch(profileRepositoryProvider));
  },
);

final setDefaultPaymentMethodUseCaseProvider =
    Provider<SetDefaultPaymentMethodUseCase>((ref) {
      return SetDefaultPaymentMethodUseCase(
        ref.watch(profileRepositoryProvider),
      );
    });

// Profile Integration Service
final profileIntegrationServiceProvider = Provider<ProfileIntegrationService>((
  ref,
) {
  return ProfileIntegrationService(
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

// Profile data providers
final userProfileProvider = FutureProvider.family<auth.User?, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getUserProfile(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});

final userAddressesProvider = FutureProvider.family<List<Address>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getUserAddresses(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (addresses) => addresses,
  );
});

final userPaymentMethodsProvider =
    FutureProvider.family<List<PaymentMethod>, String>((ref, userId) async {
      final repository = ref.watch(profileRepositoryProvider);
      final result = await repository.getUserPaymentMethods(userId);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (paymentMethods) => paymentMethods,
      );
    });

final userPreferencesProvider = FutureProvider.family<UserPreferences, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getUserPreferences(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (preferences) => preferences,
  );
});

// Default address provider
final defaultAddressProvider = FutureProvider.family<Address?, String>((
  ref,
  userId,
) async {
  final addresses = await ref.watch(userAddressesProvider(userId).future);
  return addresses.where((address) => address.isDefault).firstOrNull;
});

// Default payment method provider
final defaultPaymentMethodProvider =
    FutureProvider.family<PaymentMethod?, String>((ref, userId) async {
      final paymentMethods = await ref.watch(
        userPaymentMethodsProvider(userId).future,
      );
      return paymentMethods.where((method) => method.isDefault).firstOrNull;
    });

// Profile analytics providers
final profileViewProvider = Provider.family<Future<void>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository
      .trackProfileView(userId)
      .then(
        (result) => result.fold(
          (failure) => throw Exception(failure.message),
          (success) => success,
        ),
      );
});

final preferenceChangeProvider =
    Provider.family<
      Future<void>,
      ({String userId, String preference, dynamic value})
    >((ref, params) {
      final repository = ref.watch(profileRepositoryProvider);
      return repository
          .trackPreferenceChange(params.userId, params.preference, params.value)
          .then(
            (result) => result.fold(
              (failure) => throw Exception(failure.message),
              (success) => success,
            ),
          );
    });

// Cache management providers
final refreshProfileCacheProvider = Provider.family<Future<void>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository
      .refreshProfileCache(userId)
      .then(
        (result) => result.fold(
          (failure) => throw Exception(failure.message),
          (success) => success,
        ),
      );
});

final clearProfileCacheProvider = Provider.family<Future<void>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository
      .clearProfileCache(userId)
      .then(
        (result) => result.fold(
          (failure) => throw Exception(failure.message),
          (success) => success,
        ),
      );
});

// Data export/import providers
final exportUserDataProvider =
    Provider.family<Future<Map<String, dynamic>>, String>((ref, userId) {
      final repository = ref.watch(profileRepositoryProvider);
      return repository
          .exportUserData(userId)
          .then(
            (result) => result.fold(
              (failure) => throw Exception(failure.message),
              (data) => data,
            ),
          );
    });

final importUserDataProvider =
    Provider.family<Future<void>, ({String userId, Map<String, dynamic> data})>(
      (ref, params) {
        final repository = ref.watch(profileRepositoryProvider);
        return repository
            .importUserData(params.userId, params.data)
            .then(
              (result) => result.fold(
                (failure) => throw Exception(failure.message),
                (success) => success,
              ),
            );
      },
    );

// Utility providers for profile management
final hasDefaultAddressProvider = Provider.family<bool, String>((ref, userId) {
  final addressesAsync = ref.watch(userAddressesProvider(userId));
  return addressesAsync.when(
    data: (addresses) => addresses.any((address) => address.isDefault),
    loading: () => false,
    error: (error, stack) => false,
  );
});

final hasDefaultPaymentMethodProvider = Provider.family<bool, String>((
  ref,
  userId,
) {
  final paymentMethodsAsync = ref.watch(userPaymentMethodsProvider(userId));
  return paymentMethodsAsync.when(
    data: (methods) => methods.any((method) => method.isDefault),
    loading: () => false,
    error: (error, stack) => false,
  );
});

final profileCompletionProvider = Provider.family<double, String>((
  ref,
  userId,
) {
  final userAsync = ref.watch(userProfileProvider(userId));
  final addressesAsync = ref.watch(userAddressesProvider(userId));
  final paymentMethodsAsync = ref.watch(userPaymentMethodsProvider(userId));

  return userAsync.when(
    data: (user) {
      if (user == null) return 0.0;

      double completion = 0.0;
      int totalFields = 6;

      // Basic profile fields (4 fields)
      if (user.displayName?.isNotEmpty == true) completion += 1;
      if (user.email.isNotEmpty) completion += 1;
      if (user.phoneNumber?.isNotEmpty == true) completion += 1;
      if (user.photoUrl?.isNotEmpty == true) completion += 1;

      // Address (1 field)
      addressesAsync.whenData((addresses) {
        if (addresses.isNotEmpty) completion += 1;
      });

      // Payment method (1 field)
      paymentMethodsAsync.whenData((methods) {
        if (methods.isNotEmpty) completion += 1;
      });

      return completion / totalFields;
    },
    loading: () => 0.0,
    error: (error, stack) => 0.0,
  );
});
