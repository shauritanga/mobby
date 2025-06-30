import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobby/core/usecases/usecase.dart';

import '../../../latra/domain/entities/latra_application.dart';
import '../../../latra/domain/entities/latra_document.dart';
import '../../data/datasources/admin_latra_remote_datasource.dart';
import '../../data/repositories/admin_latra_repository_impl.dart';
import '../../domain/entities/verification_status.dart';
import '../../domain/repositories/admin_latra_repository.dart';
import '../../domain/usecases/monitor_integration.dart';
import '../../domain/usecases/process_applications.dart';
import '../../domain/usecases/verify_documents.dart';

// Repository Providers
final adminLATRARemoteDataSourceProvider = Provider<AdminLATRARemoteDataSource>(
  (ref) {
    return AdminLATRARemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
    );
  },
);

final adminLATRARepositoryProvider = Provider<AdminLATRARepository>((ref) {
  return AdminLATRARepositoryImpl(
    remoteDataSource: ref.read(adminLATRARemoteDataSourceProvider),
    connectivity: Connectivity(),
  );
});

// Use Case Providers
final getAllApplicationsUseCaseProvider = Provider<GetAllApplications>((ref) {
  return GetAllApplications(ref.read(adminLATRARepositoryProvider));
});

final updateApplicationStatusUseCaseProvider =
    Provider<UpdateApplicationStatus>((ref) {
      return UpdateApplicationStatus(ref.read(adminLATRARepositoryProvider));
    });

final assignApplicationUseCaseProvider = Provider<AssignApplication>((ref) {
  return AssignApplication(ref.read(adminLATRARepositoryProvider));
});

final addApplicationNotesUseCaseProvider = Provider<AddApplicationNotes>((ref) {
  return AddApplicationNotes(ref.read(adminLATRARepositoryProvider));
});

final getApplicationsAnalyticsUseCaseProvider =
    Provider<GetApplicationsAnalytics>((ref) {
      return GetApplicationsAnalytics(ref.read(adminLATRARepositoryProvider));
    });

final bulkUpdateApplicationStatusUseCaseProvider =
    Provider<BulkUpdateApplicationStatus>((ref) {
      return BulkUpdateApplicationStatus(
        ref.read(adminLATRARepositoryProvider),
      );
    });

final searchApplicationsUseCaseProvider = Provider<SearchApplications>((ref) {
  return SearchApplications(ref.read(adminLATRARepositoryProvider));
});

final getAllDocumentsUseCaseProvider = Provider<GetAllDocuments>((ref) {
  return GetAllDocuments(ref.read(adminLATRARepositoryProvider));
});

final verifyDocumentUseCaseProvider = Provider<VerifyDocument>((ref) {
  return VerifyDocument(ref.read(adminLATRARepositoryProvider));
});

final getDocumentVerificationsUseCaseProvider =
    Provider<GetDocumentVerifications>((ref) {
      return GetDocumentVerifications(ref.read(adminLATRARepositoryProvider));
    });

final getVerificationHistoryUseCaseProvider = Provider<GetVerificationHistory>((
  ref,
) {
  return GetVerificationHistory(ref.read(adminLATRARepositoryProvider));
});

final getVerificationAnalyticsUseCaseProvider =
    Provider<GetVerificationAnalytics>((ref) {
      return GetVerificationAnalytics(ref.read(adminLATRARepositoryProvider));
    });

final searchDocumentsUseCaseProvider = Provider<SearchDocuments>((ref) {
  return SearchDocuments(ref.read(adminLATRARepositoryProvider));
});

final getIntegrationStatusesUseCaseProvider = Provider<GetIntegrationStatuses>((
  ref,
) {
  return GetIntegrationStatuses(ref.read(adminLATRARepositoryProvider));
});

final getIntegrationStatusUseCaseProvider = Provider<GetIntegrationStatus>((
  ref,
) {
  return GetIntegrationStatus(ref.read(adminLATRARepositoryProvider));
});

final updateIntegrationStatusUseCaseProvider =
    Provider<UpdateIntegrationStatus>((ref) {
      return UpdateIntegrationStatus(ref.read(adminLATRARepositoryProvider));
    });

final getIntegrationEventsUseCaseProvider = Provider<GetIntegrationEvents>((
  ref,
) {
  return GetIntegrationEvents(ref.read(adminLATRARepositoryProvider));
});

final addIntegrationEventUseCaseProvider = Provider<AddIntegrationEvent>((ref) {
  return AddIntegrationEvent(ref.read(adminLATRARepositoryProvider));
});

final getIntegrationAnalyticsUseCaseProvider =
    Provider<GetIntegrationAnalytics>((ref) {
      return GetIntegrationAnalytics(ref.read(adminLATRARepositoryProvider));
    });

final getAdminDashboardDataUseCaseProvider = Provider<GetAdminDashboardData>((
  ref,
) {
  return GetAdminDashboardData(ref.read(adminLATRARepositoryProvider));
});

// State Providers
final applicationFiltersProvider = StateProvider<ApplicationFilters>((ref) {
  return const ApplicationFilters();
});

final documentFiltersProvider = StateProvider<DocumentFilters>((ref) {
  return const DocumentFilters();
});

final integrationFiltersProvider = StateProvider<IntegrationFilters>((ref) {
  return const IntegrationFilters();
});

// Data Providers
final applicationsProvider =
    FutureProvider.family<List<LATRAApplication>, ApplicationFilters>((
      ref,
      filters,
    ) async {
      final useCase = ref.read(getAllApplicationsUseCaseProvider);
      final result = await useCase(
        GetAllApplicationsParams(
          status: filters.status,
          type: filters.type,
          startDate: filters.startDate,
          endDate: filters.endDate,
          searchQuery: filters.searchQuery,
          page: filters.page,
          limit: filters.limit,
        ),
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (applications) => applications,
      );
    });

final documentsProvider =
    FutureProvider.family<List<LATRADocument>, DocumentFilters>((
      ref,
      filters,
    ) async {
      final useCase = ref.read(getAllDocumentsUseCaseProvider);
      final result = await useCase(
        GetAllDocumentsParams(
          status: filters.status,
          type: filters.type,
          startDate: filters.startDate,
          endDate: filters.endDate,
          searchQuery: filters.searchQuery,
          page: filters.page,
          limit: filters.limit,
        ),
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (documents) => documents,
      );
    });

final integrationStatusesProvider = FutureProvider<List<IntegrationStatus>>((
  ref,
) async {
  final useCase = ref.read(getIntegrationStatusesUseCaseProvider);
  final result = await useCase(NoParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (statuses) => statuses,
  );
});

final applicationsAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final useCase = ref.read(getApplicationsAnalyticsUseCaseProvider);
  final result = await useCase(const GetApplicationsAnalyticsParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (analytics) => analytics,
  );
});

final verificationAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final useCase = ref.read(getVerificationAnalyticsUseCaseProvider);
  final result = await useCase(const GetVerificationAnalyticsParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (analytics) => analytics,
  );
});

final integrationAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final useCase = ref.read(getIntegrationAnalyticsUseCaseProvider);
  final result = await useCase(const GetIntegrationAnalyticsParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (analytics) => analytics,
  );
});

final adminDashboardDataProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final useCase = ref.read(getAdminDashboardDataUseCaseProvider);
  final result = await useCase(NoParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

// Filter Classes
class ApplicationFilters {
  final LATRAApplicationStatus? status;
  final LATRAApplicationType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final int page;
  final int limit;

  const ApplicationFilters({
    this.status,
    this.type,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
  });

  ApplicationFilters copyWith({
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? page,
    int? limit,
  }) {
    return ApplicationFilters(
      status: status ?? this.status,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

class DocumentFilters {
  final LATRADocumentStatus? status;
  final LATRADocumentType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final int page;
  final int limit;

  const DocumentFilters({
    this.status,
    this.type,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
  });

  DocumentFilters copyWith({
    LATRADocumentStatus? status,
    LATRADocumentType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? page,
    int? limit,
  }) {
    return DocumentFilters(
      status: status ?? this.status,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

class IntegrationFilters {
  final IntegrationHealth? health;
  final String? serviceName;
  final DateTime? startDate;
  final DateTime? endDate;

  const IntegrationFilters({
    this.health,
    this.serviceName,
    this.startDate,
    this.endDate,
  });

  IntegrationFilters copyWith({
    IntegrationHealth? health,
    String? serviceName,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return IntegrationFilters(
      health: health ?? this.health,
      serviceName: serviceName ?? this.serviceName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
