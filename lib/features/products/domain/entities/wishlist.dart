import 'product.dart';

class Wishlist {
  final String id;
  final String userId;
  final List<Product> products;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? name;
  final bool isPublic;

  const Wishlist({
    required this.id,
    required this.userId,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.isPublic = false,
  });

  Wishlist copyWith({
    String? id,
    String? userId,
    List<Product>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    bool? isPublic,
  }) {
    return Wishlist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  // Helper getters
  int get itemCount => products.length;
  
  double get totalValue => products.fold<double>(0, (sum, product) => sum + product.price);
  
  double get totalSavings => products
      .where((p) => p.isOnSale && p.originalPrice != null)
      .fold<double>(0, (sum, product) => sum + (product.originalPrice! - product.price));

  List<Product> get availableProducts => products.where((p) => p.isInStock).toList();
  
  List<Product> get onSaleProducts => products.where((p) => p.isOnSale).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Wishlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Wishlist(id: $id, userId: $userId, itemCount: $itemCount)';
  }
}
