import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class ViewOrdersParams {
  final String userId;
  final int page;
  final int limit;
  final OrderStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? query;

  const ViewOrdersParams({
    required this.userId,
    this.page = 1,
    this.limit = 20,
    this.status,
    this.startDate,
    this.endDate,
    this.query,
  });
}

class ViewOrders {
  final OrdersRepository repository;

  ViewOrders(this.repository);

  Future<List<Order>> call(ViewOrdersParams params) async {
    if (params.query != null || 
        params.status != null || 
        params.startDate != null || 
        params.endDate != null) {
      return await repository.searchOrders(
        params.userId,
        query: params.query,
        status: params.status,
        startDate: params.startDate,
        endDate: params.endDate,
        page: params.page,
        limit: params.limit,
      );
    }
    
    return await repository.getUserOrders(
      params.userId,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetOrderDetails {
  final OrdersRepository repository;

  GetOrderDetails(this.repository);

  Future<Order?> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}

class GetOrderStatistics {
  final OrdersRepository repository;

  GetOrderStatistics(this.repository);

  Future<Map<String, dynamic>> call(String userId) async {
    return await repository.getOrderStatistics(userId);
  }
}
