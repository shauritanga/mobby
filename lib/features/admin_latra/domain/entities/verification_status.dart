import 'package:equatable/equatable.dart';

/// Verification status entity for admin LATRA management
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin LATRA Management Feature
class VerificationStatus extends Equatable {
  final String id;
  final String applicationId;
  final String documentId;
  final String verifiedBy;
  final String verifierName;
  final VerificationResult result;
  final String? notes;
  final List<String> issues;
  final Map<String, dynamic> verificationData;
  final DateTime verificationDate;
  final DateTime? reviewDate;
  final String? reviewedBy;
  final String? reviewNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VerificationStatus({
    required this.id,
    required this.applicationId,
    required this.documentId,
    required this.verifiedBy,
    required this.verifierName,
    required this.result,
    this.notes,
    this.issues = const [],
    this.verificationData = const {},
    required this.verificationDate,
    this.reviewDate,
    this.reviewedBy,
    this.reviewNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isApproved => result == VerificationResult.approved;
  bool get isRejected => result == VerificationResult.rejected;
  bool get isPending => result == VerificationResult.pending;
  bool get requiresReview => result == VerificationResult.requiresReview;
  bool get hasIssues => issues.isNotEmpty;

  String get resultDisplayName => result.displayName;

  VerificationStatus copyWith({
    String? id,
    String? applicationId,
    String? documentId,
    String? verifiedBy,
    String? verifierName,
    VerificationResult? result,
    String? notes,
    List<String>? issues,
    Map<String, dynamic>? verificationData,
    DateTime? verificationDate,
    DateTime? reviewDate,
    String? reviewedBy,
    String? reviewNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VerificationStatus(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      documentId: documentId ?? this.documentId,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifierName: verifierName ?? this.verifierName,
      result: result ?? this.result,
      notes: notes ?? this.notes,
      issues: issues ?? this.issues,
      verificationData: verificationData ?? this.verificationData,
      verificationDate: verificationDate ?? this.verificationDate,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        applicationId,
        documentId,
        verifiedBy,
        verifierName,
        result,
        notes,
        issues,
        verificationData,
        verificationDate,
        reviewDate,
        reviewedBy,
        reviewNotes,
        createdAt,
        updatedAt,
      ];
}

/// Verification result enumeration
enum VerificationResult {
  pending,
  approved,
  rejected,
  requiresReview,
  expired;

  String get displayName {
    switch (this) {
      case VerificationResult.pending:
        return 'Pending';
      case VerificationResult.approved:
        return 'Approved';
      case VerificationResult.rejected:
        return 'Rejected';
      case VerificationResult.requiresReview:
        return 'Requires Review';
      case VerificationResult.expired:
        return 'Expired';
    }
  }

  bool get isCompleted => this == approved || this == rejected;
  bool get needsAction => this == pending || this == requiresReview;
}

/// Integration status entity for monitoring LATRA API integration
class IntegrationStatus extends Equatable {
  final String id;
  final String serviceName;
  final IntegrationHealth health;
  final DateTime lastCheck;
  final int responseTime;
  final String? errorMessage;
  final Map<String, dynamic> metrics;
  final List<IntegrationEvent> recentEvents;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IntegrationStatus({
    required this.id,
    required this.serviceName,
    required this.health,
    required this.lastCheck,
    required this.responseTime,
    this.errorMessage,
    this.metrics = const {},
    this.recentEvents = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isHealthy => health == IntegrationHealth.healthy;
  bool get hasWarnings => health == IntegrationHealth.warning;
  bool get isDown => health == IntegrationHealth.down;
  bool get isUnknown => health == IntegrationHealth.unknown;

  String get healthDisplayName => health.displayName;

  IntegrationStatus copyWith({
    String? id,
    String? serviceName,
    IntegrationHealth? health,
    DateTime? lastCheck,
    int? responseTime,
    String? errorMessage,
    Map<String, dynamic>? metrics,
    List<IntegrationEvent>? recentEvents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IntegrationStatus(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      health: health ?? this.health,
      lastCheck: lastCheck ?? this.lastCheck,
      responseTime: responseTime ?? this.responseTime,
      errorMessage: errorMessage ?? this.errorMessage,
      metrics: metrics ?? this.metrics,
      recentEvents: recentEvents ?? this.recentEvents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serviceName,
        health,
        lastCheck,
        responseTime,
        errorMessage,
        metrics,
        recentEvents,
        createdAt,
        updatedAt,
      ];
}

/// Integration health enumeration
enum IntegrationHealth {
  healthy,
  warning,
  down,
  unknown;

  String get displayName {
    switch (this) {
      case IntegrationHealth.healthy:
        return 'Healthy';
      case IntegrationHealth.warning:
        return 'Warning';
      case IntegrationHealth.down:
        return 'Down';
      case IntegrationHealth.unknown:
        return 'Unknown';
    }
  }
}

/// Integration event entity
class IntegrationEvent extends Equatable {
  final String id;
  final String serviceName;
  final IntegrationEventType type;
  final String message;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const IntegrationEvent({
    required this.id,
    required this.serviceName,
    required this.type,
    required this.message,
    this.data = const {},
    required this.timestamp,
  });

  String get typeDisplayName => type.displayName;

  @override
  List<Object?> get props => [
        id,
        serviceName,
        type,
        message,
        data,
        timestamp,
      ];
}

/// Integration event type enumeration
enum IntegrationEventType {
  success,
  warning,
  error,
  timeout,
  maintenance;

  String get displayName {
    switch (this) {
      case IntegrationEventType.success:
        return 'Success';
      case IntegrationEventType.warning:
        return 'Warning';
      case IntegrationEventType.error:
        return 'Error';
      case IntegrationEventType.timeout:
        return 'Timeout';
      case IntegrationEventType.maintenance:
        return 'Maintenance';
    }
  }
}
