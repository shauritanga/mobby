import 'package:equatable/equatable.dart';

/// Commission entity for admin insurance management
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin Insurance Management Feature
class Commission extends Equatable {
  final String id;
  final String partnerId;
  final String partnerName;
  final String policyId;
  final String policyNumber;
  final String applicationId;
  final String userId;
  final String userName;
  final CommissionType type;
  final CommissionStatus status;
  final double baseAmount;
  final double commissionRate;
  final double commissionAmount;
  final double taxAmount;
  final double netAmount;
  final String currency;
  final CommissionTier tier;
  final DateTime earnedDate;
  final DateTime? paidDate;
  final DateTime? dueDate;
  final String? paymentReference;
  final String? paymentMethod;
  final List<CommissionAdjustment> adjustments;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Commission({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.policyId,
    required this.policyNumber,
    required this.applicationId,
    required this.userId,
    required this.userName,
    required this.type,
    required this.status,
    required this.baseAmount,
    required this.commissionRate,
    required this.commissionAmount,
    required this.taxAmount,
    required this.netAmount,
    required this.currency,
    required this.tier,
    required this.earnedDate,
    this.paidDate,
    this.dueDate,
    this.paymentReference,
    this.paymentMethod,
    this.adjustments = const [],
    this.notes,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPaid => status == CommissionStatus.paid;
  bool get isPending => status == CommissionStatus.pending;
  bool get isOverdue => dueDate != null && 
      dueDate!.isBefore(DateTime.now()) && 
      status != CommissionStatus.paid;
  
  double get commissionPercentage => commissionRate * 100;
  double get totalAdjustments => adjustments.fold(0.0, (sum, adj) => sum + adj.amount);
  double get finalAmount => netAmount + totalAdjustments;

  String get statusDisplayName => status.displayName;
  String get typeDisplayName => type.displayName;
  String get tierDisplayName => tier.displayName;

  Commission copyWith({
    String? id,
    String? partnerId,
    String? partnerName,
    String? policyId,
    String? policyNumber,
    String? applicationId,
    String? userId,
    String? userName,
    CommissionType? type,
    CommissionStatus? status,
    double? baseAmount,
    double? commissionRate,
    double? commissionAmount,
    double? taxAmount,
    double? netAmount,
    String? currency,
    CommissionTier? tier,
    DateTime? earnedDate,
    DateTime? paidDate,
    DateTime? dueDate,
    String? paymentReference,
    String? paymentMethod,
    List<CommissionAdjustment>? adjustments,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Commission(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      policyId: policyId ?? this.policyId,
      policyNumber: policyNumber ?? this.policyNumber,
      applicationId: applicationId ?? this.applicationId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      status: status ?? this.status,
      baseAmount: baseAmount ?? this.baseAmount,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      netAmount: netAmount ?? this.netAmount,
      currency: currency ?? this.currency,
      tier: tier ?? this.tier,
      earnedDate: earnedDate ?? this.earnedDate,
      paidDate: paidDate ?? this.paidDate,
      dueDate: dueDate ?? this.dueDate,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      adjustments: adjustments ?? this.adjustments,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        partnerId,
        partnerName,
        policyId,
        policyNumber,
        applicationId,
        userId,
        userName,
        type,
        status,
        baseAmount,
        commissionRate,
        commissionAmount,
        taxAmount,
        netAmount,
        currency,
        tier,
        earnedDate,
        paidDate,
        dueDate,
        paymentReference,
        paymentMethod,
        adjustments,
        notes,
        metadata,
        createdAt,
        updatedAt,
      ];
}

/// Commission type enumeration
enum CommissionType {
  newBusiness,
  renewal,
  crossSell,
  upsell,
  referral,
  bonus;

  String get displayName {
    switch (this) {
      case CommissionType.newBusiness:
        return 'New Business';
      case CommissionType.renewal:
        return 'Renewal';
      case CommissionType.crossSell:
        return 'Cross-sell';
      case CommissionType.upsell:
        return 'Up-sell';
      case CommissionType.referral:
        return 'Referral';
      case CommissionType.bonus:
        return 'Bonus';
    }
  }
}

/// Commission status enumeration
enum CommissionStatus {
  pending,
  approved,
  paid,
  disputed,
  cancelled,
  adjusted;

  String get displayName {
    switch (this) {
      case CommissionStatus.pending:
        return 'Pending';
      case CommissionStatus.approved:
        return 'Approved';
      case CommissionStatus.paid:
        return 'Paid';
      case CommissionStatus.disputed:
        return 'Disputed';
      case CommissionStatus.cancelled:
        return 'Cancelled';
      case CommissionStatus.adjusted:
        return 'Adjusted';
    }
  }

  bool get isPayable => this == approved;
  bool get needsAction => this == pending || this == disputed;
}

/// Commission tier enumeration
enum CommissionTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond;

  String get displayName {
    switch (this) {
      case CommissionTier.bronze:
        return 'Bronze';
      case CommissionTier.silver:
        return 'Silver';
      case CommissionTier.gold:
        return 'Gold';
      case CommissionTier.platinum:
        return 'Platinum';
      case CommissionTier.diamond:
        return 'Diamond';
    }
  }

  double get multiplier {
    switch (this) {
      case CommissionTier.bronze:
        return 1.0;
      case CommissionTier.silver:
        return 1.1;
      case CommissionTier.gold:
        return 1.25;
      case CommissionTier.platinum:
        return 1.5;
      case CommissionTier.diamond:
        return 2.0;
    }
  }
}

/// Commission adjustment entity
class CommissionAdjustment extends Equatable {
  final String id;
  final String reason;
  final double amount;
  final AdjustmentType type;
  final String adjustedBy;
  final String? notes;
  final DateTime adjustedDate;

  const CommissionAdjustment({
    required this.id,
    required this.reason,
    required this.amount,
    required this.type,
    required this.adjustedBy,
    this.notes,
    required this.adjustedDate,
  });

  bool get isPositive => amount > 0;
  bool get isNegative => amount < 0;
  String get typeDisplayName => type.displayName;

  @override
  List<Object?> get props => [
        id,
        reason,
        amount,
        type,
        adjustedBy,
        notes,
        adjustedDate,
      ];
}

/// Adjustment type enumeration
enum AdjustmentType {
  bonus,
  penalty,
  correction,
  refund,
  chargeback;

  String get displayName {
    switch (this) {
      case AdjustmentType.bonus:
        return 'Bonus';
      case AdjustmentType.penalty:
        return 'Penalty';
      case AdjustmentType.correction:
        return 'Correction';
      case AdjustmentType.refund:
        return 'Refund';
      case AdjustmentType.chargeback:
        return 'Chargeback';
    }
  }
}
