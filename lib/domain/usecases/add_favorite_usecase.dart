import '../repositories/crypto_repository.dart';

class AddFavoriteUseCase {
  final CryptoRepository repository;

  AddFavoriteUseCase(this.repository);

  Future<void> call(String cryptoId) {
    return repository.addFavorite(cryptoId);
  }
}
