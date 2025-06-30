import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/address.dart';

part 'address_model.g.dart';

/// Address model for data layer
/// Following Firebase integration pattern as specified in FEATURES_DOCUMENTATION.md
@JsonSerializable()
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

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

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
  factory AddressModel.fromFirestore(Map<String, dynamic> data, String documentId) {
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
