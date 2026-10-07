import 'package:flutter/material.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import '../ride/ride_tracking_screen.dart';

class PostCandidatesScreen extends StatefulWidget {
  final CargoPost post;
  const PostCandidatesScreen({super.key, required this.post});

  @override
  State<PostCandidatesScreen> createState() => _PostCandidatesScreenState();
}

class _PostCandidatesScreenState extends State<PostCandidatesScreen> {
  List<Map<String, dynamic>> _candidates = [];
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    SupabaseService.client
        .from('post_candidates')
        .stream(primaryKey: ['candidate_id'])
        .eq('post_id', widget.post.postId)
        .listen((rows) async {
      final enriched = <Map<String, dynamic>>[];
      for (final r in rows) {
        final driver = await SupabaseService.client.from('drivers').select('full_name, rating').eq('driver_id', r['driver_id']).maybeSingle();
        enriched.add({...r, 'driver_name': driver?['full_name'] ?? 'Motorista', 'driver_rating': driver?['rating'] ?? 5.0});
      }
      if (mounted) setState(() => _candidates = enriched);
    });
  }

  Future<void> _accept(Map<String, dynamic> candidate) async {
    setState(() => _accepting = true);
    try {
      // Cria a Ride real a partir da proposta aceite.
      final ride = await SupabaseService.client.from('rides').insert({
        'user_id': widget.post.userId,
        'driver_id': candidate['driver_id'],
        'pick_up': widget.post.pickupAddress,
        'drop_off': widget.post.dropoffAddress,
        'total_fare': candidate['proposed_price'],
        'status': 'driver_assigned',
        'ride_type': 'cargo',
      }).select().single();

      await SupabaseService.client.from('posts').update({'status': 'matched', 'ride_id': ride['ride_id']}).eq('post_id', widget.post.postId);
      await SupabaseService.client.from('post_candidates').update({'status': 'accepted'}).eq('candidate_id', candidate['candidate_id']);

      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RideTrackingScreen(ride: Ride.fromMap(ride))));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _accepting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível aceitar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Propostas recebidas')),
      body: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.secondary,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.post.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 4),
              Text('${widget.post.pickupAddress} → ${widget.post.dropoffAddress}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          Expanded(
            child: _candidates.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Aguardando propostas de motoristas...\nIsto atualiza automaticamente.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary))))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _candidates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final c = _candidates[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                        child: Row(children: [
                          CircleAvatar(radius: 22, backgroundColor: AppColors.secondary.withValues(alpha: 0.1), child: const Icon(Icons.person, color: AppColors.secondary)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c['driver_name'], style: const TextStyle(fontWeight: FontWeight.w700)),
                              Row(children: [const Icon(Icons.star, size: 13, color: AppColors.warning), const SizedBox(width: 3), Text('${c['driver_rating']}', style: const TextStyle(fontSize: 12))]),
                            ]),
                          ),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('Kz ${(c['proposed_price'] as num?)?.toStringAsFixed(0) ?? '?'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14), textStyle: const TextStyle(fontSize: 12)),
                                onPressed: _accepting ? null : () => _accept(c),
                                child: const Text('Aceitar'),
                              ),
                            ),
                          ]),
                        ]),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
