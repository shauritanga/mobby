import 'package:equatable/equatable.dart';

/// Insurance partner entity for admin insurance management
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin Insurance Management Feature
class InsurancePartner extends Equatable {
  final String id;
  final String name;
  final String shortName;
  final String description;
  final String logoUrl;
  final List<String> imageUrls;
  final PartnerType type;
  final PartnerStatus status;
  final PartnerContact contact;
  final PartnerRating rating;
  final PartnerFinancials financials;
  final List<String> supportedPolicyTypes;
  final List<String> features;
  final List<String> benefits;
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
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InsurancePartner({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.logoUrl,
    this.imageUrls = const [],
    required this.type,
    required this.status,
    required this.contact,
    required this.rating,
    required this.financials,
    this.supportedPolicyTypes = const [],
    this.features = const [],
    this.benefits = const [],
    this.isFeatured = false,
    this.isRecommended = false,
    this.isVerified = false,
    required this.licenseNumber,
    required this.licenseExpiryDate,
    this.certifications = const [],
    required this.minPremium,
    required this.maxPremium,
    required this.currency,
    this.paymentMethods = const [],
    required this.processingTimeInDays,
    required this.claimSuccessRate,
    required this.establishedDate,
    required this.totalCustomers,
    required this.totalClaimsPaid,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == PartnerStatus.active;
  bool get hasHighRating => rating.overallRating >= 4.0;
  bool get isLicenseValid => licenseExpiryDate.isAfter(DateTime.now());
  bool get isReliable => isVerified && hasHighRating && claimSuccessRate >= 0.8;
  String get displayName => shortName.isNotEmpty ? shortName : name;
  String get formattedPremiumRange => 
      '$currency ${minPremium.toStringAsFixed(0)} - ${maxPremium.toStringAsFixed(0)}';

  InsurancePartner copyWith({
    String? id,
    String? name,
    String? shortName,
    String? description,
    String? logoUrl,
    List<String>? imageUrls,
    PartnerType? type,
    PartnerStatus? status,
    PartnerContact? contact,
    PartnerRating? rating,
    PartnerFinancials? financials,
    List<String>? supportedPolicyTypes,
    List<String>? features,
    List<String>? benefits,
    bool? isFeatured,
    bool? isRecommended,
    bool? isVerified,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    List<String>? certifications,
    double? minPremium,
    double? maxPremium,
    String? currency,
    List<String>? paymentMethods,
    int? processingTimeInDays,
    double? claimSuccessRate,
    DateTime? establishedDate,
    int? totalCustomers,
    double? totalClaimsPaid,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InsurancePartner(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      type: type ?? this.type,
      status: status ?? this.status,
      contact: contact ?? this.contact,
      rating: rating ?? this.rating,
      financials: financials ?? this.financials,
      supportedPolicyTypes: supportedPolicyTypes ?? this.supportedPolicyTypes,
      features: features ?? this.features,
      benefits: benefits ?? this.benefits,
      isFeatured: isFeatured ?? this.isFeatured,
      isRecommended: isRecommended ?? this.isRecommended,
      isVerified: isVerified ?? this.isVerified,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      certifications: certifications ?? this.certifications,
      minPremium: minPremium ?? this.minPremium,
      maxPremium: maxPremium ?? this.maxPremium,
      currency: currency ?? this.currency,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      processingTimeInDays: processingTimeInDays ?? this.processingTimeInDays,
      claimSuccessRate: claimSuccessRate ?? this.claimSuccessRate,
      establishedDate: establishedDate ?? this.establishedDate,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalClaimsPaid: totalClaimsPaid ?? this.totalClaimsPaid,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        shortName,
        description,
        logoUrl,
        imageUrls,
        type,
        status,
        contact,
        rating,
        financials,
        supportedPolicyTypes,
        features,
        benefits,
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
        metadata,
        createdAt,
        updatedAt,
      ];
}

/// Partner type enumeration
enum PartnerType {
  insurer,
  broker,
  agent,
  reinsurer;

  String get displayName {
    switch (this) {
      case PartnerType.insurer:
        return 'Insurance Company';
      case PartnerType.broker:
        return 'Insurance Broker';
      case PartnerType.agent:
        return 'Insurance Agent';
      case PartnerType.reinsurer:
        return 'Reinsurance Company';
    }
  }
}

/// Partner status enumeration
enum PartnerStatus {
  active,
  inactive,
  suspended,
  pending,
  rejected;

  String get displayName {
    switch (this) {
      case PartnerStatus.active:
        return 'Active';
      case PartnerStatus.inactive:
        return 'Inactive';
      case PartnerStatus.suspended:
        return 'Suspended';
      case PartnerStatus.pending:
        return 'Pending Approval';
      case PartnerStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isOperational => this == active;
  bool get needsAction => this == pending || this == suspended;
}

/// Partner contact information
class PartnerContact extends Equatable {
  final String email;
  final String phone;
  final String website;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? emergencyContact;
  final String? supportEmail;
  final String? supportPhone;

  const PartnerContact({
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.emergencyContact,
    this.supportEmail,
    this.supportPhone,
  });

  @override
  List<Object?> get props => [
        email,
        phone,
        website,
        address,
        city,
        state,
        country,
        postalCode,
        emergencyContact,
        supportEmail,
        supportPhone,
      ];
}

/// Partner rating information
class PartnerRating extends Equatable {
  final double overallRating;
  final int totalReviews;
  final double serviceRating;
  final double claimsRating;
  final double pricingRating;
  final double reliabilityRating;

  const PartnerRating({
    required this.overallRating,
    required this.totalReviews,
    required this.serviceRating,
    required this.claimsRating,
    required this.pricingRating,
    required this.reliabilityRating,
  });

  bool get hasGoodRating => overallRating >= 4.0;
  bool get hasExcellentRating => overallRating >= 4.5;

  @override
  List<Object?> get props => [
        overallRating,
        totalReviews,
        serviceRating,
        claimsRating,
        pricingRating,
        reliabilityRating,
      ];
}

/// Partner financial information
class PartnerFinancials extends Equatable {
  final double totalRevenue;
  final double totalCommissions;
  final double outstandingCommissions;
  final double averageCommissionRate;
  final int totalPoliciesSold;
  final double totalPremiumsCollected;
  final DateTime lastPaymentDate;
  final String paymentStatus;

  const PartnerFinancials({
    required this.totalRevenue,
    required this.totalCommissions,
    required this.outstandingCommissions,
    required this.averageCommissionRate,
    required this.totalPoliciesSold,
    required this.totalPremiumsCollected,
    required this.lastPaymentDate,
    required this.paymentStatus,
  });

  bool get hasOutstandingPayments => outstandingCommissions > 0;
  double get commissionPercentage => averageCommissionRate * 100;

  @override
  List<Object?> get props => [
        totalRevenue,
        totalCommissions,
        outstandingCommissions,
        averageCommissionRate,
        totalPoliciesSold,
        totalPremiumsCollected,
        lastPaymentDate,
        paymentStatus,
      ];
}
