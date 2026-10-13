class Driver {
  final String driverId;
  final String? fleetId;
  final String fullName;
  final String phone;
  final String email;
  final String licenseNumber;
  final String status; // pending, verified, rejected, suspended
  final double rating;
  final double driverCashBal;

  const Driver({
    required this.driverId,
    this.fleetId,
    this.fullName = '',
    this.phone = '',
    this.email = '',
    this.licenseNumber = '',
    this.status = 'pending',
    this.rating = 5.0,
    this.driverCashBal = 0,
  });

  bool get isVerified => status == 'verified';

  factory Driver.fromMap(Map<String, dynamic> map) => Driver(
        driverId: map['driver_id'] as String,
        fleetId: map['fleet_id'] as String?,
        fullName: map['full_name'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        email: map['email'] as String? ?? '',
        licenseNumber: map['license_number'] as String? ?? '',
        status: map['status'] as String? ?? 'pending',
        rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
        driverCashBal: (map['driver_cash_bal'] as num?)?.toDouble() ?? 0,
      );
}
