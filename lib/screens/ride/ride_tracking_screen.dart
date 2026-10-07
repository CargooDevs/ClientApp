import 'package:flutter/material.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import '../home/home_screen.dart';

class RideTrackingScreen extends StatefulWidget {
  final Ride ride;
  const RideTrackingScreen({super.key, required this.ride});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  late RideStatus _status;
  Map<String, dynamic>? _driverData;

  final _stages = const [RideStatus.searching, RideStatus.driverAssigned, RideStatus.pickingUp, RideStatus.inTransit, RideStatus.delivered];

  @override
  void initState() {
    super.initState();
    _status = widget.ride.status;
    if (widget.ride.driverId != null) _loadDriver(widget.ride.driverId!);
    _subscribe();
  }

  void _subscribe() {
    SupabaseService.client.from('rides').stream(primaryKey: ['ride_id']).eq('ride_id', widget.ride.rideId).listen((rows) {
      if (rows.isEmpty || !mounted) return;
      final ride = Ride.fromMap(rows.first);
      setState(() => _status = ride.status);
      if (ride.driverId != null && _driverData == null) _loadDriver(ride.driverId!);
    });
  }

  Future<void> _loadDriver(String driverId) async {
    final driver = await SupabaseService.client.from('drivers').select('*, vehicles(plate_number, model)').eq('driver_id', driverId).maybeSingle();
    if (mounted) setState(() => _driverData = driver);
  }

  Future<void> _openChat() async {
    final driverId = widget.ride.driverId;
    if (driverId == null) return;
    final convId = widget.ride.convId ?? await getOrCreateConversation(userId: widget.ride.userId, driverId: driverId);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(convId: convId, otherPartyName: _driverData?['full_name'] ?? 'Motorista', isDriver: false, otherUserId: driverId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final stageIndex = _stages.indexOf(_status);
    final vehicles = _driverData?['vehicles'];
    final vehicle = (vehicles is List && vehicles.isNotEmpty) ? vehicles.first : null;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Container(
              color: const Color(0xFFE8ECF1), width: double.infinity,
              child: Center(child: _status == RideStatus.searching ? const CircularProgressIndicator(color: AppColors.primary) : Icon(widget.ride.rideType == RideType.cargo ? Icons.local_shipping_outlined : Icons.directions_car_filled, size: 72, color: AppColors.secondary)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(_status.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              if (stageIndex >= 0)
                Row(children: List.generate(_stages.length, (i) {
                  final active = i <= stageIndex;
                  return Expanded(child: Container(margin: EdgeInsets.only(right: i == _stages.length - 1 ? 0 : 4), height: 4, decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.divider, borderRadius: BorderRadius.circular(2))));
                })),
              const SizedBox(height: 18),
              if (_driverData != null) ...[
                Row(children: [
                  CircleAvatar(radius: 26, backgroundColor: AppColors.secondary.withValues(alpha: 0.1), child: const Icon(Icons.person, color: AppColors.secondary)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_driverData?['full_name'] ?? 'Motorista', style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('${vehicle?['model'] ?? ''} · ${vehicle?['plate_number'] ?? ''}', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      Row(children: [const Icon(Icons.star, size: 14, color: AppColors.warning), const SizedBox(width: 3), Text('${_driverData?['rating'] ?? 5.0}', style: const TextStyle(fontSize: 12.5))]),
                    ]),
                  ),
                  IconButton(onPressed: _openChat, icon: const Icon(Icons.chat_bubble_outline, color: AppColors.secondary)),
                ]),
                const SizedBox(height: 18),
              ],
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Valor', style: TextStyle(color: AppColors.textSecondary)),
                Text('Kz ${widget.ride.totalFare.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ]),
              const SizedBox(height: 16),
              if (_status == RideStatus.delivered)
                CustomButton(label: 'Concluir', onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false))
              else
                CustomButton(label: 'Cancelar', outlined: true, onPressed: () async {
                  await SupabaseService.client.from('rides').update({'status': 'cancelled'}).eq('ride_id', widget.ride.rideId);
                  if (context.mounted) Navigator.of(context).pop();
                }),
            ]),
          ),
        ]),
      ),
    );
  }
}
