import 'package:hive_flutter/hive_flutter.dart';

abstract class CryptoLocalDataSource {
  Future<void> addFavorite(String cryptoId);
  Future<void> removeFavorite(String cryptoId);
  Future<List<String>> getFavorites();
  Future<bool> isFavorite(String cryptoId);
}

class HiveCryptoLocalDataSource implements CryptoLocalDataSource {
  Box? _box;
  String? _currentUserId;

  HiveCryptoLocalDataSource();

  Future<void> setUserId(String userId) async {
    if (_currentUserId == userId && _box != null) return;
    
    if (_box != null) await _box!.close();
    
    _currentUserId = userId;
    _box = await Hive.openBox('favs_$userId');
  }

  Box get _activeBox {
    if (_box == null) {
      throw Exception('Local database not initialized for user. Please login again.');
    }
    return _box!;
  }

  @override
  Future<void> addFavorite(String cryptoId) async {
    await _activeBox.put(cryptoId, true);
    await _activeBox.flush();
  }

  @override
  Future<void> removeFavorite(String cryptoId) async {
    await _activeBox.delete(cryptoId);
    await _activeBox.flush();
  }

  @override
  Future<List<String>> getFavorites() async {
    if (_box == null) return [];
    return _activeBox.keys.map((e) => e.toString()).toList();
  }

  @override
  Future<bool> isFavorite(String cryptoId) async {
    if (_box == null) return false;
    return _activeBox.get(cryptoId, defaultValue: false) == true;
  }
}
