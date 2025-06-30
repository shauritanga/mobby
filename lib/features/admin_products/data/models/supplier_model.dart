import '../../domain/entities/supplier.dart';

class SupplierContactModel {
  final String? primaryContactName;
  final String? primaryContactTitle;
  final String email;
  final String? phone;
  final String? mobile;
  final String? fax;
  final String? website;

  const SupplierContactModel({
    this.primaryContactName,
    this.primaryContactTitle,
    required this.email,
    this.phone,
    this.mobile,
    this.fax,
    this.website,
  });

  factory SupplierContactModel.fromJson(Map<String, dynamic> json) {
    return SupplierContactModel(
      primaryContactName: json['primaryContactName'] as String?,
      primaryContactTitle: json['primaryContactTitle'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      fax: json['fax'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryContactName': primaryContactName,
      'primaryContactTitle': primaryContactTitle,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'fax': fax,
      'website': website,
    };
  }

  factory SupplierContactModel.fromEntity(SupplierContact contact) {
    return SupplierContactModel(
      primaryContactName: contact.primaryContactName,
      primaryContactTitle: contact.primaryContactTitle,
      email: contact.email,
      phone: contact.phone,
      mobile: contact.mobile,
      fax: contact.fax,
      website: contact.website,
    );
  }

  SupplierContact toEntity() {
    return SupplierContact(
      primaryContactName: primaryContactName,
      primaryContactTitle: primaryContactTitle,
      email: email,
      phone: phone,
      mobile: mobile,
      fax: fax,
      website: website,
    );
  }
}

class SupplierAddressModel {
  final String street;
  final String? street2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  const SupplierAddressModel({
    required this.street,
    this.street2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory SupplierAddressModel.fromJson(Map<String, dynamic> json) {
    return SupplierAddressModel(
      street: json['street'] as String,
      street2: json['street2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'street2': street2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }

  factory SupplierAddressModel.fromEntity(SupplierAddress address) {
    return SupplierAddressModel(
      street: address.street,
      street2: address.street2,
      city: address.city,
      state: address.state,
      postalCode: address.postalCode,
      country: address.country,
    );
  }

  SupplierAddress toEntity() {
    return SupplierAddress(
      street: street,
      street2: street2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
    );
  }
}

class SupplierPaymentTermsModel {
  final int paymentDays;
  final double? discountPercentage;
  final int? discountDays;
  final String currency;
  final String? paymentMethod;
  final String? bankDetails;

  const SupplierPaymentTermsModel({
    required this.paymentDays,
    this.discountPercentage,
    this.discountDays,
    required this.currency,
    this.paymentMethod,
    this.bankDetails,
  });

  factory SupplierPaymentTermsModel.fromJson(Map<String, dynamic> json) {
    return SupplierPaymentTermsModel(
      paymentDays: json['paymentDays'] as int,
      discountPercentage: json['discountPercentage'] != null ? (json['discountPercentage'] as num).toDouble() : null,
      discountDays: json['discountDays'] as int?,
      currency: json['currency'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      bankDetails: json['bankDetails'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentDays': paymentDays,
      'discountPercentage': discountPercentage,
      'discountDays': discountDays,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'bankDetails': bankDetails,
    };
  }

  factory SupplierPaymentTermsModel.fromEntity(SupplierPaymentTerms terms) {
    return SupplierPaymentTermsModel(
      paymentDays: terms.paymentDays,
      discountPercentage: terms.discountPercentage,
      discountDays: terms.discountDays,
      currency: terms.currency,
      paymentMethod: terms.paymentMethod,
      bankDetails: terms.bankDetails,
    );
  }

  SupplierPaymentTerms toEntity() {
    return SupplierPaymentTerms(
      paymentDays: paymentDays,
      discountPercentage: discountPercentage,
      discountDays: discountDays,
      currency: currency,
      paymentMethod: paymentMethod,
      bankDetails: bankDetails,
    );
  }
}

class SupplierModel {
  final String id;
  final String name;
  final String? displayName;
  final String? description;
  final String? supplierCode;
  final SupplierType type;
  final SupplierStatus status;
  final SupplierContactModel contact;
  final SupplierAddressModel address;
  final SupplierPaymentTermsModel paymentTerms;
  final String? taxId;
  final String? registrationNumber;
  final String? logoUrl;
  final List<String> categories;
  final double rating;
  final int totalOrders;
  final double totalOrderValue;
  final int activeProducts;
  final DateTime? lastOrderDate;
  final DateTime? contractStartDate;
  final DateTime? contractEndDate;
  final Map<String, dynamic> customFields;
  final List<String> tags;
  final bool isPreferred;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const SupplierModel({
    required this.id,
    required this.name,
    this.displayName,
    this.description,
    this.supplierCode,
    required this.type,
    required this.status,
    required this.contact,
    required this.address,
    required this.paymentTerms,
    this.taxId,
    this.registrationNumber,
    this.logoUrl,
    required this.categories,
    this.rating = 0.0,
    this.totalOrders = 0,
    this.totalOrderValue = 0.0,
    this.activeProducts = 0,
    this.lastOrderDate,
    this.contractStartDate,
    this.contractEndDate,
    required this.customFields,
    required this.tags,
    this.isPreferred = false,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      supplierCode: json['supplierCode'] as String?,
      type: SupplierType.values.firstWhere((e) => e.name == json['type']),
      status: SupplierStatus.values.firstWhere((e) => e.name == json['status']),
      contact: SupplierContactModel.fromJson(json['contact'] as Map<String, dynamic>),
      address: SupplierAddressModel.fromJson(json['address'] as Map<String, dynamic>),
      paymentTerms: SupplierPaymentTermsModel.fromJson(json['paymentTerms'] as Map<String, dynamic>),
      taxId: json['taxId'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      logoUrl: json['logoUrl'] as String?,
      categories: List<String>.from(json['categories'] as List),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalOrderValue: (json['totalOrderValue'] as num?)?.toDouble() ?? 0.0,
      activeProducts: json['activeProducts'] as int? ?? 0,
      lastOrderDate: json['lastOrderDate'] != null ? DateTime.parse(json['lastOrderDate'] as String) : null,
      contractStartDate: json['contractStartDate'] != null ? DateTime.parse(json['contractStartDate'] as String) : null,
      contractEndDate: json['contractEndDate'] != null ? DateTime.parse(json['contractEndDate'] as String) : null,
      customFields: Map<String, dynamic>.from(json['customFields'] as Map),
      tags: List<String>.from(json['tags'] as List),
      isPreferred: json['isPreferred'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'supplierCode': supplierCode,
      'type': type.name,
      'status': status.name,
      'contact': contact.toJson(),
      'address': address.toJson(),
      'paymentTerms': paymentTerms.toJson(),
      'taxId': taxId,
      'registrationNumber': registrationNumber,
      'logoUrl': logoUrl,
      'categories': categories,
      'rating': rating,
      'totalOrders': totalOrders,
      'totalOrderValue': totalOrderValue,
      'activeProducts': activeProducts,
      'lastOrderDate': lastOrderDate?.toIso8601String(),
      'contractStartDate': contractStartDate?.toIso8601String(),
      'contractEndDate': contractEndDate?.toIso8601String(),
      'customFields': customFields,
      'tags': tags,
      'isPreferred': isPreferred,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory SupplierModel.fromEntity(Supplier supplier) {
    return SupplierModel(
      id: supplier.id,
      name: supplier.name,
      displayName: supplier.displayName,
      description: supplier.description,
      supplierCode: supplier.supplierCode,
      type: supplier.type,
      status: supplier.status,
      contact: SupplierContactModel.fromEntity(supplier.contact),
      address: SupplierAddressModel.fromEntity(supplier.address),
      paymentTerms: SupplierPaymentTermsModel.fromEntity(supplier.paymentTerms),
      taxId: supplier.taxId,
      registrationNumber: supplier.registrationNumber,
      logoUrl: supplier.logoUrl,
      categories: supplier.categories,
      rating: supplier.rating,
      totalOrders: supplier.totalOrders,
      totalOrderValue: supplier.totalOrderValue,
      activeProducts: supplier.activeProducts,
      lastOrderDate: supplier.lastOrderDate,
      contractStartDate: supplier.contractStartDate,
      contractEndDate: supplier.contractEndDate,
      customFields: supplier.customFields,
      tags: supplier.tags,
      isPreferred: supplier.isPreferred,
      isVerified: supplier.isVerified,
      createdAt: supplier.createdAt,
      updatedAt: supplier.updatedAt,
      createdBy: supplier.createdBy,
      updatedBy: supplier.updatedBy,
    );
  }

  Supplier toEntity() {
    return Supplier(
      id: id,
      name: name,
      displayName: displayName,
      description: description,
      supplierCode: supplierCode,
      type: type,
      status: status,
      contact: contact.toEntity(),
      address: address.toEntity(),
      paymentTerms: paymentTerms.toEntity(),
      taxId: taxId,
      registrationNumber: registrationNumber,
      logoUrl: logoUrl,
      categories: categories,
      rating: rating,
      totalOrders: totalOrders,
      totalOrderValue: totalOrderValue,
      activeProducts: activeProducts,
      lastOrderDate: lastOrderDate,
      contractStartDate: contractStartDate,
      contractEndDate: contractEndDate,
      customFields: customFields,
      tags: tags,
      isPreferred: isPreferred,
      isVerified: isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }
}
