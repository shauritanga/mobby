import '../../domain/entities/template.dart';

class TemplateVariableModel extends TemplateVariable {
  const TemplateVariableModel({
    required super.name,
    required super.type,
    required super.description,
    required super.required,
    super.defaultValue,
  });

  factory TemplateVariableModel.fromJson(Map<String, dynamic> json) {
    return TemplateVariableModel(
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      required: json['required'] as bool,
      defaultValue: json['defaultValue'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'required': required,
      'defaultValue': defaultValue,
    };
  }

  factory TemplateVariableModel.fromEntity(TemplateVariable variable) {
    return TemplateVariableModel(
      name: variable.name,
      type: variable.type,
      description: variable.description,
      required: variable.required,
      defaultValue: variable.defaultValue,
    );
  }
}

class TemplateContentModel extends TemplateContent {
  const TemplateContentModel({
    super.subject,
    required super.title,
    required super.body,
    super.imageUrl,
    super.actionUrl,
    super.actionText,
    super.styling,
  });

  factory TemplateContentModel.fromJson(Map<String, dynamic> json) {
    return TemplateContentModel(
      subject: json['subject'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      actionText: json['actionText'] as String?,
      styling: json['styling'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'styling': styling,
    };
  }

  factory TemplateContentModel.fromEntity(TemplateContent content) {
    return TemplateContentModel(
      subject: content.subject,
      title: content.title,
      body: content.body,
      imageUrl: content.imageUrl,
      actionUrl: content.actionUrl,
      actionText: content.actionText,
      styling: content.styling,
    );
  }
}

class TemplateModel extends Template {
  const TemplateModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.category,
    required super.content,
    required super.variables,
    required super.isActive,
    required super.isDefault,
    super.previewImageUrl,
    super.metadata,
    required super.createdBy,
    super.lastModifiedBy,
    required super.createdAt,
    required super.updatedAt,
    required super.usageCount,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: TemplateType.values.byName(json['type'] as String),
      category: TemplateCategory.values.byName(json['category'] as String),
      content: TemplateContentModel.fromJson(
        json['content'] as Map<String, dynamic>,
      ),
      variables: (json['variables'] as List)
          .map((e) => TemplateVariableModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool,
      isDefault: json['isDefault'] as bool,
      previewImageUrl: json['previewImageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdBy: json['createdBy'] as String,
      lastModifiedBy: json['lastModifiedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      usageCount: json['usageCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'category': category.name,
      'content': TemplateContentModel.fromEntity(content).toJson(),
      'variables': variables
          .map((e) => TemplateVariableModel.fromEntity(e).toJson())
          .toList(),
      'isActive': isActive,
      'isDefault': isDefault,
      'previewImageUrl': previewImageUrl,
      'metadata': metadata,
      'createdBy': createdBy,
      'lastModifiedBy': lastModifiedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  factory TemplateModel.fromEntity(Template template) {
    return TemplateModel(
      id: template.id,
      name: template.name,
      description: template.description,
      type: template.type,
      category: template.category,
      content: template.content,
      variables: template.variables,
      isActive: template.isActive,
      isDefault: template.isDefault,
      previewImageUrl: template.previewImageUrl,
      metadata: template.metadata,
      createdBy: template.createdBy,
      lastModifiedBy: template.lastModifiedBy,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
      usageCount: template.usageCount,
    );
  }

  Template toEntity() => this;

  @override
  TemplateModel copyWith({
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
    return TemplateModel(
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
