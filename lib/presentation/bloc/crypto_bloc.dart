import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/crypto_entity.dart';
import '../../domain/usecases/get_cryptos_usecase.dart';
import '../../domain/usecases/add_favorite_usecase.dart';
import '../../domain/usecases/remove_favorite_usecase.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import 'crypto_event.dart';
import 'crypto_state.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final GetCryptosUseCase getCryptosUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;

  static const int pageSize = 20;

  String? _currentSort;
  String? _currentSortDirection;

  CryptoBloc({
    required this.getCryptosUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.getFavoritesUseCase,
  }) : super(const CryptoInitial()) {
    on<FetchCryptosRequested>(_onFetchCryptosRequested);
    on<CryptoSortChanged>(_onSortChanged);
    on<AddFavoriteRequested>(_onAddFavoriteRequested);
    on<RemoveFavoriteRequested>(_onRemoveFavoriteRequested);
    on<LoadFavoritesRequested>(_onLoadFavoritesRequested);
  }

  String _mapErrorToMessage(Object error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 401:
          return 'Unauthorized access. Please check your API key.';
        case 403:
          return 'Access forbidden. You might have reached your rate limit.';
        case 404:
          return 'Requested data not found.';
        case 422:
          return 'Invalid request parameters.';
        case 500:
          return 'Internal server error. Please try again later.';
        default:
          return 'Connection error. Please check your internet.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  Future<void> _onFetchCryptosRequested(
    FetchCryptosRequested event,
    Emitter<CryptoState> emit,
  ) async {
    final favorites = state is CryptoLoaded ? (state as CryptoLoaded).favorites : <CryptoEntity>[];
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

      final currentPage = (event.offset / event.limit).floor() + 1;
      final hasNextPage = cryptos.length >= event.limit;
      final totalPages = hasNextPage ? currentPage + 1 : currentPage;

      emit(
        CryptoLoaded(
          cryptos: cryptos,
          favorites: favorites,
          currentPage: currentPage,
          totalPages: totalPages,
          currentSort: _currentSort,
          currentSortDirection: _currentSortDirection,
        ),
      );
    } catch (error) {
      emit(CryptoError(_mapErrorToMessage(error)));
    }
  }

  Future<void> _onSortChanged(
    CryptoSortChanged event,
    Emitter<CryptoState> emit,
  ) async {
    final favorites = state is CryptoLoaded ? (state as CryptoLoaded).favorites : <CryptoEntity>[];
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

      final hasNextPage = cryptos.length >= pageSize;
      
      emit(
        CryptoLoaded(
          cryptos: cryptos,
          favorites: favorites,
          currentPage: 1,
          totalPages: hasNextPage ? 2 : 1,
          currentSort: _currentSort,
          currentSortDirection: _currentSortDirection,
        ),
      );
    } catch (error) {
      emit(CryptoError(_mapErrorToMessage(error)));
    }
  }

  Future<void> _onAddFavoriteRequested(
    AddFavoriteRequested event,
    Emitter<CryptoState> emit,
  ) async {
    try {
      await addFavoriteUseCase(event.cryptoId);
      add(const LoadFavoritesRequested()); // Refresh favorites
      if (state is CryptoLoaded) {
        final currentState = state as CryptoLoaded;
        final updatedCryptos = currentState.cryptos
            .map(
              (crypto) => crypto.id == event.cryptoId
                  ? crypto.copyWith(isFavorite: true)
                  : crypto,
            )
            .toList();

        emit(currentState.copyWith(cryptos: updatedCryptos));
      }
    } catch (error) {
      emit(CryptoError(_mapErrorToMessage(error)));
    }
  }

  Future<void> _onRemoveFavoriteRequested(
    RemoveFavoriteRequested event,
    Emitter<CryptoState> emit,
  ) async {
    try {
      await removeFavoriteUseCase(event.cryptoId);
      add(const LoadFavoritesRequested()); // Refresh favorites
      if (state is CryptoLoaded) {
        final currentState = state as CryptoLoaded;
        final updatedCryptos = currentState.cryptos
            .map(
              (crypto) => crypto.id == event.cryptoId
                  ? crypto.copyWith(isFavorite: false)
                  : crypto,
            )
            .toList();

        emit(currentState.copyWith(cryptos: updatedCryptos));
      }
    } catch (error) {
      emit(CryptoError(_mapErrorToMessage(error)));
    }
  }

  Future<void> _onLoadFavoritesRequested(
    LoadFavoritesRequested event,
    Emitter<CryptoState> emit,
  ) async {
    try {
      // First, get the list of favorite IDs from local storage
      final favoriteIds = await addFavoriteUseCase.repository.getFavorites();
      
      if (favoriteIds.isEmpty) {
        if (state is CryptoLoaded) {
          emit((state as CryptoLoaded).copyWith(favorites: []));
        } else {
          emit(const CryptoLoaded(cryptos: [], favorites: [], currentPage: 1, totalPages: 1));
        }
        return;
      }

      final favorites = await getFavoritesUseCase(offset: 0, limit: 100);
      if (state is CryptoLoaded) {
        emit((state as CryptoLoaded).copyWith(favorites: favorites));
      } else {
        emit(
          CryptoLoaded(
            cryptos: const [],
            favorites: favorites,
            currentPage: 1,
            totalPages: 1,
          ),
        );
      }
    } catch (error) {
      emit(CryptoError(_mapErrorToMessage(error)));
    }
  }
}
