import '../../domain/entities/verification_status.dart';

/// Verification status model for data layer
class VerificationStatusModel extends VerificationStatus {
  const VerificationStatusModel({
    required super.id,
    required super.applicationId,
    required super.documentId,
    required super.verifiedBy,
    required super.verifierName,
    required super.result,
    super.notes,
    super.issues,
    super.verificationData,
    required super.verificationDate,
    super.reviewDate,
    super.reviewedBy,
    super.reviewNotes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory VerificationStatusModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return VerificationStatusModel(
      id: id,
      applicationId: data['applicationId'] ?? '',
      documentId: data['documentId'] ?? '',
      verifiedBy: data['verifiedBy'] ?? '',
      verifierName: data['verifierName'] ?? '',
      result: VerificationResult.values.firstWhere(
        (e) => e.name == data['result'],
        orElse: () => VerificationResult.pending,
      ),
      notes: data['notes'],
      issues: List<String>.from(data['issues'] ?? []),
      verificationData: Map<String, dynamic>.from(data['verificationData'] ?? {}),
      verificationDate: DateTime.parse(data['verificationDate']),
      reviewDate: data['reviewDate'] != null ? DateTime.parse(data['reviewDate']) : null,
      reviewedBy: data['reviewedBy'],
      reviewNotes: data['reviewNotes'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'applicationId': applicationId,
      'documentId': documentId,
      'verifiedBy': verifiedBy,
      'verifierName': verifierName,
      'result': result.name,
      'notes': notes,
      'issues': issues,
      'verificationData': verificationData,
      'verificationDate': verificationDate.toIso8601String(),
      'reviewDate': reviewDate?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'reviewNotes': reviewNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VerificationStatusModel.fromEntity(VerificationStatus entity) {
    return VerificationStatusModel(
      id: entity.id,
      applicationId: entity.applicationId,
      documentId: entity.documentId,
      verifiedBy: entity.verifiedBy,
      verifierName: entity.verifierName,
      result: entity.result,
      notes: entity.notes,
      issues: entity.issues,
      verificationData: entity.verificationData,
      verificationDate: entity.verificationDate,
      reviewDate: entity.reviewDate,
      reviewedBy: entity.reviewedBy,
      reviewNotes: entity.reviewNotes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  VerificationStatus toEntity() {
    return VerificationStatus(
      id: id,
      applicationId: applicationId,
      documentId: documentId,
      verifiedBy: verifiedBy,
      verifierName: verifierName,
      result: result,
      notes: notes,
      issues: issues,
      verificationData: verificationData,
      verificationDate: verificationDate,
      reviewDate: reviewDate,
      reviewedBy: reviewedBy,
      reviewNotes: reviewNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Integration status model for data layer
class IntegrationStatusModel extends IntegrationStatus {
  const IntegrationStatusModel({
    required super.id,
    required super.serviceName,
    required super.health,
    required super.lastCheck,
    required super.responseTime,
    super.errorMessage,
    super.metrics,
    super.recentEvents,
    required super.createdAt,
    required super.updatedAt,
  });

  factory IntegrationStatusModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return IntegrationStatusModel(
      id: id,
      serviceName: data['serviceName'] ?? '',
      health: IntegrationHealth.values.firstWhere(
        (e) => e.name == data['health'],
        orElse: () => IntegrationHealth.unknown,
      ),
      lastCheck: DateTime.parse(data['lastCheck']),
      responseTime: data['responseTime'] ?? 0,
      errorMessage: data['errorMessage'],
      metrics: Map<String, dynamic>.from(data['metrics'] ?? {}),
      recentEvents: (data['recentEvents'] as List<dynamic>?)
          ?.map((e) => IntegrationEventModel.fromMap(e))
          .toList() ?? [],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'serviceName': serviceName,
      'health': health.name,
      'lastCheck': lastCheck.toIso8601String(),
      'responseTime': responseTime,
      'errorMessage': errorMessage,
      'metrics': metrics,
      'recentEvents': recentEvents.map((e) => IntegrationEventModel.fromEntity(e).toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory IntegrationStatusModel.fromEntity(IntegrationStatus entity) {
    return IntegrationStatusModel(
      id: entity.id,
      serviceName: entity.serviceName,
      health: entity.health,
      lastCheck: entity.lastCheck,
      responseTime: entity.responseTime,
      errorMessage: entity.errorMessage,
      metrics: entity.metrics,
      recentEvents: entity.recentEvents,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  IntegrationStatus toEntity() {
    return IntegrationStatus(
      id: id,
      serviceName: serviceName,
      health: health,
      lastCheck: lastCheck,
      responseTime: responseTime,
      errorMessage: errorMessage,
      metrics: metrics,
      recentEvents: recentEvents,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Integration event model for data layer
class IntegrationEventModel extends IntegrationEvent {
  const IntegrationEventModel({
    required super.id,
    required super.serviceName,
    required super.type,
    required super.message,
    super.data,
    required super.timestamp,
  });

  factory IntegrationEventModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return IntegrationEventModel(
      id: id,
      serviceName: data['serviceName'] ?? '',
      type: IntegrationEventType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => IntegrationEventType.error,
      ),
      message: data['message'] ?? '',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  factory IntegrationEventModel.fromMap(Map<String, dynamic> data) {
    return IntegrationEventModel(
      id: data['id'] ?? '',
      serviceName: data['serviceName'] ?? '',
      type: IntegrationEventType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => IntegrationEventType.error,
      ),
      message: data['message'] ?? '',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'serviceName': serviceName,
      'type': type.name,
      'message': message,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceName': serviceName,
      'type': type.name,
      'message': message,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory IntegrationEventModel.fromEntity(IntegrationEvent entity) {
    return IntegrationEventModel(
      id: entity.id,
      serviceName: entity.serviceName,
      type: entity.type,
      message: entity.message,
      data: entity.data,
      timestamp: entity.timestamp,
    );
  }

  IntegrationEvent toEntity() {
    return IntegrationEvent(
      id: id,
      serviceName: serviceName,
      type: type,
      message: message,
      data: data,
      timestamp: timestamp,
    );
  }
}
