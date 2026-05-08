import '../repositories/crypto_price_history_repository.dart';
import '../entities/price_history_entity.dart';

class GetPriceHistoryUseCase {
  final CryptoPriceHistoryRepository repository;

  GetPriceHistoryUseCase(this.repository);

  Future<List<PriceHistoryEntity>> call(String cryptoId) {
    return repository.getPriceHistory(cryptoId);
  }
}
