import 'package:equatable/equatable.dart';
import '../../domain/entities/price_history_entity.dart';

abstract class CryptoDetailState extends Equatable {
  const CryptoDetailState();

  @override
  List<Object?> get props => [];
}

class CryptoDetailInitial extends CryptoDetailState {
  const CryptoDetailInitial();
}

class CryptoDetailLoading extends CryptoDetailState {
  const CryptoDetailLoading();
}

class CryptoDetailLoaded extends CryptoDetailState {
  final List<PriceHistoryEntity> priceHistory;
  final double highPrice;
  final double lowPrice;

  const CryptoDetailLoaded({
    required this.priceHistory,
    required this.highPrice,
    required this.lowPrice,
  });

  @override
  List<Object?> get props => [priceHistory, highPrice, lowPrice];
}

class CryptoDetailError extends CryptoDetailState {
  final String message;

  const CryptoDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
