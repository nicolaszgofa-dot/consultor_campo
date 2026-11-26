import '../simulador/referencias_terminal.dart';

// ---------------------------------------------------------------------------
// Monitor: ativações e onde ajustar o tempo de liga e desliga.
// ---------------------------------------------------------------------------

/// O que o técnico precisa saber de um monitor para o desligamento de linha.
class AjusteMonitor {
  /// Modelo como está em [monitoresCompativeis].
  final String modelo;

  /// Ativações pedidas pelo treinamento da Linha Elétric.
  final String ativacoes;

  /// Nome do ajuste de tempo no monitor (como o fabricante chama).
  final String nomeDoAjuste;

  /// Onde fica e como ajustar, em passos.
  final List<String> passos;

  /// true quando o caminho foi conferido no manual do fabricante; false
  /// quando é orientação geral e precisa ser conferido no monitor.
  final bool confirmado;

  /// De onde veio a informação.
  final String fonte;

  const AjusteMonitor({
    required this.modelo,
    required this.ativacoes,
    required this.nomeDoAjuste,
    required this.passos,
    required this.confirmado,
    required this.fonte,
  });

  MonitorCompativel get compatibilidade =>
      monitoresCompativeis.firstWhere((m) => m.modelo == modelo);

  /// Marca e modelo, sem repetir a marca quando ela já está no modelo
  /// ("CCI 1200", e não "CCI CCI 1200").
  String get nome {
    final c = compatibilidade;
    return c.modelo.startsWith(c.fabricante)
        ? c.modelo
        : '${c.fabricante} ${c.modelo}';
  }
}

const _consultar =
    'O manual J.Assy orienta consultar o manual do monitor ou o '
    'fornecedor: cada marca tem o seu menu.';

/// Na mesma ordem de [monitoresCompativeis].
const ajustesMonitores = <AjusteMonitor>[
  AjusteMonitor(
    modelo: 'GS3',
    ativacoes: 'Controle de seção (até 16 seções)',
    nomeDoAjuste: 'Tempo de ligar e de desligar (Turn On/Off)',
    passos: [
      'Na aba de configuração, habilite Documentação, Orientação e Controle '
          'de seção.',
      'Marque o Controle de seção mestre.',
      'Confira as configurações de sobreposição e os tempos de ligar e '
          'desligar.',
    ],
    confirmado: false,
    fonte: 'Guia de plantadeira de revenda John Deere para o GS3 2630.',
  ),
  AjusteMonitor(
    modelo: 'GS4',
    ativacoes: 'Controle de seção',
    nomeDoAjuste:
        'Retardo mecânico Ligado e Desligado (Mechanical Delay '
        'On/Off)',
    passos: [
      'Abra o Perfil do implemento e a página de Retardo mecânico.',
      'Ligado: tempo da primeira semente chegar ao solo depois do comando '
          'de ligar. Desligado: tempo da última semente depois do comando de '
          'desligar. Valores de 0,10 a 15 s.',
      'Para corrigir falhas e sobreposições, o ícone de Ajuste de desempenho '
          '(Performance Tuning) abre o Controle de seção: você informa a '
          'distância medida e a velocidade e ele recalcula os tempos.',
      'Não mude os tempos enquanto planta.',
    ],
    confirmado: true,
    fonte: 'Ajuda on-line dos monitores John Deere Geração 4 (4640).',
  ),
  AjusteMonitor(
    modelo: 'CCI 1200',
    ativacoes: 'Task Controller liberado; Controle de seção comprado',
    nomeDoAjuste: 'Tempo de ligar e de desligar da seção',
    passos: [_consultar],
    confirmado: false,
    fonte: 'Manual do Selenium (Compatibilidade).',
  ),
  AjusteMonitor(
    modelo: 'C3000',
    ativacoes: 'Todas já ativas (até 12 seções no treinamento; 32 no manual)',
    nomeDoAjuste: 'Temporização do controle de seção (Timing)',
    passos: [
      'No Topcon X35, o ajuste fica em Controle de seção > Temporização '
          '(Timing), com a tela de conferir a temporização.',
      'Confira o menu equivalente no C3000 (versão AGCO).',
    ],
    confirmado: false,
    fonte: 'Manual do operador Topcon X35 (índice).',
  ),
  AjusteMonitor(
    modelo: 'PRO700, PR1200',
    ativacoes:
        'Pro 700 e Intelliview IV: Controlador de tarefas (48 seções). '
        'Pro 1200 e Intelliview 12: Controle de seção (24, ou 128 com '
        'desbloqueio)',
    nomeDoAjuste: 'Atraso de ligar e de desligar da seção',
    passos: [
      'O ajuste fica no aplicativo Task Controller do monitor (manual Case IH '
          '47938688 para o Pro 700).',
      _consultar,
    ],
    confirmado: false,
    fonte: 'Treinamento Linha Elétric; manual Task Controller Case IH.',
  ),
  AjusteMonitor(
    modelo: 'CR7',
    ativacoes: 'Controlador de tarefas e VRA (taxa variável)',
    nomeDoAjuste: 'Antecipação (look-ahead) de ligar e de desligar',
    passos: [
      'Nos monitores Raven, a antecipação de ligar e a de desligar são '
          'tempos em segundos, sempre positivos.',
      'Confira no manual do CR7 a tela de controle de seção.',
    ],
    confirmado: false,
    fonte: 'Manual do Raven Viper Pro.',
  ),
  AjusteMonitor(
    modelo: 'GPX-750',
    ativacoes: 'ISOBUS, Task Controller e Multi-Product Control',
    nomeDoAjuste: 'Atraso (latência) de ligar e de desligar',
    passos: [_consultar],
    confirmado: false,
    fonte: 'Treinamento Linha Elétric.',
  ),
  AjusteMonitor(
    modelo: 'InCommand 1200',
    ativacoes: 'Todas já ativas',
    nomeDoAjuste: 'Atraso de ligar e de desligar',
    passos: [_consultar],
    confirmado: false,
    fonte: 'Treinamento Linha Elétric.',
  ),
  AjusteMonitor(
    modelo: 'Ti7 e Ti10',
    ativacoes: 'VT e TC ISOBUS (Ti7: 40 seções; Ti10: 60)',
    nomeDoAjuste: 'Antecipação de abertura e fechamento',
    passos: [_consultar],
    confirmado: false,
    fonte: 'Treinamento Linha Elétric.',
  ),
];

/// O que conferir antes de ir para o campo, valendo para todo monitor.
const checklistDesligamento = [
  'Ativação do controle de seção (e do Task Controller) liberada no monitor.',
  'Terminador ISOBUS no cabeamento do implemento.',
  'Medidas da plantadeira em Configurações > Implemento.',
  'Fonte de velocidade com GPS: quanto melhor o sinal, mais preciso o corte.',
  'Todas as linhas endereçadas e plantando no terminal J.Assy.',
];

// ---------------------------------------------------------------------------
// Ajuste no campo: quanto mudar o tempo a partir do que se viu no chão.
// ---------------------------------------------------------------------------

/// O que aconteceu na cabeceira, conferido no chão.
enum Ocorrencia {
  desligouAntes(
    'Desligou antes',
    'Parou antes de chegar à área plantada',
    desligar: true,
    adiantado: true,
  ),
  desligouDepois(
    'Desligou depois',
    'Seguiu plantando dentro da área plantada',
    desligar: true,
    adiantado: false,
  ),
  ligouAntes(
    'Ligou antes',
    'Começou a plantar ainda dentro da área plantada',
    desligar: false,
    adiantado: true,
  ),
  ligouDepois(
    'Ligou depois',
    'Só começou a plantar depois de sair da área plantada',
    desligar: false,
    adiantado: false,
  );

  final String titulo;
  final String descricao;

  /// true para o comando de desligar; false para o de ligar.
  final bool desligar;

  /// true quando a linha agiu cedo demais.
  final bool adiantado;

  const Ocorrencia(
    this.titulo,
    this.descricao, {
    required this.desligar,
    required this.adiantado,
  });

  /// O que fica no chão: desligar cedo ou ligar tarde deixa faixa sem
  /// semente; o contrário planta em dobro.
  bool get deixaFalha => desligar == adiantado;

  String get resultadoNoChao => deixaFalha
      ? 'falha (faixa sem semente)'
      : 'sobreposição (semente em dobro)';
}

class CorrecaoTempo {
  final Ocorrencia ocorrencia;
  final double distanciaM;
  final double velocidadeKmh;

  const CorrecaoTempo({
    required this.ocorrencia,
    required this.distanciaM,
    required this.velocidadeKmh,
  });

  double get velocidadeMs => velocidadeKmh / 3.6;

  /// Tempo que a máquina leva para percorrer o erro medido no chão.
  double get segundos => distanciaM / velocidadeMs;

  /// Adiantado: o monitor está mandando cedo demais, então o tempo de
  /// antecipação (retardo) diminui. Atrasado: aumenta.
  bool get aumentar => !ocorrencia.adiantado;

  String get qualTempo => ocorrencia.desligar ? 'desligar' : 'ligar';

  /// Novo valor a partir do atual, quando o técnico sabe o atual. Nunca
  /// negativo.
  double? novoValor(double? atual) {
    if (atual == null) return null;
    final v = aumentar ? atual + segundos : atual - segundos;
    return v < 0 ? 0 : v;
  }

  static CorrecaoTempo? calcular({
    required Ocorrencia? ocorrencia,
    required double? distanciaM,
    required double? velocidadeKmh,
  }) {
    if (ocorrencia == null ||
        distanciaM == null ||
        distanciaM <= 0 ||
        velocidadeKmh == null ||
        velocidadeKmh <= 0) {
      return null;
    }
    return CorrecaoTempo(
      ocorrencia: ocorrencia,
      distanciaM: distanciaM,
      velocidadeKmh: velocidadeKmh,
    );
  }
}

// ---------------------------------------------------------------------------
// Geometria da plantadeira (Configurações > Implemento).
// ---------------------------------------------------------------------------

/// Tipos de implemento do terminal J.Assy (manual do Titanium Elétric).
enum TipoLinhas {
  encontradas(
    'Encontradas',
    'Todas as saídas de semente na mesma distância '
        'das rodas.',
  ),
  desencontradas('Desencontradas', 'Linhas curtas e longas alternadas.'),
  personalizadas(
    'Personalizadas',
    'Você escolhe quais linhas são curtas e '
        'quais são longas.',
  );

  final String titulo;
  final String descricao;

  const TipoLinhas(this.titulo, this.descricao);
}

class GeometriaPlantadeira {
  final TipoLinhas tipo;
  final int linhas;
  final double espacamentoM;
  final double engateRodaM;

  /// Roda até a saída das linhas curtas (ou de todas, nas encontradas).
  final double rodaSaidaCurtaM;

  /// Roda até a saída das linhas longas (desencontradas e personalizadas).
  final double rodaSaidaLongaM;

  /// Desencontradas: a linha 1 é longa (true) ou curta (false).
  final bool primeiraLonga;

  /// Personalizadas: índices (0 = linha 1) das linhas longas.
  final Set<int> longas;

  const GeometriaPlantadeira({
    this.tipo = TipoLinhas.encontradas,
    this.linhas = 0,
    this.espacamentoM = 0,
    this.engateRodaM = 0,
    this.rodaSaidaCurtaM = 0,
    this.rodaSaidaLongaM = 0,
    this.primeiraLonga = false,
    this.longas = const {},
  });

  GeometriaPlantadeira copiar({
    TipoLinhas? tipo,
    int? linhas,
    double? espacamentoM,
    double? engateRodaM,
    double? rodaSaidaCurtaM,
    double? rodaSaidaLongaM,
    bool? primeiraLonga,
    Set<int>? longas,
  }) => GeometriaPlantadeira(
    tipo: tipo ?? this.tipo,
    linhas: linhas ?? this.linhas,
    espacamentoM: espacamentoM ?? this.espacamentoM,
    engateRodaM: engateRodaM ?? this.engateRodaM,
    rodaSaidaCurtaM: rodaSaidaCurtaM ?? this.rodaSaidaCurtaM,
    rodaSaidaLongaM: rodaSaidaLongaM ?? this.rodaSaidaLongaM,
    primeiraLonga: primeiraLonga ?? this.primeiraLonga,
    longas: longas ?? this.longas,
  );

  bool get temLongas => tipo != TipoLinhas.encontradas;

  double get larguraM => linhas * espacamentoM;

  /// A linha [i] (0 = linha 1) é longa?
  bool ehLonga(int i) => switch (tipo) {
    TipoLinhas.encontradas => false,
    TipoLinhas.desencontradas => i.isEven == primeiraLonga,
    TipoLinhas.personalizadas => longas.contains(i),
  };

  int get quantidadeLongas => [
    for (var i = 0; i < linhas; i++)
      if (ehLonga(i)) i,
  ].length;

  int get quantidadeCurtas => linhas - quantidadeLongas;

  /// O que falta preencher para o resultado sair.
  List<String> get faltando => [
    if (linhas <= 0) 'número de linhas',
    if (espacamentoM <= 0) 'espaçamento entre linhas',
    if (engateRodaM <= 0) 'engate até as rodas',
    if (rodaSaidaCurtaM <= 0)
      temLongas ? 'rodas até a saída curta' : 'rodas até a saída',
    if (temLongas && rodaSaidaLongaM <= 0) 'rodas até a saída longa',
  ];

  bool get completa => faltando.isEmpty;

  /// Avisos de medida que parece errada (não impede o resultado).
  List<String> get avisos => [
    if (linhas > 62) 'A Linha Elétric atende até 62 linhas.',
    if (espacamentoM > 0 && (espacamentoM < 0.15 || espacamentoM > 1.2))
      'Espaçamento fora do comum: confira se está em metros (ex.: 0,50).',
    if (temLongas &&
        rodaSaidaLongaM > 0 &&
        rodaSaidaCurtaM > 0 &&
        rodaSaidaLongaM <= rodaSaidaCurtaM)
      'A saída longa deve ficar mais longe das rodas que a curta.',
    if (tipo == TipoLinhas.personalizadas &&
        linhas > 0 &&
        (quantidadeLongas == 0 || quantidadeCurtas == 0))
      'Nas personalizadas, marque no desenho quais linhas são longas.',
    for (final (nome, v) in [
      ('engate até as rodas', engateRodaM),
      ('rodas até a saída', rodaSaidaCurtaM),
      ('rodas até a saída longa', rodaSaidaLongaM),
    ])
      if (v > 15) 'Medida "$nome" acima de 15 m: confira se está em metros.',
  ];
}
