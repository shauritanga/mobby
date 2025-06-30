import 'package:equatable/equatable.dart';
import 'notification.dart';

enum CampaignStatus {
  draft,
  scheduled,
  active,
  paused,
  completed,
  cancelled,
}

enum CampaignType {
  oneTime,
  recurring,
  triggered,
}

enum TargetAudience {
  all,
  newUsers,
  activeUsers,
  inactiveUsers,
  premiumUsers,
  custom,
}

class CampaignTarget extends Equatable {
  final TargetAudience audience;
  final List<String>? userIds;
  final Map<String, dynamic>? filters;
  final int? estimatedReach;

  const CampaignTarget({
    required this.audience,
    this.userIds,
    this.filters,
    this.estimatedReach,
  });

  @override
  List<Object?> get props => [audience, userIds, filters, estimatedReach];
}

class CampaignSchedule extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? daysOfWeek;
  final String? timeOfDay;
  final String? timezone;
  final int? frequency; // in hours for recurring campaigns

  const CampaignSchedule({
    this.startDate,
    this.endDate,
    this.daysOfWeek,
    this.timeOfDay,
    this.timezone,
    this.frequency,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        daysOfWeek,
        timeOfDay,
        timezone,
        frequency,
      ];
}

class CampaignStats extends Equatable {
  final int totalSent;
  final int delivered;
  final int opened;
  final int clicked;
  final int failed;
  final double deliveryRate;
  final double openRate;
  final double clickRate;

  const CampaignStats({
    required this.totalSent,
    required this.delivered,
    required this.opened,
    required this.clicked,
    required this.failed,
    required this.deliveryRate,
    required this.openRate,
    required this.clickRate,
  });

  @override
  List<Object?> get props => [
        totalSent,
        delivered,
        opened,
        clicked,
        failed,
        deliveryRate,
        openRate,
        clickRate,
      ];
}

class Campaign extends Equatable {
  final String id;
  final String name;
  final String description;
  final CampaignType type;
  final CampaignStatus status;
  final String templateId;
  final CampaignTarget target;
  final CampaignSchedule schedule;
  final List<NotificationChannel> channels;
  final Map<String, dynamic>? content;
  final CampaignStats? stats;
  final String createdBy;
  final String? lastModifiedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? launchedAt;
  final DateTime? completedAt;

  const Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.templateId,
    required this.target,
    required this.schedule,
    required this.channels,
    this.content,
    this.stats,
    required this.createdBy,
    this.lastModifiedBy,
    required this.createdAt,
    required this.updatedAt,
    this.launchedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        status,
        templateId,
        target,
        schedule,
        channels,
        content,
        stats,
        createdBy,
        lastModifiedBy,
        createdAt,
        updatedAt,
        launchedAt,
        completedAt,
      ];

  // Computed properties
  bool get isActive => status == CampaignStatus.active;
  bool get isDraft => status == CampaignStatus.draft;
  bool get isCompleted => status == CampaignStatus.completed;
  bool get isScheduled => status == CampaignStatus.scheduled;
  
  String get statusText {
    switch (status) {
      case CampaignStatus.draft:
        return 'Draft';
      case CampaignStatus.scheduled:
        return 'Scheduled';
      case CampaignStatus.active:
        return 'Active';
      case CampaignStatus.paused:
        return 'Paused';
      case CampaignStatus.completed:
        return 'Completed';
      case CampaignStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get typeText {
    switch (type) {
      case CampaignType.oneTime:
        return 'One-time';
      case CampaignType.recurring:
        return 'Recurring';
      case CampaignType.triggered:
        return 'Triggered';
    }
  }

  String get audienceText {
    switch (target.audience) {
      case TargetAudience.all:
        return 'All Users';
      case TargetAudience.newUsers:
        return 'New Users';
      case TargetAudience.activeUsers:
        return 'Active Users';
      case TargetAudience.inactiveUsers:
        return 'Inactive Users';
      case TargetAudience.premiumUsers:
        return 'Premium Users';
      case TargetAudience.custom:
        return 'Custom Audience';
    }
  }

  Campaign copyWith({
    String? id,
    String? name,
    String? description,
    CampaignType? type,
    CampaignStatus? status,
    String? templateId,
    CampaignTarget? target,
    CampaignSchedule? schedule,
    List<NotificationChannel>? channels,
    Map<String, dynamic>? content,
    CampaignStats? stats,
    String? createdBy,
    String? lastModifiedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? launchedAt,
    DateTime? completedAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      templateId: templateId ?? this.templateId,
      target: target ?? this.target,
      schedule: schedule ?? this.schedule,
      channels: channels ?? this.channels,
      content: content ?? this.content,
      stats: stats ?? this.stats,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      launchedAt: launchedAt ?? this.launchedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
