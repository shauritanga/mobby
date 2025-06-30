import 'package:equatable/equatable.dart';

enum ReportType {
  sales,
  users,
  products,
  orders,
  insurance,
  vehicles,
  financial,
  performance,
  engagement,
  custom
}

enum ReportFormat {
  pdf,
  excel,
  csv,
  json
}

enum ReportStatus {
  pending,
  generating,
  completed,
  failed,
  expired
}

enum ReportFrequency {
  onDemand,
  daily,
  weekly,
  monthly,
  quarterly,
  yearly
}

class ReportFilter extends Equatable {
  final String key;
  final String operator;
  final dynamic value;
  final String? displayName;

  const ReportFilter({
    required this.key,
    required this.operator,
    required this.value,
    this.displayName,
  });

  @override
  List<Object?> get props => [key, operator, value, displayName];
}

class ReportSection extends Equatable {
  final String id;
  final String title;
  final String? description;
  final Map<String, dynamic> data;
  final List<String> charts;
  final int order;

  const ReportSection({
    required this.id,
    required this.title,
    this.description,
    required this.data,
    required this.charts,
    required this.order,
  });

  @override
  List<Object?> get props => [id, title, description, data, charts, order];
}

class ReportSchedule extends Equatable {
  final String id;
  final ReportFrequency frequency;
  final DateTime nextRun;
  final List<String> recipients;
  final bool isActive;
  final Map<String, dynamic> settings;

  const ReportSchedule({
    required this.id,
    required this.frequency,
    required this.nextRun,
    required this.recipients,
    this.isActive = true,
    required this.settings,
  });

  @override
  List<Object?> get props => [
        id,
        frequency,
        nextRun,
        recipients,
        isActive,
        settings,
      ];
}

class Report extends Equatable {
  final String id;
  final String name;
  final String description;
  final ReportType type;
  final ReportFormat format;
  final ReportStatus status;
  final String? templateId;
  final DateTime startDate;
  final DateTime endDate;
  final List<ReportFilter> filters;
  final List<ReportSection> sections;
  final Map<String, dynamic> parameters;
  final String? fileUrl;
  final int? fileSizeBytes;
  final String? generatedBy;
  final String? generatedByName;
  final ReportSchedule? schedule;
  final DateTime? generatedAt;
  final DateTime? expiresAt;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Report({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.format,
    required this.status,
    this.templateId,
    required this.startDate,
    required this.endDate,
    required this.filters,
    required this.sections,
    required this.parameters,
    this.fileUrl,
    this.fileSizeBytes,
    this.generatedBy,
    this.generatedByName,
    this.schedule,
    this.generatedAt,
    this.expiresAt,
    this.errorMessage,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == ReportStatus.completed;
  
  bool get isFailed => status == ReportStatus.failed;
  
  bool get isGenerating => status == ReportStatus.generating;
  
  bool get isPending => status == ReportStatus.pending;
  
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  
  bool get isDownloadable => isCompleted && !isExpired && fileUrl != null;
  
  bool get isScheduled => schedule != null;

  String get formattedFileSize {
    if (fileSizeBytes == null) return '';
    
    final bytes = fileSizeBytes!;
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes bytes';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.generating:
        return 'Generating';
      case ReportStatus.completed:
        return 'Completed';
      case ReportStatus.failed:
        return 'Failed';
      case ReportStatus.expired:
        return 'Expired';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case ReportType.sales:
        return 'Sales Report';
      case ReportType.users:
        return 'Users Report';
      case ReportType.products:
        return 'Products Report';
      case ReportType.orders:
        return 'Orders Report';
      case ReportType.insurance:
        return 'Insurance Report';
      case ReportType.vehicles:
        return 'Vehicles Report';
      case ReportType.financial:
        return 'Financial Report';
      case ReportType.performance:
        return 'Performance Report';
      case ReportType.engagement:
        return 'Engagement Report';
      case ReportType.custom:
        return 'Custom Report';
    }
  }

  Duration get generationTime {
    if (generatedAt == null) return Duration.zero;
    return generatedAt!.difference(createdAt);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        format,
        status,
        templateId,
        startDate,
        endDate,
        filters,
        sections,
        parameters,
        fileUrl,
        fileSizeBytes,
        generatedBy,
        generatedByName,
        schedule,
        generatedAt,
        expiresAt,
        errorMessage,
        metadata,
        createdAt,
        updatedAt,
      ];
}
