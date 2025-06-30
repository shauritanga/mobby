import 'package:equatable/equatable.dart';

enum InventoryMovementType {
  stockIn,
  stockOut,
  adjustment,
  sale,
  returned,
  damaged,
  expired,
  transfer,
}

enum InventoryStatus { available, reserved, damaged, expired, returned }

class InventoryMovement extends Equatable {
  final String id;
  final String productId;
  final String? variantId;
  final InventoryMovementType type;
  final int quantity;
  final int previousQuantity;
  final int newQuantity;
  final String reason;
  final String? reference; // Order ID, Transfer ID, etc.
  final double? unitCost;
  final String? notes;
  final String performedBy;
  final String performedByName;
  final DateTime timestamp;

  const InventoryMovement({
    required this.id,
    required this.productId,
    this.variantId,
    required this.type,
    required this.quantity,
    required this.previousQuantity,
    required this.newQuantity,
    required this.reason,
    this.reference,
    this.unitCost,
    this.notes,
    required this.performedBy,
    required this.performedByName,
    required this.timestamp,
  });

  bool get isIncrease =>
      type == InventoryMovementType.stockIn ||
      type == InventoryMovementType.returned;

  bool get isDecrease =>
      type == InventoryMovementType.stockOut ||
      type == InventoryMovementType.sale ||
      type == InventoryMovementType.damaged ||
      type == InventoryMovementType.expired;

  String get typeDisplayName {
    switch (type) {
      case InventoryMovementType.stockIn:
        return 'Stock In';
      case InventoryMovementType.stockOut:
        return 'Stock Out';
      case InventoryMovementType.adjustment:
        return 'Adjustment';
      case InventoryMovementType.sale:
        return 'Sale';
      case InventoryMovementType.returned:
        return 'Return';
      case InventoryMovementType.damaged:
        return 'Damaged';
      case InventoryMovementType.expired:
        return 'Expired';
      case InventoryMovementType.transfer:
        return 'Transfer';
    }
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    variantId,
    type,
    quantity,
    previousQuantity,
    newQuantity,
    reason,
    reference,
    unitCost,
    notes,
    performedBy,
    performedByName,
    timestamp,
  ];
}

class InventoryLocation extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String address;
  final bool isDefault;
  final bool isActive;

  const InventoryLocation({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.address,
    this.isDefault = false,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    description,
    address,
    isDefault,
    isActive,
  ];
}

class Inventory extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productSku;
  final String? variantId;
  final String? variantName;
  final String locationId;
  final String locationName;
  final int quantity;
  final int reservedQuantity;
  final int availableQuantity;
  final int? reorderPoint;
  final int? maxStockLevel;
  final double averageCost;
  final double totalValue;
  final InventoryStatus status;
  final DateTime? lastStockIn;
  final DateTime? lastStockOut;
  final List<InventoryMovement> recentMovements;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Inventory({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    this.variantId,
    this.variantName,
    required this.locationId,
    required this.locationName,
    required this.quantity,
    this.reservedQuantity = 0,
    required this.availableQuantity,
    this.reorderPoint,
    this.maxStockLevel,
    required this.averageCost,
    required this.totalValue,
    required this.status,
    this.lastStockIn,
    this.lastStockOut,
    required this.recentMovements,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isInStock => availableQuantity > 0;
  bool get isLowStock =>
      reorderPoint != null && availableQuantity <= reorderPoint!;
  bool get isOverStock => maxStockLevel != null && quantity >= maxStockLevel!;
  bool get hasReservedStock => reservedQuantity > 0;

  double get turnoverRate {
    // Simplified calculation - would need sales data for accurate calculation
    return totalValue > 0 ? (averageCost * quantity) / totalValue : 0.0;
  }

  String get stockLevel {
    if (!isInStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    if (isOverStock) return 'Overstock';
    return 'In Stock';
  }

  String get statusDisplayName {
    switch (status) {
      case InventoryStatus.available:
        return 'Available';
      case InventoryStatus.reserved:
        return 'Reserved';
      case InventoryStatus.damaged:
        return 'Damaged';
      case InventoryStatus.expired:
        return 'Expired';
      case InventoryStatus.returned:
        return 'Returned';
    }
  }

  Inventory copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productSku,
    String? variantId,
    String? variantName,
    String? locationId,
    String? locationName,
    int? quantity,
    int? reservedQuantity,
    int? availableQuantity,
    int? reorderPoint,
    int? maxStockLevel,
    double? averageCost,
    double? totalValue,
    InventoryStatus? status,
    DateTime? lastStockIn,
    DateTime? lastStockOut,
    List<InventoryMovement>? recentMovements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Inventory(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      variantId: variantId ?? this.variantId,
      variantName: variantName ?? this.variantName,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      quantity: quantity ?? this.quantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      averageCost: averageCost ?? this.averageCost,
      totalValue: totalValue ?? this.totalValue,
      status: status ?? this.status,
      lastStockIn: lastStockIn ?? this.lastStockIn,
      lastStockOut: lastStockOut ?? this.lastStockOut,
      recentMovements: recentMovements ?? this.recentMovements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    productSku,
    variantId,
    variantName,
    locationId,
    locationName,
    quantity,
    reservedQuantity,
    availableQuantity,
    reorderPoint,
    maxStockLevel,
    averageCost,
    totalValue,
    status,
    lastStockIn,
    lastStockOut,
    recentMovements,
    createdAt,
    updatedAt,
  ];
}
