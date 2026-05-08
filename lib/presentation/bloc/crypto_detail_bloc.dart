import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../domain/usecases/get_price_history_usecase.dart';
import 'crypto_detail_event.dart';
import 'crypto_detail_state.dart';

class CryptoDetailBloc extends Bloc<CryptoDetailEvent, CryptoDetailState> {
  final GetPriceHistoryUseCase getPriceHistoryUseCase;

  CryptoDetailBloc({required this.getPriceHistoryUseCase})
    : super(const CryptoDetailInitial()) {
    on<FetchCryptoDetailRequested>(_onFetchCryptoDetailRequested);
  }

  String _mapErrorToMessage(Object error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 401:
          return 'Unauthorized access. Please check your API key.';
        case 403:
          return 'Access forbidden. You might have reached your rate limit.';
        case 404:
          return 'Requested data not found.';
        case 422:
          return 'Invalid request parameters.';
        case 500:
          return 'Internal server error. Please try again later.';
        default:
          return 'Connection error. Please check your internet.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  Future<void> _onFetchCryptoDetailRequested(
    FetchCryptoDetailRequested event,
    Emitter<CryptoDetailState> emit,
  ) async {
    emit(const CryptoDetailLoading());
    try {
      final priceHistory = await getPriceHistoryUseCase(event.cryptoId);

      if (priceHistory.isEmpty) {
        emit(const CryptoDetailError('No price history found.'));
        return;
      }

      final prices = priceHistory.map((e) => e.price).toList();
      final highPrice = prices.reduce((a, b) => a > b ? a : b);
      final lowPrice = prices.reduce((a, b) => a < b ? a : b);

      emit(
        CryptoDetailLoaded(
          priceHistory: priceHistory,
          highPrice: highPrice,
          lowPrice: lowPrice,
        ),
      );
    } catch (error) {
      emit(CryptoDetailError(_mapErrorToMessage(error)));
    }
  }
}
