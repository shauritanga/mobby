import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/maintenance_record.dart';
import '../../domain/usecases/manage_vehicles_usecase.dart';
import '../../domain/usecases/manage_documents_usecase.dart';
import '../../domain/usecases/manage_maintenance_usecase.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../data/datasources/vehicle_remote_datasource.dart';
import '../../data/datasources/vehicle_local_datasource.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Vehicle providers for state management
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature

// Data source providers
final vehicleRemoteDataSourceProvider = Provider<VehicleRemoteDataSource>((
  ref,
) {
  return VehicleRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

final vehicleLocalDataSourceProvider = Provider<VehicleLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return VehicleLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

// Repository provider
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(
    remoteDataSource: ref.watch(vehicleRemoteDataSourceProvider),
    localDataSource: ref.watch(vehicleLocalDataSourceProvider),
    connectivity: Connectivity(),
  );
});

// Use case providers
final getUserVehiclesUseCaseProvider = Provider<GetUserVehiclesUseCase>((ref) {
  return GetUserVehiclesUseCase(ref.watch(vehicleRepositoryProvider));
});

final getVehicleByIdUseCaseProvider = Provider<GetVehicleByIdUseCase>((ref) {
  return GetVehicleByIdUseCase(ref.watch(vehicleRepositoryProvider));
});

final createVehicleUseCaseProvider = Provider<CreateVehicleUseCase>((ref) {
  return CreateVehicleUseCase(ref.watch(vehicleRepositoryProvider));
});

final updateVehicleUseCaseProvider = Provider<UpdateVehicleUseCase>((ref) {
  return UpdateVehicleUseCase(ref.watch(vehicleRepositoryProvider));
});

final deleteVehicleUseCaseProvider = Provider<DeleteVehicleUseCase>((ref) {
  return DeleteVehicleUseCase(ref.watch(vehicleRepositoryProvider));
});

final searchVehiclesUseCaseProvider = Provider<SearchVehiclesUseCase>((ref) {
  return SearchVehiclesUseCase(ref.watch(vehicleRepositoryProvider));
});

// Document use case providers
final getVehicleDocumentsUseCaseProvider = Provider<GetVehicleDocumentsUseCase>(
  (ref) {
    return GetVehicleDocumentsUseCase(ref.watch(vehicleRepositoryProvider));
  },
);

final getUserDocumentsUseCaseProvider = Provider<GetUserDocumentsUseCase>((
  ref,
) {
  return GetUserDocumentsUseCase(ref.watch(vehicleRepositoryProvider));
});

final createDocumentUseCaseProvider = Provider<CreateDocumentUseCase>((ref) {
  return CreateDocumentUseCase(ref.watch(vehicleRepositoryProvider));
});

final updateDocumentUseCaseProvider = Provider<UpdateDocumentUseCase>((ref) {
  return UpdateDocumentUseCase(ref.watch(vehicleRepositoryProvider));
});

final deleteDocumentUseCaseProvider = Provider<DeleteDocumentUseCase>((ref) {
  return DeleteDocumentUseCase(ref.watch(vehicleRepositoryProvider));
});

final getExpiredDocumentsUseCaseProvider = Provider<GetExpiredDocumentsUseCase>(
  (ref) {
    return GetExpiredDocumentsUseCase(ref.watch(vehicleRepositoryProvider));
  },
);

final getExpiringSoonDocumentsUseCaseProvider =
    Provider<GetExpiringSoonDocumentsUseCase>((ref) {
      return GetExpiringSoonDocumentsUseCase(
        ref.watch(vehicleRepositoryProvider),
      );
    });

final uploadDocumentUseCaseProvider = Provider<UploadDocumentUseCase>((ref) {
  return UploadDocumentUseCase(ref.watch(vehicleRepositoryProvider));
});

// Maintenance use case providers
final getVehicleMaintenanceRecordsUseCaseProvider =
    Provider<GetVehicleMaintenanceRecordsUseCase>((ref) {
      return GetVehicleMaintenanceRecordsUseCase(
        ref.watch(vehicleRepositoryProvider),
      );
    });

final getUserMaintenanceRecordsUseCaseProvider =
    Provider<GetUserMaintenanceRecordsUseCase>((ref) {
      return GetUserMaintenanceRecordsUseCase(
        ref.watch(vehicleRepositoryProvider),
      );
    });

final createMaintenanceRecordUseCaseProvider =
    Provider<CreateMaintenanceRecordUseCase>((ref) {
      return CreateMaintenanceRecordUseCase(
        ref.watch(vehicleRepositoryProvider),
      );
    });

final updateMaintenanceRecordUseCaseProvider =
    Provider<UpdateMaintenanceRecordUseCase>((ref) {
      return UpdateMaintenanceRecordUseCase(
        ref.watch(vehicleRepositoryProvider),
      );
    });

final deleteMaintenanceRecordUseCaseProvider =
    Provider<DeleteMaintenanceRecordUseCase>((ref) {
      return DeleteMaintenanceRecordUseCase(
        ref.watch(vehicleRepositoryProvider),
      );
    });

final getOverdueMaintenanceRecordsUseCaseProvider =
    Provider<GetOverdueMaintenanceRecordsUseCase>((ref) {
      return GetOverdueMaintenanceRecordsUseCase(
        ref.watch(vehicleRepositoryProvider),
      );
    });

final getTotalMaintenanceCostUseCaseProvider =
    Provider<GetTotalMaintenanceCostUseCase>((ref) {
      return GetTotalMaintenanceCostUseCase(
        ref.watch(vehicleRepositoryProvider),
      );
    });

final getMaintenanceStatisticsUseCaseProvider =
    Provider<GetMaintenanceStatisticsUseCase>((ref) {
      return GetMaintenanceStatisticsUseCase(
        ref.watch(vehicleRepositoryProvider),
      );
    });

// Data providers
final userVehiclesProvider = FutureProvider.family<List<Vehicle>, String>((
  ref,
  userId,
) async {
  final useCase = ref.watch(getUserVehiclesUseCaseProvider);
  final result = await useCase(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (vehicles) => vehicles,
  );
});

final vehicleByIdProvider = FutureProvider.family<Vehicle?, String>((
  ref,
  vehicleId,
) async {
  final useCase = ref.watch(getVehicleByIdUseCaseProvider);
  final result = await useCase(vehicleId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (vehicle) => vehicle,
  );
});

final vehicleDocumentsProvider = FutureProvider.family<List<Document>, String>((
  ref,
  vehicleId,
) async {
  final useCase = ref.watch(getVehicleDocumentsUseCaseProvider);
  final result = await useCase(vehicleId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (documents) => documents,
  );
});

final userDocumentsProvider = FutureProvider.family<List<Document>, String>((
  ref,
  userId,
) async {
  final useCase = ref.watch(getUserDocumentsUseCaseProvider);
  final result = await useCase(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (documents) => documents,
  );
});

final vehicleMaintenanceRecordsProvider =
    FutureProvider.family<List<MaintenanceRecord>, String>((
      ref,
      vehicleId,
    ) async {
      final useCase = ref.watch(getVehicleMaintenanceRecordsUseCaseProvider);
      final result = await useCase(vehicleId);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (records) => records,
      );
    });

final userMaintenanceRecordsProvider =
    FutureProvider.family<List<MaintenanceRecord>, String>((ref, userId) async {
      final useCase = ref.watch(getUserMaintenanceRecordsUseCaseProvider);
      final result = await useCase(userId);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (records) => records,
      );
    });

// Current user's vehicles provider
final currentUserVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return [];

  final vehiclesAsync = ref.watch(userVehiclesProvider(currentUser.id));
  return vehiclesAsync.when(
    data: (vehicles) => vehicles,
    loading: () => [],
    error: (error, stack) => [],
  );
});

// Current user's documents provider
final currentUserDocumentsProvider = FutureProvider<List<Document>>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return [];

  final documentsAsync = ref.watch(userDocumentsProvider(currentUser.id));
  return documentsAsync.when(
    data: (documents) => documents,
    loading: () => [],
    error: (error, stack) => [],
  );
});

// Current user's maintenance records provider
final currentUserMaintenanceRecordsProvider =
    FutureProvider<List<MaintenanceRecord>>((ref) async {
      final currentUser = ref.watch(currentUserProvider).value;
      if (currentUser == null) return [];

      final recordsAsync = ref.watch(
        userMaintenanceRecordsProvider(currentUser.id),
      );
      return recordsAsync.when(
        data: (records) => records,
        loading: () => [],
        error: (error, stack) => [],
      );
    });

// Expired documents provider
final expiredDocumentsProvider = FutureProvider<List<Document>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return [];

  final useCase = ref.watch(getExpiredDocumentsUseCaseProvider);
  final result = await useCase(currentUser.id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (documents) => documents,
  );
});

// Expiring soon documents provider
final expiringSoonDocumentsProvider = FutureProvider<List<Document>>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return [];

  final useCase = ref.watch(getExpiringSoonDocumentsUseCaseProvider);
  final result = await useCase(currentUser.id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (documents) => documents,
  );
});

// Overdue maintenance records provider
final overdueMaintenanceRecordsProvider =
    FutureProvider<List<MaintenanceRecord>>((ref) async {
      final currentUser = ref.watch(currentUserProvider).value;
      if (currentUser == null) return [];

      final useCase = ref.watch(getOverdueMaintenanceRecordsUseCaseProvider);
      final result = await useCase(currentUser.id);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (records) => records,
      );
    });

// Vehicle statistics provider
final vehicleStatisticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
      final vehicles = await ref.watch(userVehiclesProvider(userId).future);
      final documents = await ref.watch(userDocumentsProvider(userId).future);
      final maintenanceRecords = await ref.watch(
        userMaintenanceRecordsProvider(userId).future,
      );

      // Calculate statistics
      final totalVehicles = vehicles.length;
      final activeVehicles = vehicles
          .where((v) => v.status == VehicleStatus.active)
          .length;
      final totalDocuments = documents.length;
      final expiredDocuments = documents.where((d) => d.isExpired).length;
      final expiringSoonDocuments = documents
          .where((d) => d.isExpiringSoon)
          .length;
      final totalMaintenanceRecords = maintenanceRecords.length;
      final totalMaintenanceCost = maintenanceRecords.fold<double>(
        0.0,
        (total, record) => total + record.cost,
      );

      // Vehicle type distribution
      final vehicleTypeDistribution = <String, int>{};
      for (final vehicle in vehicles) {
        final type = vehicle.type.displayName;
        vehicleTypeDistribution[type] =
            (vehicleTypeDistribution[type] ?? 0) + 1;
      }

      // Fuel type distribution
      final fuelTypeDistribution = <String, int>{};
      for (final vehicle in vehicles) {
        final fuelType = vehicle.fuelType.displayName;
        fuelTypeDistribution[fuelType] =
            (fuelTypeDistribution[fuelType] ?? 0) + 1;
      }

      return {
        'totalVehicles': totalVehicles,
        'activeVehicles': activeVehicles,
        'totalDocuments': totalDocuments,
        'expiredDocuments': expiredDocuments,
        'expiringSoonDocuments': expiringSoonDocuments,
        'totalMaintenanceRecords': totalMaintenanceRecords,
        'totalMaintenanceCost': totalMaintenanceCost,
        'vehicleTypeDistribution': vehicleTypeDistribution,
        'fuelTypeDistribution': fuelTypeDistribution,
        'averageVehicleAge': vehicles.isNotEmpty
            ? vehicles.map((v) => v.age).reduce((a, b) => a + b) /
                  vehicles.length
            : 0.0,
      };
    });

// Vehicle alerts provider
final vehicleAlertsProvider = FutureProvider<Map<String, List<dynamic>>>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return {};

  final expiredDocs = await ref.watch(expiredDocumentsProvider.future);
  final expiringSoonDocs = await ref.watch(
    expiringSoonDocumentsProvider.future,
  );
  final overdueMaintenance = await ref.watch(
    overdueMaintenanceRecordsProvider.future,
  );

  return {
    'expiredDocuments': expiredDocs,
    'expiringSoonDocuments': expiringSoonDocs,
    'overdueMaintenance': overdueMaintenance,
  };
});

// Search vehicles provider
final searchVehiclesProvider = FutureProvider.family<List<Vehicle>, String>((
  ref,
  query,
) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null || query.trim().isEmpty) return [];

  final useCase = ref.watch(searchVehiclesUseCaseProvider);
  final result = await useCase(
    SearchVehiclesParams(userId: currentUser.id, query: query),
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (vehicles) => vehicles,
  );
});

// Vehicle form state provider
final vehicleFormStateProvider =
    StateNotifierProvider<VehicleFormStateNotifier, VehicleFormState>((ref) {
      return VehicleFormStateNotifier();
    });

// Vehicle form state
class VehicleFormState {
  final bool isLoading;
  final String? error;
  final Vehicle? vehicle;

  const VehicleFormState({this.isLoading = false, this.error, this.vehicle});

  VehicleFormState copyWith({
    bool? isLoading,
    String? error,
    Vehicle? vehicle,
  }) {
    return VehicleFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      vehicle: vehicle ?? this.vehicle,
    );
  }
}

// Vehicle form state notifier
class VehicleFormStateNotifier extends StateNotifier<VehicleFormState> {
  VehicleFormStateNotifier() : super(const VehicleFormState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setVehicle(Vehicle? vehicle) {
    state = state.copyWith(vehicle: vehicle);
  }

  void reset() {
    state = const VehicleFormState();
  }
}
