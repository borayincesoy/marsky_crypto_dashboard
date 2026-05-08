import 'package:equatable/equatable.dart';

class PriceHistoryEntity extends Equatable {
  final String timestamp;
  final double price;

  const PriceHistoryEntity({required this.timestamp, required this.price});

  @override
  List<Object?> get props => [timestamp, price];
}
