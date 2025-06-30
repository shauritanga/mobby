// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetricDataPointModel _$MetricDataPointModelFromJson(
        Map<String, dynamic> json) =>
    MetricDataPointModel(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MetricDataPointModelToJson(
        MetricDataPointModel instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'value': instance.value,
      'metadata': instance.metadata,
    };

MetricTrendModel _$MetricTrendModelFromJson(Map<String, dynamic> json) =>
    MetricTrendModel(
      direction: $enumDecode(_$TrendDirectionEnumMap, json['direction']),
      percentage: (json['percentage'] as num).toDouble(),
      period: json['period'] as String,
      previousValue: (json['previousValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
    );

Map<String, dynamic> _$MetricTrendModelToJson(MetricTrendModel instance) =>
    <String, dynamic>{
      'direction': _$TrendDirectionEnumMap[instance.direction]!,
      'percentage': instance.percentage,
      'period': instance.period,
      'previousValue': instance.previousValue,
      'currentValue': instance.currentValue,
    };

const _$TrendDirectionEnumMap = {
  TrendDirection.up: 'up',
  TrendDirection.down: 'down',
  TrendDirection.stable: 'stable',
};

MetricModel _$MetricModelFromJson(Map<String, dynamic> json) => MetricModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$MetricTypeEnumMap, json['type']),
      period: $enumDecode(_$MetricPeriodEnumMap, json['period']),
      currentValue: (json['currentValue'] as num).toDouble(),
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      unit: json['unit'] as String,
      currency: json['currency'] as String?,
      trend: _trendFromJson(json['trend'] as Map<String, dynamic>?),
      dataPoints: _dataPointsFromJson(json['dataPoints'] as List),
      filters: json['filters'] as Map<String, dynamic>,
      isRealTime: json['isRealTime'] as bool? ?? false,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MetricModelToJson(MetricModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'displayName': instance.displayName,
      'description': instance.description,
      'type': _$MetricTypeEnumMap[instance.type]!,
      'period': _$MetricPeriodEnumMap[instance.period]!,
      'currentValue': instance.currentValue,
      'targetValue': instance.targetValue,
      'unit': instance.unit,
      'currency': instance.currency,
      'trend': _trendToJson(instance.trend),
      'dataPoints': _dataPointsToJson(instance.dataPoints),
      'filters': instance.filters,
      'isRealTime': instance.isRealTime,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$MetricTypeEnumMap = {
  MetricType.users: 'users',
  MetricType.orders: 'orders',
  MetricType.revenue: 'revenue',
  MetricType.products: 'products',
  MetricType.categories: 'categories',
  MetricType.insurance: 'insurance',
  MetricType.vehicles: 'vehicles',
  MetricType.performance: 'performance',
  MetricType.engagement: 'engagement',
  MetricType.conversion: 'conversion',
  MetricType.retention: 'retention',
  MetricType.satisfaction: 'satisfaction',
  MetricType.growth: 'growth',
  MetricType.traffic: 'traffic',
  MetricType.bounce: 'bounce',
  MetricType.session: 'session',
  MetricType.pageViews: 'pageViews',
  MetricType.downloads: 'downloads',
  MetricType.signups: 'signups',
  MetricType.churn: 'churn',
  MetricType.ltv: 'ltv',
  MetricType.cac: 'cac',
  MetricType.mrr: 'mrr',
  MetricType.arr: 'arr',
  MetricType.nps: 'nps',
  MetricType.csat: 'csat',
  MetricType.ces: 'ces',
  MetricType.other: 'other',
};

const _$MetricPeriodEnumMap = {
  MetricPeriod.realTime: 'realTime',
  MetricPeriod.hourly: 'hourly',
  MetricPeriod.daily: 'daily',
  MetricPeriod.weekly: 'weekly',
  MetricPeriod.monthly: 'monthly',
  MetricPeriod.quarterly: 'quarterly',
  MetricPeriod.yearly: 'yearly',
};
