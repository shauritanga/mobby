import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../models/auth_token_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCachedUser();
  
  Future<AuthTokenModel?> getCachedToken();
  Future<void> cacheToken(AuthTokenModel token);
  Future<void> clearCachedToken();
  
  Future<bool> isFirstTime();
  Future<void> setFirstTime(bool isFirstTime);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _cachedUserKey = 'CACHED_USER';
  static const String _cachedTokenKey = 'CACHED_TOKEN';
  static const String _isFirstTimeKey = 'IS_FIRST_TIME';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedUserKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(_cachedUserKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await sharedPreferences.remove(_cachedUserKey);
    } catch (e) {
      throw CacheException('Failed to clear cached user: ${e.toString()}');
    }
  }

  @override
  Future<AuthTokenModel?> getCachedToken() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedTokenKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return AuthTokenModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached token: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheToken(AuthTokenModel token) async {
    try {
      final jsonString = json.encode(token.toJson());
      await sharedPreferences.setString(_cachedTokenKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache token: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCachedToken() async {
    try {
      await sharedPreferences.remove(_cachedTokenKey);
    } catch (e) {
      throw CacheException('Failed to clear cached token: ${e.toString()}');
    }
  }

  @override
  Future<bool> isFirstTime() async {
    try {
      return sharedPreferences.getBool(_isFirstTimeKey) ?? true;
    } catch (e) {
      throw CacheException('Failed to get first time status: ${e.toString()}');
    }
  }

  @override
  Future<void> setFirstTime(bool isFirstTime) async {
    try {
      await sharedPreferences.setBool(_isFirstTimeKey, isFirstTime);
    } catch (e) {
      throw CacheException('Failed to set first time status: ${e.toString()}');
    }
  }
}
