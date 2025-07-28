import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/user_preferences.dart';
import '../../../auth/domain/entities/user.dart';
import '../datasources/profile_remote_datasource.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/address_model.dart';
import '../models/payment_method_model.dart';
import '../models/user_preferences_model.dart';

/// Profile repository implementation following clean architecture
/// As specified in FEATURES_DOCUMENTATION.md with database abstraction layer
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.updateUserProfile(
          displayName: displayName,
          phoneNumber: phoneNumber,
          photoUrl: photoUrl,
        );

        // Cache updated user
        await localDataSource.cacheUserProfile(userModel);

        return Right(userModel.toEntity());
      } on AuthenticationException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User?>> getUserProfile(String userId) async {
    try {
      // Try to get from remote first if connected
      if (await networkInfo.isConnected) {
        try {
          final userModel = await remoteDataSource.getUserProfile(userId);
          if (userModel != null) {
            // Cache the user
            await localDataSource.cacheUserProfile(userModel);
            return Right(userModel.toEntity());
          }
        } catch (e) {
          // If remote fails, fall back to cache
        }
      }

      // Get from cache
      final cachedUser = await localDataSource.getCachedUserProfile(userId);
      return Right(cachedUser?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserAccount() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteUserAccount();

        // Clear all local cache
        // Note: We can't clear by userId since the user is deleted
        // This would need to be handled by the auth system

        return const Right(null);
      } on AuthenticationException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Address>>> getUserAddresses(String userId) async {
    try {
      // Try to get from remote first if connected
      if (await networkInfo.isConnected) {
        try {
          final addressModels = await remoteDataSource.getUserAddresses(userId);

          // Cache the addresses
          await localDataSource.cacheUserAddresses(userId, addressModels);

          return Right(addressModels.map((model) => model.toEntity()).toList());
        } catch (e) {
          // If remote fails, fall back to cache
        }
      }

      // Get from cache
      final cachedAddresses = await localDataSource.getCachedUserAddresses(
        userId,
      );
      if (cachedAddresses != null) {
        return Right(cachedAddresses.map((model) => model.toEntity()).toList());
      }

      return const Right([]);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Address>> getAddressById(String addressId) async {
    if (await networkInfo.isConnected) {
      try {
        final addressModel = await remoteDataSource.getAddressById(addressId);
        return Right(addressModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Address>> addAddress(Address address) async {
    if (await networkInfo.isConnected) {
      try {
        final addressModel = AddressModel.fromEntity(address);
        final result = await remoteDataSource.addAddress(addressModel);

        // Invalidate cache to force refresh
        await localDataSource.clearCachedUserAddresses(address.userId);

        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Address>> updateAddress(Address address) async {
    if (await networkInfo.isConnected) {
      try {
        final addressModel = AddressModel.fromEntity(address);
        final result = await remoteDataSource.updateAddress(addressModel);

        // Invalidate cache to force refresh
        await localDataSource.clearCachedUserAddresses(address.userId);

        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAddress(addressId);

        // Note: We'd need the userId to clear cache properly
        // This could be improved by passing userId or getting it from the address

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Address>> setDefaultAddress(
    String userId,
    String addressId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.setDefaultAddress(
          userId,
          addressId,
        );

        // Invalidate cache to force refresh
        await localDataSource.clearCachedUserAddresses(userId);

        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethod>>> getUserPaymentMethods(
    String userId,
  ) async {
    try {
      // Try to get from remote first if connected
      if (await networkInfo.isConnected) {
        try {
          final paymentMethodModels = await remoteDataSource
              .getUserPaymentMethods(userId);

          // Cache the payment methods
          await localDataSource.cacheUserPaymentMethods(
            userId,
            paymentMethodModels,
          );

          return Right(
            paymentMethodModels.map((model) => model.toEntity()).toList(),
          );
        } catch (e) {
          // If remote fails, fall back to cache
        }
      }

      // Get from cache
      final cachedPaymentMethods = await localDataSource
          .getCachedUserPaymentMethods(userId);
      if (cachedPaymentMethods != null) {
        return Right(
          cachedPaymentMethods.map((model) => model.toEntity()).toList(),
        );
      }

      return const Right([]);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> getPaymentMethodById(
    String paymentMethodId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final paymentMethodModel = await remoteDataSource.getPaymentMethodById(
          paymentMethodId,
        );
        return Right(paymentMethodModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> addPaymentMethod(
    PaymentMethod paymentMethod,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final paymentMethodModel = PaymentMethodModel.fromEntity(paymentMethod);
        final result = await remoteDataSource.addPaymentMethod(
          paymentMethodModel,
        );

        // Invalidate cache to force refresh
        await localDataSource.clearCachedUserPaymentMethods(
          paymentMethod.userId,
        );

        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> updatePaymentMethod(
    PaymentMethod paymentMethod,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final paymentMethodModel = PaymentMethodModel.fromEntity(paymentMethod);
        final result = await remoteDataSource.updatePaymentMethod(
          paymentMethodModel,
        );

        // Invalidate cache to force refresh
        await localDataSource.clearCachedUserPaymentMethods(
          paymentMethod.userId,
        );

        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePaymentMethod(
    String paymentMethodId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deletePaymentMethod(paymentMethodId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> setDefaultPaymentMethod(
    String userId,
    String paymentMethodId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.setDefaultPaymentMethod(
          userId,
          paymentMethodId,
        );

        // Invalidate cache to force refresh
        await localDataSource.clearCachedUserPaymentMethods(userId);

        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserPreferences>> getUserPreferences(
    String userId,
  ) async {
    try {
      // Try to get from remote first if connected
      if (await networkInfo.isConnected) {
        try {
          final preferencesModel = await remoteDataSource.getUserPreferences(
            userId,
          );

          // Cache the preferences
          await localDataSource.cacheUserPreferences(preferencesModel);

          return Right(preferencesModel.toEntity());
        } catch (e) {
          // If remote fails, fall back to cache
        }
      }

      // Get from cache
      final cachedPreferences = await localDataSource.getCachedUserPreferences(
        userId,
      );
      if (cachedPreferences != null) {
        return Right(cachedPreferences.toEntity());
      }

      // Return default preferences if nothing is cached
      return Right(UserPreferences(userId: userId, createdAt: DateTime.now()));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserPreferences>> updateUserPreferences(
    UserPreferences preferences,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final preferencesModel = UserPreferencesModel.fromEntity(preferences);
        final result = await remoteDataSource.updateUserPreferences(
          preferencesModel,
        );

        // Cache updated preferences
        await localDataSource.cacheUserPreferences(result);

        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserPreferences>> resetUserPreferences(
    String userId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.resetUserPreferences(userId);

        // Cache reset preferences
        await localDataSource.cacheUserPreferences(result);

        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> trackProfileView(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.trackProfileView(userId);
      }
      return const Right(null);
    } catch (e) {
      // Analytics failures should not break the app
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> trackPreferenceChange(
    String userId,
    String preference,
    dynamic value,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.trackPreferenceChange(userId, preference, value);
      }
      return const Right(null);
    } catch (e) {
      // Analytics failures should not break the app
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportUserData(
    String userId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.exportUserData(userId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> importUserData(
    String userId,
    Map<String, dynamic> data,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.importUserData(userId, data);

        // Clear all cache to force refresh
        await localDataSource.clearAllProfileCache(userId);

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshProfileCache(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        // Refresh all profile data
        await getUserProfile(userId);
        await getUserAddresses(userId);
        await getUserPaymentMethods(userId);
        await getUserPreferences(userId);
      }
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearProfileCache(String userId) async {
    try {
      await localDataSource.clearAllProfileCache(userId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
