import 'package:material_ui/material_ui.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import 'config/app_config.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment(
    AppConfig.supabaseUrlEnv,
    defaultValue: '',
  );
  const supabaseKey = String.fromEnvironment(
    AppConfig.supabasePublishableKey,
    defaultValue: '',
  );

  if (!AppConfig.isSupabaseConfigured(supabaseUrl, supabaseKey)) {
    throw FlutterError(
      'Supabase is not configured. Run the app with --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... or set valid project values.',
    );
  }

  await SupabaseService.init(
    url: supabaseUrl,
    publishableKey: supabaseKey,
  );

  runApp(const CargooClientApp());
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
