import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/metric.dart';

part 'metric_model.g.dart';

@JsonSerializable()
class MetricDataPointModel {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? metadata;

  const MetricDataPointModel({
    required this.timestamp,
    required this.value,
    this.metadata,
  });

  factory MetricDataPointModel.fromJson(Map<String, dynamic> json) =>
      _$MetricDataPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetricDataPointModelToJson(this);

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

@JsonSerializable()
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

  factory MetricTrendModel.fromJson(Map<String, dynamic> json) =>
      _$MetricTrendModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetricTrendModelToJson(this);

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

@JsonSerializable()
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
  @JsonKey(fromJson: _trendFromJson, toJson: _trendToJson)
  final MetricTrend? trend;
  @JsonKey(fromJson: _dataPointsFromJson, toJson: _dataPointsToJson)
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

  factory MetricModel.fromJson(Map<String, dynamic> json) =>
      _$MetricModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetricModelToJson(this);

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

// Helper functions for JSON conversion
MetricTrend? _trendFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return MetricTrendModel.fromJson(json).toEntity();
}

Map<String, dynamic>? _trendToJson(MetricTrend? trend) {
  if (trend == null) return null;
  return MetricTrendModel.fromEntity(trend).toJson();
}

List<MetricDataPoint> _dataPointsFromJson(List<dynamic> json) {
  return json
      .map(
        (e) =>
            MetricDataPointModel.fromJson(e as Map<String, dynamic>).toEntity(),
      )
      .toList();
}

List<Map<String, dynamic>> _dataPointsToJson(List<MetricDataPoint> dataPoints) {
  return dataPoints
      .map((e) => MetricDataPointModel.fromEntity(e).toJson())
      .toList();
}
