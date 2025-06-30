import 'package:equatable/equatable.dart';

/// LATRA document entity representing documents related to LATRA applications
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRADocument extends Equatable {
  final String id;
  final String applicationId;
  final String userId;
  final String? vehicleId;
  final LATRADocumentType type;
  final String title;
  final String? description;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSize;
  final LATRADocumentStatus status;
  final DateTime? verificationDate;
  final String? verificationNotes;
  final String? verifiedBy;
  final bool isRequired;
  final DateTime? expiryDate;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LATRADocument({
    required this.id,
    required this.applicationId,
    required this.userId,
    this.vehicleId,
    required this.type,
    required this.title,
    this.description,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.status,
    this.verificationDate,
    this.verificationNotes,
    this.verifiedBy,
    this.isRequired = true,
    this.expiryDate,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if document is verified
  bool get isVerified => status == LATRADocumentStatus.verified;

  /// Check if document is rejected
  bool get isRejected => status == LATRADocumentStatus.rejected;

  /// Check if document is pending verification
  bool get isPending => status == LATRADocumentStatus.pending;

  /// Check if document is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Check if document expires soon (within 30 days)
  bool get expiresSoon {
    if (expiryDate == null) return false;
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return expiryDate!.isBefore(thirtyDaysFromNow) && !isExpired;
  }

  /// Get file size in human readable format
  String get fileSizeFormatted {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Create copy with updated fields
  LATRADocument copyWith({
    String? id,
    String? applicationId,
    String? userId,
    String? vehicleId,
    LATRADocumentType? type,
    String? title,
    String? description,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    LATRADocumentStatus? status,
    DateTime? verificationDate,
    String? verificationNotes,
    String? verifiedBy,
    bool? isRequired,
    DateTime? expiryDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LATRADocument(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      verificationDate: verificationDate ?? this.verificationDate,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      isRequired: isRequired ?? this.isRequired,
      expiryDate: expiryDate ?? this.expiryDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    applicationId,
    userId,
    vehicleId,
    type,
    title,
    description,
    fileUrl,
    fileName,
    fileType,
    fileSize,
    status,
    verificationDate,
    verificationNotes,
    verifiedBy,
    isRequired,
    expiryDate,
    metadata,
    createdAt,
    updatedAt,
  ];
}

/// LATRA document type enumeration
enum LATRADocumentType {
  nationalId,
  drivingLicense,
  vehicleRegistration,
  insuranceCertificate,
  inspectionCertificate,
  purchaseReceipt,
  importPermit,
  taxClearance,
  ownershipTransfer,
  powerOfAttorney,
  // Additional document types for license applications
  insurance,
  inspection,
  medicalCertificate,
  passportPhoto,
  proofOfResidence,
  other;

  String get displayName {
    switch (this) {
      case LATRADocumentType.nationalId:
        return 'National ID';
      case LATRADocumentType.drivingLicense:
        return 'Driving License';
      case LATRADocumentType.vehicleRegistration:
        return 'Vehicle Registration';
      case LATRADocumentType.insuranceCertificate:
        return 'Insurance Certificate';
      case LATRADocumentType.inspectionCertificate:
        return 'Inspection Certificate';
      case LATRADocumentType.purchaseReceipt:
        return 'Purchase Receipt';
      case LATRADocumentType.importPermit:
        return 'Import Permit';
      case LATRADocumentType.taxClearance:
        return 'Tax Clearance';
      case LATRADocumentType.ownershipTransfer:
        return 'Ownership Transfer';
      case LATRADocumentType.powerOfAttorney:
        return 'Power of Attorney';
      case LATRADocumentType.insurance:
        return 'Insurance Certificate';
      case LATRADocumentType.inspection:
        return 'Inspection Certificate';
      case LATRADocumentType.medicalCertificate:
        return 'Medical Certificate';
      case LATRADocumentType.passportPhoto:
        return 'Passport Photo';
      case LATRADocumentType.proofOfResidence:
        return 'Proof of Residence';
      case LATRADocumentType.other:
        return 'Other Document';
    }
  }
}

/// LATRA document status enumeration
enum LATRADocumentStatus {
  pending,
  verified,
  rejected,
  uploaded,
  expired;

  String get displayName {
    switch (this) {
      case LATRADocumentStatus.pending:
        return 'Pending Verification';
      case LATRADocumentStatus.verified:
        return 'Verified';
      case LATRADocumentStatus.uploaded:
        return 'Uploaded';
      case LATRADocumentStatus.rejected:
        return 'Rejected';
      case LATRADocumentStatus.expired:
        return 'Expired';
    }
  }
}
