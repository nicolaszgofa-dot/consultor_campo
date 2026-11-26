import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/formatos.dart';
import 'desligamento_dados.dart';

/// Plantadeira vista de cima, andando para cima: engate, rodas e as saídas
/// de semente (curtas e longas), com as cotas que vão no terminal. Nas
/// personalizadas, tocar numa linha alterna entre curta e longa.
class DesenhoGeometria extends StatelessWidget {
  final GeometriaPlantadeira g;
  final ValueChanged<int>? aoTocarLinha;

  const DesenhoGeometria({super.key, required this.g, this.aoTocarLinha});

  static const altura = 300.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final pintor = _Pintor(g);
        return Semantics(
          label: 'Desenho da plantadeira vista de cima',
          child: GestureDetector(
            onTapDown: aoTocarLinha == null
                ? null
                : (d) {
                    final i = pintor.linhaEm(
                      d.localPosition,
                      Size(box.maxWidth, altura),
                    );
                    if (i != null) aoTocarLinha!(i);
                  },
            child: CustomPaint(
              size: Size(box.maxWidth, altura),
              painter: pintor,
            ),
          ),
        );
      },
    );
  }
}

class _Pintor extends CustomPainter {
  final GeometriaPlantadeira g;

  _Pintor(this.g);

  static const _esq = 92.0; // espaço das cotas
  /// Margem direita: com linhas longas, a cota delas fica à direita.
  double get _dir => g.temLongas ? 78.0 : 12.0;
  static const _topo = 46.0; // espaço do trator
  static const _base = 26.0;

  int get _linhas => g.linhas.clamp(1, 62);

  /// Distâncias (m) para posicionar; sem medida, usa proporção de exemplo.
  (double engate, double curta, double longa) get _medidas {
    final e = g.engateRodaM > 0 ? g.engateRodaM : 3.0;
    final c = g.rodaSaidaCurtaM > 0 ? g.rodaSaidaCurtaM : 1.0;
    final l = g.temLongas
        ? (g.rodaSaidaLongaM > 0 ? g.rodaSaidaLongaM : c + 0.6)
        : c;
    return (e, c, l);
  }

  double _escala(Size s) {
    final (e, c, l) = _medidas;
    return (s.height - _topo - _base) / (e + math.max(c, l));
  }

  double _xLinha(int i, Size s) {
    final w = s.width - _esq - _dir;
    return _esq + w * (i + 0.5) / _linhas;
  }

  int? linhaEm(Offset p, Size s) {
    if (p.dx < _esq || p.dx > s.width - _dir) return null;
    final w = s.width - _esq - _dir;
    final i = ((p.dx - _esq) / w * _linhas).floor();
    return i >= 0 && i < g.linhas ? i : null;
  }

  @override
  void paint(Canvas canvas, Size s) {
    final k = _escala(s);
    final (e, c, l) = _medidas;
    final yEngate = _topo;
    final yRodas = yEngate + e * k;
    final yCurta = yRodas + c * k;
    final yLonga = yRodas + l * k;
    final xMeio = _esq + (s.width - _esq - _dir) / 2;
    final xIni = _esq + 4;
    final xFim = s.width - _dir - 4;

    final traco = Paint()
      ..color = Cores.cinzaEscuro
      ..strokeWidth = 2;
    final fino = Paint()
      ..color = Cores.cinza
      ..strokeWidth = 1;

    // Trator (só a traseira) e sentido de deslocamento.
    final trator = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(xMeio, 14), width: 64, height: 26),
      const Radius.circular(6),
    );
    canvas.drawRRect(trator, Paint()..color = Cores.verdeEscuro);
    _texto(canvas, 'trator', Offset(xMeio, 14), Cores.branco, 11, centro: true);
    _texto(
      canvas,
      '↑ sentido',
      Offset(xMeio + 40, 8),
      Cores.textoSecundario,
      11,
    );

    // Cabeçalho e engate.
    canvas.drawLine(Offset(xMeio, 27), Offset(xMeio, yRodas), traco);
    canvas.drawCircle(
      Offset(xMeio, yEngate),
      5,
      Paint()..color = Cores.atencao,
    );

    // Chassi e rodas.
    canvas.drawLine(Offset(xIni, yRodas), Offset(xFim, yRodas), traco);
    for (final x in [xIni + 18, xFim - 18]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, yRodas), width: 12, height: 28),
          const Radius.circular(3),
        ),
        Paint()..color = Cores.tinta,
      );
    }

    // Linhas: braço da roda até a saída e o ponto da semente.
    final raio = (((s.width - _esq - _dir) / _linhas) * 0.32).clamp(2.0, 7.0);
    for (var i = 0; i < _linhas; i++) {
      final longa = g.ehLonga(i);
      final x = _xLinha(i, s);
      final y = longa ? yLonga : yCurta;
      canvas.drawLine(Offset(x, yRodas), Offset(x, y), fino);
      canvas.drawCircle(
        Offset(x, y),
        raio,
        Paint()..color = longa ? Cores.dupla : Cores.verde,
      );
    }

    // Cotas à esquerda.
    void cota(
      double y1,
      double y2,
      String rotulo,
      double valor,
      double x, {
      bool aDireita = false,
    }) {
      final p = Paint()
        ..color = Cores.textoSecundario
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, y1), Offset(x, y2), p);
      canvas.drawLine(Offset(x - 4, y1), Offset(x + 4, y1), p);
      canvas.drawLine(Offset(x - 4, y2), Offset(x + 4, y2), p);
      final txt = valor > 0 ? '${numeroBr(valor, 2)} m' : '?';
      _texto(
        canvas,
        '$rotulo\n$txt',
        Offset(aDireita ? x + 6 : x - 6, (y1 + y2) / 2 - 12),
        Cores.tinta,
        11,
        direita: !aDireita,
      );
    }

    cota(yEngate, yRodas, 'engate-roda', g.engateRodaM, _esq - 6);
    cota(
      yRodas,
      yCurta,
      g.temLongas ? 'roda-curta' : 'roda-saída',
      g.rodaSaidaCurtaM,
      _esq - 6,
    );
    if (g.temLongas) {
      cota(
        yRodas,
        yLonga,
        "roda-longa",
        g.rodaSaidaLongaM,
        s.width - _dir + 10,
        aDireita: true,
      );
    }

    // Legenda.
    final yLeg = s.height - 10;
    canvas.drawCircle(Offset(_esq + 6, yLeg), 5, Paint()..color = Cores.verde);
    _texto(
      canvas,
      g.temLongas ? 'curta' : 'saída da semente',
      Offset(_esq + 14, yLeg - 7),
      Cores.tinta,
      11,
    );
    if (g.temLongas) {
      canvas.drawCircle(
        Offset(_esq + 62, yLeg),
        5,
        Paint()..color = Cores.dupla,
      );
      _texto(canvas, 'longa', Offset(_esq + 70, yLeg - 7), Cores.tinta, 11);
    }
  }

  void _texto(
    Canvas canvas,
    String t,
    Offset o,
    Color cor,
    double tam, {
    bool centro = false,
    bool direita = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(color: cor, fontSize: tam, height: 1.1),
      ),
      textAlign: direita ? TextAlign.right : TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout();
    var p = o;
    if (centro) p = o - Offset(tp.width / 2, tp.height / 2);
    if (direita) p = Offset(o.dx - tp.width, o.dy);
    tp.paint(canvas, p);
  }

  @override
  bool shouldRepaint(_Pintor old) => true;
}
