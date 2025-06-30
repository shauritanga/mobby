import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/return_model.dart';

abstract class OrdersLocalDataSource {
  Future<void> cacheOrders(List<OrderModel> orders, String userId);
  Future<List<OrderModel>> getCachedOrders(String userId);
  Future<void> cacheOrder(OrderModel order);
  Future<OrderModel?> getCachedOrder(String orderId);
  Future<void> cacheReturns(List<ReturnModel> returns, String userId);
  Future<List<ReturnModel>> getCachedReturns(String userId);
  Future<void> clearCache();
  Future<void> clearUserCache(String userId);
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  final SharedPreferences _prefs;

  OrdersLocalDataSourceImpl({required SharedPreferences prefs})
    : _prefs = prefs;

  static const String _ordersKey = 'cached_orders_';
  static const String _orderKey = 'cached_order_';
  static const String _returnsKey = 'cached_returns_';

  @override
  Future<void> cacheOrders(List<OrderModel> orders, String userId) async {
    try {
      final ordersJson = orders.map((order) => order.toJson()).toList();
      final ordersString = jsonEncode(ordersJson);
      await _prefs.setString('$_ordersKey$userId', ordersString);

      // Also cache individual orders
      for (final order in orders) {
        await cacheOrder(order);
      }
    } catch (e) {
      // Error caching orders: $e
    }
  }

  @override
  Future<List<OrderModel>> getCachedOrders(String userId) async {
    try {
      final ordersString = _prefs.getString('$_ordersKey$userId');
      if (ordersString == null) return [];

      final ordersJson = jsonDecode(ordersString) as List<dynamic>;
      return ordersJson
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Error getting cached orders: $e
      return [];
    }
  }

  @override
  Future<void> cacheOrder(OrderModel order) async {
    try {
      final orderString = jsonEncode(order.toJson());
      await _prefs.setString('$_orderKey${order.id}', orderString);
    } catch (e) {
      // Error caching order: $e
    }
  }

  @override
  Future<OrderModel?> getCachedOrder(String orderId) async {
    try {
      final orderString = _prefs.getString('$_orderKey$orderId');
      if (orderString == null) return null;

      final orderJson = jsonDecode(orderString) as Map<String, dynamic>;
      return OrderModel.fromJson(orderJson);
    } catch (e) {
      // Error getting cached order: $e
      return null;
    }
  }

  @override
  Future<void> cacheReturns(List<ReturnModel> returns, String userId) async {
    try {
      final returnsJson = returns
          .map((returnItem) => returnItem.toJson())
          .toList();
      final returnsString = jsonEncode(returnsJson);
      await _prefs.setString('$_returnsKey$userId', returnsString);
    } catch (e) {
      // Error caching returns: $e
    }
  }

  @override
  Future<List<ReturnModel>> getCachedReturns(String userId) async {
    try {
      final returnsString = _prefs.getString('$_returnsKey$userId');
      if (returnsString == null) return [];

      final returnsJson = jsonDecode(returnsString) as List<dynamic>;
      return returnsJson
          .map((json) => ReturnModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Error getting cached returns: $e
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = _prefs.getKeys();
      final orderKeys = keys.where(
        (key) =>
            key.startsWith(_ordersKey) ||
            key.startsWith(_orderKey) ||
            key.startsWith(_returnsKey),
      );

      for (final key in orderKeys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      // Error clearing cache: $e
    }
  }

  @override
  Future<void> clearUserCache(String userId) async {
    try {
      await _prefs.remove('$_ordersKey$userId');
      await _prefs.remove('$_returnsKey$userId');

      // Clear individual order cache for this user would require tracking
      // which orders belong to which user, which is complex for this implementation
    } catch (e) {
      // Error clearing user cache: $e
    }
  }
}
