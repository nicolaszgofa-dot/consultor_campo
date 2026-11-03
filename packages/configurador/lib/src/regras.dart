/// Motor de regras do Configurador Técnico J.Assy.
///
/// Regras e pendências: docs/configurador/especificacao.md. Regras ainda sem
/// definição técnica entram no resultado como [StatusItem.pendente].
library;

import 'adaptacoes.dart';

enum Tecnologia {
  titaniumEletric('Titanium Elétric'),
  seleniumEletric('Selenium Elétric'),

  /// Dois motores por linha (disco e esteira): metade das linhas por saída
  /// do alternador, que é sempre usado. Sem kit conversão.
  seleniumNeo('Selenium Neo', linhasPorSaida: 5, temKitConversao: false);

  final String nome;

  /// Linhas que cada saída do alternador alimenta.
  final int linhasPorSaida;
  final bool temKitConversao;

  const Tecnologia(
    this.nome, {
    this.linhasPorSaida = 10,
    this.temKitConversao = true,
  });
}

enum TipoPlantadeira {
  autotransportavel('Autotransportável'),
  caixaCentral('Caixa central'),
  tandem('Tandem'),
  solteira('Solteira', secoesSeparadas: false);

  final String nome;

  /// Se as seções fecham separadas. Na solteira a máquina inteira é uma seção.
  final bool secoesSeparadas;

  const TipoPlantadeira(this.nome, {this.secoesSeparadas = true});
}

/// Bocal do reservatório de sementes pipoqueira (Titanium Elétric).
enum BocalTitanium {
  pol25('Bocal 2,5 pol'),
  pol30('Bocal 3,0 pol'),
  pol25e30('Bocal 2,5 + 3,0 pol');

  final String nome;

  const BocalTitanium(this.nome);
}

/// Kit bocal de sementes (Selenium Elétric).
enum BocalSelenium {
  gravidade('Kit bocal de sementes Selenium gravidade'),
  giratorio25('Kit bocal de sementes Selenium gravidade bocal girat. 2,5 pol'),
  giratorio30('Kit bocal de sementes Selenium gravidade bocal girat. 3,0 pol'),
  engateRapido('Kit bocal de sementes Selenium engate rápido com tela dupla');

  final String nome;

  const BocalSelenium(this.nome);
}

/// Kit bocal de sementes (Selenium Neo). O de pressão positiva já vem no
/// conjunto dosador: não entra como item à parte.
enum BocalNeo {
  gravidade('Kit bocal de sementes Selenium Neo gravidade'),
  giratorio30(
    'Kit bocal de sementes Selenium Neo gravidade bocal girat. 3 pol',
  ),
  pressaoPositiva(
    'Kit bocal de sementes Selenium Neo pressão positiva',
    vemNoDosador: true,
  );

  final String nome;
  final bool vemNoDosador;

  const BocalNeo(this.nome, {this.vemNoDosador = false});
}

/// Comprimentos disponíveis, em metros.
abstract final class Comprimentos {
  static const isobus = [5, 11, 14, 17];
  static const chicotePainel = [4, 9, 14];
  static const mangueiras = [6, 9, 12, 15];
}

/// Dados levantados na máquina.
class EntradaConfiguracao {
  final Tecnologia tecnologia;
  final TipoPlantadeira tipo;
  final int totalLinhas;

  /// Linhas de cada seção, na ordem da máquina. Ignorado na solteira.
  final List<int> linhasPorSecao;

  /// Só é perguntado em máquinas de até 12 linhas. Nulo = não respondido.
  final bool? temAlternador;

  /// Se a máquina permite instalar o alternador no cabeçalho
  /// (autotransportável) ou no tandem (tandem). Nulo = não respondido.
  final bool? alternadorNaFrente;

  /// Comprimentos escolhidos pelo vendedor, em metros. Nulo = não escolhido.
  final int? comprimentoIsobus;
  final int? comprimentoMangueiras;

  /// Chicotes painel escolhidos pelo vendedor: comprimento em metros →
  /// quantidade. Nulo = ainda não escolhidos.
  final Map<int, int>? chicotesPainel;

  /// Titanium Elétric: se terá reservatório de sementes pipoqueira e, se
  /// sim, qual bocal. Nulo = não respondido. Ignorado no Selenium.
  final bool? reservatorioPipoqueira;
  final BocalTitanium? bocalTitanium;

  /// Selenium Elétric: kit bocal de sementes. Ignorado no Titanium.
  final BocalSelenium? bocalSelenium;

  /// Selenium Neo: kit bocal de sementes. Ignorado nas demais.
  final BocalNeo? bocalNeo;

  /// Kit conversão para a [tecnologia]: troca o conjunto pelo kit e não
  /// leva discos, reservatório pipoqueira nem bocais.
  final bool kitConversao;

  /// Marca e modelo da plantadeira para a adaptação. Não se aplica ao kit
  /// conversão. Nulo = não escolhida.
  final Adaptacao? adaptacao;

  const EntradaConfiguracao({
    required this.tecnologia,
    required this.tipo,
    required this.totalLinhas,
    this.linhasPorSecao = const [],
    this.temAlternador,
    this.alternadorNaFrente,
    this.comprimentoIsobus,
    this.comprimentoMangueiras,
    this.chicotesPainel,
    this.reservatorioPipoqueira,
    this.bocalTitanium,
    this.bocalSelenium,
    this.bocalNeo,
    this.kitConversao = false,
    this.adaptacao,
  });

  /// Seções usadas nas regras: na solteira, uma seção com todas as linhas.
  List<int> get secoes => tipo.secoesSeparadas ? linhasPorSecao : [totalLinhas];
}

enum StatusItem { definido, pendente }

class ItemConfiguracao {
  final String componente;
  final int quantidade;

  /// Por que o item entrou (mostrado ao vendedor).
  final String motivo;
  final StatusItem status;

  /// O que falta definir, quando pendente.
  final String? pendencia;

  /// Comprimento escolhido, em metros, para itens vendidos por tamanho.
  final int? comprimento;

  /// Comprimentos disponíveis; vazia quando o item não tem tamanho.
  final List<int> opcoesComprimento;

  /// Quantidade sugerida pelas regras, quando o vendedor pode ajustar.
  final int? quantidadeRecomendada;

  /// Comprimento sugerido pelo tipo de máquina, em metros.
  final int? comprimentoSugerido;

  /// Aviso que acompanha o item sempre, mesmo depois de definido.
  final String? observacao;

  /// Quantidade de cada comprimento (metros → quantidade), para itens em que
  /// o vendedor mistura tamanhos. Vazio nos demais.
  final Map<int, int> quantidadesPorComprimento;

  const ItemConfiguracao({
    required this.componente,
    required this.quantidade,
    required this.motivo,
    this.status = StatusItem.definido,
    this.pendencia,
    this.comprimento,
    this.opcoesComprimento = const [],
    this.quantidadeRecomendada,
    this.comprimentoSugerido,
    this.observacao,
    this.quantidadesPorComprimento = const {},
  });
}

/// [info] só informa o vendedor; [aviso] pede atenção; [erro] bloqueia.
enum NivelValidacao { erro, aviso, info }

class Validacao {
  final NivelValidacao nivel;
  final String mensagem;

  const Validacao(this.nivel, this.mensagem);

  bool get bloqueia => nivel == NivelValidacao.erro;
}

/// Um conjunto de linhas vizinhas alimentado por uma saída do alternador.
class SaidaAlternador {
  final int numero;
  final int primeiraLinha;
  final int ultimaLinha;

  /// Seções (1, 2, 3…) com linhas nesta saída.
  final List<int> secoes;

  /// Linhas desta saída em cada uma das [secoes], na mesma ordem.
  final List<int> trechos;

  const SaidaAlternador({
    required this.numero,
    required this.primeiraLinha,
    required this.ultimaLinha,
    required this.secoes,
    required this.trechos,
  });

  int get linhas => ultimaLinha - primeiraLinha + 1;

  bool get misturaSecoes => secoes.length > 1;
}

enum ModoDistribuicao {
  /// Cada seção dividida em conjuntos de até 10 linhas.
  porSecao,

  /// Linhas distribuídas pelas 6 saídas como recurso global.
  global,
}

class DistribuicaoSaidas {
  final ModoDistribuicao modo;
  final List<SaidaAlternador> saidas;

  const DistribuicaoSaidas({required this.modo, required this.saidas});

  List<SaidaAlternador> get saidasQueMisturamSecoes =>
      saidas.where((s) => s.misturaSecoes).toList();

  /// Trechos de linhas ligados em sequência: um por saída e seção atendida.
  List<int> get trechos => [for (final s in saidas) ...s.trechos];
}

class ResultadoConfiguracao {
  final EntradaConfiguracao entrada;
  final List<ItemConfiguracao> itens;
  final List<Validacao> validacoes;

  /// Nula quando não há alternador ou a configuração está bloqueada.
  final DistribuicaoSaidas? distribuicao;

  const ResultadoConfiguracao({
    required this.entrada,
    required this.itens,
    required this.validacoes,
    required this.distribuicao,
  });

  bool get bloqueada => validacoes.any((v) => v.bloqueia);

  List<ItemConfiguracao> get pendentes =>
      itens.where((i) => i.status == StatusItem.pendente).toList();

  ItemConfiguracao? item(String componente) {
    for (final i in itens) {
      if (i.componente == componente) return i;
    }
    return null;
  }
}

abstract final class Componentes {
  static String conjunto(Tecnologia t) => switch (t) {
    Tecnologia.seleniumNeo => 'Conjunto dosador Selenium Neo',
    _ => 'Conjunto ${t.nome}',
  };

  static String kitConversao(Tecnologia t) => switch (t) {
    Tecnologia.titaniumEletric => 'Kit conversão Titanium Elétric',
    Tecnologia.seleniumEletric =>
      'Kit conversão Selenium G3 p/ Selenium Elétric',
    Tecnologia.seleniumNeo => throw ArgumentError('Selenium Neo não tem kit'),
  };
  static const ecu = 'Conjunto ECU';
  static const sensorLevante = 'Sensor de levante';
  static const sensorSemente = 'Sensor de semente';
  static const caboIsobus = 'Cabo ISOBUS';
  static const alternador = 'Alternador hidráulico';
  static const mangueiras = 'Kit de mangueiras do alternador';
  static const caboBateria = 'Cabo de alimentação direto da bateria';
  static const chicote4 = 'Chicote de 4 linhas';
  static const chicote1 = 'Chicote de 1 linha';
  static const chicotePainel = 'Chicote painel';

  // Titanium Elétric.
  static const discoMilhoTitanium =
      'Conjunto disco/anéis Titanium milho 28 furos';
  static const discoSojaTitanium =
      'Conjunto disco/anéis Titanium soja 90 furos';
  static const reservatorioPipoqueira = 'Reservatório de sementes pipoqueira';

  /// Bocal do reservatório pipoqueira antes de o vendedor escolher.
  static const bocalPipoqueira = 'Bocal do reservatório pipoqueira';

  // Selenium Elétric.
  static const discoSojaSelenium =
      'Subconjunto disco/anel soja 40 furos Selenium V23';
  static const discoMilhoSelenium = 'Subconjunto disco/anel milho Selenium V23';

  /// Kit bocal do Selenium antes de o vendedor escolher.
  static const bocalSelenium = 'Kit bocal de sementes Selenium';

  /// Condutor de sementes do Selenium antes de escolher a adaptação.
  static const condutorSelenium = 'Condutor de sementes';

  // Selenium Neo.
  static const esteiraNeo = 'Conjunto esteira transportadora Neo';
  static const bocalNeo = 'Kit bocal de sementes Selenium Neo';

  /// Os quatro subconjuntos; a regra de alta e baixa velocidade vem depois.
  static const discoNeo = 'Subconjunto disco/anel Selenium Neo 26';
  static const discosNeo = [
    'Subconjunto disco/anel milho 14 furos Neo 26 (milho baixa velocidade)',
    'Subconjunto disco/anel milho 28 furos Neo 26 (milho alta velocidade)',
    'Subconjunto disco/anel soja 35 furos Neo 26 (soja baixa velocidade)',
    'Subconjunto disco/anel soja 70 furos Neo 26 (soja alta velocidade)',
  ];

  /// Selenium Neo: até 22 linhas o alternador de 100 A; acima, o de 250 A.
  static const alternador100 = 'Alternador hidráulico 100 A';
  static const alternador250 = 'Alternador hidráulico 250 A';
}

class RegrasConfigurador {
  static const saidasPorAlternador = 6;
  static const linhasPorSaida = 10;
  static const linhasSemAlternadorObrigatorio = 12;

  /// Padrão sem alternador: 2 chicotes painel de 4 m.
  static const chicotesPainelSemAlternador = 2;
  static const comprimentoPainelSemAlternador = 4;

  static int get capacidadeMaxima => saidasPorAlternador * linhasPorSaida;

  /// Selenium Neo: até 22 linhas o alternador de 100 A; acima, o de 250 A,
  /// por enquanto até 55 linhas (11 saídas de 5 linhas, a confirmar).
  static const linhasNeoAlternador100 = 22;
  static const linhasMaximasNeo = 55;
  static const saidasAlternador250 = 11;

  /// Linhas que a tecnologia aceita numa máquina.
  static int capacidade(Tecnologia t) =>
      t == Tecnologia.seleniumNeo ? linhasMaximasNeo : capacidadeMaxima;

  /// Saídas do alternador usado na máquina.
  static int saidasDoAlternador(EntradaConfiguracao e) =>
      e.tecnologia == Tecnologia.seleniumNeo &&
          e.totalLinhas > linhasNeoAlternador100
      ? saidasAlternador250
      : saidasPorAlternador;

  /// Linhas que o alternador usado atende: no Selenium Neo, 22 no de 100 A
  /// e 55 no de 250 A.
  static int limiteDoAlternador(EntradaConfiguracao e) =>
      e.tecnologia != Tecnologia.seleniumNeo
      ? capacidadeMaxima
      : e.totalLinhas > linhasNeoAlternador100
      ? linhasMaximasNeo
      : linhasNeoAlternador100;

  /// Nome do alternador no resultado: no Selenium Neo, com a amperagem.
  static String componenteAlternador(EntradaConfiguracao e) =>
      e.tecnologia != Tecnologia.seleniumNeo
      ? Componentes.alternador
      : e.totalLinhas > linhasNeoAlternador100
      ? Componentes.alternador250
      : Componentes.alternador100;

  /// Alternador é obrigatório a partir de 13 linhas e em toda máquina com
  /// seções separadas: máquina sem alternador é, na prática, solteira. No
  /// Selenium Neo ele é sempre usado.
  static bool alternadorObrigatorio(
    int linhas,
    TipoPlantadeira tipo, [
    Tecnologia? tecnologia,
  ]) =>
      tecnologia == Tecnologia.seleniumNeo ||
      tipo.secoesSeparadas ||
      linhas > linhasSemAlternadorObrigatorio;

  /// Só na solteira de até 12 linhas (fora o Selenium Neo) o vendedor
  /// responde se haverá alternador.
  static bool perguntarAlternador(
    int linhas,
    TipoPlantadeira tipo, [
    Tecnologia? tecnologia,
  ]) => linhas > 0 && !alternadorObrigatorio(linhas, tipo, tecnologia);

  static bool usaAlternador(EntradaConfiguracao e) =>
      alternadorObrigatorio(e.totalLinhas, e.tipo, e.tecnologia) ||
      (e.temAlternador ?? false);

  /// Chicotes de 4 e de 1 linha de uma seção. Cada seção é montada como se
  /// fosse uma máquina separada, porque fecha sozinha.
  static ({int quatro, int um}) chicotesDaSecao(int linhas) =>
      (quatro: linhas ~/ 4, um: linhas % 4);

  static const observacaoComprimento =
      'O comprimento segue o tamanho da máquina: confirmar as '
      'características da máquina para ter certeza.';

  /// Pergunta sobre a posição do alternador, que define a sugestão de
  /// comprimento no autotransportável e no tandem. Nula se não se aplica.
  static String? perguntaAlternadorNaFrente(EntradaConfiguracao e) {
    if (!usaAlternador(e)) return null;
    return switch (e.tipo) {
      TipoPlantadeira.autotransportavel =>
        'A máquina permite instalar o alternador no cabeçalho?',
      TipoPlantadeira.tandem =>
        'A máquina permite instalar o alternador no tandem?',
      _ => null,
    };
  }

  /// Comprimentos sugeridos de cabo ISOBUS e mangueiras, em metros. Os dois
  /// saem de pontos próximos, por isso andam em dupla. Nula se depende de
  /// uma resposta que ainda não foi dada.
  static ({int isobus, int mangueiras})? sugestaoComprimentos(
    EntradaConfiguracao e,
  ) => switch (e.tipo) {
    TipoPlantadeira.solteira => (isobus: 5, mangueiras: 6),
    TipoPlantadeira.caixaCentral => (isobus: 17, mangueiras: 15),
    TipoPlantadeira.autotransportavel ||
    TipoPlantadeira.tandem => switch (perguntaAlternadorNaFrente(e) == null
        ? null
        : e.alternadorNaFrente) {
      true => (isobus: 5, mangueiras: 6),
      false => (isobus: 11, mangueiras: 12),
      null => null,
    },
  };

  static List<Validacao> validar(EntradaConfiguracao e) {
    final v = <Validacao>[];
    if (e.totalLinhas < 1) {
      v.add(
        const Validacao(NivelValidacao.erro, 'Informe o número de linhas.'),
      );
      return v;
    }
    if (e.totalLinhas > capacidade(e.tecnologia)) {
      v.add(
        Validacao(
          NivelValidacao.erro,
          e.tecnologia == Tecnologia.seleniumNeo
              ? 'Selenium Neo com ${e.totalLinhas} linhas passa do limite de '
                    '$linhasMaximasNeo linhas do alternador de 250 A. Precisa '
                    'de validação técnica.'
              : 'Máquina com ${e.totalLinhas} linhas passa da capacidade de '
                    'um alternador ($saidasPorAlternador saídas × '
                    '$linhasPorSaida linhas = $capacidadeMaxima). Precisa de '
                    'validação técnica.',
        ),
      );
    }
    if (e.secoes.isEmpty) {
      v.add(
        const Validacao(NivelValidacao.erro, 'Informe as seções da máquina.'),
      );
    } else {
      if (e.secoes.any((s) => s < 1)) {
        v.add(
          const Validacao(
            NivelValidacao.erro,
            'Toda seção precisa ter pelo menos 1 linha.',
          ),
        );
      }
      final soma = e.secoes.fold(0, (s, n) => s + n);
      if (soma != e.totalLinhas) {
        v.add(
          Validacao(
            NivelValidacao.erro,
            'A soma das seções ($soma) é diferente do total de linhas '
            '(${e.totalLinhas}).',
          ),
        );
      }
    }
    if (perguntarAlternador(e.totalLinhas, e.tipo, e.tecnologia) &&
        e.temAlternador == null) {
      v.add(
        const Validacao(
          NivelValidacao.erro,
          'Responda se a máquina terá alternador hidráulico.',
        ),
      );
    }
    void comprimento(String componente, int? escolhido, List<int> opcoes) {
      if (escolhido != null && !opcoes.contains(escolhido)) {
        v.add(
          Validacao(
            NivelValidacao.erro,
            '$componente não tem $escolhido m. Opções: ${_metros(opcoes)}.',
          ),
        );
      }
    }

    comprimento(
      Componentes.caboIsobus,
      e.comprimentoIsobus,
      Comprimentos.isobus,
    );
    comprimento(
      Componentes.mangueiras,
      e.comprimentoMangueiras,
      Comprimentos.mangueiras,
    );
    for (final MapEntry(key: metros, value: qtd)
        in e.chicotesPainel?.entries ?? const <MapEntry<int, int>>[]) {
      comprimento(
        Componentes.chicotePainel,
        metros,
        Comprimentos.chicotePainel,
      );
      if (qtd < 0) {
        v.add(
          Validacao(
            NivelValidacao.erro,
            'A quantidade de chicotes painel de $metros m não pode ser '
            'negativa.',
          ),
        );
      }
    }
    final adaptacao = e.adaptacao;
    if (adaptacao != null && !adaptacaoValida(e.tecnologia, adaptacao)) {
      v.add(
        Validacao(
          NivelValidacao.erro,
          'Adaptação $adaptacao não existe para ${e.tecnologia.nome}.',
        ),
      );
    }
    return v;
  }

  /// Distribui as linhas pelas saídas do alternador, [porSaida] linhas em
  /// cada uma de [saidas] saídas. Nula se não couber.
  static DistribuicaoSaidas? distribuirSaidas(
    List<int> linhasPorSecao, {
    int porSaida = linhasPorSaida,
    int saidas = saidasPorAlternador,
  }) {
    final total = linhasPorSecao.fold(0, (s, n) => s + n);
    if (total < 1 || total > porSaida * saidas) return null;
    List<int> dividir(int linhas) => _dividir(linhas, porSaida);

    // 1. Sem misturar seções.
    final porSecao = <SaidaAlternador>[];
    var inicio = 1;
    for (var s = 0; s < linhasPorSecao.length; s++) {
      for (final tamanho in dividir(linhasPorSecao[s])) {
        porSecao.add(
          SaidaAlternador(
            numero: porSecao.length + 1,
            primeiraLinha: inicio,
            ultimaLinha: inicio + tamanho - 1,
            secoes: [s + 1],
            trechos: [tamanho],
          ),
        );
        inicio += tamanho;
      }
    }
    if (porSecao.length <= saidas) {
      return DistribuicaoSaidas(
        modo: ModoDistribuicao.porSecao,
        saidas: porSecao,
      );
    }

    // 2. Recurso global: conjuntos equilibrados em sequência.
    final fimDaSecao = <int>[];
    var acumulado = 0;
    for (final n in linhasPorSecao) {
      acumulado += n;
      fimDaSecao.add(acumulado);
    }
    int secaoDaLinha(int linha) =>
        fimDaSecao.indexWhere((fim) => linha <= fim) + 1;

    final global = <SaidaAlternador>[];
    inicio = 1;
    for (final tamanho in dividir(total)) {
      final fim = inicio + tamanho - 1;
      final secoes = [
        for (var s = secaoDaLinha(inicio); s <= secaoDaLinha(fim); s++) s,
      ];
      global.add(
        SaidaAlternador(
          numero: global.length + 1,
          primeiraLinha: inicio,
          ultimaLinha: fim,
          secoes: secoes,
          trechos: [
            for (final s in secoes)
              _min(fim, fimDaSecao[s - 1]) -
                  _max(inicio, s == 1 ? 1 : fimDaSecao[s - 2] + 1) +
                  1,
          ],
        ),
      );
      inicio = fim + 1;
    }
    return DistribuicaoSaidas(modo: ModoDistribuicao.global, saidas: global);
  }

  /// Divide [linhas] no menor número de conjuntos de até [porSaida],
  /// equilibrados.
  static List<int> _dividir(int linhas, int porSaida) {
    final conjuntos = (linhas / porSaida).ceil();
    final base = linhas ~/ conjuntos;
    final sobra = linhas % conjuntos;
    return [for (var i = 0; i < conjuntos; i++) base + (i < sobra ? 1 : 0)];
  }

  static int _min(int a, int b) => a < b ? a : b;
  static int _max(int a, int b) => a > b ? a : b;

  static String _metros(List<int> opcoes) =>
      '${opcoes.take(opcoes.length - 1).join(', ')} ou ${opcoes.last} m';

  /// Item vendido por comprimento: pendente até o vendedor escolher.
  static ItemConfiguracao _porComprimento({
    required String componente,
    required int quantidade,
    required String motivo,
    required List<int> opcoes,
    required int? escolhido,
    int? quantidadeRecomendada,
    int? sugerido,
    String? origemSugestao,
    String? perguntaPendente,
    String? observacao,
  }) {
    final valido = escolhido != null && opcoes.contains(escolhido);
    final escolher =
        'Escolher o comprimento conforme o tamanho da máquina '
        '(${_metros(opcoes)}).';
    return ItemConfiguracao(
      componente: componente,
      quantidade: quantidade,
      motivo: motivo,
      status: valido ? StatusItem.definido : StatusItem.pendente,
      pendencia: valido
          ? null
          : [
              if (sugerido != null)
                'Sugerido: $sugerido m ($origemSugestao).'
              else if (perguntaPendente != null)
                'Responda "$perguntaPendente" para ver a sugestão.',
              escolher,
            ].join(' '),
      comprimento: valido ? escolhido : null,
      opcoesComprimento: opcoes,
      quantidadeRecomendada: quantidadeRecomendada,
      comprimentoSugerido: sugerido,
      observacao: observacao,
    );
  }

  /// Texto curto de onde vem a sugestão de comprimento.
  static String _origemSugestao(EntradaConfiguracao e) => switch (e.tipo) {
    TipoPlantadeira.autotransportavel =>
      e.alternadorNaFrente!
          ? 'autotransportável com alternador no cabeçalho'
          : 'autotransportável sem alternador no cabeçalho',
    TipoPlantadeira.tandem =>
      e.alternadorNaFrente!
          ? 'tandem com alternador no tandem'
          : 'tandem sem alternador no tandem',
    TipoPlantadeira.caixaCentral => 'caixa central',
    TipoPlantadeira.solteira => 'solteira',
  };

  /// Selenium Elétric (fora do kit conversão): condutor de sementes da
  /// adaptação escolhida, um por linha.
  static ItemConfiguracao? _condutorSelenium(EntradaConfiguracao e) {
    if (e.tecnologia != Tecnologia.seleniumEletric || e.kitConversao) {
      return null;
    }
    final a = e.adaptacao;
    final condutor = a == null ? null : condutoresSelenium[a.marca]?[a.modelo];
    if (condutor == null) {
      return ItemConfiguracao(
        componente: Componentes.condutorSelenium,
        quantidade: e.totalLinhas,
        motivo: 'Um por linha (${e.totalLinhas} linhas).',
        status: StatusItem.pendente,
        pendencia: 'Escolher a adaptação (marca e modelo da plantadeira).',
      );
    }
    if (condutor == condutorOriginal) return null;
    return ItemConfiguracao(
      componente: condutor,
      quantidade: e.totalLinhas,
      motivo: 'Pela adaptação $a, um por linha.',
    );
  }

  /// Aviso de que a plantadeira mantém o condutor de sementes original.
  static Validacao? _avisoCondutorOriginal(EntradaConfiguracao e) {
    final a = e.adaptacao;
    if (e.tecnologia != Tecnologia.seleniumEletric ||
        e.kitConversao ||
        a == null ||
        condutoresSelenium[a.marca]?[a.modelo] != condutorOriginal) {
      return null;
    }
    return Validacao(
      NivelValidacao.info,
      'A adaptação $a usa o condutor de sementes original da plantadeira.',
    );
  }

  /// Discos, reservatório e bocais de cada tecnologia, um por linha.
  static List<ItemConfiguracao> _itensDaTecnologia(EntradaConfiguracao e) {
    if (e.kitConversao) return const [];
    final linhas = e.totalLinhas;
    final porLinha = 'Um por linha ($linhas linhas).';
    ItemConfiguracao item(String componente) => ItemConfiguracao(
      componente: componente,
      quantidade: linhas,
      motivo: porLinha,
    );
    ItemConfiguracao pendente(String componente, String pendencia) =>
        ItemConfiguracao(
          componente: componente,
          quantidade: linhas,
          motivo: porLinha,
          status: StatusItem.pendente,
          pendencia: pendencia,
        );

    switch (e.tecnologia) {
      case Tecnologia.titaniumEletric:
        return [
          item(Componentes.discoMilhoTitanium),
          item(Componentes.discoSojaTitanium),
          if (e.reservatorioPipoqueira == null)
            pendente(
              Componentes.reservatorioPipoqueira,
              'Responder se terá reservatório de sementes pipoqueira.',
            )
          else if (e.reservatorioPipoqueira!) ...[
            item(Componentes.reservatorioPipoqueira),
            if (e.bocalTitanium == null)
              pendente(
                Componentes.bocalPipoqueira,
                'Escolher o bocal: '
                '${BocalTitanium.values.map((b) => b.nome).join(', ')}.',
              )
            else
              item(e.bocalTitanium!.nome),
          ],
        ];
      case Tecnologia.seleniumEletric:
        return [
          item(Componentes.discoSojaSelenium),
          item(Componentes.discoMilhoSelenium),
          if (e.bocalSelenium == null)
            pendente(Componentes.bocalSelenium, 'Escolher o kit bocal.')
          else
            item(e.bocalSelenium!.nome),
        ];
      case Tecnologia.seleniumNeo:
        return [
          pendente(
            Componentes.discoNeo,
            'A regra de escolha entre alta e baixa velocidade ainda vai ser '
            'definida. Opções: ${Componentes.discosNeo.join('; ')}.',
          ),
          if (e.bocalNeo == null)
            pendente(Componentes.bocalNeo, 'Escolher o kit bocal.')
          else if (!e.bocalNeo!.vemNoDosador)
            item(e.bocalNeo!.nome),
        ];
    }
  }

  /// Chicote painel: quantidade recomendada pelas seções e saídas usadas; o
  /// vendedor escolhe quantos de cada comprimento. Sem alternador o padrão é
  /// 2 de 4 m.
  static ItemConfiguracao? _chicotePainel(
    EntradaConfiguracao e,
    DistribuicaoSaidas? distribuicao,
  ) {
    final int recomendado;
    final String motivo;
    var escolhidos = e.chicotesPainel;
    if (distribuicao != null) {
      final saidas = distribuicao.saidas.length;
      final trocas = distribuicao.trechos.length - saidas;
      recomendado = saidas + trocas;
      motivo =
          'Leva a alimentação de cada saída do alternador até os chicotes de '
          'linha. Recomendado: $recomendado ($saidas saídas usadas'
          '${trocas > 0 ? ' + $trocas trocas de seção dentro de uma saída' : ''}).';
    } else if (e.temAlternador == false) {
      recomendado = chicotesPainelSemAlternador;
      escolhidos ??= {comprimentoPainelSemAlternador: recomendado};
      motivo =
          'Obrigatório em máquina sem alternador: padrão de '
          '$chicotesPainelSemAlternador de $comprimentoPainelSemAlternador m.';
    } else {
      return null;
    }
    final quantidades = {
      for (final m in Comprimentos.chicotePainel)
        if ((escolhidos?[m] ?? 0) > 0) m: escolhidos![m]!,
    };
    final total = quantidades.values.fold(0, (s, n) => s + n);
    return ItemConfiguracao(
      componente: Componentes.chicotePainel,
      quantidade: total,
      motivo: motivo,
      status: total > 0 ? StatusItem.definido : StatusItem.pendente,
      pendencia: total > 0
          ? null
          : 'Escolher quantos chicotes painel de cada comprimento '
                '(${_metros(Comprimentos.chicotePainel)}). '
                'Recomendado: $recomendado.',
      opcoesComprimento: Comprimentos.chicotePainel,
      quantidadeRecomendada: recomendado,
      quantidadesPorComprimento: quantidades,
    );
  }

  static ResultadoConfiguracao configurar(EntradaConfiguracao e) {
    final validacoes = validar(e);
    final linhas = e.totalLinhas;
    final alternador = usaAlternador(e);
    final bloqueada = validacoes.any((v) => v.bloqueia);
    final distribuicao = alternador && !bloqueada
        ? distribuirSaidas(
            e.secoes,
            porSaida: e.tecnologia.linhasPorSaida,
            saidas: saidasDoAlternador(e),
          )
        : null;
    final neo = e.tecnologia == Tecnologia.seleniumNeo;

    // Chicotes de linha por seção, nunca pelo total da máquina.
    final secoes = bloqueada ? <int>[] : e.secoes;
    var quatro = 0, um = 0;
    for (final s in secoes) {
      final c = chicotesDaSecao(s);
      quatro += c.quatro;
      um += c.um;
    }
    final porSecao =
        'Por seção, como se cada uma fosse uma máquina separada '
        '(${secoes.map((s) {
          final c = chicotesDaSecao(s);
          return '$s linhas: ${c.quatro} de 4 + ${c.um} de 1';
        }).join('; ')}).';

    final sugestao = sugestaoComprimentos(e);
    final origem = sugestao == null ? null : _origemSugestao(e);
    final pergunta = perguntaAlternadorNaFrente(e);

    final itens = <ItemConfiguracao>[
      if (linhas > 0)
        ItemConfiguracao(
          componente: e.kitConversao
              ? Componentes.kitConversao(e.tecnologia)
              : Componentes.conjunto(e.tecnologia),
          quantidade: linhas,
          motivo: 'Um por linha ($linhas linhas).',
        ),
      if (linhas > 0) ..._itensDaTecnologia(e),
      if (linhas > 0) ?_condutorSelenium(e),
      const ItemConfiguracao(
        componente: Componentes.ecu,
        quantidade: 1,
        motivo: 'Obrigatório em toda configuração.',
      ),
      const ItemConfiguracao(
        componente: Componentes.sensorLevante,
        quantidade: 1,
        motivo: 'Obrigatório em toda configuração.',
      ),
      // No Selenium Neo a esteira transportadora entra no lugar do sensor.
      if (linhas > 0)
        ItemConfiguracao(
          componente: neo ? Componentes.esteiraNeo : Componentes.sensorSemente,
          quantidade: linhas,
          motivo: 'Um por linha ($linhas linhas).',
        ),
      _porComprimento(
        componente: Componentes.caboIsobus,
        quantidade: 1,
        motivo: 'Obrigatório em toda configuração.',
        opcoes: Comprimentos.isobus,
        escolhido: e.comprimentoIsobus,
        sugerido: sugestao?.isobus,
        origemSugestao: origem,
        perguntaPendente: pergunta,
        observacao: observacaoComprimento,
      ),
      if (alternador) ...[
        ItemConfiguracao(
          componente: componenteAlternador(e),
          quantidade: 1,
          motivo: neo
              ? linhas > linhasNeoAlternador100
                    ? 'Selenium Neo acima de $linhasNeoAlternador100 linhas usa '
                          'o de 250 A.'
                    : 'Sempre usado no Selenium Neo; até '
                          '$linhasNeoAlternador100 linhas, o de 100 A.'
              : e.tipo.secoesSeparadas
              ? 'Obrigatório em ${e.tipo.nome.toLowerCase()}.'
              : alternadorObrigatorio(linhas, e.tipo)
              ? 'Obrigatório a partir de 13 linhas.'
              : 'Escolhido para a máquina de $linhas linhas.',
        ),
        _porComprimento(
          componente: Componentes.mangueiras,
          quantidade: 1,
          motivo:
              'Acompanha o alternador: 3 mangueiras, uma mais fina para '
              'o dreno.',
          opcoes: Comprimentos.mangueiras,
          escolhido: e.comprimentoMangueiras,
          sugerido: sugestao?.mangueiras,
          origemSugestao: origem,
          perguntaPendente: pergunta,
          observacao: observacaoComprimento,
        ),
      ] else if (e.temAlternador == false)
        const ItemConfiguracao(
          componente: Componentes.caboBateria,
          quantidade: 1,
          motivo: 'Obrigatório em máquina sem alternador.',
        ),
      if (quatro > 0)
        ItemConfiguracao(
          componente: Componentes.chicote4,
          quantidade: quatro,
          motivo: porSecao,
        ),
      if (um > 0)
        ItemConfiguracao(
          componente: Componentes.chicote1,
          quantidade: um,
          motivo: porSecao,
        ),
      ?_chicotePainel(e, distribuicao),
    ];

    if (_avisoCondutorOriginal(e) case final info?) validacoes.add(info);
    if (neo && (e.bocalNeo?.vemNoDosador ?? false)) {
      validacoes.add(
        const Validacao(
          NivelValidacao.info,
          'O kit bocal de pressão positiva já vem no conjunto dosador '
          'Selenium Neo: não entra como item à parte.',
        ),
      );
    }

    final painel = itens.lastOrNull;
    if (painel != null &&
        painel.componente == Componentes.chicotePainel &&
        painel.quantidade > 0 &&
        painel.quantidade != painel.quantidadeRecomendada) {
      validacoes.add(
        Validacao(
          NivelValidacao.aviso,
          'Chicote painel: ${painel.quantidade} escolhidos, recomendado '
          '${painel.quantidadeRecomendada}.',
        ),
      );
    }

    if (distribuicao != null) {
      for (final s in distribuicao.saidasQueMisturamSecoes) {
        validacoes.add(
          Validacao(
            NivelValidacao.aviso,
            'Saída ${s.numero} (linhas ${s.primeiraLinha} a ${s.ultimaLinha}) '
            'atende as seções ${s.secoes.join(' e ')}: validar com a '
            'engenharia.',
          ),
        );
      }
    }

    return ResultadoConfiguracao(
      entrada: e,
      itens: itens,
      validacoes: validacoes,
      distribuicao: distribuicao,
    );
  }
}
