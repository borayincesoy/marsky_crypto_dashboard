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

  CryptoDetailError _mapErrorToState(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return const CryptoDetailError(
          title: 'Connection Timed Out',
          message: 'The server is taking too long to respond. Please check your internet.',
        );
      } else if (error.type == DioExceptionType.connectionError) {
        return const CryptoDetailError(
          title: 'No Internet Connection',
          message: 'Please check your network settings and try again.',
        );
      }

      switch (error.response?.statusCode) {
        case 401:
          return const CryptoDetailError(
            title: 'Unauthorized',
            message: 'Access denied. Please check your API key.',
          );
        default:
          return CryptoDetailError(
            title: 'Data Error',
            message: 'Could not fetch price history (${error.response?.statusCode ?? 'Unknown'}).',
          );
      }
    }
    return CryptoDetailError(
      title: 'Unexpected Error',
      message: error.toString().replaceAll('Exception: ', ''),
    );
  }

  Future<void> _onFetchCryptoDetailRequested(
    FetchCryptoDetailRequested event,
    Emitter<CryptoDetailState> emit,
  ) async {
    emit(const CryptoDetailLoading());
    try {
      final priceHistory = await getPriceHistoryUseCase(event.cryptoId);

      if (priceHistory.isEmpty) {
        emit(const CryptoDetailError(
          title: 'No Data',
          message: 'No price history found for this cryptocurrency.',
        ));
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
      emit(_mapErrorToState(error));
    }
  }
}
