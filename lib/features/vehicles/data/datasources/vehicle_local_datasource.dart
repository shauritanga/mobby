import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/vehicle_model.dart';
import '../models/document_model.dart';
import '../models/maintenance_record_model.dart';

/// Vehicle local data source interface
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
abstract class VehicleLocalDataSource {
  // Vehicle operations
  Future<List<VehicleModel>> getCachedUserVehicles(String userId);
  Future<VehicleModel?> getCachedVehicleById(String vehicleId);
  Future<void> cacheUserVehicles(String userId, List<VehicleModel> vehicles);
  Future<void> cacheVehicle(VehicleModel vehicle);
  Future<void> removeCachedVehicle(String vehicleId);
  Future<void> clearVehicleCache(String userId);

  // Document operations
  Future<List<DocumentModel>> getCachedVehicleDocuments(String vehicleId);
  Future<List<DocumentModel>> getCachedUserDocuments(String userId);
  Future<DocumentModel?> getCachedDocumentById(String documentId);
  Future<void> cacheVehicleDocuments(String vehicleId, List<DocumentModel> documents);
  Future<void> cacheUserDocuments(String userId, List<DocumentModel> documents);
  Future<void> cacheDocument(DocumentModel document);
  Future<void> removeCachedDocument(String documentId);
  Future<void> clearDocumentCache(String userId);

  // Maintenance operations
  Future<List<MaintenanceRecordModel>> getCachedVehicleMaintenanceRecords(String vehicleId);
  Future<List<MaintenanceRecordModel>> getCachedUserMaintenanceRecords(String userId);
  Future<MaintenanceRecordModel?> getCachedMaintenanceRecordById(String recordId);
  Future<void> cacheVehicleMaintenanceRecords(String vehicleId, List<MaintenanceRecordModel> records);
  Future<void> cacheUserMaintenanceRecords(String userId, List<MaintenanceRecordModel> records);
  Future<void> cacheMaintenanceRecord(MaintenanceRecordModel record);
  Future<void> removeCachedMaintenanceRecord(String recordId);
  Future<void> clearMaintenanceCache(String userId);

  // Cache management
  Future<void> clearAllVehicleCache();
  Future<DateTime?> getLastCacheUpdate(String key);
  Future<void> setLastCacheUpdate(String key, DateTime timestamp);
}

/// SharedPreferences implementation of VehicleLocalDataSource
class VehicleLocalDataSourceImpl implements VehicleLocalDataSource {
  final SharedPreferences sharedPreferences;

  VehicleLocalDataSourceImpl({required this.sharedPreferences});

  // Cache keys
  static const String _vehiclesCachePrefix = 'CACHED_VEHICLES_';
  static const String _vehicleCachePrefix = 'CACHED_VEHICLE_';
  static const String _vehicleDocumentsCachePrefix = 'CACHED_VEHICLE_DOCUMENTS_';
  static const String _userDocumentsCachePrefix = 'CACHED_USER_DOCUMENTS_';
  static const String _documentCachePrefix = 'CACHED_DOCUMENT_';
  static const String _vehicleMaintenanceCachePrefix = 'CACHED_VEHICLE_MAINTENANCE_';
  static const String _userMaintenanceCachePrefix = 'CACHED_USER_MAINTENANCE_';
  static const String _maintenanceCachePrefix = 'CACHED_MAINTENANCE_';
  static const String _cacheTimestampPrefix = 'CACHE_TIMESTAMP_';

  @override
  Future<List<VehicleModel>> getCachedUserVehicles(String userId) async {
    try {
      final jsonString = sharedPreferences.getString('$_vehiclesCachePrefix$userId');
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => VehicleModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<VehicleModel?> getCachedVehicleById(String vehicleId) async {
    try {
      final jsonString = sharedPreferences.getString('$_vehicleCachePrefix$vehicleId');
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return VehicleModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheUserVehicles(String userId, List<VehicleModel> vehicles) async {
    try {
      final jsonString = json.encode(vehicles.map((v) => v.toJson()).toList());
      await sharedPreferences.setString('$_vehiclesCachePrefix$userId', jsonString);
      await setLastCacheUpdate('vehicles_$userId', DateTime.now());
      
      // Also cache individual vehicles
      for (final vehicle in vehicles) {
        await cacheVehicle(vehicle);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheVehicle(VehicleModel vehicle) async {
    try {
      final jsonString = json.encode(vehicle.toJson());
      await sharedPreferences.setString('$_vehicleCachePrefix${vehicle.id}', jsonString);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> removeCachedVehicle(String vehicleId) async {
    try {
      await sharedPreferences.remove('$_vehicleCachePrefix$vehicleId');
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearVehicleCache(String userId) async {
    try {
      await sharedPreferences.remove('$_vehiclesCachePrefix$userId');
      await sharedPreferences.remove('${_cacheTimestampPrefix}vehicles_$userId');
      
      // Remove individual vehicle caches for this user
      final keys = sharedPreferences.getKeys();
      for (final key in keys) {
        if (key.startsWith(_vehicleCachePrefix)) {
          await sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<DocumentModel>> getCachedVehicleDocuments(String vehicleId) async {
    try {
      final jsonString = sharedPreferences.getString('$_vehicleDocumentsCachePrefix$vehicleId');
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => DocumentModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<DocumentModel>> getCachedUserDocuments(String userId) async {
    try {
      final jsonString = sharedPreferences.getString('$_userDocumentsCachePrefix$userId');
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => DocumentModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<DocumentModel?> getCachedDocumentById(String documentId) async {
    try {
      final jsonString = sharedPreferences.getString('$_documentCachePrefix$documentId');
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return DocumentModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheVehicleDocuments(String vehicleId, List<DocumentModel> documents) async {
    try {
      final jsonString = json.encode(documents.map((d) => d.toJson()).toList());
      await sharedPreferences.setString('$_vehicleDocumentsCachePrefix$vehicleId', jsonString);
      await setLastCacheUpdate('vehicle_documents_$vehicleId', DateTime.now());
      
      // Also cache individual documents
      for (final document in documents) {
        await cacheDocument(document);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheUserDocuments(String userId, List<DocumentModel> documents) async {
    try {
      final jsonString = json.encode(documents.map((d) => d.toJson()).toList());
      await sharedPreferences.setString('$_userDocumentsCachePrefix$userId', jsonString);
      await setLastCacheUpdate('user_documents_$userId', DateTime.now());
      
      // Also cache individual documents
      for (final document in documents) {
        await cacheDocument(document);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheDocument(DocumentModel document) async {
    try {
      final jsonString = json.encode(document.toJson());
      await sharedPreferences.setString('$_documentCachePrefix${document.id}', jsonString);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> removeCachedDocument(String documentId) async {
    try {
      await sharedPreferences.remove('$_documentCachePrefix$documentId');
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearDocumentCache(String userId) async {
    try {
      await sharedPreferences.remove('$_userDocumentsCachePrefix$userId');
      await sharedPreferences.remove('${_cacheTimestampPrefix}user_documents_$userId');
      
      // Remove individual document caches
      final keys = sharedPreferences.getKeys();
      for (final key in keys) {
        if (key.startsWith(_documentCachePrefix) || key.startsWith(_vehicleDocumentsCachePrefix)) {
          await sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<MaintenanceRecordModel>> getCachedVehicleMaintenanceRecords(String vehicleId) async {
    try {
      final jsonString = sharedPreferences.getString('$_vehicleMaintenanceCachePrefix$vehicleId');
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => MaintenanceRecordModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<MaintenanceRecordModel>> getCachedUserMaintenanceRecords(String userId) async {
    try {
      final jsonString = sharedPreferences.getString('$_userMaintenanceCachePrefix$userId');
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => MaintenanceRecordModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<MaintenanceRecordModel?> getCachedMaintenanceRecordById(String recordId) async {
    try {
      final jsonString = sharedPreferences.getString('$_maintenanceCachePrefix$recordId');
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return MaintenanceRecordModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheVehicleMaintenanceRecords(String vehicleId, List<MaintenanceRecordModel> records) async {
    try {
      final jsonString = json.encode(records.map((r) => r.toJson()).toList());
      await sharedPreferences.setString('$_vehicleMaintenanceCachePrefix$vehicleId', jsonString);
      await setLastCacheUpdate('vehicle_maintenance_$vehicleId', DateTime.now());
      
      // Also cache individual records
      for (final record in records) {
        await cacheMaintenanceRecord(record);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheUserMaintenanceRecords(String userId, List<MaintenanceRecordModel> records) async {
    try {
      final jsonString = json.encode(records.map((r) => r.toJson()).toList());
      await sharedPreferences.setString('$_userMaintenanceCachePrefix$userId', jsonString);
      await setLastCacheUpdate('user_maintenance_$userId', DateTime.now());
      
      // Also cache individual records
      for (final record in records) {
        await cacheMaintenanceRecord(record);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheMaintenanceRecord(MaintenanceRecordModel record) async {
    try {
      final jsonString = json.encode(record.toJson());
      await sharedPreferences.setString('$_maintenanceCachePrefix${record.id}', jsonString);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> removeCachedMaintenanceRecord(String recordId) async {
    try {
      await sharedPreferences.remove('$_maintenanceCachePrefix$recordId');
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearMaintenanceCache(String userId) async {
    try {
      await sharedPreferences.remove('$_userMaintenanceCachePrefix$userId');
      await sharedPreferences.remove('${_cacheTimestampPrefix}user_maintenance_$userId');
      
      // Remove individual maintenance caches
      final keys = sharedPreferences.getKeys();
      for (final key in keys) {
        if (key.startsWith(_maintenanceCachePrefix) || key.startsWith(_vehicleMaintenanceCachePrefix)) {
          await sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearAllVehicleCache() async {
    try {
      final keys = sharedPreferences.getKeys();
      final vehicleKeys = keys.where((key) => 
        key.startsWith(_vehiclesCachePrefix) ||
        key.startsWith(_vehicleCachePrefix) ||
        key.startsWith(_vehicleDocumentsCachePrefix) ||
        key.startsWith(_userDocumentsCachePrefix) ||
        key.startsWith(_documentCachePrefix) ||
        key.startsWith(_vehicleMaintenanceCachePrefix) ||
        key.startsWith(_userMaintenanceCachePrefix) ||
        key.startsWith(_maintenanceCachePrefix) ||
        (key.startsWith(_cacheTimestampPrefix) && (
          key.contains('vehicles_') ||
          key.contains('documents_') ||
          key.contains('maintenance_')
        ))
      );
      
      for (final key in vehicleKeys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<DateTime?> getLastCacheUpdate(String key) async {
    try {
      final timestampString = sharedPreferences.getString('$_cacheTimestampPrefix$key');
      if (timestampString != null) {
        return DateTime.parse(timestampString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setLastCacheUpdate(String key, DateTime timestamp) async {
    try {
      await sharedPreferences.setString('$_cacheTimestampPrefix$key', timestamp.toIso8601String());
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
