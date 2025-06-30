import '../../domain/entities/return.dart';

class ReturnItemModel extends ReturnItem {
  const ReturnItemModel({
    required super.orderItemId,
    required super.productId,
    required super.productName,
    required super.productSku,
    required super.quantityToReturn,
    required super.unitPrice,
    required super.refundAmount,
    required super.reason,
    super.notes,
    super.images = const [],
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnItemModel(
      orderItemId: json['orderItemId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String,
      quantityToReturn: json['quantityToReturn'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      refundAmount: (json['refundAmount'] as num).toDouble(),
      reason: ReturnReason.values.byName(json['reason'] as String),
      notes: json['notes'] as String?,
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderItemId': orderItemId,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'quantityToReturn': quantityToReturn,
      'unitPrice': unitPrice,
      'refundAmount': refundAmount,
      'reason': reason.name,
      'notes': notes,
      'images': images,
    };
  }

  factory ReturnItemModel.fromEntity(ReturnItem item) {
    return ReturnItemModel(
      orderItemId: item.orderItemId,
      productId: item.productId,
      productName: item.productName,
      productSku: item.productSku,
      quantityToReturn: item.quantityToReturn,
      unitPrice: item.unitPrice,
      refundAmount: item.refundAmount,
      reason: item.reason,
      notes: item.notes,
      images: item.images,
    );
  }

  ReturnItem toEntity() => this;
}

class ReturnModel extends Return {
  const ReturnModel({
    required super.id,
    required super.orderId,
    required super.userId,
    required super.returnNumber,
    required super.status,
    required super.items,
    required super.totalRefundAmount,
    required super.refundMethod,
    required super.currency,
    super.customerNotes,
    super.adminNotes,
    super.images = const [],
    required super.requestDate,
    super.approvedDate,
    super.rejectedDate,
    super.shippedDate,
    super.receivedDate,
    super.completedDate,
    super.rejectionReason,
    super.trackingNumber,
    super.refundTransactionId,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    return ReturnModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      returnNumber: json['returnNumber'] as String,
      status: ReturnStatus.values.byName(json['status'] as String),
      items: [], // Simplified for now
      totalRefundAmount: (json['totalRefundAmount'] as num).toDouble(),
      refundMethod: RefundMethod.values.byName(json['refundMethod'] as String),
      currency: json['currency'] as String,
      customerNotes: json['customerNotes'] as String?,
      adminNotes: json['adminNotes'] as String?,
      images: List<String>.from(json['images'] ?? []),
      requestDate: DateTime.parse(json['requestDate'] as String),
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'] as String)
          : null,
      rejectedDate: json['rejectedDate'] != null
          ? DateTime.parse(json['rejectedDate'] as String)
          : null,
      shippedDate: json['shippedDate'] != null
          ? DateTime.parse(json['shippedDate'] as String)
          : null,
      receivedDate: json['receivedDate'] != null
          ? DateTime.parse(json['receivedDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'returnNumber': returnNumber,
      'status': status.name,
      'totalRefundAmount': totalRefundAmount,
      'refundMethod': refundMethod.name,
      'currency': currency,
      'customerNotes': customerNotes,
      'adminNotes': adminNotes,
      'images': images,
      'requestDate': requestDate.toIso8601String(),
      'approvedDate': approvedDate?.toIso8601String(),
      'rejectedDate': rejectedDate?.toIso8601String(),
      'shippedDate': shippedDate?.toIso8601String(),
      'receivedDate': receivedDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'trackingNumber': trackingNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReturnModel.fromEntity(Return returnRequest) {
    return ReturnModel(
      id: returnRequest.id,
      orderId: returnRequest.orderId,
      userId: returnRequest.userId,
      returnNumber: returnRequest.returnNumber,
      status: returnRequest.status,
      items: returnRequest.items,
      totalRefundAmount: returnRequest.totalRefundAmount,
      refundMethod: returnRequest.refundMethod,
      currency: returnRequest.currency,
      customerNotes: returnRequest.customerNotes,
      adminNotes: returnRequest.adminNotes,
      images: returnRequest.images,
      requestDate: returnRequest.requestDate,
      approvedDate: returnRequest.approvedDate,
      rejectedDate: returnRequest.rejectedDate,
      shippedDate: returnRequest.shippedDate,
      receivedDate: returnRequest.receivedDate,
      completedDate: returnRequest.completedDate,
      rejectionReason: returnRequest.rejectionReason,
      trackingNumber: returnRequest.trackingNumber,
      refundTransactionId: returnRequest.refundTransactionId,
      metadata: returnRequest.metadata,
      createdAt: returnRequest.createdAt,
      updatedAt: returnRequest.updatedAt,
    );
  }

  Return toEntity() => this;
}
