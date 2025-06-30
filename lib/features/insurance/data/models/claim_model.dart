import '../../domain/entities/claim.dart';

class ClaimDocumentModel extends ClaimDocument {
  const ClaimDocumentModel({
    required super.id,
    required super.name,
    required super.type,
    required super.url,
    required super.sizeInBytes,
    required super.uploadedAt,
    super.isRequired = false,
    super.isVerified = false,
  });

  factory ClaimDocumentModel.fromJson(Map<String, dynamic> json) {
    return ClaimDocumentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      sizeInBytes: json['sizeInBytes'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      isRequired: json['isRequired'] as bool,
      isVerified: json['isVerified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'url': url,
      'sizeInBytes': sizeInBytes,
      'uploadedAt': uploadedAt.toIso8601String(),
      'isRequired': isRequired,
      'isVerified': isVerified,
    };
  }

  factory ClaimDocumentModel.fromEntity(ClaimDocument document) {
    return ClaimDocumentModel(
      id: document.id,
      name: document.name,
      type: document.type,
      url: document.url,
      sizeInBytes: document.sizeInBytes,
      uploadedAt: document.uploadedAt,
      isRequired: document.isRequired,
      isVerified: document.isVerified,
    );
  }

  ClaimDocument toEntity() => this;
}

class ClaimEventModel extends ClaimEvent {
  const ClaimEventModel({
    required super.id,
    required super.description,
    super.notes,
    required super.timestamp,
    super.performedBy,
    required super.status,
    super.metadata,
  });

  factory ClaimEventModel.fromJson(Map<String, dynamic> json) {
    return ClaimEventModel(
      id: json['id'] as String,
      description: json['description'] as String,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      performedBy: json['performedBy'] as String?,
      status: ClaimStatus.values.byName(json['status'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'performedBy': performedBy,
      'status': status.name,
      'metadata': metadata,
    };
  }

  factory ClaimEventModel.fromEntity(ClaimEvent event) {
    return ClaimEventModel(
      id: event.id,
      description: event.description,
      notes: event.notes,
      timestamp: event.timestamp,
      performedBy: event.performedBy,
      status: event.status,
      metadata: event.metadata,
    );
  }

  ClaimEvent toEntity() => this;
}

class ClaimAssessmentModel extends ClaimAssessment {
  const ClaimAssessmentModel({
    required super.id,
    required super.assessorName,
    required super.assessorPhone,
    super.scheduledDate,
    super.completedDate,
    super.report,
    super.estimatedAmount,
    super.findings = const [],
    super.recommendations = const [],
  });

  factory ClaimAssessmentModel.fromJson(Map<String, dynamic> json) {
    return ClaimAssessmentModel(
      id: json['id'] as String,
      assessorName: json['assessorName'] as String,
      assessorPhone: json['assessorPhone'] as String,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      report: json['report'] as String?,
      estimatedAmount: json['estimatedAmount'] != null
          ? (json['estimatedAmount'] as num).toDouble()
          : null,
      findings: List<String>.from(json['findings'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessorName': assessorName,
      'assessorPhone': assessorPhone,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'report': report,
      'estimatedAmount': estimatedAmount,
      'findings': findings,
      'recommendations': recommendations,
    };
  }

  factory ClaimAssessmentModel.fromEntity(ClaimAssessment assessment) {
    return ClaimAssessmentModel(
      id: assessment.id,
      assessorName: assessment.assessorName,
      assessorPhone: assessment.assessorPhone,
      scheduledDate: assessment.scheduledDate,
      completedDate: assessment.completedDate,
      report: assessment.report,
      estimatedAmount: assessment.estimatedAmount,
      findings: assessment.findings,
      recommendations: assessment.recommendations,
    );
  }

  ClaimAssessment toEntity() => this;
}

class ClaimModel extends Claim {
  const ClaimModel({
    required super.id,
    required super.userId,
    required super.policyId,
    required super.policyNumber,
    required super.providerId,
    required super.providerName,
    required super.claimNumber,
    required super.type,
    required super.status,
    required super.priority,
    required super.title,
    required super.description,
    required super.incidentDate,
    required super.incidentLocation,
    required super.claimedAmount,
    super.approvedAmount,
    super.settledAmount,
    required super.currency,
    required super.documents,
    required super.events,
    super.assessment,
    super.rejectionReason,
    super.settlementDate,
    super.settlementMethod,
    super.assignedTo,
    super.assignedToName,
    super.assignedToPhone,
    super.customFields,
    required super.submittedAt,
    super.reviewedAt,
    super.closedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      policyId: json['policyId'] as String,
      policyNumber: json['policyNumber'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      claimNumber: json['claimNumber'] as String,
      type: ClaimType.values.byName(json['type'] as String),
      status: ClaimStatus.values.byName(json['status'] as String),
      priority: ClaimPriority.values.byName(json['priority'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      incidentDate: DateTime.parse(json['incidentDate'] as String),
      incidentLocation: json['incidentLocation'] as String,
      claimedAmount: (json['claimedAmount'] as num).toDouble(),
      approvedAmount: json['approvedAmount'] != null
          ? (json['approvedAmount'] as num).toDouble()
          : null,
      settledAmount: json['settledAmount'] != null
          ? (json['settledAmount'] as num).toDouble()
          : null,
      currency: json['currency'] as String,
      documents: [], // Simplified for now
      events: [], // Simplified for now
      assessment: null, // Simplified for now
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'policyId': policyId,
      'policyNumber': policyNumber,
      'providerId': providerId,
      'providerName': providerName,
      'claimNumber': claimNumber,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'incidentDate': incidentDate.toIso8601String(),
      'incidentLocation': incidentLocation,
      'claimedAmount': claimedAmount,
      'approvedAmount': approvedAmount,
      'settledAmount': settledAmount,
      'currency': currency,
      'submittedAt': submittedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClaimModel.fromEntity(Claim claim) {
    return ClaimModel(
      id: claim.id,
      userId: claim.userId,
      policyId: claim.policyId,
      policyNumber: claim.policyNumber,
      providerId: claim.providerId,
      providerName: claim.providerName,
      claimNumber: claim.claimNumber,
      type: claim.type,
      status: claim.status,
      priority: claim.priority,
      title: claim.title,
      description: claim.description,
      incidentDate: claim.incidentDate,
      incidentLocation: claim.incidentLocation,
      claimedAmount: claim.claimedAmount,
      approvedAmount: claim.approvedAmount,
      settledAmount: claim.settledAmount,
      currency: claim.currency,
      documents: claim.documents,
      events: claim.events,
      assessment: claim.assessment,
      rejectionReason: claim.rejectionReason,
      settlementDate: claim.settlementDate,
      settlementMethod: claim.settlementMethod,
      assignedTo: claim.assignedTo,
      assignedToName: claim.assignedToName,
      assignedToPhone: claim.assignedToPhone,
      customFields: claim.customFields,
      submittedAt: claim.submittedAt,
      reviewedAt: claim.reviewedAt,
      closedAt: claim.closedAt,
      createdAt: claim.createdAt,
      updatedAt: claim.updatedAt,
    );
  }

  Claim toEntity() => this;
}
