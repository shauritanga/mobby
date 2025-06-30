import 'package:equatable/equatable.dart';

/// Insurance application entity for admin insurance management
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin Insurance Management Feature
class InsuranceApplication extends Equatable {
  final String id;
  final String applicationNumber;
  final String userId;
  final String userName;
  final String userEmail;
  final String partnerId;
  final String partnerName;
  final ApplicationType type;
  final ApplicationStatus status;
  final ApplicationPriority priority;
  final String title;
  final String description;
  final Map<String, dynamic> applicationData;
  final List<ApplicationDocument> documents;
  final List<ApplicationNote> notes;
  final double requestedCoverageAmount;
  final double premiumAmount;
  final String currency;
  final DateTime requestedStartDate;
  final DateTime requestedEndDate;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime? assignedDate;
  final String? rejectionReason;
  final List<ApplicationStatusHistory> statusHistory;
  final Map<String, dynamic> underwritingData;
  final double? riskScore;
  final String? riskCategory;
  final DateTime submittedDate;
  final DateTime? processedDate;
  final DateTime? approvedDate;
  final DateTime? rejectedDate;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InsuranceApplication({
    required this.id,
    required this.applicationNumber,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.partnerId,
    required this.partnerName,
    required this.type,
    required this.status,
    required this.priority,
    required this.title,
    required this.description,
    required this.applicationData,
    this.documents = const [],
    this.notes = const [],
    required this.requestedCoverageAmount,
    required this.premiumAmount,
    required this.currency,
    required this.requestedStartDate,
    required this.requestedEndDate,
    this.assignedTo,
    this.assignedToName,
    this.assignedDate,
    this.rejectionReason,
    this.statusHistory = const [],
    this.underwritingData = const {},
    this.riskScore,
    this.riskCategory,
    required this.submittedDate,
    this.processedDate,
    this.approvedDate,
    this.rejectedDate,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == ApplicationStatus.pending;
  bool get isUnderReview => status == ApplicationStatus.underReview;
  bool get isApproved => status == ApplicationStatus.approved;
  bool get isRejected => status == ApplicationStatus.rejected;
  bool get isAssigned => assignedTo != null;
  bool get hasHighRisk => riskScore != null && riskScore! > 0.7;
  bool get isOverdue => submittedDate.isBefore(DateTime.now().subtract(const Duration(days: 7))) && 
      status == ApplicationStatus.pending;

  String get statusDisplayName => status.displayName;
  String get typeDisplayName => type.displayName;
  String get priorityDisplayName => priority.displayName;
  String get formattedPremium => '$currency ${premiumAmount.toStringAsFixed(2)}';
  String get formattedCoverage => '$currency ${requestedCoverageAmount.toStringAsFixed(2)}';

  int get daysSinceSubmission => DateTime.now().difference(submittedDate).inDays;
  int get processingDays => processedDate != null 
      ? processedDate!.difference(submittedDate).inDays 
      : daysSinceSubmission;

  InsuranceApplication copyWith({
    String? id,
    String? applicationNumber,
    String? userId,
    String? userName,
    String? userEmail,
    String? partnerId,
    String? partnerName,
    ApplicationType? type,
    ApplicationStatus? status,
    ApplicationPriority? priority,
    String? title,
    String? description,
    Map<String, dynamic>? applicationData,
    List<ApplicationDocument>? documents,
    List<ApplicationNote>? notes,
    double? requestedCoverageAmount,
    double? premiumAmount,
    String? currency,
    DateTime? requestedStartDate,
    DateTime? requestedEndDate,
    String? assignedTo,
    String? assignedToName,
    DateTime? assignedDate,
    String? rejectionReason,
    List<ApplicationStatusHistory>? statusHistory,
    Map<String, dynamic>? underwritingData,
    double? riskScore,
    String? riskCategory,
    DateTime? submittedDate,
    DateTime? processedDate,
    DateTime? approvedDate,
    DateTime? rejectedDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InsuranceApplication(
      id: id ?? this.id,
      applicationNumber: applicationNumber ?? this.applicationNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      applicationData: applicationData ?? this.applicationData,
      documents: documents ?? this.documents,
      notes: notes ?? this.notes,
      requestedCoverageAmount: requestedCoverageAmount ?? this.requestedCoverageAmount,
      premiumAmount: premiumAmount ?? this.premiumAmount,
      currency: currency ?? this.currency,
      requestedStartDate: requestedStartDate ?? this.requestedStartDate,
      requestedEndDate: requestedEndDate ?? this.requestedEndDate,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedDate: assignedDate ?? this.assignedDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      statusHistory: statusHistory ?? this.statusHistory,
      underwritingData: underwritingData ?? this.underwritingData,
      riskScore: riskScore ?? this.riskScore,
      riskCategory: riskCategory ?? this.riskCategory,
      submittedDate: submittedDate ?? this.submittedDate,
      processedDate: processedDate ?? this.processedDate,
      approvedDate: approvedDate ?? this.approvedDate,
      rejectedDate: rejectedDate ?? this.rejectedDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        applicationNumber,
        userId,
        userName,
        userEmail,
        partnerId,
        partnerName,
        type,
        status,
        priority,
        title,
        description,
        applicationData,
        documents,
        notes,
        requestedCoverageAmount,
        premiumAmount,
        currency,
        requestedStartDate,
        requestedEndDate,
        assignedTo,
        assignedToName,
        assignedDate,
        rejectionReason,
        statusHistory,
        underwritingData,
        riskScore,
        riskCategory,
        submittedDate,
        processedDate,
        approvedDate,
        rejectedDate,
        metadata,
        createdAt,
        updatedAt,
      ];
}

/// Application type enumeration
enum ApplicationType {
  motor,
  health,
  life,
  property,
  travel,
  business;

  String get displayName {
    switch (this) {
      case ApplicationType.motor:
        return 'Motor Insurance';
      case ApplicationType.health:
        return 'Health Insurance';
      case ApplicationType.life:
        return 'Life Insurance';
      case ApplicationType.property:
        return 'Property Insurance';
      case ApplicationType.travel:
        return 'Travel Insurance';
      case ApplicationType.business:
        return 'Business Insurance';
    }
  }
}

/// Application status enumeration
enum ApplicationStatus {
  pending,
  underReview,
  approved,
  rejected,
  cancelled,
  expired;

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.cancelled:
        return 'Cancelled';
      case ApplicationStatus.expired:
        return 'Expired';
    }
  }

  bool get isCompleted => this == approved || this == rejected;
  bool get needsAction => this == pending || this == underReview;
}

/// Application priority enumeration
enum ApplicationPriority {
  low,
  normal,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case ApplicationPriority.low:
        return 'Low';
      case ApplicationPriority.normal:
        return 'Normal';
      case ApplicationPriority.high:
        return 'High';
      case ApplicationPriority.urgent:
        return 'Urgent';
    }
  }
}

/// Application document entity
class ApplicationDocument extends Equatable {
  final String id;
  final String fileName;
  final String fileUrl;
  final String documentType;
  final int fileSize;
  final String mimeType;
  final DateTime uploadedDate;
  final String uploadedBy;

  const ApplicationDocument({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.documentType,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedDate,
    required this.uploadedBy,
  });

  @override
  List<Object?> get props => [
        id,
        fileName,
        fileUrl,
        documentType,
        fileSize,
        mimeType,
        uploadedDate,
        uploadedBy,
      ];
}

/// Application note entity
class ApplicationNote extends Equatable {
  final String id;
  final String content;
  final String addedBy;
  final String addedByName;
  final bool isInternal;
  final DateTime addedDate;

  const ApplicationNote({
    required this.id,
    required this.content,
    required this.addedBy,
    required this.addedByName,
    required this.isInternal,
    required this.addedDate,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        addedBy,
        addedByName,
        isInternal,
        addedDate,
      ];
}

/// Application status history entity
class ApplicationStatusHistory extends Equatable {
  final String id;
  final ApplicationStatus fromStatus;
  final ApplicationStatus toStatus;
  final String changedBy;
  final String changedByName;
  final String? reason;
  final DateTime changedDate;

  const ApplicationStatusHistory({
    required this.id,
    required this.fromStatus,
    required this.toStatus,
    required this.changedBy,
    required this.changedByName,
    this.reason,
    required this.changedDate,
  });

  @override
  List<Object?> get props => [
        id,
        fromStatus,
        toStatus,
        changedBy,
        changedByName,
        reason,
        changedDate,
      ];
}
