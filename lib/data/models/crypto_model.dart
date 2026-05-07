import 'package:equatable/equatable.dart';

class CryptoModel extends Equatable {
  final String id;
  final int rank;
  final String name;
  final String symbol;
  final String iconUrl;
  final double price;
  final double priceChange;
  final double marketCap;
  final double volume24h;
  final String sparkline;
  final bool isFavorite;

  const CryptoModel({
    required this.id,
    required this.rank,
    required this.name,
    required this.symbol,
    required this.iconUrl,
    required this.price,
    required this.priceChange,
    required this.marketCap,
    required this.volume24h,
    required this.sparkline,
    this.isFavorite = false,
  });

  factory CryptoModel.fromJson(Map<String, dynamic> json) {
    return CryptoModel(
      id: json['uuid'] ?? '',
      rank: int.tryParse(json['rank'].toString()) ?? 0,
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      priceChange: double.tryParse(json['change'].toString()) ?? 0.0,
      marketCap: double.tryParse(json['marketCap'].toString()) ?? 0.0,
      volume24h: double.tryParse(json['24hVolume'].toString()) ?? 0.0,
      sparkline: json['sparkline'] is List
          ? (json['sparkline'] as List).join(',')
          : '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    rank,
    name,
    symbol,
    iconUrl,
    price,
    priceChange,
    marketCap,
    volume24h,
    sparkline,
    isFavorite,
  ];

  CryptoModel copyWith({
    String? id,
    int? rank,
    String? name,
    String? symbol,
    String? iconUrl,
    double? price,
    double? priceChange,
    double? marketCap,
    double? volume24h,
    String? sparkline,
    bool? isFavorite,
  }) {
    return CryptoModel(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      iconUrl: iconUrl ?? this.iconUrl,
      price: price ?? this.price,
      priceChange: priceChange ?? this.priceChange,
      marketCap: marketCap ?? this.marketCap,
      volume24h: volume24h ?? this.volume24h,
      sparkline: sparkline ?? this.sparkline,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
