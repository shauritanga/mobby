import 'package:equatable/equatable.dart';

enum TemplateType { push, email, sms, inApp }

enum TemplateCategory { transactional, marketing, system, reminder }

class TemplateVariable extends Equatable {
  final String name;
  final String type; // string, number, date, boolean
  final String description;
  final bool required;
  final String? defaultValue;

  const TemplateVariable({
    required this.name,
    required this.type,
    required this.description,
    required this.required,
    this.defaultValue,
  });

  @override
  List<Object?> get props => [name, type, description, required, defaultValue];
}

class TemplateContent extends Equatable {
  final String? subject; // for email
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionUrl;
  final String? actionText;
  final Map<String, dynamic>? styling;

  const TemplateContent({
    this.subject,
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionUrl,
    this.actionText,
    this.styling,
  });

  @override
  List<Object?> get props => [
    subject,
    title,
    body,
    imageUrl,
    actionUrl,
    actionText,
    styling,
  ];
}

class Template extends Equatable {
  final String id;
  final String name;
  final String description;
  final TemplateType type;
  final TemplateCategory category;
  final TemplateContent content;
  final List<TemplateVariable> variables;
  final bool isActive;
  final bool isDefault;
  final String? previewImageUrl;
  final Map<String, dynamic>? metadata;
  final String createdBy;
  final String? lastModifiedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int usageCount;

  const Template({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.content,
    required this.variables,
    required this.isActive,
    required this.isDefault,
    this.previewImageUrl,
    this.metadata,
    required this.createdBy,
    this.lastModifiedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.usageCount,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    category,
    content,
    variables,
    isActive,
    isDefault,
    previewImageUrl,
    metadata,
    createdBy,
    lastModifiedBy,
    createdAt,
    updatedAt,
    usageCount,
  ];

  // Computed properties
  String get typeText {
    switch (type) {
      case TemplateType.push:
        return 'Push Notification';
      case TemplateType.email:
        return 'Email';
      case TemplateType.sms:
        return 'SMS';
      case TemplateType.inApp:
        return 'In-App';
    }
  }

  String get categoryText {
    switch (category) {
      case TemplateCategory.transactional:
        return 'Transactional';
      case TemplateCategory.marketing:
        return 'Marketing';
      case TemplateCategory.system:
        return 'System';
      case TemplateCategory.reminder:
        return 'Reminder';
    }
  }

  List<String> get requiredVariables {
    return variables.where((v) => v.required).map((v) => v.name).toList();
  }

  List<String> get optionalVariables {
    return variables.where((v) => !v.required).map((v) => v.name).toList();
  }

  bool get hasVariables => variables.isNotEmpty;

  String renderContent(Map<String, dynamic> data) {
    String renderedTitle = content.title;
    String renderedBody = content.body;

    // Replace variables in title and body
    for (final variable in variables) {
      final value =
          data[variable.name]?.toString() ?? variable.defaultValue ?? '';
      renderedTitle = renderedTitle.replaceAll('{{${variable.name}}}', value);
      renderedBody = renderedBody.replaceAll('{{${variable.name}}}', value);
    }

    return '$renderedTitle\n$renderedBody';
  }

  Template copyWith({
    String? id,
    String? name,
    String? description,
    TemplateType? type,
    TemplateCategory? category,
    TemplateContent? content,
    List<TemplateVariable>? variables,
    bool? isActive,
    bool? isDefault,
    String? previewImageUrl,
    Map<String, dynamic>? metadata,
    String? createdBy,
    String? lastModifiedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? usageCount,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      content: content ?? this.content,
      variables: variables ?? this.variables,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      metadata: metadata ?? this.metadata,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
