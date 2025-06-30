import 'package:equatable/equatable.dart';

/// LATRA application entity representing applications to Tanzania's Land Transport Regulatory Authority
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRAApplication extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final String applicationNumber;
  final LATRAApplicationType type;
  final LATRAApplicationStatus status;
  final String title;
  final String description;
  final Map<String, dynamic> formData;
  final List<String> requiredDocuments;
  final List<String> submittedDocuments;
  final double applicationFee;
  final String? paymentReference;
  final DateTime? submissionDate;
  final DateTime? approvalDate;
  final String? rejectionReason;
  final String? certificateNumber;
  final String? certificateUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? vehicleRegistrationNumber;

  const LATRAApplication({
    required this.id,
    required this.userId,
    this.vehicleId = '',
    required this.applicationNumber,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    this.formData = const {},
    this.requiredDocuments = const [],
    this.submittedDocuments = const [],
    this.applicationFee = 0.0,
    this.paymentReference,
    this.submissionDate,
    this.approvalDate,
    this.rejectionReason,
    this.certificateNumber,
    this.certificateUrl,
    required this.createdAt,
    required this.updatedAt,
    this.vehicleRegistrationNumber,
  });

  /// Copy with method for creating modified instances
  LATRAApplication copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    String? applicationNumber,
    LATRAApplicationType? type,
    LATRAApplicationStatus? status,
    String? title,
    String? description,
    Map<String, dynamic>? formData,
    List<String>? requiredDocuments,
    List<String>? submittedDocuments,
    double? applicationFee,
    String? paymentReference,
    DateTime? submissionDate,
    DateTime? approvalDate,
    String? rejectionReason,
    String? certificateNumber,
    String? certificateUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vehicleRegistrationNumber,
  }) {
    return LATRAApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      applicationNumber: applicationNumber ?? this.applicationNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      formData: formData ?? this.formData,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      submittedDocuments: submittedDocuments ?? this.submittedDocuments,
      applicationFee: applicationFee ?? this.applicationFee,
      paymentReference: paymentReference ?? this.paymentReference,
      submissionDate: submissionDate ?? this.submissionDate,
      approvalDate: approvalDate ?? this.approvalDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehicleRegistrationNumber:
          vehicleRegistrationNumber ?? this.vehicleRegistrationNumber,
    );
  }

  /// Check if application is completed
  bool get isCompleted => status == LATRAApplicationStatus.approved;

  /// Check if application is pending
  bool get isPending =>
      status == LATRAApplicationStatus.pending ||
      status == LATRAApplicationStatus.underReview;

  /// Check if application is rejected
  bool get isRejected => status == LATRAApplicationStatus.rejected;

  /// Check if documents are missing
  bool get hasMissingDocuments =>
      submittedDocuments.length < requiredDocuments.length;

  /// Get missing documents
  List<String> get missingDocuments => requiredDocuments
      .where((doc) => !submittedDocuments.contains(doc))
      .toList();

  @override
  List<Object?> get props => [
    id,
    userId,
    vehicleId,
    applicationNumber,
    type,
    status,
    title,
    description,
    formData,
    requiredDocuments,
    submittedDocuments,
    applicationFee,
    paymentReference,
    submissionDate,
    approvalDate,
    rejectionReason,
    certificateNumber,
    certificateUrl,
    createdAt,
    updatedAt,
  ];
}

/// LATRA application type enumeration
enum LATRAApplicationType {
  vehicleRegistration,
  licenseRenewal,
  ownershipTransfer,
  duplicateRegistration,
  temporaryPermit;

  String get name {
    switch (this) {
      case LATRAApplicationType.vehicleRegistration:
        return 'vehicle_registration';
      case LATRAApplicationType.licenseRenewal:
        return 'license_renewal';
      case LATRAApplicationType.ownershipTransfer:
        return 'ownership_transfer';
      case LATRAApplicationType.duplicateRegistration:
        return 'duplicate_registration';
      case LATRAApplicationType.temporaryPermit:
        return 'temporary_permit';
    }
  }

  String get displayName {
    switch (this) {
      case LATRAApplicationType.vehicleRegistration:
        return 'Vehicle Registration';
      case LATRAApplicationType.licenseRenewal:
        return 'License Renewal';
      case LATRAApplicationType.ownershipTransfer:
        return 'Ownership Transfer';
      case LATRAApplicationType.duplicateRegistration:
        return 'Duplicate Registration';
      case LATRAApplicationType.temporaryPermit:
        return 'Temporary Permit';
    }
  }
}

/// LATRA application status enumeration
enum LATRAApplicationStatus {
  draft,
  submitted,
  pending,
  underReview,
  documentsRequired,
  approved,
  completed,
  rejected,
  cancelled;

  String get name {
    switch (this) {
      case LATRAApplicationStatus.draft:
        return 'draft';
      case LATRAApplicationStatus.pending:
        return 'pending';
      case LATRAApplicationStatus.underReview:
        return 'under_review';
      case LATRAApplicationStatus.documentsRequired:
        return 'documents_required';
      case LATRAApplicationStatus.approved:
        return 'approved';
      case LATRAApplicationStatus.rejected:
        return 'rejected';
      case LATRAApplicationStatus.completed:
        return 'completed';
      case LATRAApplicationStatus.submitted:
        return 'submitted';
      case LATRAApplicationStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case LATRAApplicationStatus.draft:
        return 'Draft';
      case LATRAApplicationStatus.pending:
        return 'Pending';
      case LATRAApplicationStatus.underReview:
        return 'Under Review';
      case LATRAApplicationStatus.documentsRequired:
        return 'Documents Required';
      case LATRAApplicationStatus.approved:
        return 'Approved';
      case LATRAApplicationStatus.rejected:
        return 'Rejected';
      case LATRAApplicationStatus.completed:
        return 'Completed';
      case LATRAApplicationStatus.submitted:
        return 'Submitted';
      case LATRAApplicationStatus.cancelled:
        return 'Cancelled';
    }
  }
}
