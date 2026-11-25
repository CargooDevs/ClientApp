import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import 'config/app_config.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError: ${details.exception}\n${details.stack}');
      };

      const supabaseUrl = String.fromEnvironment(
        AppConfig.supabaseUrlEnv,
        defaultValue: '',
      );
      const supabaseKey = String.fromEnvironment(
        AppConfig.supabasePublishableKey,
        defaultValue: '',
      );

      if (!AppConfig.isSupabaseConfigured(supabaseUrl, supabaseKey)) {
        const message =
            'Supabase is not configured. Run the app with '
            '--dart-define=SUPABASE_URL=... '
            '--dart-define=SUPABASE_PUBLISHABLE_KEY=...';
        debugPrint(message);
        runApp(const StartupErrorApp(message: message));
        return;
      }

      try {
        await SupabaseService.init(
          url: supabaseUrl,
          publishableKey: supabaseKey,
        );
      } catch (e, st) {
        debugPrint('Supabase init failed: $e\n$st');
        runApp(StartupErrorApp(message: 'Supabase init failed:\n$e'));
        return;
      }

      runApp(const CargooClientApp());
    },
    (error, stack) => debugPrint('Uncaught: $error\n$stack'),
  );
}

class CargooClientApp extends StatelessWidget {
  const CargooClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cargoo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}

/// Shown instead of a black screen when startup fails.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(message, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}