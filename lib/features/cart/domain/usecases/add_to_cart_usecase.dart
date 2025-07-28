import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<Cart, AddToCartParams> {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(AddToCartParams params) async {
    // Validate input
    if (params.quantity <= 0) {
      return Left(ValidationFailure('Quantity must be greater than 0'));
    }

    if (params.product.isOutOfStock) {
      return Left(ValidationFailure('Product is out of stock'));
    }

    if (params.quantity > params.product.stockQuantity) {
      return Left(ValidationFailure('Requested quantity exceeds available stock'));
    }

    return await repository.addToCart(
      params.userId,
      params.product,
      params.quantity,
    );
  }
}

class AddToCartParams {
  final String userId;
  final Product product;
  final int quantity;

  AddToCartParams({
    required this.userId,
    required this.product,
    required this.quantity,
  });
}
