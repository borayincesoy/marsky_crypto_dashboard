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

  AuthFailure _mapErrorToState(Object error) {
    String title = 'Authentication Error';
    String message = error.toString().replaceAll('Exception: ', '');

    if (message.toLowerCase().contains('invalid login credentials')) {
      title = 'Invalid Credentials';
      message = 'The email or password you entered is incorrect. Please double-check and try again.';
    } else if (message.toLowerCase().contains('network') || message.toLowerCase().contains('connection')) {
      title = 'Network Problem';
      message = 'Could not connect to the authentication server. Please check your internet connection.';
    } else if (message.toLowerCase().contains('user already registered')) {
      title = 'Account Exists';
      message = 'An account with this email already exists. Please try logging in instead.';
    }

    return AuthFailure(title: title, message: message);
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
      emit(_mapErrorToState(error));
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
      emit(_mapErrorToState(error));
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
      emit(_mapErrorToState(error));
    }
  }
}
