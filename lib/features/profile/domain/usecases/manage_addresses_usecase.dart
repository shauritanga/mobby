import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';
import '../entities/address.dart';

/// Manage Addresses Use Cases
/// Following the specifications from FEATURES_DOCUMENTATION.md - Use Cases: Manage Addresses

// Get User Addresses
class GetUserAddressesUseCase implements UseCase<List<Address>, String> {
  final ProfileRepository repository;

  GetUserAddressesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Address>>> call(String userId) async {
    return await repository.getUserAddresses(userId);
  }
}

// Add Address
class AddAddressUseCase implements UseCase<Address, Address> {
  final ProfileRepository repository;

  AddAddressUseCase(this.repository);

  @override
  Future<Either<Failure, Address>> call(Address address) async {
    return await repository.addAddress(address);
  }
}

// Update Address
class UpdateAddressUseCase implements UseCase<Address, Address> {
  final ProfileRepository repository;

  UpdateAddressUseCase(this.repository);

  @override
  Future<Either<Failure, Address>> call(Address address) async {
    return await repository.updateAddress(address);
  }
}

// Delete Address
class DeleteAddressUseCase implements UseCase<void, String> {
  final ProfileRepository repository;

  DeleteAddressUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String addressId) async {
    return await repository.deleteAddress(addressId);
  }
}

// Set Default Address
class SetDefaultAddressUseCase
    implements UseCase<Address, SetDefaultAddressParams> {
  final ProfileRepository repository;

  SetDefaultAddressUseCase(this.repository);

  @override
  Future<Either<Failure, Address>> call(SetDefaultAddressParams params) async {
    return await repository.setDefaultAddress(params.userId, params.addressId);
  }
}

class SetDefaultAddressParams {
  final String userId;
  final String addressId;

  SetDefaultAddressParams({required this.userId, required this.addressId});
}
