import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';
import '../../../auth/domain/entities/user.dart';

/// Update Profile Use Case
/// Following the specifications from FEATURES_DOCUMENTATION.md - Use Cases: Update Profile
class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateUserProfile(
      displayName: params.displayName,
      phoneNumber: params.phoneNumber,
      photoUrl: params.photoUrl,
    );
  }
}

class UpdateProfileParams {
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;

  UpdateProfileParams({this.displayName, this.phoneNumber, this.photoUrl});
}
