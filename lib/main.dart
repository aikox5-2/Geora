import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/login.dart';
import 'pages/screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables securely
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Graceful fallback to static configuration
  }

  // Initialize Supabase Client
  await SupabaseService.initialize();

  runApp(const GeoraApp());
}

class GeoraApp extends StatelessWidget {
  const GeoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEORA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
