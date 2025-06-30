import 'package:equatable/equatable.dart';
import 'order_item.dart';
import 'shipment.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
  returned
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
  partiallyRefunded
}

enum PaymentMethod {
  creditCard,
  debitCard,
  mobileMoney,
  bankTransfer,
  cash,
  wallet
}

class ShippingAddress extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final bool isDefault;

  const ShippingAddress({
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
        fullName,
        phoneNumber,
        addressLine1,
        addressLine2,
        city,
        region,
        postalCode,
        country,
        isDefault,
      ];
}

class Order extends Equatable {
  final String id;
  final String userId;
  final String orderNumber;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingCost;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final ShippingAddress shippingAddress;
  final ShippingAddress? billingAddress;
  final String? notes;
  final String? couponCode;
  final DateTime orderDate;
  final DateTime? estimatedDeliveryDate;
  final DateTime? deliveredDate;
  final DateTime? cancelledDate;
  final String? cancellationReason;
  final List<Shipment> shipments;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.currency,
    required this.shippingAddress,
    this.billingAddress,
    this.notes,
    this.couponCode,
    required this.orderDate,
    this.estimatedDeliveryDate,
    this.deliveredDate,
    this.cancelledDate,
    this.cancellationReason,
    required this.shipments,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;
  
  bool get canBeReturned => status == OrderStatus.delivered && 
      deliveredDate != null && 
      DateTime.now().difference(deliveredDate!).inDays <= 30;

  bool get isCompleted => status == OrderStatus.delivered;
  
  bool get isCancelled => status == OrderStatus.cancelled;

  double get finalAmount => totalAmount;

  @override
  List<Object?> get props => [
        id,
        userId,
        orderNumber,
        status,
        paymentStatus,
        paymentMethod,
        items,
        subtotal,
        shippingCost,
        taxAmount,
        discountAmount,
        totalAmount,
        currency,
        shippingAddress,
        billingAddress,
        notes,
        couponCode,
        orderDate,
        estimatedDeliveryDate,
        deliveredDate,
        cancelledDate,
        cancellationReason,
        shipments,
        metadata,
        createdAt,
        updatedAt,
      ];
}
