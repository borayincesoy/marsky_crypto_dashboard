import '../repositories/crypto_repository.dart';
import '../entities/crypto_entity.dart';

class GetFavoritesUseCase {
  final CryptoRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<List<CryptoEntity>> call({required int offset, required int limit}) {
    return repository.getFavoriteCryptos(offset: offset, limit: limit);
  }
}
