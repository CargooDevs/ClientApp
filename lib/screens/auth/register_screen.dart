import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await SupabaseService.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'name': _nameController.text.trim(),
          'surname': _surnameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'user_type': 'client',
        },
      );
      if (response.user != null && mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Não foi possível criar a conta. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Bem-vindo à Cargoo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Crie a sua conta para começar.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            CustomTextField(label: 'Nome', hint: 'Primeiro nome', controller: _nameController, prefixIcon: Icons.person_outline),
            const SizedBox(height: 16),
            CustomTextField(label: 'Apelido', hint: 'Sobrenome', controller: _surnameController, prefixIcon: Icons.person_outline),
            const SizedBox(height: 16),
            CustomTextField(label: 'Telefone', hint: '+244 9XX XXX XXX', controller: _phoneController, prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            CustomTextField(label: 'E-mail', hint: 'voce@exemplo.com', controller: _emailController, prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            CustomTextField(label: 'Senha', hint: 'Crie uma senha segura', controller: _passwordController, prefixIcon: Icons.lock_outline, obscureText: true),
            if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12.5))],
            const SizedBox(height: 28),
            CustomButton(label: 'Criar conta', loading: _loading, onPressed: _register),
          ]),
        ),
      ),
    );
  }
}
