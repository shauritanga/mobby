import 'package:equatable/equatable.dart';

enum PolicyType { automotive, health, life, property, travel, business }

enum PolicyStatus {
  draft,
  pending,
  active,
  expired,
  cancelled,
  suspended,
  lapsed,
}

enum PaymentFrequency { monthly, quarterly, semiAnnual, annual, oneTime }

enum CoverageType {
  comprehensive,
  thirdParty,
  collision,
  liability,
  medical,
  property,
  life,
  disability,
}

class PolicyCoverage extends Equatable {
  final CoverageType type;
  final String name;
  final String description;
  final double coverageAmount;
  final double deductible;
  final List<String> inclusions;
  final List<String> exclusions;
  final bool isOptional;

  const PolicyCoverage({
    required this.type,
    required this.name,
    required this.description,
    required this.coverageAmount,
    required this.deductible,
    required this.inclusions,
    required this.exclusions,
    this.isOptional = false,
  });

  @override
  List<Object?> get props => [
    type,
    name,
    description,
    coverageAmount,
    deductible,
    inclusions,
    exclusions,
    isOptional,
  ];
}

class PolicyBeneficiary extends Equatable {
  final String id;
  final String name;
  final String relationship;
  final String phoneNumber;
  final String email;
  final double percentage;
  final bool isPrimary;

  const PolicyBeneficiary({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    required this.email,
    required this.percentage,
    this.isPrimary = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    relationship,
    phoneNumber,
    email,
    percentage,
    isPrimary,
  ];
}

class PolicyPayment extends Equatable {
  final String id;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status;
  final String? paymentMethod;
  final String? transactionId;

  const PolicyPayment({
    required this.id,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.paymentMethod,
    this.transactionId,
  });

  bool get isPaid => paidDate != null;
  bool get isOverdue => !isPaid && DateTime.now().isAfter(dueDate);

  @override
  List<Object?> get props => [
    id,
    amount,
    dueDate,
    paidDate,
    status,
    paymentMethod,
    transactionId,
  ];
}

class Policy extends Equatable {
  final String id;
  final String userId;
  final String providerId;
  final String providerName;
  final String policyNumber;
  final PolicyType type;
  final PolicyStatus status;
  final String title;
  final String description;
  final List<PolicyCoverage> coverages;
  final double totalCoverageAmount;
  final double premiumAmount;
  final PaymentFrequency paymentFrequency;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? renewalDate;
  final List<PolicyBeneficiary> beneficiaries;
  final List<PolicyPayment> payments;
  final Map<String, dynamic> terms;
  final List<String> documents;
  final String? vehicleId;
  final String? propertyId;
  final Map<String, dynamic>? customFields;
  final bool autoRenewal;
  final double? discountPercentage;
  final String? agentId;
  final String? agentName;
  final String? agentPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Policy({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.providerName,
    required this.policyNumber,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.coverages,
    required this.totalCoverageAmount,
    required this.premiumAmount,
    required this.paymentFrequency,
    required this.currency,
    required this.startDate,
    required this.endDate,
    this.renewalDate,
    required this.beneficiaries,
    required this.payments,
    required this.terms,
    required this.documents,
    this.vehicleId,
    this.propertyId,
    this.customFields,
    this.autoRenewal = false,
    this.discountPercentage,
    this.agentId,
    this.agentName,
    this.agentPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == PolicyStatus.active;

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isExpiringSoon =>
      !isExpired &&
      DateTime.now().add(const Duration(days: 30)).isAfter(endDate);

  bool get hasUnpaidPayments => payments.any((payment) => !payment.isPaid);

  bool get hasOverduePayments => payments.any((payment) => payment.isOverdue);

  double get totalPaid => payments
      .where((payment) => payment.isPaid)
      .fold(0.0, (sum, payment) => sum + payment.amount);

  double get totalOutstanding => payments
      .where((payment) => !payment.isPaid)
      .fold(0.0, (sum, payment) => sum + payment.amount);

  PolicyPayment? get nextPayment =>
      payments.where((payment) => !payment.isPaid).isNotEmpty
      ? payments
            .where((payment) => !payment.isPaid)
            .reduce((a, b) => a.dueDate.isBefore(b.dueDate) ? a : b)
      : null;

  int get daysUntilExpiry => endDate.difference(DateTime.now()).inDays;

  String get formattedPremium =>
      '$currency ${premiumAmount.toStringAsFixed(2)}';

  String get formattedCoverage =>
      '$currency ${totalCoverageAmount.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
    id,
    userId,
    providerId,
    providerName,
    policyNumber,
    type,
    status,
    title,
    description,
    coverages,
    totalCoverageAmount,
    premiumAmount,
    paymentFrequency,
    currency,
    startDate,
    endDate,
    renewalDate,
    beneficiaries,
    payments,
    terms,
    documents,
    vehicleId,
    propertyId,
    customFields,
    autoRenewal,
    discountPercentage,
    agentId,
    agentName,
    agentPhone,
    createdAt,
    updatedAt,
  ];
}
