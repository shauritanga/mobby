import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_model.dart';
import '../models/cart_item_model.dart';

/// Local data source for cart operations using SharedPreferences
abstract class CartLocalDataSource {
  /// Get cached cart for a user
  Future<CartModel?> getCachedCart(String userId);

  /// Cache a cart for a user
  Future<void> cacheCart(String userId, CartModel cart);

  /// Remove cached cart for a user
  Future<void> removeCachedCart(String userId);

  /// Get all cached carts (for debugging/admin purposes)
  Future<Map<String, CartModel>> getAllCachedCarts();

  /// Clear all cached carts
  Future<void> clearAllCachedCarts();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl({required this.sharedPreferences});

  static const String _cartPrefix = 'CACHED_CART_';

  @override
  Future<CartModel?> getCachedCart(String userId) async {
    try {
      final jsonString = sharedPreferences.getString('$_cartPrefix$userId');
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return CartModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      print('Error getting cached cart for user $userId: $e');
      return null;
    }
  }

  @override
  Future<void> cacheCart(String userId, CartModel cart) async {
    try {
      final jsonString = json.encode(cart.toJson());
      await sharedPreferences.setString('$_cartPrefix$userId', jsonString);
    } catch (e) {
      print('Error caching cart for user $userId: $e');
      throw Exception('Failed to cache cart');
    }
  }

  @override
  Future<void> removeCachedCart(String userId) async {
    try {
      await sharedPreferences.remove('$_cartPrefix$userId');
    } catch (e) {
      print('Error removing cached cart for user $userId: $e');
      throw Exception('Failed to remove cached cart');
    }
  }

  @override
  Future<Map<String, CartModel>> getAllCachedCarts() async {
    try {
      final Map<String, CartModel> carts = {};
      final keys = sharedPreferences.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cartPrefix)) {
          final userId = key.substring(_cartPrefix.length);
          final cart = await getCachedCart(userId);
          if (cart != null) {
            carts[userId] = cart;
          }
        }
      }
      
      return carts;
    } catch (e) {
      print('Error getting all cached carts: $e');
      return {};
    }
  }

  @override
  Future<void> clearAllCachedCarts() async {
    try {
      final keys = sharedPreferences.getKeys();
      final cartKeys = keys.where((key) => key.startsWith(_cartPrefix));
      
      for (final key in cartKeys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      print('Error clearing all cached carts: $e');
      throw Exception('Failed to clear cached carts');
    }
  }
}
