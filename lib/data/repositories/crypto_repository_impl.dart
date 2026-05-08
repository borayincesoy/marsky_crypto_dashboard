import '../models/crypto_model.dart';
import '../datasources/crypto_local_data_source.dart';
import '../datasources/crypto_remote_data_source.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/entities/crypto_entity.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoRemoteDataSource remoteDataSource;
  final CryptoLocalDataSource localDataSource;

  CryptoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  CryptoEntity _modelToEntity(CryptoModel model) {
    return CryptoEntity(
      id: model.id,
      rank: model.rank,
      name: model.name,
      symbol: model.symbol,
      iconUrl: model.iconUrl,
      price: model.price,
      priceChange: model.priceChange,
      marketCap: model.marketCap,
      volume24h: model.volume24h,
      sparkline: model.sparkline,
      isFavorite: model.isFavorite,
    );
  }

  @override
  Future<List<CryptoEntity>> getCryptos({
    required int offset,
    required int limit,
    String? orderBy,
    String? orderDirection,
  }) async {
    final cryptos = await remoteDataSource.getCryptos(
      offset: offset,
      limit: limit,
      orderBy: orderBy,
      orderDirection: orderDirection,
    );

    final favorites = await localDataSource.getFavorites();

    return cryptos
        .map(
          (crypto) => _modelToEntity(
            crypto.copyWith(isFavorite: favorites.contains(crypto.id)),
          ),
        )
        .toList();
  }

  @override
  Future<void> addFavorite(String cryptoId) async {
    await localDataSource.addFavorite(cryptoId);
  }

  @override
  Future<void> removeFavorite(String cryptoId) async {
    await localDataSource.removeFavorite(cryptoId);
  }

  @override
  Future<List<String>> getFavorites() {
    return localDataSource.getFavorites();
  }

  @override
  Future<List<CryptoEntity>> getFavoriteCryptos({
    required int offset,
    required int limit,
  }) async {
    final favorites = await localDataSource.getFavorites();

    if (favorites.isEmpty) {
      return [];
    }

    // CoinRanking API allows filtering by UUIDs using the uuids[] parameter
    final favoriteModels = await remoteDataSource.getCryptos(
      offset: offset,
      limit: limit,
      uuids: favorites,
    );

    return favoriteModels
        .map((model) => _modelToEntity(model.copyWith(isFavorite: true)))
        .toList();
  }
}
