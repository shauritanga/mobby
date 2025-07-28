import '../../domain/entities/latra_document.dart';

/// LATRA document model for data layer
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRADocumentModel extends LATRADocument {
  const LATRADocumentModel({
    required super.id,
    required super.applicationId,
    required super.userId,
    super.vehicleId,
    required super.type,
    required super.title,
    super.description,
    required super.fileUrl,
    required super.fileName,
    required super.fileType,
    required super.fileSize,
    required super.status,
    super.verificationDate,
    super.verificationNotes,
    super.verifiedBy,
    super.isRequired,
    super.expiryDate,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from domain entity
  factory LATRADocumentModel.fromEntity(LATRADocument document) {
    return LATRADocumentModel(
      id: document.id,
      applicationId: document.applicationId,
      userId: document.userId,
      vehicleId: document.vehicleId,
      type: document.type,
      title: document.title,
      description: document.description,
      fileUrl: document.fileUrl,
      fileName: document.fileName,
      fileType: document.fileType,
      fileSize: document.fileSize,
      status: document.status,
      verificationDate: document.verificationDate,
      verificationNotes: document.verificationNotes,
      verifiedBy: document.verifiedBy,
      isRequired: document.isRequired,
      expiryDate: document.expiryDate,
      metadata: document.metadata,
      createdAt: document.createdAt,
      updatedAt: document.updatedAt,
    );
  }

  /// Create model from JSON
  factory LATRADocumentModel.fromJson(Map<String, dynamic> json) {
    return LATRADocumentModel(
      id: json['id'] as String,
      applicationId: json['applicationId'] as String,
      userId: json['userId'] as String,
      vehicleId: json['vehicleId'] as String?,
      type: LATRADocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LATRADocumentType.other,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      status: LATRADocumentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LATRADocumentStatus.pending,
      ),
      verificationDate: json['verificationDate'] != null
          ? DateTime.parse(json['verificationDate'] as String)
          : null,
      verificationNotes: json['verificationNotes'] as String?,
      verifiedBy: json['verifiedBy'] as String?,
      isRequired: json['isRequired'] as bool? ?? true,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'userId': userId,
      'vehicleId': vehicleId,
      'type': type.name,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'status': status.name,
      'verificationDate': verificationDate?.toIso8601String(),
      'verificationNotes': verificationNotes,
      'verifiedBy': verifiedBy,
      'isRequired': isRequired,
      'expiryDate': expiryDate?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert model to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert DateTime objects to Firestore Timestamps if needed
    return json;
  }

  /// Create model from Firestore document
  factory LATRADocumentModel.fromFirestore(
    Map<String, dynamic> doc,
    String id,
  ) {
    final data = Map<String, dynamic>.from(doc);
    data['id'] = id;
    return LATRADocumentModel.fromJson(data);
  }

  /// Create copy with updated fields
  @override
  LATRADocumentModel copyWith({
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
    return LATRADocumentModel(
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
}
