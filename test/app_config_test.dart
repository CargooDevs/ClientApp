import 'package:cargoo_client/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('rejects placeholder Supabase values', () {
      expect(
        AppConfig.isSupabaseConfigured(
          'https://SEU-PROJETO.supabase.co',
          'SUA_ANON_KEY',
        ),
        isFalse,
      );
    });

    test('accepts valid Supabase values', () {
      expect(
        AppConfig.isSupabaseConfigured(
          'https://project.supabase.co',
          'valid_anon_key',
        ),
        isTrue,
      );
    });

    test('requires non-empty values', () {
      expect(AppConfig.isSupabaseConfigured('', ''), isFalse);
    });
  });
}
