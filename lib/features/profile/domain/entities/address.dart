import 'package:equatable/equatable.dart';

/// Address entity for user addresses
/// Following the specifications from FEATURES_DOCUMENTATION.md
class Address extends Equatable {
  final String id;
  final String userId;
  final String type; // home, work, other
  final String fullName;
  final String phoneNumber;
  final String street;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Address({
    required this.id,
    required this.userId,
    required this.type,
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.region,
    required this.postalCode,
    this.country = 'Tanzania',
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  Address copyWith({
    String? id,
    String? userId,
    String? type,
    String? fullName,
    String? phoneNumber,
    String? street,
    String? city,
    String? region,
    String? postalCode,
    String? country,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted address string
  String get formattedAddress {
    return '$street, $city, $region $postalCode, $country';
  }

  /// Get short address for display
  String get shortAddress {
    return '$city, $region';
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        fullName,
        phoneNumber,
        street,
        city,
        region,
        postalCode,
        country,
        isDefault,
        createdAt,
        updatedAt,
      ];
}

/// Address types enum for better type safety
enum AddressType {
  home('Home'),
  work('Work'),
  other('Other');

  const AddressType(this.displayName);
  final String displayName;
}
