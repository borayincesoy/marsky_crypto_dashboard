import '../entities/price_history_entity.dart';

abstract class CryptoPriceHistoryRepository {
  Future<List<PriceHistoryEntity>> getPriceHistory(String cryptoId);
}
