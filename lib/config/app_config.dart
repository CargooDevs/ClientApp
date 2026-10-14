class AppConfig {
  static const String supabaseUrlEnv = 'SUPABASE_URL';
  static const String supabaseAnonKeyEnv = 'SUPABASE_ANON_KEY';

  static bool isSupabaseConfigured(String url, String anonKey) {
    final normalizedUrl = url.trim();
    final normalizedKey = anonKey.trim();

    if (normalizedUrl.isEmpty || normalizedKey.isEmpty) {
      return false;
    }

    final isPlaceholder = normalizedUrl.contains('SEU-PROJETO') ||
        normalizedUrl.contains('example.com') ||
        normalizedKey.contains('SUA_') ||
        normalizedKey.contains('YOUR_') ||
        normalizedKey.contains('REPLACE');

    if (isPlaceholder) {
      return false;
    }

    return Uri.tryParse(normalizedUrl)?.scheme.startsWith('http') == true &&
        normalizedKey.isNotEmpty;
  }
}
