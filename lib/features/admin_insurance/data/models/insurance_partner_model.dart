import '../../domain/entities/insurance_partner.dart';

/// Insurance partner model for data layer
class InsurancePartnerModel extends InsurancePartner {
  const InsurancePartnerModel({
    required super.id,
    required super.name,
    required super.shortName,
    required super.description,
    required super.logoUrl,
    super.imageUrls,
    required super.type,
    required super.status,
    required super.contact,
    required super.rating,
    required super.financials,
    super.supportedPolicyTypes,
    super.features,
    super.benefits,
    super.isFeatured,
    super.isRecommended,
    super.isVerified,
    required super.licenseNumber,
    required super.licenseExpiryDate,
    super.certifications,
    required super.minPremium,
    required super.maxPremium,
    required super.currency,
    super.paymentMethods,
    required super.processingTimeInDays,
    required super.claimSuccessRate,
    required super.establishedDate,
    required super.totalCustomers,
    required super.totalClaimsPaid,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InsurancePartnerModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return InsurancePartnerModel(
      id: id,
      name: data['name'] ?? '',
      shortName: data['shortName'] ?? '',
      description: data['description'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      type: PartnerType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PartnerType.insurer,
      ),
      status: PartnerStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PartnerStatus.pending,
      ),
      contact: PartnerContactModel.fromMap(data['contact'] ?? {}),
      rating: PartnerRatingModel.fromMap(data['rating'] ?? {}),
      financials: PartnerFinancialsModel.fromMap(data['financials'] ?? {}),
      supportedPolicyTypes: List<String>.from(data['supportedPolicyTypes'] ?? []),
      features: List<String>.from(data['features'] ?? []),
      benefits: List<String>.from(data['benefits'] ?? []),
      isFeatured: data['isFeatured'] ?? false,
      isRecommended: data['isRecommended'] ?? false,
      isVerified: data['isVerified'] ?? false,
      licenseNumber: data['licenseNumber'] ?? '',
      licenseExpiryDate: DateTime.parse(data['licenseExpiryDate']),
      certifications: List<String>.from(data['certifications'] ?? []),
      minPremium: (data['minPremium'] ?? 0).toDouble(),
      maxPremium: (data['maxPremium'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TZS',
      paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
      processingTimeInDays: data['processingTimeInDays'] ?? 0,
      claimSuccessRate: (data['claimSuccessRate'] ?? 0).toDouble(),
      establishedDate: DateTime.parse(data['establishedDate']),
      totalCustomers: data['totalCustomers'] ?? 0,
      totalClaimsPaid: (data['totalClaimsPaid'] ?? 0).toDouble(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'shortName': shortName,
      'description': description,
      'logoUrl': logoUrl,
      'imageUrls': imageUrls,
      'type': type.name,
      'status': status.name,
      'contact': PartnerContactModel.fromEntity(contact).toMap(),
      'rating': PartnerRatingModel.fromEntity(rating).toMap(),
      'financials': PartnerFinancialsModel.fromEntity(financials).toMap(),
      'supportedPolicyTypes': supportedPolicyTypes,
      'features': features,
      'benefits': benefits,
      'isFeatured': isFeatured,
      'isRecommended': isRecommended,
      'isVerified': isVerified,
      'licenseNumber': licenseNumber,
      'licenseExpiryDate': licenseExpiryDate.toIso8601String(),
      'certifications': certifications,
      'minPremium': minPremium,
      'maxPremium': maxPremium,
      'currency': currency,
      'paymentMethods': paymentMethods,
      'processingTimeInDays': processingTimeInDays,
      'claimSuccessRate': claimSuccessRate,
      'establishedDate': establishedDate.toIso8601String(),
      'totalCustomers': totalCustomers,
      'totalClaimsPaid': totalClaimsPaid,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InsurancePartnerModel.fromEntity(InsurancePartner entity) {
    return InsurancePartnerModel(
      id: entity.id,
      name: entity.name,
      shortName: entity.shortName,
      description: entity.description,
      logoUrl: entity.logoUrl,
      imageUrls: entity.imageUrls,
      type: entity.type,
      status: entity.status,
      contact: entity.contact,
      rating: entity.rating,
      financials: entity.financials,
      supportedPolicyTypes: entity.supportedPolicyTypes,
      features: entity.features,
      benefits: entity.benefits,
      isFeatured: entity.isFeatured,
      isRecommended: entity.isRecommended,
      isVerified: entity.isVerified,
      licenseNumber: entity.licenseNumber,
      licenseExpiryDate: entity.licenseExpiryDate,
      certifications: entity.certifications,
      minPremium: entity.minPremium,
      maxPremium: entity.maxPremium,
      currency: entity.currency,
      paymentMethods: entity.paymentMethods,
      processingTimeInDays: entity.processingTimeInDays,
      claimSuccessRate: entity.claimSuccessRate,
      establishedDate: entity.establishedDate,
      totalCustomers: entity.totalCustomers,
      totalClaimsPaid: entity.totalClaimsPaid,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  InsurancePartner toEntity() {
    return InsurancePartner(
      id: id,
      name: name,
      shortName: shortName,
      description: description,
      logoUrl: logoUrl,
      imageUrls: imageUrls,
      type: type,
      status: status,
      contact: contact,
      rating: rating,
      financials: financials,
      supportedPolicyTypes: supportedPolicyTypes,
      features: features,
      benefits: benefits,
      isFeatured: isFeatured,
      isRecommended: isRecommended,
      isVerified: isVerified,
      licenseNumber: licenseNumber,
      licenseExpiryDate: licenseExpiryDate,
      certifications: certifications,
      minPremium: minPremium,
      maxPremium: maxPremium,
      currency: currency,
      paymentMethods: paymentMethods,
      processingTimeInDays: processingTimeInDays,
      claimSuccessRate: claimSuccessRate,
      establishedDate: establishedDate,
      totalCustomers: totalCustomers,
      totalClaimsPaid: totalClaimsPaid,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Partner contact model
class PartnerContactModel extends PartnerContact {
  const PartnerContactModel({
    required super.email,
    required super.phone,
    required super.website,
    required super.address,
    required super.city,
    required super.state,
    required super.country,
    required super.postalCode,
    super.emergencyContact,
    super.supportEmail,
    super.supportPhone,
  });

  factory PartnerContactModel.fromMap(Map<String, dynamic> data) {
    return PartnerContactModel(
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      website: data['website'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      postalCode: data['postalCode'] ?? '',
      emergencyContact: data['emergencyContact'],
      supportEmail: data['supportEmail'],
      supportPhone: data['supportPhone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'website': website,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'emergencyContact': emergencyContact,
      'supportEmail': supportEmail,
      'supportPhone': supportPhone,
    };
  }

  factory PartnerContactModel.fromEntity(PartnerContact entity) {
    return PartnerContactModel(
      email: entity.email,
      phone: entity.phone,
      website: entity.website,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      postalCode: entity.postalCode,
      emergencyContact: entity.emergencyContact,
      supportEmail: entity.supportEmail,
      supportPhone: entity.supportPhone,
    );
  }
}

/// Partner rating model
class PartnerRatingModel extends PartnerRating {
  const PartnerRatingModel({
    required super.overallRating,
    required super.totalReviews,
    required super.serviceRating,
    required super.claimsRating,
    required super.pricingRating,
    required super.reliabilityRating,
  });

  factory PartnerRatingModel.fromMap(Map<String, dynamic> data) {
    return PartnerRatingModel(
      overallRating: (data['overallRating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      serviceRating: (data['serviceRating'] ?? 0).toDouble(),
      claimsRating: (data['claimsRating'] ?? 0).toDouble(),
      pricingRating: (data['pricingRating'] ?? 0).toDouble(),
      reliabilityRating: (data['reliabilityRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overallRating': overallRating,
      'totalReviews': totalReviews,
      'serviceRating': serviceRating,
      'claimsRating': claimsRating,
      'pricingRating': pricingRating,
      'reliabilityRating': reliabilityRating,
    };
  }

  factory PartnerRatingModel.fromEntity(PartnerRating entity) {
    return PartnerRatingModel(
      overallRating: entity.overallRating,
      totalReviews: entity.totalReviews,
      serviceRating: entity.serviceRating,
      claimsRating: entity.claimsRating,
      pricingRating: entity.pricingRating,
      reliabilityRating: entity.reliabilityRating,
    );
  }
}

/// Partner financials model
class PartnerFinancialsModel extends PartnerFinancials {
  const PartnerFinancialsModel({
    required super.totalRevenue,
    required super.totalCommissions,
    required super.outstandingCommissions,
    required super.averageCommissionRate,
    required super.totalPoliciesSold,
    required super.totalPremiumsCollected,
    required super.lastPaymentDate,
    required super.paymentStatus,
  });

  factory PartnerFinancialsModel.fromMap(Map<String, dynamic> data) {
    return PartnerFinancialsModel(
      totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
      totalCommissions: (data['totalCommissions'] ?? 0).toDouble(),
      outstandingCommissions: (data['outstandingCommissions'] ?? 0).toDouble(),
      averageCommissionRate: (data['averageCommissionRate'] ?? 0).toDouble(),
      totalPoliciesSold: data['totalPoliciesSold'] ?? 0,
      totalPremiumsCollected: (data['totalPremiumsCollected'] ?? 0).toDouble(),
      lastPaymentDate: DateTime.parse(data['lastPaymentDate']),
      paymentStatus: data['paymentStatus'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalRevenue': totalRevenue,
      'totalCommissions': totalCommissions,
      'outstandingCommissions': outstandingCommissions,
      'averageCommissionRate': averageCommissionRate,
      'totalPoliciesSold': totalPoliciesSold,
      'totalPremiumsCollected': totalPremiumsCollected,
      'lastPaymentDate': lastPaymentDate.toIso8601String(),
      'paymentStatus': paymentStatus,
    };
  }

  factory PartnerFinancialsModel.fromEntity(PartnerFinancials entity) {
    return PartnerFinancialsModel(
      totalRevenue: entity.totalRevenue,
      totalCommissions: entity.totalCommissions,
      outstandingCommissions: entity.outstandingCommissions,
      averageCommissionRate: entity.averageCommissionRate,
      totalPoliciesSold: entity.totalPoliciesSold,
      totalPremiumsCollected: entity.totalPremiumsCollected,
      lastPaymentDate: entity.lastPaymentDate,
      paymentStatus: entity.paymentStatus,
    );
  }
}
