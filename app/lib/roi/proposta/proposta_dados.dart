import 'package:roi/roi.dart';

/// De qual benefício do ROI sai o valor mostrado no cartão do produto.
enum FonteRoi { plantabilidade, sobreposicao, taxaVariavel, curvas, operacao }

/// Ícones de traço do PDF (viewBox 24×24).
enum IconeProposta {
  velocidade('<path d="M12 14l4-4"/><path d="M3.3 17a9 9 0 1 1 17.4 0"/>'),
  semente(
    '<path d="M12 21c-4-2-6-6-6-10 3 0 6 2 6 6 0-4 3-8 6-8 0 6-2 10-6 12Z"/>',
  ),
  linhas('<path d="M4 4v16M9 4v16M15 4v16M20 4v16"/><path d="M2 12h20"/>'),
  mapa(
    '<path d="M9 4 3 6v14l6-2 6 2 6-2V4l-6 2-6-2Z"/><path d="M9 4v14M15 6v14"/>',
  ),
  curva('<path d="M4 20c0-9 7-16 16-16"/><path d="M8 20c0-7 5-12 12-12"/>'),
  monitor(
    '<rect x="3" y="4" width="18" height="12" rx="2"/><path d="M8 20h8M12 16v4"/>'
    '<path d="m7 12 3-3 2 2 4-4"/>',
  ),
  culturas(
    '<path d="M12 21V9"/><path d="M12 13c-3 0-5-2-5-5 3 0 5 2 5 5Zm0-4c3 0 '
    '5-2 5-5-3 0-5 2-5 5Z"/>',
  ),
  sinal(
    '<path d="M5 12a10 10 0 0 1 14 0"/><path d="M8.5 15.5a5 5 0 0 1 7 0"/>'
    '<circle cx="12" cy="19" r="1"/>',
  ),
  olho(
    '<path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12Z"/>'
    '<circle cx="12" cy="12" r="3"/>',
  ),
  check('<path d="m5 12 4 4 10-10"/>'),
  ferramenta(
    '<path d="M14.7 6.3a4 4 0 0 0-5.4 5.4L3 18l3 3 6.3-6.3a4 4 0 0 0 '
    '5.4-5.4l-2.5 2.5-2.4-.6-.6-2.4Z"/>',
  ),
  escudo(
    '<path d="M12 2 4 6v6c0 5 3.5 8.5 8 10 4.5-1.5 8-5 8-10V6l-8-4Z"/>'
    '<path d="m8.5 12 2.5 2.5 4.5-5"/>',
  ),
  calendario(
    '<rect x="3" y="5" width="18" height="16" rx="2"/>'
    '<path d="M3 10h18M8 3v4M16 3v4"/>',
  );

  final String desenho;

  const IconeProposta(this.desenho);

  String svg(String cor) =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
      'stroke="$cor" stroke-width="2" stroke-linecap="round" '
      'stroke-linejoin="round">$desenho</svg>';
}

/// Benefício do produto na página 3. [fonte] nula = sem valor do ROI.
class BeneficioProduto {
  final IconeProposta icone;
  final String titulo;
  final String texto;
  final FonteRoi? fonte;

  const BeneficioProduto(this.icone, this.titulo, this.texto, [this.fonte]);
}

enum Fornecimento { completo, motorizacao }

const _itensComuns = [
  'Módulo ECU',
  'Cabo ISOBUS',
  'Cabos de energia',
  'Antena de comunicação',
  'Sensor de levante',
  'Condutor de semente',
];

/// Textos dos modelos de proposta e das fichas de batalha (sem citar
/// concorrente: o PDF vai para o cliente).
enum ProdutoProposta {
  titanium(
    nome: 'Titanium Elétric',
    imagem: 'assets/configurador/titanium_eletric.webp',
    fornecimentos: {
      Fornecimento.completo: 'Dosador + motorização',
      Fornecimento.motorizacao: 'Só motorização',
    },
    itemProposta: {
      Fornecimento.completo: 'dosadores Titanium com motorização',
      Fornecimento.motorizacao: 'motorizações para dosador Titanium',
    },
    descricao:
        'O Titanium é o dosador que distribui as sementes com alto índice de '
        'redução de duplas e falhas. A plataforma Eletric se comunica via '
        'ISOBUS e elimina toda a transmissão mecânica da plantadeira ligada à '
        'semente.',
    caracteristicas: [
      (IconeProposta.linhas, 'Desligamento automático linha a linha'),
      (IconeProposta.mapa, 'Plantio em taxa variável'),
      (IconeProposta.sinal, 'Comunicação sem fio'),
      (IconeProposta.monitor, 'Regulagem pelo monitor do trator'),
      (IconeProposta.olho, 'Visor do desempenho do disco e anel'),
      (IconeProposta.velocidade, 'Alta precisão de dosagem'),
    ],
    sistema: {
      Fornecimento.completo: [
        'Dosador Titanium',
        'Motorização para dosador Titanium',
        'Alternador hidráulico',
        'Mangueiras hidráulicas',
        ..._itensComuns,
        'Sensor de sementes',
        'Frete e instalação',
      ],
      Fornecimento.motorizacao: [
        'Motorização para dosador Titanium',
        ..._itensComuns,
        'Sensor de sementes',
        'Frete e instalação',
      ],
    },
    provaNumero: '−33%',
    provaTexto:
        'falhas que o dosador convencional a 8,2 km/h, em soja no campo',
    provaFonte: 'UnB, Energia na Agricultura, 2020',
    beneficios: [
      BeneficioProduto(
        IconeProposta.velocidade,
        'Plantio certo em velocidade',
        '75,7% de espaçamentos aceitáveis a 8,2 km/h, contra 64,5% do '
            'convencional (UnB).',
        FonteRoi.plantabilidade,
      ),
      BeneficioProduto(
        IconeProposta.linhas,
        'Desliga linha a linha',
        'Cada linha para sozinha em área já plantada: menos semente dobrada '
            'em cabeceiras e recortes.',
        FonteRoi.sobreposicao,
      ),
      BeneficioProduto(
        IconeProposta.mapa,
        'Taxa variável no ISOBUS',
        'A população certa em cada zona, comandada pelo monitor que já está '
            'no trator.',
        FonteRoi.taxaVariavel,
      ),
      BeneficioProduto(
        IconeProposta.curva,
        'Compensação em curvas',
        'Na curva, cada linha gira na sua velocidade e mantém o espaçamento.',
        FonteRoi.curvas,
      ),
    ],
  ),
  selenium(
    nome: 'Selenium Elétric',
    imagem: 'assets/configurador/selenium_eletric.webp',
    fornecimentos: {
      Fornecimento.completo: 'Dosador + motorização',
      Fornecimento.motorizacao: 'Conversão do Selenium G3',
    },
    itemProposta: {
      Fornecimento.completo: 'dosadores Selenium Elétric',
      Fornecimento.motorizacao:
          'conversões de Selenium G3 para Selenium Elétric',
    },
    descricao:
        'O dosador pneumático da J.Assy é de fácil manuseio, não precisa de '
        'regulagem e dá melhor espaçamento às sementes. A plataforma Eletric '
        'se comunica via ISOBUS e elimina toda a transmissão mecânica da '
        'plantadeira ligada à semente.',
    caracteristicas: [
      (IconeProposta.linhas, 'Desligamento automático linha a linha'),
      (IconeProposta.mapa, 'Plantio em taxa variável'),
      (IconeProposta.sinal, 'Comunicação sem fio'),
      (IconeProposta.monitor, 'Regulagem pelo monitor do trator'),
      (IconeProposta.semente, 'Economia de sementes e insumos'),
      (IconeProposta.culturas, 'Mais produtividade nas bordaduras'),
    ],
    sistema: {
      Fornecimento.completo: [
        'Dosador Selenium Elétric',
        'Disco e anel para milho, 28 furos',
        'Disco e anel para soja, 40 furos',
        'Alternador hidráulico',
        'Mangueiras hidráulicas',
        ..._itensComuns,
        'Frete e instalação',
      ],
      Fornecimento.motorizacao: [
        'Dosador Selenium Elétric',
        'Alternador hidráulico',
        'Mangueiras hidráulicas',
        ..._itensComuns,
        'Sensor de sementes',
        'Frete e instalação',
      ],
    },
    // Sem o nome do concorrente: o PDF vai para o cliente.
    provaNumero: '85,4%',
    provaTexto:
        'de espaçamentos aceitáveis em campo, contra 76,1% de um dosador a '
        'vácuo concorrente',
    provaFonte: 'Ensaio J.Assy',
    beneficios: [
      BeneficioProduto(
        IconeProposta.velocidade,
        'Espaçamento certo sem regulagem',
        'O pneumático não precisa de regulagem e fecha o estande: 9,2 plantas '
            'por metro contra 8,5 do dosador a vácuo concorrente (ensaio '
            'J.Assy).',
        FonteRoi.plantabilidade,
      ),
      BeneficioProduto(
        IconeProposta.linhas,
        'Desliga linha a linha',
        'Cada linha para sozinha em área já plantada: menos semente dobrada '
            'em cabeceiras e recortes.',
        FonteRoi.sobreposicao,
      ),
      BeneficioProduto(
        IconeProposta.mapa,
        'Taxa variável no ISOBUS',
        'A população certa em cada zona, comandada pelo monitor que já está '
            'no trator.',
        FonteRoi.taxaVariavel,
      ),
      BeneficioProduto(
        IconeProposta.sinal,
        'Prático e sem fio',
        'Os dosadores falam com o trator sem fio e são regulados pelo monitor '
            'da cabine: menos cabos, menos parada e menos manutenção.',
        FonteRoi.operacao,
      ),
    ],
  ),
  neo(
    nome: 'Selenium Neo',
    imagem: 'assets/configurador/selenium_neo.png',
    fornecimentos: {Fornecimento.completo: 'Dosador com esteira'},
    itemProposta: {Fornecimento.completo: 'dosadores Selenium Neo com esteira'},
    descricao:
        'O Selenium Neo leva a semente do disco ao solo por uma esteira, sem '
        'a queda livre no tubo: ela chega no espaçamento do disco mesmo em '
        'alta velocidade. Dois motores sincronizados, disco e esteira, '
        'comandados via ISOBUS.',
    caracteristicas: [
      (IconeProposta.velocidade, 'Plantio em até 16 km/h'),
      (IconeProposta.linhas, 'Desligamento automático linha a linha'),
      (IconeProposta.mapa, 'Plantio em taxa variável'),
      (IconeProposta.sinal, 'Comunicação sem fio'),
      (IconeProposta.monitor, 'Regulagem pelo monitor do trator'),
      (IconeProposta.olho, 'Sensor de sementes na esteira'),
    ],
    // A confirmar com a engenharia: lista montada a partir das fichas.
    sistema: {
      Fornecimento.completo: [
        'Dosador Selenium Neo',
        'Esteira condutora de sementes',
        'Motores do disco e da esteira',
        'Sensor de sementes na esteira',
        'Alternador hidráulico',
        'Mangueiras hidráulicas',
        'Módulo ECU',
        'Cabo ISOBUS',
        'Cabos de energia',
        'Antena de comunicação',
        'Sensor de levante',
        'Frete e instalação',
      ],
    },
    provaNumero: '94,4%',
    provaTexto:
        'de espaçamentos aceitáveis em campo, contra 84,3% de um dosador de '
        'esteira concorrente',
    provaFonte: 'Ensaio J.Assy',
    beneficios: [
      BeneficioProduto(
        IconeProposta.semente,
        'Semente no espaçamento do disco',
        'A esteira tira a queda livre do tubo: CV de 24,4% contra 33,2% do '
            'dosador de esteira concorrente (ensaio J.Assy).',
        FonteRoi.plantabilidade,
      ),
      BeneficioProduto(
        IconeProposta.velocidade,
        'Mais hectares na janela',
        'Até 16 km/h com dois motores sincronizados: plantio rápido sem '
            'abrir mão do espaçamento.',
      ),
      BeneficioProduto(
        IconeProposta.linhas,
        'Desliga linha a linha',
        'Cada linha para sozinha em área já plantada: menos semente dobrada '
            'em cabeceiras e recortes.',
        FonteRoi.sobreposicao,
      ),
      BeneficioProduto(
        IconeProposta.mapa,
        'Taxa variável no ISOBUS',
        'A população certa em cada zona, comandada pelo monitor que já está '
            'no trator.',
        FonteRoi.taxaVariavel,
      ),
    ],
  ),
  // Júpiter, Level e Commander: lista do sistema fica para depois.
  jupiter(
    nome: 'Júpiter',
    imagem: 'assets/configurador/jupiter.png',
    fornecimentos: {Fornecimento.completo: 'Dosador de adubo'},
    itemProposta: {Fornecimento.completo: 'dosadores de adubo Júpiter'},
    descricao:
        'O Júpiter dosa o adubo por volume, com rotor e calha: a dose não '
        'depende do nível do depósito nem da rampa do terreno. Encaixe '
        'rápido, sem ferramentas.',
    caracteristicas: [
      (IconeProposta.velocidade, 'Dose de 100 a 600 kg/ha'),
      (IconeProposta.curva, 'Desempenho em aclive e declive'),
      (IconeProposta.linhas, 'Menor variação entre linhas'),
      (IconeProposta.ferramenta, 'Encaixe sem ferramentas'),
      (IconeProposta.semente, 'Quebra torrões de adubo'),
      (IconeProposta.escudo, 'Prêmio iF Design 2023'),
    ],
    sistema: {},
    provaNumero: '100–600',
    provaTexto:
        'kg/ha de faixa de dose no mesmo dosador, com encaixe sem '
        'ferramentas',
    provaFonte: 'J.Assy',
    solucaoCompleta: false,
    beneficios: [
      BeneficioProduto(
        IconeProposta.curva,
        'Dose certa em qualquer terreno',
        'O rotor volumétrico mantém a dose em aclive, em declive e com o '
            'depósito cheio ou vazio.',
      ),
      BeneficioProduto(
        IconeProposta.linhas,
        'Linhas por igual',
        'Rotor e calha dão menor variação de adubo entre as linhas.',
      ),
      BeneficioProduto(
        IconeProposta.ferramenta,
        'Menos parada',
        'Encaixe sem ferramentas e quebra-torrões: regulagem e limpeza mais '
            'rápidas.',
      ),
      BeneficioProduto(
        IconeProposta.velocidade,
        'Faixa ampla de dose',
        'De 100 a 600 kg/ha no mesmo dosador, para cada adubo e cada talhão.',
      ),
    ],
  ),
  level(
    nome: 'Level',
    imagem: 'assets/configurador/level.png',
    fornecimentos: {Fornecimento.completo: 'Controle de pressão'},
    itemProposta: {
      Fornecimento.completo: 'linhas com controle de pressão Level',
    },
    descricao:
        'O Level ajusta a pressão de cada linha da plantadeira conforme o '
        'solo, para a semente ficar na profundidade certa. Funciona na tela '
        'ISOBUS do trator, sem monitor próprio, e se comunica sem fio.',
    caracteristicas: [
      (IconeProposta.linhas, 'Pressão linha a linha'),
      (IconeProposta.semente, 'Profundidade uniforme'),
      (IconeProposta.monitor, 'Na tela ISOBUS do trator'),
      (IconeProposta.sinal, 'Comunicação sem fio'),
      (IconeProposta.velocidade, 'Menos trepidação da linha'),
      (IconeProposta.culturas, 'Emergência por igual'),
    ],
    sistema: {},
    provaNumero: '100%',
    provaTexto: 'ISOBUS e sem fio: usa a tela que já está no trator',
    provaFonte: 'J.Assy',
    solucaoCompleta: false,
    beneficios: [
      BeneficioProduto(
        IconeProposta.semente,
        'Profundidade certa',
        'Pressão ajustada a cada linha, conforme o solo: a semente fica na '
            'profundidade certa.',
      ),
      BeneficioProduto(
        IconeProposta.culturas,
        'Emergência por igual',
        'Plantas que nascem juntas competem menos entre si e produzem mais.',
      ),
      BeneficioProduto(
        IconeProposta.monitor,
        'Sem monitor extra',
        'Roda na tela ISOBUS do trator; não precisa de monitor próprio.',
      ),
      BeneficioProduto(
        IconeProposta.velocidade,
        'Linha estável',
        'Menos trepidação da linha, mesmo em velocidade.',
      ),
    ],
  ),
  commander(
    nome: 'Commander',
    imagem: 'assets/configurador/commander.png',
    fornecimentos: {Fornecimento.completo: 'Controle de seções'},
    itemProposta: {Fornecimento.completo: 'seções controladas pelo Commander'},
    unidade: 'seção',
    unidades: 'seções',
    descricao:
        'O Commander controla as seções hidráulicas da plantadeira, na '
        'semente e no adubo, com corte de seção e taxa variável conforme o '
        'mapa de prescrição. Até 16 seções por máquina, via ISOBUS e sem fio.',
    caracteristicas: [
      (IconeProposta.linhas, 'Corte de seção na semente e no adubo'),
      (IconeProposta.mapa, 'Taxa variável de semente e adubo'),
      (IconeProposta.monitor, 'Sistema ISOBUS'),
      (IconeProposta.sinal, 'Comunicação sem fio'),
      (IconeProposta.check, 'Até 16 seções por máquina'),
      (IconeProposta.semente, 'Menos desperdício de insumos'),
    ],
    sistema: {},
    provaNumero: '16',
    provaTexto: 'seções por máquina, controladas por um só Commander',
    provaFonte: 'J.Assy',
    solucaoCompleta: false,
    beneficios: [
      BeneficioProduto(
        IconeProposta.linhas,
        'Corta onde já plantou',
        'Cada seção desliga sozinha em área já plantada, na semente e no '
            'adubo.',
        FonteRoi.sobreposicao,
      ),
      BeneficioProduto(
        IconeProposta.mapa,
        'Taxa variável nos dois insumos',
        'A dose certa de semente e de adubo em cada zona do mapa de '
            'prescrição.',
        FonteRoi.taxaVariavel,
      ),
      BeneficioProduto(
        IconeProposta.monitor,
        'Na tela do trator',
        'ISOBUS: o comando fica no monitor que já está na cabine.',
      ),
      BeneficioProduto(
        IconeProposta.sinal,
        'Sem fios pela máquina',
        'Comunicação sem fio: instalação mais limpa e menos manutenção.',
      ),
    ],
  );

  final String nome;

  /// Como o produto é cobrado: por linha ou por seção.
  final String unidade;
  final String unidades;

  /// Se entra a faixa "Solução completa" (dosador + motor no mesmo pacote).
  final bool solucaoCompleta;

  bool get porLinha => unidade == 'linha';

  /// Foto do produto. Nula = sem foto no app ainda.
  final String? imagem;
  final Map<Fornecimento, String> fornecimentos;
  final Map<Fornecimento, String> itemProposta;
  final String descricao;
  final List<(IconeProposta, String)> caracteristicas;
  final Map<Fornecimento, List<String>> sistema;
  final String provaNumero;
  final String provaTexto;
  final String provaFonte;
  final List<BeneficioProduto> beneficios;

  const ProdutoProposta({
    required this.nome,
    required this.imagem,
    required this.fornecimentos,
    required this.itemProposta,
    required this.descricao,
    required this.caracteristicas,
    required this.sistema,
    required this.provaNumero,
    required this.provaTexto,
    required this.provaFonte,
    required this.beneficios,
    this.unidade = 'linha',
    this.unidades = 'linhas',
    this.solucaoCompleta = true,
  });
}

/// Parcela depois da entrada: fração do total e quando vence.
typedef ParcelaProposta = ({double fracao, String quando});

/// Um produto da proposta. [valorCampanha] nulo = sem condição especial.
class ItemProposta {
  final ProdutoProposta produto;
  final Fornecimento fornecimento;
  final String plantadeira;
  final int linhas;
  final double valorLinha;
  final double? valorCampanha;

  const ItemProposta({
    required this.produto,
    required this.fornecimento,
    required this.plantadeira,
    required this.linhas,
    required this.valorLinha,
    this.valorCampanha,
  });

  bool get temCampanha => valorCampanha != null;

  /// Valor por linha que vale na proposta.
  double get valorFinal => valorCampanha ?? valorLinha;

  double get totalTabela => linhas * valorLinha;
  double get total => linhas * valorFinal;
}

/// Tudo o que o vendedor preenche ao gerar a proposta. Nenhum valor vem
/// preenchido: o app é público. Nada disso é salvo.
class DadosProposta {
  final List<ItemProposta> itens;
  final String impostos;

  /// Uma página por produto, com prova, benefícios e o que vem no sistema.
  final bool paginasProdutos;

  final String cliente;
  final String documento;
  final String inscricao;
  final String telefone;
  final String email;
  final String cidade;
  final DateTime data;
  final String consultor;
  final String contatoConsultor;

  final double entrada;
  final List<ParcelaProposta> parcelas;
  final String validade;
  final String prazo;
  final String local;
  final String agente;
  final String garantia;

  const DadosProposta({
    required this.itens,
    this.impostos = '',
    this.paginasProdutos = true,
    required this.cliente,
    this.documento = '',
    this.inscricao = '',
    this.telefone = '',
    this.email = '',
    required this.cidade,
    required this.data,
    required this.consultor,
    this.contatoConsultor = '',
    this.entrada = 0,
    this.parcelas = const [],
    this.validade = '',
    this.prazo = '',
    this.local = '',
    this.agente = '',
    this.garantia = '',
  });

  double get total => itens.fold(0, (s, i) => s + i.total);
  double get totalTabela => itens.fold(0, (s, i) => s + i.totalTabela);

  /// Quanto o cliente deixa de pagar com as condições de campanha.
  double get economia => totalTabela - total;

  /// Linhas de plantio da proposta: por plantadeira, a maior quantidade
  /// entre os itens cobrados por linha (Titanium e Júpiter na mesma máquina
  /// não somam duas vezes). Seções do Commander não contam.
  int get linhas {
    final porPlantadeira = <String, int>{};
    for (final i in itens.where((i) => i.produto.porLinha)) {
      final chave = i.plantadeira.trim().toLowerCase();
      final atual = porPlantadeira[chave] ?? 0;
      if (i.linhas > atual) porPlantadeira[chave] = i.linhas;
    }
    return porPlantadeira.values.fold(0, (s, n) => s + n);
  }

  /// O produto, quando a proposta tem um só. Nulo com produtos diferentes.
  ProdutoProposta? get produtoUnico {
    final produtos = itens.map((i) => i.produto).toSet();
    return produtos.length == 1 ? produtos.first : null;
  }

  /// Valores da entrada e das parcelas, somando o total.
  List<double> get valoresPagamento => dividirEmParcelas(total, [
    if (entrada > 0) entrada,
    for (final p in parcelas) p.fracao,
  ]);
}

/// As premissas do ROI com o investimento e as linhas da proposta, para o
/// retorno do PDF bater com o valor proposto.
PremissasRoi premissasDaProposta(PremissasRoi p, DadosProposta d) =>
    PremissasRoi(
      areaHa: p.areaHa,
      linhas: d.linhas.toDouble(),
      produtividadeScHa: p.produtividadeScHa,
      precoSaca: p.precoSaca,
      populacao: p.populacao,
      precoMilSementes: p.precoMilSementes,
      sobreposicao: p.sobreposicao,
      reducaoSobreposicao: p.reducaoSobreposicao,
      areaZonaHa: p.areaZonaHa,
      populacaoAtualZona: p.populacaoAtualZona,
      populacaoPrescrita: p.populacaoPrescrita,
      areaCurvas: p.areaCurvas,
      perdaCurvas: p.perdaCurvas,
      economiaOperacional: p.economiaOperacional,
      investimento: d.total,
      concorrente: p.concorrente,
      plantadeiraNova: p.plantadeiraNova,
      valorPlantadeiraAtual: p.valorPlantadeiraAtual,
      vidaSafras: p.vidaSafras,
    );

/// Valor do benefício do ROI que o cartão do produto mostra.
double valorDaFonte(ResultadoRoi r, CenarioRoi c, FonteRoi f) => switch (f) {
  FonteRoi.plantabilidade => r.cenarios[c]!.plantabilidade,
  FonteRoi.sobreposicao => r.fixos.sobreposicao,
  FonteRoi.taxaVariavel => r.fixos.taxaVariavel,
  FonteRoi.curvas => r.fixos.curvas,
  FonteRoi.operacao => r.fixos.operacao,
};
