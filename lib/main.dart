import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/datasources/crypto_local_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/crypto_remote_data_source.dart';
import 'data/datasources/crypto_price_history_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/crypto_repository_impl.dart';
import 'data/repositories/crypto_price_history_repository_impl.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/get_cryptos_usecase.dart';
import 'domain/usecases/add_favorite_usecase.dart';
import 'domain/usecases/remove_favorite_usecase.dart';
import 'domain/usecases/get_favorites_usecase.dart';
import 'domain/usecases/get_price_history_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/crypto_bloc.dart';
import 'presentation/bloc/crypto_detail_bloc.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/supabase_config_required_page.dart';
import 'env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  final favoritesBox = await Hive.openBox('marsky_persistent_favs');
  final localDataSource = HiveCryptoLocalDataSource(favoritesBox);

  final hasValidSupabaseConfig =
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('REPLACE') &&
      !supabaseAnonKey.contains('REPLACE');

  if (hasValidSupabaseConfig) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // Auth setup
  final authRemoteDataSource = SupabaseAuthRemoteDataSource();
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  // Crypto setup
  final cryptoRemoteDataSource = CoinRankingRemoteDataSource();
  final cryptoRepository = CryptoRepositoryImpl(
    remoteDataSource: cryptoRemoteDataSource,
    localDataSource: localDataSource,
  );
  final getCryptosUseCase = GetCryptosUseCase(cryptoRepository);
  final addFavoriteUseCase = AddFavoriteUseCase(cryptoRepository);
  final removeFavoriteUseCase = RemoveFavoriteUseCase(cryptoRepository);
  final getFavoritesUseCase = GetFavoritesUseCase(cryptoRepository);

  // Price History setup
  final priceHistoryRemoteDataSource =
      CoinRankingPriceHistoryRemoteDataSource();
  final priceHistoryRepository = CryptoPriceHistoryRepositoryImpl(
    remoteDataSource: priceHistoryRemoteDataSource,
  );
  final getPriceHistoryUseCase = GetPriceHistoryUseCase(priceHistoryRepository);

  runApp(
    MyApp(
      requiresSupabaseConfig: !hasValidSupabaseConfig,
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      getCryptosUseCase: getCryptosUseCase,
      addFavoriteUseCase: addFavoriteUseCase,
      removeFavoriteUseCase: removeFavoriteUseCase,
      getFavoritesUseCase: getFavoritesUseCase,
      getPriceHistoryUseCase: getPriceHistoryUseCase,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool requiresSupabaseConfig;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCryptosUseCase getCryptosUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final GetPriceHistoryUseCase getPriceHistoryUseCase;

  const MyApp({
    super.key,
    required this.requiresSupabaseConfig,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCryptosUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.getFavoritesUseCase,
    required this.getPriceHistoryUseCase,
  });

  @override
  Widget build(BuildContext context) {
    if (requiresSupabaseConfig) {
      return const MaterialApp(
        title: 'Marsky Crypto Dashboard',
        home: SupabaseConfigRequiredPage(),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => CryptoBloc(
            getCryptosUseCase: getCryptosUseCase,
            addFavoriteUseCase: addFavoriteUseCase,
            removeFavoriteUseCase: removeFavoriteUseCase,
            getFavoritesUseCase: getFavoritesUseCase,
          ),
        ),
        BlocProvider(
          create: (_) =>
              CryptoDetailBloc(getPriceHistoryUseCase: getPriceHistoryUseCase),
        ),
      ],
      child: MaterialApp(
        title: 'Marsky Crypto Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A1C1E),
            primary: const Color(0xFF1A1C1E),
            secondary: const Color(0xFF6C757D),
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A1C1E),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          tabBarTheme: const TabBarThemeData(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1C1E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        initialRoute: Supabase.instance.client.auth.currentSession != null
            ? HomePage.routeName
            : LoginPage.routeName,
        routes: {
          LoginPage.routeName: (_) => const LoginPage(),
          RegisterPage.routeName: (_) => const RegisterPage(),
          HomePage.routeName: (_) => const HomePage(),
        },
      ),
    );
  }
}
