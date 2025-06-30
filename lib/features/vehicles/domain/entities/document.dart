import 'package:equatable/equatable.dart';

/// Document entity representing vehicle-related documents
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class Document extends Equatable {
  final String id;
  final String vehicleId;
  final String userId;
  final DocumentType type;
  final String title;
  final String? description;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSize;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issuer;
  final String? documentNumber;
  final DocumentStatus status;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Document({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.issueDate,
    this.expiryDate,
    this.issuer,
    this.documentNumber,
    this.status = DocumentStatus.active,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if document is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Check if document is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return expiryDate!.isBefore(thirtyDaysFromNow) && expiryDate!.isAfter(now);
  }

  /// Get days until expiry
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    if (expiryDate!.isBefore(now)) return 0;
    return expiryDate!.difference(now).inDays;
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Check if document is an image
  bool get isImage {
    final imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageTypes.contains(fileType.toLowerCase());
  }

  /// Check if document is a PDF
  bool get isPdf => fileType.toLowerCase() == 'pdf';

  /// Get document icon based on type
  String get iconName {
    if (isImage) return 'image';
    if (isPdf) return 'pdf';
    return 'document';
  }

  /// Copy with method for immutability
  Document copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    DocumentType? type,
    String? title,
    String? description,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? issuer,
    String? documentNumber,
    DocumentStatus? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      issuer: issuer ?? this.issuer,
      documentNumber: documentNumber ?? this.documentNumber,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        userId,
        type,
        title,
        description,
        fileUrl,
        fileName,
        fileType,
        fileSize,
        issueDate,
        expiryDate,
        issuer,
        documentNumber,
        status,
        metadata,
        createdAt,
        updatedAt,
      ];
}

/// Document type enumeration
enum DocumentType {
  registration,
  insurance,
  inspection,
  license,
  permit,
  receipt,
  warranty,
  manual,
  photo,
  other;

  String get displayName {
    switch (this) {
      case DocumentType.registration:
        return 'Vehicle Registration';
      case DocumentType.insurance:
        return 'Insurance Certificate';
      case DocumentType.inspection:
        return 'Inspection Certificate';
      case DocumentType.license:
        return 'Driving License';
      case DocumentType.permit:
        return 'Special Permit';
      case DocumentType.receipt:
        return 'Purchase Receipt';
      case DocumentType.warranty:
        return 'Warranty Document';
      case DocumentType.manual:
        return 'Owner\'s Manual';
      case DocumentType.photo:
        return 'Vehicle Photo';
      case DocumentType.other:
        return 'Other Document';
    }
  }

  String get description {
    switch (this) {
      case DocumentType.registration:
        return 'Official vehicle registration certificate';
      case DocumentType.insurance:
        return 'Vehicle insurance policy certificate';
      case DocumentType.inspection:
        return 'Vehicle safety inspection certificate';
      case DocumentType.license:
        return 'Driver\'s license document';
      case DocumentType.permit:
        return 'Special driving or vehicle permit';
      case DocumentType.receipt:
        return 'Vehicle purchase receipt or invoice';
      case DocumentType.warranty:
        return 'Vehicle or parts warranty document';
      case DocumentType.manual:
        return 'Vehicle owner\'s manual or guide';
      case DocumentType.photo:
        return 'Vehicle photograph or image';
      case DocumentType.other:
        return 'Other vehicle-related document';
    }
  }

  bool get hasExpiryDate {
    switch (this) {
      case DocumentType.registration:
      case DocumentType.insurance:
      case DocumentType.inspection:
      case DocumentType.license:
      case DocumentType.permit:
      case DocumentType.warranty:
        return true;
      case DocumentType.receipt:
      case DocumentType.manual:
      case DocumentType.photo:
      case DocumentType.other:
        return false;
    }
  }
}

/// Document status enumeration
enum DocumentStatus {
  active,
  expired,
  pending,
  rejected,
  archived;

  String get displayName {
    switch (this) {
      case DocumentStatus.active:
        return 'Active';
      case DocumentStatus.expired:
        return 'Expired';
      case DocumentStatus.pending:
        return 'Pending Verification';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.archived:
        return 'Archived';
    }
  }
}
