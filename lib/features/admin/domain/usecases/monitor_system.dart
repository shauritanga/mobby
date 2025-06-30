import '../entities/system_status.dart';
import '../repositories/admin_repository.dart';

class MonitorSystem {
  final AdminRepository repository;

  MonitorSystem(this.repository);

  Future<SystemStatus> call() async {
    return await repository.getSystemStatus();
  }
}

class GetServicesHealth {
  final AdminRepository repository;

  GetServicesHealth(this.repository);

  Future<List<ServiceHealth>> call() async {
    return await repository.getServicesHealth();
  }
}

class GetServiceHealth {
  final AdminRepository repository;

  GetServiceHealth(this.repository);

  Future<ServiceHealth?> call(String serviceName) async {
    return await repository.getServiceHealth(serviceName);
  }
}

class GetSystemAlertsParams {
  final AlertSeverity? severity;
  final bool? isResolved;
  final int limit;

  const GetSystemAlertsParams({
    this.severity,
    this.isResolved,
    this.limit = 50,
  });
}

class GetSystemAlerts {
  final AdminRepository repository;

  GetSystemAlerts(this.repository);

  Future<List<SystemAlert>> call(GetSystemAlertsParams params) async {
    return await repository.getSystemAlerts(
      severity: params.severity,
      isResolved: params.isResolved,
      limit: params.limit,
    );
  }
}

class ResolveAlertParams {
  final String alertId;
  final String resolvedBy;

  const ResolveAlertParams({
    required this.alertId,
    required this.resolvedBy,
  });
}

class ResolveAlert {
  final AdminRepository repository;

  ResolveAlert(this.repository);

  Future<void> call(ResolveAlertParams params) async {
    return await repository.resolveAlert(params.alertId, params.resolvedBy);
  }
}

class GetSystemResources {
  final AdminRepository repository;

  GetSystemResources(this.repository);

  Future<List<SystemResource>> call() async {
    return await repository.getSystemResources();
  }
}

class GetQuickActionsData {
  final AdminRepository repository;

  GetQuickActionsData(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getQuickActionsData();
  }
}

class PerformQuickActionParams {
  final String actionType;
  final Map<String, dynamic> parameters;

  const PerformQuickActionParams({
    required this.actionType,
    required this.parameters,
  });
}

class PerformQuickAction {
  final AdminRepository repository;

  PerformQuickAction(this.repository);

  Future<void> call(PerformQuickActionParams params) async {
    return await repository.performQuickAction(
      params.actionType,
      params.parameters,
    );
  }
}

class GetRecentActivities {
  final AdminRepository repository;

  GetRecentActivities(this.repository);

  Future<List<Map<String, dynamic>>> call({int limit = 20}) async {
    return await repository.getRecentActivities(limit: limit);
  }
}

class GetSystemOverview {
  final AdminRepository repository;

  GetSystemOverview(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getSystemOverview();
  }
}

class SubscribeToAlerts {
  final AdminRepository repository;

  SubscribeToAlerts(this.repository);

  Future<void> call(String userId) async {
    return await repository.subscribeToAlerts(userId);
  }
}

class UnsubscribeFromAlerts {
  final AdminRepository repository;

  UnsubscribeFromAlerts(this.repository);

  Future<void> call(String userId) async {
    return await repository.unsubscribeFromAlerts(userId);
  }
}
