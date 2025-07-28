import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class WatchCartUseCase {
  final CartRepository repository;

  WatchCartUseCase(this.repository);

  Stream<Cart> call(String userId) {
    return repository.watchUserCart(userId);
  }
}
