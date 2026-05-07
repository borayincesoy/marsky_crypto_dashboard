import '../repositories/crypto_repository.dart';
import '../entities/crypto_entity.dart';

class GetCryptosUseCase {
  final CryptoRepository repository;

  GetCryptosUseCase(this.repository);

  Future<List<CryptoEntity>> call({
    required int offset,
    required int limit,
    String? orderBy,
    String? orderDirection,
  }) {
    return repository.getCryptos(
      offset: offset,
      limit: limit,
      orderBy: orderBy,
      orderDirection: orderDirection,
    );
  }
}
