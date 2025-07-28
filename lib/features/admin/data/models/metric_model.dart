import '../../domain/entities/metric.dart';

class MetricDataPointModel {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? metadata;

  const MetricDataPointModel({
    required this.timestamp,
    required this.value,
    this.metadata,
  });

  factory MetricDataPointModel.fromJson(Map<String, dynamic> json) {
    return MetricDataPointModel(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'metadata': metadata,
    };
  }

  factory MetricDataPointModel.fromEntity(MetricDataPoint dataPoint) {
    return MetricDataPointModel(
      timestamp: dataPoint.timestamp,
      value: dataPoint.value,
      metadata: dataPoint.metadata,
    );
  }

  MetricDataPoint toEntity() {
    return MetricDataPoint(
      timestamp: timestamp,
      value: value,
      metadata: metadata,
    );
  }
}

class MetricTrendModel {
  final TrendDirection direction;
  final double percentage;
  final String period;
  final double previousValue;
  final double currentValue;

  const MetricTrendModel({
    required this.direction,
    required this.percentage,
    required this.period,
    required this.previousValue,
    required this.currentValue,
  });

  factory MetricTrendModel.fromJson(Map<String, dynamic> json) {
    return MetricTrendModel(
      direction: TrendDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => TrendDirection.stable,
      ),
      percentage: (json['percentage'] as num).toDouble(),
      period: json['period'] as String,
      previousValue: (json['previousValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction.name,
      'percentage': percentage,
      'period': period,
      'previousValue': previousValue,
      'currentValue': currentValue,
    };
  }

  factory MetricTrendModel.fromEntity(MetricTrend trend) {
    return MetricTrendModel(
      direction: trend.direction,
      percentage: trend.percentage,
      period: trend.period,
      previousValue: trend.previousValue,
      currentValue: trend.currentValue,
    );
  }

  MetricTrend toEntity() {
    return MetricTrend(
      direction: direction,
      percentage: percentage,
      period: period,
      previousValue: previousValue,
      currentValue: currentValue,
    );
  }
}

class MetricModel {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final MetricType type;
  final MetricPeriod period;
  final double currentValue;
  final double? targetValue;
  final String unit;
  final String? currency;
  final MetricTrend? trend;
  final List<MetricDataPoint> dataPoints;
  final Map<String, dynamic> filters;
  final bool isRealTime;
  final DateTime lastUpdated;
  final DateTime createdAt;

  const MetricModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.type,
    required this.period,
    required this.currentValue,
    this.targetValue,
    required this.unit,
    this.currency,
    this.trend,
    required this.dataPoints,
    required this.filters,
    this.isRealTime = false,
    required this.lastUpdated,
    required this.createdAt,
  });

  factory MetricModel.fromJson(Map<String, dynamic> json) {
    return MetricModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      type: MetricType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MetricType.users,
      ),
      period: MetricPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => MetricPeriod.daily,
      ),
      currentValue: (json['currentValue'] as num).toDouble(),
      targetValue: json['targetValue'] != null
          ? (json['targetValue'] as num).toDouble()
          : null,
      unit: json['unit'] as String,
      currency: json['currency'] as String?,
      trend: json['trend'] != null
          ? MetricTrendModel.fromJson(
              json['trend'] as Map<String, dynamic>,
            ).toEntity()
          : null,
      dataPoints: (json['dataPoints'] as List<dynamic>)
          .map(
            (e) => MetricDataPointModel.fromJson(
              e as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList(),
      filters: Map<String, dynamic>.from(json['filters'] as Map),
      isRealTime: json['isRealTime'] as bool? ?? false,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'type': type.name,
      'period': period.name,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'unit': unit,
      'currency': currency,
      'trend': trend != null
          ? MetricTrendModel.fromEntity(trend!).toJson()
          : null,
      'dataPoints': dataPoints
          .map((e) => MetricDataPointModel.fromEntity(e).toJson())
          .toList(),
      'filters': filters,
      'isRealTime': isRealTime,
      'lastUpdated': lastUpdated.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MetricModel.fromEntity(Metric metric) {
    return MetricModel(
      id: metric.id,
      name: metric.name,
      displayName: metric.displayName,
      description: metric.description,
      type: metric.type,
      period: metric.period,
      currentValue: metric.currentValue,
      targetValue: metric.targetValue,
      unit: metric.unit,
      currency: metric.currency,
      trend: metric.trend,
      dataPoints: metric.dataPoints,
      filters: metric.filters,
      isRealTime: metric.isRealTime,
      lastUpdated: metric.lastUpdated,
      createdAt: metric.createdAt,
    );
  }

  Metric toEntity() {
    return Metric(
      id: id,
      name: name,
      displayName: displayName,
      description: description,
      type: type,
      period: period,
      currentValue: currentValue,
      targetValue: targetValue,
      unit: unit,
      currency: currency,
      trend: trend,
      dataPoints: dataPoints,
      filters: filters,
      isRealTime: isRealTime,
      lastUpdated: lastUpdated,
      createdAt: createdAt,
    );
  }
}
