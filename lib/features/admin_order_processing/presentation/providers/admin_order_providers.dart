import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../domain/entities/order.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/usecases/process_orders.dart';
import '../../domain/usecases/manage_shipping.dart';
import '../../domain/usecases/customer_communication.dart';
import '../../data/datasources/admin_order_remote_datasource.dart';
import '../../data/repositories/admin_order_repository_impl.dart';

// Data source providers
final adminOrderRemoteDataSourceProvider = Provider<AdminOrderRemoteDataSource>(
  (ref) {
    return AdminOrderRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
    );
  },
);

// Repository provider
final adminOrderRepositoryProvider = Provider((ref) {
  return AdminOrderRepositoryImpl(
    remoteDataSource: ref.read(adminOrderRemoteDataSourceProvider),
  );
});

// Order Use Case Providers
final getOrdersUseCaseProvider = Provider((ref) {
  return GetOrders(ref.read(adminOrderRepositoryProvider));
});

final getOrderByIdUseCaseProvider = Provider((ref) {
  return GetOrderById(ref.read(adminOrderRepositoryProvider));
});

final getOrderByNumberUseCaseProvider = Provider((ref) {
  return GetOrderByNumber(ref.read(adminOrderRepositoryProvider));
});

final updateOrderStatusUseCaseProvider = Provider((ref) {
  return UpdateOrderStatus(ref.read(adminOrderRepositoryProvider));
});

final updateOrderPriorityUseCaseProvider = Provider((ref) {
  return UpdateOrderPriority(ref.read(adminOrderRepositoryProvider));
});

final assignOrderUseCaseProvider = Provider((ref) {
  return AssignOrder(ref.read(adminOrderRepositoryProvider));
});

final unassignOrderUseCaseProvider = Provider((ref) {
  return UnassignOrder(ref.read(adminOrderRepositoryProvider));
});

final addOrderNotesUseCaseProvider = Provider((ref) {
  return AddOrderNotes(ref.read(adminOrderRepositoryProvider));
});

final processOrderUseCaseProvider = Provider((ref) {
  return ProcessOrder(ref.read(adminOrderRepositoryProvider));
});

final cancelOrderUseCaseProvider = Provider((ref) {
  return CancelOrder(ref.read(adminOrderRepositoryProvider));
});

final getOrderQueueUseCaseProvider = Provider((ref) {
  return GetOrderQueue(ref.read(adminOrderRepositoryProvider));
});

final getOrdersAnalyticsUseCaseProvider = Provider((ref) {
  return GetOrdersAnalytics(ref.read(adminOrderRepositoryProvider));
});

final searchOrdersUseCaseProvider = Provider((ref) {
  return SearchOrders(ref.read(adminOrderRepositoryProvider));
});

final bulkUpdateOrderStatusUseCaseProvider = Provider((ref) {
  return BulkUpdateOrderStatus(ref.read(adminOrderRepositoryProvider));
});

// Shipping Use Case Providers
final getShipmentsUseCaseProvider = Provider((ref) {
  return GetShipments(ref.read(adminOrderRepositoryProvider));
});

final getShipmentByIdUseCaseProvider = Provider((ref) {
  return GetShipmentById(ref.read(adminOrderRepositoryProvider));
});

final getShipmentsByOrderUseCaseProvider = Provider((ref) {
  return GetShipmentsByOrder(ref.read(adminOrderRepositoryProvider));
});

final createShipmentUseCaseProvider = Provider((ref) {
  return CreateShipment(ref.read(adminOrderRepositoryProvider));
});

final updateShipmentStatusUseCaseProvider = Provider((ref) {
  return UpdateShipmentStatus(ref.read(adminOrderRepositoryProvider));
});

final addTrackingNumberUseCaseProvider = Provider((ref) {
  return AddTrackingNumber(ref.read(adminOrderRepositoryProvider));
});

final addTrackingEventUseCaseProvider = Provider((ref) {
  return AddTrackingEvent(ref.read(adminOrderRepositoryProvider));
});

final updateShipmentTrackingUseCaseProvider = Provider((ref) {
  return UpdateShipmentTracking(ref.read(adminOrderRepositoryProvider));
});

final getShippingCarriersUseCaseProvider = Provider((ref) {
  return GetShippingCarriers(ref.read(adminOrderRepositoryProvider));
});

final getActiveShipmentsUseCaseProvider = Provider((ref) {
  return GetActiveShipments(ref.read(adminOrderRepositoryProvider));
});

final getDelayedShipmentsUseCaseProvider = Provider((ref) {
  return GetDelayedShipments(ref.read(adminOrderRepositoryProvider));
});

final getShippingAnalyticsUseCaseProvider = Provider((ref) {
  return GetShippingAnalytics(ref.read(adminOrderRepositoryProvider));
});

final searchShipmentsUseCaseProvider = Provider((ref) {
  return SearchShipments(ref.read(adminOrderRepositoryProvider));
});

final shipOrderUseCaseProvider = Provider((ref) {
  return ShipOrder(ref.read(adminOrderRepositoryProvider));
});

// Communication Use Case Providers
final sendOrderConfirmationUseCaseProvider = Provider((ref) {
  return SendOrderConfirmation(ref.read(adminOrderRepositoryProvider));
});

final sendShippingNotificationUseCaseProvider = Provider((ref) {
  return SendShippingNotification(ref.read(adminOrderRepositoryProvider));
});

final sendDeliveryNotificationUseCaseProvider = Provider((ref) {
  return SendDeliveryNotification(ref.read(adminOrderRepositoryProvider));
});

final sendOrderStatusUpdateUseCaseProvider = Provider((ref) {
  return SendOrderStatusUpdate(ref.read(adminOrderRepositoryProvider));
});

final sendCustomMessageUseCaseProvider = Provider((ref) {
  return SendCustomMessage(ref.read(adminOrderRepositoryProvider));
});

final getOrderCommunicationsUseCaseProvider = Provider((ref) {
  return GetOrderCommunications(ref.read(adminOrderRepositoryProvider));
});

final logCommunicationUseCaseProvider = Provider((ref) {
  return LogCommunication(ref.read(adminOrderRepositoryProvider));
});

final sendBulkOrderUpdatesUseCaseProvider = Provider((ref) {
  return SendBulkOrderUpdates(ref.read(adminOrderRepositoryProvider));
});

final sendAutomatedNotificationsUseCaseProvider = Provider((ref) {
  return SendAutomatedNotifications(ref.read(adminOrderRepositoryProvider));
});

final getCommunicationTemplatesUseCaseProvider = Provider((ref) {
  return GetCommunicationTemplates(ref.read(adminOrderRepositoryProvider));
});

// State providers for UI
class OrdersListState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const OrdersListState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  OrdersListState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return OrdersListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Orders list provider
final ordersListProvider =
    StateNotifierProvider<OrdersListNotifier, AsyncValue<OrdersListState>>((
      ref,
    ) {
      return OrdersListNotifier(ref);
    });

class OrdersListNotifier extends StateNotifier<AsyncValue<OrdersListState>> {
  final Ref _ref;

  OrdersListNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> loadOrders({
    String? searchQuery,
    OrderStatus? status,
    OrderPriority? priority,
    PaymentStatus? paymentStatus,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    bool sortDescending = false,
    bool refresh = false,
  }) async {
    try {
      final currentState = state.value;
      final page = refresh ? 1 : (currentState?.currentPage ?? 1);

      if (refresh) {
        state = const AsyncValue.loading();
      } else if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(isLoading: true));
      }

      final getOrdersUseCase = _ref.read(getOrdersUseCaseProvider);
      final params = GetOrdersParams(
        searchQuery: searchQuery,
        status: status,
        priority: priority,
        paymentStatus: paymentStatus,
        assignedTo: assignedTo,
        startDate: startDate,
        endDate: endDate,
        sortBy: sortBy,
        sortDescending: sortDescending,
        page: page,
        limit: 20,
      );

      final newOrders = await getOrdersUseCase(params);

      final existingOrders = refresh ? <Order>[] : (currentState?.orders ?? []);
      final allOrders = [...existingOrders, ...newOrders];

      state = AsyncValue.data(
        OrdersListState(
          orders: allOrders,
          isLoading: false,
          hasMore: newOrders.length >= 20,
          currentPage: page + 1,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshOrders({
    String? searchQuery,
    OrderStatus? status,
    OrderPriority? priority,
    PaymentStatus? paymentStatus,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    bool sortDescending = false,
  }) async {
    return loadOrders(
      searchQuery: searchQuery,
      status: status,
      priority: priority,
      paymentStatus: paymentStatus,
      assignedTo: assignedTo,
      startDate: startDate,
      endDate: endDate,
      sortBy: sortBy,
      sortDescending: sortDescending,
      refresh: true,
    );
  }

  Future<void> loadMoreOrders() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoading) {
      return;
    }

    await loadOrders();
  }
}

// Individual data providers
final ordersAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final getOrdersAnalyticsUseCase = ref.read(getOrdersAnalyticsUseCaseProvider);
  return await getOrdersAnalyticsUseCase();
});

final orderQueueProvider = FutureProvider<List<Order>>((ref) async {
  final getOrderQueueUseCase = ref.read(getOrderQueueUseCaseProvider);
  return await getOrderQueueUseCase();
});

final shippingAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final getShippingAnalyticsUseCase = ref.read(
    getShippingAnalyticsUseCaseProvider,
  );
  return await getShippingAnalyticsUseCase();
});

final activeShipmentsProvider = FutureProvider<List<Shipment>>((ref) async {
  final getActiveShipmentsUseCase = ref.read(getActiveShipmentsUseCaseProvider);
  return await getActiveShipmentsUseCase();
});

final delayedShipmentsProvider = FutureProvider<List<Shipment>>((ref) async {
  final getDelayedShipmentsUseCase = ref.read(
    getDelayedShipmentsUseCaseProvider,
  );
  return await getDelayedShipmentsUseCase();
});

final shippingCarriersProvider = FutureProvider<List<ShippingCarrier>>((
  ref,
) async {
  final getShippingCarriersUseCase = ref.read(
    getShippingCarriersUseCaseProvider,
  );
  return await getShippingCarriersUseCase();
});

final communicationTemplatesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final getCommunicationTemplatesUseCase = ref.read(
        getCommunicationTemplatesUseCaseProvider,
      );
      return await getCommunicationTemplatesUseCase();
    });

// Order details provider
final orderDetailsProvider = FutureProvider.family<Order?, String>((
  ref,
  orderId,
) async {
  final getOrderByIdUseCase = ref.read(getOrderByIdUseCaseProvider);
  return await getOrderByIdUseCase(orderId);
});

// Shipment details provider
final shipmentDetailsProvider = FutureProvider.family<Shipment?, String>((
  ref,
  shipmentId,
) async {
  final getShipmentByIdUseCase = ref.read(getShipmentByIdUseCaseProvider);
  return await getShipmentByIdUseCase(shipmentId);
});

// Order shipments provider
final orderShipmentsProvider = FutureProvider.family<List<Shipment>, String>((
  ref,
  orderId,
) async {
  final getShipmentsByOrderUseCase = ref.read(
    getShipmentsByOrderUseCaseProvider,
  );
  return await getShipmentsByOrderUseCase(orderId);
});

// Order communications provider
final orderCommunicationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      orderId,
    ) async {
      final getOrderCommunicationsUseCase = ref.read(
        getOrderCommunicationsUseCaseProvider,
      );
      return await getOrderCommunicationsUseCase(orderId);
    });

// Order by number provider
final orderByNumberProvider = FutureProvider.family<Order?, String>((
  ref,
  orderNumber,
) async {
  final getOrderByNumberUseCase = ref.read(getOrderByNumberUseCaseProvider);
  return await getOrderByNumberUseCase(orderNumber);
});
