import '../entities/template.dart';

abstract class TemplatesRepository {
  // Template CRUD operations
  Future<List<Template>> getTemplates({
    int page = 1,
    int limit = 20,
    TemplateType? type,
    TemplateCategory? category,
    bool? isActive,
  });

  Future<Template?> getTemplate(String templateId);

  Future<Template> createTemplate(Template template);

  Future<Template> updateTemplate(Template template);

  Future<void> deleteTemplate(String templateId);

  // Template management
  Future<Template> activateTemplate(String templateId);

  Future<Template> deactivateTemplate(String templateId);

  Future<Template> setAsDefault(String templateId, TemplateType type);

  Future<Template> duplicateTemplate(String templateId, String newName);

  // Template validation
  Future<bool> validateTemplate(Template template);

  Future<Map<String, dynamic>> previewTemplate(
    String templateId,
    Map<String, dynamic> data,
  );

  Future<String> renderTemplate(
    String templateId,
    Map<String, dynamic> data,
  );

  // Template categories and types
  Future<List<Template>> getTemplatesByType(TemplateType type);

  Future<List<Template>> getTemplatesByCategory(TemplateCategory category);

  Future<List<Template>> getDefaultTemplates();

  Future<List<Template>> getActiveTemplates();

  // Template usage tracking
  Future<void> incrementUsageCount(String templateId);

  Future<Map<String, int>> getTemplateUsageStats(String templateId);

  Future<List<Map<String, dynamic>>> getPopularTemplates({
    int limit = 10,
  });

  // Template variables
  Future<List<String>> getAvailableVariables(TemplateType type);

  Future<Map<String, String>> getVariableDescriptions(TemplateType type);

  // Search and filter
  Future<List<Template>> searchTemplates(
    String query, {
    int page = 1,
    int limit = 20,
  });

  Future<List<Template>> getTemplatesByCreator(
    String creatorId, {
    int page = 1,
    int limit = 20,
  });

  // Template import/export
  Future<Template> importTemplate(Map<String, dynamic> templateData);

  Future<Map<String, dynamic>> exportTemplate(String templateId);

  Future<List<Template>> importTemplatesFromFile(String filePath);

  Future<void> exportTemplatesToFile(
    List<String> templateIds,
    String filePath,
  );

  // Real-time updates
  Stream<Template> watchTemplate(String templateId);

  Stream<List<Template>> watchTemplates();
}
