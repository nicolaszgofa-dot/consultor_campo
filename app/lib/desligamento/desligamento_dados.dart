import '../simulador/referencias_terminal.dart';

// ---------------------------------------------------------------------------
// Monitor: licenças e onde ajustar o liga e desliga.
// ---------------------------------------------------------------------------

/// De onde veio o passo a passo de um monitor.
enum Conferencia {
  tutorialJassy('Conferido no tutorial J.Assy'),
  manualFabricante('Conferido no manual do fabricante'),
  conferir('Confira no manual do monitor');

  final String selo;

  const Conferencia(this.selo);

  bool get conferido => this != conferir;
}

/// Os campos de ajuste fino do liga e desliga num monitor.
class CampoAjuste {
  /// Nome do campo do comando de ligar e do de desligar.
  final String ligar;
  final String desligar;

  /// true quando o ajuste é uma distância (m); false, um tempo (s).
  final bool emMetros;

  /// true quando, no campo de desligar, valor maior desliga mais tarde
  /// (é uma sobreposição de saída, não uma antecipação).
  final bool desligarMaiorEhMaisTarde;

  /// Dica extra do monitor (assistente de calibração, por exemplo).
  final String? observacao;

  const CampoAjuste({
    required this.ligar,
    required this.desligar,
    this.emMetros = false,
    this.desligarMaiorEhMaisTarde = false,
    this.observacao,
  });
}

/// O que o técnico precisa saber de um monitor para o desligamento de linha.
class AjusteMonitor {
  /// Modelo como está em [monitoresCompativeis].
  final String modelo;

  /// Licenças e ativações para o corte de seção.
  final String ativacoes;

  /// Onde ficam as configurações do corte de seção, em passos.
  final List<String> passos;

  /// Os campos de ajuste fino; nulo quando ainda não se sabe.
  final CampoAjuste? campo;

  final Conferencia conferencia;

  /// De onde veio a informação.
  final String fonte;

  /// Tutorial em vídeo da J.Assy, quando há.
  final String? video;

  const AjusteMonitor({
    required this.modelo,
    required this.ativacoes,
    required this.passos,
    required this.campo,
    required this.conferencia,
    required this.fonte,
    this.video,
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

const _tutorial = 'Tutorial J.Assy no YouTube (playlist Monitores ISOBUS).';
const _yt = 'https://www.youtube.com/watch?v=';

/// Na mesma ordem de [monitoresCompativeis].
const ajustesMonitores = <AjusteMonitor>[
  AjusteMonitor(
    modelo: 'GS3',
    ativacoes:
        'Comprar a licença Controle de seção (até 16 seções). '
        'Terminal universal, taxa variável e multiprodutos já vêm liberados.',
    passos: [
      'Equipamento > Máquina: confira a posição da antena GPS no trator.',
      'O implemento J.Assy aparece sozinho em Plantadeira, com as medidas do '
          'terminal J.Assy.',
      'Controle de seção: habilite o Controle de seção mestre e a operação.',
      'Configurações de sobreposição (limites externos, internos e '
          'cobertura): minimizar falhas, minimizar sobreposição ou uma '
          'porcentagem.',
      'Configurações de ligar e desligar: o atraso do sistema, do comando até '
          'a semente chegar ao solo.',
      'Taxa variável: na tela J.Assy, menu Sistema, habilite a '
          'compatibilidade com o GS3.',
    ],
    campo: CampoAjuste(ligar: 'Ligar (atraso)', desligar: 'Desligar (atraso)'),
    conferencia: Conferencia.tutorialJassy,
    fonte: _tutorial,
    video: '${_yt}OIZF7UgBhIk',
  ),
  AjusteMonitor(
    modelo: 'GS4',
    ativacoes: 'Controle de seção',
    passos: [
      'Abra o Perfil do implemento e a página de Retardo mecânico.',
      'Ligado: tempo da primeira semente chegar ao solo depois do comando '
          'de ligar. Desligado: tempo da última semente depois do comando de '
          'desligar. De 0,10 a 15 s.',
      'O ícone de Ajuste de desempenho (Performance Tuning) abre o Controle '
          'de seção: você informa a distância medida e a velocidade e ele '
          'recalcula os tempos.',
      'Não mude os tempos enquanto planta.',
    ],
    campo: CampoAjuste(
      ligar: 'Retardo mecânico Ligado',
      desligar: 'Retardo mecânico Desligado',
      observacao:
          'Ou use o Ajuste de desempenho com a distância e a '
          'velocidade medidas.',
    ),
    conferencia: Conferencia.manualFabricante,
    fonte: 'Ajuda on-line dos monitores John Deere Geração 4 (4640).',
  ),
  AjusteMonitor(
    modelo: 'CCI 1200',
    ativacoes: 'Task Controller liberado; Controle de seção comprado',
    passos: [
      'Ainda sem tutorial J.Assy. O manual J.Assy orienta consultar o manual '
          'do monitor ou o fornecedor.',
    ],
    campo: null,
    conferencia: Conferencia.conferir,
    fonte: 'Manual do Selenium (Compatibilidade).',
  ),
  AjusteMonitor(
    modelo: 'C3000',
    ativacoes:
        'Comprar o Controle automático de seção (até 32 seções) e, '
        'para mapas, a taxa variável. O terminal virtual já vem liberado, mas '
        'pode estar desabilitado em monitor novo.',
    passos: [
      'Sistema > Características > Implemento: confira as licenças.',
      'No implemento, use só as funções que vai usar (controle de seção e '
          'taxa).',
      'Implemento > Controle de seção > Seções: a geometria de cada seção '
          'vem da tela J.Assy.',
      'Tempo de atividade (ligar) e Tempo de inatividade (desligar): '
          'antecipação em segundos, sem valores negativos.',
      'Controle automático de seção: a escala de sobreposição vai de 0 '
          '(desliga ao encostar na área plantada) a 10 (invade o máximo).',
    ],
    campo: CampoAjuste(
      ligar: 'Tempo de atividade',
      desligar: 'Tempo de inatividade',
    ),
    conferencia: Conferencia.tutorialJassy,
    fonte: _tutorial,
    video: '${_yt}1sMy4I6cnHc',
  ),
  AjusteMonitor(
    modelo: 'PRO700, PR1200',
    ativacoes:
        'Pro 700: comprar o Task Controller (corte de até 48 seções e '
        'taxa variável). Pro 1200: controle de seção, taxa variável e '
        'multiprodutos vêm de fábrica nas últimas versões; também precisa do '
        'Controlador de tarefas.',
    passos: [
      'Pro 700: Ferramentas > Sobreposição. Habilite o controle de '
          'sobreposição e o de limite, escolha a camada Elétric e ajuste as '
          'porcentagens e as distâncias de início e de fim em metros.',
      'Pro 700: na camada do Task Controller, ajuste o Atraso do produto. A '
          'tarefa precisa estar iniciada no Task Controller.',
      'Pro 1200: no implemento, Atraso iniciar e Atraso interromper. O '
          'botão Calibrar guia a medição: você informa o erro médio em cm e '
          'ele calcula o novo atraso.',
      'Sobreposição: a J.Assy não recomenda 99%; um valor menor deixa o mapa '
          'melhor.',
    ],
    campo: CampoAjuste(
      ligar: 'Atraso iniciar (Pro 1200) ou Atraso do produto (Pro 700)',
      desligar: 'Atraso interromper (Pro 1200) ou Atraso do produto (Pro 700)',
      observacao: 'No Pro 1200, o Calibrar faz a conta com o erro médio em cm.',
    ),
    conferencia: Conferencia.tutorialJassy,
    fonte: _tutorial,
    video: '${_yt}Ax1rRUE6AwQ',
  ),
  AjusteMonitor(
    modelo: 'CR7',
    ativacoes:
        'Comprar o Controlador de tarefas (corte de seção). Taxa '
        'variável e Multi VRA (multiprodutos) também são pagos.',
    passos: [
      'Menu > Controle de seção: escolha o implemento e habilite o controle '
          'de seção.',
      'Olhar adiante para ligar e Olhar adiante para desligar: o atraso do '
          'sistema, em segundos.',
      'Porcentagem de sobreposição e de limite; sobreposição de entrada e de '
          'saída em metros.',
      'Na tela de operação, a chave de corte de seção: azul é automático, '
          'verde planta sempre e vermelho desliga tudo.',
    ],
    campo: CampoAjuste(
      ligar: 'Olhar adiante para ligar',
      desligar: 'Olhar adiante para desligar',
    ),
    conferencia: Conferencia.tutorialJassy,
    fonte: _tutorial,
    video: '${_yt}WXhLNXwpL-w',
  ),
  AjusteMonitor(
    modelo: 'GPX-750',
    ativacoes:
        'Comprar o Task Controller (corte de até 256 seções), ativado '
        'por QR Code. Precision IQ e terminal universal já vêm liberados.',
    passos: [
      'Em Sistemas de mensagens, ligue o envio da velocidade do GPS para a '
          'tela J.Assy.',
      'No implemento: Latência ligada e Latência desligada, o atraso do '
          'sistema em segundos; Aplicar latência ao limite.',
      'Iniciar e finalizar sobreposição em metros; porcentagem de '
          'sobreposição e de limite.',
      'A J.Assy recomenda baixar um pouco a sobreposição de 99%, que faz '
          'cortes em trechos muito pequenos.',
      'Controle de aplicação: a opção de latências negativas e de desligar '
          'na taxa zero.',
    ],
    campo: CampoAjuste(
      ligar: 'Latência ligada',
      desligar: 'Latência desligada',
    ),
    conferencia: Conferencia.tutorialJassy,
    fonte: _tutorial,
    video: '${_yt}po5IVsjCkRg',
  ),
  AjusteMonitor(
    modelo: 'InCommand 1200',
    ativacoes:
        'A licença ISOBUS (controlador de tarefas). Se estiver travada, '
        'compre com a revenda do monitor e use Destravar.',
    passos: [
      'Configurações ISOBUS: habilite o controlador de tarefas. Deixe '
          'desmarcados os atrasos de seção vindos da ECU: o ajuste é feito no '
          'monitor.',
      'Implemento > chave > Fechamento de seção.',
      'Cobertura: a J.Assy recomenda definição de usuário em 50 a 70%, entre '
          'minimizar falhas e minimizar sobreposição.',
      'Antecipação Ligar e Desligar: a distância que o sistema antecipa cada '
          'comando. É aqui o ajuste fino quando liga ou desliga atrasado.',
    ],
    campo: CampoAjuste(
      ligar: 'Antecipação Ligar',
      desligar: 'Antecipação Desligar',
      emMetros: true,
    ),
    conferencia: Conferencia.tutorialJassy,
    fonte: _tutorial,
    video: '${_yt}V7r-_KhTvn8',
  ),
  AjusteMonitor(
    modelo: 'Ti7 e Ti10',
    ativacoes:
        'As licenças TC (controle de seção) e VT. Depois de inserir, '
        'reinicie o monitor.',
    passos: [
      'Mantenha o monitor na versão mais nova.',
      'No implemento, as dimensões e as seções vêm da tela J.Assy.',
      'Controle de seção: deixe "Sempre sobrepor" desabilitado, senão ele '
          'nunca desliga.',
      'Sobreposição: a J.Assy recomenda 50%.',
      'Antecipação: entrada e saída em metros. Entrada maior liga mais cedo; '
          'saída maior desliga mais tarde. O ajuste costuma ser mais na '
          'entrada.',
      'Na tela de operação, deixe as seções no "A" (automático).',
    ],
    campo: CampoAjuste(
      ligar: 'Antecipação de entrada',
      desligar: 'Antecipação de saída',
      emMetros: true,
      desligarMaiorEhMaisTarde: true,
    ),
    conferencia: Conferencia.tutorialJassy,
    fonte: _tutorial,
    video: '${_yt}tBoc9WMMJYM',
  ),
];

/// Instrução para o campo de um monitor, a partir da correção medida.
class InstrucaoAjuste {
  final String campo;
  final bool aumentar;
  final double valor;
  final bool emMetros;

  const InstrucaoAjuste({
    required this.campo,
    required this.aumentar,
    required this.valor,
    required this.emMetros,
  });

  String get unidade => emMetros ? 'm' : 's';

  double? novoValor(double? atual) => _novo(atual, aumentar, valor);
}

double? _novo(double? atual, bool aumentar, double delta) {
  if (atual == null) return null;
  final v = aumentar ? atual + delta : atual - delta;
  return v < 0 ? 0 : v;
}

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
  double? novoValor(double? atual) => _novo(atual, aumentar, segundos);

  /// O que mexer no campo de um monitor: em segundos ou em metros, e no
  /// sentido certo (no Hexagon, a saída maior desliga mais tarde).
  InstrucaoAjuste? instrucaoPara(CampoAjuste? c) {
    if (c == null) return null;
    final desligar = ocorrencia.desligar;
    final inverte = desligar && c.desligarMaiorEhMaisTarde;
    return InstrucaoAjuste(
      campo: desligar ? c.desligar : c.ligar,
      aumentar: inverte ? !aumentar : aumentar,
      valor: c.emMetros ? distanciaM : segundos,
      emMetros: c.emMetros,
    );
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
