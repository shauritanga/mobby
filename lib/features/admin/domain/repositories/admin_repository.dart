import '../entities/metric.dart';
import '../entities/report.dart';
import '../entities/system_status.dart';

abstract class AdminRepository {
  // Metrics operations
  Future<List<Metric>> getMetrics({
    List<MetricType>? types,
    MetricPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Metric?> getMetricById(String metricId);
  
  Future<List<Metric>> getDashboardMetrics();
  
  Future<List<Metric>> getRealtimeMetrics();
  
  Future<Map<String, dynamic>> getMetricsSummary();

  // Reports operations
  Future<List<Report>> getReports({
    ReportType? type,
    ReportStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });
  
  Future<Report?> getReportById(String reportId);
  
  Future<Report> createReport(Report report);
  
  Future<Report> updateReport(Report report);
  
  Future<void> deleteReport(String reportId);
  
  Future<String> generateReport(String reportId);
  
  Future<List<Report>> getScheduledReports();
  
  Future<Report> scheduleReport(Report report, ReportSchedule schedule);

  // System Status operations
  Future<SystemStatus> getSystemStatus();
  
  Future<List<ServiceHealth>> getServicesHealth();
  
  Future<ServiceHealth?> getServiceHealth(String serviceName);
  
  Future<List<SystemAlert>> getSystemAlerts({
    AlertSeverity? severity,
    bool? isResolved,
    int limit = 50,
  });
  
  Future<void> resolveAlert(String alertId, String resolvedBy);
  
  Future<List<SystemResource>> getSystemResources();

  // Analytics operations
  Future<Map<String, dynamic>> getUserAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Map<String, dynamic>> getOrderAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Map<String, dynamic>> getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Map<String, dynamic>> getProductAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Map<String, dynamic>> getInsuranceAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Quick Actions operations
  Future<Map<String, dynamic>> getQuickActionsData();
  
  Future<void> performQuickAction(String actionType, Map<String, dynamic> parameters);
  
  Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 20});
  
  Future<Map<String, dynamic>> getSystemOverview();

  // Export operations
  Future<String> exportData({
    required String dataType,
    required String format,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? filters,
  });

  // Notifications
  Future<void> subscribeToAlerts(String userId);
  Future<void> unsubscribeFromAlerts(String userId);
}
