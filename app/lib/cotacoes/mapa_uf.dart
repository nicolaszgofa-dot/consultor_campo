import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tema.dart';
import 'mapa_brasil.dart';

/// Etiquetas dos estados pequenos do litoral, no mar (longitude, latitude),
/// uma embaixo da outra.
const _etiquetaNoMar = <String, (double, double)>{
  'RN': (-32.0, -4.4),
  'PB': (-32.0, -6.3),
  'PE': (-32.0, -8.2),
  'AL': (-32.0, -10.1),
  'SE': (-32.6, -12.0),
  'ES': (-36.4, -20.0),
  'RJ': (-39.0, -24.6),
};

/// Etiquetas fora do centro, em graus a partir dele.
const _deslocamentoEtiqueta = <String, (double, double)>{
  'SC': (3.2, 0),
  'DF': (2.4, 0.2),
  'GO': (-0.8, -0.6),
};

/// Mapa do Brasil por estado: cor pelo preço e etiqueta com UF e preço.
/// Tocar no estado ou na etiqueta escolhe o estado.
class MapaBrasil extends StatelessWidget {
  /// Texto da etiqueta de cada UF (ex.: "142,2"); ausente = sem dado.
  final Map<String, String> valores;

  /// Cor de cada UF.
  final Map<String, Color> cores;
  final String? selecionado;
  final ValueChanged<String> aoEscolher;

  /// Falso: etiqueta só com a UF (tela estreita).
  final bool mostrarValores;

  const MapaBrasil({
    super.key,
    required this.valores,
    required this.cores,
    required this.selecionado,
    required this.aoEscolher,
    this.mostrarValores = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final proj = _Projecao.para(box.maxWidth);
        final caminhos = {
          for (final e in contornosUf.entries) e.key: proj.caminho(e.value),
        };
        return SizedBox(
          width: proj.largura,
          height: proj.altura,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTapUp: (d) {
                    // De trás para frente: o DF fica por cima de Goiás.
                    for (final uf in caminhos.keys.toList().reversed) {
                      if (caminhos[uf]!.contains(d.localPosition)) {
                        aoEscolher(uf);
                        return;
                      }
                    }
                  },
                  child: CustomPaint(
                    painter: _PintorMapa(caminhos, cores, selecionado),
                  ),
                ),
              ),
              for (final uf in contornosUf.keys)
                _posicionar(
                  proj,
                  uf,
                  _Etiqueta(
                    uf: uf,
                    valor: valores[uf],
                    mostrarValor: mostrarValores,
                    selecionado: uf == selecionado,
                    aoTocar: () => aoEscolher(uf),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _posicionar(_Projecao proj, String uf, Widget filho) {
    final (lon, lat) = _etiquetaNoMar[uf] ?? _centro(contornosUf[uf]!);
    final (dx, dy) = _deslocamentoEtiqueta[uf] ?? (0.0, 0.0);
    final p = proj.ponto(lon + dx, lat + dy);
    // Etiqueta centrada no ponto.
    return Positioned(
      left: p.dx - 60,
      top: p.dy - 12,
      width: 120,
      height: 24,
      child: Center(child: filho),
    );
  }
}

/// Centro do maior polígono do estado (centroide pela área).
(double, double) _centro(List<List<double>> poligonos) {
  var melhor = poligonos.first;
  var maior = 0.0;
  for (final p in poligonos) {
    final a = _area(p).abs();
    if (a > maior) {
      maior = a;
      melhor = p;
    }
  }
  var cx = 0.0, cy = 0.0, a = 0.0;
  for (var i = 0; i < melhor.length; i += 2) {
    final j = (i + 2) % melhor.length;
    final f = melhor[i] * melhor[j + 1] - melhor[j] * melhor[i + 1];
    cx += (melhor[i] + melhor[j]) * f;
    cy += (melhor[i + 1] + melhor[j + 1]) * f;
    a += f;
  }
  return (cx / (3 * a), cy / (3 * a));
}

double _area(List<double> p) {
  var s = 0.0;
  for (var i = 0; i < p.length; i += 2) {
    final j = (i + 2) % p.length;
    s += p[i] * p[j + 1] - p[j] * p[i + 1];
  }
  return s / 2;
}

/// Longitude e latitude para pixels, com a correção do cosseno da
/// latitude média para o país não sair achatado.
class _Projecao {
  static const _lonMin = -74.1, _lonMax = -28.6, _latMin = -33.8;
  static const _latMax = 5.4;
  static final _kx = math.cos(-15 * math.pi / 180);

  final double escala;

  const _Projecao(this.escala);

  /// O mapa ocupa a largura toda; a margem à direita é para as etiquetas
  /// dos estados do litoral.
  factory _Projecao.para(double largura) =>
      _Projecao(largura / ((_lonMax - _lonMin) * _kx));

  double get largura => (_lonMax - _lonMin) * _kx * escala;
  double get altura => (_latMax - _latMin) * escala;

  Offset ponto(double lon, double lat) =>
      Offset((lon - _lonMin) * _kx * escala, (_latMax - lat) * escala);

  Path caminho(List<List<double>> poligonos) {
    final path = Path();
    for (final p in poligonos) {
      final o = ponto(p[0], p[1]);
      path.moveTo(o.dx, o.dy);
      for (var i = 2; i < p.length; i += 2) {
        final q = ponto(p[i], p[i + 1]);
        path.lineTo(q.dx, q.dy);
      }
      path.close();
    }
    return path;
  }
}

class _PintorMapa extends CustomPainter {
  final Map<String, Path> caminhos;
  final Map<String, Color> cores;
  final String? selecionado;

  _PintorMapa(this.caminhos, this.cores, this.selecionado);

  @override
  void paint(Canvas canvas, Size size) {
    final borda = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round
      ..color = Cores.branco;
    for (final e in caminhos.entries) {
      canvas.drawPath(
        e.value,
        Paint()..color = cores[e.key] ?? const Color(0xFFE3E5E7),
      );
      canvas.drawPath(e.value, borda);
    }
    final sel = selecionado == null ? null : caminhos[selecionado];
    if (sel != null) {
      canvas.drawPath(
        sel,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round
          ..color = Cores.tinta,
      );
    }
  }

  @override
  bool shouldRepaint(_PintorMapa old) =>
      old.cores != cores ||
      old.selecionado != selecionado ||
      old.caminhos.length != caminhos.length;
}

class _Etiqueta extends StatelessWidget {
  final String uf;
  final String? valor;
  final bool mostrarValor;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _Etiqueta({
    required this.uf,
    required this.valor,
    required this.mostrarValor,
    required this.selecionado,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      label: '$uf ${valor ?? 'sem dado'}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: aoTocar,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: selecionado ? Cores.verdeEscuro : const Color(0xE61D1D1B),
            borderRadius: BorderRadius.circular(8),
            border: selecionado
                ? Border.all(color: Cores.verdeVivo, width: 1.5)
                : null,
          ),
          child: Text.rich(
            TextSpan(
              text: uf,
              children: [
                if (valor != null && mostrarValor)
                  TextSpan(
                    text: ' $valor',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB9F5B3),
                    ),
                  ),
              ],
            ),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Cores.branco,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
