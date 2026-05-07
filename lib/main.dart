import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/supabase_config_required_page.dart';
import 'env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hasValidSupabaseConfig = supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('REPLACE') &&
      !supabaseAnonKey.contains('REPLACE');

  if (hasValidSupabaseConfig) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  final authRemoteDataSource = SupabaseAuthRemoteDataSource();
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  runApp(MyApp(
    requiresSupabaseConfig: !hasValidSupabaseConfig,
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
  ));
}

class MyApp extends StatelessWidget {
  final bool requiresSupabaseConfig;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  const MyApp({
    super.key,
    required this.requiresSupabaseConfig,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  });

  @override
  Widget build(BuildContext context) {
    if (requiresSupabaseConfig) {
      return const MaterialApp(
        title: 'Marsky Crypto Dashboard',
        home: SupabaseConfigRequiredPage(),
      );
    }

    return BlocProvider(
      create: (_) => AuthBloc(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        logoutUseCase: logoutUseCase,
      ),
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
