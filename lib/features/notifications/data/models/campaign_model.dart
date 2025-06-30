import '../../domain/entities/campaign.dart';
import '../../domain/entities/notification.dart';

class CampaignTargetModel extends CampaignTarget {
  const CampaignTargetModel({
    required super.audience,
    super.userIds,
    super.filters,
    super.estimatedReach,
  });

  factory CampaignTargetModel.fromJson(Map<String, dynamic> json) {
    return CampaignTargetModel(
      audience: TargetAudience.values.byName(json['audience'] as String),
      userIds: json['userIds'] != null
          ? List<String>.from(json['userIds'] as List)
          : null,
      filters: json['filters'] as Map<String, dynamic>?,
      estimatedReach: json['estimatedReach'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audience': audience.name,
      'userIds': userIds,
      'filters': filters,
      'estimatedReach': estimatedReach,
    };
  }

  factory CampaignTargetModel.fromEntity(CampaignTarget target) {
    return CampaignTargetModel(
      audience: target.audience,
      userIds: target.userIds,
      filters: target.filters,
      estimatedReach: target.estimatedReach,
    );
  }
}

class CampaignScheduleModel extends CampaignSchedule {
  const CampaignScheduleModel({
    super.startDate,
    super.endDate,
    super.daysOfWeek,
    super.timeOfDay,
    super.timezone,
    super.frequency,
  });

  factory CampaignScheduleModel.fromJson(Map<String, dynamic> json) {
    return CampaignScheduleModel(
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      daysOfWeek: json['daysOfWeek'] != null
          ? List<String>.from(json['daysOfWeek'] as List)
          : null,
      timeOfDay: json['timeOfDay'] as String?,
      timezone: json['timezone'] as String?,
      frequency: json['frequency'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'daysOfWeek': daysOfWeek,
      'timeOfDay': timeOfDay,
      'timezone': timezone,
      'frequency': frequency,
    };
  }

  factory CampaignScheduleModel.fromEntity(CampaignSchedule schedule) {
    return CampaignScheduleModel(
      startDate: schedule.startDate,
      endDate: schedule.endDate,
      daysOfWeek: schedule.daysOfWeek,
      timeOfDay: schedule.timeOfDay,
      timezone: schedule.timezone,
      frequency: schedule.frequency,
    );
  }
}

class CampaignStatsModel extends CampaignStats {
  const CampaignStatsModel({
    required super.totalSent,
    required super.delivered,
    required super.opened,
    required super.clicked,
    required super.failed,
    required super.deliveryRate,
    required super.openRate,
    required super.clickRate,
  });

  factory CampaignStatsModel.fromJson(Map<String, dynamic> json) {
    return CampaignStatsModel(
      totalSent: json['totalSent'] as int,
      delivered: json['delivered'] as int,
      opened: json['opened'] as int,
      clicked: json['clicked'] as int,
      failed: json['failed'] as int,
      deliveryRate: (json['deliveryRate'] as num).toDouble(),
      openRate: (json['openRate'] as num).toDouble(),
      clickRate: (json['clickRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSent': totalSent,
      'delivered': delivered,
      'opened': opened,
      'clicked': clicked,
      'failed': failed,
      'deliveryRate': deliveryRate,
      'openRate': openRate,
      'clickRate': clickRate,
    };
  }

  factory CampaignStatsModel.fromEntity(CampaignStats stats) {
    return CampaignStatsModel(
      totalSent: stats.totalSent,
      delivered: stats.delivered,
      opened: stats.opened,
      clicked: stats.clicked,
      failed: stats.failed,
      deliveryRate: stats.deliveryRate,
      openRate: stats.openRate,
      clickRate: stats.clickRate,
    );
  }
}

class CampaignModel extends Campaign {
  const CampaignModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.status,
    required super.templateId,
    required super.target,
    required super.schedule,
    required super.channels,
    super.content,
    super.stats,
    required super.createdBy,
    super.lastModifiedBy,
    required super.createdAt,
    required super.updatedAt,
    super.launchedAt,
    super.completedAt,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: CampaignType.values.byName(json['type'] as String),
      status: CampaignStatus.values.byName(json['status'] as String),
      templateId: json['templateId'] as String,
      target: CampaignTargetModel.fromJson(json['target'] as Map<String, dynamic>),
      schedule: CampaignScheduleModel.fromJson(json['schedule'] as Map<String, dynamic>),
      channels: (json['channels'] as List)
          .map((e) => NotificationChannel.values.byName(e as String))
          .toList(),
      content: json['content'] as Map<String, dynamic>?,
      stats: json['stats'] != null
          ? CampaignStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      createdBy: json['createdBy'] as String,
      lastModifiedBy: json['lastModifiedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      launchedAt: json['launchedAt'] != null
          ? DateTime.parse(json['launchedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'templateId': templateId,
      'target': CampaignTargetModel.fromEntity(target).toJson(),
      'schedule': CampaignScheduleModel.fromEntity(schedule).toJson(),
      'channels': channels.map((e) => e.name).toList(),
      'content': content,
      'stats': stats != null ? CampaignStatsModel.fromEntity(stats!).toJson() : null,
      'createdBy': createdBy,
      'lastModifiedBy': lastModifiedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'launchedAt': launchedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory CampaignModel.fromEntity(Campaign campaign) {
    return CampaignModel(
      id: campaign.id,
      name: campaign.name,
      description: campaign.description,
      type: campaign.type,
      status: campaign.status,
      templateId: campaign.templateId,
      target: campaign.target,
      schedule: campaign.schedule,
      channels: campaign.channels,
      content: campaign.content,
      stats: campaign.stats,
      createdBy: campaign.createdBy,
      lastModifiedBy: campaign.lastModifiedBy,
      createdAt: campaign.createdAt,
      updatedAt: campaign.updatedAt,
      launchedAt: campaign.launchedAt,
      completedAt: campaign.completedAt,
    );
  }

  Campaign toEntity() => this;
}
