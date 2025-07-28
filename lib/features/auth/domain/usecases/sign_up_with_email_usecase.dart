import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailUseCase {
  final AuthRepository repository;

  SignUpWithEmailUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String confirmPassword,
    required String displayName,
    String? phoneNumber,
  }) async {
    // Validate input
    final emailValidation = Validators.validateEmail(email);
    if (emailValidation != null) {
      return Left(ValidationFailure(emailValidation));
    }

    final passwordValidation = Validators.validatePassword(password);
    if (passwordValidation != null) {
      return Left(ValidationFailure(passwordValidation));
    }

    final confirmPasswordValidation = Validators.validateConfirmPassword(
      confirmPassword,
      password,
    );
    if (confirmPasswordValidation != null) {
      return Left(ValidationFailure(confirmPasswordValidation));
    }

    final nameValidation = Validators.validateName(displayName);
    if (nameValidation != null) {
      return Left(ValidationFailure(nameValidation));
    }

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final phoneValidation = Validators.validatePhoneNumber(phoneNumber);
      if (phoneValidation != null) {
        return Left(ValidationFailure(phoneValidation));
      }
    }

    // Call repository
    return await repository.signUpWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
      displayName: displayName.trim(),
      phoneNumber: phoneNumber?.trim(),
    );
  }
}
