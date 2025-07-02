import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/template_model.dart';
import '../../domain/entities/template.dart';

abstract class TemplatesRemoteDataSource {
  Stream<TemplateModel> watchTemplate(String templateId);
  Stream<List<TemplateModel>> watchTemplates();
  Future<List<TemplateModel>> getTemplates({
    int page = 1,
    int limit = 20,
    TemplateType? type,
    TemplateCategory? category,
    bool? isActive,
  });

  Future<TemplateModel?> getTemplate(String templateId);
  Future<TemplateModel> createTemplate(TemplateModel template);
  Future<TemplateModel> updateTemplate(TemplateModel template);
  Future<void> deleteTemplate(String templateId);
  Future<TemplateModel> activateTemplate(String templateId);
  Future<TemplateModel> deactivateTemplate(String templateId);
  Future<TemplateModel> setAsDefault(String templateId, TemplateType type);
  Future<TemplateModel> duplicateTemplate(String templateId, String newName);
  Future<bool> validateTemplate(TemplateModel template);
  Future<Map<String, dynamic>> previewTemplate(
    String templateId,
    Map<String, dynamic> data,
  );
  Future<String> renderTemplate(String templateId, Map<String, dynamic> data);
  Future<List<TemplateModel>> getTemplatesByType(TemplateType type);
  Future<List<TemplateModel>> getTemplatesByCategory(TemplateCategory category);
  Future<List<TemplateModel>> getDefaultTemplates();
  Future<List<TemplateModel>> getActiveTemplates();
  Future<void> incrementUsageCount(String templateId);
  Future<Map<String, int>> getTemplateUsageStats(String templateId);
  Future<List<Map<String, dynamic>>> getPopularTemplates({int limit = 10});
}

class TemplatesRemoteDataSourceImpl implements TemplatesRemoteDataSource {
  final FirebaseFirestore _firestore;

  TemplatesRemoteDataSourceImpl(this._firestore);

  @override
  Stream<TemplateModel> watchTemplate(String templateId) {
    return _firestore
        .collection('templates')
        .doc(templateId)
        .snapshots()
        .map((doc) => TemplateModel.fromJson({'id': doc.id, ...doc.data()!}));
  }

  @override
  Stream<List<TemplateModel>> watchTemplates() {
    return _firestore
        .collection('templates')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TemplateModel.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  @override
  Future<List<TemplateModel>> getTemplates({
    int page = 1,
    int limit = 20,
    TemplateType? type,
    TemplateCategory? category,
    bool? isActive,
  }) async {
    try {
      Query query = _firestore
          .collection('templates')
          .orderBy('createdAt', descending: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      final querySnapshot = await query.limit(limit).get();

      final templates = querySnapshot.docs
          .map(
            (doc) => TemplateModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      return templates;
    } catch (e) {
      throw Exception('Failed to fetch templates: $e');
    }
  }

  @override
  Future<TemplateModel?> getTemplate(String templateId) async {
    try {
      final doc = await _firestore
          .collection('templates')
          .doc(templateId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return TemplateModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch template: $e');
    }
  }

  @override
  Future<TemplateModel> createTemplate(TemplateModel template) async {
    try {
      final templateData = template.toJson();
      templateData.remove('id');

      final docRef = await _firestore.collection('templates').add(templateData);

      final createdTemplate = template.copyWith(id: docRef.id);
      return createdTemplate;
    } catch (e) {
      throw Exception('Failed to create template: $e');
    }
  }

  @override
  Future<TemplateModel> updateTemplate(TemplateModel template) async {
    try {
      await _firestore
          .collection('templates')
          .doc(template.id)
          .update(template.toJson());

      return template;
    } catch (e) {
      throw Exception('Failed to update template: $e');
    }
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _firestore.collection('templates').doc(templateId).delete();
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }

  @override
  Future<TemplateModel> activateTemplate(String templateId) async {
    try {
      await _firestore.collection('templates').doc(templateId).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedTemplate = await getTemplate(templateId);
      return updatedTemplate!;
    } catch (e) {
      throw Exception('Failed to activate template: $e');
    }
  }

  @override
  Future<TemplateModel> deactivateTemplate(String templateId) async {
    try {
      await _firestore.collection('templates').doc(templateId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedTemplate = await getTemplate(templateId);
      return updatedTemplate!;
    } catch (e) {
      throw Exception('Failed to deactivate template: $e');
    }
  }

  @override
  Future<TemplateModel> setAsDefault(
    String templateId,
    TemplateType type,
  ) async {
    try {
      final batch = _firestore.batch();

      // First, remove default status from all templates of this type
      final existingDefaults = await _firestore
          .collection('templates')
          .where('type', isEqualTo: type.name)
          .where('isDefault', isEqualTo: true)
          .get();

      for (final doc in existingDefaults.docs) {
        batch.update(doc.reference, {
          'isDefault': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Set the new template as default
      final templateRef = _firestore.collection('templates').doc(templateId);
      batch.update(templateRef, {
        'isDefault': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      final updatedTemplate = await getTemplate(templateId);
      return updatedTemplate!;
    } catch (e) {
      throw Exception('Failed to set template as default: $e');
    }
  }

  @override
  Future<TemplateModel> duplicateTemplate(
    String templateId,
    String newName,
  ) async {
    try {
      final originalTemplate = await getTemplate(templateId);
      if (originalTemplate == null) {
        throw Exception('Template not found');
      }

      final duplicatedTemplate = originalTemplate.copyWith(
        id: '', // Will be generated
        name: newName,
        isDefault: false,
        usageCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createTemplate(duplicatedTemplate);
    } catch (e) {
      throw Exception('Failed to duplicate template: $e');
    }
  }

  @override
  Future<bool> validateTemplate(TemplateModel template) async {
    try {
      // Basic validation rules
      if (template.name.trim().isEmpty) {
        return false;
      }

      if (template.content.title.trim().isEmpty) {
        return false;
      }

      if (template.content.body.trim().isEmpty) {
        return false;
      }

      // Validate variables in content
      final titleVariables = _extractVariables(template.content.title);
      final bodyVariables = _extractVariables(template.content.body);
      final allContentVariables = {...titleVariables, ...bodyVariables};

      final definedVariables = template.variables.map((v) => v.name).toSet();

      // Check if all variables used in content are defined
      for (final variable in allContentVariables) {
        if (!definedVariables.contains(variable)) {
          return false;
        }
      }

      // Type-specific validation
      switch (template.type) {
        case TemplateType.email:
          if (template.content.subject == null ||
              template.content.subject!.trim().isEmpty) {
            return false;
          }
          break;
        case TemplateType.sms:
          // SMS should be short
          if (template.content.body.length > 160) {
            return false;
          }
          break;
        case TemplateType.push:
          // Push notifications should have concise titles
          if (template.content.title.length > 50) {
            return false;
          }
          break;
        case TemplateType.inApp:
          // In-app notifications can be longer
          break;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> previewTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    try {
      final template = await getTemplate(templateId);
      if (template == null) {
        throw Exception('Template not found');
      }

      final renderedContent = _renderTemplateContent(template, data);

      return {
        'id': template.id,
        'name': template.name,
        'type': template.type.name,
        'category': template.category.name,
        'content': renderedContent,
        'previewImageUrl': template.previewImageUrl,
      };
    } catch (e) {
      throw Exception('Failed to preview template: $e');
    }
  }

  @override
  Future<String> renderTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    try {
      final template = await getTemplate(templateId);
      if (template == null) {
        throw Exception('Template not found');
      }

      return template.renderContent(data);
    } catch (e) {
      throw Exception('Failed to render template: $e');
    }
  }

  @override
  Future<List<TemplateModel>> getTemplatesByType(TemplateType type) async {
    try {
      final querySnapshot = await _firestore
          .collection('templates')
          .where('type', isEqualTo: type.name)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => TemplateModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get templates by type: $e');
    }
  }

  @override
  Future<List<TemplateModel>> getTemplatesByCategory(
    TemplateCategory category,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('templates')
          .where('category', isEqualTo: category.name)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => TemplateModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get templates by category: $e');
    }
  }

  @override
  Future<List<TemplateModel>> getDefaultTemplates() async {
    try {
      final querySnapshot = await _firestore
          .collection('templates')
          .where('isDefault', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TemplateModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get default templates: $e');
    }
  }

  @override
  Future<List<TemplateModel>> getActiveTemplates() async {
    try {
      final querySnapshot = await _firestore
          .collection('templates')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => TemplateModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active templates: $e');
    }
  }

  @override
  Future<void> incrementUsageCount(String templateId) async {
    try {
      await _firestore.collection('templates').doc(templateId).update({
        'usageCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to increment usage count: $e');
    }
  }

  @override
  Future<Map<String, int>> getTemplateUsageStats(String templateId) async {
    try {
      // Get usage from notifications that used this template
      final notificationsQuery = await _firestore
          .collection('notifications')
          .where('templateId', isEqualTo: templateId)
          .get();

      final campaignsQuery = await _firestore
          .collection('campaigns')
          .where('templateId', isEqualTo: templateId)
          .get();

      return {
        'totalNotifications': notificationsQuery.docs.length,
        'totalCampaigns': campaignsQuery.docs.length,
        'totalUsage':
            notificationsQuery.docs.length + campaignsQuery.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to get template usage stats: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularTemplates({
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('templates')
          .where('isActive', isEqualTo: true)
          .orderBy('usageCount', descending: true)
          .limit(limit)
          .get();

      final popularTemplates = <Map<String, dynamic>>[];

      for (final doc in querySnapshot.docs) {
        final template = TemplateModel.fromJson({'id': doc.id, ...doc.data()});

        final usageStats = await getTemplateUsageStats(template.id);

        popularTemplates.add({
          'template': template.toJson(),
          'usageStats': usageStats,
        });
      }

      return popularTemplates;
    } catch (e) {
      throw Exception('Failed to get popular templates: $e');
    }
  }

  // Helper methods
  Set<String> _extractVariables(String content) {
    final regex = RegExp(r'\{\{(\w+)\}\}');
    final matches = regex.allMatches(content);
    return matches.map((match) => match.group(1)!).toSet();
  }

  Map<String, dynamic> _renderTemplateContent(
    TemplateModel template,
    Map<String, dynamic> data,
  ) {
    String renderedTitle = template.content.title;
    String renderedBody = template.content.body;
    String? renderedSubject = template.content.subject;

    // Replace variables
    for (final variable in template.variables) {
      final value =
          data[variable.name]?.toString() ?? variable.defaultValue ?? '';
      renderedTitle = renderedTitle.replaceAll('{{${variable.name}}}', value);
      renderedBody = renderedBody.replaceAll('{{${variable.name}}}', value);
      if (renderedSubject != null) {
        renderedSubject = renderedSubject.replaceAll(
          '{{${variable.name}}}',
          value,
        );
      }
    }

    return {
      'subject': renderedSubject,
      'title': renderedTitle,
      'body': renderedBody,
      'imageUrl': template.content.imageUrl,
      'actionUrl': template.content.actionUrl,
      'actionText': template.content.actionText,
      'styling': template.content.styling,
    };
  }
}
