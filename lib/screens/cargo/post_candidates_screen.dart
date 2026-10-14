import 'dart:async';

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
  final _cargoApi = CargoApi();
  List<CargoCandidateOffer> _candidates = [];
  StreamSubscription<List<CargoCandidateOffer>>? _offersSubscription;
  bool _accepting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _offersSubscription?.cancel();
    setState(() => _loadError = null);
    _offersSubscription =
        _cargoApi.watchPendingOffers(widget.post.postId).listen((offers) {
      if (mounted) setState(() => _candidates = offers);
    }, onError: (Object error, StackTrace stackTrace) {
      if (mounted) {
        setState(() {
          _candidates = [];
          _loadError = 'Não foi possível carregar as propostas: $error';
        });
      }
    });
  }

  Future<void> _accept(CargoCandidateOffer offer) async {
    setState(() => _accepting = true);
    try {
      final ride = await _cargoApi.acceptOffer(offer.candidate.candidateId);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => RideTrackingScreen(ride: ride)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _accepting = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Não foi possível aceitar: $e')));
      }
    }
  }

  @override
  void dispose() {
    unawaited(_offersSubscription?.cancel());
    super.dispose();
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.post.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              const SizedBox(height: 4),
              Text(
                  '${widget.post.pickupAddress} → ${widget.post.dropoffAddress}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          Expanded(
            child: _loadError != null && _candidates.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_loadError!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _subscribe,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _candidates.isEmpty
                    ? const Center(
                        child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                                'Aguardando propostas de motoristas...\nIsto atualiza automaticamente.',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: AppColors.textSecondary))))
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _candidates.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final offer = _candidates[i];
                          final candidate = offer.candidate;
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.divider)),
                            child: Row(children: [
                              CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.secondary
                                      .withValues(alpha: 0.1),
                                  child: const Icon(Icons.person,
                                      color: AppColors.secondary)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          offer.driver?.fullName.isNotEmpty ==
                                                  true
                                              ? offer.driver!.fullName
                                              : 'Motorista',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700)),
                                      if (offer.driver != null)
                                        Row(children: [
                                          const Icon(Icons.star,
                                              size: 13,
                                              color: AppColors.warning),
                                          const SizedBox(width: 3),
                                          Text(
                                              offer.driver!.rating
                                                  .toStringAsFixed(1),
                                              style:
                                                  const TextStyle(fontSize: 12))
                                        ]),
                                    ]),
                              ),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        'Kz ${candidate.proposedPrice?.toStringAsFixed(0) ?? '?'}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      height: 32,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14),
                                            textStyle:
                                                const TextStyle(fontSize: 12)),
                                        onPressed: _accepting
                                            ? null
                                            : () => _accept(offer),
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
