import 'package:flutter/material.dart';

import 'home_page.dart';
import 'tema.dart';

void main() {
  runApp(const ConsultorCampoApp());
}

class ConsultorCampoApp extends StatelessWidget {
  const ConsultorCampoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consultor de Campo',
      debugShowCheckedModeBanner: false,
      theme: temaConsultor(),
      home: const HomePage(),
    );
  }
}
