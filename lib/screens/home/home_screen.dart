import 'package:flutter/material.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import '../cargo/create_post_screen.dart';
import '../ride/request_ride_screen.dart';
import '../hire/browse_vehicles_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [const _HomeTab(), const HistoryScreen(embedded: true), const ProfileScreen(embedded: true)];

    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: AppColors.surface,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Atividade'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          const Text('O que precisa hoje?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Escolha um serviço para começar', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          _ServiceCard(
            icon: Icons.inventory_2_outlined,
            color: AppColors.primary,
            title: 'Enviar carga',
            subtitle: 'Publique o pedido e receba propostas de motoristas',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreatePostScreen())),
          ),
          const SizedBox(height: 14),
          _ServiceCard(
            icon: Icons.directions_car_filled_outlined,
            color: AppColors.secondary,
            title: 'Pedir corrida',
            subtitle: 'Transporte de passageiro, motorista atribuído na hora',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RequestRideScreen())),
          ),
          const SizedBox(height: 14),
          _ServiceCard(
            icon: Icons.time_to_leave_outlined,
            color: AppColors.success,
            title: 'Alugar veículo',
            subtitle: 'Por hora ou por dia, com ou sem motorista',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BrowseVehiclesScreen())),
          ),
        ]),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ServiceCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.divider)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 26)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}
