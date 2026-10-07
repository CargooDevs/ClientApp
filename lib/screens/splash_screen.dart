import 'package:flutter/material.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/images/client/cargoo_wordmark.png',
              width: 240, fit: BoxFit.contain),
          const SizedBox(height: 20),
          const Text('Carga, corrida ou aluguer — à sua espera',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ]),
      ),
    );
  }
}
