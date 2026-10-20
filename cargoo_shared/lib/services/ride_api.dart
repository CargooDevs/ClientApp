import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ride.dart';
import 'supabase_service.dart';

class RideApi {
  final SupabaseClient _client;

  RideApi({SupabaseClient? client}) : _client = client ?? SupabaseService.client;

  Future<Ride> acceptPassengerRide(String rideId) async {
    final result = await _client.rpc(
      'accept_passenger_ride',
      params: {'p_ride_id': rideId},
    );
    if (result is! Map) {
      throw const FormatException(
        'A API de aceitação devolveu uma resposta inválida.',
      );
    }

    return Ride.fromMap(Map<String, dynamic>.from(result));
  }
}
