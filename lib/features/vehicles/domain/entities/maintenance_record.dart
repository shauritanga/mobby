import 'package:equatable/equatable.dart';

/// Maintenance record entity representing vehicle maintenance history
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class MaintenanceRecord extends Equatable {
  final String id;
  final String vehicleId;
  final String userId;
  final MaintenanceType type;
  final String title;
  final String description;
  final DateTime serviceDate;
  final int? mileageAtService;
  final double cost;
  final String currency;
  final String? serviceProvider;
  final String? serviceProviderContact;
  final String? location;
  final List<String> partsReplaced;
  final List<String> servicesPerformed;
  final DateTime? nextServiceDate;
  final int? nextServiceMileage;
  final List<String> receiptUrls;
  final Map<String, dynamic> notes;
  final MaintenanceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.serviceDate,
    this.mileageAtService,
    required this.cost,
    this.currency = 'TZS',
    this.serviceProvider,
    this.serviceProviderContact,
    this.location,
    this.partsReplaced = const [],
    this.servicesPerformed = const [],
    this.nextServiceDate,
    this.nextServiceMileage,
    this.receiptUrls = const [],
    this.notes = const {},
    this.status = MaintenanceStatus.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if next service is due
  bool get isNextServiceDue {
    if (nextServiceDate == null) return false;
    return DateTime.now().isAfter(nextServiceDate!);
  }

  /// Check if next service is due soon (within 7 days)
  bool get isNextServiceDueSoon {
    if (nextServiceDate == null) return false;
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    return nextServiceDate!.isBefore(sevenDaysFromNow) &&
        nextServiceDate!.isAfter(now);
  }

  /// Get days until next service
  int? get daysUntilNextService {
    if (nextServiceDate == null) return null;
    final now = DateTime.now();
    if (nextServiceDate!.isBefore(now)) return 0;
    return nextServiceDate!.difference(now).inDays;
  }

  /// Get formatted cost
  String get formattedCost {
    final formatter = cost
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$currency $formatter';
  }

  /// Get service age in days
  int get serviceAgeInDays => DateTime.now().difference(serviceDate).inDays;

  /// Check if this is a recent service (within 30 days)
  bool get isRecentService => serviceAgeInDays <= 30;

  /// Get maintenance category color
  String get categoryColor {
    switch (type) {
      case MaintenanceType.oilChange:
        return '#4CAF50'; // Green
      case MaintenanceType.tireRotation:
        return '#FF9800'; // Orange
      case MaintenanceType.brakeService:
        return '#F44336'; // Red
      case MaintenanceType.engineService:
        return '#2196F3'; // Blue
      case MaintenanceType.transmission:
        return '#9C27B0'; // Purple
      case MaintenanceType.electrical:
        return '#FF5722'; // Deep Orange
      case MaintenanceType.bodywork:
        return '#607D8B'; // Blue Grey
      case MaintenanceType.inspection:
        return '#00BCD4'; // Cyan
      case MaintenanceType.other:
        return '#795548'; // Brown
    }
  }

  /// Copy with method for immutability
  MaintenanceRecord copyWith({
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
    return MaintenanceRecord(
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
      serviceProviderContact:
          serviceProviderContact ?? this.serviceProviderContact,
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

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    userId,
    type,
    title,
    description,
    serviceDate,
    mileageAtService,
    cost,
    currency,
    serviceProvider,
    serviceProviderContact,
    location,
    partsReplaced,
    servicesPerformed,
    nextServiceDate,
    nextServiceMileage,
    receiptUrls,
    notes,
    status,
    createdAt,
    updatedAt,
  ];
}

/// Maintenance type enumeration
enum MaintenanceType {
  oilChange,
  tireRotation,
  brakeService,
  engineService,
  transmission,
  electrical,
  bodywork,
  inspection,
  other;

  String get displayName {
    switch (this) {
      case MaintenanceType.oilChange:
        return 'Oil Change';
      case MaintenanceType.tireRotation:
        return 'Tire Rotation';
      case MaintenanceType.brakeService:
        return 'Brake Service';
      case MaintenanceType.engineService:
        return 'Engine Service';
      case MaintenanceType.transmission:
        return 'Transmission Service';
      case MaintenanceType.electrical:
        return 'Electrical Service';
      case MaintenanceType.bodywork:
        return 'Bodywork';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case MaintenanceType.oilChange:
        return 'Engine oil and filter change';
      case MaintenanceType.tireRotation:
        return 'Tire rotation and alignment';
      case MaintenanceType.brakeService:
        return 'Brake system service and repair';
      case MaintenanceType.engineService:
        return 'Engine maintenance and repair';
      case MaintenanceType.transmission:
        return 'Transmission service and repair';
      case MaintenanceType.electrical:
        return 'Electrical system service';
      case MaintenanceType.bodywork:
        return 'Body repair and painting';
      case MaintenanceType.inspection:
        return 'Vehicle safety inspection';
      case MaintenanceType.other:
        return 'Other maintenance activity';
    }
  }
}

/// Maintenance status enumeration
enum MaintenanceStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  overdue;

  String get displayName {
    switch (this) {
      case MaintenanceStatus.scheduled:
        return 'Scheduled';
      case MaintenanceStatus.inProgress:
        return 'In Progress';
      case MaintenanceStatus.completed:
        return 'Completed';
      case MaintenanceStatus.cancelled:
        return 'Cancelled';
      case MaintenanceStatus.overdue:
        return 'Overdue';
    }
  }
}
