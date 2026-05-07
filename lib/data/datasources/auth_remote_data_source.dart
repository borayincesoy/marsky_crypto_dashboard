import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<void> login(String email, String password);
  Future<void> register(String email, String password);
  Future<void> logout();
}

class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final SupabaseClient _client;

  SupabaseAuthRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<void> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null || response.user == null) {
      throw Exception(
        'Giriş sırasında bir hata oluştu. Lütfen bilgilerinizi kontrol edin.',
      );
    }
  }

  @override
  Future<void> register(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Kayıt işlemi başarısız oldu. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
