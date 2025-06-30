import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/metric_model.dart';
import '../models/report_model.dart';
import '../models/system_status_model.dart';
import '../../domain/entities/metric.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/system_status.dart';

abstract class AdminRemoteDataSource {
  // Metrics operations
  Future<List<MetricModel>> getMetrics({
    List<MetricType>? types,
    MetricPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<MetricModel?> getMetricById(String metricId);
  Future<List<MetricModel>> getDashboardMetrics();
  Future<List<MetricModel>> getRealtimeMetrics();
  Future<Map<String, dynamic>> getMetricsSummary();

  // Reports operations
  Future<List<ReportModel>> getReports({
    ReportType? type,
    ReportStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<ReportModel?> getReportById(String reportId);
  Future<ReportModel> createReport(ReportModel report);
  Future<ReportModel> updateReport(ReportModel report);
  Future<void> deleteReport(String reportId);
  Future<String> generateReport(String reportId);
  Future<List<ReportModel>> getScheduledReports();
  Future<ReportModel> scheduleReport(
    ReportModel report,
    ReportScheduleModel schedule,
  );

  // System Status operations
  Future<SystemStatusModel> getSystemStatus();
  Future<List<ServiceHealthModel>> getServicesHealth();
  Future<ServiceHealthModel?> getServiceHealth(String serviceName);
  Future<List<SystemAlertModel>> getSystemAlerts({
    AlertSeverity? severity,
    bool? isResolved,
    int limit = 50,
  });
  Future<void> resolveAlert(String alertId, String resolvedBy);
  Future<List<SystemResourceModel>> getSystemResources();

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
  Future<void> performQuickAction(
    String actionType,
    Map<String, dynamic> parameters,
  );
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
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore _firestore;

  AdminRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<MetricModel>> getMetrics({
    List<MetricType>? types,
    MetricPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Fetching admin metrics

      Query query = _firestore.collection('adminMetrics');

      if (types != null && types.isNotEmpty) {
        query = query.where('type', whereIn: types.map((t) => t.name).toList());
      }

      if (period != null) {
        query = query.where('period', isEqualTo: period.name);
      }

      query = query.orderBy('lastUpdated', descending: true);

      final querySnapshot = await query.get();

      final metrics = querySnapshot.docs
          .map(
            (doc) => MetricModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Found ${metrics.length} metrics
      return metrics;
    } catch (e) {
      // Error fetching metrics: $e
      throw Exception('Failed to fetch metrics: $e');
    }
  }

  @override
  Future<MetricModel?> getMetricById(String metricId) async {
    try {
      final doc = await _firestore
          .collection('adminMetrics')
          .doc(metricId)
          .get();

      if (!doc.exists) return null;

      return MetricModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch metric: $e');
    }
  }

  @override
  Future<List<MetricModel>> getDashboardMetrics() async {
    try {
      // Fetching dashboard metrics

      final querySnapshot = await _firestore
          .collection('adminMetrics')
          .where('isDashboard', isEqualTo: true)
          .orderBy('order')
          .get();

      final metrics = querySnapshot.docs
          .map((doc) => MetricModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      // Found ${metrics.length} dashboard metrics
      return metrics;
    } catch (e) {
      // Error fetching dashboard metrics: $e
      throw Exception('Failed to fetch dashboard metrics: $e');
    }
  }

  @override
  Future<List<MetricModel>> getRealtimeMetrics() async {
    try {
      final querySnapshot = await _firestore
          .collection('adminMetrics')
          .where('isRealTime', isEqualTo: true)
          .orderBy('lastUpdated', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MetricModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch realtime metrics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getMetricsSummary() async {
    try {
      // Aggregate metrics summary from various collections
      final usersCount = await _getUsersCount();
      final ordersCount = await _getOrdersCount();
      final revenue = await _getTotalRevenue();
      final productsCount = await _getProductsCount();

      return {
        'totalUsers': usersCount,
        'totalOrders': ordersCount,
        'totalRevenue': revenue,
        'totalProducts': productsCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to fetch metrics summary: $e');
    }
  }

  Future<int> _getUsersCount() async {
    final snapshot = await _firestore.collection('users').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getOrdersCount() async {
    final snapshot = await _firestore.collection('orders').count().get();
    return snapshot.count ?? 0;
  }

  Future<double> _getTotalRevenue() async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      total += amount;
    }
    return total;
  }

  Future<int> _getProductsCount() async {
    final snapshot = await _firestore.collection('products').count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<List<ReportModel>> getReports({
    ReportType? type,
    ReportStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('adminReports');

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.orderBy('createdAt', descending: true);

      if (page > 1) {
        final offset = (page - 1) * limit;
        query = query.limit(offset + limit);
      } else {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (page > 1) {
        final offset = (page - 1) * limit;
        docs = docs.skip(offset).toList();
      }

      return docs
          .map(
            (doc) => ReportModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  @override
  Future<ReportModel?> getReportById(String reportId) async {
    try {
      final doc = await _firestore
          .collection('adminReports')
          .doc(reportId)
          .get();

      if (!doc.exists) return null;

      return ReportModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch report: $e');
    }
  }

  @override
  Future<ReportModel> createReport(ReportModel report) async {
    try {
      final reportData = report.toJson();
      reportData.remove('id');

      final docRef = await _firestore
          .collection('adminReports')
          .add(reportData);

      return ReportModel.fromJson({'id': docRef.id, ...reportData});
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  @override
  Future<ReportModel> updateReport(ReportModel report) async {
    try {
      await _firestore
          .collection('adminReports')
          .doc(report.id)
          .update(report.toJson());
      return report;
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('adminReports').doc(reportId).delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  @override
  Future<String> generateReport(String reportId) async {
    try {
      // In a real implementation, this would trigger report generation
      // For now, we'll simulate the process
      await _firestore.collection('adminReports').doc(reportId).update({
        'status': ReportStatus.generating.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Simulate generation process
      await Future.delayed(const Duration(seconds: 2));

      final fileUrl = 'https://storage.example.com/reports/$reportId.pdf';

      await _firestore.collection('adminReports').doc(reportId).update({
        'status': ReportStatus.completed.name,
        'fileUrl': fileUrl,
        'generatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return fileUrl;
    } catch (e) {
      await _firestore.collection('adminReports').doc(reportId).update({
        'status': ReportStatus.failed.name,
        'errorMessage': e.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      throw Exception('Failed to generate report: $e');
    }
  }

  @override
  Future<List<ReportModel>> getScheduledReports() async {
    try {
      final querySnapshot = await _firestore
          .collection('adminReports')
          .where('schedule', isNotEqualTo: null)
          .where('schedule.isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReportModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch scheduled reports: $e');
    }
  }

  @override
  Future<ReportModel> scheduleReport(
    ReportModel report,
    ReportScheduleModel schedule,
  ) async {
    try {
      final updatedReport = ReportModel.fromJson({
        ...report.toJson(),
        'schedule': schedule.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return await updateReport(updatedReport);
    } catch (e) {
      throw Exception('Failed to schedule report: $e');
    }
  }

  @override
  Future<SystemStatusModel> getSystemStatus() async {
    try {
      // Simulate system status - in real implementation, this would check actual services
      final services = await getServicesHealth();
      final alerts = await getSystemAlerts(limit: 10);
      final resources = await getSystemResources();

      ServiceStatus overallStatus = ServiceStatus.healthy;
      if (services.any((s) => s.status == ServiceStatus.down)) {
        overallStatus = ServiceStatus.down;
      } else if (services.any((s) => s.status == ServiceStatus.critical)) {
        overallStatus = ServiceStatus.critical;
      } else if (services.any((s) => s.status == ServiceStatus.warning)) {
        overallStatus = ServiceStatus.warning;
      }

      return SystemStatusModel(
        id: 'system-status',
        overallStatus: overallStatus,
        services: services,
        alerts: alerts,
        resources: resources,
        systemInfo: {
          'version': '1.0.0',
          'environment': 'production',
          'region': 'us-east-1',
        },
        lastUpdated: DateTime.now(),
        upSince: DateTime.now().subtract(const Duration(days: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch system status: $e');
    }
  }

  @override
  Future<List<ServiceHealthModel>> getServicesHealth() async {
    try {
      // Simulate service health checks
      final services = [
        ServiceHealthModel(
          serviceName: 'API Gateway',
          status: ServiceStatus.healthy,
          responseTime: 120,
          uptime: 0.999,
          version: '1.2.3',
          lastChecked: DateTime.now(),
        ),
        ServiceHealthModel(
          serviceName: 'Database',
          status: ServiceStatus.healthy,
          responseTime: 45,
          uptime: 0.998,
          version: '5.7.0',
          lastChecked: DateTime.now(),
        ),
        ServiceHealthModel(
          serviceName: 'Authentication',
          status: ServiceStatus.warning,
          responseTime: 200,
          uptime: 0.995,
          version: '2.1.0',
          lastChecked: DateTime.now(),
          errorMessage: 'High response time detected',
        ),
        ServiceHealthModel(
          serviceName: 'File Storage',
          status: ServiceStatus.healthy,
          responseTime: 80,
          uptime: 0.999,
          version: '3.0.1',
          lastChecked: DateTime.now(),
        ),
      ];

      return services;
    } catch (e) {
      throw Exception('Failed to fetch services health: $e');
    }
  }

  @override
  Future<ServiceHealthModel?> getServiceHealth(String serviceName) async {
    try {
      final services = await getServicesHealth();
      return services.where((s) => s.serviceName == serviceName).firstOrNull;
    } catch (e) {
      throw Exception('Failed to fetch service health: $e');
    }
  }

  @override
  Future<List<SystemAlertModel>> getSystemAlerts({
    AlertSeverity? severity,
    bool? isResolved,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore.collection('systemAlerts');

      if (severity != null) {
        query = query.where('severity', isEqualTo: severity.name);
      }

      if (isResolved != null) {
        query = query.where('isResolved', isEqualTo: isResolved);
      }

      query = query.orderBy('timestamp', descending: true).limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map(
            (doc) => SystemAlertModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      // Return simulated alerts if collection doesn't exist
      return [
        SystemAlertModel(
          id: 'alert-1',
          title: 'High CPU Usage',
          message: 'CPU usage has exceeded 80% for the past 10 minutes',
          severity: AlertSeverity.warning,
          source: 'System Monitor',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        SystemAlertModel(
          id: 'alert-2',
          title: 'Database Connection Pool Full',
          message: 'Database connection pool has reached maximum capacity',
          severity: AlertSeverity.error,
          source: 'Database Monitor',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];
    }
  }

  @override
  Future<void> resolveAlert(String alertId, String resolvedBy) async {
    try {
      await _firestore.collection('systemAlerts').doc(alertId).update({
        'isResolved': true,
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': resolvedBy,
      });
    } catch (e) {
      throw Exception('Failed to resolve alert: $e');
    }
  }

  @override
  Future<List<SystemResourceModel>> getSystemResources() async {
    try {
      // Simulate system resources
      return [
        SystemResourceModel(
          name: 'CPU',
          usage: 65.5,
          capacity: 100.0,
          unit: '%',
          status: ServiceStatus.healthy,
          lastUpdated: DateTime.now(),
        ),
        SystemResourceModel(
          name: 'Memory',
          usage: 12.8,
          capacity: 16.0,
          unit: 'GB',
          status: ServiceStatus.warning,
          lastUpdated: DateTime.now(),
        ),
        SystemResourceModel(
          name: 'Disk',
          usage: 450.0,
          capacity: 1000.0,
          unit: 'GB',
          status: ServiceStatus.healthy,
          lastUpdated: DateTime.now(),
        ),
        SystemResourceModel(
          name: 'Network',
          usage: 125.0,
          capacity: 1000.0,
          unit: 'Mbps',
          status: ServiceStatus.healthy,
          lastUpdated: DateTime.now(),
        ),
      ];
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
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;

      // Calculate new users in period
      int newUsers = 0;
      if (startDate != null) {
        newUsers = usersSnapshot.docs.where((doc) {
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          return createdAt != null && createdAt.isAfter(startDate);
        }).length;
      }

      return {
        'totalUsers': totalUsers,
        'newUsers': newUsers,
        'activeUsers': (totalUsers * 0.7).round(), // Simulate 70% active
        'userGrowthRate': newUsers > 0 ? ((newUsers / totalUsers) * 100) : 0.0,
        'averageSessionDuration': 12.5, // minutes
        'topUserLocations': ['Dar es Salaam', 'Arusha', 'Mwanza'],
      };
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
      final ordersSnapshot = await _firestore.collection('orders').get();
      final totalOrders = ordersSnapshot.docs.length;

      double totalRevenue = 0.0;
      int completedOrders = 0;

      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

        totalRevenue += amount;
        if (status == 'delivered') completedOrders++;
      }

      return {
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'totalRevenue': totalRevenue,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
        'conversionRate': 15.5, // Simulate 15.5%
        'topProducts': ['Product A', 'Product B', 'Product C'],
      };
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
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'delivered')
          .get();

      double totalRevenue = 0.0;
      final monthlyRevenue = <String, double>{};

      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();
        final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        totalRevenue += amount;

        if (createdAt != null) {
          final monthKey =
              '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
          monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0.0) + amount;
        }
      }

      return {
        'totalRevenue': totalRevenue,
        'monthlyRevenue': monthlyRevenue,
        'revenueGrowthRate': 12.5, // Simulate 12.5% growth
        'averageMonthlyRevenue': monthlyRevenue.values.isNotEmpty
            ? monthlyRevenue.values.reduce((a, b) => a + b) /
                  monthlyRevenue.length
            : 0.0,
        'currency': 'TZS',
      };
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
      final productsSnapshot = await _firestore.collection('products').get();
      final totalProducts = productsSnapshot.docs.length;

      int activeProducts = 0;
      final categoryCount = <String, int>{};

      for (final doc in productsSnapshot.docs) {
        final data = doc.data();
        final isActive = data['isActive'] as bool? ?? false;
        final category = data['category'] as String? ?? 'Other';

        if (isActive) activeProducts++;
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      return {
        'totalProducts': totalProducts,
        'activeProducts': activeProducts,
        'inactiveProducts': totalProducts - activeProducts,
        'categoriesCount': categoryCount.length,
        'topCategories':
            (categoryCount.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .take(5)
                .map((e) => e.key)
                .toList(),
        'averageProductsPerCategory': categoryCount.isNotEmpty
            ? totalProducts / categoryCount.length
            : 0.0,
      };
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
      final policiesSnapshot = await _firestore.collection('policies').get();
      final totalPolicies = policiesSnapshot.docs.length;

      int activePolicies = 0;
      double totalPremiums = 0.0;
      final typeCount = <String, int>{};

      for (final doc in policiesSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        final premium = (data['premiumAmount'] as num?)?.toDouble() ?? 0.0;
        final type = data['type'] as String? ?? 'other';

        if (status == 'active') activePolicies++;
        totalPremiums += premium;
        typeCount[type] = (typeCount[type] ?? 0) + 1;
      }

      return {
        'totalPolicies': totalPolicies,
        'activePolicies': activePolicies,
        'totalPremiums': totalPremiums,
        'averagePremium': totalPolicies > 0
            ? totalPremiums / totalPolicies
            : 0.0,
        'policyTypes': typeCount,
        'claimSuccessRate': 85.5, // Simulate 85.5%
        'currency': 'TZS',
      };
    } catch (e) {
      throw Exception('Failed to fetch insurance analytics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getQuickActionsData() async {
    try {
      final usersCount = await _getUsersCount();
      final ordersCount = await _getOrdersCount();
      final revenue = await _getTotalRevenue();

      return {
        'pendingOrders': (ordersCount * 0.15).round(),
        'totalRevenue': revenue,
        'newUsers': (usersCount * 0.05).round(),
        'systemAlerts': 3,
        'recentActivity': 25,
        'serverUptime': '99.9%',
        'lastBackup': DateTime.now()
            .subtract(const Duration(hours: 6))
            .toIso8601String(),
      };
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
      // Simulate quick action execution
      // Log quick action execution
      // In production, use proper logging framework

      switch (actionType) {
        case 'backup_database':
          await Future.delayed(const Duration(seconds: 2));
          break;
        case 'clear_cache':
          await Future.delayed(const Duration(seconds: 1));
          break;
        case 'send_notification':
          await Future.delayed(const Duration(milliseconds: 500));
          break;
        case 'restart_service':
          await Future.delayed(const Duration(seconds: 3));
          break;
        default:
          throw Exception('Unknown action type: $actionType');
      }
    } catch (e) {
      throw Exception('Failed to perform quick action: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentActivities({
    int limit = 20,
  }) async {
    try {
      // Simulate recent activities
      final activities = <Map<String, dynamic>>[];
      final now = DateTime.now();

      for (int i = 0; i < limit; i++) {
        activities.add({
          'id': 'activity-$i',
          'type': [
            'user_login',
            'order_placed',
            'payment_processed',
            'report_generated',
          ][i % 4],
          'description': _getActivityDescription(i % 4),
          'user': 'User ${i + 1}',
          'timestamp': now.subtract(Duration(minutes: i * 5)).toIso8601String(),
          'severity': ['info', 'success', 'warning'][i % 3],
        });
      }

      return activities;
    } catch (e) {
      throw Exception('Failed to fetch recent activities: $e');
    }
  }

  String _getActivityDescription(int type) {
    switch (type) {
      case 0:
        return 'User logged into the system';
      case 1:
        return 'New order placed successfully';
      case 2:
        return 'Payment processed for order';
      case 3:
        return 'Monthly report generated';
      default:
        return 'System activity occurred';
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemOverview() async {
    try {
      final systemStatus = await getSystemStatus();
      final metrics = await getMetricsSummary();

      return {
        'systemHealth': systemStatus.overallStatus.name,
        'totalUsers': metrics['totalUsers'],
        'totalOrders': metrics['totalOrders'],
        'totalRevenue': metrics['totalRevenue'],
        'activeServices': systemStatus.healthyServicesCount,
        'totalServices': systemStatus.services.length,
        'activeAlerts': systemStatus.activeAlertsCount,
        'systemUptime': systemStatus.formattedUptime,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
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
      // Simulate data export
      final exportId = 'export-${DateTime.now().millisecondsSinceEpoch}';
      final fileName =
          '${dataType}_export_${DateTime.now().toIso8601String().split('T')[0]}.$format';

      // In a real implementation, this would generate the actual export file
      await Future.delayed(const Duration(seconds: 3));

      final fileUrl =
          'https://storage.example.com/exports/$fileName?id=$exportId';

      return fileUrl;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
}
