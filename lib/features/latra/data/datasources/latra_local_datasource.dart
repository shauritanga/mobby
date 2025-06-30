import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/latra_application_model.dart';
import '../models/latra_status_model.dart';
import '../models/latra_document_model.dart';

/// LATRA local data source for caching
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
abstract class LATRALocalDataSource {
  // Application caching
  Future<List<LATRAApplicationModel>> getCachedUserApplications(String userId);
  Future<LATRAApplicationModel?> getCachedApplicationById(String applicationId);
  Future<void> cacheUserApplications(String userId, List<LATRAApplicationModel> applications);
  Future<void> cacheApplication(LATRAApplicationModel application);
  Future<void> removeCachedApplication(String applicationId);

  // Status caching
  Future<List<LATRAStatusModel>> getCachedApplicationStatus(String applicationId);
  Future<LATRAStatusModel?> getCachedLatestStatus(String applicationId);
  Future<void> cacheApplicationStatus(String applicationId, List<LATRAStatusModel> statusList);
  Future<void> cacheStatus(LATRAStatusModel status);

  // Document caching
  Future<List<LATRADocumentModel>> getCachedApplicationDocuments(String applicationId);
  Future<List<LATRADocumentModel>> getCachedUserDocuments(String userId);
  Future<void> cacheApplicationDocuments(String applicationId, List<LATRADocumentModel> documents);
  Future<void> cacheDocument(LATRADocumentModel document);
  Future<void> removeCachedDocument(String documentId);

  // Cache management
  Future<void> clearAllCache();
  Future<void> clearUserCache(String userId);
  Future<bool> isCacheValid(String key);
}

/// SharedPreferences implementation of LATRA local data source
class LATRALocalDataSourceImpl implements LATRALocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _applicationsPrefix = 'latra_applications_';
  static const String _applicationPrefix = 'latra_application_';
  static const String _statusPrefix = 'latra_status_';
  static const String _documentsPrefix = 'latra_documents_';
  static const String _userDocumentsPrefix = 'latra_user_documents_';
  static const String _cacheTimestampPrefix = 'latra_cache_timestamp_';
  static const int _cacheValidityHours = 24;

  const LATRALocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<LATRAApplicationModel>> getCachedUserApplications(String userId) async {
    final key = '$_applicationsPrefix$userId';
    
    if (!await isCacheValid(key)) {
      return [];
    }

    final jsonString = sharedPreferences.getString(key);
    if (jsonString == null) return [];

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => LATRAApplicationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<LATRAApplicationModel?> getCachedApplicationById(String applicationId) async {
    final key = '$_applicationPrefix$applicationId';
    
    if (!await isCacheValid(key)) {
      return null;
    }

    final jsonString = sharedPreferences.getString(key);
    if (jsonString == null) return null;

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return LATRAApplicationModel.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUserApplications(String userId, List<LATRAApplicationModel> applications) async {
    final key = '$_applicationsPrefix$userId';
    final jsonList = applications.map((app) => app.toJson()).toList();
    
    await sharedPreferences.setString(key, json.encode(jsonList));
    await _setCacheTimestamp(key);
  }

  @override
  Future<void> cacheApplication(LATRAApplicationModel application) async {
    final key = '$_applicationPrefix${application.id}';
    
    await sharedPreferences.setString(key, json.encode(application.toJson()));
    await _setCacheTimestamp(key);
  }

  @override
  Future<void> removeCachedApplication(String applicationId) async {
    final key = '$_applicationPrefix$applicationId';
    await sharedPreferences.remove(key);
    await sharedPreferences.remove('$_cacheTimestampPrefix$key');
  }

  @override
  Future<List<LATRAStatusModel>> getCachedApplicationStatus(String applicationId) async {
    final key = '$_statusPrefix$applicationId';
    
    if (!await isCacheValid(key)) {
      return [];
    }

    final jsonString = sharedPreferences.getString(key);
    if (jsonString == null) return [];

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => LATRAStatusModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<LATRAStatusModel?> getCachedLatestStatus(String applicationId) async {
    final statusList = await getCachedApplicationStatus(applicationId);
    if (statusList.isEmpty) return null;

    // Return the most recent status
    statusList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return statusList.first;
  }

  @override
  Future<void> cacheApplicationStatus(String applicationId, List<LATRAStatusModel> statusList) async {
    final key = '$_statusPrefix$applicationId';
    final jsonList = statusList.map((status) => status.toJson()).toList();
    
    await sharedPreferences.setString(key, json.encode(jsonList));
    await _setCacheTimestamp(key);
  }

  @override
  Future<void> cacheStatus(LATRAStatusModel status) async {
    // Get existing status list and add new status
    final existingStatus = await getCachedApplicationStatus(status.applicationId);
    
    // Remove existing status with same ID if it exists
    existingStatus.removeWhere((s) => s.id == status.id);
    
    // Add new status
    existingStatus.add(status);
    
    // Cache updated list
    await cacheApplicationStatus(status.applicationId, existingStatus);
  }

  @override
  Future<List<LATRADocumentModel>> getCachedApplicationDocuments(String applicationId) async {
    final key = '$_documentsPrefix$applicationId';
    
    if (!await isCacheValid(key)) {
      return [];
    }

    final jsonString = sharedPreferences.getString(key);
    if (jsonString == null) return [];

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => LATRADocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<LATRADocumentModel>> getCachedUserDocuments(String userId) async {
    final key = '$_userDocumentsPrefix$userId';
    
    if (!await isCacheValid(key)) {
      return [];
    }

    final jsonString = sharedPreferences.getString(key);
    if (jsonString == null) return [];

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => LATRADocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheApplicationDocuments(String applicationId, List<LATRADocumentModel> documents) async {
    final key = '$_documentsPrefix$applicationId';
    final jsonList = documents.map((doc) => doc.toJson()).toList();
    
    await sharedPreferences.setString(key, json.encode(jsonList));
    await _setCacheTimestamp(key);
  }

  @override
  Future<void> cacheDocument(LATRADocumentModel document) async {
    // Cache in application documents
    final existingDocs = await getCachedApplicationDocuments(document.applicationId);
    
    // Remove existing document with same ID if it exists
    existingDocs.removeWhere((d) => d.id == document.id);
    
    // Add new document
    existingDocs.add(document);
    
    // Cache updated list
    await cacheApplicationDocuments(document.applicationId, existingDocs);

    // Also cache in user documents if userId is available
    if (document.userId.isNotEmpty) {
      final userDocs = await getCachedUserDocuments(document.userId);
      userDocs.removeWhere((d) => d.id == document.id);
      userDocs.add(document);
      
      final userKey = '$_userDocumentsPrefix${document.userId}';
      final jsonList = userDocs.map((doc) => doc.toJson()).toList();
      await sharedPreferences.setString(userKey, json.encode(jsonList));
      await _setCacheTimestamp(userKey);
    }
  }

  @override
  Future<void> removeCachedDocument(String documentId) async {
    // This is a simplified implementation
    // In a real app, you might need to track which caches contain this document
    final keys = sharedPreferences.getKeys()
        .where((key) => key.startsWith(_documentsPrefix) || key.startsWith(_userDocumentsPrefix));

    for (final key in keys) {
      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        try {
          final jsonList = json.decode(jsonString) as List;
          final documents = jsonList
              .map((json) => LATRADocumentModel.fromJson(json as Map<String, dynamic>))
              .toList();
          
          final updatedDocs = documents.where((doc) => doc.id != documentId).toList();
          
          if (updatedDocs.length != documents.length) {
            // Document was found and removed
            final updatedJsonList = updatedDocs.map((doc) => doc.toJson()).toList();
            await sharedPreferences.setString(key, json.encode(updatedJsonList));
          }
        } catch (e) {
          // Skip invalid cache entries
        }
      }
    }
  }

  @override
  Future<void> clearAllCache() async {
    final keys = sharedPreferences.getKeys()
        .where((key) => 
            key.startsWith(_applicationsPrefix) ||
            key.startsWith(_applicationPrefix) ||
            key.startsWith(_statusPrefix) ||
            key.startsWith(_documentsPrefix) ||
            key.startsWith(_userDocumentsPrefix) ||
            key.startsWith(_cacheTimestampPrefix))
        .toList();

    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }

  @override
  Future<void> clearUserCache(String userId) async {
    final keys = [
      '$_applicationsPrefix$userId',
      '$_userDocumentsPrefix$userId',
    ];

    for (final key in keys) {
      await sharedPreferences.remove(key);
      await sharedPreferences.remove('$_cacheTimestampPrefix$key');
    }
  }

  @override
  Future<bool> isCacheValid(String key) async {
    final timestampKey = '$_cacheTimestampPrefix$key';
    final timestamp = sharedPreferences.getInt(timestampKey);
    
    if (timestamp == null) return false;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(cacheTime);
    
    return difference.inHours < _cacheValidityHours;
  }

  /// Set cache timestamp for a key
  Future<void> _setCacheTimestamp(String key) async {
    final timestampKey = '$_cacheTimestampPrefix$key';
    await sharedPreferences.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
  }
}
