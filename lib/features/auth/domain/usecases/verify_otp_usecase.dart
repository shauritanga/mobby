import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String verificationCode,
    required OtpType type,
  }) async {
    // Validate input
    final otpValidation = Validators.validateOTP(verificationCode);
    if (otpValidation != null) {
      return Left(ValidationFailure(otpValidation));
    }

    // Call appropriate repository method based on type
    switch (type) {
      case OtpType.phone:
        return await repository.verifyPhoneNumber(
          verificationCode: verificationCode,
        );
      case OtpType.email:
        return await repository.verifyEmailWithCode(
          verificationCode: verificationCode,
        );
    }
  }
}

enum OtpType {
  phone,
  email,
}
