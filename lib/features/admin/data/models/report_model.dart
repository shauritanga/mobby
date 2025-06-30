import '../../domain/entities/report.dart';

class ReportFilterModel extends ReportFilter {
  const ReportFilterModel({
    required super.key,
    required super.operator,
    required super.value,
    super.displayName,
  });

  factory ReportFilterModel.fromJson(Map<String, dynamic> json) {
    return ReportFilterModel(
      key: json['key'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'operator': operator, 'value': value};
  }

  factory ReportFilterModel.fromEntity(ReportFilter filter) {
    return ReportFilterModel(
      key: filter.key,
      operator: filter.operator,
      value: filter.value,
      displayName: filter.displayName,
    );
  }

  ReportFilter toEntity() => this;
}

class ReportSectionModel extends ReportSection {
  const ReportSectionModel({
    required super.id,
    required super.title,
    super.description,
    required super.data,
    required super.charts,
    required super.order,
  });

  factory ReportSectionModel.fromJson(Map<String, dynamic> json) {
    return ReportSectionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      data: json['data'] as Map<String, dynamic>,
      charts: List<String>.from(json['charts'] as List),
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'data': data,
      'charts': charts,
      'order': order,
    };
  }

  factory ReportSectionModel.fromEntity(ReportSection section) {
    return ReportSectionModel(
      id: section.id,
      title: section.title,
      description: section.description,
      data: section.data,
      charts: section.charts,
      order: section.order,
    );
  }

  ReportSection toEntity() => this;
}

class ReportScheduleModel extends ReportSchedule {
  const ReportScheduleModel({
    required super.id,
    required super.frequency,
    required super.nextRun,
    required super.recipients,
    super.isActive = true,
    required super.settings,
  });

  factory ReportScheduleModel.fromJson(Map<String, dynamic> json) {
    return ReportScheduleModel(
      id: json['id'] as String,
      frequency: ReportFrequency.values.byName(json['frequency'] as String),
      nextRun: DateTime.parse(json['nextRun'] as String),
      recipients: List<String>.from(json['recipients'] as List),
      isActive: json['isActive'] as bool,
      settings: json['settings'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frequency': frequency.name,
      'nextRun': nextRun.toIso8601String(),
      'recipients': recipients,
      'isActive': isActive,
      'settings': settings,
    };
  }

  factory ReportScheduleModel.fromEntity(ReportSchedule schedule) {
    return ReportScheduleModel(
      id: schedule.id,
      frequency: schedule.frequency,
      nextRun: schedule.nextRun,
      recipients: schedule.recipients,
      isActive: schedule.isActive,
      settings: schedule.settings,
    );
  }

  ReportSchedule toEntity() => this;
}

class ReportModel extends Report {
  const ReportModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.format,
    required super.status,
    super.templateId,
    required super.startDate,
    required super.endDate,
    required super.filters,
    required super.sections,
    required super.parameters,
    super.fileUrl,
    super.fileSizeBytes,
    super.generatedBy,
    super.generatedByName,
    super.schedule,
    super.generatedAt,
    super.expiresAt,
    super.errorMessage,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: ReportType.values.byName(json['type'] as String),
      format: ReportFormat.values.byName(json['format'] as String),
      status: ReportStatus.values.byName(json['status'] as String),
      templateId: json['templateId'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      filters: _filtersFromJson(json['filters'] as List<dynamic>),
      sections: _sectionsFromJson(json['sections'] as List<dynamic>),
      parameters: json['parameters'] as Map<String, dynamic>,
      fileUrl: json['fileUrl'] as String?,
      fileSizeBytes: json['fileSizeBytes'] as int?,
      generatedBy: json['generatedBy'] as String?,
      generatedByName: json['generatedByName'] as String?,
      schedule: json['schedule'] != null
          ? ReportScheduleModel.fromJson(
              json['schedule'] as Map<String, dynamic>,
            )
          : null,
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'format': format.name,
      'status': status.name,
      'templateId': templateId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'filters': _filtersToJson(filters),
      'sections': _sectionsToJson(sections),
      'parameters': parameters,
      'fileUrl': fileUrl,
      'fileSizeBytes': fileSizeBytes,
      'generatedBy': generatedBy,
      'generatedByName': generatedByName,
      'schedule': schedule != null
          ? ReportScheduleModel.fromEntity(schedule!).toJson()
          : null,
      'generatedAt': generatedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReportModel.fromEntity(Report report) {
    return ReportModel(
      id: report.id,
      name: report.name,
      description: report.description,
      type: report.type,
      format: report.format,
      status: report.status,
      templateId: report.templateId,
      startDate: report.startDate,
      endDate: report.endDate,
      filters: report.filters,
      sections: report.sections,
      parameters: report.parameters,
      fileUrl: report.fileUrl,
      fileSizeBytes: report.fileSizeBytes,
      generatedBy: report.generatedBy,
      generatedByName: report.generatedByName,
      schedule: report.schedule,
      generatedAt: report.generatedAt,
      expiresAt: report.expiresAt,
      errorMessage: report.errorMessage,
      metadata: report.metadata,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt,
    );
  }

  Report toEntity() => this;
}

// Helper functions for JSON conversion
List<ReportFilter> _filtersFromJson(List<dynamic> json) {
  return json
      .map((e) => ReportFilterModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<Map<String, dynamic>> _filtersToJson(List<ReportFilter> filters) {
  return filters.map((e) => ReportFilterModel.fromEntity(e).toJson()).toList();
}

List<ReportSection> _sectionsFromJson(List<dynamic> json) {
  return json
      .map((e) => ReportSectionModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<Map<String, dynamic>> _sectionsToJson(List<ReportSection> sections) {
  return sections
      .map((e) => ReportSectionModel.fromEntity(e).toJson())
      .toList();
}
