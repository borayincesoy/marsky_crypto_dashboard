import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../data/datasources/crypto_local_data_source.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final CryptoLocalDataSource localDataSource;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.localDataSource,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await loginUseCase(event.email, event.password);
      
      final userId = supabase.Supabase.instance.client.auth.currentUser?.id;
      if (userId != null && localDataSource is HiveCryptoLocalDataSource) {
        await (localDataSource as HiveCryptoLocalDataSource).setUserId(userId);
      }
      
      emit(const AuthAuthenticated());
    } catch (error) {
      emit(AuthFailure(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await registerUseCase(event.email, event.password);
      
      final userId = supabase.Supabase.instance.client.auth.currentUser?.id;
      if (userId != null && localDataSource is HiveCryptoLocalDataSource) {
        await (localDataSource as HiveCryptoLocalDataSource).setUserId(userId);
      }

      emit(const AuthAuthenticated());
    } catch (error) {
      emit(AuthFailure(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await logoutUseCase();
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(AuthFailure(error.toString().replaceAll('Exception: ', '')));
    }
  }
}
