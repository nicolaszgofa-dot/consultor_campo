/// Motor de regras do Configurador Técnico J.Assy.
///
/// Regras e pendências: docs/configurador/especificacao.md. Regras ainda sem
/// definição técnica entram no resultado como [StatusItem.pendente].
library;

enum Tecnologia {
  titaniumElectric('Titanium Electric'),
  seleniumElectric('Selenium Electric');

  final String nome;

  const Tecnologia(this.nome);
}

/// Dados levantados na máquina.
class EntradaConfiguracao {
  final Tecnologia tecnologia;
  final int totalLinhas;

  /// Ex.: "Autotransportável". Lista oficial ainda pendente.
  final String arquitetura;

  /// Linhas de cada seção, na ordem da máquina.
  final List<int> linhasPorSecao;

  /// Só é perguntado em máquinas de até 12 linhas. Nulo = não respondido.
  final bool? temAlternador;

  const EntradaConfiguracao({
    required this.tecnologia,
    required this.totalLinhas,
    required this.arquitetura,
    required this.linhasPorSecao,
    this.temAlternador,
  });
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

  const ItemConfiguracao({
    required this.componente,
    required this.quantidade,
    required this.motivo,
    this.status = StatusItem.definido,
    this.pendencia,
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

  const SaidaAlternador({
    required this.numero,
    required this.primeiraLinha,
    required this.ultimaLinha,
    required this.secoes,
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
  static const ecu = 'ECU';
  static const sensorLevante = 'Sensor de levante';
  static const sensorSemente = 'Sensor de semente';
  static const caboIsobus = 'Cabo ISOBUS';
  static const alternador = 'Alternador hidráulico';
  static const caboBateria = 'Cabo de alimentação direto da bateria';
  static const chicotes = 'Chicotes de 1 e 4 linhas';
  static const caboPainel = 'Cabo de painel';
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
    if (e.linhasPorSecao.isEmpty) {
      v.add(
        const Validacao(NivelValidacao.erro, 'Informe as seções da máquina.'),
      );
    } else {
      if (e.linhasPorSecao.any((s) => s < 1)) {
        v.add(
          const Validacao(
            NivelValidacao.erro,
            'Toda seção precisa ter pelo menos 1 linha.',
          ),
        );
      }
      final soma = e.linhasPorSecao.fold(0, (s, n) => s + n);
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
      global.add(
        SaidaAlternador(
          numero: global.length + 1,
          primeiraLinha: inicio,
          ultimaLinha: fim,
          secoes: [
            for (var s = secaoDaLinha(inicio); s <= secaoDaLinha(fim); s++) s,
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

  static ResultadoConfiguracao configurar(EntradaConfiguracao e) {
    final validacoes = validar(e);
    final linhas = e.totalLinhas;
    final usaAlternador =
        alternadorObrigatorio(linhas) || (e.temAlternador ?? false);

    final itens = <ItemConfiguracao>[
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
      const ItemConfiguracao(
        componente: Componentes.caboIsobus,
        quantidade: 1,
        motivo: 'Obrigatório em toda configuração.',
        status: StatusItem.pendente,
        pendencia: 'Modelo e comprimento a definir.',
      ),
      if (usaAlternador)
        ItemConfiguracao(
          componente: Componentes.alternador,
          quantidade: 1,
          motivo: alternadorObrigatorio(linhas)
              ? 'Obrigatório a partir de 13 linhas.'
              : 'Escolhido para a máquina de $linhas linhas.',
        )
      else if (e.temAlternador == false)
        const ItemConfiguracao(
          componente: Componentes.caboBateria,
          quantidade: 1,
          motivo: 'Máquina sem alternador: alimentação direto da bateria.',
        ),
      const ItemConfiguracao(
        componente: Componentes.chicotes,
        quantidade: 0,
        motivo: 'Ligação dos sensores às linhas.',
        status: StatusItem.pendente,
        pendencia: 'Composição dos chicotes a definir.',
      ),
      const ItemConfiguracao(
        componente: Componentes.caboPainel,
        quantidade: 1,
        motivo: 'Ligação ao painel.',
        status: StatusItem.pendente,
        pendencia: 'Comprimento a definir.',
      ),
    ];

    final bloqueada = validacoes.any((v) => v.bloqueia);
    final distribuicao = usaAlternador && !bloqueada
        ? distribuirSaidas(e.linhasPorSecao)
        : null;
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
