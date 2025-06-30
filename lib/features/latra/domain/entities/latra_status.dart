import 'package:equatable/equatable.dart';

/// LATRA status entity representing the status of LATRA applications
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRAStatus extends Equatable {
  final String id;
  final String applicationId;
  final String userId;
  final LATRAStatusType type;
  final String title;
  final String description;
  final String? details;
  final DateTime timestamp;
  final String? officerName;
  final String? officeLocation;
  final Map<String, dynamic> metadata;

  const LATRAStatus({
    required this.id,
    required this.applicationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.details,
    required this.timestamp,
    this.officerName,
    this.officeLocation,
    this.metadata = const {},
  });

  /// Check if status is positive
  bool get isPositive => type == LATRAStatusType.approved ||
      type == LATRAStatusType.processed ||
      type == LATRAStatusType.completed;

  /// Check if status requires action
  bool get requiresAction => type == LATRAStatusType.documentsRequired ||
      type == LATRAStatusType.paymentRequired ||
      type == LATRAStatusType.appointmentRequired;

  /// Check if status is final
  bool get isFinal => type == LATRAStatusType.approved ||
      type == LATRAStatusType.rejected ||
      type == LATRAStatusType.cancelled;

  /// Create copy with updated fields
  LATRAStatus copyWith({
    String? id,
    String? applicationId,
    String? userId,
    LATRAStatusType? type,
    String? title,
    String? description,
    String? details,
    DateTime? timestamp,
    String? officerName,
    String? officeLocation,
    Map<String, dynamic>? metadata,
  }) {
    return LATRAStatus(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      officerName: officerName ?? this.officerName,
      officeLocation: officeLocation ?? this.officeLocation,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        applicationId,
        userId,
        type,
        title,
        description,
        details,
        timestamp,
        officerName,
        officeLocation,
        metadata,
      ];
}

/// LATRA status type enumeration
enum LATRAStatusType {
  submitted,
  received,
  underReview,
  documentsRequired,
  paymentRequired,
  appointmentRequired,
  processed,
  approved,
  rejected,
  cancelled,
  completed;

  String get displayName {
    switch (this) {
      case LATRAStatusType.submitted:
        return 'Submitted';
      case LATRAStatusType.received:
        return 'Received';
      case LATRAStatusType.underReview:
        return 'Under Review';
      case LATRAStatusType.documentsRequired:
        return 'Documents Required';
      case LATRAStatusType.paymentRequired:
        return 'Payment Required';
      case LATRAStatusType.appointmentRequired:
        return 'Appointment Required';
      case LATRAStatusType.processed:
        return 'Processed';
      case LATRAStatusType.approved:
        return 'Approved';
      case LATRAStatusType.rejected:
        return 'Rejected';
      case LATRAStatusType.cancelled:
        return 'Cancelled';
      case LATRAStatusType.completed:
        return 'Completed';
    }
  }

  String get description {
    switch (this) {
      case LATRAStatusType.submitted:
        return 'Application has been submitted';
      case LATRAStatusType.received:
        return 'Application has been received by LATRA';
      case LATRAStatusType.underReview:
        return 'Application is being reviewed';
      case LATRAStatusType.documentsRequired:
        return 'Additional documents are required';
      case LATRAStatusType.paymentRequired:
        return 'Payment is required to proceed';
      case LATRAStatusType.appointmentRequired:
        return 'Appointment booking is required';
      case LATRAStatusType.processed:
        return 'Application has been processed';
      case LATRAStatusType.approved:
        return 'Application has been approved';
      case LATRAStatusType.rejected:
        return 'Application has been rejected';
      case LATRAStatusType.cancelled:
        return 'Application has been cancelled';
      case LATRAStatusType.completed:
        return 'Process has been completed';
    }
  }
}
