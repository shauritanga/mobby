import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository repository;

  SignInWithEmailUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // Validate input
    final emailValidation = Validators.validateEmail(email);
    if (emailValidation != null) {
      return Left(ValidationFailure(emailValidation));
    }

    final passwordValidation = Validators.validateRequired(password, 'Password');
    if (passwordValidation != null) {
      return Left(ValidationFailure(passwordValidation));
    }

    // Call repository
    return await repository.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }
}
