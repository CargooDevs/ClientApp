import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/core_models.dart';
import '../models/driver.dart';
import '../models/post.dart';
import '../models/ride.dart';
import 'supabase_service.dart';

class CreateCargoPostRequest {
  final String title;
  final String description;
  final double? cargoWeightKg;
  final bool isFragile;
  final bool needsHelper;
  final String vehicleTypeId;
  final String pickupAddress;
  final String dropoffAddress;

  const CreateCargoPostRequest({
    required this.title,
    required this.description,
    required this.cargoWeightKg,
    required this.isFragile,
    required this.needsHelper,
    required this.vehicleTypeId,
    required this.pickupAddress,
    required this.dropoffAddress,
  });
}

class CargoCandidateOffer {
  final PostCandidate candidate;
  final Driver? driver;

  const CargoCandidateOffer({required this.candidate, this.driver});
}

class CargoApi {
  final SupabaseClient _client;

  CargoApi({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  Future<List<VehicleType>> loadVehicleTypes() async {
    final rows = await _client.from('vehicle_types').select();
    return rows.map(VehicleType.fromMap).toList();
  }

  Future<CargoPost> createPost(CreateCargoPostRequest request) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('É necessário iniciar sessão para publicar uma carga.');
    }

    final pickupAddress = request.pickupAddress.trim();
    final dropoffAddress = request.dropoffAddress.trim();
    if (pickupAddress.isEmpty || dropoffAddress.isEmpty) {
      throw ArgumentError('Informe os locais de coleta e entrega.');
    }
    if (request.cargoWeightKg != null &&
        (!request.cargoWeightKg!.isFinite || request.cargoWeightKg! < 0)) {
      throw ArgumentError.value(
        request.cargoWeightKg,
        'cargoWeightKg',
        'O peso deve ser um número válido e não negativo.',
      );
    }

    final row = await _client
        .from('posts')
        .insert({
          'user_id': userId,
          'title': request.title.trim().isEmpty
              ? 'Envio de carga'
              : request.title.trim(),
          'status': 'open',
          'vehicle_type_id': request.vehicleTypeId,
          'category': 'cargo',
          'description': request.description.trim(),
          'cargo_weight_kg': request.cargoWeightKg,
          'is_fragile': request.isFragile,
          'needs_helper': request.needsHelper,
          'pickup_address': pickupAddress,
          'dropoff_address': dropoffAddress,
        })
        .select()
        .single();

    return CargoPost.fromMap(row);
  }

  Stream<List<CargoCandidateOffer>> watchPendingOffers(String postId) {
    return _client
        .from('post_candidates')
        .stream(primaryKey: ['candidate_id'])
        .eq('post_id', postId)
        .asyncMap((rows) async {
      final candidates = rows
          .map(PostCandidate.fromMap)
          .where((offer) => offer.status == 'pending')
          .toList();
      final driverRows = candidates.isEmpty
          ? <Map<String, dynamic>>[]
          : await _client.rpc(
              'get_cargo_offer_driver_profiles',
              params: {'p_post_id': postId},
            );
      final drivers = <String, Driver>{
        for (final row in driverRows)
          row['driver_id'] as String: Driver.fromMap(row),
      };

      return candidates
          .map((candidate) => CargoCandidateOffer(
                candidate: candidate,
                driver: drivers[candidate.driverId],
              ))
          .toList();
    });
  }

  Future<Ride> acceptOffer(String candidateId) async {
    final result = await _client.rpc(
      'accept_cargo_candidate',
      params: {'p_candidate_id': candidateId},
    );
    if (result is! Map) {
      throw const FormatException(
        'A API de aceitação devolveu uma resposta inválida.',
      );
    }

    return Ride.fromMap(Map<String, dynamic>.from(result));
  }
}
