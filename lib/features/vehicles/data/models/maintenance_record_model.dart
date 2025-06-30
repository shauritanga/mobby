import '../../domain/entities/maintenance_record.dart';

/// Maintenance record model for data layer
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class MaintenanceRecordModel extends MaintenanceRecord {
  const MaintenanceRecordModel({
    required super.id,
    required super.vehicleId,
    required super.userId,
    required super.type,
    required super.title,
    required super.description,
    required super.serviceDate,
    super.mileageAtService,
    required super.cost,
    super.currency,
    super.serviceProvider,
    super.serviceProviderContact,
    super.location,
    super.partsReplaced,
    super.servicesPerformed,
    super.nextServiceDate,
    super.nextServiceMileage,
    super.receiptUrls,
    super.notes,
    super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create MaintenanceRecordModel from MaintenanceRecord entity
  factory MaintenanceRecordModel.fromEntity(MaintenanceRecord record) {
    return MaintenanceRecordModel(
      id: record.id,
      vehicleId: record.vehicleId,
      userId: record.userId,
      type: record.type,
      title: record.title,
      description: record.description,
      serviceDate: record.serviceDate,
      mileageAtService: record.mileageAtService,
      cost: record.cost,
      currency: record.currency,
      serviceProvider: record.serviceProvider,
      serviceProviderContact: record.serviceProviderContact,
      location: record.location,
      partsReplaced: record.partsReplaced,
      servicesPerformed: record.servicesPerformed,
      nextServiceDate: record.nextServiceDate,
      nextServiceMileage: record.nextServiceMileage,
      receiptUrls: record.receiptUrls,
      notes: record.notes,
      status: record.status,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  /// Create MaintenanceRecordModel from JSON
  factory MaintenanceRecordModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecordModel(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      userId: json['userId'] ?? '',
      type: _parseMaintenanceType(json['type']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      serviceDate: DateTime.parse(json['serviceDate']),
      mileageAtService: json['mileageAtService'],
      cost: (json['cost'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'TZS',
      serviceProvider: json['serviceProvider'],
      serviceProviderContact: json['serviceProviderContact'],
      location: json['location'],
      partsReplaced: List<String>.from(json['partsReplaced'] ?? []),
      servicesPerformed: List<String>.from(json['servicesPerformed'] ?? []),
      nextServiceDate: json['nextServiceDate'] != null
          ? DateTime.parse(json['nextServiceDate'])
          : null,
      nextServiceMileage: json['nextServiceMileage'],
      receiptUrls: List<String>.from(json['receiptUrls'] ?? []),
      notes: Map<String, dynamic>.from(json['notes'] ?? {}),
      status: _parseMaintenanceStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert MaintenanceRecordModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'serviceDate': serviceDate.toIso8601String(),
      'mileageAtService': mileageAtService,
      'cost': cost,
      'currency': currency,
      'serviceProvider': serviceProvider,
      'serviceProviderContact': serviceProviderContact,
      'location': location,
      'partsReplaced': partsReplaced,
      'servicesPerformed': servicesPerformed,
      'nextServiceDate': nextServiceDate?.toIso8601String(),
      'nextServiceMileage': nextServiceMileage,
      'receiptUrls': receiptUrls,
      'notes': notes,
      'status': status.name,
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
  factory MaintenanceRecordModel.fromFirestore(Map<String, dynamic> doc, String id) {
    final data = Map<String, dynamic>.from(doc);
    data['id'] = id;
    return MaintenanceRecordModel.fromJson(data);
  }

  /// Copy with method for MaintenanceRecordModel
  MaintenanceRecordModel copyWithModel({
    String? id,
    String? vehicleId,
    String? userId,
    MaintenanceType? type,
    String? title,
    String? description,
    DateTime? serviceDate,
    int? mileageAtService,
    double? cost,
    String? currency,
    String? serviceProvider,
    String? serviceProviderContact,
    String? location,
    List<String>? partsReplaced,
    List<String>? servicesPerformed,
    DateTime? nextServiceDate,
    int? nextServiceMileage,
    List<String>? receiptUrls,
    Map<String, dynamic>? notes,
    MaintenanceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceRecordModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      serviceDate: serviceDate ?? this.serviceDate,
      mileageAtService: mileageAtService ?? this.mileageAtService,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      serviceProviderContact: serviceProviderContact ?? this.serviceProviderContact,
      location: location ?? this.location,
      partsReplaced: partsReplaced ?? this.partsReplaced,
      servicesPerformed: servicesPerformed ?? this.servicesPerformed,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      nextServiceMileage: nextServiceMileage ?? this.nextServiceMileage,
      receiptUrls: receiptUrls ?? this.receiptUrls,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for parsing enums
  static MaintenanceType _parseMaintenanceType(dynamic value) {
    if (value == null) return MaintenanceType.other;
    if (value is MaintenanceType) return value;
    return MaintenanceType.values.firstWhere(
      (e) => e.name == value.toString(),
      orElse: () => MaintenanceType.other,
    );
  }

  static MaintenanceStatus _parseMaintenanceStatus(dynamic value) {
    if (value == null) return MaintenanceStatus.completed;
    if (value is MaintenanceStatus) return value;
    return MaintenanceStatus.values.firstWhere(
      (e) => e.name == value.toString(),
      orElse: () => MaintenanceStatus.completed,
    );
  }
}
