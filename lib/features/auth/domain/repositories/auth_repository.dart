import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../entities/auth_token.dart';

abstract class AuthRepository {
  // Authentication methods
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signInWithPhoneNumber({
    required String phoneNumber,
    required String verificationCode,
  });

  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  });

  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, void>> sendPhoneVerification({
    required String phoneNumber,
  });

  Future<Either<Failure, User>> verifyPhoneNumber({
    required String verificationCode,
  });

  Future<Either<Failure, User>> verifyEmailWithCode({
    required String verificationCode,
  });

  Future<Either<Failure, void>> signOut();

  // User state methods
  Future<Either<Failure, User?>> getCurrentUser();
  
  Stream<User?> get authStateChanges;

  // Token management
  Future<Either<Failure, AuthToken?>> getCurrentToken();
  
  Future<Either<Failure, AuthToken>> refreshToken();

  // Profile management
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> deleteAccount();
}
