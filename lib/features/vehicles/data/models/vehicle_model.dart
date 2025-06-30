import '../../domain/entities/vehicle.dart';

/// Vehicle model for data layer
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.userId,
    required super.make,
    required super.model,
    required super.year,
    required super.color,
    required super.plateNumber,
    required super.engineNumber,
    required super.chassisNumber,
    required super.type,
    required super.fuelType,
    required super.transmission,
    super.mileage,
    super.vin,
    super.registrationNumber,
    super.registrationDate,
    super.insuranceExpiry,
    super.inspectionExpiry,
    super.imageUrls,
    super.specifications,
    super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create VehicleModel from Vehicle entity
  factory VehicleModel.fromEntity(Vehicle vehicle) {
    return VehicleModel(
      id: vehicle.id,
      userId: vehicle.userId,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      color: vehicle.color,
      plateNumber: vehicle.plateNumber,
      engineNumber: vehicle.engineNumber,
      chassisNumber: vehicle.chassisNumber,
      type: vehicle.type,
      fuelType: vehicle.fuelType,
      transmission: vehicle.transmission,
      mileage: vehicle.mileage,
      vin: vehicle.vin,
      registrationNumber: vehicle.registrationNumber,
      registrationDate: vehicle.registrationDate,
      insuranceExpiry: vehicle.insuranceExpiry,
      inspectionExpiry: vehicle.inspectionExpiry,
      imageUrls: vehicle.imageUrls,
      specifications: vehicle.specifications,
      status: vehicle.status,
      createdAt: vehicle.createdAt,
      updatedAt: vehicle.updatedAt,
    );
  }

  /// Create VehicleModel from JSON
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      color: json['color'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      engineNumber: json['engineNumber'] ?? '',
      chassisNumber: json['chassisNumber'] ?? '',
      type: _parseVehicleType(json['type']),
      fuelType: _parseFuelType(json['fuelType']),
      transmission: _parseTransmissionType(json['transmission']),
      mileage: json['mileage'],
      vin: json['vin'],
      registrationNumber: json['registrationNumber'],
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'])
          : null,
      insuranceExpiry: json['insuranceExpiry'] != null
          ? DateTime.parse(json['insuranceExpiry'])
          : null,
      inspectionExpiry: json['inspectionExpiry'] != null
          ? DateTime.parse(json['inspectionExpiry'])
          : null,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      status: _parseVehicleStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert VehicleModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'plateNumber': plateNumber,
      'engineNumber': engineNumber,
      'chassisNumber': chassisNumber,
      'type': type.name,
      'fuelType': fuelType.name,
      'transmission': transmission.name,
      'mileage': mileage,
      'vin': vin,
      'registrationNumber': registrationNumber,
      'registrationDate': registrationDate?.toIso8601String(),
      'insuranceExpiry': insuranceExpiry?.toIso8601String(),
      'inspectionExpiry': inspectionExpiry?.toIso8601String(),
      'imageUrls': imageUrls,
      'specifications': specifications,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert DateTime objects to Firestore Timestamps if needed
    return json;
  }

  /// Create from Firestore document
  factory VehicleModel.fromFirestore(Map<String, dynamic> doc, String id) {
    final data = Map<String, dynamic>.from(doc);
    data['id'] = id;
    return VehicleModel.fromJson(data);
  }

  /// Copy with method for VehicleModel
  VehicleModel copyWithModel({
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
    return VehicleModel(
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

  // Helper methods for parsing enums
  static VehicleType _parseVehicleType(dynamic value) {
    if (value == null) return VehicleType.car;
    if (value is VehicleType) return value;
    return VehicleType.values.firstWhere(
      (e) => e.name == value.toString(),
      orElse: () => VehicleType.car,
    );
  }

  static FuelType _parseFuelType(dynamic value) {
    if (value == null) return FuelType.petrol;
    if (value is FuelType) return value;
    return FuelType.values.firstWhere(
      (e) => e.name == value.toString(),
      orElse: () => FuelType.petrol,
    );
  }

  static TransmissionType _parseTransmissionType(dynamic value) {
    if (value == null) return TransmissionType.manual;
    if (value is TransmissionType) return value;
    return TransmissionType.values.firstWhere(
      (e) => e.name == value.toString(),
      orElse: () => TransmissionType.manual,
    );
  }

  static VehicleStatus _parseVehicleStatus(dynamic value) {
    if (value == null) return VehicleStatus.active;
    if (value is VehicleStatus) return value;
    return VehicleStatus.values.firstWhere(
      (e) => e.name == value.toString(),
      orElse: () => VehicleStatus.active,
    );
  }
}
