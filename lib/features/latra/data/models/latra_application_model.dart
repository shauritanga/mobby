import '../../domain/entities/latra_application.dart';

/// LATRA application model for data layer
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRAApplicationModel extends LATRAApplication {
  const LATRAApplicationModel({
    required super.id,
    required super.userId,
    required super.vehicleId,
    required super.applicationNumber,
    required super.type,
    required super.status,
    required super.title,
    required super.description,
    required super.formData,
    required super.requiredDocuments,
    super.submittedDocuments,
    required super.applicationFee,
    super.paymentReference,
    super.submissionDate,
    super.approvalDate,
    super.rejectionReason,
    super.certificateNumber,
    super.certificateUrl,
    required super.createdAt,
    required super.updatedAt,
    super.vehicleRegistrationNumber,
  });

  /// Create model from domain entity
  factory LATRAApplicationModel.fromEntity(LATRAApplication application) {
    return LATRAApplicationModel(
      id: application.id,
      userId: application.userId,
      vehicleId: application.vehicleId,
      applicationNumber: application.applicationNumber,
      type: application.type,
      status: application.status,
      title: application.title,
      description: application.description,
      formData: application.formData,
      requiredDocuments: application.requiredDocuments,
      submittedDocuments: application.submittedDocuments,
      applicationFee: application.applicationFee,
      paymentReference: application.paymentReference,
      submissionDate: application.submissionDate,
      approvalDate: application.approvalDate,
      rejectionReason: application.rejectionReason,
      certificateNumber: application.certificateNumber,
      certificateUrl: application.certificateUrl,
      createdAt: application.createdAt,
      updatedAt: application.updatedAt,
      vehicleRegistrationNumber: application.vehicleRegistrationNumber,
    );
  }

  /// Create model from JSON
  factory LATRAApplicationModel.fromJson(Map<String, dynamic> json) {
    return LATRAApplicationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vehicleId: json['vehicleId'] as String,
      applicationNumber: json['applicationNumber'] as String,
      type: LATRAApplicationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LATRAApplicationType.vehicleRegistration,
      ),
      status: LATRAApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LATRAApplicationStatus.draft,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      formData: Map<String, dynamic>.from(json['formData'] as Map),
      requiredDocuments: List<String>.from(json['requiredDocuments'] as List),
      submittedDocuments: List<String>.from(
        json['submittedDocuments'] as List? ?? [],
      ),
      applicationFee: (json['applicationFee'] as num).toDouble(),
      paymentReference: json['paymentReference'] as String?,
      submissionDate: json['submissionDate'] != null
          ? DateTime.parse(json['submissionDate'] as String)
          : null,
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      certificateNumber: json['certificateNumber'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      vehicleRegistrationNumber: json['vehicleRegistrationNumber'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'applicationNumber': applicationNumber,
      'type': type.name,
      'status': status.name,
      'title': title,
      'description': description,
      'formData': formData,
      'requiredDocuments': requiredDocuments,
      'submittedDocuments': submittedDocuments,
      'applicationFee': applicationFee,
      'paymentReference': paymentReference,
      'submissionDate': submissionDate?.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'certificateNumber': certificateNumber,
      'certificateUrl': certificateUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'vehicleRegistrationNumber': vehicleRegistrationNumber,
    };
  }

  /// Convert model to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert DateTime objects to Firestore Timestamps if needed
    return json;
  }

  /// Create model from Firestore document
  factory LATRAApplicationModel.fromFirestore(
    Map<String, dynamic> doc,
    String id,
  ) {
    final data = Map<String, dynamic>.from(doc);
    data['id'] = id;
    return LATRAApplicationModel.fromJson(data);
  }

  /// Create copy with updated fields
  @override
  LATRAApplicationModel copyWith({
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
    return LATRAApplicationModel(
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
}
