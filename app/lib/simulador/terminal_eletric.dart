import 'package:flutter/material.dart';

import 'explicacoes.dart';
import 'terminal_estado.dart';

/// Cores do terminal virtual (capturas do treinamento da Linha Elétric).
abstract final class _T {
  static const fundo = Color(0xFF3A3A3A);
  static const borda = Color(0xFF6E6E6E);
  static const texto = Color(0xFFFFFFFF);
  static const textoApagado = Color(0xFFBDBDBD);
  static const plantando = Color(0xFFCCFF99);
  static const manobra = Color(0xFFFFFFCC);
  static const alarme = Color(0xFFD32F2F);
  static const tituloGrafico = Color(0xFFD6D6D6);
  static const areaGrafico = Color(0xFF8E8E8E);
  static const barra = Color(0xFFC8F59A);
  static const barraBorda = Color(0xFF3E8E2F);
  static const limite = Color(0xFF3D7BE0);
  static const tecla = Color(0xFF3F3F3F);
  static const teclaAtiva = Color(0xFFFFFFFF);
  static const relogio = Color(0xFFEFE8C8);
  static const painelClaro = Color(0xFFD0D0D0);
  static const destaque = Color(0xFFFFC107);
}

const _mono = TextStyle(
  fontFamily: 'Courier New',
  fontFamilyFallback: ['Courier', 'monospace'],
  color: _T.texto,
  fontWeight: FontWeight.w700,
);

String _n(double v, [int casas = 1]) => v.toStringAsFixed(casas);

/// Terminal virtual do Elétric desenhado em 640 × 480 e escalado para caber.
/// Com [explicando], tocar numa parte chama [aoExplicar] em vez de agir.
class TerminalEletric extends StatelessWidget {
  final TerminalEstado estado;
  final bool explicando;
  final ValueChanged<ParteTerminal> aoExplicar;

  const TerminalEletric({
    super.key,
    required this.estado,
    required this.aoExplicar,
    this.explicando = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) => AspectRatio(
        aspectRatio: 4 / 3,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1B1B1B), width: 6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: FittedBox(
              child: SizedBox(
                width: 640,
                height: 480,
                child: _Tela(
                  e: estado,
                  explicando: explicando,
                  aoExplicar: aoExplicar,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tela extends StatelessWidget {
  final TerminalEstado e;
  final bool explicando;
  final ValueChanged<ParteTerminal> aoExplicar;

  const _Tela({
    required this.e,
    required this.explicando,
    required this.aoExplicar,
  });

  /// Região tocável: age normalmente ou, no modo explicação, explica.
  Widget _parte(
    ParteTerminal parte,
    Rect r,
    Widget filho, {
    VoidCallback? acao,
  }) {
    return Positioned.fromRect(
      rect: r,
      child: Semantics(
        button: true,
        label: parte.titulo,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: explicando ? () => aoExplicar(parte) : acao,
          child: Stack(
            fit: StackFit.expand,
            children: [
              filho,
              if (explicando)
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _T.destaque.withValues(alpha: 0.12),
                      border: Border.all(color: _T.destaque, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emTrabalho = e.tela == TelaTerminal.trabalho;
    return ColoredBox(
      color: _T.fundo,
      child: Stack(
        children: [
          // Painel esquerdo (480 de largura).
          _parte(
            ParteTerminal.barraIcones,
            const Rect.fromLTWH(0, 0, 480, 30),
            _BarraIcones(e: e),
          ),
          _parte(
            ParteTerminal.barraMensagens,
            const Rect.fromLTWH(8, 32, 464, 30),
            _BarraMensagens(e: e),
          ),
          if (emTrabalho) ..._trabalho(),
          if (e.tela == TelaTerminal.linha)
            Positioned(
              left: 0,
              top: 68,
              width: 480,
              height: 412,
              child: _TelaLinha(e: e),
            ),
          if (e.tela == TelaTerminal.configuracoes)
            const Positioned(
              left: 0,
              top: 68,
              width: 480,
              height: 412,
              child: _TelaConfiguracoes(),
            ),
          // Teclas A–J à direita.
          ..._teclas(),
          if (e.ajustandoTaxa && emTrabalho)
            Positioned(
              left: 0,
              top: 214,
              width: 480,
              height: 266,
              child: _AjusteTaxa(e: e),
            ),
        ],
      ),
    );
  }

  List<Widget> _trabalho() {
    final m = e.media;
    final plant = e.plantando;
    return [
      _parte(
        ParteTerminal.taxa,
        const Rect.fromLTWH(8, 68, 152, 140),
        _Quadro(
          titulo: 'TAXA',
          valor: plant ? _n(m.taxa, m.taxa >= 10 ? 0 : 1) : _n(e.taxaAlvo, 0),
          unidade: 'SEM\\M',
          selecionado: e.ajustandoTaxa,
          rodape: [
            ('ALVO', _n(e.taxaAlvo)),
            ('ESP', '${_n(e.espacamentoAlvoCm, 0)}cm'),
          ],
        ),
        acao: e.abrirAjusteTaxa,
      ),
      _parte(
        ParteTerminal.singulacao,
        const Rect.fromLTWH(164, 68, 152, 140),
        _Quadro(
          titulo: 'SINGULACAO',
          valor: _n(m.singulacao, m.singulacao >= 99.95 ? 0 : 1),
          unidade: '%',
          rodape: [
            ('FALHAS', '${_n(m.falhas, 1)}%'),
            ('DUPLOS', '${_n(m.duplas, 1)}%'),
          ],
        ),
      ),
      _parte(
        ParteTerminal.cv,
        const Rect.fromLTWH(320, 68, 152, 140),
        _Quadro(titulo: 'CV', valor: _n(m.cv), unidade: '%'),
      ),
      _parte(
        ParteTerminal.graficoCima,
        const Rect.fromLTWH(8, 214, 464, 130),
        _Grafico(
          e: e,
          grafico: e.graficoCima,
          primeiraLinha: 0,
          aoTrocar: e.trocarGraficoCima,
          explicando: explicando,
        ),
      ),
      _parte(
        ParteTerminal.graficoBaixo,
        const Rect.fromLTWH(8, 346, 464, 130),
        _Grafico(
          e: e,
          grafico: e.graficoBaixo,
          primeiraLinha: 0,
          aoTrocar: e.trocarGraficoBaixo,
          explicando: explicando,
        ),
      ),
    ];
  }

  List<Widget> _teclas() {
    Rect tecla(int col, int lin) =>
        Rect.fromLTWH(480 + col * 80.0 + 2, lin * 80.0 + 2, 76, 76);
    Widget vazia(String letra) => _Tecla(letra: letra, child: null);
    return [
      _parte(
        ParteTerminal.velocidade,
        tecla(0, 0),
        _Tecla(
          letra: 'A',
          child: _ConteudoTecla(
            icone: Icons.speed,
            rotulo: e.fonteVelocidade.rotulo,
            valor: _n(e.velocidadeKmh),
            unidade: 'km/h',
          ),
        ),
        acao: e.trocarFonteVelocidade,
      ),
      _parte(
        ParteTerminal.tensao,
        tecla(0, 1),
        _Tecla(
          letra: 'B',
          child: _ConteudoTecla(
            icone: Icons.battery_charging_full,
            valor: _n(e.tensaoV),
            unidade: 'V',
          ),
        ),
      ),
      _parte(
        ParteTerminal.plantar,
        tecla(0, 2),
        _Tecla(
          letra: 'C',
          child: _ConteudoTecla(
            icone: e.plantando ? Icons.upload : Icons.agriculture,
            valor: null,
            unidade: e.plantando ? 'Manobrar' : 'Plantar',
          ),
        ),
        acao: e.alternarPlantar,
      ),
      Positioned.fromRect(rect: tecla(0, 3), child: vazia('D')),
      _parte(
        ParteTerminal.inicio,
        tecla(0, 4),
        _Tecla(
          letra: 'E',
          ativa: e.tela == TelaTerminal.trabalho,
          child: const Icon(Icons.home, size: 52),
        ),
        acao: () => e.irPara(TelaTerminal.trabalho),
      ),
      for (final (i, l) in ['F', 'G', 'H', 'I'].indexed)
        Positioned.fromRect(rect: tecla(1, i), child: vazia(l)),
      _parte(
        ParteTerminal.configuracoes,
        tecla(1, 4),
        _Tecla(
          letra: 'J',
          ativa: e.tela == TelaTerminal.configuracoes,
          child: const Icon(Icons.tune, size: 52),
        ),
        acao: () => e.irPara(TelaTerminal.configuracoes),
      ),
      _parte(
        ParteTerminal.rodape,
        const Rect.fromLTWH(482, 402, 156, 76),
        const _Rodape(),
      ),
    ];
  }
}

class _BarraIcones extends StatelessWidget {
  final TerminalEstado e;

  const _BarraIcones({required this.e});

  @override
  Widget build(BuildContext context) {
    Widget icone(IconData i, {bool ativo = true, Color? cor}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Icon(i, size: 18, color: ativo ? (cor ?? _T.texto) : _T.borda),
    );
    return ColoredBox(
      color: _T.fundo,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Text('J.ASSY', style: _mono.copyWith(fontSize: 20)),
            const Spacer(),
            Text(
              '${_n(e.hectares, 2)} ha',
              style: _mono.copyWith(fontSize: 14, color: _T.textoApagado),
            ),
            const SizedBox(width: 8),
            icone(Icons.map, ativo: false),
            icone(Icons.view_week, ativo: e.secaoDesligada, cor: _T.destaque),
            icone(
              Icons.agriculture,
              cor: e.plantando ? _T.plantando : _T.manobra,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.blur_circular, size: 16, color: _T.texto),
            Text('${e.furosDisco}', style: _mono.copyWith(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _BarraMensagens extends StatelessWidget {
  final TerminalEstado e;

  const _BarraMensagens({required this.e});

  @override
  Widget build(BuildContext context) {
    final alarmes = e.alarmes;
    final (fundo, cor, texto) = alarmes.isNotEmpty
        ? (_T.alarme, _T.texto, alarmes.first.texto)
        : e.plantando
        ? (_T.plantando, Colors.black, 'Plantando')
        : (_T.manobra, Colors.black, 'Manobra');
    return Container(
      color: fundo,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _mono.copyWith(fontSize: 16, color: cor),
            ),
          ),
          if (alarmes.length > 1)
            Text(
              '+${alarmes.length - 1}',
              style: _mono.copyWith(fontSize: 16, color: cor),
            ),
        ],
      ),
    );
  }
}

class _Quadro extends StatelessWidget {
  final String titulo;
  final String valor;
  final String unidade;
  final List<(String, String)> rodape;
  final bool selecionado;

  const _Quadro({
    required this.titulo,
    required this.valor,
    required this.unidade,
    this.rodape = const [],
    this.selecionado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selecionado ? const Color(0xFF2E7D32) : _T.fundo,
        border: Border.all(
          color: selecionado ? _T.plantando : _T.borda,
          width: selecionado ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(titulo, style: _mono.copyWith(fontSize: 15)),
          Expanded(
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(valor, style: _mono.copyWith(fontSize: 44)),
              ),
            ),
          ),
          Text(unidade, style: _mono.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          if (rodape.isNotEmpty)
            Container(
              height: 32,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _T.borda)),
              ),
              child: Row(
                children: [
                  for (final (i, (simbolo, v)) in rodape.indexed)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: i == 0
                              ? null
                              : const Border(left: BorderSide(color: _T.borda)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                simbolo,
                                style: _mono.copyWith(fontSize: 11),
                              ),
                              Text(v, style: _mono.copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Gráfico de barras por linha, com o título que alterna a grandeza.
class _Grafico extends StatelessWidget {
  final TerminalEstado e;
  final Grafico grafico;
  final int primeiraLinha;
  final VoidCallback aoTrocar;
  final bool explicando;

  const _Grafico({
    required this.e,
    required this.grafico,
    required this.primeiraLinha,
    required this.aoTrocar,
    required this.explicando,
  });

  @override
  Widget build(BuildContext context) {
    final escala = e.escala(grafico);
    final valores = [
      for (var i = 0; i < e.numeroLinhas; i++) e.valor(grafico, i),
    ];
    String rotulo(double v) =>
        v >= 100 || v == v.roundToDouble() ? v.toStringAsFixed(0) : _n(v);
    double fracao(double v) =>
        ((v - escala.minimo) / (escala.maximo - escala.minimo)).clamp(0, 1);
    final limites = [?escala.limiteAlto, ?escala.limiteBaixo];
    // O máximo só aparece se não encostar no rótulo de um limite.
    final eixo = <double>[
      if (limites.every((l) => fracao(escala.maximo) - fracao(l) > 0.15))
        escala.maximo,
      ...limites,
      if (escala.minimo > 0) escala.minimo,
    ];
    return Column(
      children: [
        GestureDetector(
          onTap: explicando ? null : aoTrocar,
          child: Container(
            width: 260,
            height: 22,
            color: _T.tituloGrafico,
            alignment: Alignment.center,
            child: Text(
              grafico.titulo,
              style: _mono.copyWith(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 46,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final h = box.maxHeight - 14;
                    return Stack(
                      children: [
                        for (final v in eixo)
                          Positioned(
                            right: 4,
                            top: (h - h * fracao(v)).clamp(6, h) - 6,
                            child: Text(
                              rotulo(v),
                              style: _mono.copyWith(fontSize: 11),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => GestureDetector(
                    onTapUp: explicando
                        ? null
                        : (d) {
                            final i =
                                (d.localPosition.dx /
                                        box.maxWidth *
                                        e.numeroLinhas)
                                    .floor();
                            e.abrirLinha(i);
                          },
                    child: CustomPaint(
                      painter: _PintorBarras(
                        valores: valores,
                        minimo: escala.minimo,
                        maximo: escala.maximo,
                        limiteAlto: escala.limiteAlto,
                        limiteBaixo: escala.limiteBaixo,
                        desligadas: [
                          for (var i = 0; i < e.numeroLinhas; i++)
                            !e.linhaLigada(i),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PintorBarras extends CustomPainter {
  final List<double> valores;
  final double minimo;
  final double maximo;
  final double? limiteAlto;
  final double? limiteBaixo;
  final List<bool> desligadas;

  _PintorBarras({
    required this.valores,
    required this.minimo,
    required this.maximo,
    required this.limiteAlto,
    required this.limiteBaixo,
    required this.desligadas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const rotulos = 14.0;
    final h = size.height - rotulos;
    final n = valores.length;
    final w = size.width / n;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, h),
      Paint()..color = _T.areaGrafico,
    );
    final barra = Paint()..color = _T.barra;
    final apagada = Paint()..color = const Color(0xFF6A6A6A);
    final borda = Paint()
      ..color = _T.barraBorda
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < n; i++) {
      final x = i * w;
      final frac = _fracao(valores[i]);
      if (desligadas[i]) {
        canvas.drawRect(Rect.fromLTWH(x + 1, 0, w - 2, h), apagada);
      } else {
        canvas.drawRect(
          Rect.fromLTWH(x + 1, h - h * frac, w - 2, h * frac),
          barra,
        );
      }
      canvas.drawRect(Rect.fromLTWH(x + 1, 0, w - 2, h), borda);
      if (i == 0 || (i + 1) % 5 == 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: (i + 1).toString().padLeft(2, '0'),
            style: _mono.copyWith(fontSize: 9),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + w / 2 - tp.width / 2, h + 2));
      }
    }
    final tracejado = Paint()
      ..color = _T.limite
      ..strokeWidth = 1.5;
    for (final limite in [limiteAlto, limiteBaixo]) {
      if (limite == null) continue;
      final y = h - h * _fracao(limite);
      for (var x = 0.0; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), tracejado);
      }
    }
  }

  double _fracao(double v) =>
      ((v - minimo) / (maximo - minimo)).clamp(0.0, 1.0);

  @override
  bool shouldRepaint(_PintorBarras old) => true;
}

class _Tecla extends StatelessWidget {
  final String letra;
  final Widget? child;
  final bool ativa;

  const _Tecla({required this.letra, required this.child, this.ativa = false});

  @override
  Widget build(BuildContext context) {
    final cor = ativa ? Colors.black87 : _T.texto;
    return Container(
      decoration: BoxDecoration(
        color: ativa ? _T.teclaAtiva : _T.tecla,
        border: Border.all(color: const Color(0xFF1E1E1E), width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 2,
            top: 0,
            child: Text(letra, style: _mono.copyWith(fontSize: 11, color: cor)),
          ),
          if (child != null)
            Center(
              child: IconTheme(
                data: IconThemeData(color: cor),
                child: DefaultTextStyle(
                  style: _mono.copyWith(color: cor),
                  child: child!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConteudoTecla extends StatelessWidget {
  final IconData icone;
  final String? rotulo;
  final String? valor;
  final String unidade;

  const _ConteudoTecla({
    required this.icone,
    required this.valor,
    required this.unidade,
    this.rotulo,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: valor == null ? 34 : 20),
              if (rotulo != null) ...[
                const SizedBox(width: 2),
                Text(rotulo!, style: _mono.copyWith(fontSize: 8)),
              ],
            ],
          ),
          if (valor != null) Text(valor!, style: _mono.copyWith(fontSize: 20)),
          Text(unidade, style: _mono.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _Rodape extends StatelessWidget {
  const _Rodape();

  @override
  Widget build(BuildContext context) {
    final agora = TimeOfDay.now();
    final hora = '${agora.hour}:${agora.minute.toString().padLeft(2, '0')}';
    return Column(
      children: [
        Container(
          height: 36,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: _T.relogio,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            hora,
            style: _mono.copyWith(fontSize: 15, color: const Color(0xFF2E5E1E)),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Row(
            children: [
              for (final t in const ['2/2', null])
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _T.relogio,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: t == null
                        ? const Icon(
                            Icons.view_list,
                            size: 18,
                            color: Color(0xFF2E5E1E),
                          )
                        : Text(
                            t,
                            style: _mono.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF2E5E1E),
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AjusteTaxa extends StatelessWidget {
  final TerminalEstado e;

  const _AjusteTaxa({required this.e});

  @override
  Widget build(BuildContext context) {
    Widget botao(String t, VoidCallback a, String rotulo) => Semantics(
      button: true,
      label: rotulo,
      child: GestureDetector(
        onTap: a,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF555555)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            t,
            style: _mono.copyWith(fontSize: 24, color: Colors.black),
          ),
        ),
      ),
    );
    return Container(
      color: _T.painelClaro,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 190,
              height: 26,
              color: const Color(0xFF9E9E9E),
              alignment: Alignment.center,
              child: Text('TAXA', style: _mono.copyWith(fontSize: 16)),
            ),
          ),
          Align(
            alignment: const Alignment(-0.15, 0.1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  color: const Color(0xFF9E9E9E),
                  child: Text(
                    e.taxaAlvo.toStringAsFixed(2).replaceAll('.', ','),
                    style: _mono.copyWith(fontSize: 60),
                  ),
                ),
                Text(
                  'SEM\\M',
                  style: _mono.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            child: botao('×', e.fecharAjusteTaxa, 'Fechar ajuste da taxa'),
          ),
          Positioned(
            right: 8,
            top: 80,
            child: botao('+', () => e.mudarTaxa(0.1), 'Aumentar taxa'),
          ),
          Positioned(
            right: 8,
            top: 140,
            child: botao('−', () => e.mudarTaxa(-0.1), 'Diminuir taxa'),
          ),
        ],
      ),
    );
  }
}

/// Uma linha da plantadeira: dosador e sensor, com liga e desliga.
class _TelaLinha extends StatelessWidget {
  final TerminalEstado e;

  const _TelaLinha({required this.e});

  @override
  Widget build(BuildContext context) {
    final i = e.linhaSelecionada;
    final ligada = e.linhaLigada(i);
    final l = e.leituras[i];
    Widget seta(IconData icone, VoidCallback a, String rotulo) => Semantics(
      button: true,
      label: rotulo,
      child: GestureDetector(
        onTap: a,
        child: Container(
          width: 40,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFDDDDDD),
            border: Border.all(color: const Color(0xFF555555)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icone, color: Colors.black54),
        ),
      ),
    );
    Widget cartao(String titulo, IconData icone) => Container(
      height: 86,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF555555),
        border: Border.all(color: _T.borda),
      ),
      child: Row(
        children: [
          Icon(
            icone,
            size: 54,
            color: ligada ? const Color(0xFF7CFC00) : _T.borda,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(titulo, style: _mono.copyWith(fontSize: 14)),
            ),
          ),
          Semantics(
            button: true,
            label: ligada ? 'Desligar linha ${i + 1}' : 'Ligar linha ${i + 1}',
            child: GestureDetector(
              onTap: () => e.alternarLinha(i),
              child: Container(
                width: 46,
                height: 28,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: ligada
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: 18,
                  color: ligada ? const Color(0xFF4CAF50) : _T.borda,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              seta(Icons.chevron_left, e.linhaAnterior, 'Linha anterior'),
              SizedBox(
                width: 200,
                child: Text(
                  'LINHA ${i + 1}',
                  textAlign: TextAlign.center,
                  style: _mono.copyWith(fontSize: 20, color: _T.textoApagado),
                ),
              ),
              seta(Icons.chevron_right, e.proximaLinha, 'Próxima linha'),
            ],
          ),
        ),
        cartao('SELENIUM ELETRIC', Icons.settings_input_component),
        cartao('SENSOR DE SEMENTE', Icons.sensors),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            decoration: BoxDecoration(border: Border.all(color: _T.borda)),
            child: Row(
              children: [
                for (final (rot, v) in [
                  ('TAXA', ligada ? _n(l.taxa) : '–'),
                  ('SINGULACAO', ligada ? '${_n(l.singulacao)}%' : '–'),
                  ('CV', ligada ? '${_n(l.cv)}%' : '–'),
                ])
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(rot, style: _mono.copyWith(fontSize: 13)),
                        Text(v, style: _mono.copyWith(fontSize: 26)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Menu de configurações. As telas de cada item chegam na próxima etapa.
class _TelaConfiguracoes extends StatelessWidget {
  const _TelaConfiguracoes();

  @override
  Widget build(BuildContext context) {
    const itens = [
      (Icons.settings, 'Sistema'),
      (Icons.grain, 'Dosagem e Sensoriamento'),
      (Icons.agriculture, 'Implemento'),
      (Icons.filter_alt, 'Filtro de Velocidade'),
      (Icons.speed, 'Fonte de Velocidade'),
      (Icons.wifi_tethering, 'Enderecamento'),
      (Icons.battery_charging_full, 'Energia'),
      (Icons.height, 'Sensor de Levante'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 6),
          child: Text('Configuracoes', style: _mono.copyWith(fontSize: 18)),
        ),
        for (final (icone, nome) in itens)
          Container(
            height: 36,
            margin: const EdgeInsets.only(bottom: 2),
            color: const Color(0xFFCFCFCF),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icone, size: 20, color: const Color(0xFF444444)),
                const SizedBox(width: 18),
                Text(
                  nome,
                  style: _mono.copyWith(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Telas de configuracao: proxima etapa do simulador.',
          textAlign: TextAlign.center,
          style: _mono.copyWith(fontSize: 11, color: _T.textoApagado),
        ),
      ],
    );
  }
}
