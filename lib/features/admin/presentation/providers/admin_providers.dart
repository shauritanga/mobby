import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/metric.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/system_status.dart';
import '../../domain/usecases/view_metrics.dart';
import '../../domain/usecases/generate_reports.dart';
import '../../domain/usecases/monitor_system.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';

// Data source providers
final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

// Repository provider
final adminRepositoryProvider = Provider((ref) {
  return AdminRepositoryImpl(
    remoteDataSource: ref.read(adminRemoteDataSourceProvider),
  );
});

// Use case providers - Metrics
final viewMetricsUseCaseProvider = Provider((ref) {
  return ViewMetrics(ref.read(adminRepositoryProvider));
});

final getDashboardMetricsUseCaseProvider = Provider((ref) {
  return GetDashboardMetrics(ref.read(adminRepositoryProvider));
});

final getRealtimeMetricsUseCaseProvider = Provider((ref) {
  return GetRealtimeMetrics(ref.read(adminRepositoryProvider));
});

final getMetricDetailsUseCaseProvider = Provider((ref) {
  return GetMetricDetails(ref.read(adminRepositoryProvider));
});

final getMetricsSummaryUseCaseProvider = Provider((ref) {
  return GetMetricsSummary(ref.read(adminRepositoryProvider));
});

final getUserAnalyticsUseCaseProvider = Provider((ref) {
  return GetUserAnalytics(ref.read(adminRepositoryProvider));
});

final getOrderAnalyticsUseCaseProvider = Provider((ref) {
  return GetOrderAnalytics(ref.read(adminRepositoryProvider));
});

final getRevenueAnalyticsUseCaseProvider = Provider((ref) {
  return GetRevenueAnalytics(ref.read(adminRepositoryProvider));
});

final getProductAnalyticsUseCaseProvider = Provider((ref) {
  return GetProductAnalytics(ref.read(adminRepositoryProvider));
});

final getInsuranceAnalyticsUseCaseProvider = Provider((ref) {
  return GetInsuranceAnalytics(ref.read(adminRepositoryProvider));
});

// Use case providers - Reports
final viewReportsUseCaseProvider = Provider((ref) {
  return ViewReports(ref.read(adminRepositoryProvider));
});

final getReportDetailsUseCaseProvider = Provider((ref) {
  return GetReportDetails(ref.read(adminRepositoryProvider));
});

final createReportUseCaseProvider = Provider((ref) {
  return CreateReport(ref.read(adminRepositoryProvider));
});

final generateReportUseCaseProvider = Provider((ref) {
  return GenerateReport(ref.read(adminRepositoryProvider));
});

final updateReportUseCaseProvider = Provider((ref) {
  return UpdateReport(ref.read(adminRepositoryProvider));
});

final deleteReportUseCaseProvider = Provider((ref) {
  return DeleteReport(ref.read(adminRepositoryProvider));
});

final getScheduledReportsUseCaseProvider = Provider((ref) {
  return GetScheduledReports(ref.read(adminRepositoryProvider));
});

final scheduleReportUseCaseProvider = Provider((ref) {
  return ScheduleReport(ref.read(adminRepositoryProvider));
});

final exportDataUseCaseProvider = Provider((ref) {
  return ExportData(ref.read(adminRepositoryProvider));
});

// Use case providers - System Monitoring
final monitorSystemUseCaseProvider = Provider((ref) {
  return MonitorSystem(ref.read(adminRepositoryProvider));
});

final getServicesHealthUseCaseProvider = Provider((ref) {
  return GetServicesHealth(ref.read(adminRepositoryProvider));
});

final getServiceHealthUseCaseProvider = Provider((ref) {
  return GetServiceHealth(ref.read(adminRepositoryProvider));
});

final getSystemAlertsUseCaseProvider = Provider((ref) {
  return GetSystemAlerts(ref.read(adminRepositoryProvider));
});

final resolveAlertUseCaseProvider = Provider((ref) {
  return ResolveAlert(ref.read(adminRepositoryProvider));
});

final getSystemResourcesUseCaseProvider = Provider((ref) {
  return GetSystemResources(ref.read(adminRepositoryProvider));
});

final getQuickActionsDataUseCaseProvider = Provider((ref) {
  return GetQuickActionsData(ref.read(adminRepositoryProvider));
});

final performQuickActionUseCaseProvider = Provider((ref) {
  return PerformQuickAction(ref.read(adminRepositoryProvider));
});

final getRecentActivitiesUseCaseProvider = Provider((ref) {
  return GetRecentActivities(ref.read(adminRepositoryProvider));
});

final getSystemOverviewUseCaseProvider = Provider((ref) {
  return GetSystemOverview(ref.read(adminRepositoryProvider));
});

final subscribeToAlertsUseCaseProvider = Provider((ref) {
  return SubscribeToAlerts(ref.read(adminRepositoryProvider));
});

final unsubscribeFromAlertsUseCaseProvider = Provider((ref) {
  return UnsubscribeFromAlerts(ref.read(adminRepositoryProvider));
});

// State providers for UI
class DashboardState {
  final List<Metric> metrics;
  final SystemStatus? systemStatus;
  final Map<String, dynamic>? overview;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.metrics = const [],
    this.systemStatus,
    this.overview,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    List<Metric>? metrics,
    SystemStatus? systemStatus,
    Map<String, dynamic>? overview,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      metrics: metrics ?? this.metrics,
      systemStatus: systemStatus ?? this.systemStatus,
      overview: overview ?? this.overview,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Dashboard provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardState>>((ref) {
      return DashboardNotifier(ref);
    });

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardState>> {
  final Ref _ref;

  DashboardNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> loadDashboard({bool refresh = false}) async {
    try {
      if (refresh) {
        state = const AsyncValue.loading();
      } else if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(isLoading: true));
      }

      // Load dashboard data concurrently
      final futures = await Future.wait([
        _ref.read(getDashboardMetricsUseCaseProvider)(),
        _ref.read(monitorSystemUseCaseProvider)(),
        _ref.read(getSystemOverviewUseCaseProvider)(),
      ]);

      final metrics = futures[0] as List<Metric>;
      final systemStatus = futures[1] as SystemStatus;
      final overview = futures[2] as Map<String, dynamic>;

      state = AsyncValue.data(
        DashboardState(
          metrics: metrics,
          systemStatus: systemStatus,
          overview: overview,
          isLoading: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshMetrics() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      state = AsyncValue.data(currentState.copyWith(isLoading: true));

      final metrics = await _ref.read(getDashboardMetricsUseCaseProvider)();

      state = AsyncValue.data(
        currentState.copyWith(metrics: metrics, isLoading: false),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Individual data providers
final dashboardMetricsProvider = FutureProvider<List<Metric>>((ref) async {
  final getDashboardMetricsUseCase = ref.read(
    getDashboardMetricsUseCaseProvider,
  );
  return await getDashboardMetricsUseCase();
});

final realtimeMetricsProvider = FutureProvider<List<Metric>>((ref) async {
  final getRealtimeMetricsUseCase = ref.read(getRealtimeMetricsUseCaseProvider);
  return await getRealtimeMetricsUseCase();
});

final systemStatusProvider = FutureProvider<SystemStatus>((ref) async {
  final monitorSystemUseCase = ref.read(monitorSystemUseCaseProvider);
  return await monitorSystemUseCase();
});

final systemOverviewProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final getSystemOverviewUseCase = ref.read(getSystemOverviewUseCaseProvider);
  return await getSystemOverviewUseCase();
});

final metricsSummaryProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final getMetricsSummaryUseCase = ref.read(getMetricsSummaryUseCaseProvider);
  return await getMetricsSummaryUseCase();
});

final servicesHealthProvider = FutureProvider<List<ServiceHealth>>((ref) async {
  final getServicesHealthUseCase = ref.read(getServicesHealthUseCaseProvider);
  return await getServicesHealthUseCase();
});

final systemAlertsProvider = FutureProvider<List<SystemAlert>>((ref) async {
  final getSystemAlertsUseCase = ref.read(getSystemAlertsUseCaseProvider);
  final params = GetSystemAlertsParams(isResolved: false, limit: 10);
  return await getSystemAlertsUseCase(params);
});

final systemResourcesProvider = FutureProvider<List<SystemResource>>((
  ref,
) async {
  final getSystemResourcesUseCase = ref.read(getSystemResourcesUseCaseProvider);
  return await getSystemResourcesUseCase();
});

final quickActionsDataProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final getQuickActionsDataUseCase = ref.read(
    getQuickActionsDataUseCaseProvider,
  );
  return await getQuickActionsDataUseCase();
});

final recentActivitiesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final getRecentActivitiesUseCase = ref.read(
    getRecentActivitiesUseCaseProvider,
  );
  return await getRecentActivitiesUseCase();
});

// Analytics providers
final userAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final getUserAnalyticsUseCase = ref.read(getUserAnalyticsUseCaseProvider);
  return await getUserAnalyticsUseCase();
});

final orderAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final getOrderAnalyticsUseCase = ref.read(getOrderAnalyticsUseCaseProvider);
  return await getOrderAnalyticsUseCase();
});

final revenueAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final getRevenueAnalyticsUseCase = ref.read(
    getRevenueAnalyticsUseCaseProvider,
  );
  return await getRevenueAnalyticsUseCase();
});

final productAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final getProductAnalyticsUseCase = ref.read(
    getProductAnalyticsUseCaseProvider,
  );
  return await getProductAnalyticsUseCase();
});

final insuranceAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final getInsuranceAnalyticsUseCase = ref.read(
    getInsuranceAnalyticsUseCaseProvider,
  );
  return await getInsuranceAnalyticsUseCase();
});

// Reports providers
final reportsProvider = FutureProvider<List<Report>>((ref) async {
  final viewReportsUseCase = ref.read(viewReportsUseCaseProvider);
  final params = ViewReportsParams();
  return await viewReportsUseCase(params);
});

final reportDetailsProvider = FutureProvider.family<Report?, String>((
  ref,
  reportId,
) async {
  final getReportDetailsUseCase = ref.read(getReportDetailsUseCaseProvider);
  return await getReportDetailsUseCase(reportId);
});

final scheduledReportsProvider = FutureProvider<List<Report>>((ref) async {
  final getScheduledReportsUseCase = ref.read(
    getScheduledReportsUseCaseProvider,
  );
  return await getScheduledReportsUseCase();
});
