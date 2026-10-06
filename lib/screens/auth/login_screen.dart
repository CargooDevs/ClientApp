import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await SupabaseService.client.auth.signInWithPassword(email: _emailController.text.trim(), password: _passwordController.text);
      if (response.user != null && mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Não foi possível entrar. Verifique a sua ligação e tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 24),
            Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 34)),
            const SizedBox(height: 24),
            const Text('Bem-vindo de volta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Entre para continuar', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            CustomTextField(label: 'E-mail', hint: 'voce@exemplo.com', controller: _emailController, prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 18),
            CustomTextField(label: 'Senha', hint: '••••••••', controller: _passwordController, prefixIcon: Icons.lock_outline, obscureText: true),
            if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12.5))],
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Esqueci a senha'))),
            const SizedBox(height: 8),
            CustomButton(label: 'Entrar', loading: _loading, onPressed: _login),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: RichText(text: const TextSpan(style: TextStyle(color: AppColors.textSecondary), children: [
                  TextSpan(text: 'Não tem conta? '),
                  TextSpan(text: 'Cadastre-se', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ])),
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('É motorista/transportador? Baixe o app Cargoo Motorista.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5))),
          ]),
        ),
      ),
    );
  }
}
