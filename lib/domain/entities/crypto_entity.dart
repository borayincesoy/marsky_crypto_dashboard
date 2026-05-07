import 'package:equatable/equatable.dart';

class CryptoEntity extends Equatable {
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

  const CryptoEntity({
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

  CryptoEntity copyWith({
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
    return CryptoEntity(
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
