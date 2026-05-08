import 'package:dio/dio.dart';
import '../../env.dart';
import '../models/crypto_model.dart';

abstract class CryptoRemoteDataSource {
  Future<List<CryptoModel>> getCryptos({
    required int offset,
    required int limit,
    String? orderBy,
    String? orderDirection,
    List<String>? uuids,
  });
}

class CoinRankingRemoteDataSource implements CryptoRemoteDataSource {
  static const String _baseUrl = 'https://api.coinranking.com/v2';

  final Dio _dio;

  CoinRankingRemoteDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              headers: {'Content-Type': 'application/json'},
            ),
          );

  @override
  Future<List<CryptoModel>> getCryptos({
    required int offset,
    required int limit,
    String? orderBy,
    String? orderDirection,
    List<String>? uuids,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (orderBy != null) {
        params['orderBy'] = orderBy;
      }

      if (orderDirection != null) {
        params['orderDirection'] = orderDirection;
      }

      if (uuids != null && uuids.isNotEmpty) {
        params['uuids[]'] = uuids;
      }

      final response = await _dio.get(
        '/coins',
        queryParameters: params,
        options: Options(headers: {'x-access-token': coinRankingApiKey}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> coins = data['data']?['coins'] ?? [];

        return coins
            .map((coin) => CryptoModel.fromJson(coin as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('API isteği başarısız: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('API hatası: ${e.message}');
    } catch (e) {
      throw Exception('Beklenmeyen hata: $e');
    }
  }
}
