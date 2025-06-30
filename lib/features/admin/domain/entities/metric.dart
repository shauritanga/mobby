import 'package:equatable/equatable.dart';

enum MetricType {
  users,
  orders,
  revenue,
  products,
  categories,
  insurance,
  vehicles,
  performance,
  engagement,
  conversion,
  retention,
  satisfaction,
  growth,
  traffic,
  bounce,
  session,
  pageViews,
  downloads,
  signups,
  churn,
  ltv,
  cac,
  mrr,
  arr,
  nps,
  csat,
  ces,
  other,
}

enum MetricPeriod {
  realTime,
  hourly,
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
}

enum TrendDirection { up, down, stable }

class MetricDataPoint extends Equatable {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? metadata;

  const MetricDataPoint({
    required this.timestamp,
    required this.value,
    this.metadata,
  });

  @override
  List<Object?> get props => [timestamp, value, metadata];
}

class MetricTrend extends Equatable {
  final TrendDirection direction;
  final double percentage;
  final String period;
  final double previousValue;
  final double currentValue;

  const MetricTrend({
    required this.direction,
    required this.percentage,
    required this.period,
    required this.previousValue,
    required this.currentValue,
  });

  bool get isPositive => direction == TrendDirection.up;
  bool get isNegative => direction == TrendDirection.down;
  bool get isStable => direction == TrendDirection.stable;

  @override
  List<Object?> get props => [
    direction,
    percentage,
    period,
    previousValue,
    currentValue,
  ];
}

class Metric extends Equatable {
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

  const Metric({
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

  bool get hasTarget => targetValue != null;

  bool get isTargetMet => hasTarget && currentValue >= targetValue!;

  double get targetProgress =>
      hasTarget ? (currentValue / targetValue!) * 100 : 0.0;

  // Convenience getters for widget compatibility
  double get value => currentValue;

  double? get change => trend?.percentage;

  String get formattedValue {
    if (currency != null) {
      return '$currency ${_formatNumber(currentValue)}';
    }
    return '${_formatNumber(currentValue)} $unit';
  }

  String get formattedTarget {
    if (!hasTarget) return '';
    if (currency != null) {
      return '$currency ${_formatNumber(targetValue!)}';
    }
    return '${_formatNumber(targetValue!)} $unit';
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    displayName,
    description,
    type,
    period,
    currentValue,
    targetValue,
    unit,
    currency,
    trend,
    dataPoints,
    filters,
    isRealTime,
    lastUpdated,
    createdAt,
  ];
}
