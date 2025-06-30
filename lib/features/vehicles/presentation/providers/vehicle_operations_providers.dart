import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/maintenance_record.dart';
import '../../domain/usecases/manage_vehicles_usecase.dart';
import '../../domain/usecases/manage_documents_usecase.dart';
import '../../domain/usecases/manage_maintenance_usecase.dart';
import 'vehicle_providers.dart';

/// Vehicle operations providers for handling CRUD operations
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature

// Vehicle operations provider
final vehicleOperationsProvider = Provider<VehicleOperations>((ref) {
  return VehicleOperations(ref);
});

// Document operations provider
final documentOperationsProvider = Provider<DocumentOperations>((ref) {
  return DocumentOperations(ref);
});

// Maintenance operations provider
final maintenanceOperationsProvider = Provider<MaintenanceOperations>((ref) {
  return MaintenanceOperations(ref);
});

// Vehicle operations class
class VehicleOperations {
  final Ref ref;

  VehicleOperations(this.ref);

  Future<Vehicle> createVehicle(CreateVehicleParams params) async {
    final useCase = ref.read(createVehicleUseCaseProvider);
    final result = await useCase(params);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (vehicle) {
        // Invalidate related providers to refresh UI
        ref.invalidate(userVehiclesProvider(params.userId));
        ref.invalidate(currentUserVehiclesProvider);
        ref.invalidate(vehicleStatisticsProvider(params.userId));
        return vehicle;
      },
    );
  }

  Future<Vehicle> updateVehicle(UpdateVehicleParams params) async {
    final useCase = ref.read(updateVehicleUseCaseProvider);
    final result = await useCase(params);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (vehicle) {
        // Invalidate related providers to refresh UI
        ref.invalidate(vehicleByIdProvider(params.vehicleId));
        ref.invalidate(userVehiclesProvider(vehicle.userId));
        ref.invalidate(currentUserVehiclesProvider);
        ref.invalidate(vehicleStatisticsProvider(vehicle.userId));
        return vehicle;
      },
    );
  }

  Future<void> deleteVehicle(String vehicleId, String userId) async {
    final useCase = ref.read(deleteVehicleUseCaseProvider);
    final result = await useCase(vehicleId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Invalidate related providers to refresh UI
        ref.invalidate(vehicleByIdProvider(vehicleId));
        ref.invalidate(userVehiclesProvider(userId));
        ref.invalidate(currentUserVehiclesProvider);
        ref.invalidate(vehicleStatisticsProvider(userId));
        ref.invalidate(vehicleDocumentsProvider(vehicleId));
        ref.invalidate(vehicleMaintenanceRecordsProvider(vehicleId));
      },
    );
  }

  Future<List<Vehicle>> searchVehicles(String userId, String query) async {
    final useCase = ref.read(searchVehiclesUseCaseProvider);
    final result = await useCase(SearchVehiclesParams(userId: userId, query: query));
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (vehicles) => vehicles,
    );
  }

  Future<String> uploadVehicleImage(String vehicleId, String filePath) async {
    final repository = ref.read(vehicleRepositoryProvider);
    final result = await repository.uploadVehicleImage(vehicleId, filePath);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (imageUrl) => imageUrl,
    );
  }

  Future<bool> validatePlateNumber(String plateNumber, {String? excludeVehicleId}) async {
    final repository = ref.read(vehicleRepositoryProvider);
    final result = await repository.validatePlateNumber(plateNumber, excludeVehicleId: excludeVehicleId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (isValid) => isValid,
    );
  }

  Future<bool> validateEngineNumber(String engineNumber, {String? excludeVehicleId}) async {
    final repository = ref.read(vehicleRepositoryProvider);
    final result = await repository.validateEngineNumber(engineNumber, excludeVehicleId: excludeVehicleId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (isValid) => isValid,
    );
  }

  Future<bool> validateChassisNumber(String chassisNumber, {String? excludeVehicleId}) async {
    final repository = ref.read(vehicleRepositoryProvider);
    final result = await repository.validateChassisNumber(chassisNumber, excludeVehicleId: excludeVehicleId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (isValid) => isValid,
    );
  }

  Future<bool> validateVin(String vin, {String? excludeVehicleId}) async {
    final repository = ref.read(vehicleRepositoryProvider);
    final result = await repository.validateVin(vin, excludeVehicleId: excludeVehicleId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (isValid) => isValid,
    );
  }
}

// Document operations class
class DocumentOperations {
  final Ref ref;

  DocumentOperations(this.ref);

  Future<Document> createDocument(CreateDocumentParams params) async {
    final useCase = ref.read(createDocumentUseCaseProvider);
    final result = await useCase(params);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (document) {
        // Invalidate related providers to refresh UI
        ref.invalidate(vehicleDocumentsProvider(params.vehicleId));
        ref.invalidate(userDocumentsProvider(params.userId));
        ref.invalidate(currentUserDocumentsProvider);
        ref.invalidate(expiredDocumentsProvider);
        ref.invalidate(expiringSoonDocumentsProvider);
        ref.invalidate(vehicleAlertsProvider);
        ref.invalidate(vehicleStatisticsProvider(params.userId));
        return document;
      },
    );
  }

  Future<Document> updateDocument(UpdateDocumentParams params) async {
    final useCase = ref.read(updateDocumentUseCaseProvider);
    final result = await useCase(params);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (document) {
        // Invalidate related providers to refresh UI
        ref.invalidate(vehicleDocumentsProvider(document.vehicleId));
        ref.invalidate(userDocumentsProvider(document.userId));
        ref.invalidate(currentUserDocumentsProvider);
        ref.invalidate(expiredDocumentsProvider);
        ref.invalidate(expiringSoonDocumentsProvider);
        ref.invalidate(vehicleAlertsProvider);
        ref.invalidate(vehicleStatisticsProvider(document.userId));
        return document;
      },
    );
  }

  Future<void> deleteDocument(String documentId, String vehicleId, String userId) async {
    final useCase = ref.read(deleteDocumentUseCaseProvider);
    final result = await useCase(documentId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Invalidate related providers to refresh UI
        ref.invalidate(vehicleDocumentsProvider(vehicleId));
        ref.invalidate(userDocumentsProvider(userId));
        ref.invalidate(currentUserDocumentsProvider);
        ref.invalidate(expiredDocumentsProvider);
        ref.invalidate(expiringSoonDocumentsProvider);
        ref.invalidate(vehicleAlertsProvider);
        ref.invalidate(vehicleStatisticsProvider(userId));
      },
    );
  }

  Future<String> uploadDocument(String documentId, String filePath) async {
    final useCase = ref.read(uploadDocumentUseCaseProvider);
    final result = await useCase(UploadDocumentParams(documentId: documentId, filePath: filePath));
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (documentUrl) => documentUrl,
    );
  }

  Future<List<Document>> getExpiredDocuments(String userId) async {
    final useCase = ref.read(getExpiredDocumentsUseCaseProvider);
    final result = await useCase(userId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (documents) => documents,
    );
  }

  Future<List<Document>> getExpiringSoonDocuments(String userId) async {
    final useCase = ref.read(getExpiringSoonDocumentsUseCaseProvider);
    final result = await useCase(userId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (documents) => documents,
    );
  }
}

// Maintenance operations class
class MaintenanceOperations {
  final Ref ref;

  MaintenanceOperations(this.ref);

  Future<MaintenanceRecord> createMaintenanceRecord(CreateMaintenanceRecordParams params) async {
    final useCase = ref.read(createMaintenanceRecordUseCaseProvider);
    final result = await useCase(params);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (record) {
        // Invalidate related providers to refresh UI
        ref.invalidate(vehicleMaintenanceRecordsProvider(params.vehicleId));
        ref.invalidate(userMaintenanceRecordsProvider(params.userId));
        ref.invalidate(currentUserMaintenanceRecordsProvider);
        ref.invalidate(overdueMaintenanceRecordsProvider);
        ref.invalidate(vehicleAlertsProvider);
        ref.invalidate(vehicleStatisticsProvider(params.userId));
        return record;
      },
    );
  }

  Future<MaintenanceRecord> updateMaintenanceRecord(UpdateMaintenanceRecordParams params) async {
    final useCase = ref.read(updateMaintenanceRecordUseCaseProvider);
    final result = await useCase(params);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (record) {
        // Invalidate related providers to refresh UI
        ref.invalidate(vehicleMaintenanceRecordsProvider(record.vehicleId));
        ref.invalidate(userMaintenanceRecordsProvider(record.userId));
        ref.invalidate(currentUserMaintenanceRecordsProvider);
        ref.invalidate(overdueMaintenanceRecordsProvider);
        ref.invalidate(vehicleAlertsProvider);
        ref.invalidate(vehicleStatisticsProvider(record.userId));
        return record;
      },
    );
  }

  Future<void> deleteMaintenanceRecord(String recordId, String vehicleId, String userId) async {
    final useCase = ref.read(deleteMaintenanceRecordUseCaseProvider);
    final result = await useCase(recordId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Invalidate related providers to refresh UI
        ref.invalidate(vehicleMaintenanceRecordsProvider(vehicleId));
        ref.invalidate(userMaintenanceRecordsProvider(userId));
        ref.invalidate(currentUserMaintenanceRecordsProvider);
        ref.invalidate(overdueMaintenanceRecordsProvider);
        ref.invalidate(vehicleAlertsProvider);
        ref.invalidate(vehicleStatisticsProvider(userId));
      },
    );
  }

  Future<List<MaintenanceRecord>> getOverdueMaintenanceRecords(String userId) async {
    final useCase = ref.read(getOverdueMaintenanceRecordsUseCaseProvider);
    final result = await useCase(userId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (records) => records,
    );
  }

  Future<double> getTotalMaintenanceCost(String vehicleId, {DateTime? startDate, DateTime? endDate}) async {
    final useCase = ref.read(getTotalMaintenanceCostUseCaseProvider);
    final result = await useCase(GetMaintenanceCostParams(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
    ));
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (cost) => cost,
    );
  }

  Future<Map<String, dynamic>> getMaintenanceStatistics(String vehicleId) async {
    final useCase = ref.read(getMaintenanceStatisticsUseCaseProvider);
    final result = await useCase(vehicleId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (statistics) => statistics,
    );
  }

  Future<String> uploadMaintenanceReceipt(String recordId, String filePath) async {
    final repository = ref.read(vehicleRepositoryProvider);
    final result = await repository.uploadMaintenanceReceipt(recordId, filePath);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (receiptUrl) => receiptUrl,
    );
  }
}

// Vehicle filter state provider
final vehicleFilterStateProvider = StateNotifierProvider<VehicleFilterStateNotifier, VehicleFilterState>((ref) {
  return VehicleFilterStateNotifier();
});

// Vehicle filter state
class VehicleFilterState {
  final VehicleType? selectedType;
  final VehicleStatus? selectedStatus;
  final FuelType? selectedFuelType;
  final String? searchQuery;
  final bool showExpiredDocuments;
  final bool showOverdueMaintenance;

  const VehicleFilterState({
    this.selectedType,
    this.selectedStatus,
    this.selectedFuelType,
    this.searchQuery,
    this.showExpiredDocuments = false,
    this.showOverdueMaintenance = false,
  });

  VehicleFilterState copyWith({
    VehicleType? selectedType,
    VehicleStatus? selectedStatus,
    FuelType? selectedFuelType,
    String? searchQuery,
    bool? showExpiredDocuments,
    bool? showOverdueMaintenance,
  }) {
    return VehicleFilterState(
      selectedType: selectedType,
      selectedStatus: selectedStatus,
      selectedFuelType: selectedFuelType,
      searchQuery: searchQuery,
      showExpiredDocuments: showExpiredDocuments ?? this.showExpiredDocuments,
      showOverdueMaintenance: showOverdueMaintenance ?? this.showOverdueMaintenance,
    );
  }

  bool get hasActiveFilters {
    return selectedType != null ||
           selectedStatus != null ||
           selectedFuelType != null ||
           (searchQuery?.isNotEmpty == true) ||
           showExpiredDocuments ||
           showOverdueMaintenance;
  }
}

// Vehicle filter state notifier
class VehicleFilterStateNotifier extends StateNotifier<VehicleFilterState> {
  VehicleFilterStateNotifier() : super(const VehicleFilterState());

  void setVehicleType(VehicleType? type) {
    state = state.copyWith(selectedType: type);
  }

  void setVehicleStatus(VehicleStatus? status) {
    state = state.copyWith(selectedStatus: status);
  }

  void setFuelType(FuelType? fuelType) {
    state = state.copyWith(selectedFuelType: fuelType);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void setShowExpiredDocuments(bool show) {
    state = state.copyWith(showExpiredDocuments: show);
  }

  void setShowOverdueMaintenance(bool show) {
    state = state.copyWith(showOverdueMaintenance: show);
  }

  void clearFilters() {
    state = const VehicleFilterState();
  }
}

// Filtered vehicles provider
final filteredVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final filterState = ref.watch(vehicleFilterStateProvider);
  final allVehicles = await ref.watch(currentUserVehiclesProvider.future);
  
  var filteredVehicles = allVehicles;
  
  // Apply type filter
  if (filterState.selectedType != null) {
    filteredVehicles = filteredVehicles.where((v) => v.type == filterState.selectedType).toList();
  }
  
  // Apply status filter
  if (filterState.selectedStatus != null) {
    filteredVehicles = filteredVehicles.where((v) => v.status == filterState.selectedStatus).toList();
  }
  
  // Apply fuel type filter
  if (filterState.selectedFuelType != null) {
    filteredVehicles = filteredVehicles.where((v) => v.fuelType == filterState.selectedFuelType).toList();
  }
  
  // Apply search query filter
  if (filterState.searchQuery?.isNotEmpty == true) {
    final query = filterState.searchQuery!.toLowerCase();
    filteredVehicles = filteredVehicles.where((v) =>
      v.make.toLowerCase().contains(query) ||
      v.model.toLowerCase().contains(query) ||
      v.plateNumber.toLowerCase().contains(query) ||
      v.year.toString().contains(query) ||
      v.color.toLowerCase().contains(query)
    ).toList();
  }
  
  // Apply expired documents filter
  if (filterState.showExpiredDocuments) {
    filteredVehicles = filteredVehicles.where((v) => v.hasExpiredDocuments).toList();
  }
  
  return filteredVehicles;
});
