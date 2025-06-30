import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // Cache user locally
        await localDataSource.cacheUser(userModel);
        
        return Right(userModel.toEntity());
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signUpWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
          phoneNumber: phoneNumber,
        );
        
        // Cache user locally
        await localDataSource.cacheUser(userModel);
        
        return Right(userModel.toEntity());
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, User>> signInWithPhoneNumber({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signInWithPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCode: verificationCode,
        );
        
        // Cache user locally
        await localDataSource.cacheUser(userModel);
        
        return Right(userModel.toEntity());
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendPasswordResetEmail(email: email);
        return const Right(null);
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, void>> sendEmailVerification() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendEmailVerification();
        return const Right(null);
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, void>> sendPhoneVerification({
    required String phoneNumber,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendPhoneVerification(phoneNumber: phoneNumber);
        return const Right(null);
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, User>> verifyPhoneNumber({
    required String verificationCode,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.verifyPhoneNumber(
          verificationCode: verificationCode,
        );
        
        // Cache user locally
        await localDataSource.cacheUser(userModel);
        
        return Right(userModel.toEntity());
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, User>> verifyEmailWithCode({
    required String verificationCode,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.verifyEmailWithCode(
          verificationCode: verificationCode,
        );
        
        // Cache user locally
        await localDataSource.cacheUser(userModel);
        
        return Right(userModel.toEntity());
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, void>> signOut() async {
    try {
      // Sign out from remote
      if (await networkInfo.isConnected) {
        await remoteDataSource.signOut();
      }
      
      // Clear local cache
      await localDataSource.clearCachedUser();
      await localDataSource.clearCachedToken();
      
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Try to get from remote first if connected
      if (await networkInfo.isConnected) {
        try {
          final userModel = await remoteDataSource.getCurrentUser();
          if (userModel != null) {
            // Cache the user
            await localDataSource.cacheUser(userModel);
            return Right(userModel.toEntity());
          }
        } catch (e) {
          // If remote fails, fall back to cache
        }
      }
      
      // Get from cache
      final cachedUser = await localDataSource.getCachedUser();
      return Right(cachedUser?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      if (userModel != null) {
        // Cache user when state changes
        localDataSource.cacheUser(userModel);
        return userModel.toEntity();
      } else {
        // Clear cache when user signs out
        localDataSource.clearCachedUser();
        localDataSource.clearCachedToken();
        return null;
      }
    });
  }

  @override
  Future<Either<Failure, AuthToken?>> getCurrentToken() async {
    try {
      // Try to get from remote first if connected
      if (await networkInfo.isConnected) {
        try {
          final tokenModel = await remoteDataSource.getCurrentToken();
          if (tokenModel != null) {
            // Cache the token
            await localDataSource.cacheToken(tokenModel);
            return Right(tokenModel.toEntity());
          }
        } catch (e) {
          // If remote fails, fall back to cache
        }
      }
      
      // Get from cache
      final cachedToken = await localDataSource.getCachedToken();
      return Right(cachedToken?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken() async {
    if (await networkInfo.isConnected) {
      try {
        final tokenModel = await remoteDataSource.refreshToken();
        
        // Cache the new token
        await localDataSource.cacheToken(tokenModel);
        
        return Right(tokenModel.toEntity());
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.updateProfile(
          displayName: displayName,
          photoUrl: photoUrl,
        );
        
        // Cache updated user
        await localDataSource.cacheUser(userModel);
        
        return Right(userModel.toEntity());
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updatePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        return const Right(null);
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
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
  Future<Either<Failure, void>> deleteAccount() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAccount();
        
        // Clear local cache
        await localDataSource.clearCachedUser();
        await localDataSource.clearCachedToken();
        
        return const Right(null);
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
