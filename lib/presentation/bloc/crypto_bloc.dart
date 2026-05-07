import 'package:bloc/bloc.dart';
import '../../domain/usecases/get_cryptos_usecase.dart';
import '../../domain/usecases/add_favorite_usecase.dart';
import '../../domain/usecases/remove_favorite_usecase.dart';
import 'crypto_event.dart';
import 'crypto_state.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final GetCryptosUseCase getCryptosUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;

  static const int pageSize = 20;

  String? _currentSort;
  String? _currentSortDirection;

  CryptoBloc({
    required this.getCryptosUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  }) : super(const CryptoInitial()) {
    on<FetchCryptosRequested>(_onFetchCryptosRequested);
    on<CryptoSortChanged>(_onSortChanged);
    on<AddFavoriteRequested>(_onAddFavoriteRequested);
    on<RemoveFavoriteRequested>(_onRemoveFavoriteRequested);
  }

  Future<void> _onFetchCryptosRequested(
    FetchCryptosRequested event,
    Emitter<CryptoState> emit,
  ) async {
    emit(const CryptoLoading());
    try {
      final cryptos = await getCryptosUseCase(
        offset: event.offset,
        limit: event.limit,
        orderBy: event.orderBy ?? _currentSort,
        orderDirection: event.orderDirection ?? _currentSortDirection,
      );

      _currentSort = event.orderBy ?? _currentSort;
      _currentSortDirection = event.orderDirection ?? _currentSortDirection;

      final totalPages = (cryptos.length / pageSize).ceil();
      final currentPage = (event.offset / pageSize).floor() + 1;

      emit(
        CryptoLoaded(
          cryptos: cryptos,
          currentPage: currentPage,
          totalPages: totalPages,
          currentSort: _currentSort,
          currentSortDirection: _currentSortDirection,
        ),
      );
    } catch (error) {
      emit(CryptoError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSortChanged(
    CryptoSortChanged event,
    Emitter<CryptoState> emit,
  ) async {
    emit(const CryptoLoading());
    try {
      final cryptos = await getCryptosUseCase(
        offset: 0,
        limit: pageSize,
        orderBy: event.orderBy,
        orderDirection: event.orderDirection,
      );

      _currentSort = event.orderBy;
      _currentSortDirection = event.orderDirection;

      emit(
        CryptoLoaded(
          cryptos: cryptos,
          currentPage: 1,
          totalPages: (cryptos.length / pageSize).ceil(),
          currentSort: _currentSort,
          currentSortDirection: _currentSortDirection,
        ),
      );
    } catch (error) {
      emit(CryptoError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddFavoriteRequested(
    AddFavoriteRequested event,
    Emitter<CryptoState> emit,
  ) async {
    try {
      await addFavoriteUseCase(event.cryptoId);
      if (state is CryptoLoaded) {
        final currentState = state as CryptoLoaded;
        final updatedCryptos = currentState.cryptos
            .map(
              (crypto) => crypto.id == event.cryptoId
                  ? crypto.copyWith(isFavorite: true)
                  : crypto,
            )
            .toList();

        emit(
          CryptoLoaded(
            cryptos: updatedCryptos,
            currentPage: currentState.currentPage,
            totalPages: currentState.totalPages,
            currentSort: currentState.currentSort,
            currentSortDirection: currentState.currentSortDirection,
          ),
        );
      }
    } catch (error) {
      emit(CryptoError(error.toString()));
    }
  }

  Future<void> _onRemoveFavoriteRequested(
    RemoveFavoriteRequested event,
    Emitter<CryptoState> emit,
  ) async {
    try {
      await removeFavoriteUseCase(event.cryptoId);
      if (state is CryptoLoaded) {
        final currentState = state as CryptoLoaded;
        final updatedCryptos = currentState.cryptos
            .map(
              (crypto) => crypto.id == event.cryptoId
                  ? crypto.copyWith(isFavorite: false)
                  : crypto,
            )
            .toList();

        emit(
          CryptoLoaded(
            cryptos: updatedCryptos,
            currentPage: currentState.currentPage,
            totalPages: currentState.totalPages,
            currentSort: currentState.currentSort,
            currentSortDirection: currentState.currentSortDirection,
          ),
        );
      }
    } catch (error) {
      emit(CryptoError(error.toString()));
    }
  }
}

extension CryptoExtension on CryptoBloc {
  copyWith({isFavorite}) {}
}
