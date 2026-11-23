import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tema.dart';

/// Ícones dos módulos da tela inicial, na mesma lógica do símbolo do app:
/// grade de 48, traço de 3 e um único elemento de destaque por ícone
/// (semente, broto ou o dado que importa).
enum IconeModulo {
  plantio,
  configurador,
  roi,
  proposta,
  mercado,
  pecas,
  playbook,
  conceito,
  materialTecnico,
  relatorios,

  // Só no app da revenda.
  pedido,
  assistencia,
  regulagem,
  treinamento,
}

class IconeDoModulo extends StatelessWidget {
  final IconeModulo icone;
  final double tamanho;
  final Color traco;
  final Color destaque;

  const IconeDoModulo(
    this.icone, {
    super.key,
    this.tamanho = 32,
    this.traco = Cores.verdeEscuro,
    this.destaque = Cores.verde,
  });

  /// Versão apagada, para o que ainda está em breve.
  const IconeDoModulo.apagado(this.icone, {super.key, this.tamanho = 32})
    : traco = Cores.cinzaEscuro,
      destaque = Cores.cinza;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(tamanho),
        painter: _PintorIcone(icone, traco, destaque),
      ),
    );
  }
}

class _PintorIcone extends CustomPainter {
  final IconeModulo icone;
  final Color traco;
  final Color destaque;

  _PintorIcone(this.icone, this.traco, this.destaque);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48);
    final linha = Paint()
      ..color = traco
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linhaDestaque = Paint()
      ..color = destaque
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cheio = Paint()..color = traco;
    final cheioDestaque = Paint()..color = destaque;
    final branco = Paint()..color = Cores.branco;

    void reta(List<Offset> pontos, [Paint? p]) {
      final path = Path()..moveTo(pontos.first.dx, pontos.first.dy);
      for (final o in pontos.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, p ?? linha);
    }

    /// Folha de (x0,y0) até (x1,y1), com as curvas dos dois lados.
    Path folha(List<double> c) => Path()
      ..moveTo(c[0], c[1])
      ..cubicTo(c[2], c[3], c[4], c[5], c[6], c[7])
      ..cubicTo(c[8], c[9], c[10], c[11], c[0], c[1])
      ..close();

    switch (icone) {
      case IconeModulo.plantio:
        reta(const [Offset(4, 36), Offset(44, 36)]);
        for (final x in const [9.0, 18.0, 27.0]) {
          canvas.drawCircle(Offset(x, 29), 3.2, cheio);
        }
        canvas.drawPath(
          folha(const [35, 32, 35, 23, 39, 18, 45, 17, 45, 25, 41, 31]),
          cheioDestaque,
        );

      case IconeModulo.configurador:
        for (final y in const [13.0, 24.0, 35.0]) {
          reta([Offset(6, y), Offset(42, y)]);
        }
        for (final c in const [Offset(15, 13), Offset(31, 35)]) {
          canvas.drawCircle(c, 4.5, branco);
          canvas.drawCircle(c, 4.5, linha);
        }
        canvas.drawCircle(const Offset(26, 24), 6, cheioDestaque);

      case IconeModulo.roi:
        reta(const [Offset(6, 6), Offset(6, 42), Offset(42, 42)]);
        reta(const [
          Offset(12, 34),
          Offset(20, 26),
          Offset(27, 30),
          Offset(37, 16),
        ]);
        canvas.drawCircle(const Offset(38, 14), 4.5, cheioDestaque);

      case IconeModulo.proposta:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(9, 5, 30, 38),
            const Radius.circular(4),
          ),
          linha,
        );
        reta(const [Offset(16, 14), Offset(32, 14)]);
        reta(const [Offset(16, 21), Offset(27, 21)]);
        reta(const [
          Offset(17, 31),
          Offset(22, 36),
          Offset(32, 26),
        ], linhaDestaque);

      case IconeModulo.pecas:
        // Porca sextavada com o furo em destaque.
        final porca = Path()..moveTo(24 + 17, 24);
        for (var i = 1; i <= 6; i++) {
          final a = i * math.pi / 3;
          porca.lineTo(24 + 17 * math.cos(a), 24 + 17 * math.sin(a));
        }
        porca.close();
        canvas.drawPath(porca, linha);
        canvas.drawCircle(const Offset(24, 24), 6.5, cheioDestaque);

      case IconeModulo.mercado:
        reta(const [Offset(24, 44), Offset(24, 14)]);
        for (final y in const [38.0, 27.0]) {
          canvas.drawPath(
            folha([24, y, 17, y, 13, y - 4, 13, y - 10, 19, y - 10, 24, y - 6]),
            linha,
          );
          canvas.drawPath(
            folha([24, y, 31, y, 35, y - 4, 35, y - 10, 29, y - 10, 24, y - 6]),
            linha,
          );
        }
        canvas.drawPath(
          folha(const [24, 16, 20, 13, 20, 7, 24, 3, 28, 7, 28, 13]),
          cheioDestaque,
        );

      case IconeModulo.playbook:
        final livro = Path()
          ..moveTo(4, 12)
          ..cubicTo(12, 10, 19, 11, 24, 15)
          ..cubicTo(29, 11, 36, 10, 44, 12)
          ..lineTo(44, 38)
          ..cubicTo(36, 36, 29, 37, 24, 41)
          ..cubicTo(19, 37, 12, 36, 4, 38)
          ..close();
        canvas.drawPath(livro, linha);
        reta(const [Offset(24, 15), Offset(24, 41)]);
        final marcador = Path()
          ..moveTo(30, 10.5)
          ..lineTo(37, 10.5)
          ..lineTo(37, 23)
          ..lineTo(33.5, 20)
          ..lineTo(30, 23)
          ..close();
        canvas.drawPath(marcador, cheioDestaque);

      case IconeModulo.conceito:
        final lampada = Path()
          ..moveTo(18, 33)
          ..cubicTo(12, 29, 10, 24, 10, 19)
          ..arcToPoint(const Offset(38, 19), radius: const Radius.circular(14))
          ..cubicTo(38, 24, 36, 29, 30, 33)
          ..lineTo(30, 36)
          ..lineTo(18, 36)
          ..close();
        canvas.drawPath(lampada, linha);
        reta(const [Offset(19, 42), Offset(29, 42)]);
        canvas.drawPath(
          folha(const [24, 30, 24, 23, 27, 19, 32, 18, 32, 24, 29, 28]),
          cheioDestaque,
        );
        reta(const [Offset(24, 30), Offset(24, 25)], linhaDestaque);

      case IconeModulo.materialTecnico:
        reta(const [
          Offset(10, 5),
          Offset(29, 5),
          Offset(38, 14),
          Offset(38, 43),
          Offset(10, 43),
          Offset(10, 5),
        ]);
        reta(const [Offset(29, 5), Offset(29, 14), Offset(38, 14)]);
        reta(const [Offset(16, 22), Offset(32, 22)]);
        reta(const [Offset(16, 29), Offset(32, 29)]);
        reta(const [Offset(16, 36), Offset(24, 36)]);
        canvas.drawCircle(const Offset(31, 36), 3.5, cheioDestaque);

      case IconeModulo.relatorios:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(8, 7, 32, 36),
            const Radius.circular(4),
          ),
          linha,
        );
        const prancheta = Rect.fromLTWH(18, 4, 12, 6);
        canvas.drawRect(prancheta, branco);
        canvas.drawRect(prancheta, linha);
        reta(const [Offset(16, 36), Offset(16, 29)]);
        reta(const [Offset(24, 36), Offset(24, 23)]);
        reta(
          const [Offset(32, 36), Offset(32, 17)],
          Paint()
            ..color = destaque
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );

      case IconeModulo.pedido:
        // Caixa de peças com a etiqueta do pedido em destaque.
        reta(const [
          Offset(6, 16),
          Offset(24, 8),
          Offset(42, 16),
          Offset(42, 36),
          Offset(24, 44),
          Offset(6, 36),
          Offset(6, 16),
        ]);
        reta(const [Offset(6, 16), Offset(24, 24), Offset(42, 16)]);
        reta(const [Offset(24, 24), Offset(24, 44)]);
        reta(const [Offset(15, 12), Offset(33, 20)]);
        canvas.drawCircle(const Offset(34, 31), 4.5, cheioDestaque);

      case IconeModulo.assistencia:
        // Escudo (garantia) com uma chave de boca (assistência).
        final escudo = Path()
          ..moveTo(24, 4)
          ..lineTo(41, 10)
          ..lineTo(41, 22)
          ..cubicTo(41, 33, 33, 40, 24, 44)
          ..cubicTo(15, 40, 7, 33, 7, 22)
          ..lineTo(7, 10)
          ..close();
        canvas.drawPath(escudo, linha);
        reta(const [Offset(17, 31), Offset(26, 22)], linhaDestaque);
        canvas.drawCircle(const Offset(29, 19), 5, linhaDestaque);
        canvas.drawCircle(const Offset(31.5, 16.5), 2.2, branco);

      case IconeModulo.regulagem:
        // Mostrador com ponteiro: regular até o ponto certo.
        canvas.drawArc(
          const Rect.fromLTWH(5, 9, 38, 38),
          math.pi,
          math.pi,
          false,
          linha,
        );
        for (final a in const [1.15, 1.5, 1.85]) {
          final ang = a * math.pi;
          reta([
            Offset(24 + 15 * math.cos(ang), 28 + 15 * math.sin(ang)),
            Offset(24 + 19 * math.cos(ang), 28 + 19 * math.sin(ang)),
          ]);
        }
        reta(const [Offset(24, 28), Offset(34, 17)], linhaDestaque);
        canvas.drawCircle(const Offset(24, 28), 4, cheioDestaque);
        reta(const [Offset(10, 38), Offset(38, 38)]);

      case IconeModulo.treinamento:
        // Capelo de formatura com a borla em destaque.
        reta(const [
          Offset(4, 18),
          Offset(24, 9),
          Offset(44, 18),
          Offset(24, 27),
          Offset(4, 18),
        ]);
        final base = Path()
          ..moveTo(12, 22)
          ..lineTo(12, 33)
          ..cubicTo(17, 38, 31, 38, 36, 33)
          ..lineTo(36, 22);
        canvas.drawPath(base, linha);
        reta(const [Offset(40, 20), Offset(40, 32)], linhaDestaque);
        canvas.drawCircle(const Offset(40, 35), 3.5, cheioDestaque);
    }
  }

  @override
  bool shouldRepaint(_PintorIcone old) =>
      old.icone != icone || old.traco != traco || old.destaque != destaque;
}
