import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'alarmes.dart';

export 'alarmes.dart';

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
  gpsIsobus('GPS ISO', 'GPS ISOBUS'),
  gpsEcu('GPS ECU', 'GPS ECU'),
  manual('MANUAL', 'MANUAL'),
  radar('RADAR', 'RADAR');

  /// Texto curto da tecla A.
  final String rotulo;

  /// Texto da lista em Fonte de Velocidade.
  final String nome;

  const FonteVelocidade(this.rotulo, this.nome);

  bool get gps => this == gpsIsobus || this == gpsEcu;
}

/// Fonte de energia das linhas (Configurações > Energia).
enum FonteEnergia {
  bateria('Bateria'),
  alternador('Alternador');

  final String nome;

  const FonteEnergia(this.nome);
}

/// Telas do terminal virtual simulado.
enum TelaTerminal { trabalho, linha, configuracoes, senha }

/// Itens do menu de configurações, na ordem do terminal.
enum TelaConfig {
  sistema('Sistema'),
  dosagem('Dosagem e Sensoriamento'),
  implemento('Implemento'),
  filtro('Filtro de Velocidade'),
  fonteVelocidade('Fonte de Velocidade'),
  enderecamento('Enderecamento'),
  energia('Energia'),
  levante('Sensor de Levante');

  final String titulo;

  const TelaConfig(this.titulo);
}

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

/// Simulação do terminal do Selenium/Titanium Elétric no monitor ISOBUS.
/// Os números são gerados (não vêm de máquina) e seguem a lógica do manual:
/// taxa por linha em torno da taxa alvo, singulação, falhas, duplos, CV e
/// distribuição; os alarmes saem dos limites das configurações.
class TerminalEstado extends ChangeNotifier {
  TerminalEstado({
    int numeroLinhas = 24,
    this.espacamentoLinhasM = 0.5,
    this.furosDisco = 28,
    int semente = 7,
  }) : _aleatorio = math.Random(semente) {
    _linhaLigada = List.filled(numeroLinhas, true, growable: true);
    _leituras = List.filled(numeroLinhas, LeituraLinha.parada, growable: true);
    _enderecos = [for (var i = 0; i < numeroLinhas; i++) _novoEndereco()];
    atualizar();
  }

  final math.Random _aleatorio;

  // ------------------------------------------------- Dosagem e Sensoriamento
  int furosDisco;
  double taxaAlvo = 14;
  double maximoFalhas = 10;
  double maximoDuplos = 10;
  double populacaoMaximaPct = 20;
  double populacaoMinimaPct = 20;
  double distribuicaoMinima = 90;
  double cvMaximo = 45;
  double distanciaMedidasM = 100;
  double ajustePopulacao = 1;

  /// Parâmetros de engenharia (com senha).
  double singulacaoCritica = 70;
  double porcentagemSujeira = 25;
  bool engenhariaLiberada = false;

  // ------------------------------------------------------------- Implemento
  double espacamentoLinhasM;
  double engateRodaM = 1;
  double rodaSaidaCurtaM = 1;
  double rodaSaidaLongaM = 1;
  int numeroLinhaCurta = 0;
  bool titanium = false;

  // ---------------------------------------------------------------- Sistema
  bool taxaVariavelGs3 = true;
  int maximoSecoesMonitor = 60;

  // --------------------------------------------------- Filtro de velocidade
  bool filtroHabilitado = true;
  double tempoPartidaS = 0.3;
  double velocidadePartidaKmh = 1;
  double tempoParadaS = 0.3;
  double velocidadeParadaKmh = 0.9;

  // ---------------------------------------------------- Fonte de velocidade
  FonteVelocidade fonteVelocidade = FonteVelocidade.gpsIsobus;
  double velocidadeKmh = 6.5;
  double dopMaximo = 10;
  double constanteRadar = 0;

  // ----------------------------------------------------------------- Energia
  FonteEnergia energia = FonteEnergia.alternador;
  double tensaoV = 24.1;
  int rotacaoAlternador = 4735;
  int rotacaoMinima = 3000;
  int rotacaoMaxima = 6500;

  // ------------------------------------------------------- Sensor de levante
  bool sensor1Habilitado = false;
  bool sensor1Invertido = false;
  bool sensor2Habilitado = true;
  bool sensor2Invertido = false;
  bool levanteManual = true;

  /// Com os dois sensores: basta um indicar manobra (ou precisam os dois).
  bool bastaUmEmManobra = true;

  // ----------------------------------------------------------- Endereçamento
  int linhaEndereco = 0;
  bool lendoEndereco = false;
  int contagemLeitura = 0;
  String? enderecoLido;
  late List<String> _enderecos;

  // --------------------------------------------------------------- Navegação
  bool plantando = true;
  TelaTerminal tela = TelaTerminal.trabalho;
  TelaConfig? config;
  int linhaSelecionada = 0;
  Grafico graficoCima = Grafico.taxa;
  Grafico graficoBaixo = Grafico.singulacao;
  bool ajustandoTaxa = false;

  /// Campo de configuração aberto para edição (id do campo).
  String? campoEditando;

  // ------------------------------------------------------- Falhas simuladas
  /// Linha simulando entupimento ou fim de semente (nula = nenhuma).
  int? linhaEntupida;
  bool pressaoArAlta = false;
  bool alternadorParado = false;
  bool semSinalGps = false;

  /// Área trabalhada desde o início da simulação, em hectares.
  double hectares = 1.71;

  late List<bool> _linhaLigada;
  late List<LeituraLinha> _leituras;
  Timer? _relogio;

  int get numeroLinhas => _linhaLigada.length;
  List<LeituraLinha> get leituras => List.unmodifiable(_leituras);
  bool linhaLigada(int i) => _linhaLigada[i];
  int get linhasLigadas => _linhaLigada.where((l) => l).length;
  bool get secaoDesligada => linhasLigadas < numeroLinhas;
  String endereco(int linha) => _enderecos[linha];

  /// Espaçamento entre sementes na linha para a taxa alvo, em cm.
  double get espacamentoAlvoCm => 100 / taxaAlvo;

  /// Velocidade abaixo da qual os dosadores param.
  double get _velocidadeParada => filtroHabilitado ? velocidadeParadaKmh : 0.05;

  /// Os dosadores estão girando: plantando e com velocidade.
  bool get dosando => plantando && velocidadeKmh >= _velocidadeParada;

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
      maximo: taxaAlvo * math.max(1.3, 1.1 + populacaoMaximaPct / 100),
      limiteAlto: taxaAlvo * (1 + populacaoMaximaPct / 100),
      limiteBaixo: taxaAlvo * (1 - populacaoMinimaPct / 100),
    ),
    Grafico.populacao => (
      minimo: 0,
      maximo:
          taxaAlvo *
          math.max(1.3, 1.1 + populacaoMaximaPct / 100) *
          10 /
          espacamentoLinhasM,
      limiteAlto:
          taxaAlvo * (1 + populacaoMaximaPct / 100) * 10 / espacamentoLinhasM,
      limiteBaixo:
          taxaAlvo * (1 - populacaoMinimaPct / 100) * 10 / espacamentoLinhasM,
    ),
    Grafico.cv => (
      minimo: 0,
      maximo: math.max(60, cvMaximo + 10),
      limiteAlto: cvMaximo,
      limiteBaixo: null,
    ),
    // Singulação e distribuição ficam quase sempre acima de 90%: o eixo
    // começa em 80 para as diferenças entre linhas aparecerem.
    Grafico.singulacao => (
      minimo: 80,
      maximo: 100,
      limiteAlto: null,
      limiteBaixo: singulacaoCritica >= 80 ? singulacaoCritica : null,
    ),
    Grafico.distribuicao => (
      minimo: 80,
      maximo: 100,
      limiteAlto: null,
      limiteBaixo: distribuicaoMinima >= 80 ? distribuicaoMinima : null,
    ),
  };

  /// Alarmes ativos agora: os vermelhos (críticos) primeiro.
  List<Alarme> get alarmes {
    final lista = <Alarme>[];
    if (energia == FonteEnergia.alternador) {
      if (alternadorParado) {
        lista.add(const Alarme(TipoAlarme.alternadorDesligado));
      } else if (rotacaoAlternador < rotacaoMinima) {
        lista.add(const Alarme(TipoAlarme.baixaRotacaoAlternador));
      } else if (rotacaoAlternador > rotacaoMaxima) {
        lista.add(const Alarme(TipoAlarme.altaRotacaoAlternador));
      }
    }
    if (semSinalGps && fonteVelocidade.gps) {
      lista.add(const Alarme(TipoAlarme.fonteVelocidadeAusente));
    }
    if (dosando) {
      if (linhaEntupida != null && _linhaLigada[linhaEntupida!]) {
        lista.add(Alarme(TipoAlarme.fimDeSementes, linha: linhaEntupida));
      }
      final alta = taxaAlvo * (1 + populacaoMaximaPct / 100);
      final baixa = taxaAlvo * (1 - populacaoMinimaPct / 100);
      for (var i = 0; i < numeroLinhas; i++) {
        if (!_linhaLigada[i] || i == linhaEntupida) continue;
        final l = _leituras[i];
        if (l.singulacao < singulacaoCritica) {
          lista.add(Alarme(TipoAlarme.baixaSingulacao, linha: i));
        }
        if (l.falhas > maximoFalhas) {
          lista.add(Alarme(TipoAlarme.excessoFalhas, linha: i));
        }
        if (l.duplas > maximoDuplos) {
          lista.add(Alarme(TipoAlarme.excessoDuplos, linha: i));
        }
        if (l.distribuicao < distribuicaoMinima) {
          lista.add(Alarme(TipoAlarme.distribuicaoRuim, linha: i));
        }
        if (l.taxa > alta) {
          lista.add(Alarme(TipoAlarme.altaTaxa, linha: i));
        } else if (l.taxa < baixa) {
          lista.add(Alarme(TipoAlarme.baixaTaxa, linha: i));
        }
      }
      if (media.cv > cvMaximo) lista.add(const Alarme(TipoAlarme.cvElevado));
    }
    if (ajustePopulacao > 1) {
      lista.add(const Alarme(TipoAlarme.ganhoPopulacao));
    }
    return [
      ...lista.where((a) => a.critico),
      ...lista.where((a) => !a.critico),
    ];
  }

  double _ruido(double desvio) {
    // Aproximação de normal: soma de três uniformes.
    final u =
        _aleatorio.nextDouble() +
        _aleatorio.nextDouble() +
        _aleatorio.nextDouble();
    return (u - 1.5) * desvio * 2;
  }

  String _novoEndereco() => _aleatorio
      .nextInt(0x7FFFFFFF)
      .toRadixString(16)
      .toUpperCase()
      .padLeft(8, '0');

  void _gerarLeituras() {
    rotacaoAlternador = alternadorParado ? 0 : (4735 + _ruido(40)).round();
    tensaoV = 24.1 + _ruido(0.1);
    if (!plantando) return;
    for (var i = 0; i < numeroLinhas; i++) {
      if (!dosando || !_linhaLigada[i] || i == linhaEntupida) {
        _leituras[i] = LeituraLinha.parada;
        continue;
      }
      // Pressão de ar alta: o disco pega mais de uma semente por furo.
      final duplasBase = pressaoArAlta ? 12.0 : 0.5;
      final falhas = (0.6 + _ruido(0.5)).clamp(0.0, 30.0);
      final duplas = (duplasBase + _ruido(duplasBase * 0.6 + 0.2)).clamp(
        0.0,
        30.0,
      );
      _leituras[i] = LeituraLinha(
        taxa: math.max(
          0,
          taxaAlvo *
              (1 + duplas / 100 - falhas / 100 + _ruido(0.025)) *
              ajustePopulacao,
        ),
        singulacao: (100 - falhas - duplas).clamp(0.0, 100.0),
        falhas: falhas,
        duplas: duplas,
        cv: (19 + duplas * 1.2 + _ruido(3)).clamp(5.0, 100.0),
        distribuicao: (96 - duplas * 0.6 + _ruido(1.5)).clamp(0.0, 100.0),
      );
    }
  }

  /// Gera uma nova leitura de todas as linhas (uma por segundo).
  void atualizar() {
    _gerarLeituras();
    if (dosando) {
      hectares +=
          velocidadeKmh *
          (linhasLigadas * espacamentoLinhasM) /
          10 /
          3600 *
          _segundosPorLeitura;
    }
    if (lendoEndereco) contagemLeitura++;
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

  /// Muda uma configuração e refaz as leituras na hora.
  void mudar(VoidCallback mudanca) {
    mudanca();
    _gerarLeituras();
    notifyListeners();
  }

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
    config = null;
    campoEditando = null;
    ajustandoTaxa = false;
    notifyListeners();
  }

  void abrirConfig(TelaConfig c) {
    tela = TelaTerminal.configuracoes;
    config = c;
    campoEditando = null;
    notifyListeners();
  }

  /// Seta de voltar das telas de configuração: volta ao menu.
  void voltarConfig() {
    config = null;
    campoEditando = null;
    cancelarLeitura();
    notifyListeners();
  }

  void editarCampo(String? id) {
    campoEditando = id;
    notifyListeners();
  }

  /// Tecla do cadeado: pede a senha ou trava de novo.
  void alternarCadeado() {
    if (engenhariaLiberada) {
      engenhariaLiberada = false;
      notifyListeners();
    } else {
      tela = TelaTerminal.senha;
      campoEditando = null;
      notifyListeners();
    }
  }

  /// Na simulação, qualquer senha libera os parâmetros de engenharia.
  void liberarEngenharia() {
    engenhariaLiberada = true;
    tela = TelaTerminal.configuracoes;
    notifyListeners();
  }

  void fecharSenha() {
    tela = TelaTerminal.configuracoes;
    notifyListeners();
  }

  void trocarFonteVelocidade() {
    mudar(
      () => fonteVelocidade = FonteVelocidade
          .values[(fonteVelocidade.index + 1) % FonteVelocidade.values.length],
    );
  }

  void mudarVelocidade(double kmh) {
    mudar(() => velocidadeKmh = kmh.clamp(0.0, 20.0));
  }

  /// Muda o número de linhas: as novas entram ligadas e com endereço.
  void mudarNumeroLinhas(int n) {
    n = n.clamp(1, 60);
    mudar(() {
      while (_linhaLigada.length < n) {
        _linhaLigada.add(true);
        _leituras.add(LeituraLinha.parada);
        _enderecos.add(_novoEndereco());
      }
      if (_linhaLigada.length > n) {
        _linhaLigada.removeRange(n, _linhaLigada.length);
        _leituras.removeRange(n, _leituras.length);
        _enderecos.removeRange(n, _enderecos.length);
      }
      linhaSelecionada = linhaSelecionada.clamp(0, n - 1);
      linhaEndereco = linhaEndereco.clamp(0, n - 1);
      numeroLinhaCurta = numeroLinhaCurta.clamp(0, n);
      if (linhaEntupida != null && linhaEntupida! >= n) linhaEntupida = null;
    });
  }

  /// Simula (ou resolve) um entupimento na linha.
  void entupir(int? linha) {
    linhaEntupida = linha;
    atualizar();
  }

  // ----------------------------------------------------------- Endereçamento

  void lerEndereco() {
    lendoEndereco = true;
    contagemLeitura = 0;
    enderecoLido = null;
    notifyListeners();
  }

  void cancelarLeitura() {
    lendoEndereco = false;
    notifyListeners();
  }

  /// O ímã encostado no módulo da linha faz ele enviar o endereço.
  void encostarIma() {
    if (!lendoEndereco) return;
    lendoEndereco = false;
    enderecoLido = _novoEndereco();
    notifyListeners();
  }

  /// Grava o endereço lido na linha escolhida.
  void gravarEndereco() {
    final lido = enderecoLido;
    if (lido == null) return;
    _enderecos[linhaEndereco] = lido;
    notifyListeners();
  }
}
