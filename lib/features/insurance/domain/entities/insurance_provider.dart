import 'package:equatable/equatable.dart';

enum ProviderType { automotive, health, life, property, travel, business }

enum ProviderStatus { active, inactive, suspended, pending }

class ProviderRating extends Equatable {
  final double overallRating;
  final int totalReviews;
  final double claimProcessingRating;
  final double customerServiceRating;
  final double valueForMoneyRating;
  final double coverageRating;

  const ProviderRating({
    required this.overallRating,
    required this.totalReviews,
    required this.claimProcessingRating,
    required this.customerServiceRating,
    required this.valueForMoneyRating,
    required this.coverageRating,
  });

  @override
  List<Object?> get props => [
    overallRating,
    totalReviews,
    claimProcessingRating,
    customerServiceRating,
    valueForMoneyRating,
    coverageRating,
  ];
}

class ProviderContact extends Equatable {
  final String email;
  final String phone;
  final String? whatsapp;
  final String? website;
  final String address;
  final String city;
  final String region;
  final String country;

  const ProviderContact({
    required this.email,
    required this.phone,
    this.whatsapp,
    this.website,
    required this.address,
    required this.city,
    required this.region,
    required this.country,
  });

  @override
  List<Object?> get props => [
    email,
    phone,
    whatsapp,
    website,
    address,
    city,
    region,
    country,
  ];
}

class InsuranceProvider extends Equatable {
  final String id;
  final String name;
  final String shortName;
  final String description;
  final String logoUrl;
  final List<String> imageUrls;
  final List<ProviderType> types;
  final ProviderStatus status;
  final ProviderRating rating;
  final ProviderContact contact;
  final List<String> features;
  final List<String> benefits;
  final Map<String, dynamic> metadata;
  final bool isFeatured;
  final bool isRecommended;
  final bool isVerified;
  final String licenseNumber;
  final DateTime licenseExpiryDate;
  final List<String> certifications;
  final double minPremium;
  final double maxPremium;
  final String currency;
  final List<String> paymentMethods;
  final int processingTimeInDays;
  final double claimSuccessRate;
  final DateTime establishedDate;
  final int totalCustomers;
  final double totalClaimsPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InsuranceProvider({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.logoUrl,
    required this.imageUrls,
    required this.types,
    required this.status,
    required this.rating,
    required this.contact,
    required this.features,
    required this.benefits,
    required this.metadata,
    this.isFeatured = false,
    this.isRecommended = false,
    this.isVerified = false,
    required this.licenseNumber,
    required this.licenseExpiryDate,
    required this.certifications,
    required this.minPremium,
    required this.maxPremium,
    required this.currency,
    required this.paymentMethods,
    required this.processingTimeInDays,
    required this.claimSuccessRate,
    required this.establishedDate,
    required this.totalCustomers,
    required this.totalClaimsPaid,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == ProviderStatus.active;

  bool get hasHighRating => rating.overallRating >= 4.0;

  bool get isLicenseValid => licenseExpiryDate.isAfter(DateTime.now());

  bool get isReliable => isVerified && hasHighRating && claimSuccessRate >= 0.8;

  String get displayName => shortName.isNotEmpty ? shortName : name;

  String get formattedPremiumRange =>
      '$currency ${minPremium.toStringAsFixed(0)} - ${maxPremium.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
    id,
    name,
    shortName,
    description,
    logoUrl,
    imageUrls,
    types,
    status,
    rating,
    contact,
    features,
    benefits,
    metadata,
    isFeatured,
    isRecommended,
    isVerified,
    licenseNumber,
    licenseExpiryDate,
    certifications,
    minPremium,
    maxPremium,
    currency,
    paymentMethods,
    processingTimeInDays,
    claimSuccessRate,
    establishedDate,
    totalCustomers,
    totalClaimsPaid,
    createdAt,
    updatedAt,
  ];
}
