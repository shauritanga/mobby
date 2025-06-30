import '../../domain/entities/insurance_provider.dart';

class ProviderRatingModel extends ProviderRating {
  const ProviderRatingModel({
    required super.overallRating,
    required super.totalReviews,
    required super.claimProcessingRating,
    required super.customerServiceRating,
    required super.valueForMoneyRating,
    required super.coverageRating,
  });

  factory ProviderRatingModel.fromJson(Map<String, dynamic> json) {
    return ProviderRatingModel(
      overallRating: (json['overallRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      claimProcessingRating: (json['claimProcessingRating'] as num).toDouble(),
      customerServiceRating: (json['customerServiceRating'] as num).toDouble(),
      valueForMoneyRating: (json['valueForMoneyRating'] as num).toDouble(),
      coverageRating: (json['coverageRating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallRating': overallRating,
      'totalReviews': totalReviews,
      'claimProcessingRating': claimProcessingRating,
      'customerServiceRating': customerServiceRating,
      'valueForMoneyRating': valueForMoneyRating,
      'coverageRating': coverageRating,
    };
  }

  factory ProviderRatingModel.fromEntity(ProviderRating rating) {
    return ProviderRatingModel(
      overallRating: rating.overallRating,
      totalReviews: rating.totalReviews,
      claimProcessingRating: rating.claimProcessingRating,
      customerServiceRating: rating.customerServiceRating,
      valueForMoneyRating: rating.valueForMoneyRating,
      coverageRating: rating.coverageRating,
    );
  }

  ProviderRating toEntity() => this;
}

class ProviderContactModel extends ProviderContact {
  const ProviderContactModel({
    required super.email,
    required super.phone,
    super.whatsapp,
    super.website,
    required super.address,
    required super.city,
    required super.region,
    required super.country,
  });

  factory ProviderContactModel.fromJson(Map<String, dynamic> json) {
    return ProviderContactModel(
      email: json['email'] as String,
      phone: json['phone'] as String,
      whatsapp: json['whatsapp'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      region: json['region'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'whatsapp': whatsapp,
      'website': website,
      'address': address,
      'city': city,
      'region': region,
      'country': country,
    };
  }

  factory ProviderContactModel.fromEntity(ProviderContact contact) {
    return ProviderContactModel(
      email: contact.email,
      phone: contact.phone,
      whatsapp: contact.whatsapp,
      website: contact.website,
      address: contact.address,
      city: contact.city,
      region: contact.region,
      country: contact.country,
    );
  }

  ProviderContact toEntity() => this;
}

class InsuranceProviderModel extends InsuranceProvider {
  const InsuranceProviderModel({
    required super.id,
    required super.name,
    required super.shortName,
    required super.description,
    required super.logoUrl,
    required super.imageUrls,
    required super.types,
    required super.status,
    required super.rating,
    required super.contact,
    required super.features,
    required super.benefits,
    required super.metadata,
    super.isFeatured = false,
    super.isRecommended = false,
    super.isVerified = false,
    required super.licenseNumber,
    required super.licenseExpiryDate,
    required super.certifications,
    required super.minPremium,
    required super.maxPremium,
    required super.currency,
    required super.paymentMethods,
    required super.processingTimeInDays,
    required super.claimSuccessRate,
    required super.establishedDate,
    required super.totalCustomers,
    required super.totalClaimsPaid,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InsuranceProviderModel.fromJson(Map<String, dynamic> json) {
    return InsuranceProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      types: (json['types'] as List)
          .map((e) => ProviderType.values.byName(e as String))
          .toList(),
      status: ProviderStatus.values.byName(json['status'] as String),
      rating: ProviderRatingModel.fromJson(
        json['rating'] as Map<String, dynamic>,
      ),
      contact: ProviderContactModel.fromJson(
        json['contact'] as Map<String, dynamic>,
      ),
      features: List<String>.from(json['features'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>,
      isFeatured: json['isFeatured'] as bool,
      isRecommended: json['isRecommended'] as bool,
      isVerified: json['isVerified'] as bool,
      licenseNumber: json['licenseNumber'] as String,
      licenseExpiryDate: DateTime.parse(json['licenseExpiryDate'] as String),
      certifications: List<String>.from(json['certifications'] ?? []),
      minPremium: (json['minPremium'] as num).toDouble(),
      maxPremium: (json['maxPremium'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentMethods: List<String>.from(json['paymentMethods'] ?? []),
      processingTimeInDays: json['processingTimeInDays'] as int,
      claimSuccessRate: (json['claimSuccessRate'] as num).toDouble(),
      establishedDate: DateTime.parse(json['establishedDate'] as String),
      totalCustomers: json['totalCustomers'] as int,
      totalClaimsPaid: (json['totalClaimsPaid'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'description': description,
      'logoUrl': logoUrl,
      'imageUrls': imageUrls,
      'types': types.map((e) => e.name).toList(),
      'status': status.name,
      'rating': ProviderRatingModel.fromEntity(rating).toJson(),
      'contact': ProviderContactModel.fromEntity(contact).toJson(),
      'features': features,
      'benefits': benefits,
      'metadata': metadata,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InsuranceProviderModel.fromEntity(InsuranceProvider provider) {
    return InsuranceProviderModel(
      id: provider.id,
      name: provider.name,
      shortName: provider.shortName,
      description: provider.description,
      logoUrl: provider.logoUrl,
      imageUrls: provider.imageUrls,
      types: provider.types,
      status: provider.status,
      rating: provider.rating,
      contact: provider.contact,
      features: provider.features,
      benefits: provider.benefits,
      metadata: provider.metadata,
      isFeatured: provider.isFeatured,
      isRecommended: provider.isRecommended,
      isVerified: provider.isVerified,
      licenseNumber: provider.licenseNumber,
      licenseExpiryDate: provider.licenseExpiryDate,
      certifications: provider.certifications,
      minPremium: provider.minPremium,
      maxPremium: provider.maxPremium,
      currency: provider.currency,
      paymentMethods: provider.paymentMethods,
      processingTimeInDays: provider.processingTimeInDays,
      claimSuccessRate: provider.claimSuccessRate,
      establishedDate: provider.establishedDate,
      totalCustomers: provider.totalCustomers,
      totalClaimsPaid: provider.totalClaimsPaid,
      createdAt: provider.createdAt,
      updatedAt: provider.updatedAt,
    );
  }

  InsuranceProvider toEntity() => this;
}
