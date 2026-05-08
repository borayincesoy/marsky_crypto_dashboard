import 'package:hive_flutter/hive_flutter.dart';

abstract class CryptoLocalDataSource {
  Future<void> addFavorite(String cryptoId);
  Future<void> removeFavorite(String cryptoId);
  Future<List<String>> getFavorites();
  Future<bool> isFavorite(String cryptoId);
}

class HiveCryptoLocalDataSource implements CryptoLocalDataSource {
  final Box _box;

  HiveCryptoLocalDataSource(this._box);

  @override
  Future<void> addFavorite(String cryptoId) async {
    await _box.put(cryptoId, true);
    await _box.flush();
  }

  @override
  Future<void> removeFavorite(String cryptoId) async {
    await _box.delete(cryptoId);
    await _box.flush();
  }

  @override
  Future<List<String>> getFavorites() async {
    return _box.keys.map((e) => e.toString()).toList();
  }

  @override
  Future<bool> isFavorite(String cryptoId) async {
    return _box.get(cryptoId, defaultValue: false) == true;
  }
}
