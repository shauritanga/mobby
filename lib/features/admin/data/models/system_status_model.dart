import '../../domain/entities/system_status.dart';

class ServiceHealthModel extends ServiceHealth {
  const ServiceHealthModel({
    required super.serviceName,
    required super.status,
    required super.responseTime,
    required super.uptime,
    super.version,
    required super.lastChecked,
    super.errorMessage,
    super.metrics,
  });

  factory ServiceHealthModel.fromJson(Map<String, dynamic> json) {
    return ServiceHealthModel(
      serviceName: json['serviceName'] as String,
      status: ServiceStatus.values.byName(json['status'] as String),
      responseTime: (json['responseTime'] as num).toDouble(),
      uptime: (json['uptime'] as num).toDouble(),
      lastChecked: DateTime.parse(json['lastChecked'] as String),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceName': serviceName,
      'status': status.name,
      'responseTime': responseTime,
      'lastChecked': lastChecked.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  factory ServiceHealthModel.fromEntity(ServiceHealth health) {
    return ServiceHealthModel(
      serviceName: health.serviceName,
      status: health.status,
      responseTime: health.responseTime,
      uptime: health.uptime,
      version: health.version,
      lastChecked: health.lastChecked,
      errorMessage: health.errorMessage,
      metrics: health.metrics,
    );
  }

  ServiceHealth toEntity() => this;
}

class SystemAlertModel extends SystemAlert {
  const SystemAlertModel({
    required super.id,
    required super.title,
    required super.message,
    required super.severity,
    required super.source,
    required super.timestamp,
    super.isResolved = false,
    super.resolvedAt,
    super.resolvedBy,
    super.metadata,
  });

  factory SystemAlertModel.fromJson(Map<String, dynamic> json) {
    return SystemAlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: AlertSeverity.values.byName(json['severity'] as String),
      source: json['source'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isResolved: json['isResolved'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'severity': severity.name,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
      'isResolved': isResolved,
    };
  }

  factory SystemAlertModel.fromEntity(SystemAlert alert) {
    return SystemAlertModel(
      id: alert.id,
      title: alert.title,
      message: alert.message,
      severity: alert.severity,
      source: alert.source,
      timestamp: alert.timestamp,
      isResolved: alert.isResolved,
      resolvedAt: alert.resolvedAt,
      resolvedBy: alert.resolvedBy,
      metadata: alert.metadata,
    );
  }

  SystemAlert toEntity() => this;
}

class SystemResourceModel extends SystemResource {
  const SystemResourceModel({
    required super.name,
    required super.usage,
    required super.capacity,
    required super.unit,
    required super.status,
    required super.lastUpdated,
  });

  factory SystemResourceModel.fromJson(Map<String, dynamic> json) {
    return SystemResourceModel(
      name: json['name'] as String,
      usage: (json['usage'] as num).toDouble(),
      capacity: (json['capacity'] as num).toDouble(),
      unit: json['unit'] as String,
      status: ServiceStatus.values.byName(json['status'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'usage': usage,
      'capacity': capacity,
      'unit': unit,
      'status': status.name,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory SystemResourceModel.fromEntity(SystemResource resource) {
    return SystemResourceModel(
      name: resource.name,
      usage: resource.usage,
      capacity: resource.capacity,
      unit: resource.unit,
      status: resource.status,
      lastUpdated: resource.lastUpdated,
    );
  }

  SystemResource toEntity() => this;
}

class SystemStatusModel extends SystemStatus {
  const SystemStatusModel({
    required super.id,
    required super.overallStatus,
    required super.services,
    required super.alerts,
    required super.resources,
    required super.systemInfo,
    required super.lastUpdated,
    required super.upSince,
  });

  factory SystemStatusModel.fromJson(Map<String, dynamic> json) {
    return SystemStatusModel(
      id: json['id'] as String,
      overallStatus: ServiceStatus.values.byName(
        json['overallStatus'] as String,
      ),
      services: _servicesFromJson(json['services'] as List<dynamic>),
      alerts: _alertsFromJson(json['alerts'] as List<dynamic>),
      resources: _resourcesFromJson(json['resources'] as List<dynamic>),
      systemInfo: json['systemInfo'] as Map<String, dynamic>,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      upSince: DateTime.parse(json['upSince'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'overallStatus': overallStatus.name,
      'services': _servicesToJson(services),
      'alerts': _alertsToJson(alerts),
      'resources': _resourcesToJson(resources),
      'systemInfo': systemInfo,
      'lastUpdated': lastUpdated.toIso8601String(),
      'upSince': upSince.toIso8601String(),
    };
  }

  factory SystemStatusModel.fromEntity(SystemStatus status) {
    return SystemStatusModel(
      id: status.id,
      overallStatus: status.overallStatus,
      services: status.services,
      alerts: status.alerts,
      resources: status.resources,
      systemInfo: status.systemInfo,
      lastUpdated: status.lastUpdated,
      upSince: status.upSince,
    );
  }

  SystemStatus toEntity() => this;
}

// Helper functions for JSON conversion
List<ServiceHealth> _servicesFromJson(List<dynamic> json) {
  return json
      .map((e) => ServiceHealthModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<Map<String, dynamic>> _servicesToJson(List<ServiceHealth> services) {
  return services
      .map((e) => ServiceHealthModel.fromEntity(e).toJson())
      .toList();
}

List<SystemAlert> _alertsFromJson(List<dynamic> json) {
  return json
      .map((e) => SystemAlertModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<Map<String, dynamic>> _alertsToJson(List<SystemAlert> alerts) {
  return alerts.map((e) => SystemAlertModel.fromEntity(e).toJson()).toList();
}

List<SystemResource> _resourcesFromJson(List<dynamic> json) {
  return json
      .map((e) => SystemResourceModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<Map<String, dynamic>> _resourcesToJson(List<SystemResource> resources) {
  return resources
      .map((e) => SystemResourceModel.fromEntity(e).toJson())
      .toList();
}
