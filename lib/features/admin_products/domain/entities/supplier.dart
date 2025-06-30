import 'package:equatable/equatable.dart';

enum SupplierStatus {
  active,
  inactive,
  suspended,
  pending
}

enum SupplierType {
  manufacturer,
  wholesaler,
  distributor,
  dropshipper,
  individual
}

class SupplierContact extends Equatable {
  final String? primaryContactName;
  final String? primaryContactTitle;
  final String email;
  final String? phone;
  final String? mobile;
  final String? fax;
  final String? website;

  const SupplierContact({
    this.primaryContactName,
    this.primaryContactTitle,
    required this.email,
    this.phone,
    this.mobile,
    this.fax,
    this.website,
  });

  @override
  List<Object?> get props => [
        primaryContactName,
        primaryContactTitle,
        email,
        phone,
        mobile,
        fax,
        website,
      ];
}

class SupplierAddress extends Equatable {
  final String street;
  final String? street2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  const SupplierAddress({
    required this.street,
    this.street2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  String get fullAddress {
    final parts = [
      street,
      if (street2 != null && street2!.isNotEmpty) street2,
      city,
      state,
      postalCode,
      country,
    ];
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [street, street2, city, state, postalCode, country];
}

class SupplierPaymentTerms extends Equatable {
  final int paymentDays; // Net payment days (e.g., 30 for Net 30)
  final double? discountPercentage; // Early payment discount
  final int? discountDays; // Days to qualify for discount
  final String currency;
  final String? paymentMethod;
  final String? bankDetails;

  const SupplierPaymentTerms({
    required this.paymentDays,
    this.discountPercentage,
    this.discountDays,
    required this.currency,
    this.paymentMethod,
    this.bankDetails,
  });

  String get termsDescription {
    if (discountPercentage != null && discountDays != null) {
      return '${discountPercentage!.toStringAsFixed(1)}% ${discountDays!}d, Net ${paymentDays}d';
    }
    return 'Net ${paymentDays}d';
  }

  @override
  List<Object?> get props => [
        paymentDays,
        discountPercentage,
        discountDays,
        currency,
        paymentMethod,
        bankDetails,
      ];
}

class Supplier extends Equatable {
  final String id;
  final String name;
  final String? displayName;
  final String? description;
  final String? supplierCode;
  final SupplierType type;
  final SupplierStatus status;
  final SupplierContact contact;
  final SupplierAddress address;
  final SupplierPaymentTerms paymentTerms;
  final String? taxId;
  final String? registrationNumber;
  final String? logoUrl;
  final List<String> categories; // Categories they supply
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

  const Supplier({
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

  bool get isActive => status == SupplierStatus.active;
  bool get hasContract => contractStartDate != null && contractEndDate != null;
  bool get isContractActive => hasContract && 
      DateTime.now().isAfter(contractStartDate!) && 
      DateTime.now().isBefore(contractEndDate!);
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;
  bool get hasRecentOrders => lastOrderDate != null && 
      DateTime.now().difference(lastOrderDate!).inDays <= 90;

  String get statusDisplayName {
    switch (status) {
      case SupplierStatus.active:
        return 'Active';
      case SupplierStatus.inactive:
        return 'Inactive';
      case SupplierStatus.suspended:
        return 'Suspended';
      case SupplierStatus.pending:
        return 'Pending';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case SupplierType.manufacturer:
        return 'Manufacturer';
      case SupplierType.wholesaler:
        return 'Wholesaler';
      case SupplierType.distributor:
        return 'Distributor';
      case SupplierType.dropshipper:
        return 'Dropshipper';
      case SupplierType.individual:
        return 'Individual';
    }
  }

  double get averageOrderValue => totalOrders > 0 ? totalOrderValue / totalOrders : 0.0;

  Supplier copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    String? supplierCode,
    SupplierType? type,
    SupplierStatus? status,
    SupplierContact? contact,
    SupplierAddress? address,
    SupplierPaymentTerms? paymentTerms,
    String? taxId,
    String? registrationNumber,
    String? logoUrl,
    List<String>? categories,
    double? rating,
    int? totalOrders,
    double? totalOrderValue,
    int? activeProducts,
    DateTime? lastOrderDate,
    DateTime? contractStartDate,
    DateTime? contractEndDate,
    Map<String, dynamic>? customFields,
    List<String>? tags,
    bool? isPreferred,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      supplierCode: supplierCode ?? this.supplierCode,
      type: type ?? this.type,
      status: status ?? this.status,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      taxId: taxId ?? this.taxId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      logoUrl: logoUrl ?? this.logoUrl,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      totalOrderValue: totalOrderValue ?? this.totalOrderValue,
      activeProducts: activeProducts ?? this.activeProducts,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      contractStartDate: contractStartDate ?? this.contractStartDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      customFields: customFields ?? this.customFields,
      tags: tags ?? this.tags,
      isPreferred: isPreferred ?? this.isPreferred,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        description,
        supplierCode,
        type,
        status,
        contact,
        address,
        paymentTerms,
        taxId,
        registrationNumber,
        logoUrl,
        categories,
        rating,
        totalOrders,
        totalOrderValue,
        activeProducts,
        lastOrderDate,
        contractStartDate,
        contractEndDate,
        customFields,
        tags,
        isPreferred,
        isVerified,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
