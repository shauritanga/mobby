import '../../domain/entities/document.dart';

/// Document model for data layer
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class DocumentModel extends Document {
  const DocumentModel({
    required super.id,
    required super.vehicleId,
    required super.userId,
    required super.type,
    required super.title,
    super.description,
    required super.fileUrl,
    required super.fileName,
    required super.fileType,
    required super.fileSize,
    super.issueDate,
    super.expiryDate,
    super.issuer,
    super.documentNumber,
    super.status,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create DocumentModel from Document entity
  factory DocumentModel.fromEntity(Document document) {
    return DocumentModel(
      id: document.id,
      vehicleId: document.vehicleId,
      userId: document.userId,
      type: document.type,
      title: document.title,
      description: document.description,
      fileUrl: document.fileUrl,
      fileName: document.fileName,
      fileType: document.fileType,
      fileSize: document.fileSize,
      issueDate: document.issueDate,
      expiryDate: document.expiryDate,
      issuer: document.issuer,
      documentNumber: document.documentNumber,
      status: document.status,
      metadata: document.metadata,
      createdAt: document.createdAt,
      updatedAt: document.updatedAt,
    );
  }

  /// Create DocumentModel from JSON
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      userId: json['userId'] ?? '',
      type: _parseDocumentType(json['type']),
      title: json['title'] ?? '',
      description: json['description'],
      fileUrl: json['fileUrl'] ?? '',
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      issueDate: json['issueDate'] != null
          ? DateTime.parse(json['issueDate'])
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      issuer: json['issuer'],
      documentNumber: json['documentNumber'],
      status: _parseDocumentStatus(json['status']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert DocumentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'issuer': issuer,
      'documentNumber': documentNumber,
      'status': status.name,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert DateTime objects to Firestore Timestamps if needed
    return json;
  }

  /// Create from Firestore document
  factory DocumentModel.fromFirestore(Map<String, dynamic> doc, String id) {
    final data = Map<String, dynamic>.from(doc);
    data['id'] = id;
    return DocumentModel.fromJson(data);
  }

  /// Copy with method for DocumentModel
  DocumentModel copyWithModel({
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
    return DocumentModel(
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

  // Helper methods for parsing enums
  static DocumentType _parseDocumentType(dynamic value) {
    if (value == null) return DocumentType.other;
    if (value is DocumentType) return value;
    return DocumentType.values.firstWhere(
      (e) => e.name == value.toString(),
      orElse: () => DocumentType.other,
    );
  }

  static DocumentStatus _parseDocumentStatus(dynamic value) {
    if (value == null) return DocumentStatus.active;
    if (value is DocumentStatus) return value;
    return DocumentStatus.values.firstWhere(
      (e) => e.name == value.toString(),
      orElse: () => DocumentStatus.active,
    );
  }
}
