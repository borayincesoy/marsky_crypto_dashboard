import '../entities/crypto_entity.dart';

abstract class CryptoRepository {
  Future<List<CryptoEntity>> getCryptos({
    required int offset,
    required int limit,
    String? orderBy,
    String? orderDirection,
  });

  Future<void> addFavorite(String cryptoId);
  Future<void> removeFavorite(String cryptoId);
  Future<List<String>> getFavorites();
  Future<List<CryptoEntity>> getFavoriteCryptos({
    required int offset,
    required int limit,
  });
}
