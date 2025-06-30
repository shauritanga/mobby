import 'package:equatable/equatable.dart';

enum ClaimType {
  accident,
  theft,
  fire,
  flood,
  medical,
  death,
  disability,
  property,
  liability,
  other,
}

enum ClaimStatus {
  draft,
  submitted,
  underReview,
  investigating,
  approved,
  rejected,
  settled,
  closed,
  appealed,
}

enum ClaimPriority { low, medium, high, urgent }

class ClaimDocument extends Equatable {
  final String id;
  final String name;
  final String type;
  final String url;
  final int sizeInBytes;
  final DateTime uploadedAt;
  final bool isRequired;
  final bool isVerified;

  const ClaimDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.sizeInBytes,
    required this.uploadedAt,
    this.isRequired = false,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    url,
    sizeInBytes,
    uploadedAt,
    isRequired,
    isVerified,
  ];
}

class ClaimEvent extends Equatable {
  final String id;
  final String description;
  final String? notes;
  final DateTime timestamp;
  final String? performedBy;
  final ClaimStatus status;
  final Map<String, dynamic>? metadata;

  const ClaimEvent({
    required this.id,
    required this.description,
    this.notes,
    required this.timestamp,
    this.performedBy,
    required this.status,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    description,
    notes,
    timestamp,
    performedBy,
    status,
    metadata,
  ];
}

class ClaimAssessment extends Equatable {
  final String id;
  final String assessorName;
  final String assessorPhone;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? report;
  final double? estimatedAmount;
  final List<String> findings;
  final List<String> recommendations;

  const ClaimAssessment({
    required this.id,
    required this.assessorName,
    required this.assessorPhone,
    this.scheduledDate,
    this.completedDate,
    this.report,
    this.estimatedAmount,
    this.findings = const [],
    this.recommendations = const [],
  });

  bool get isCompleted => completedDate != null;
  bool get isScheduled => scheduledDate != null;

  @override
  List<Object?> get props => [
    id,
    assessorName,
    assessorPhone,
    scheduledDate,
    completedDate,
    report,
    estimatedAmount,
    findings,
    recommendations,
  ];
}

class Claim extends Equatable {
  final String id;
  final String userId;
  final String policyId;
  final String policyNumber;
  final String providerId;
  final String providerName;
  final String claimNumber;
  final ClaimType type;
  final ClaimStatus status;
  final ClaimPriority priority;
  final String title;
  final String description;
  final DateTime incidentDate;
  final String incidentLocation;
  final double claimedAmount;
  final double? approvedAmount;
  final double? settledAmount;
  final String currency;
  final List<ClaimDocument> documents;
  final List<ClaimEvent> events;
  final ClaimAssessment? assessment;
  final String? rejectionReason;
  final DateTime? settlementDate;
  final String? settlementMethod;
  final String? assignedTo;
  final String? assignedToName;
  final String? assignedToPhone;
  final Map<String, dynamic>? customFields;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Claim({
    required this.id,
    required this.userId,
    required this.policyId,
    required this.policyNumber,
    required this.providerId,
    required this.providerName,
    required this.claimNumber,
    required this.type,
    required this.status,
    required this.priority,
    required this.title,
    required this.description,
    required this.incidentDate,
    required this.incidentLocation,
    required this.claimedAmount,
    this.approvedAmount,
    this.settledAmount,
    required this.currency,
    required this.documents,
    required this.events,
    this.assessment,
    this.rejectionReason,
    this.settlementDate,
    this.settlementMethod,
    this.assignedTo,
    this.assignedToName,
    this.assignedToPhone,
    this.customFields,
    required this.submittedAt,
    this.reviewedAt,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSubmitted => status != ClaimStatus.draft;

  bool get isUnderReview =>
      status == ClaimStatus.underReview || status == ClaimStatus.investigating;

  bool get isApproved => status == ClaimStatus.approved;

  bool get isRejected => status == ClaimStatus.rejected;

  bool get isSettled => status == ClaimStatus.settled;

  bool get isClosed => status == ClaimStatus.closed;

  bool get canBeEdited => status == ClaimStatus.draft;

  bool get canBeAppealed =>
      isRejected && DateTime.now().difference(updatedAt).inDays <= 30;

  int get daysSinceSubmission => DateTime.now().difference(submittedAt).inDays;

  int get daysInCurrentStatus => DateTime.now().difference(updatedAt).inDays;

  ClaimEvent? get latestEvent => events.isNotEmpty
      ? events.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b)
      : null;

  double get finalAmount => settledAmount ?? approvedAmount ?? claimedAmount;

  String get formattedClaimedAmount =>
      '$currency ${claimedAmount.toStringAsFixed(2)}';

  String get formattedApprovedAmount => approvedAmount != null
      ? '$currency ${approvedAmount!.toStringAsFixed(2)}'
      : 'N/A';

  String get formattedSettledAmount => settledAmount != null
      ? '$currency ${settledAmount!.toStringAsFixed(2)}'
      : 'N/A';

  @override
  List<Object?> get props => [
    id,
    userId,
    policyId,
    policyNumber,
    providerId,
    providerName,
    claimNumber,
    type,
    status,
    priority,
    title,
    description,
    incidentDate,
    incidentLocation,
    claimedAmount,
    approvedAmount,
    settledAmount,
    currency,
    documents,
    events,
    assessment,
    rejectionReason,
    settlementDate,
    settlementMethod,
    assignedTo,
    assignedToName,
    assignedToPhone,
    customFields,
    submittedAt,
    reviewedAt,
    closedAt,
    createdAt,
    updatedAt,
  ];
}
