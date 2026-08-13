import 'package:flutter/material.dart';
import 'screens/home_screen_stateful.dart';

void main() {
  runApp(const VistaraApp());
}

class VistaraApp extends StatelessWidget {
  const VistaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vistara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4FA0)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
