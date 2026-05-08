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
  final List<CryptoEntity> favorites;
  final int currentPage;
  final int totalPages;
  final String? currentSort;
  final String? currentSortDirection;

  const CryptoLoaded({
    required this.cryptos,
    this.favorites = const [],
    required this.currentPage,
    required this.totalPages,
    this.currentSort,
    this.currentSortDirection,
  });

  @override
  List<Object?> get props => [
    cryptos,
    favorites,
    currentPage,
    totalPages,
    currentSort,
    currentSortDirection,
  ];

  CryptoLoaded copyWith({
    List<CryptoEntity>? cryptos,
    List<CryptoEntity>? favorites,
    int? currentPage,
    int? totalPages,
    String? currentSort,
    String? currentSortDirection,
  }) {
    return CryptoLoaded(
      cryptos: cryptos ?? this.cryptos,
      favorites: favorites ?? this.favorites,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentSort: currentSort ?? this.currentSort,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }
}

class CryptoError extends CryptoState {
  final String message;

  const CryptoError(this.message);

  @override
  List<Object?> get props => [message];
}
