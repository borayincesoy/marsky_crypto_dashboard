import 'package:equatable/equatable.dart';

abstract class CryptoEvent extends Equatable {
  const CryptoEvent();

  @override
  List<Object?> get props => [];
}

class FetchCryptosRequested extends CryptoEvent {
  final int offset;
  final int limit;
  final String? orderBy;
  final String? orderDirection;

  const FetchCryptosRequested({
    required this.offset,
    required this.limit,
    this.orderBy,
    this.orderDirection,
  });

  @override
  List<Object?> get props => [offset, limit, orderBy, orderDirection];
}

class CryptoSortChanged extends CryptoEvent {
  final String? orderBy;
  final String? orderDirection;

  const CryptoSortChanged({this.orderBy, this.orderDirection});

  @override
  List<Object?> get props => [orderBy, orderDirection];
}

class AddFavoriteRequested extends CryptoEvent {
  final String cryptoId;

  const AddFavoriteRequested(this.cryptoId);

  @override
  List<Object?> get props => [cryptoId];
}

class RemoveFavoriteRequested extends CryptoEvent {
  final String cryptoId;

  const RemoveFavoriteRequested(this.cryptoId);

  @override
  List<Object?> get props => [cryptoId];
}

class LoadFavoritesRequested extends CryptoEvent {
  const LoadFavoritesRequested();
}
