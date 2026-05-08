import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:marsky_crypto_dashboard/domain/entities/crypto_entity.dart';
import 'package:marsky_crypto_dashboard/domain/usecases/get_cryptos_usecase.dart';
import 'package:marsky_crypto_dashboard/domain/usecases/add_favorite_usecase.dart';
import 'package:marsky_crypto_dashboard/domain/usecases/remove_favorite_usecase.dart';
import 'package:marsky_crypto_dashboard/domain/usecases/get_favorites_usecase.dart';
import 'package:marsky_crypto_dashboard/presentation/bloc/crypto_bloc.dart';
import 'package:marsky_crypto_dashboard/presentation/bloc/crypto_event.dart';
import 'package:marsky_crypto_dashboard/presentation/bloc/crypto_state.dart';

class MockGetCryptosUseCase extends Mock implements GetCryptosUseCase {}
class MockAddFavoriteUseCase extends Mock implements AddFavoriteUseCase {}
class MockRemoveFavoriteUseCase extends Mock implements RemoveFavoriteUseCase {}
class MockGetFavoritesUseCase extends Mock implements GetFavoritesUseCase {}

void main() {
  late CryptoBloc cryptoBloc;
  late MockGetCryptosUseCase mockGetCryptosUseCase;
  late MockAddFavoriteUseCase mockAddFavoriteUseCase;
  late MockRemoveFavoriteUseCase mockRemoveFavoriteUseCase;
  late MockGetFavoritesUseCase mockGetFavoritesUseCase;

  setUp(() {
    mockGetCryptosUseCase = MockGetCryptosUseCase();
    mockAddFavoriteUseCase = MockAddFavoriteUseCase();
    mockRemoveFavoriteUseCase = MockRemoveFavoriteUseCase();
    mockGetFavoritesUseCase = MockGetFavoritesUseCase();

    cryptoBloc = CryptoBloc(
      getCryptosUseCase: mockGetCryptosUseCase,
      addFavoriteUseCase: mockAddFavoriteUseCase,
      removeFavoriteUseCase: mockRemoveFavoriteUseCase,
      getFavoritesUseCase: mockGetFavoritesUseCase,
    );
  });

  tearDown(() {
    cryptoBloc.close();
  });

  final tCryptoList = [
    const CryptoEntity(
      id: '1',
      rank: 1,
      name: 'Bitcoin',
      symbol: 'BTC',
      iconUrl: 'url',
      price: 50000.0,
      priceChange: 5.0,
      marketCap: 1000000000.0,
      volume24h: 500000000.0,
      sparkline: [],
      isFavorite: false,
    ),
  ];

  group('FetchCryptosRequested', () {
    blocTest<CryptoBloc, CryptoState>(
      'emits [CryptoLoading, CryptoLoaded] when successful',
      build: () {
        when(() => mockGetCryptosUseCase(
              offset: any(named: 'offset'),
              limit: any(named: 'limit'),
              orderBy: any(named: 'orderBy'),
              orderDirection: any(named: 'orderDirection'),
            )).thenAnswer((_) async => tCryptoList);
        return cryptoBloc;
      },
      act: (bloc) => bloc.add(const FetchCryptosRequested(offset: 0, limit: 20)),
      expect: () => [
        const CryptoLoading(),
        CryptoLoaded(
          cryptos: tCryptoList,
          favorites: const [],
          currentPage: 1,
          totalPages: 1,
        ),
      ],
    );

    blocTest<CryptoBloc, CryptoState>(
      'emits [CryptoLoading, CryptoError] when unsuccessful',
      build: () {
        when(() => mockGetCryptosUseCase(
              offset: any(named: 'offset'),
              limit: any(named: 'limit'),
              orderBy: any(named: 'orderBy'),
              orderDirection: any(named: 'orderDirection'),
            )).thenThrow(Exception('Failed to fetch'));
        return cryptoBloc;
      },
      act: (bloc) => bloc.add(const FetchCryptosRequested(offset: 0, limit: 20)),
      expect: () => [
        const CryptoLoading(),
        const CryptoError('An unexpected error occurred. Please try again.'),
      ],
    );
  });
}
