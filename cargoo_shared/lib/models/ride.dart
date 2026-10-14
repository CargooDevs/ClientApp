enum RideStatus {
  searching,
  driverAssigned,
  pickingUp,
  inTransit,
  delivered,
  cancelled;

  static RideStatus fromDb(String value) {
    switch (value) {
      case 'searching':
        return RideStatus.searching;
      case 'driver_assigned':
        return RideStatus.driverAssigned;
      case 'picking_up':
        return RideStatus.pickingUp;
      case 'in_transit':
        return RideStatus.inTransit;
      case 'delivered':
        return RideStatus.delivered;
      default:
        return RideStatus.cancelled;
    }
  }

  String toDb() {
    switch (this) {
      case RideStatus.searching:
        return 'searching';
      case RideStatus.driverAssigned:
        return 'driver_assigned';
      case RideStatus.pickingUp:
        return 'picking_up';
      case RideStatus.inTransit:
        return 'in_transit';
      case RideStatus.delivered:
        return 'delivered';
      case RideStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case RideStatus.searching:
        return 'Procurando motorista...';
      case RideStatus.driverAssigned:
        return 'Motorista a caminho';
      case RideStatus.pickingUp:
        return 'Chegando ao local';
      case RideStatus.inTransit:
        return 'Em trânsito';
      case RideStatus.delivered:
        return 'Concluído';
      case RideStatus.cancelled:
        return 'Cancelado';
    }
  }
}

/// Tipo de deslocamento: transporte de passageiro ou entrega de carga já
/// combinada (originada diretamente ou a partir de um [CargoPost] aceite).
enum RideType { passenger, cargo }

class Ride {
  final String rideId;
  final String userId;
  final String? driverId;
  final String pickUp;
  final String dropOff;
  final double totalFare;
  final String? paymentId;
  final RideStatus status;
  final String? convId;
  final RideType rideType;

  const Ride({
    required this.rideId,
    required this.userId,
    this.driverId,
    required this.pickUp,
    required this.dropOff,
    required this.totalFare,
    this.paymentId,
    this.status = RideStatus.searching,
    this.convId,
    this.rideType = RideType.passenger,
  });

  factory Ride.fromMap(Map<String, dynamic> map) => Ride(
        rideId: map['ride_id'] as String,
        userId: map['user_id'] as String,
        driverId: map['driver_id'] as String?,
        pickUp: map['pick_up'] as String? ?? '',
        dropOff: map['drop_off'] as String? ?? '',
        totalFare: (map['total_fare'] as num?)?.toDouble() ?? 0,
        paymentId: map['payment_id'] as String?,
        status: RideStatus.fromDb(map['status'] as String? ?? 'searching'),
        convId: map['conv_id'] as String?,
        rideType: (map['ride_type'] as String?) == 'cargo' ? RideType.cargo : RideType.passenger,
      );
}
