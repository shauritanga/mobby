import '../../domain/entities/template.dart';
import '../../domain/repositories/templates_repository.dart';
import '../datasources/templates_remote_datasource.dart';
import '../models/template_model.dart';

class TemplatesRepositoryImpl implements TemplatesRepository {
  final TemplatesRemoteDataSource remoteDataSource;

  TemplatesRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Template>> getTemplates({
    int page = 1,
    int limit = 20,
    TemplateType? type,
    TemplateCategory? category,
    bool? isActive,
  }) async {
    final templates = await remoteDataSource.getTemplates(
      page: page,
      limit: limit,
      type: type,
      category: category,
      isActive: isActive,
    );
    return templates.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Template?> getTemplate(String templateId) async {
    final template = await remoteDataSource.getTemplate(templateId);
    return template?.toEntity();
  }

  @override
  Future<Template> createTemplate(Template template) async {
    final templateModel = TemplateModel.fromEntity(template);
    final createdModel = await remoteDataSource.createTemplate(templateModel);
    return createdModel.toEntity();
  }

  @override
  Future<Template> updateTemplate(Template template) async {
    final templateModel = TemplateModel.fromEntity(template);
    final updatedModel = await remoteDataSource.updateTemplate(templateModel);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    await remoteDataSource.deleteTemplate(templateId);
  }

  @override
  Future<Template> activateTemplate(String templateId) async {
    final template = await remoteDataSource.activateTemplate(templateId);
    return template.toEntity();
  }

  @override
  Future<Template> deactivateTemplate(String templateId) async {
    final template = await remoteDataSource.deactivateTemplate(templateId);
    return template.toEntity();
  }

  @override
  Future<Template> setAsDefault(String templateId, TemplateType type) async {
    final template = await remoteDataSource.setAsDefault(templateId, type);
    return template.toEntity();
  }

  @override
  Future<Template> duplicateTemplate(String templateId, String newName) async {
    final template = await remoteDataSource.duplicateTemplate(templateId, newName);
    return template.toEntity();
  }

  @override
  Future<bool> validateTemplate(Template template) async {
    final templateModel = TemplateModel.fromEntity(template);
    return await remoteDataSource.validateTemplate(templateModel);
  }

  @override
  Future<Map<String, dynamic>> previewTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    return await remoteDataSource.previewTemplate(templateId, data);
  }

  @override
  Future<String> renderTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    return await remoteDataSource.renderTemplate(templateId, data);
  }

  @override
  Future<List<Template>> getTemplatesByType(TemplateType type) async {
    final templates = await remoteDataSource.getTemplatesByType(type);
    return templates.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Template>> getTemplatesByCategory(TemplateCategory category) async {
    final templates = await remoteDataSource.getTemplatesByCategory(category);
    return templates.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Template>> getDefaultTemplates() async {
    final templates = await remoteDataSource.getDefaultTemplates();
    return templates.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Template>> getActiveTemplates() async {
    final templates = await remoteDataSource.getActiveTemplates();
    return templates.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> incrementUsageCount(String templateId) async {
    await remoteDataSource.incrementUsageCount(templateId);
  }

  @override
  Future<Map<String, int>> getTemplateUsageStats(String templateId) async {
    return await remoteDataSource.getTemplateUsageStats(templateId);
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularTemplates({
    int limit = 10,
  }) async {
    return await remoteDataSource.getPopularTemplates(limit: limit);
  }

  @override
  Future<List<String>> getAvailableVariables(TemplateType type) async {
    // Define available variables based on template type
    switch (type) {
      case TemplateType.push:
        return [
          'userName',
          'appName',
          'orderNumber',
          'productName',
          'amount',
          'currency',
          'date',
          'time',
        ];
      case TemplateType.email:
        return [
          'userName',
          'userEmail',
          'firstName',
          'lastName',
          'companyName',
          'orderNumber',
          'productName',
          'amount',
          'currency',
          'date',
          'time',
          'supportEmail',
          'unsubscribeUrl',
        ];
      case TemplateType.sms:
        return [
          'userName',
          'firstName',
          'orderNumber',
          'amount',
          'currency',
          'code',
          'link',
        ];
      case TemplateType.inApp:
        return [
          'userName',
          'firstName',
          'orderNumber',
          'productName',
          'amount',
          'currency',
          'date',
          'time',
          'actionUrl',
        ];
    }
  }

  @override
  Future<Map<String, String>> getVariableDescriptions(TemplateType type) async {
    // Define variable descriptions based on template type
    const commonDescriptions = {
      'userName': 'The user\'s display name',
      'firstName': 'The user\'s first name',
      'lastName': 'The user\'s last name',
      'userEmail': 'The user\'s email address',
      'orderNumber': 'The order reference number',
      'productName': 'The name of the product',
      'amount': 'The monetary amount',
      'currency': 'The currency code (e.g., TZS)',
      'date': 'The current date',
      'time': 'The current time',
    };

    switch (type) {
      case TemplateType.push:
        return {
          ...commonDescriptions,
          'appName': 'The name of the application',
        };
      case TemplateType.email:
        return {
          ...commonDescriptions,
          'companyName': 'The company name',
          'supportEmail': 'The support email address',
          'unsubscribeUrl': 'The unsubscribe URL',
        };
      case TemplateType.sms:
        return {
          ...commonDescriptions,
          'code': 'A verification or reference code',
          'link': 'A short URL link',
        };
      case TemplateType.inApp:
        return {
          ...commonDescriptions,
          'actionUrl': 'The URL for the call-to-action',
        };
    }
  }

  @override
  Future<List<Template>> searchTemplates(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    // This would require implementing search in the data source
    // For now, we'll get all templates and filter locally
    final templates = await remoteDataSource.getTemplates(
      page: page,
      limit: limit * 2, // Get more to account for filtering
    );
    
    final filtered = templates
        .where((template) =>
            template.name.toLowerCase().contains(query.toLowerCase()) ||
            template.description.toLowerCase().contains(query.toLowerCase()) ||
            template.content.title.toLowerCase().contains(query.toLowerCase()))
        .take(limit)
        .toList();
    
    return filtered.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Template>> getTemplatesByCreator(
    String creatorId, {
    int page = 1,
    int limit = 20,
  }) async {
    // This would require implementing creator filtering in the data source
    // For now, we'll get all templates and filter locally
    final templates = await remoteDataSource.getTemplates(
      page: page,
      limit: limit * 2, // Get more to account for filtering
    );
    
    final filtered = templates
        .where((template) => template.createdBy == creatorId)
        .take(limit)
        .toList();
    
    return filtered.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Template> importTemplate(Map<String, dynamic> templateData) async {
    try {
      final template = TemplateModel.fromJson(templateData);
      
      // Reset some fields for import
      final importedTemplate = template.copyWith(
        id: '', // Will be generated
        usageCount: 0,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final createdModel = await remoteDataSource.createTemplate(importedTemplate);
      return createdModel.toEntity();
    } catch (e) {
      throw Exception('Failed to import template: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportTemplate(String templateId) async {
    final template = await remoteDataSource.getTemplate(templateId);
    if (template == null) {
      throw Exception('Template not found');
    }
    
    return template.toJson();
  }

  @override
  Future<List<Template>> importTemplatesFromFile(String filePath) async {
    // This would require file system access and JSON parsing
    // For now, we'll throw an unimplemented error
    throw UnimplementedError('File import not implemented yet');
  }

  @override
  Future<void> exportTemplatesToFile(
    List<String> templateIds,
    String filePath,
  ) async {
    // This would require file system access and JSON serialization
    // For now, we'll throw an unimplemented error
    throw UnimplementedError('File export not implemented yet');
  }

  @override
  Stream<Template> watchTemplate(String templateId) {
    // This would require implementing real-time listeners
    throw UnimplementedError('Real-time template watching not implemented yet');
  }

  @override
  Stream<List<Template>> watchTemplates() {
    // This would require implementing real-time listeners
    throw UnimplementedError('Real-time templates watching not implemented yet');
  }
}
