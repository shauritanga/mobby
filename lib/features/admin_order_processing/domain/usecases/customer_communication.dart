import '../entities/order.dart';
import '../entities/shipment.dart';
import '../repositories/admin_order_repository.dart';

class SendOrderConfirmation {
  final AdminOrderRepository repository;

  SendOrderConfirmation(this.repository);

  Future<void> call(String orderId) async {
    // Validate order exists
    final order = await repository.getOrderById(orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    // Send order confirmation
    await repository.sendOrderConfirmation(orderId);

    // Log communication
    await repository.logCommunication(
      orderId,
      'email',
      'Order Confirmation',
      'Order confirmation email sent to customer',
      metadata: {
        'orderNumber': order.orderNumber,
        'customerEmail': order.customerEmail,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

class SendShippingNotificationParams {
  final String orderId;
  final String shipmentId;
  final String? customMessage;

  const SendShippingNotificationParams({
    required this.orderId,
    required this.shipmentId,
    this.customMessage,
  });
}

class SendShippingNotification {
  final AdminOrderRepository repository;

  SendShippingNotification(this.repository);

  Future<void> call(SendShippingNotificationParams params) async {
    // Validate order and shipment exist
    final order = await repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    final shipment = await repository.getShipmentById(params.shipmentId);
    if (shipment == null) {
      throw Exception('Shipment not found');
    }

    // Send shipping notification
    await repository.sendShippingNotification(
      params.orderId,
      params.shipmentId,
    );

    // Log communication
    await repository.logCommunication(
      params.orderId,
      'email',
      'Shipping Notification',
      params.customMessage ?? 'Shipping notification email sent to customer',
      metadata: {
        'orderNumber': order.orderNumber,
        'shipmentId': params.shipmentId,
        'trackingNumber': shipment.trackingNumber,
        'carrier': shipment.carrier.name,
        'customerEmail': order.customerEmail,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

class SendDeliveryNotificationParams {
  final String orderId;
  final String shipmentId;
  final String? customMessage;

  const SendDeliveryNotificationParams({
    required this.orderId,
    required this.shipmentId,
    this.customMessage,
  });
}

class SendDeliveryNotification {
  final AdminOrderRepository repository;

  SendDeliveryNotification(this.repository);

  Future<void> call(SendDeliveryNotificationParams params) async {
    // Validate order and shipment exist
    final order = await repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    final shipment = await repository.getShipmentById(params.shipmentId);
    if (shipment == null) {
      throw Exception('Shipment not found');
    }

    // Validate shipment is delivered
    if (shipment.status != ShipmentStatus.delivered) {
      throw Exception('Shipment is not delivered');
    }

    // Send delivery notification
    await repository.sendDeliveryNotification(
      params.orderId,
      params.shipmentId,
    );

    // Log communication
    await repository.logCommunication(
      params.orderId,
      'email',
      'Delivery Notification',
      params.customMessage ?? 'Delivery notification email sent to customer',
      metadata: {
        'orderNumber': order.orderNumber,
        'shipmentId': params.shipmentId,
        'deliveryDate': shipment.actualDelivery?.toIso8601String(),
        'customerEmail': order.customerEmail,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

class SendOrderStatusUpdateParams {
  final String orderId;
  final OrderStatus status;
  final String? customMessage;

  const SendOrderStatusUpdateParams({
    required this.orderId,
    required this.status,
    this.customMessage,
  });
}

class SendOrderStatusUpdate {
  final AdminOrderRepository repository;

  SendOrderStatusUpdate(this.repository);

  Future<void> call(SendOrderStatusUpdateParams params) async {
    // Validate order exists
    final order = await repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    // Send status update
    await repository.sendOrderStatusUpdate(
      params.orderId,
      params.status,
      message: params.customMessage,
    );

    // Log communication
    await repository.logCommunication(
      params.orderId,
      'email',
      'Order Status Update',
      params.customMessage ??
          'Order status update sent to customer: ${params.status.displayName}',
      metadata: {
        'orderNumber': order.orderNumber,
        'previousStatus': order.status.name,
        'newStatus': params.status.name,
        'customerEmail': order.customerEmail,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

class SendCustomMessageParams {
  final String orderId;
  final String subject;
  final String message;
  final String? communicationType;

  const SendCustomMessageParams({
    required this.orderId,
    required this.subject,
    required this.message,
    this.communicationType = 'email',
  });
}

class SendCustomMessage {
  final AdminOrderRepository repository;

  SendCustomMessage(this.repository);

  Future<void> call(SendCustomMessageParams params) async {
    // Validate order exists
    final order = await repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    // Validate message content
    if (params.subject.trim().isEmpty) {
      throw Exception('Subject cannot be empty');
    }

    if (params.message.trim().isEmpty) {
      throw Exception('Message cannot be empty');
    }

    // Send custom message
    await repository.sendCustomMessage(
      params.orderId,
      params.subject,
      params.message,
    );

    // Log communication
    await repository.logCommunication(
      params.orderId,
      params.communicationType ?? 'email',
      params.subject,
      params.message,
      metadata: {
        'orderNumber': order.orderNumber,
        'customerEmail': order.customerEmail,
        'messageLength': params.message.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

class GetOrderCommunications {
  final AdminOrderRepository repository;

  GetOrderCommunications(this.repository);

  Future<List<Map<String, dynamic>>> call(String orderId) async {
    // Validate order exists
    final order = await repository.getOrderById(orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    return await repository.getOrderCommunications(orderId);
  }
}

class LogCommunicationParams {
  final String orderId;
  final String type;
  final String subject;
  final String message;
  final Map<String, dynamic>? metadata;

  const LogCommunicationParams({
    required this.orderId,
    required this.type,
    required this.subject,
    required this.message,
    this.metadata,
  });
}

class LogCommunication {
  final AdminOrderRepository repository;

  LogCommunication(this.repository);

  Future<void> call(LogCommunicationParams params) async {
    await repository.logCommunication(
      params.orderId,
      params.type,
      params.subject,
      params.message,
      metadata: params.metadata,
    );
  }
}

class SendBulkOrderUpdatesParams {
  final List<String> orderIds;
  final String subject;
  final String message;
  final String? communicationType;

  const SendBulkOrderUpdatesParams({
    required this.orderIds,
    required this.subject,
    required this.message,
    this.communicationType = 'email',
  });
}

class SendBulkOrderUpdates {
  final AdminOrderRepository repository;

  SendBulkOrderUpdates(this.repository);

  Future<void> call(SendBulkOrderUpdatesParams params) async {
    // Validate input
    if (params.orderIds.isEmpty) {
      throw Exception('No orders selected');
    }

    if (params.subject.trim().isEmpty) {
      throw Exception('Subject cannot be empty');
    }

    if (params.message.trim().isEmpty) {
      throw Exception('Message cannot be empty');
    }

    // Send messages to all orders
    final results = <String, bool>{};

    for (final orderId in params.orderIds) {
      try {
        final sendCustomMessage = SendCustomMessage(repository);
        await sendCustomMessage(
          SendCustomMessageParams(
            orderId: orderId,
            subject: params.subject,
            message: params.message,
            communicationType: params.communicationType,
          ),
        );
        results[orderId] = true;
      } catch (e) {
        results[orderId] = false;
        // Log error but continue with other orders
        print('Failed to send message to order $orderId: $e');
      }
    }

    // Check if any messages failed
    final failedCount = results.values.where((success) => !success).length;
    if (failedCount > 0) {
      throw Exception(
        'Failed to send messages to $failedCount out of ${params.orderIds.length} orders',
      );
    }
  }
}

class SendAutomatedNotificationsParams {
  final String orderId;
  final String trigger;
  final Map<String, dynamic>? context;

  const SendAutomatedNotificationsParams({
    required this.orderId,
    required this.trigger,
    this.context,
  });
}

class SendAutomatedNotifications {
  final AdminOrderRepository repository;

  SendAutomatedNotifications(this.repository);

  Future<void> call(SendAutomatedNotificationsParams params) async {
    // Get order details
    final order = await repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    // Handle different notification triggers
    switch (params.trigger) {
      case 'order_confirmed':
        final sendConfirmation = SendOrderConfirmation(repository);
        await sendConfirmation(params.orderId);
        break;

      case 'order_shipped':
        final shipmentId = params.context?['shipmentId'] as String?;
        if (shipmentId != null) {
          final sendShipping = SendShippingNotification(repository);
          await sendShipping(
            SendShippingNotificationParams(
              orderId: params.orderId,
              shipmentId: shipmentId,
            ),
          );
        }
        break;

      case 'order_delivered':
        final shipmentId = params.context?['shipmentId'] as String?;
        if (shipmentId != null) {
          final sendDelivery = SendDeliveryNotification(repository);
          await sendDelivery(
            SendDeliveryNotificationParams(
              orderId: params.orderId,
              shipmentId: shipmentId,
            ),
          );
        }
        break;

      case 'order_cancelled':
        final sendStatusUpdate = SendOrderStatusUpdate(repository);
        await sendStatusUpdate(
          SendOrderStatusUpdateParams(
            orderId: params.orderId,
            status: OrderStatus.cancelled,
            customMessage: params.context?['reason'] as String?,
          ),
        );
        break;

      case 'payment_failed':
        final sendCustomMessage = SendCustomMessage(repository);
        await sendCustomMessage(
          SendCustomMessageParams(
            orderId: params.orderId,
            subject: 'Payment Issue - Order ${order.orderNumber}',
            message:
                'We encountered an issue processing your payment. Please update your payment method to complete your order.',
          ),
        );
        break;

      default:
        throw Exception('Unknown notification trigger: ${params.trigger}');
    }
  }
}

class GetCommunicationTemplates {
  final AdminOrderRepository repository;

  GetCommunicationTemplates(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    // Return predefined communication templates
    return [
      {
        'id': 'order_delay',
        'name': 'Order Delay Notification',
        'subject': 'Update on Your Order #{orderNumber}',
        'template':
            'We wanted to update you on your recent order. Due to high demand, your order will be delayed by approximately {delayDays} days. We apologize for any inconvenience and appreciate your patience.',
        'variables': ['orderNumber', 'delayDays'],
      },
      {
        'id': 'back_in_stock',
        'name': 'Back in Stock Notification',
        'subject': 'Good News! Your Order is Ready',
        'template':
            'Great news! The items in your order #{orderNumber} are now back in stock and ready to ship. We will process your order within the next 24 hours.',
        'variables': ['orderNumber'],
      },
      {
        'id': 'delivery_attempt',
        'name': 'Delivery Attempt Failed',
        'subject': 'Delivery Attempt for Order #{orderNumber}',
        'template':
            'We attempted to deliver your order #{orderNumber} but were unable to complete the delivery. Please contact our shipping partner or visit their website to reschedule delivery.',
        'variables': ['orderNumber', 'trackingNumber'],
      },
      {
        'id': 'customer_satisfaction',
        'name': 'Customer Satisfaction Survey',
        'subject': 'How was your experience with Order #{orderNumber}?',
        'template':
            'Thank you for your recent order! We would love to hear about your experience. Please take a moment to share your feedback.',
        'variables': ['orderNumber'],
      },
    ];
  }
}
