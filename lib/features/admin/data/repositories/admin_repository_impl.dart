import '../../domain/entities/metric.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/system_status.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/report_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl({required AdminRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Metric>> getMetrics({
    List<MetricType>? types,
    MetricPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final metrics = await _remoteDataSource.getMetrics(
        types: types,
        period: period,
        startDate: startDate,
        endDate: endDate,
      );
      return metrics.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch metrics: $e');
    }
  }

  @override
  Future<Metric?> getMetricById(String metricId) async {
    try {
      final metric = await _remoteDataSource.getMetricById(metricId);
      return metric?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch metric: $e');
    }
  }

  @override
  Future<List<Metric>> getDashboardMetrics() async {
    try {
      final metrics = await _remoteDataSource.getDashboardMetrics();
      return metrics.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch dashboard metrics: $e');
    }
  }

  @override
  Future<List<Metric>> getRealtimeMetrics() async {
    try {
      final metrics = await _remoteDataSource.getRealtimeMetrics();
      return metrics.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch realtime metrics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getMetricsSummary() async {
    try {
      return await _remoteDataSource.getMetricsSummary();
    } catch (e) {
      throw Exception('Failed to fetch metrics summary: $e');
    }
  }

  @override
  Future<List<Report>> getReports({
    ReportType? type,
    ReportStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final reports = await _remoteDataSource.getReports(
        type: type,
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );
      return reports.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  @override
  Future<Report?> getReportById(String reportId) async {
    try {
      final report = await _remoteDataSource.getReportById(reportId);
      return report?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch report: $e');
    }
  }

  @override
  Future<Report> createReport(Report report) async {
    try {
      final reportModel = ReportModel.fromEntity(report);
      final createdReport = await _remoteDataSource.createReport(reportModel);
      return createdReport.toEntity();
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  @override
  Future<Report> updateReport(Report report) async {
    try {
      final reportModel = ReportModel.fromEntity(report);
      final updatedReport = await _remoteDataSource.updateReport(reportModel);
      return updatedReport.toEntity();
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      await _remoteDataSource.deleteReport(reportId);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  @override
  Future<String> generateReport(String reportId) async {
    try {
      return await _remoteDataSource.generateReport(reportId);
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  @override
  Future<List<Report>> getScheduledReports() async {
    try {
      final reports = await _remoteDataSource.getScheduledReports();
      return reports.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch scheduled reports: $e');
    }
  }

  @override
  Future<Report> scheduleReport(Report report, ReportSchedule schedule) async {
    try {
      final reportModel = ReportModel.fromEntity(report);
      final scheduleModel = ReportScheduleModel.fromEntity(schedule);
      final scheduledReport = await _remoteDataSource.scheduleReport(
        reportModel,
        scheduleModel,
      );
      return scheduledReport.toEntity();
    } catch (e) {
      throw Exception('Failed to schedule report: $e');
    }
  }

  @override
  Future<SystemStatus> getSystemStatus() async {
    try {
      final systemStatus = await _remoteDataSource.getSystemStatus();
      return systemStatus.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch system status: $e');
    }
  }

  @override
  Future<List<ServiceHealth>> getServicesHealth() async {
    try {
      final services = await _remoteDataSource.getServicesHealth();
      return services.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch services health: $e');
    }
  }

  @override
  Future<ServiceHealth?> getServiceHealth(String serviceName) async {
    try {
      final service = await _remoteDataSource.getServiceHealth(serviceName);
      return service?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch service health: $e');
    }
  }

  @override
  Future<List<SystemAlert>> getSystemAlerts({
    AlertSeverity? severity,
    bool? isResolved,
    int limit = 50,
  }) async {
    try {
      final alerts = await _remoteDataSource.getSystemAlerts(
        severity: severity,
        isResolved: isResolved,
        limit: limit,
      );
      return alerts.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch system alerts: $e');
    }
  }

  @override
  Future<void> resolveAlert(String alertId, String resolvedBy) async {
    try {
      await _remoteDataSource.resolveAlert(alertId, resolvedBy);
    } catch (e) {
      throw Exception('Failed to resolve alert: $e');
    }
  }

  @override
  Future<List<SystemResource>> getSystemResources() async {
    try {
      final resources = await _remoteDataSource.getSystemResources();
      return resources.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch system resources: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _remoteDataSource.getUserAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch user analytics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _remoteDataSource.getOrderAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch order analytics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _remoteDataSource.getRevenueAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch revenue analytics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _remoteDataSource.getProductAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch product analytics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getInsuranceAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _remoteDataSource.getInsuranceAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch insurance analytics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getQuickActionsData() async {
    try {
      return await _remoteDataSource.getQuickActionsData();
    } catch (e) {
      throw Exception('Failed to fetch quick actions data: $e');
    }
  }

  @override
  Future<void> performQuickAction(
    String actionType,
    Map<String, dynamic> parameters,
  ) async {
    try {
      await _remoteDataSource.performQuickAction(actionType, parameters);
    } catch (e) {
      throw Exception('Failed to perform quick action: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentActivities({
    int limit = 20,
  }) async {
    try {
      return await _remoteDataSource.getRecentActivities(limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch recent activities: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemOverview() async {
    try {
      return await _remoteDataSource.getSystemOverview();
    } catch (e) {
      throw Exception('Failed to fetch system overview: $e');
    }
  }

  @override
  Future<String> exportData({
    required String dataType,
    required String format,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? filters,
  }) async {
    try {
      return await _remoteDataSource.exportData(
        dataType: dataType,
        format: format,
        startDate: startDate,
        endDate: endDate,
        filters: filters,
      );
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  @override
  Future<void> subscribeToAlerts(String userId) async {
    // TODO: Implement real-time alerts subscription
  }

  @override
  Future<void> unsubscribeFromAlerts(String userId) async {
    // TODO: Implement real-time alerts unsubscription
  }
}
