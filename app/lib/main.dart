import 'package:flutter/material.dart';

import 'home_page.dart';

void main() {
  runApp(const ConsultorCampoApp());
}

class ConsultorCampoApp extends StatelessWidget {
  const ConsultorCampoApp({super.key});

  static const _semente = Color(0xFF2E6B3A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consultor de Campo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _semente),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _semente,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
