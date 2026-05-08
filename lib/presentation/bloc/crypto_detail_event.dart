import 'package:equatable/equatable.dart';

abstract class CryptoDetailEvent extends Equatable {
  const CryptoDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchCryptoDetailRequested extends CryptoDetailEvent {
  final String cryptoId;

  const FetchCryptoDetailRequested(this.cryptoId);

  @override
  List<Object?> get props => [cryptoId];
}
