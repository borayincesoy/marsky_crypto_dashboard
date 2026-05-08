import 'package:equatable/equatable.dart';

class PriceHistoryModel extends Equatable {
  final String timestamp;
  final double price;

  const PriceHistoryModel({required this.timestamp, required this.price});

  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) {
    return PriceHistoryModel(
      timestamp: json['timestamp']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [timestamp, price];
}
