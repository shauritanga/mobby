import '../../domain/entities/address.dart';

/// Address model for data layer
/// Following Firebase integration pattern as specified in FEATURES_DOCUMENTATION.md
class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.fullName,
    required super.phoneNumber,
    required super.street,
    required super.city,
    required super.region,
    required super.postalCode,
    super.country,
    super.isDefault,
    required super.createdAt,
    super.updatedAt,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: map['type'] as String,
      fullName: map['fullName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      street: map['street'] as String,
      city: map['city'] as String,
      region: map['region'] as String,
      postalCode: map['postalCode'] as String,
      country: map['country'] as String? ?? 'Tanzania',
      isDefault: map['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // For backward compatibility
  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      AddressModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  factory AddressModel.fromEntity(Address address) {
    return AddressModel(
      id: address.id,
      userId: address.userId,
      type: address.type,
      fullName: address.fullName,
      phoneNumber: address.phoneNumber,
      street: address.street,
      city: address.city,
      region: address.region,
      postalCode: address.postalCode,
      country: address.country,
      isDefault: address.isDefault,
      createdAt: address.createdAt,
      updatedAt: address.updatedAt,
    );
  }

  Address toEntity() {
    return Address(
      id: id,
      userId: userId,
      type: type,
      fullName: fullName,
      phoneNumber: phoneNumber,
      street: street,
      city: city,
      region: region,
      postalCode: postalCode,
      country: country,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Firebase specific factory
  factory AddressModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return AddressModel(
      id: documentId,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'other',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      region: data['region'] ?? '',
      postalCode: data['postalCode'] ?? '',
      country: data['country'] ?? 'Tanzania',
      isDefault: data['isDefault'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }
}
