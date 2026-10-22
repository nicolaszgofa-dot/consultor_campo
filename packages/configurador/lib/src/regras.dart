/// Motor de regras do Configurador Técnico J.Assy.
///
/// Regras e pendências: docs/configurador/especificacao.md. Regras ainda sem
/// definição técnica entram no resultado como [StatusItem.pendente].
library;

enum Tecnologia {
  titaniumEletric('Titanium Elétric'),
  seleniumEletric('Selenium Elétric');

  final String nome;

  const Tecnologia(this.nome);
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

/// Como o vendedor monta os chicotes de linha de cada conjunto.
enum ComposicaoChicotes {
  /// O máximo de chicotes de 4 linhas, o resto com chicotes de 1 linha.
  quatroEUm('Chicotes de 4 linhas, completando com de 1 linha'),

  /// Um chicote de 1 linha por linha.
  soUmaLinha('Só chicotes de 1 linha');

  final String nome;

  const ComposicaoChicotes(this.nome);
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

  final ComposicaoChicotes composicaoChicotes;

  /// Comprimentos escolhidos pelo vendedor, em metros. Nulo = não escolhido.
  final int? comprimentoIsobus;
  final int? comprimentoChicotePainel;
  final int? comprimentoMangueiras;

  const EntradaConfiguracao({
    required this.tecnologia,
    required this.tipo,
    required this.totalLinhas,
    this.linhasPorSecao = const [],
    this.temAlternador,
    this.composicaoChicotes = ComposicaoChicotes.quatroEUm,
    this.comprimentoIsobus,
    this.comprimentoChicotePainel,
    this.comprimentoMangueiras,
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

  const ItemConfiguracao({
    required this.componente,
    required this.quantidade,
    required this.motivo,
    this.status = StatusItem.definido,
    this.pendencia,
    this.comprimento,
    this.opcoesComprimento = const [],
  });
}

enum NivelValidacao { erro, aviso }

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
  static String conjunto(Tecnologia t) => 'Conjunto ${t.nome}';
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
}

class RegrasConfigurador {
  static const saidasPorAlternador = 6;
  static const linhasPorSaida = 10;
  static const linhasSemAlternadorObrigatorio = 12;

  static int get capacidadeMaxima => saidasPorAlternador * linhasPorSaida;

  /// Alternador é obrigatório a partir de 13 linhas.
  static bool alternadorObrigatorio(int linhas) =>
      linhas > linhasSemAlternadorObrigatorio;

  /// Até 12 linhas o vendedor precisa responder se haverá alternador.
  static bool perguntarAlternador(int linhas) =>
      linhas > 0 && !alternadorObrigatorio(linhas);

  static bool usaAlternador(EntradaConfiguracao e) =>
      alternadorObrigatorio(e.totalLinhas) || (e.temAlternador ?? false);

  /// Chicotes de 4 e de 1 linha para um trecho de [linhas] em sequência.
  static ({int quatro, int um}) chicotesDoTrecho(
    int linhas,
    ComposicaoChicotes composicao,
  ) => switch (composicao) {
    ComposicaoChicotes.quatroEUm => (quatro: linhas ~/ 4, um: linhas % 4),
    ComposicaoChicotes.soUmaLinha => (quatro: 0, um: linhas),
  };

  static List<Validacao> validar(EntradaConfiguracao e) {
    final v = <Validacao>[];
    if (e.totalLinhas < 1) {
      v.add(
        const Validacao(NivelValidacao.erro, 'Informe o número de linhas.'),
      );
      return v;
    }
    if (e.totalLinhas > capacidadeMaxima) {
      v.add(
        Validacao(
          NivelValidacao.erro,
          'Máquina com ${e.totalLinhas} linhas passa da capacidade de um '
          'alternador ($saidasPorAlternador saídas × $linhasPorSaida linhas = '
          '$capacidadeMaxima). Precisa de validação técnica.',
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
    if (perguntarAlternador(e.totalLinhas) && e.temAlternador == null) {
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
      Componentes.chicotePainel,
      e.comprimentoChicotePainel,
      Comprimentos.chicotePainel,
    );
    comprimento(
      Componentes.mangueiras,
      e.comprimentoMangueiras,
      Comprimentos.mangueiras,
    );
    return v;
  }

  /// Distribui as linhas pelas saídas do alternador. Nula se não couber.
  static DistribuicaoSaidas? distribuirSaidas(List<int> linhasPorSecao) {
    final total = linhasPorSecao.fold(0, (s, n) => s + n);
    if (total < 1 || total > capacidadeMaxima) return null;

    // 1. Sem misturar seções.
    final porSecao = <SaidaAlternador>[];
    var inicio = 1;
    for (var s = 0; s < linhasPorSecao.length; s++) {
      for (final tamanho in _dividir(linhasPorSecao[s])) {
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
    if (porSecao.length <= saidasPorAlternador) {
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
    for (final tamanho in _dividir(total)) {
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

  /// Divide [linhas] no menor número de conjuntos de até 10, equilibrados.
  static List<int> _dividir(int linhas) {
    final conjuntos = (linhas / linhasPorSaida).ceil();
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
  }) {
    final valido = escolhido != null && opcoes.contains(escolhido);
    return ItemConfiguracao(
      componente: componente,
      quantidade: quantidade,
      motivo: motivo,
      status: valido ? StatusItem.definido : StatusItem.pendente,
      pendencia: valido
          ? null
          : 'Escolher o comprimento conforme o tamanho da máquina '
                '(${_metros(opcoes)}).',
      comprimento: valido ? escolhido : null,
      opcoesComprimento: opcoes,
    );
  }

  static ResultadoConfiguracao configurar(EntradaConfiguracao e) {
    final validacoes = validar(e);
    final linhas = e.totalLinhas;
    final alternador = usaAlternador(e);
    final bloqueada = validacoes.any((v) => v.bloqueia);
    final distribuicao = alternador && !bloqueada
        ? distribuirSaidas(e.secoes)
        : null;

    // Trechos ligados em sequência pelos chicotes de linha.
    final trechos = distribuicao?.trechos ?? (bloqueada ? <int>[] : e.secoes);
    var quatro = 0, um = 0;
    for (final t in trechos) {
      final c = chicotesDoTrecho(t, e.composicaoChicotes);
      quatro += c.quatro;
      um += c.um;
    }
    final composicao = switch (e.composicaoChicotes) {
      ComposicaoChicotes.quatroEUm => 'até 4 linhas por chicote',
      ComposicaoChicotes.soUmaLinha => 'um por linha',
    };

    final itens = <ItemConfiguracao>[
      if (linhas > 0)
        ItemConfiguracao(
          componente: Componentes.conjunto(e.tecnologia),
          quantidade: linhas,
          motivo: 'Um por linha ($linhas linhas).',
        ),
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
      if (linhas > 0)
        ItemConfiguracao(
          componente: Componentes.sensorSemente,
          quantidade: linhas,
          motivo: 'Um por linha ($linhas linhas).',
        ),
      _porComprimento(
        componente: Componentes.caboIsobus,
        quantidade: 1,
        motivo: 'Obrigatório em toda configuração.',
        opcoes: Comprimentos.isobus,
        escolhido: e.comprimentoIsobus,
      ),
      if (alternador) ...[
        ItemConfiguracao(
          componente: Componentes.alternador,
          quantidade: 1,
          motivo: alternadorObrigatorio(linhas)
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
        ),
      ] else if (e.temAlternador == false)
        const ItemConfiguracao(
          componente: Componentes.caboBateria,
          quantidade: 1,
          motivo: 'Máquina sem alternador: alimentação direto da bateria.',
        ),
      if (quatro > 0)
        ItemConfiguracao(
          componente: Componentes.chicote4,
          quantidade: quatro,
          motivo: 'Chicotes de linha, $composicao.',
        ),
      if (um > 0)
        ItemConfiguracao(
          componente: Componentes.chicote1,
          quantidade: um,
          motivo: 'Chicotes de linha, $composicao.',
        ),
      if (distribuicao != null)
        _porComprimento(
          componente: Componentes.chicotePainel,
          quantidade: trechos.length,
          motivo:
              'Um por saída do alternador até os chicotes de linha, mais '
              'um a cada passagem de uma seção para outra.',
          opcoes: Comprimentos.chicotePainel,
          escolhido: e.comprimentoChicotePainel,
        )
      else if (e.temAlternador == false)
        const ItemConfiguracao(
          componente: Componentes.chicotePainel,
          quantidade: 0,
          motivo: 'Ligação da alimentação até os chicotes de linha.',
          status: StatusItem.pendente,
          pendencia: 'Quantidade sem alternador a definir.',
          opcoesComprimento: Comprimentos.chicotePainel,
        ),
    ];

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
