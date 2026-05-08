import 'package:dio/dio.dart';
import '../../env.dart';
import '../models/price_history_model.dart';

abstract class CryptoPriceHistoryRemoteDataSource {
  Future<List<PriceHistoryModel>> getPriceHistory(String cryptoId);
}

class CoinRankingPriceHistoryRemoteDataSource
    implements CryptoPriceHistoryRemoteDataSource {
  static const String _baseUrl = 'https://api.coinranking.com/v2';

  final Dio _dio;

  CoinRankingPriceHistoryRemoteDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              headers: {'Content-Type': 'application/json'},
            ),
          );

  @override
  Future<List<PriceHistoryModel>> getPriceHistory(String cryptoId) async {
    try {
      final response = await _dio.get(
        '/coin/$cryptoId/history',
        queryParameters: {'timePeriod': '24h'},
        options: Options(headers: {'x-access-token': coinRankingApiKey}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> history = data['data']?['history'] ?? [];

        return history
            .map(
              (item) =>
                  PriceHistoryModel.fromJson(item as Map<String, dynamic>),
            )
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
