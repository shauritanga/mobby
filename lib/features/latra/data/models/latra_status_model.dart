import '../../domain/entities/latra_status.dart';

/// LATRA status model for data layer
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRAStatusModel extends LATRAStatus {
  const LATRAStatusModel({
    required super.id,
    required super.applicationId,
    required super.userId,
    required super.type,
    required super.title,
    required super.description,
    super.details,
    required super.timestamp,
    super.officerName,
    super.officeLocation,
    super.metadata,
  });

  /// Create model from domain entity
  factory LATRAStatusModel.fromEntity(LATRAStatus status) {
    return LATRAStatusModel(
      id: status.id,
      applicationId: status.applicationId,
      userId: status.userId,
      type: status.type,
      title: status.title,
      description: status.description,
      details: status.details,
      timestamp: status.timestamp,
      officerName: status.officerName,
      officeLocation: status.officeLocation,
      metadata: status.metadata,
    );
  }

  /// Create model from JSON
  factory LATRAStatusModel.fromJson(Map<String, dynamic> json) {
    return LATRAStatusModel(
      id: json['id'] as String,
      applicationId: json['applicationId'] as String,
      userId: json['userId'] as String,
      type: LATRAStatusType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LATRAStatusType.submitted,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      details: json['details'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      officerName: json['officerName'] as String?,
      officeLocation: json['officeLocation'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'officerName': officerName,
      'officeLocation': officeLocation,
      'metadata': metadata,
    };
  }

  /// Convert model to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert DateTime objects to Firestore Timestamps if needed
    return json;
  }

  /// Create model from Firestore document
  factory LATRAStatusModel.fromFirestore(Map<String, dynamic> doc, String id) {
    final data = Map<String, dynamic>.from(doc);
    data['id'] = id;
    return LATRAStatusModel.fromJson(data);
  }

  /// Create copy with updated fields
  LATRAStatusModel copyWith({
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
    return LATRAStatusModel(
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
}
