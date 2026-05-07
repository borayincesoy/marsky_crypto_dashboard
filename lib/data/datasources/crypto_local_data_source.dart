import 'package:hive/hive.dart';

abstract class CryptoLocalDataSource {
  Future<void> addFavorite(String cryptoId);
  Future<void> removeFavorite(String cryptoId);
  Future<List<String>> getFavorites();
  Future<bool> isFavorite(String cryptoId);
}

class HiveCryptoLocalDataSource implements CryptoLocalDataSource {
  static const String _boxName = 'favorites';

  late Box<dynamic> _box;

  HiveCryptoLocalDataSource();

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  @override
  Future<void> addFavorite(String cryptoId) async {
    final favorites = await getFavorites();
    if (!favorites.contains(cryptoId)) {
      favorites.add(cryptoId);
      await _box.put(_boxName, favorites);
    }
  }

  @override
  Future<void> removeFavorite(String cryptoId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((id) => id == cryptoId);
    await _box.put(_boxName, favorites);
  }

  @override
  Future<List<String>> getFavorites() async {
    final data = _box.get(_boxName);
    if (data == null) {
      return [];
    }
    return List<String>.from(data as List);
  }

  @override
  Future<bool> isFavorite(String cryptoId) async {
    final favorites = await getFavorites();
    return favorites.contains(cryptoId);
  }
}
