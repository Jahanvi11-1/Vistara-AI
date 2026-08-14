import 'package:flutter/material.dart';

import 'screens/onboarding_screen.dart';
import 'theme/vistara_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VistaraApp());
}

class VistaraApp extends StatelessWidget {
  const VistaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vistara',
      debugShowCheckedModeBanner: false,

      // Vistara theme is used globally.
      theme: VistaraTheme.lightTheme,

      // IMPORTANT:
      // App always starts with onboarding.
      home: const OnboardingScreen(),
    );
  }
}