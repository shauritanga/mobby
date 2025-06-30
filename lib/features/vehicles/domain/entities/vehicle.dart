import 'package:equatable/equatable.dart';

/// Vehicle entity representing a user's registered vehicle
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class Vehicle extends Equatable {
  final String id;
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
  final String? vin; // Vehicle Identification Number
  final String? registrationNumber;
  final DateTime? registrationDate;
  final DateTime? insuranceExpiry;
  final DateTime? inspectionExpiry;
  final List<String> imageUrls;
  final Map<String, dynamic> specifications;
  final VehicleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
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
    this.status = VehicleStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get vehicle display name
  String get displayName => '$year $make $model';

  /// Get vehicle full description
  String get fullDescription => '$displayName ($plateNumber)';

  /// Check if vehicle registration is expired
  bool get isRegistrationExpired {
    if (registrationDate == null) return false;
    // Assuming registration is valid for 1 year in Tanzania
    final expiryDate = DateTime(
      registrationDate!.year + 1,
      registrationDate!.month,
      registrationDate!.day,
    );
    return DateTime.now().isAfter(expiryDate);
  }

  /// Check if vehicle insurance is expired
  bool get isInsuranceExpired {
    if (insuranceExpiry == null) return false;
    return DateTime.now().isAfter(insuranceExpiry!);
  }

  /// Check if vehicle inspection is expired
  bool get isInspectionExpired {
    if (inspectionExpiry == null) return false;
    return DateTime.now().isAfter(inspectionExpiry!);
  }

  /// Check if vehicle has any expired documents
  bool get hasExpiredDocuments {
    return isRegistrationExpired || isInsuranceExpired || isInspectionExpired;
  }

  /// Get vehicle age in years
  int get age => DateTime.now().year - year;

  /// Check if vehicle is vintage (older than 25 years)
  bool get isVintage => age >= 25;

  /// Get primary image URL
  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Copy with method for immutability
  Vehicle copyWith({
    String? id,
    String? userId,
    String? make,
    String? model,
    int? year,
    String? color,
    String? plateNumber,
    String? engineNumber,
    String? chassisNumber,
    VehicleType? type,
    FuelType? fuelType,
    TransmissionType? transmission,
    int? mileage,
    String? vin,
    String? registrationNumber,
    DateTime? registrationDate,
    DateTime? insuranceExpiry,
    DateTime? inspectionExpiry,
    List<String>? imageUrls,
    Map<String, dynamic>? specifications,
    VehicleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      plateNumber: plateNumber ?? this.plateNumber,
      engineNumber: engineNumber ?? this.engineNumber,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      type: type ?? this.type,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      mileage: mileage ?? this.mileage,
      vin: vin ?? this.vin,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      inspectionExpiry: inspectionExpiry ?? this.inspectionExpiry,
      imageUrls: imageUrls ?? this.imageUrls,
      specifications: specifications ?? this.specifications,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        make,
        model,
        year,
        color,
        plateNumber,
        engineNumber,
        chassisNumber,
        type,
        fuelType,
        transmission,
        mileage,
        vin,
        registrationNumber,
        registrationDate,
        insuranceExpiry,
        inspectionExpiry,
        imageUrls,
        specifications,
        status,
        createdAt,
        updatedAt,
      ];
}

/// Vehicle type enumeration
enum VehicleType {
  car,
  motorcycle,
  truck,
  bus,
  van,
  suv,
  pickup,
  trailer,
  other;

  String get displayName {
    switch (this) {
      case VehicleType.car:
        return 'Car';
      case VehicleType.motorcycle:
        return 'Motorcycle';
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.bus:
        return 'Bus';
      case VehicleType.van:
        return 'Van';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.pickup:
        return 'Pickup';
      case VehicleType.trailer:
        return 'Trailer';
      case VehicleType.other:
        return 'Other';
    }
  }
}

/// Fuel type enumeration
enum FuelType {
  petrol,
  diesel,
  electric,
  hybrid,
  lpg,
  cng,
  other;

  String get displayName {
    switch (this) {
      case FuelType.petrol:
        return 'Petrol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
      case FuelType.lpg:
        return 'LPG';
      case FuelType.cng:
        return 'CNG';
      case FuelType.other:
        return 'Other';
    }
  }
}

/// Transmission type enumeration
enum TransmissionType {
  manual,
  automatic,
  cvt,
  other;

  String get displayName {
    switch (this) {
      case TransmissionType.manual:
        return 'Manual';
      case TransmissionType.automatic:
        return 'Automatic';
      case TransmissionType.cvt:
        return 'CVT';
      case TransmissionType.other:
        return 'Other';
    }
  }
}

/// Vehicle status enumeration
enum VehicleStatus {
  active,
  inactive,
  sold,
  scrapped,
  stolen;

  String get displayName {
    switch (this) {
      case VehicleStatus.active:
        return 'Active';
      case VehicleStatus.inactive:
        return 'Inactive';
      case VehicleStatus.sold:
        return 'Sold';
      case VehicleStatus.scrapped:
        return 'Scrapped';
      case VehicleStatus.stolen:
        return 'Stolen';
    }
  }
}
