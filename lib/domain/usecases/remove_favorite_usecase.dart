import '../repositories/crypto_repository.dart';

class RemoveFavoriteUseCase {
  final CryptoRepository repository;

  RemoveFavoriteUseCase(this.repository);

  Future<void> call(String cryptoId) {
    return repository.removeFavorite(cryptoId);
  }
}
