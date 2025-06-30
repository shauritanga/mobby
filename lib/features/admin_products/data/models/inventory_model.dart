import '../../domain/entities/inventory.dart';

class InventoryMovementModel {
  final String id;
  final String productId;
  final String? variantId;
  final InventoryMovementType type;
  final int quantity;
  final int previousQuantity;
  final int newQuantity;
  final String reason;
  final String? reference;
  final double? unitCost;
  final String? notes;
  final String performedBy;
  final String performedByName;
  final DateTime timestamp;

  const InventoryMovementModel({
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

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    return InventoryMovementModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      variantId: json['variantId'] as String?,
      type: InventoryMovementType.values.firstWhere((e) => e.name == json['type']),
      quantity: json['quantity'] as int,
      previousQuantity: json['previousQuantity'] as int,
      newQuantity: json['newQuantity'] as int,
      reason: json['reason'] as String,
      reference: json['reference'] as String?,
      unitCost: json['unitCost'] != null ? (json['unitCost'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      performedBy: json['performedBy'] as String,
      performedByName: json['performedByName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'variantId': variantId,
      'type': type.name,
      'quantity': quantity,
      'previousQuantity': previousQuantity,
      'newQuantity': newQuantity,
      'reason': reason,
      'reference': reference,
      'unitCost': unitCost,
      'notes': notes,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory InventoryMovementModel.fromEntity(InventoryMovement movement) {
    return InventoryMovementModel(
      id: movement.id,
      productId: movement.productId,
      variantId: movement.variantId,
      type: movement.type,
      quantity: movement.quantity,
      previousQuantity: movement.previousQuantity,
      newQuantity: movement.newQuantity,
      reason: movement.reason,
      reference: movement.reference,
      unitCost: movement.unitCost,
      notes: movement.notes,
      performedBy: movement.performedBy,
      performedByName: movement.performedByName,
      timestamp: movement.timestamp,
    );
  }

  InventoryMovement toEntity() {
    return InventoryMovement(
      id: id,
      productId: productId,
      variantId: variantId,
      type: type,
      quantity: quantity,
      previousQuantity: previousQuantity,
      newQuantity: newQuantity,
      reason: reason,
      reference: reference,
      unitCost: unitCost,
      notes: notes,
      performedBy: performedBy,
      performedByName: performedByName,
      timestamp: timestamp,
    );
  }
}

class InventoryLocationModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String address;
  final bool isDefault;
  final bool isActive;

  const InventoryLocationModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.address,
    this.isDefault = false,
    this.isActive = true,
  });

  factory InventoryLocationModel.fromJson(Map<String, dynamic> json) {
    return InventoryLocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'address': address,
      'isDefault': isDefault,
      'isActive': isActive,
    };
  }

  factory InventoryLocationModel.fromEntity(InventoryLocation location) {
    return InventoryLocationModel(
      id: location.id,
      name: location.name,
      code: location.code,
      description: location.description,
      address: location.address,
      isDefault: location.isDefault,
      isActive: location.isActive,
    );
  }

  InventoryLocation toEntity() {
    return InventoryLocation(
      id: id,
      name: name,
      code: code,
      description: description,
      address: address,
      isDefault: isDefault,
      isActive: isActive,
    );
  }
}

class InventoryModel {
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
  final List<InventoryMovementModel> recentMovements;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryModel({
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

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String,
      variantId: json['variantId'] as String?,
      variantName: json['variantName'] as String?,
      locationId: json['locationId'] as String,
      locationName: json['locationName'] as String,
      quantity: json['quantity'] as int,
      reservedQuantity: json['reservedQuantity'] as int? ?? 0,
      availableQuantity: json['availableQuantity'] as int,
      reorderPoint: json['reorderPoint'] as int?,
      maxStockLevel: json['maxStockLevel'] as int?,
      averageCost: (json['averageCost'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      status: InventoryStatus.values.firstWhere((e) => e.name == json['status']),
      lastStockIn: json['lastStockIn'] != null ? DateTime.parse(json['lastStockIn'] as String) : null,
      lastStockOut: json['lastStockOut'] != null ? DateTime.parse(json['lastStockOut'] as String) : null,
      recentMovements: (json['recentMovements'] as List? ?? [])
          .map((m) => InventoryMovementModel.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'variantId': variantId,
      'variantName': variantName,
      'locationId': locationId,
      'locationName': locationName,
      'quantity': quantity,
      'reservedQuantity': reservedQuantity,
      'availableQuantity': availableQuantity,
      'reorderPoint': reorderPoint,
      'maxStockLevel': maxStockLevel,
      'averageCost': averageCost,
      'totalValue': totalValue,
      'status': status.name,
      'lastStockIn': lastStockIn?.toIso8601String(),
      'lastStockOut': lastStockOut?.toIso8601String(),
      'recentMovements': recentMovements.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InventoryModel.fromEntity(Inventory inventory) {
    return InventoryModel(
      id: inventory.id,
      productId: inventory.productId,
      productName: inventory.productName,
      productSku: inventory.productSku,
      variantId: inventory.variantId,
      variantName: inventory.variantName,
      locationId: inventory.locationId,
      locationName: inventory.locationName,
      quantity: inventory.quantity,
      reservedQuantity: inventory.reservedQuantity,
      availableQuantity: inventory.availableQuantity,
      reorderPoint: inventory.reorderPoint,
      maxStockLevel: inventory.maxStockLevel,
      averageCost: inventory.averageCost,
      totalValue: inventory.totalValue,
      status: inventory.status,
      lastStockIn: inventory.lastStockIn,
      lastStockOut: inventory.lastStockOut,
      recentMovements: inventory.recentMovements.map((m) => InventoryMovementModel.fromEntity(m)).toList(),
      createdAt: inventory.createdAt,
      updatedAt: inventory.updatedAt,
    );
  }

  Inventory toEntity() {
    return Inventory(
      id: id,
      productId: productId,
      productName: productName,
      productSku: productSku,
      variantId: variantId,
      variantName: variantName,
      locationId: locationId,
      locationName: locationName,
      quantity: quantity,
      reservedQuantity: reservedQuantity,
      availableQuantity: availableQuantity,
      reorderPoint: reorderPoint,
      maxStockLevel: maxStockLevel,
      averageCost: averageCost,
      totalValue: totalValue,
      status: status,
      lastStockIn: lastStockIn,
      lastStockOut: lastStockOut,
      recentMovements: recentMovements.map((m) => m.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
