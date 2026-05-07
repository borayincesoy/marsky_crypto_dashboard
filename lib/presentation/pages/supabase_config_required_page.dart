import 'package:flutter/material.dart';

class SupabaseConfigRequiredPage extends StatelessWidget {
  const SupabaseConfigRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Yapılandırması Gerekli')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Lütfen lib/env.dart dosyasına Supabase URL ve Anon Key bilgilerinizi girin.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Örnek:\n'
              'const String supabaseUrl = "https://xyzcompany.supabase.co";\n'
              'const String supabaseAnonKey = "your-anon-key";',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
