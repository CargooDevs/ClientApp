import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import '../home/home_screen.dart';

class RideTrackingScreen extends StatefulWidget {
  final Ride ride;
  const RideTrackingScreen({super.key, required this.ride});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  late Ride _ride;
  late RideStatus _status;
  Map<String, dynamic>? _driverData;
  StreamSubscription<List<Map<String, dynamic>>>? _rideSubscription;
  bool _cancelling = false;

  final _stages = const [
    RideStatus.searching,
    RideStatus.driverAssigned,
    RideStatus.pickingUp,
    RideStatus.inTransit,
    RideStatus.delivered
  ];

  @override
  void initState() {
    super.initState();
    _ride = widget.ride;
    _status = _ride.status;
    if (_ride.driverId != null) _loadDriver(_ride.driverId!);
    _subscribe();
  }

  void _subscribe() {
    _rideSubscription = SupabaseService.client
        .from('rides')
        .stream(primaryKey: ['ride_id'])
        .eq('ride_id', _ride.rideId)
        .listen((rows) {
          if (rows.isEmpty || !mounted) return;
          final updatedRide = Ride.fromMap(rows.first);
          setState(() {
            _ride = updatedRide;
            _status = updatedRide.status;
          });
          if (updatedRide.driverId != null && _driverData == null) {
            _loadDriver(updatedRide.driverId!);
          }
        }, onError: (Object error, StackTrace stackTrace) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Não foi possível atualizar a corrida: $error')),
            );
          }
        });
  }

  Future<void> _loadDriver(String driverId) async {
    try {
      final driver = await SupabaseService.client
          .from('drivers')
          .select('*, vehicles(plate_number, model)')
          .eq('driver_id', driverId)
          .maybeSingle();
      if (mounted) setState(() => _driverData = driver);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Não foi possível carregar o motorista: $error')),
        );
      }
    }
  }

  Future<void> _openChat() async {
    final driverId = _ride.driverId;
    if (driverId == null) return;
    final convId = _ride.convId ??
        await getOrCreateConversation(userId: _ride.userId, driverId: driverId);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(
        convId: convId,
        otherPartyName: _driverData?['full_name'] ?? 'Motorista',
        isDriver: false,
        otherUserId: driverId,
      ),
    ));
  }

  Future<void> _cancelRide() async {
    setState(() => _cancelling = true);
    try {
      final cancelled = await SupabaseService.client
          .from('rides')
          .update({'status': 'cancelled'})
          .eq('ride_id', _ride.rideId)
          .eq('status', 'searching')
          .select('ride_id')
          .maybeSingle();
      if (cancelled == null) {
        throw StateError('A corrida já foi atribuída ou cancelada.');
      }
      if (mounted) setState(() => _status = RideStatus.cancelled);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível cancelar a corrida: $error')),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  void dispose() {
    unawaited(_rideSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stageIndex = _stages.indexOf(_status);
    final vehicles = _driverData?['vehicles'];
    final vehicle =
        (vehicles is List && vehicles.isNotEmpty) ? vehicles.first : null;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Container(
              color: const Color(0xFFE8ECF1),
              width: double.infinity,
              child: Center(
                  child: _status == RideStatus.searching
                      ? const CircularProgressIndicator(
                          color: AppColors.primary)
                      : Icon(
                          _ride.rideType == RideType.cargo
                              ? Icons.local_shipping_outlined
                              : Icons.directions_car_filled,
                          size: 72,
                          color: AppColors.secondary)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_status.label,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  if (stageIndex >= 0)
                    Row(
                        children: List.generate(_stages.length, (i) {
                      final active = i <= stageIndex;
                      return Expanded(
                          child: Container(
                              margin: EdgeInsets.only(
                                  right: i == _stages.length - 1 ? 0 : 4),
                              height: 4,
                              decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.divider,
                                  borderRadius: BorderRadius.circular(2))));
                    })),
                  const SizedBox(height: 18),
                  if (_driverData != null) ...[
                    Row(children: [
                      CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              AppColors.secondary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person,
                              color: AppColors.secondary)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_driverData?['full_name'] ?? 'Motorista',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(
                                  '${vehicle?['model'] ?? ''} · ${vehicle?['plate_number'] ?? ''}',
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary)),
                              Row(children: [
                                const Icon(Icons.star,
                                    size: 14, color: AppColors.warning),
                                const SizedBox(width: 3),
                                Text('${_driverData?['rating'] ?? 5.0}',
                                    style: const TextStyle(fontSize: 12.5))
                              ]),
                            ]),
                      ),
                      IconButton(
                          onPressed: _openChat,
                          icon: const Icon(Icons.chat_bubble_outline,
                              color: AppColors.secondary)),
                    ]),
                    const SizedBox(height: 18),
                  ],
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Valor',
                            style: TextStyle(color: AppColors.textSecondary)),
                        Text('Kz ${_ride.totalFare.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                      ]),
                  const SizedBox(height: 16),
                  if (_status == RideStatus.searching)
                    CustomButton(
                      label: 'Cancelar pedido',
                      outlined: true,
                      loading: _cancelling,
                      onPressed: _cancelRide,
                    )
                  else if (_status == RideStatus.delivered ||
                      _status == RideStatus.cancelled ||
                      _status == RideStatus.unknown)
                    CustomButton(
                        label: 'Concluir',
                        onPressed: () => Navigator.of(context)
                            .pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const HomeScreen()),
                                (route) => false))
                  else
                    CustomButton(
                      label: 'Voltar',
                      outlined: true,
                      onPressed: () => Navigator.of(context).pop(),
                    )
                ]),
          ),
        ]),
      ),
    );
  }
}
