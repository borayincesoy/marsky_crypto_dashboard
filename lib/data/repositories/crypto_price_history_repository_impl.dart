import '../models/price_history_model.dart';
import '../datasources/crypto_price_history_remote_data_source.dart';
import '../../domain/repositories/crypto_price_history_repository.dart';
import '../../domain/entities/price_history_entity.dart';

class CryptoPriceHistoryRepositoryImpl implements CryptoPriceHistoryRepository {
  final CryptoPriceHistoryRemoteDataSource remoteDataSource;

  CryptoPriceHistoryRepositoryImpl({required this.remoteDataSource});

  PriceHistoryEntity _modelToEntity(PriceHistoryModel model) {
    return PriceHistoryEntity(timestamp: model.timestamp, price: model.price);
  }

  @override
  Future<List<PriceHistoryEntity>> getPriceHistory(String cryptoId) async {
    final history = await remoteDataSource.getPriceHistory(cryptoId);
    return history.map((model) => _modelToEntity(model)).toList();
  }
}
