import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import 'book_vehicle_screen.dart';

class BrowseVehiclesScreen extends StatefulWidget {
  const BrowseVehiclesScreen({super.key});

  @override
  State<BrowseVehiclesScreen> createState() => _BrowseVehiclesScreenState();
}

class _BrowseVehiclesScreenState extends State<BrowseVehiclesScreen> {
  List<Vehicle> _vehicles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await SupabaseService.client.from('vehicles').select();
      if (mounted) {
        setState(() {
          _vehicles = (rows as List)
              .map((row) => Vehicle.fromMap(row as Map<String, dynamic>))
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _assetForVehicle(Vehicle vehicle) {
    switch (vehicle.vehicleTypeId.toLowerCase()) {
      case 'moto':
        return 'assets/images/client/vehicle_moto.svg';
      case 'van':
        return 'assets/images/client/vehicle_van.svg';
      case 'truck':
        return 'assets/images/client/vehicle_truck.svg';
      default:
        return 'assets/images/client/vehicle_utility.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alugar veículo')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _vehicles.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum veículo disponível no momento.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final vehicle = _vehicles[index];
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookVehicleScreen(vehicle: vehicle),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 72,
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SvgPicture.asset(
                                  _assetForVehicle(vehicle),
                                  width: 68,
                                  height: 42,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${vehicle.brand} ${vehicle.model}'
                                                    .trim()
                                                    .isEmpty
                                                ? 'Veículo'
                                                : '${vehicle.brand} ${vehicle.model}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (vehicle.isPremium) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.warning.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'PREMIUM',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.warning,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${vehicle.year ?? ''} · ${vehicle.plateNumber}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
