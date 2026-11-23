import 'package:flutter/material.dart';

import '../tema.dart';

/// Símbolo do JA Campo: seis sementes no mesmo espaçamento formam um "C"
/// e a última vira broto. Desenhado numa grade de 100 × 100.
///
/// Os ícones do app (web/icons, favicon e Android) seguem a mesma geometria.
class SimboloJACampo extends StatelessWidget {
  final double tamanho;
  final Color corSementes;
  final Color corBroto;

  const SimboloJACampo({
    super.key,
    this.tamanho = 40,
    this.corSementes = Cores.branco,
    this.corBroto = Cores.verdeVivo,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Símbolo JA Campo',
      image: true,
      child: CustomPaint(
        size: Size.square(tamanho),
        painter: _PintorSimbolo(corSementes, corBroto),
      ),
    );
  }
}

class _PintorSimbolo extends CustomPainter {
  final Color corSementes;
  final Color corBroto;

  _PintorSimbolo(this.corSementes, this.corBroto);

  static const _sementes = [
    Offset(48.3, 20.1),
    Offset(28.2, 29.4),
    Offset(20, 50),
    Offset(28.2, 70.6),
    Offset(48.3, 79.9),
    Offset(69.3, 73),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Margem da grade: o desenho ocupa de 13 a 87.
    final k = size.width / 76;
    canvas.translate(-12 * k, -12 * k);
    final semente = Paint()..color = corSementes;
    for (final s in _sementes) {
      canvas.drawCircle(s * k, 7 * k, semente);
    }
    final folha = Path()
      ..moveTo(66 * k, 31 * k)
      ..cubicTo(66 * k, 20 * k, 73 * k, 13 * k, 85 * k, 12 * k)
      ..cubicTo(85 * k, 24 * k, 77 * k, 31 * k, 66 * k, 31 * k)
      ..close();
    canvas.drawPath(folha, Paint()..color = corBroto);
  }

  @override
  bool shouldRepaint(_PintorSimbolo old) =>
      old.corSementes != corSementes || old.corBroto != corBroto;
}
