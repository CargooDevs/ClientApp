import 'package:flutter/material.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import 'ride_tracking_screen.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _pickupController.addListener(_onLocationsChanged);
    _dropoffController.addListener(_onLocationsChanged);
  }

  void _onLocationsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _request() async {
    final userId = SupabaseService.uid;
    final pickup = _pickupController.text.trim();
    final dropoff = _dropoffController.text.trim();
    if (userId == null || pickup.isEmpty || dropoff.isEmpty) return;

    setState(() => _requesting = true);
    try {
      final row = await SupabaseService.client.from('rides').insert({
        'user_id': userId,
        'pick_up': pickup,
        'drop_off': dropoff,
        'total_fare': 0,
        'status': 'searching',
        'ride_type': 'passenger',
      }).select().single();

      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RideTrackingScreen(ride: Ride.fromMap(row))));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _requesting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível pedir a corrida: $e')));
      }
    }
  }

  @override
  void dispose() {
    _pickupController
      ..removeListener(_onLocationsChanged)
      ..dispose();
    _dropoffController
      ..removeListener(_onLocationsChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedir corrida')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Para onde vamos?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(children: [
              const Icon(Icons.my_location, color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _pickupController, decoration: const InputDecoration(labelText: 'Local de partida', hintText: 'Insira o endereço de partida'))),
            ]),
            const Padding(padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12), child: SizedBox(height: 20, child: VerticalDivider(color: AppColors.divider, thickness: 2))),
            Row(children: [
              const Icon(Icons.location_on, color: AppColors.error, size: 20),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _dropoffController, decoration: const InputDecoration(labelText: 'Destino'))),
            ]),
            const Spacer(),
            CustomButton(label: 'Pedir corrida agora', loading: _requesting, onPressed: _pickupController.text.trim().isEmpty || _dropoffController.text.trim().isEmpty ? null : _request),
          ]),
        ),
      ),
    );
  }
}
