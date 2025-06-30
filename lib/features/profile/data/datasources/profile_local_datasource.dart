import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/address_model.dart';
import '../models/payment_method_model.dart';
import '../models/user_preferences_model.dart';
import '../../../auth/data/models/user_model.dart';

/// Profile local data source for caching
/// Following the specifications from FEATURES_DOCUMENTATION.md
abstract class ProfileLocalDataSource {
  // User Profile Caching
  Future<void> cacheUserProfile(UserModel user);
  Future<UserModel?> getCachedUserProfile(String userId);
  Future<void> clearCachedUserProfile(String userId);

  // Address Caching
  Future<void> cacheUserAddresses(String userId, List<AddressModel> addresses);
  Future<List<AddressModel>?> getCachedUserAddresses(String userId);
  Future<void> clearCachedUserAddresses(String userId);

  // Payment Methods Caching
  Future<void> cacheUserPaymentMethods(
    String userId,
    List<PaymentMethodModel> paymentMethods,
  );
  Future<List<PaymentMethodModel>?> getCachedUserPaymentMethods(String userId);
  Future<void> clearCachedUserPaymentMethods(String userId);

  // User Preferences Caching
  Future<void> cacheUserPreferences(UserPreferencesModel preferences);
  Future<UserPreferencesModel?> getCachedUserPreferences(String userId);
  Future<void> clearCachedUserPreferences(String userId);

  // Cache Management
  Future<void> clearAllProfileCache(String userId);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  static const String _userProfilePrefix = 'CACHED_USER_PROFILE_';
  static const String _userAddressesPrefix = 'CACHED_USER_ADDRESSES_';
  static const String _userPaymentMethodsPrefix =
      'CACHED_USER_PAYMENT_METHODS_';
  static const String _userPreferencesPrefix = 'CACHED_USER_PREFERENCES_';

  @override
  Future<void> cacheUserProfile(UserModel user) async {
    try {
      await sharedPreferences.setString(
        '$_userProfilePrefix${user.id}',
        json.encode(user.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache user profile: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUserProfile(String userId) async {
    try {
      final jsonString = sharedPreferences.getString(
        '$_userProfilePrefix$userId',
      );
      if (jsonString != null) {
        return UserModel.fromJson(json.decode(jsonString));
      }
      return null;
    } catch (e) {
      throw CacheException(
        'Failed to get cached user profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCachedUserProfile(String userId) async {
    try {
      await sharedPreferences.remove('$_userProfilePrefix$userId');
    } catch (e) {
      throw CacheException(
        'Failed to clear cached user profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheUserAddresses(
    String userId,
    List<AddressModel> addresses,
  ) async {
    try {
      final jsonString = json.encode(addresses.map((a) => a.toJson()).toList());
      await sharedPreferences.setString(
        '$_userAddressesPrefix$userId',
        jsonString,
      );
    } catch (e) {
      throw CacheException('Failed to cache user addresses: ${e.toString()}');
    }
  }

  @override
  Future<List<AddressModel>?> getCachedUserAddresses(String userId) async {
    try {
      final jsonString = sharedPreferences.getString(
        '$_userAddressesPrefix$userId',
      );
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => AddressModel.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      throw CacheException(
        'Failed to get cached user addresses: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCachedUserAddresses(String userId) async {
    try {
      await sharedPreferences.remove('$_userAddressesPrefix$userId');
    } catch (e) {
      throw CacheException(
        'Failed to clear cached user addresses: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheUserPaymentMethods(
    String userId,
    List<PaymentMethodModel> paymentMethods,
  ) async {
    try {
      final jsonString = json.encode(
        paymentMethods.map((p) => p.toJson()).toList(),
      );
      await sharedPreferences.setString(
        '$_userPaymentMethodsPrefix$userId',
        jsonString,
      );
    } catch (e) {
      throw CacheException(
        'Failed to cache user payment methods: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PaymentMethodModel>?> getCachedUserPaymentMethods(
    String userId,
  ) async {
    try {
      final jsonString = sharedPreferences.getString(
        '$_userPaymentMethodsPrefix$userId',
      );
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((json) => PaymentMethodModel.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException(
        'Failed to get cached user payment methods: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCachedUserPaymentMethods(String userId) async {
    try {
      await sharedPreferences.remove('$_userPaymentMethodsPrefix$userId');
    } catch (e) {
      throw CacheException(
        'Failed to clear cached user payment methods: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheUserPreferences(UserPreferencesModel preferences) async {
    try {
      await sharedPreferences.setString(
        '$_userPreferencesPrefix${preferences.userId}',
        json.encode(preferences.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache user preferences: ${e.toString()}');
    }
  }

  @override
  Future<UserPreferencesModel?> getCachedUserPreferences(String userId) async {
    try {
      final jsonString = sharedPreferences.getString(
        '$_userPreferencesPrefix$userId',
      );
      if (jsonString != null) {
        return UserPreferencesModel.fromJson(json.decode(jsonString));
      }
      return null;
    } catch (e) {
      throw CacheException(
        'Failed to get cached user preferences: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCachedUserPreferences(String userId) async {
    try {
      await sharedPreferences.remove('$_userPreferencesPrefix$userId');
    } catch (e) {
      throw CacheException(
        'Failed to clear cached user preferences: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearAllProfileCache(String userId) async {
    try {
      await Future.wait([
        clearCachedUserProfile(userId),
        clearCachedUserAddresses(userId),
        clearCachedUserPaymentMethods(userId),
        clearCachedUserPreferences(userId),
      ]);
    } catch (e) {
      throw CacheException(
        'Failed to clear all profile cache: ${e.toString()}',
      );
    }
  }
}
