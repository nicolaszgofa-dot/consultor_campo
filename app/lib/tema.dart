import 'package:flutter/material.dart';

/// Paleta da marca e tons derivados para leitura no campo (contraste ≥ 4,5:1
/// em texto pequeno).
abstract final class Cores {
  // Primárias da marca.
  static const verde = Color(0xFF2AA437);
  static const verdeVivo = Color(0xFF21DD12);
  static const verdeEscuro = Color(0xFF112C02);
  static const branco = Color(0xFFFFFFFF);
  static const tinta = Color(0xFF1D1D1B);

  // Secundárias da marca.
  static const cinza = Color(0xFFA2A8AD);
  static const cinzaEscuro = Color(0xFF75777B);

  // Derivadas: texto pequeno, fundos e bordas.
  static const textoSecundario = Color(0xFF5F6165);
  static const verdeTexto = Color(0xFF1D7A28);
  static const verdeClaro = Color(0xFFE5F5E7);
  static const fundo = Color(0xFFF4F5F5);
  static const borda = Color(0xFFDCDFE1);
  static const neutro = Color(0xFFE8EAEB);
  static const passoPendente = Color(0xFF4B5A44);

  // Semânticas (iguais no app e no relatório).
  static const falha = Color(0xFFB43C0C);
  static const dupla = Color(0xFF1D4ED8);
  static const prejuizo = Color(0xFFB42318);
  static const atencao = Color(0xFF9A5B00);
}

/// Fonte condensada para títulos e números grandes.
const fonteTitulo = 'BarlowSemiCondensed';

/// Cor do percentual de plantas no lugar certo.
Color corDoPercentual(double p) => p >= 95
    ? Cores.verdeTexto
    : p >= 85
    ? Cores.atencao
    : Cores.prejuizo;

ThemeData temaConsultor() {
  final borda = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Cores.cinza),
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Barlow',
    scaffoldBackgroundColor: Cores.fundo,
    colorScheme: ColorScheme.fromSeed(seedColor: Cores.verde).copyWith(
      primary: Cores.verde,
      onPrimary: Cores.verdeEscuro,
      secondary: Cores.verdeEscuro,
      onSecondary: Cores.branco,
      surface: Cores.branco,
      onSurface: Cores.tinta,
      onSurfaceVariant: Cores.textoSecundario,
      outline: Cores.cinza,
      outlineVariant: Cores.borda,
      error: Cores.prejuizo,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Cores.verdeEscuro,
      foregroundColor: Cores.branco,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Cores.verde,
        foregroundColor: Cores.verdeEscuro,
        disabledBackgroundColor: Cores.neutro,
        disabledForegroundColor: Cores.textoSecundario,
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Barlow',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Cores.branco,
      border: borda,
      enabledBorder: borda,
      focusedBorder: borda.copyWith(
        borderSide: const BorderSide(color: Cores.verdeTexto, width: 2),
      ),
      labelStyle: const TextStyle(color: Cores.textoSecundario),
    ),
  );
}
