import 'package:flutter/material.dart';
import 'pages/screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    );
  }
}

