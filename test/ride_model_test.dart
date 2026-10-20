import 'package:cargoo_shared/cargoo_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RideStatus', () {
    test('maps the initial database states to searching', () {
      expect(RideStatus.fromDb('requested'), RideStatus.searching);
      expect(RideStatus.fromDb('searching'), RideStatus.searching);
      expect(RideStatus.fromDb('cancelled'), RideStatus.cancelled);
    });

    test('does not misreport unknown database states as cancelled', () {
      expect(RideStatus.fromDb('unknown'), RideStatus.unknown);
    });
  });

  test('parses an unassigned searching ride', () {
    final ride = Ride.fromMap({
      'ride_id': 'ride-id',
      'user_id': 'user-id',
      'driver_id': null,
      'pick_up': 'Pickup',
      'drop_off': 'Drop-off',
      'total_fare': 0,
      'status': 'searching',
      'ride_type': 'passenger',
    });

    expect(ride.driverId, isNull);
    expect(ride.status, RideStatus.searching);
    expect(ride.rideType, RideType.passenger);
  });
}
