import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/crypto_local_data_source.dart';
import 'data/datasources/crypto_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/crypto_repository_impl.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/get_cryptos_usecase.dart';
import 'domain/usecases/add_favorite_usecase.dart';
import 'domain/usecases/remove_favorite_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/crypto_bloc.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/supabase_config_required_page.dart';
import 'env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  final localDataSource = HiveCryptoLocalDataSource();
  await localDataSource.init();

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

  runApp(
    MyApp(
      requiresSupabaseConfig: !hasValidSupabaseConfig,
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      getCryptosUseCase: getCryptosUseCase,
      addFavoriteUseCase: addFavoriteUseCase,
      removeFavoriteUseCase: removeFavoriteUseCase,
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

  const MyApp({
    super.key,
    required this.requiresSupabaseConfig,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCryptosUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
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
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Marsky Crypto Dashboard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: LoginPage.routeName,
        routes: {
          LoginPage.routeName: (_) => const LoginPage(),
          RegisterPage.routeName: (_) => const RegisterPage(),
          HomePage.routeName: (_) => const HomePage(),
        },
      ),
    );
  }
}
