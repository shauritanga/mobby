import '../entities/metric.dart';
import '../repositories/admin_repository.dart';

class ViewMetricsParams {
  final List<MetricType>? types;
  final MetricPeriod? period;
  final DateTime? startDate;
  final DateTime? endDate;

  const ViewMetricsParams({
    this.types,
    this.period,
    this.startDate,
    this.endDate,
  });
}

class ViewMetrics {
  final AdminRepository repository;

  ViewMetrics(this.repository);

  Future<List<Metric>> call(ViewMetricsParams params) async {
    return await repository.getMetrics(
      types: params.types,
      period: params.period,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetDashboardMetrics {
  final AdminRepository repository;

  GetDashboardMetrics(this.repository);

  Future<List<Metric>> call() async {
    return await repository.getDashboardMetrics();
  }
}

class GetRealtimeMetrics {
  final AdminRepository repository;

  GetRealtimeMetrics(this.repository);

  Future<List<Metric>> call() async {
    return await repository.getRealtimeMetrics();
  }
}

class GetMetricDetails {
  final AdminRepository repository;

  GetMetricDetails(this.repository);

  Future<Metric?> call(String metricId) async {
    return await repository.getMetricById(metricId);
  }
}

class GetMetricsSummary {
  final AdminRepository repository;

  GetMetricsSummary(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getMetricsSummary();
  }
}

class GetUserAnalytics {
  final AdminRepository repository;

  GetUserAnalytics(this.repository);

  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getUserAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class GetOrderAnalytics {
  final AdminRepository repository;

  GetOrderAnalytics(this.repository);

  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getOrderAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class GetRevenueAnalytics {
  final AdminRepository repository;

  GetRevenueAnalytics(this.repository);

  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getRevenueAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class GetProductAnalytics {
  final AdminRepository repository;

  GetProductAnalytics(this.repository);

  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getProductAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class GetInsuranceAnalytics {
  final AdminRepository repository;

  GetInsuranceAnalytics(this.repository);

  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getInsuranceAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
