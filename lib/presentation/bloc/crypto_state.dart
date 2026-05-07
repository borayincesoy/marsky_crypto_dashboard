import 'package:equatable/equatable.dart';
import '../../domain/entities/crypto_entity.dart';

abstract class CryptoState extends Equatable {
  const CryptoState();

  @override
  List<Object?> get props => [];
}

class CryptoInitial extends CryptoState {
  const CryptoInitial();
}

class CryptoLoading extends CryptoState {
  const CryptoLoading();
}

class CryptoLoaded extends CryptoState {
  final List<CryptoEntity> cryptos;
  final int currentPage;
  final int totalPages;
  final String? currentSort;
  final String? currentSortDirection;

  const CryptoLoaded({
    required this.cryptos,
    required this.currentPage,
    required this.totalPages,
    this.currentSort,
    this.currentSortDirection,
  });

  @override
  List<Object?> get props => [
    cryptos,
    currentPage,
    totalPages,
    currentSort,
    currentSortDirection,
  ];
}

class CryptoError extends CryptoState {
  final String message;

  const CryptoError(this.message);

  @override
  List<Object?> get props => [message];
}
