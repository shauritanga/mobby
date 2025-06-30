import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../domain/entities/order.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/entities/return.dart';
import '../../domain/usecases/view_orders.dart';
import '../../domain/usecases/track_order.dart';
import '../../domain/usecases/request_return.dart';
import '../../data/datasources/orders_remote_datasource.dart';
import '../../data/datasources/orders_local_datasource.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// Data source providers
final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  return OrdersRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

final ordersLocalDataSourceProvider = Provider<OrdersLocalDataSource>((ref) {
  // This will be provided by dependency injection in main.dart
  throw UnimplementedError('SharedPreferences must be provided');
});

// Repository provider
final ordersRepositoryProvider = Provider((ref) {
  return OrdersRepositoryImpl(
    remoteDataSource: ref.read(ordersRemoteDataSourceProvider),
    localDataSource: ref.read(ordersLocalDataSourceProvider),
  );
});

// Use case providers
final viewOrdersUseCaseProvider = Provider((ref) {
  return ViewOrders(ref.read(ordersRepositoryProvider));
});

final getOrderDetailsUseCaseProvider = Provider((ref) {
  return GetOrderDetails(ref.read(ordersRepositoryProvider));
});

final getOrderStatisticsUseCaseProvider = Provider((ref) {
  return GetOrderStatistics(ref.read(ordersRepositoryProvider));
});

final trackOrderUseCaseProvider = Provider((ref) {
  return TrackOrder(ref.read(ordersRepositoryProvider));
});

final requestReturnUseCaseProvider = Provider((ref) {
  return RequestReturn(ref.read(ordersRepositoryProvider));
});

final viewReturnsUseCaseProvider = Provider((ref) {
  return ViewReturns(ref.read(ordersRepositoryProvider));
});

final getReturnDetailsUseCaseProvider = Provider((ref) {
  return GetReturnDetails(ref.read(ordersRepositoryProvider));
});

final cancelReturnUseCaseProvider = Provider((ref) {
  return CancelReturn(ref.read(ordersRepositoryProvider));
});

// State providers for UI
class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Orders list provider
final ordersProvider =
    StateNotifierProvider<OrdersNotifier, AsyncValue<OrdersState>>((ref) {
      return OrdersNotifier(ref);
    });

class OrdersNotifier extends StateNotifier<AsyncValue<OrdersState>> {
  final Ref _ref;

  OrdersNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> loadOrders({bool refresh = false}) async {
    final user = _ref.read(currentUserProvider);

    try {
      if (refresh) {
        state = const AsyncValue.loading();
      } else if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(isLoading: true));
      }

      final viewOrdersUseCase = _ref.read(viewOrdersUseCaseProvider);
      final params = ViewOrdersParams(
        userId: user.value!.id,
        page: 1,
        limit: 20,
      );
      final orders = await viewOrdersUseCase(params);

      state = AsyncValue.data(
        OrdersState(
          orders: orders,
          isLoading: false,
          hasMore: orders.length >= 20,
          currentPage: 1,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMoreOrders() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoading ||
        !currentState.hasMore) {
      return;
    }

    final user = _ref.read(currentUserProvider);

    try {
      state = AsyncValue.data(currentState.copyWith(isLoading: true));

      final viewOrdersUseCase = _ref.read(viewOrdersUseCaseProvider);
      final params = ViewOrdersParams(
        userId: user.value!.id,
        page: currentState.currentPage + 1,
        limit: 20,
      );
      final newOrders = await viewOrdersUseCase(params);

      final allOrders = [...currentState.orders, ...newOrders];
      state = AsyncValue.data(
        OrdersState(
          orders: allOrders,
          isLoading: false,
          hasMore: newOrders.length >= 20,
          currentPage: currentState.currentPage + 1,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> searchOrders({
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = _ref.read(currentUserProvider);

    try {
      state = const AsyncValue.loading();

      final viewOrdersUseCase = _ref.read(viewOrdersUseCaseProvider);
      final params = ViewOrdersParams(
        userId: user.value!.id,
        query: query,
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: 1,
        limit: 20,
      );
      final orders = await viewOrdersUseCase(params);

      state = AsyncValue.data(
        OrdersState(
          orders: orders,
          isLoading: false,
          hasMore: orders.length >= 20,
          currentPage: 1,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Individual order provider
final orderDetailsProvider = FutureProvider.family<Order?, String>((
  ref,
  orderId,
) async {
  final getOrderDetailsUseCase = ref.read(getOrderDetailsUseCaseProvider);
  return await getOrderDetailsUseCase(orderId);
});

// Order statistics provider
final orderStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final user = ref.read(currentUserProvider);

  final getOrderStatisticsUseCase = ref.read(getOrderStatisticsUseCaseProvider);
  return await getOrderStatisticsUseCase(user.value!.id);
});

// Shipment tracking provider
final shipmentTrackingProvider =
    FutureProvider.family<List<Shipment>, TrackOrderParams>((
      ref,
      params,
    ) async {
      final trackOrderUseCase = ref.read(trackOrderUseCaseProvider);
      return await trackOrderUseCase(params);
    });

// Returns provider
final returnsProvider = FutureProvider<List<Return>>((ref) async {
  final user = ref.read(currentUserProvider);

  final viewReturnsUseCase = ref.read(viewReturnsUseCaseProvider);
  return await viewReturnsUseCase(user.value!.id);
});

// Individual return provider
final returnDetailsProvider = FutureProvider.family<Return?, String>((
  ref,
  returnId,
) async {
  final getReturnDetailsUseCase = ref.read(getReturnDetailsUseCaseProvider);
  return await getReturnDetailsUseCase(returnId);
});
