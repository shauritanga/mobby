import 'package:equatable/equatable.dart';

enum ServiceStatus {
  healthy,
  warning,
  critical,
  down,
  maintenance
}

enum AlertSeverity {
  info,
  warning,
  error,
  critical
}

class ServiceHealth extends Equatable {
  final String serviceName;
  final ServiceStatus status;
  final double responseTime;
  final double uptime;
  final String? version;
  final DateTime lastChecked;
  final String? errorMessage;
  final Map<String, dynamic>? metrics;

  const ServiceHealth({
    required this.serviceName,
    required this.status,
    required this.responseTime,
    required this.uptime,
    this.version,
    required this.lastChecked,
    this.errorMessage,
    this.metrics,
  });

  bool get isHealthy => status == ServiceStatus.healthy;
  bool get hasIssues => status != ServiceStatus.healthy;
  bool get isDown => status == ServiceStatus.down;

  String get statusDisplayName {
    switch (status) {
      case ServiceStatus.healthy:
        return 'Healthy';
      case ServiceStatus.warning:
        return 'Warning';
      case ServiceStatus.critical:
        return 'Critical';
      case ServiceStatus.down:
        return 'Down';
      case ServiceStatus.maintenance:
        return 'Maintenance';
    }
  }

  String get formattedUptime => '${(uptime * 100).toStringAsFixed(2)}%';
  String get formattedResponseTime => '${responseTime.toStringAsFixed(0)}ms';

  @override
  List<Object?> get props => [
        serviceName,
        status,
        responseTime,
        uptime,
        version,
        lastChecked,
        errorMessage,
        metrics,
      ];
}

class SystemAlert extends Equatable {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final String source;
  final DateTime timestamp;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final Map<String, dynamic>? metadata;

  const SystemAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.source,
    required this.timestamp,
    this.isResolved = false,
    this.resolvedAt,
    this.resolvedBy,
    this.metadata,
  });

  bool get isActive => !isResolved;
  bool get isCritical => severity == AlertSeverity.critical;
  bool get isError => severity == AlertSeverity.error;

  String get severityDisplayName {
    switch (severity) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.error:
        return 'Error';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  Duration get age => DateTime.now().difference(timestamp);

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        severity,
        source,
        timestamp,
        isResolved,
        resolvedAt,
        resolvedBy,
        metadata,
      ];
}

class SystemResource extends Equatable {
  final String name;
  final double usage;
  final double capacity;
  final String unit;
  final ServiceStatus status;
  final DateTime lastUpdated;

  const SystemResource({
    required this.name,
    required this.usage,
    required this.capacity,
    required this.unit,
    required this.status,
    required this.lastUpdated,
  });

  double get usagePercentage => capacity > 0 ? (usage / capacity) * 100 : 0.0;
  double get availableCapacity => capacity - usage;
  bool get isNearCapacity => usagePercentage >= 80.0;
  bool get isAtCapacity => usagePercentage >= 95.0;

  String get formattedUsage => '${usage.toStringAsFixed(1)} $unit';
  String get formattedCapacity => '${capacity.toStringAsFixed(1)} $unit';
  String get formattedPercentage => '${usagePercentage.toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [
        name,
        usage,
        capacity,
        unit,
        status,
        lastUpdated,
      ];
}

class SystemStatus extends Equatable {
  final String id;
  final ServiceStatus overallStatus;
  final List<ServiceHealth> services;
  final List<SystemAlert> alerts;
  final List<SystemResource> resources;
  final Map<String, dynamic> systemInfo;
  final DateTime lastUpdated;
  final DateTime upSince;

  const SystemStatus({
    required this.id,
    required this.overallStatus,
    required this.services,
    required this.alerts,
    required this.resources,
    required this.systemInfo,
    required this.lastUpdated,
    required this.upSince,
  });

  bool get isHealthy => overallStatus == ServiceStatus.healthy;
  bool get hasIssues => overallStatus != ServiceStatus.healthy;
  bool get hasActiveAlerts => alerts.any((alert) => alert.isActive);
  bool get hasCriticalAlerts => alerts.any((alert) => alert.isCritical && alert.isActive);

  int get healthyServicesCount => services.where((s) => s.isHealthy).length;
  int get unhealthyServicesCount => services.where((s) => s.hasIssues).length;
  int get activeAlertsCount => alerts.where((a) => a.isActive).length;
  int get criticalAlertsCount => alerts.where((a) => a.isCritical && a.isActive).length;

  double get averageResponseTime {
    if (services.isEmpty) return 0.0;
    return services.fold<double>(0.0, (sum, service) => sum + service.responseTime) / services.length;
  }

  double get averageUptime {
    if (services.isEmpty) return 0.0;
    return services.fold<double>(0.0, (sum, service) => sum + service.uptime) / services.length;
  }

  Duration get systemUptime => DateTime.now().difference(upSince);

  String get overallStatusDisplayName {
    switch (overallStatus) {
      case ServiceStatus.healthy:
        return 'All Systems Operational';
      case ServiceStatus.warning:
        return 'Minor Issues Detected';
      case ServiceStatus.critical:
        return 'Major Issues Detected';
      case ServiceStatus.down:
        return 'System Outage';
      case ServiceStatus.maintenance:
        return 'Maintenance Mode';
    }
  }

  String get formattedUptime {
    final duration = systemUptime;
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  List<Object?> get props => [
        id,
        overallStatus,
        services,
        alerts,
        resources,
        systemInfo,
        lastUpdated,
        upSince,
      ];
}
