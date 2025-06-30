import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  final AuthRepository repository;

  SendPasswordResetUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
  }) async {
    // Validate input
    final emailValidation = Validators.validateEmail(email);
    if (emailValidation != null) {
      return Left(ValidationFailure(emailValidation));
    }

    // Call repository
    return await repository.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }
}
