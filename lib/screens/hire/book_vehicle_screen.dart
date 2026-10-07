import 'package:flutter/material.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import '../history/history_screen.dart';

class BookVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  const BookVehicleScreen({super.key, required this.vehicle});

  @override
  State<BookVehicleScreen> createState() => _BookVehicleScreenState();
}

class _BookVehicleScreenState extends State<BookVehicleScreen> {
  final _pickupLocationController = TextEditingController(text: 'Minha localização atual');
  bool _isHourly = true;
  int _units = 4; // horas ou dias, dependendo do modo
  bool _booking = false;

  double get _estimatedPrice {
    final rate = _isHourly ? 2500.0 : 15000.0; // taxa base estimada — ajustar depois com dados reais
    return rate * _units;
  }

  Future<void> _confirm() async {
    setState(() => _booking = true);
    try {
      final now = DateTime.now();
      final returnAt = _isHourly ? now.add(Duration(hours: _units)) : now.add(Duration(days: _units));

      await SupabaseService.client.from('hire_bookings').insert({
        'user_id': SupabaseService.uid,
        'driver_id': widget.vehicle.driverId,
        'vehicle_id': widget.vehicle.vehicleId,
        'pickup_at': now.toIso8601String(),
        'return_at': returnAt.toIso8601String(),
        'pickup_location': _pickupLocationController.text,
        'return_location': _pickupLocationController.text,
        'is_hourly': _isHourly,
        'is_daily': !_isHourly,
        'price': _estimatedPrice,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva confirmada!')));
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HistoryScreen()), (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _booking = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível reservar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar aluguer')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
              child: Row(children: [
                const Icon(Icons.directions_car_filled_outlined, color: AppColors.secondary, size: 32),
                const SizedBox(width: 14),
                Text('${v.brand} ${v.model} · ${v.plateNumber}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 20),
            CustomTextField(label: 'Local de levantamento', controller: _pickupLocationController, prefixIcon: Icons.location_on_outlined),
            const SizedBox(height: 20),
            const Text('Tipo de aluguer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: ChoiceChip(label: const Text('Por hora'), selected: _isHourly, onSelected: (_) => setState(() { _isHourly = true; _units = 4; }))),
              const SizedBox(width: 10),
              Expanded(child: ChoiceChip(label: const Text('Por dia'), selected: !_isHourly, onSelected: (_) => setState(() { _isHourly = false; _units = 1; }))),
            ]),
            const SizedBox(height: 20),
            Text(_isHourly ? 'Número de horas' : 'Número de dias', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Row(children: [
              IconButton(onPressed: () => setState(() => _units = (_units - 1).clamp(1, 999)), icon: const Icon(Icons.remove_circle_outline)),
              Text('$_units', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              IconButton(onPressed: () => setState(() => _units += 1), icon: const Icon(Icons.add_circle_outline)),
            ]),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total estimado', style: TextStyle(color: AppColors.textSecondary)),
              Text('Kz ${_estimatedPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 14),
            CustomButton(label: 'Confirmar reserva', loading: _booking, onPressed: _confirm),
          ]),
        ),
      ),
    );
  }
}
