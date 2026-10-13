class HireBooking {
  final String hireId;
  final String userId;
  final String? driverId;
  final String vehicleId;
  final DateTime? pickupAt;
  final DateTime? returnAt;
  final String? paymentId;
  final String pickupLocation;
  final String returnLocation;
  final bool isHourly;
  final bool isDaily;
  final String? convId;
  final double price;

  const HireBooking({
    required this.hireId,
    required this.userId,
    this.driverId,
    required this.vehicleId,
    this.pickupAt,
    this.returnAt,
    this.paymentId,
    this.pickupLocation = '',
    this.returnLocation = '',
    this.isHourly = false,
    this.isDaily = false,
    this.convId,
    this.price = 0,
  });

  factory HireBooking.fromMap(Map<String, dynamic> map) => HireBooking(
        hireId: map['hire_id'] as String,
        userId: map['user_id'] as String,
        driverId: map['driver_id'] as String?,
        vehicleId: map['vehicle_id'] as String? ?? '',
        pickupAt: map['pickup_at'] != null ? DateTime.tryParse(map['pickup_at'] as String) : null,
        returnAt: map['return_at'] != null ? DateTime.tryParse(map['return_at'] as String) : null,
        paymentId: map['payment_id'] as String?,
        pickupLocation: map['pickup_location'] as String? ?? '',
        returnLocation: map['return_location'] as String? ?? '',
        isHourly: map['is_hourly'] as bool? ?? false,
        isDaily: map['is_daily'] as bool? ?? false,
        convId: map['conv_id'] as String?,
        price: (map['price'] as num?)?.toDouble() ?? 0,
      );
}
