import 'package:equatable/equatable.dart';

enum ReturnStatus {
  requested,
  approved,
  rejected,
  processing,
  shipped,
  received,
  inspecting,
  completed,
  cancelled
}

enum ReturnReason {
  defective,
  wrongItem,
  notAsDescribed,
  damagedInShipping,
  changedMind,
  sizeIssue,
  qualityIssue,
  other
}

enum RefundMethod {
  originalPayment,
  storeCredit,
  bankTransfer,
  mobileMoney,
  cash
}

class ReturnItem extends Equatable {
  final String orderItemId;
  final String productId;
  final String productName;
  final String productSku;
  final int quantityToReturn;
  final double unitPrice;
  final double refundAmount;
  final ReturnReason reason;
  final String? notes;
  final List<String> images;

  const ReturnItem({
    required this.orderItemId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantityToReturn,
    required this.unitPrice,
    required this.refundAmount,
    required this.reason,
    this.notes,
    this.images = const [],
  });

  @override
  List<Object?> get props => [
        orderItemId,
        productId,
        productName,
        productSku,
        quantityToReturn,
        unitPrice,
        refundAmount,
        reason,
        notes,
        images,
      ];
}

class Return extends Equatable {
  final String id;
  final String orderId;
  final String userId;
  final String returnNumber;
  final ReturnStatus status;
  final List<ReturnItem> items;
  final double totalRefundAmount;
  final RefundMethod refundMethod;
  final String currency;
  final String? customerNotes;
  final String? adminNotes;
  final List<String> images;
  final DateTime requestDate;
  final DateTime? approvedDate;
  final DateTime? rejectedDate;
  final DateTime? shippedDate;
  final DateTime? receivedDate;
  final DateTime? completedDate;
  final String? rejectionReason;
  final String? trackingNumber;
  final String? refundTransactionId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Return({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.returnNumber,
    required this.status,
    required this.items,
    required this.totalRefundAmount,
    required this.refundMethod,
    required this.currency,
    this.customerNotes,
    this.adminNotes,
    this.images = const [],
    required this.requestDate,
    this.approvedDate,
    this.rejectedDate,
    this.shippedDate,
    this.receivedDate,
    this.completedDate,
    this.rejectionReason,
    this.trackingNumber,
    this.refundTransactionId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isApproved => status == ReturnStatus.approved;
  
  bool get isRejected => status == ReturnStatus.rejected;
  
  bool get isCompleted => status == ReturnStatus.completed;
  
  bool get canBeCancelled => status == ReturnStatus.requested || 
                            status == ReturnStatus.approved;

  bool get isInProgress => status == ReturnStatus.processing || 
                          status == ReturnStatus.shipped || 
                          status == ReturnStatus.received || 
                          status == ReturnStatus.inspecting;

  @override
  List<Object?> get props => [
        id,
        orderId,
        userId,
        returnNumber,
        status,
        items,
        totalRefundAmount,
        refundMethod,
        currency,
        customerNotes,
        adminNotes,
        images,
        requestDate,
        approvedDate,
        rejectedDate,
        shippedDate,
        receivedDate,
        completedDate,
        rejectionReason,
        trackingNumber,
        refundTransactionId,
        metadata,
        createdAt,
        updatedAt,
      ];
}
