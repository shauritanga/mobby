import '../../domain/entities/policy.dart';

class PolicyCoverageModel extends PolicyCoverage {
  const PolicyCoverageModel({
    required super.type,
    required super.name,
    required super.description,
    required super.coverageAmount,
    required super.deductible,
    required super.inclusions,
    required super.exclusions,
    super.isOptional = false,
  });

  factory PolicyCoverageModel.fromJson(Map<String, dynamic> json) {
    return PolicyCoverageModel(
      type: CoverageType.values.byName(json['type'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      coverageAmount: (json['coverageAmount'] as num).toDouble(),
      deductible: (json['deductible'] as num).toDouble(),
      inclusions: List<String>.from(json['inclusions'] ?? []),
      exclusions: List<String>.from(json['exclusions'] ?? []),
      isOptional: json['isOptional'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'description': description,
      'coverageAmount': coverageAmount,
      'deductible': deductible,
      'inclusions': inclusions,
      'exclusions': exclusions,
      'isOptional': isOptional,
    };
  }

  factory PolicyCoverageModel.fromEntity(PolicyCoverage coverage) {
    return PolicyCoverageModel(
      type: coverage.type,
      name: coverage.name,
      description: coverage.description,
      coverageAmount: coverage.coverageAmount,
      deductible: coverage.deductible,
      inclusions: coverage.inclusions,
      exclusions: coverage.exclusions,
      isOptional: coverage.isOptional,
    );
  }

  PolicyCoverage toEntity() => this;
}

class PolicyBeneficiaryModel extends PolicyBeneficiary {
  const PolicyBeneficiaryModel({
    required super.id,
    required super.name,
    required super.relationship,
    required super.phoneNumber,
    required super.email,
    required super.percentage,
    super.isPrimary = false,
  });

  factory PolicyBeneficiaryModel.fromJson(Map<String, dynamic> json) {
    return PolicyBeneficiaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      percentage: (json['percentage'] as num).toDouble(),
      isPrimary: json['isPrimary'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
      'percentage': percentage,
      'isPrimary': isPrimary,
    };
  }

  factory PolicyBeneficiaryModel.fromEntity(PolicyBeneficiary beneficiary) {
    return PolicyBeneficiaryModel(
      id: beneficiary.id,
      name: beneficiary.name,
      relationship: beneficiary.relationship,
      phoneNumber: beneficiary.phoneNumber,
      email: beneficiary.email,
      percentage: beneficiary.percentage,
      isPrimary: beneficiary.isPrimary,
    );
  }

  PolicyBeneficiary toEntity() => this;
}

class PolicyPaymentModel extends PolicyPayment {
  const PolicyPaymentModel({
    required super.id,
    required super.amount,
    required super.dueDate,
    super.paidDate,
    required super.status,
    super.paymentMethod,
    super.transactionId,
  });

  factory PolicyPaymentModel.fromJson(Map<String, dynamic> json) {
    return PolicyPaymentModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }

  factory PolicyPaymentModel.fromEntity(PolicyPayment payment) {
    return PolicyPaymentModel(
      id: payment.id,
      amount: payment.amount,
      dueDate: payment.dueDate,
      paidDate: payment.paidDate,
      status: payment.status,
      paymentMethod: payment.paymentMethod,
      transactionId: payment.transactionId,
    );
  }

  PolicyPayment toEntity() => this;
}

class PolicyModel extends Policy {
  const PolicyModel({
    required super.id,
    required super.userId,
    required super.providerId,
    required super.providerName,
    required super.policyNumber,
    required super.type,
    required super.status,
    required super.title,
    required super.description,
    required super.coverages,
    required super.totalCoverageAmount,
    required super.premiumAmount,
    required super.paymentFrequency,
    required super.currency,
    required super.startDate,
    required super.endDate,
    super.renewalDate,
    required super.beneficiaries,
    required super.payments,
    required super.terms,
    required super.documents,
    super.vehicleId,
    super.propertyId,
    super.customFields,
    super.autoRenewal = false,
    super.discountPercentage,
    super.agentId,
    super.agentName,
    super.agentPhone,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      policyNumber: json['policyNumber'] as String,
      type: PolicyType.values.byName(json['type'] as String),
      status: PolicyStatus.values.byName(json['status'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      premiumAmount: (json['premiumAmount'] as num).toDouble(),
      totalCoverageAmount: (json['totalCoverageAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentFrequency: PaymentFrequency.values.byName(
        json['paymentFrequency'] as String,
      ),
      terms: json['terms'] as Map<String, dynamic>,
      coverages: [], // Simplified for now
      beneficiaries: [], // Simplified for now
      payments: [], // Simplified for now
      documents: [], // Simplified for now
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'providerName': providerName,
      'policyNumber': policyNumber,
      'type': type.name,
      'status': status.name,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'premiumAmount': premiumAmount,
      'totalCoverageAmount': totalCoverageAmount,
      'currency': currency,
      'paymentFrequency': paymentFrequency.name,
      'terms': terms,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PolicyModel.fromEntity(Policy policy) {
    return PolicyModel(
      id: policy.id,
      userId: policy.userId,
      providerId: policy.providerId,
      providerName: policy.providerName,
      policyNumber: policy.policyNumber,
      type: policy.type,
      status: policy.status,
      title: policy.title,
      description: policy.description,
      coverages: policy.coverages,
      totalCoverageAmount: policy.totalCoverageAmount,
      premiumAmount: policy.premiumAmount,
      paymentFrequency: policy.paymentFrequency,
      currency: policy.currency,
      startDate: policy.startDate,
      endDate: policy.endDate,
      renewalDate: policy.renewalDate,
      beneficiaries: policy.beneficiaries,
      payments: policy.payments,
      terms: policy.terms,
      documents: policy.documents,
      vehicleId: policy.vehicleId,
      propertyId: policy.propertyId,
      customFields: policy.customFields,
      autoRenewal: policy.autoRenewal,
      discountPercentage: policy.discountPercentage,
      agentId: policy.agentId,
      agentName: policy.agentName,
      agentPhone: policy.agentPhone,
      createdAt: policy.createdAt,
      updatedAt: policy.updatedAt,
    );
  }

  Policy toEntity() => this;
}
