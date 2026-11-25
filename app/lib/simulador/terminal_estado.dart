import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Grandezas que os gráficos por linha do terminal mostram.
enum Grafico {
  taxa('Taxa (sem/m)'),
  singulacao('Singulação (%)'),
  cv('CV (%)'),
  populacao('População (mil/ha)'),
  distribuicao('Distribuição (%)');

  final String titulo;

  const Grafico(this.titulo);

  Grafico get proximo => values[(index + 1) % values.length];
}

/// Fonte de velocidade do terminal (Configurações > Fonte de Velocidade).
enum FonteVelocidade {
  manual('MANUAL'),
  gpsIsobus('GPS ISO'),
  gpsEcu('GPS ECU'),
  radar('RADAR');

  final String rotulo;

  const FonteVelocidade(this.rotulo);
}

/// Telas do terminal virtual simulado.
enum TelaTerminal { trabalho, linha, configuracoes }

/// Leitura de uma linha da plantadeira num instante.
class LeituraLinha {
  final double taxa;
  final double singulacao;
  final double falhas;
  final double duplas;
  final double cv;
  final double distribuicao;

  const LeituraLinha({
    required this.taxa,
    required this.singulacao,
    required this.falhas,
    required this.duplas,
    required this.cv,
    required this.distribuicao,
  });

  static const parada = LeituraLinha(
    taxa: 0,
    singulacao: 0,
    falhas: 0,
    duplas: 0,
    cv: 0,
    distribuicao: 0,
  );
}

/// Alarme ativo, com o texto do manual do terminal.
class Alarme {
  final String texto;
  final bool critico;

  const Alarme(this.texto, {this.critico = true});
}

/// Simulação da tela de trabalho do Selenium/Titanium Elétric no terminal
/// ISOBUS. Os números são gerados (não vêm de máquina) e seguem a lógica do
/// manual: taxa por linha em torno da taxa alvo, singulação, falhas, duplos,
/// CV e distribuição; alarmes de fim de semente e de excesso de falhas.
class TerminalEstado extends ChangeNotifier {
  TerminalEstado({
    this.numeroLinhas = 24,
    this.espacamentoLinhasM = 0.5,
    this.furosDisco = 28,
    int semente = 7,
  }) : _aleatorio = math.Random(semente) {
    _linhaLigada = List.filled(numeroLinhas, true);
    _leituras = List.filled(numeroLinhas, LeituraLinha.parada);
    atualizar();
  }

  final int numeroLinhas;
  final double espacamentoLinhasM;
  final int furosDisco;
  final math.Random _aleatorio;

  // Configurações que a 1ª etapa já usa (limites do manual).
  double taxaAlvo = 14;
  double maximoFalhas = 10;
  double cvMaximo = 45;
  double populacaoMaximaPct = 20;
  double populacaoMinimaPct = 20;

  FonteVelocidade fonteVelocidade = FonteVelocidade.gpsIsobus;
  double velocidadeKmh = 6.5;
  double tensaoV = 24.1;
  int rotacaoAlternador = 4735;

  bool plantando = true;
  TelaTerminal tela = TelaTerminal.trabalho;
  int linhaSelecionada = 0;
  Grafico graficoCima = Grafico.taxa;
  Grafico graficoBaixo = Grafico.singulacao;
  bool ajustandoTaxa = false;

  /// Linha simulando entupimento ou fim de semente (nula = nenhuma).
  int? linhaEntupida;

  /// Área trabalhada desde o início da simulação, em hectares.
  double hectares = 1.71;

  late List<bool> _linhaLigada;
  late List<LeituraLinha> _leituras;
  Timer? _relogio;

  List<LeituraLinha> get leituras => List.unmodifiable(_leituras);
  bool linhaLigada(int i) => _linhaLigada[i];
  int get linhasLigadas => _linhaLigada.where((l) => l).length;
  bool get secaoDesligada => linhasLigadas < numeroLinhas;

  /// Espaçamento entre sementes na linha para a taxa alvo, em cm.
  double get espacamentoAlvoCm => 100 / taxaAlvo;

  /// Médias das linhas que estão plantando.
  LeituraLinha get media {
    final ativas = [
      for (var i = 0; i < numeroLinhas; i++)
        if (_linhaLigada[i]) _leituras[i],
    ];
    if (ativas.isEmpty) return LeituraLinha.parada;
    double m(double Function(LeituraLinha) f) =>
        ativas.map(f).reduce((a, b) => a + b) / ativas.length;
    return LeituraLinha(
      taxa: m((l) => l.taxa),
      singulacao: m((l) => l.singulacao),
      falhas: m((l) => l.falhas),
      duplas: m((l) => l.duplas),
      cv: m((l) => l.cv),
      distribuicao: m((l) => l.distribuicao),
    );
  }

  /// Valor de uma linha para o gráfico.
  double valor(Grafico g, int linha) {
    final l = _leituras[linha];
    return switch (g) {
      Grafico.taxa => l.taxa,
      Grafico.singulacao => l.singulacao,
      Grafico.cv => l.cv,
      Grafico.populacao => l.taxa * 10 / espacamentoLinhasM,
      Grafico.distribuicao => l.distribuicao,
    };
  }

  /// Faixa do eixo e limites (linhas tracejadas) de cada gráfico.
  ({double minimo, double maximo, double? limiteAlto, double? limiteBaixo})
  escala(Grafico g) => switch (g) {
    Grafico.taxa => (
      minimo: 0,
      maximo: taxaAlvo * 1.3,
      limiteAlto: taxaAlvo * (1 + populacaoMaximaPct / 100),
      limiteBaixo: taxaAlvo * (1 - populacaoMinimaPct / 100),
    ),
    Grafico.populacao => (
      minimo: 0,
      maximo: taxaAlvo * 13 / espacamentoLinhasM,
      limiteAlto:
          taxaAlvo * (1 + populacaoMaximaPct / 100) * 10 / espacamentoLinhasM,
      limiteBaixo:
          taxaAlvo * (1 - populacaoMinimaPct / 100) * 10 / espacamentoLinhasM,
    ),
    Grafico.cv => (
      minimo: 0,
      maximo: 60,
      limiteAlto: cvMaximo,
      limiteBaixo: null,
    ),
    // Singulação e distribuição ficam quase sempre acima de 90%: o eixo
    // começa em 80 para as diferenças entre linhas aparecerem.
    Grafico.singulacao || Grafico.distribuicao => (
      minimo: 80,
      maximo: 100,
      limiteAlto: null,
      limiteBaixo: 90,
    ),
  };

  /// Alarmes ativos agora, do mais grave ao mais leve.
  List<Alarme> get alarmes => [
    if (plantando && linhaEntupida != null)
      Alarme(
        'Linha ${_dois(linhaEntupida! + 1)} - Fim de Sementes ou Entupimento',
      ),
    if (plantando)
      for (var i = 0; i < numeroLinhas; i++)
        if (_linhaLigada[i] &&
            i != linhaEntupida &&
            _leituras[i].falhas > maximoFalhas)
          Alarme('Linha ${_dois(i + 1)} - Excesso de Falhas', critico: false),
    if (plantando && media.cv > cvMaximo)
      const Alarme('CV Elevado', critico: false),
  ];

  static String _dois(int n) => n.toString().padLeft(2, '0');

  double _ruido(double desvio) {
    // Aproximação de normal: soma de três uniformes.
    final u =
        _aleatorio.nextDouble() +
        _aleatorio.nextDouble() +
        _aleatorio.nextDouble();
    return (u - 1.5) * desvio * 2;
  }

  /// Gera uma nova leitura de todas as linhas.
  void atualizar() {
    if (!plantando) {
      notifyListeners();
      return;
    }
    for (var i = 0; i < numeroLinhas; i++) {
      if (!_linhaLigada[i] || i == linhaEntupida) {
        _leituras[i] = LeituraLinha.parada;
        continue;
      }
      final falhas = (0.6 + _ruido(0.5)).clamp(0.0, 30.0);
      final duplas = (0.5 + _ruido(0.4)).clamp(0.0, 30.0);
      _leituras[i] = LeituraLinha(
        taxa: math.max(0, taxaAlvo * (1 + _ruido(0.025))),
        singulacao: (100 - falhas - duplas).clamp(0.0, 100.0),
        falhas: falhas,
        duplas: duplas,
        cv: (19 + _ruido(3)).clamp(5.0, 60.0),
        distribuicao: (96 + _ruido(1.5)).clamp(0.0, 100.0),
      );
    }
    hectares +=
        velocidadeKmh *
        (numeroLinhas * espacamentoLinhasM) /
        10 /
        3600 *
        _segundosPorLeitura;
    rotacaoAlternador = (4735 + _ruido(40)).round();
    tensaoV = 24.1 + _ruido(0.1);
    notifyListeners();
  }

  static const _segundosPorLeitura = 1.0;

  /// Liga a simulação contínua (uma leitura por segundo).
  void iniciar() {
    _relogio ??= Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) => atualizar(),
    );
  }

  void parar() {
    _relogio?.cancel();
    _relogio = null;
  }

  @override
  void dispose() {
    parar();
    super.dispose();
  }

  // ---------------------------------------------------------------- ações

  void alternarPlantar() {
    plantando = !plantando;
    atualizar();
  }

  void abrirAjusteTaxa() {
    ajustandoTaxa = true;
    notifyListeners();
  }

  void fecharAjusteTaxa() {
    ajustandoTaxa = false;
    notifyListeners();
  }

  /// Passo de 0,1 sem/m, como no terminal.
  void mudarTaxa(double delta) {
    taxaAlvo = ((taxaAlvo + delta) * 10).roundToDouble() / 10;
    taxaAlvo = taxaAlvo.clamp(1.0, 40.0);
    atualizar();
  }

  void trocarGraficoCima() {
    graficoCima = graficoCima.proximo;
    notifyListeners();
  }

  void trocarGraficoBaixo() {
    graficoBaixo = graficoBaixo.proximo;
    notifyListeners();
  }

  void abrirLinha(int linha) {
    linhaSelecionada = linha.clamp(0, numeroLinhas - 1);
    tela = TelaTerminal.linha;
    notifyListeners();
  }

  void linhaAnterior() => abrirLinha((linhaSelecionada - 1) % numeroLinhas);

  void proximaLinha() => abrirLinha((linhaSelecionada + 1) % numeroLinhas);

  void alternarLinha(int linha) {
    _linhaLigada[linha] = !_linhaLigada[linha];
    atualizar();
  }

  void irPara(TelaTerminal t) {
    tela = t;
    ajustandoTaxa = false;
    notifyListeners();
  }

  void trocarFonteVelocidade() {
    fonteVelocidade = FonteVelocidade
        .values[(fonteVelocidade.index + 1) % FonteVelocidade.values.length];
    notifyListeners();
  }

  void mudarVelocidade(double kmh) {
    velocidadeKmh = kmh.clamp(0.0, 20.0);
    notifyListeners();
  }

  /// Simula (ou resolve) um entupimento na linha.
  void entupir(int? linha) {
    linhaEntupida = linha;
    atualizar();
  }
}
