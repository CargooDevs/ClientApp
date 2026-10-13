/// Um pedido publicado pelo cliente — hoje usado para carga, com `category`
/// pronto para também cobrir outros tipos de post no futuro.
class CargoPost {
  final String postId;
  final String userId;
  final String? rideId;
  final String status; // open, matched, completed, cancelled
  final String vehicleTypeId;
  final String category; // cargo, ride, hire
  final String title;
  final String? description;
  final double? cargoWeightKg;
  final bool isFragile;
  final bool needsHelper;
  final String pickupAddress;
  final String dropoffAddress;
  final DateTime? createdAt;

  const CargoPost({
    required this.postId,
    required this.userId,
    this.rideId,
    this.status = 'open',
    required this.vehicleTypeId,
    this.category = 'cargo',
    required this.title,
    this.description,
    this.cargoWeightKg,
    this.isFragile = false,
    this.needsHelper = false,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.createdAt,
  });

  factory CargoPost.fromMap(Map<String, dynamic> map) => CargoPost(
        postId: map['post_id'] as String,
        userId: map['user_id'] as String,
        rideId: map['ride_id'] as String?,
        status: map['status'] as String? ?? 'open',
        vehicleTypeId: map['vehicle_type_id'] as String? ?? '',
        category: map['category'] as String? ?? 'cargo',
        title: map['title'] as String? ?? '',
        description: map['description'] as String?,
        cargoWeightKg: (map['cargo_weight_kg'] as num?)?.toDouble(),
        isFragile: map['is_fragile'] as bool? ?? false,
        needsHelper: map['needs_helper'] as bool? ?? false,
        pickupAddress: map['pickup_address'] as String? ?? '',
        dropoffAddress: map['dropoff_address'] as String? ?? '',
        createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      );
}

/// Proposta de um motorista para cumprir um [CargoPost].
class PostCandidate {
  final String candidateId;
  final String postId;
  final String driverId;
  final String? convId;
  final double? proposedPrice;
  final String status; // pending, accepted, rejected

  const PostCandidate({
    required this.candidateId,
    required this.postId,
    required this.driverId,
    this.convId,
    this.proposedPrice,
    this.status = 'pending',
  });

  factory PostCandidate.fromMap(Map<String, dynamic> map) => PostCandidate(
        candidateId: map['candidate_id'] as String,
        postId: map['post_id'] as String,
        driverId: map['driver_id'] as String,
        convId: map['conv_id'] as String?,
        proposedPrice: (map['proposed_price'] as num?)?.toDouble(),
        status: map['status'] as String? ?? 'pending',
      );
}
