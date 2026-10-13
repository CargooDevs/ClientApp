import 'package:flutter/material.dart';

class AppUser {
  final String userId;
  final String name;
  final String surname;
  final String email;
  final String phone;

  const AppUser({required this.userId, required this.name, this.surname = '', required this.email, this.phone = ''});

  String get fullName => surname.isEmpty ? name : '$name $surname';

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        userId: map['user_id'] as String,
        name: map['name'] as String? ?? '',
        surname: map['surname'] as String? ?? '',
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
      );
}

class Fleet {
  final String fleetId;
  final String name;
  final String email;
  final String phone;

  const Fleet({required this.fleetId, required this.name, this.email = '', this.phone = ''});

  factory Fleet.fromMap(Map<String, dynamic> map) => Fleet(
        fleetId: map['fleet_id'] as String,
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
      );
}

class VehicleType {
  final String id;
  final String name;
  final double basePrice;
  final double pricePerKm;

  const VehicleType({required this.id, required this.name, this.basePrice = 0, this.pricePerKm = 0});

  double estimateFor(double distanceKm) => basePrice + (distanceKm * pricePerKm);

  IconData get icon {
    switch (id) {
      case 'moto':
        return Icons.two_wheeler;
      case 'van':
        return Icons.airport_shuttle_outlined;
      case 'truck':
        return Icons.fire_truck_outlined;
      default:
        return Icons.local_shipping_outlined;
    }
  }

  factory VehicleType.fromMap(Map<String, dynamic> map) => VehicleType(
        id: map['vehicle_type_id'] as String,
        name: map['name'] as String? ?? '',
        basePrice: (map['base_price'] as num?)?.toDouble() ?? 0,
        pricePerKm: (map['price_per_km'] as num?)?.toDouble() ?? 0,
      );

  static const List<VehicleType> fallback = [
    VehicleType(id: 'moto', name: 'Moto', basePrice: 6.0, pricePerKm: 1.2),
    VehicleType(id: 'hatch', name: 'Carro Utilitário', basePrice: 12.0, pricePerKm: 1.8),
    VehicleType(id: 'van', name: 'Van', basePrice: 25.0, pricePerKm: 2.6),
    VehicleType(id: 'truck', name: 'Caminhão 3/4', basePrice: 60.0, pricePerKm: 4.2),
  ];
}

class Vehicle {
  final String vehicleId;
  final String? fleetId;
  final String driverId;
  final String vehicleTypeId;
  final String plateNumber;
  final int? year;
  final String brand;
  final String model;
  final String? image;
  final bool isPremium;

  const Vehicle({
    required this.vehicleId,
    this.fleetId,
    required this.driverId,
    required this.vehicleTypeId,
    this.plateNumber = '',
    this.year,
    this.brand = '',
    this.model = '',
    this.image,
    this.isPremium = false,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) => Vehicle(
        vehicleId: map['vehicle_id'] as String,
        fleetId: map['fleet_id'] as String?,
        driverId: map['driver_id'] as String? ?? '',
        vehicleTypeId: map['vehicle_type_id'] as String? ?? '',
        plateNumber: map['plate_number'] as String? ?? '',
        year: map['year'] as int?,
        brand: map['brand'] as String? ?? '',
        model: map['model'] as String? ?? '',
        image: map['image'] as String?,
        isPremium: map['is_premium'] as bool? ?? false,
      );
}
