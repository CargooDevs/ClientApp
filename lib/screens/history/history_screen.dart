import 'package:flutter/material.dart';
import 'package:cargoo_shared/cargoo_shared.dart';

class HistoryScreen extends StatelessWidget {
  final bool embedded;
  const HistoryScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final content = DefaultTabController(
      length: 3,
      child: Column(children: [
        if (!embedded) const SizedBox(height: 8),
        const TabBar(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [Tab(text: 'Cargas'), Tab(text: 'Corridas'), Tab(text: 'Aluguéis')],
        ),
        const Expanded(child: TabBarView(children: [_PostsHistory(), _RidesHistory(rideType: 'passenger'), _HireHistory()])),
      ]),
    );

    if (embedded) {
      return SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 4), child: Text('Atividade', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
          Expanded(child: content),
        ]),
      );
    }
    return Scaffold(appBar: AppBar(title: const Text('Atividade')), body: content);
  }
}

class _PostsHistory extends StatelessWidget {
  const _PostsHistory();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SupabaseService.client.from('posts').select().eq('user_id', SupabaseService.uid as Object).order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data as List;
        if (items.isEmpty) return const Center(child: Text('Nenhum pedido de carga ainda.', style: TextStyle(color: AppColors.textSecondary)));
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final item = items[i] as Map<String, dynamic>;
            return _HistoryTile(icon: Icons.inventory_2_outlined, title: item['title'] ?? '', subtitle: item['status'] ?? '', trailing: item['dropoff_address'] ?? '');
          },
        );
      },
    );
  }
}

class _RidesHistory extends StatelessWidget {
  final String rideType;
  const _RidesHistory({required this.rideType});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SupabaseService.client.from('rides').select().eq('user_id', SupabaseService.uid as Object).eq('ride_type', rideType).order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data as List;
        if (items.isEmpty) return const Center(child: Text('Nenhuma corrida ainda.', style: TextStyle(color: AppColors.textSecondary)));
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final item = items[i] as Map<String, dynamic>;
            return _HistoryTile(icon: Icons.directions_car_filled_outlined, title: item['drop_off'] ?? '', subtitle: item['status'] ?? '', trailing: 'Kz ${(item['total_fare'] as num?)?.toStringAsFixed(0) ?? '0'}');
          },
        );
      },
    );
  }
}

class _HireHistory extends StatelessWidget {
  const _HireHistory();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SupabaseService.client.from('hire_bookings').select().eq('user_id', SupabaseService.uid as Object).order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data as List;
        if (items.isEmpty) return const Center(child: Text('Nenhum aluguer ainda.', style: TextStyle(color: AppColors.textSecondary)));
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final item = items[i] as Map<String, dynamic>;
            return _HistoryTile(icon: Icons.time_to_leave_outlined, title: item['pickup_location'] ?? '', subtitle: item['is_hourly'] == true ? 'Por hora' : 'Por dia', trailing: 'Kz ${(item['price'] as num?)?.toStringAsFixed(0) ?? '0'}');
          },
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

  const _HistoryTile({required this.icon, required this.title, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.06), shape: BoxShape.circle), child: Icon(icon, color: AppColors.secondary, size: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
        Text(trailing, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ]),
    );
  }
}
