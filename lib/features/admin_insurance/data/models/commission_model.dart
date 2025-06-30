import '../../domain/entities/commission.dart';

/// Commission model for data layer
class CommissionModel extends Commission {
  const CommissionModel({
    required super.id,
    required super.partnerId,
    required super.partnerName,
    required super.policyId,
    required super.policyNumber,
    required super.applicationId,
    required super.userId,
    required super.userName,
    required super.type,
    required super.status,
    required super.baseAmount,
    required super.commissionRate,
    required super.commissionAmount,
    required super.taxAmount,
    required super.netAmount,
    required super.currency,
    required super.tier,
    required super.earnedDate,
    super.paidDate,
    super.dueDate,
    super.paymentReference,
    super.paymentMethod,
    super.adjustments,
    super.notes,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommissionModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return CommissionModel(
      id: id,
      partnerId: data['partnerId'] ?? '',
      partnerName: data['partnerName'] ?? '',
      policyId: data['policyId'] ?? '',
      policyNumber: data['policyNumber'] ?? '',
      applicationId: data['applicationId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      type: CommissionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CommissionType.newBusiness,
      ),
      status: CommissionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CommissionStatus.pending,
      ),
      baseAmount: (data['baseAmount'] ?? 0).toDouble(),
      commissionRate: (data['commissionRate'] ?? 0).toDouble(),
      commissionAmount: (data['commissionAmount'] ?? 0).toDouble(),
      taxAmount: (data['taxAmount'] ?? 0).toDouble(),
      netAmount: (data['netAmount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TZS',
      tier: CommissionTier.values.firstWhere(
        (e) => e.name == data['tier'],
        orElse: () => CommissionTier.bronze,
      ),
      earnedDate: DateTime.parse(data['earnedDate']),
      paidDate: data['paidDate'] != null ? DateTime.parse(data['paidDate']) : null,
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      paymentReference: data['paymentReference'],
      paymentMethod: data['paymentMethod'],
      adjustments: (data['adjustments'] as List<dynamic>?)
          ?.map((e) => CommissionAdjustmentModel.fromMap(e))
          .toList() ?? [],
      notes: data['notes'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'partnerId': partnerId,
      'partnerName': partnerName,
      'policyId': policyId,
      'policyNumber': policyNumber,
      'applicationId': applicationId,
      'userId': userId,
      'userName': userName,
      'type': type.name,
      'status': status.name,
      'baseAmount': baseAmount,
      'commissionRate': commissionRate,
      'commissionAmount': commissionAmount,
      'taxAmount': taxAmount,
      'netAmount': netAmount,
      'currency': currency,
      'tier': tier.name,
      'earnedDate': earnedDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'paymentReference': paymentReference,
      'paymentMethod': paymentMethod,
      'adjustments': adjustments.map((e) => CommissionAdjustmentModel.fromEntity(e).toMap()).toList(),
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CommissionModel.fromEntity(Commission entity) {
    return CommissionModel(
      id: entity.id,
      partnerId: entity.partnerId,
      partnerName: entity.partnerName,
      policyId: entity.policyId,
      policyNumber: entity.policyNumber,
      applicationId: entity.applicationId,
      userId: entity.userId,
      userName: entity.userName,
      type: entity.type,
      status: entity.status,
      baseAmount: entity.baseAmount,
      commissionRate: entity.commissionRate,
      commissionAmount: entity.commissionAmount,
      taxAmount: entity.taxAmount,
      netAmount: entity.netAmount,
      currency: entity.currency,
      tier: entity.tier,
      earnedDate: entity.earnedDate,
      paidDate: entity.paidDate,
      dueDate: entity.dueDate,
      paymentReference: entity.paymentReference,
      paymentMethod: entity.paymentMethod,
      adjustments: entity.adjustments,
      notes: entity.notes,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Commission toEntity() {
    return Commission(
      id: id,
      partnerId: partnerId,
      partnerName: partnerName,
      policyId: policyId,
      policyNumber: policyNumber,
      applicationId: applicationId,
      userId: userId,
      userName: userName,
      type: type,
      status: status,
      baseAmount: baseAmount,
      commissionRate: commissionRate,
      commissionAmount: commissionAmount,
      taxAmount: taxAmount,
      netAmount: netAmount,
      currency: currency,
      tier: tier,
      earnedDate: earnedDate,
      paidDate: paidDate,
      dueDate: dueDate,
      paymentReference: paymentReference,
      paymentMethod: paymentMethod,
      adjustments: adjustments,
      notes: notes,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Commission adjustment model
class CommissionAdjustmentModel extends CommissionAdjustment {
  const CommissionAdjustmentModel({
    required super.id,
    required super.reason,
    required super.amount,
    required super.type,
    required super.adjustedBy,
    super.notes,
    required super.adjustedDate,
  });

  factory CommissionAdjustmentModel.fromMap(Map<String, dynamic> data) {
    return CommissionAdjustmentModel(
      id: data['id'] ?? '',
      reason: data['reason'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: AdjustmentType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AdjustmentType.correction,
      ),
      adjustedBy: data['adjustedBy'] ?? '',
      notes: data['notes'],
      adjustedDate: DateTime.parse(data['adjustedDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reason': reason,
      'amount': amount,
      'type': type.name,
      'adjustedBy': adjustedBy,
      'notes': notes,
      'adjustedDate': adjustedDate.toIso8601String(),
    };
  }

  factory CommissionAdjustmentModel.fromEntity(CommissionAdjustment entity) {
    return CommissionAdjustmentModel(
      id: entity.id,
      reason: entity.reason,
      amount: entity.amount,
      type: entity.type,
      adjustedBy: entity.adjustedBy,
      notes: entity.notes,
      adjustedDate: entity.adjustedDate,
    );
  }

  CommissionAdjustment toEntity() {
    return CommissionAdjustment(
      id: id,
      reason: reason,
      amount: amount,
      type: type,
      adjustedBy: adjustedBy,
      notes: notes,
      adjustedDate: adjustedDate,
    );
  }
}
