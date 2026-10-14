import 'supabase_service.dart';

/// Procura uma conversa já existente entre este cliente e motorista;
/// se não houver, cria uma nova. Usado antes de abrir o ChatScreen,
/// tanto a partir do app cliente quanto do app motorista.
Future<String> getOrCreateConversation({required String userId, required String driverId}) async {
  final existing = await SupabaseService.client
      .from('conversations')
      .select('conv_id')
      .eq('user_id', userId)
      .eq('driver_id', driverId)
      .maybeSingle();

  if (existing != null) return existing['conv_id'] as String;

  final created = await SupabaseService.client
      .from('conversations')
      .insert({'user_id': userId, 'driver_id': driverId})
      .select('conv_id')
      .single();

  return created['conv_id'] as String;
}
