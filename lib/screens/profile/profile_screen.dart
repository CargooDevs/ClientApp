import 'package:flutter/material.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    final name = user?.userMetadata?['name'] as String? ?? 'Utilizador Cargoo';
    final surname = user?.userMetadata?['surname'] as String? ?? '';
    final phone = user?.userMetadata?['phone'] as String? ?? user?.email ?? '';

    final content = SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            const CircleAvatar(radius: 34, backgroundColor: AppColors.secondary, child: Icon(Icons.person, color: Colors.white, size: 34)),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$name $surname'.trim(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(phone, style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ]),
          const SizedBox(height: 28),
          const _MenuTile(icon: Icons.credit_card_outlined, label: 'Pagamentos'),
          const _MenuTile(icon: Icons.location_on_outlined, label: 'Endereços salvos'),
          const _MenuTile(icon: Icons.notifications_outlined, label: 'Notificações'),
          const _MenuTile(icon: Icons.help_outline, label: 'Ajuda e suporte'),
          const _MenuTile(icon: Icons.description_outlined, label: 'Termos e privacidade'),
          const SizedBox(height: 12),
          _MenuTile(icon: Icons.logout, label: 'Sair', color: AppColors.error, onTap: () async {
            await SupabaseService.client.auth.signOut();
            if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
          }),
        ],
      ),
    );

    if (embedded) return content;
    return Scaffold(appBar: AppBar(title: const Text('Perfil')), body: content);
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _MenuTile({required this.icon, required this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.secondary),
      title: Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap ?? () {},
    );
  }
}
