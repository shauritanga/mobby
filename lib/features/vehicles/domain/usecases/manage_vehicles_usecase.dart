import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/vehicle_repository.dart';
import '../entities/vehicle.dart';

/// Get User Vehicles Use Case
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class GetUserVehiclesUseCase implements UseCase<List<Vehicle>, String> {
  final VehicleRepository repository;

  GetUserVehiclesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Vehicle>>> call(String userId) async {
    return await repository.getUserVehicles(userId);
  }
}

/// Get Vehicle By ID Use Case
class GetVehicleByIdUseCase implements UseCase<Vehicle?, String> {
  final VehicleRepository repository;

  GetVehicleByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Vehicle?>> call(String vehicleId) async {
    return await repository.getVehicleById(vehicleId);
  }
}

/// Create Vehicle Use Case
class CreateVehicleUseCase implements UseCase<Vehicle, CreateVehicleParams> {
  final VehicleRepository repository;

  CreateVehicleUseCase(this.repository);

  @override
  Future<Either<Failure, Vehicle>> call(CreateVehicleParams params) async {
    // Validate required fields
    if (params.make.trim().isEmpty) {
      return const Left(ValidationFailure('Vehicle make is required'));
    }
    if (params.model.trim().isEmpty) {
      return const Left(ValidationFailure('Vehicle model is required'));
    }
    if (params.year < 1900 || params.year > DateTime.now().year + 1) {
      return const Left(ValidationFailure('Invalid vehicle year'));
    }
    if (params.plateNumber.trim().isEmpty) {
      return const Left(ValidationFailure('Plate number is required'));
    }

    // Validate plate number uniqueness
    final plateValidation = await repository.validatePlateNumber(params.plateNumber);
    final isPlateValid = plateValidation.fold(
      (failure) => false,
      (isValid) => isValid,
    );
    
    if (!isPlateValid) {
      return const Left(ValidationFailure('Plate number already exists'));
    }

    // Create vehicle entity
    final vehicle = Vehicle(
      id: '', // Will be generated by repository
      userId: params.userId,
      make: params.make.trim(),
      model: params.model.trim(),
      year: params.year,
      color: params.color.trim(),
      plateNumber: params.plateNumber.trim().toUpperCase(),
      engineNumber: params.engineNumber.trim(),
      chassisNumber: params.chassisNumber.trim(),
      type: params.type,
      fuelType: params.fuelType,
      transmission: params.transmission,
      mileage: params.mileage,
      vin: params.vin?.trim(),
      registrationNumber: params.registrationNumber?.trim(),
      registrationDate: params.registrationDate,
      insuranceExpiry: params.insuranceExpiry,
      inspectionExpiry: params.inspectionExpiry,
      imageUrls: params.imageUrls,
      specifications: params.specifications,
      status: VehicleStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.createVehicle(vehicle);
  }
}

/// Update Vehicle Use Case
class UpdateVehicleUseCase implements UseCase<Vehicle, UpdateVehicleParams> {
  final VehicleRepository repository;

  UpdateVehicleUseCase(this.repository);

  @override
  Future<Either<Failure, Vehicle>> call(UpdateVehicleParams params) async {
    // Get existing vehicle
    final existingVehicleResult = await repository.getVehicleById(params.vehicleId);
    
    return existingVehicleResult.fold(
      (failure) => Left(failure),
      (existingVehicle) async {
        if (existingVehicle == null) {
          return const Left(NotFoundFailure('Vehicle not found'));
        }

        // Validate plate number if changed
        if (params.plateNumber != null && 
            params.plateNumber != existingVehicle.plateNumber) {
          final plateValidation = await repository.validatePlateNumber(
            params.plateNumber!,
            excludeVehicleId: params.vehicleId,
          );
          final isPlateValid = plateValidation.fold(
            (failure) => false,
            (isValid) => isValid,
          );
          
          if (!isPlateValid) {
            return const Left(ValidationFailure('Plate number already exists'));
          }
        }

        // Update vehicle with new data
        final updatedVehicle = existingVehicle.copyWith(
          make: params.make?.trim(),
          model: params.model?.trim(),
          year: params.year,
          color: params.color?.trim(),
          plateNumber: params.plateNumber?.trim().toUpperCase(),
          engineNumber: params.engineNumber?.trim(),
          chassisNumber: params.chassisNumber?.trim(),
          type: params.type,
          fuelType: params.fuelType,
          transmission: params.transmission,
          mileage: params.mileage,
          vin: params.vin?.trim(),
          registrationNumber: params.registrationNumber?.trim(),
          registrationDate: params.registrationDate,
          insuranceExpiry: params.insuranceExpiry,
          inspectionExpiry: params.inspectionExpiry,
          imageUrls: params.imageUrls,
          specifications: params.specifications,
          status: params.status,
          updatedAt: DateTime.now(),
        );

        return await repository.updateVehicle(updatedVehicle);
      },
    );
  }
}

/// Delete Vehicle Use Case
class DeleteVehicleUseCase implements UseCase<void, String> {
  final VehicleRepository repository;

  DeleteVehicleUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String vehicleId) async {
    return await repository.deleteVehicle(vehicleId);
  }
}

/// Search Vehicles Use Case
class SearchVehiclesUseCase implements UseCase<List<Vehicle>, SearchVehiclesParams> {
  final VehicleRepository repository;

  SearchVehiclesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Vehicle>>> call(SearchVehiclesParams params) async {
    return await repository.searchVehicles(params.userId, params.query);
  }
}

/// Parameters for creating a vehicle
class CreateVehicleParams {
  final String userId;
  final String make;
  final String model;
  final int year;
  final String color;
  final String plateNumber;
  final String engineNumber;
  final String chassisNumber;
  final VehicleType type;
  final FuelType fuelType;
  final TransmissionType transmission;
  final int? mileage;
  final String? vin;
  final String? registrationNumber;
  final DateTime? registrationDate;
  final DateTime? insuranceExpiry;
  final DateTime? inspectionExpiry;
  final List<String> imageUrls;
  final Map<String, dynamic> specifications;

  CreateVehicleParams({
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
    required this.engineNumber,
    required this.chassisNumber,
    required this.type,
    required this.fuelType,
    required this.transmission,
    this.mileage,
    this.vin,
    this.registrationNumber,
    this.registrationDate,
    this.insuranceExpiry,
    this.inspectionExpiry,
    this.imageUrls = const [],
    this.specifications = const {},
  });
}

/// Parameters for updating a vehicle
class UpdateVehicleParams {
  final String vehicleId;
  final String? make;
  final String? model;
  final int? year;
  final String? color;
  final String? plateNumber;
  final String? engineNumber;
  final String? chassisNumber;
  final VehicleType? type;
  final FuelType? fuelType;
  final TransmissionType? transmission;
  final int? mileage;
  final String? vin;
  final String? registrationNumber;
  final DateTime? registrationDate;
  final DateTime? insuranceExpiry;
  final DateTime? inspectionExpiry;
  final List<String>? imageUrls;
  final Map<String, dynamic>? specifications;
  final VehicleStatus? status;

  UpdateVehicleParams({
    required this.vehicleId,
    this.make,
    this.model,
    this.year,
    this.color,
    this.plateNumber,
    this.engineNumber,
    this.chassisNumber,
    this.type,
    this.fuelType,
    this.transmission,
    this.mileage,
    this.vin,
    this.registrationNumber,
    this.registrationDate,
    this.insuranceExpiry,
    this.inspectionExpiry,
    this.imageUrls,
    this.specifications,
    this.status,
  });
}

/// Parameters for searching vehicles
class SearchVehiclesParams {
  final String userId;
  final String query;

  SearchVehiclesParams({
    required this.userId,
    required this.query,
  });
}
