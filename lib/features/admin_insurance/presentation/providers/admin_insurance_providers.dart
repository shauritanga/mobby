import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/application.dart';
import '../../domain/entities/commission.dart';
import '../../domain/entities/insurance_partner.dart';
import '../../domain/usecases/manage_partners.dart';
import '../../domain/usecases/process_applications.dart';
import '../../domain/usecases/track_commissions.dart';
import '../../data/datasources/admin_insurance_remote_datasource.dart';
import '../../data/repositories/admin_insurance_repository_impl.dart';

/// Admin insurance providers
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin Insurance Management Feature

// Data Sources
final adminInsuranceRemoteDataSourceProvider = Provider<AdminInsuranceRemoteDataSource>((ref) {
  return AdminInsuranceRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
  );
});

// Repository
final adminInsuranceRepositoryProvider = Provider((ref) {
  return AdminInsuranceRepositoryImpl(
    remoteDataSource: ref.read(adminInsuranceRemoteDataSourceProvider),
    connectivity: Connectivity(),
  );
});

// Partner Management Use Cases
final getAllPartnersProvider = Provider((ref) {
  return GetAllPartners(ref.read(adminInsuranceRepositoryProvider));
});

final createPartnerProvider = Provider((ref) {
  return CreatePartner(ref.read(adminInsuranceRepositoryProvider));
});

final updatePartnerProvider = Provider((ref) {
  return UpdatePartner(ref.read(adminInsuranceRepositoryProvider));
});

final updatePartnerStatusProvider = Provider((ref) {
  return UpdatePartnerStatus(ref.read(adminInsuranceRepositoryProvider));
});

final deletePartnerProvider = Provider((ref) {
  return DeletePartner(ref.read(adminInsuranceRepositoryProvider));
});

final searchPartnersProvider = Provider((ref) {
  return SearchPartners(ref.read(adminInsuranceRepositoryProvider));
});

final getPartnersAnalyticsProvider = Provider((ref) {
  return GetPartnersAnalytics(ref.read(adminInsuranceRepositoryProvider));
});

// Application Processing Use Cases
final getAllApplicationsProvider = Provider((ref) {
  return GetAllApplications(ref.read(adminInsuranceRepositoryProvider));
});

final updateApplicationStatusProvider = Provider((ref) {
  return UpdateApplicationStatus(ref.read(adminInsuranceRepositoryProvider));
});

final assignApplicationProvider = Provider((ref) {
  return AssignApplication(ref.read(adminInsuranceRepositoryProvider));
});

final updateApplicationPriorityProvider = Provider((ref) {
  return UpdateApplicationPriority(ref.read(adminInsuranceRepositoryProvider));
});

final addApplicationNoteProvider = Provider((ref) {
  return AddApplicationNote(ref.read(adminInsuranceRepositoryProvider));
});

final getApplicationsByAssigneeProvider = Provider((ref) {
  return GetApplicationsByAssignee(ref.read(adminInsuranceRepositoryProvider));
});

final searchApplicationsProvider = Provider((ref) {
  return SearchApplications(ref.read(adminInsuranceRepositoryProvider));
});

final getApplicationsAnalyticsProvider = Provider((ref) {
  return GetApplicationsAnalytics(ref.read(adminInsuranceRepositoryProvider));
});

final bulkUpdateApplicationStatusProvider = Provider((ref) {
  return BulkUpdateApplicationStatus(ref.read(adminInsuranceRepositoryProvider));
});

// Commission Tracking Use Cases
final getAllCommissionsProvider = Provider((ref) {
  return GetAllCommissions(ref.read(adminInsuranceRepositoryProvider));
});

final updateCommissionStatusProvider = Provider((ref) {
  return UpdateCommissionStatus(ref.read(adminInsuranceRepositoryProvider));
});

final processCommissionPaymentProvider = Provider((ref) {
  return ProcessCommissionPayment(ref.read(adminInsuranceRepositoryProvider));
});

final addCommissionAdjustmentProvider = Provider((ref) {
  return AddCommissionAdjustment(ref.read(adminInsuranceRepositoryProvider));
});

final getCommissionsByPartnerProvider = Provider((ref) {
  return GetCommissionsByPartner(ref.read(adminInsuranceRepositoryProvider));
});

final searchCommissionsProvider = Provider((ref) {
  return SearchCommissions(ref.read(adminInsuranceRepositoryProvider));
});

final getCommissionsAnalyticsProvider = Provider((ref) {
  return GetCommissionsAnalytics(ref.read(adminInsuranceRepositoryProvider));
});

final bulkUpdateCommissionStatusProvider = Provider((ref) {
  return BulkUpdateCommissionStatus(ref.read(adminInsuranceRepositoryProvider));
});

final bulkProcessCommissionPaymentsProvider = Provider((ref) {
  return BulkProcessCommissionPayments(ref.read(adminInsuranceRepositoryProvider));
});

// State Providers for UI
final partnersProvider = StateNotifierProvider<PartnersNotifier, AsyncValue<List<InsurancePartner>>>((ref) {
  return PartnersNotifier(ref.read(getAllPartnersProvider));
});

final applicationsProvider = StateNotifierProvider<ApplicationsNotifier, AsyncValue<List<InsuranceApplication>>>((ref) {
  return ApplicationsNotifier(ref.read(getAllApplicationsProvider));
});

final commissionsProvider = StateNotifierProvider<CommissionsNotifier, AsyncValue<List<Commission>>>((ref) {
  return CommissionsNotifier(ref.read(getAllCommissionsProvider));
});

// Analytics Providers
final partnersAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final useCase = ref.read(getPartnersAnalyticsProvider);
  final result = await useCase(const GetPartnersAnalyticsParams());
  return result.fold(
    (failure) => throw Exception(failure.message),
    (analytics) => analytics,
  );
});

final applicationsAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final useCase = ref.read(getApplicationsAnalyticsProvider);
  final result = await useCase(const GetApplicationsAnalyticsParams());
  return result.fold(
    (failure) => throw Exception(failure.message),
    (analytics) => analytics,
  );
});

final commissionsAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final useCase = ref.read(getCommissionsAnalyticsProvider);
  final result = await useCase(const GetCommissionsAnalyticsParams());
  return result.fold(
    (failure) => throw Exception(failure.message),
    (analytics) => analytics,
  );
});

// Filter State Providers
final partnerFiltersProvider = StateProvider<PartnerFilters>((ref) {
  return const PartnerFilters();
});

final applicationFiltersProvider = StateProvider<ApplicationFilters>((ref) {
  return const ApplicationFilters();
});

final commissionFiltersProvider = StateProvider<CommissionFilters>((ref) {
  return const CommissionFilters();
});

// State Notifiers
class PartnersNotifier extends StateNotifier<AsyncValue<List<InsurancePartner>>> {
  final GetAllPartners _getAllPartners;

  PartnersNotifier(this._getAllPartners) : super(const AsyncValue.loading()) {
    loadPartners();
  }

  Future<void> loadPartners({
    PartnerType? type,
    PartnerStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _getAllPartners(GetAllPartnersParams(
      type: type,
      status: status,
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      page: page,
      limit: limit,
    ));

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (partners) => AsyncValue.data(partners),
    );
  }

  Future<void> refreshPartners() async {
    await loadPartners();
  }
}

class ApplicationsNotifier extends StateNotifier<AsyncValue<List<InsuranceApplication>>> {
  final GetAllApplications _getAllApplications;

  ApplicationsNotifier(this._getAllApplications) : super(const AsyncValue.loading()) {
    loadApplications();
  }

  Future<void> loadApplications({
    ApplicationType? type,
    ApplicationStatus? status,
    ApplicationPriority? priority,
    String? partnerId,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _getAllApplications(GetAllApplicationsParams(
      type: type,
      status: status,
      priority: priority,
      partnerId: partnerId,
      assignedTo: assignedTo,
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      page: page,
      limit: limit,
    ));

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (applications) => AsyncValue.data(applications),
    );
  }

  Future<void> refreshApplications() async {
    await loadApplications();
  }
}

class CommissionsNotifier extends StateNotifier<AsyncValue<List<Commission>>> {
  final GetAllCommissions _getAllCommissions;

  CommissionsNotifier(this._getAllCommissions) : super(const AsyncValue.loading()) {
    loadCommissions();
  }

  Future<void> loadCommissions({
    CommissionType? type,
    CommissionStatus? status,
    CommissionTier? tier,
    String? partnerId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _getAllCommissions(GetAllCommissionsParams(
      type: type,
      status: status,
      tier: tier,
      partnerId: partnerId,
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      page: page,
      limit: limit,
    ));

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (commissions) => AsyncValue.data(commissions),
    );
  }

  Future<void> refreshCommissions() async {
    await loadCommissions();
  }
}

// Filter Classes
class PartnerFilters {
  final PartnerType? type;
  final PartnerStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const PartnerFilters({
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  PartnerFilters copyWith({
    PartnerType? type,
    PartnerStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return PartnerFilters(
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ApplicationFilters {
  final ApplicationType? type;
  final ApplicationStatus? status;
  final ApplicationPriority? priority;
  final String? partnerId;
  final String? assignedTo;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const ApplicationFilters({
    this.type,
    this.status,
    this.priority,
    this.partnerId,
    this.assignedTo,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  ApplicationFilters copyWith({
    ApplicationType? type,
    ApplicationStatus? status,
    ApplicationPriority? priority,
    String? partnerId,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return ApplicationFilters(
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      partnerId: partnerId ?? this.partnerId,
      assignedTo: assignedTo ?? this.assignedTo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CommissionFilters {
  final CommissionType? type;
  final CommissionStatus? status;
  final CommissionTier? tier;
  final String? partnerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const CommissionFilters({
    this.type,
    this.status,
    this.tier,
    this.partnerId,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  CommissionFilters copyWith({
    CommissionType? type,
    CommissionStatus? status,
    CommissionTier? tier,
    String? partnerId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return CommissionFilters(
      type: type ?? this.type,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      partnerId: partnerId ?? this.partnerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
