import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/template.dart';
import '../../domain/usecases/manage_templates.dart';

// State classes
class TemplatesState {
  final List<Template> templates;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const TemplatesState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  TemplatesState copyWith({
    List<Template>? templates,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return TemplatesState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class TemplateFilters {
  final TemplateType? type;
  final TemplateCategory? category;
  final bool? isActive;
  final String? searchQuery;

  const TemplateFilters({
    this.type,
    this.category,
    this.isActive,
    this.searchQuery,
  });

  TemplateFilters copyWith({
    TemplateType? type,
    TemplateCategory? category,
    bool? isActive,
    String? searchQuery,
  }) {
    return TemplateFilters(
      type: type ?? this.type,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Templates Provider
class TemplatesNotifier extends StateNotifier<TemplatesState> {
  final GetTemplates _getTemplates;
  final CreateTemplate _createTemplate;
  final UpdateTemplate _updateTemplate;
  final DeleteTemplate _deleteTemplate;
  final ValidateTemplate _validateTemplate;
  final PreviewTemplate _previewTemplate;
  final DuplicateTemplate _duplicateTemplate;
  final GetTemplatesByType _getTemplatesByType;

  TemplatesNotifier({
    required GetTemplates getTemplates,
    required CreateTemplate createTemplate,
    required UpdateTemplate updateTemplate,
    required DeleteTemplate deleteTemplate,
    required ValidateTemplate validateTemplate,
    required PreviewTemplate previewTemplate,
    required DuplicateTemplate duplicateTemplate,
    required GetTemplatesByType getTemplatesByType,
  })  : _getTemplates = getTemplates,
        _createTemplate = createTemplate,
        _updateTemplate = updateTemplate,
        _deleteTemplate = deleteTemplate,
        _validateTemplate = validateTemplate,
        _previewTemplate = previewTemplate,
        _duplicateTemplate = duplicateTemplate,
        _getTemplatesByType = getTemplatesByType,
        super(const TemplatesState());

  TemplateFilters _filters = const TemplateFilters();

  Future<void> loadTemplates({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        templates: [],
        currentPage: 1,
        hasMore: true,
        error: null,
      );
    }

    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _getTemplates(GetTemplatesParams(
        page: state.currentPage,
        limit: 20,
        type: _filters.type,
        category: _filters.category,
        isActive: _filters.isActive,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (templates) {
          final allTemplates = state.currentPage == 1
              ? templates
              : [...state.templates, ...templates];

          state = state.copyWith(
            templates: allTemplates,
            isLoading: false,
            hasMore: templates.length == 20,
            currentPage: state.currentPage + 1,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createTemplate({
    required String name,
    required String description,
    required TemplateType type,
    required TemplateCategory category,
    required TemplateContent content,
    required List<TemplateVariable> variables,
    bool isActive = true,
    bool isDefault = false,
    String? previewImageUrl,
    Map<String, dynamic>? metadata,
    required String createdBy,
  }) async {
    try {
      final result = await _createTemplate(CreateTemplateParams(
        name: name,
        description: description,
        type: type,
        category: category,
        content: content,
        variables: variables,
        isActive: isActive,
        isDefault: isDefault,
        previewImageUrl: previewImageUrl,
        metadata: metadata,
        createdBy: createdBy,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (template) {
          // Add to local state
          final updatedTemplates = [template, ...state.templates];
          state = state.copyWith(
            templates: updatedTemplates,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateTemplate(Template template) async {
    try {
      final result = await _updateTemplate(UpdateTemplateParams(
        template: template,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (updatedTemplate) {
          // Update in local state
          final updatedTemplates = state.templates.map((t) {
            return t.id == updatedTemplate.id ? updatedTemplate : t;
          }).toList();

          state = state.copyWith(
            templates: updatedTemplates,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      final result = await _deleteTemplate(DeleteTemplateParams(
        templateId: templateId,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (_) {
          // Remove from local state
          final updatedTemplates = state.templates
              .where((template) => template.id != templateId)
              .toList();

          state = state.copyWith(
            templates: updatedTemplates,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> validateTemplate(Template template) async {
    try {
      final result = await _validateTemplate(ValidateTemplateParams(
        template: template,
      ));

      return result.fold(
        (failure) => false,
        (isValid) => isValid,
      );
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> previewTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _previewTemplate(PreviewTemplateParams(
        templateId: templateId,
        data: data,
      ));

      return result.fold(
        (failure) => null,
        (preview) => preview,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> duplicateTemplate(String templateId, String newName) async {
    try {
      final result = await _duplicateTemplate(DuplicateTemplateParams(
        templateId: templateId,
        newName: newName,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (duplicatedTemplate) {
          // Add to local state
          final updatedTemplates = [duplicatedTemplate, ...state.templates];
          state = state.copyWith(
            templates: updatedTemplates,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<List<Template>> getTemplatesByType(TemplateType type) async {
    try {
      final result = await _getTemplatesByType(GetTemplatesByTypeParams(
        type: type,
      ));

      return result.fold(
        (failure) => [],
        (templates) => templates,
      );
    } catch (e) {
      return [];
    }
  }

  void updateFilters(TemplateFilters filters) {
    _filters = filters;
    loadTemplates(refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Template Editor State
class TemplateEditorState {
  final Template? template;
  final bool isLoading;
  final String? error;
  final bool isValid;
  final Map<String, dynamic>? preview;

  const TemplateEditorState({
    this.template,
    this.isLoading = false,
    this.error,
    this.isValid = false,
    this.preview,
  });

  TemplateEditorState copyWith({
    Template? template,
    bool? isLoading,
    String? error,
    bool? isValid,
    Map<String, dynamic>? preview,
  }) {
    return TemplateEditorState(
      template: template ?? this.template,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isValid: isValid ?? this.isValid,
      preview: preview ?? this.preview,
    );
  }
}

class TemplateEditorNotifier extends StateNotifier<TemplateEditorState> {
  final ValidateTemplate _validateTemplate;
  final PreviewTemplate _previewTemplate;

  TemplateEditorNotifier({
    required ValidateTemplate validateTemplate,
    required PreviewTemplate previewTemplate,
  })  : _validateTemplate = validateTemplate,
        _previewTemplate = previewTemplate,
        super(const TemplateEditorState());

  void setTemplate(Template template) {
    state = state.copyWith(template: template);
    _validateCurrentTemplate();
  }

  void updateTemplate(Template template) {
    state = state.copyWith(template: template);
    _validateCurrentTemplate();
  }

  Future<void> _validateCurrentTemplate() async {
    if (state.template == null) return;

    try {
      final result = await _validateTemplate(ValidateTemplateParams(
        template: state.template!,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(
            isValid: false,
            error: failure.message,
          );
        },
        (isValid) {
          state = state.copyWith(
            isValid: isValid,
            error: isValid ? null : 'Template validation failed',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isValid: false,
        error: e.toString(),
      );
    }
  }

  Future<void> previewTemplate(Map<String, dynamic> data) async {
    if (state.template == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _previewTemplate(PreviewTemplateParams(
        templateId: state.template!.id,
        data: data,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (preview) {
          state = state.copyWith(
            isLoading: false,
            preview: preview,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearPreview() {
    state = state.copyWith(preview: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
