import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> init({required String url, required String anonKey}) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static String? get uid => client.auth.currentUser?.id;

  static Stream<AuthState> get authChanges => client.auth.onAuthStateChange;
}
