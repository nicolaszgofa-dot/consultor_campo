import 'package:flutter/material.dart';

import 'home_page.dart';
import 'perfil.dart';
import 'tema.dart';

void main() {
  runApp(const ConsultorCampoApp());
}

class ConsultorCampoApp extends StatelessWidget {
  const ConsultorCampoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: nomeApp,
      debugShowCheckedModeBanner: false,
      theme: temaConsultor(),
      home: const HomePage(),
    );
  }
}
