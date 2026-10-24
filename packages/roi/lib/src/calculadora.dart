/// Cálculo do ROI do retrofit J.Assy, igual à planilha
/// Calculadora_ROI_Retrofit_JAssy.xlsx (abas Calculadora e Comparativo).
/// Regras e exemplo: docs/roi/especificacao.md.
library;

/// Premissas levantadas com o cliente. Percentuais em fração (3% = 0.03).
class PremissasRoi {
  // Fazenda e produção.
  final double areaHa;
  final double linhas;
  final double produtividadeScHa;
  final double precoSaca;

  // Sementes e sobreposição.
  final double populacao;
  final double precoMilSementes;
  final double sobreposicao;
  final double reducaoSobreposicao;

  // Taxa variável.
  final double areaZonaHa;
  final double populacaoAtualZona;
  final double populacaoPrescrita;

  // Curvas e operação.
  final double areaCurvas;
  final double perdaCurvas;
  final double economiaOperacional;

  // Investimento.
  final double investimento;
  final double concorrente;
  final double plantadeiraNova;
  final double valorPlantadeiraAtual;
  final double vidaSafras;

  const PremissasRoi({
    this.areaHa = 0,
    this.linhas = 0,
    this.produtividadeScHa = 0,
    this.precoSaca = 0,
    this.populacao = 0,
    this.precoMilSementes = 0,
    this.sobreposicao = 0,
    this.reducaoSobreposicao = 0,
    this.areaZonaHa = 0,
    this.populacaoAtualZona = 0,
    this.populacaoPrescrita = 0,
    this.areaCurvas = 0,
    this.perdaCurvas = 0,
    this.economiaOperacional = 0,
    this.investimento = 0,
    this.concorrente = 0,
    this.plantadeiraNova = 0,
    this.valorPlantadeiraAtual = 0,
    this.vidaSafras = 0,
  });
}

/// Recuperação de resultado por melhor plantabilidade.
enum CenarioRoi {
  conservador('Conservador', 0.005, 'Apresentação inicial / cliente cético'),
  provavel('Provável', 0.01, 'Base da negociação'),
  potencial('Potencial', 0.02, 'Limite superior para sensibilidade');

  final String nome;

  /// Fração da receita bruta recuperada.
  final double recuperacao;
  final String usoRecomendado;

  const CenarioRoi(this.nome, this.recuperacao, this.usoRecomendado);
}

/// Benefícios por safra que não dependem do cenário.
class BeneficiosFixos {
  final double sobreposicao;
  final double taxaVariavel;
  final double curvas;
  final double operacao;

  const BeneficiosFixos({
    required this.sobreposicao,
    required this.taxaVariavel,
    required this.curvas,
    required this.operacao,
  });

  double get total => sobreposicao + taxaVariavel + curvas + operacao;
}

class ResultadoCenario {
  final CenarioRoi cenario;
  final double plantabilidade;
  final double beneficioSafra;

  /// Safras para pagar o investimento. Nulo sem benefício.
  final double? payback;

  /// Benefício de uma safra ÷ investimento (como na planilha).
  final double? roiAnual;

  /// Benefício somado na vida econômica.
  final double beneficioHorizonte;

  /// (Benefício no horizonte − investimento) ÷ investimento.
  final double? retornoLiquido;

  const ResultadoCenario({
    required this.cenario,
    required this.plantabilidade,
    required this.beneficioSafra,
    required this.payback,
    required this.roiAnual,
    required this.beneficioHorizonte,
    required this.retornoLiquido,
  });
}

enum Alternativa {
  jassy('Retrofit J.Assy', 'Moderniza a máquina atual'),
  concorrente('Concorrente', 'Comparar escopo e funcionalidades equivalentes'),
  plantadeiraNova(
    'Plantadeira nova',
    'Capital adicional após vender ou trocar a máquina atual',
  );

  final String nome;
  final String observacao;

  const Alternativa(this.nome, this.observacao);
}

class InvestimentoAlternativa {
  final Alternativa alternativa;
  final double investimento;
  final double? porLinha;
  final double? porHa;
  final double? porHaAno;

  /// Investimento − investimento J.Assy.
  final double diferencaJassy;

  const InvestimentoAlternativa({
    required this.alternativa,
    required this.investimento,
    required this.porLinha,
    required this.porHa,
    required this.porHaAno,
    required this.diferencaJassy,
  });
}

class ResultadoRoi {
  final PremissasRoi premissas;
  final BeneficiosFixos fixos;
  final double receitaBruta;
  final Map<CenarioRoi, ResultadoCenario> cenarios;
  final List<InvestimentoAlternativa> alternativas;

  const ResultadoRoi({
    required this.premissas,
    required this.fixos,
    required this.receitaBruta,
    required this.cenarios,
    required this.alternativas,
  });

  InvestimentoAlternativa alternativa(Alternativa a) =>
      alternativas.firstWhere((x) => x.alternativa == a);

  InvestimentoAlternativa get jassy => alternativa(Alternativa.jassy);

  /// Investimento J.Assy − concorrente.
  double get diferencaConcorrente =>
      premissas.investimento - premissas.concorrente;

  double? get diferencaConcorrentePorHa =>
      _div(diferencaConcorrente, premissas.areaHa);

  double? get diferencaConcorrentePorHaAno =>
      _div(diferencaConcorrente, premissas.areaHa * premissas.vidaSafras);

  /// Quanto o retrofit evita de capital frente à plantadeira nova.
  double get capitalEvitado => _max0(
    alternativa(Alternativa.plantadeiraNova).investimento -
        premissas.investimento,
  );
}

double? _div(double a, double b) => b > 0 ? a / b : null;
double _max0(double v) => v < 0 ? 0 : v;

abstract final class CalculadoraRoi {
  /// O que impede o cálculo. Vazio = pode calcular.
  static List<String> validar(PremissasRoi p) => [
    if (p.areaHa <= 0) 'Informe a área plantada.',
    if (p.investimento <= 0) 'Informe o investimento do retrofit J.Assy.',
    if (p.vidaSafras <= 0) 'Informe a vida econômica em safras.',
    for (final (nome, v) in [
      ('Sobreposição atual', p.sobreposicao),
      ('Redução esperada', p.reducaoSobreposicao),
      ('Área afetada por curvas', p.areaCurvas),
      ('Perda sem compensação', p.perdaCurvas),
    ])
      if (v < 0 || v > 1) '$nome precisa estar entre 0 e 100%.',
  ];

  static BeneficiosFixos beneficiosFixos(PremissasRoi p) => BeneficiosFixos(
    sobreposicao:
        p.areaHa *
        p.populacao *
        p.precoMilSementes *
        p.sobreposicao *
        p.reducaoSobreposicao /
        1000,
    taxaVariavel: _max0(
      p.areaZonaHa *
          (p.populacaoAtualZona - p.populacaoPrescrita) *
          p.precoMilSementes /
          1000,
    ),
    curvas:
        p.areaHa *
        p.areaCurvas *
        p.produtividadeScHa *
        p.precoSaca *
        p.perdaCurvas,
    operacao: p.economiaOperacional,
  );

  static ResultadoRoi calcular(PremissasRoi p) {
    final fixos = beneficiosFixos(p);
    final receita = p.areaHa * p.produtividadeScHa * p.precoSaca;
    final inv = p.investimento;

    ResultadoCenario cenario(CenarioRoi c) {
      final plantabilidade = receita * c.recuperacao;
      final beneficio = fixos.total + plantabilidade;
      final horizonte = beneficio * p.vidaSafras;
      return ResultadoCenario(
        cenario: c,
        plantabilidade: plantabilidade,
        beneficioSafra: beneficio,
        payback: _div(inv, beneficio),
        roiAnual: _div(beneficio, inv),
        beneficioHorizonte: horizonte,
        retornoLiquido: _div(horizonte - inv, inv),
      );
    }

    InvestimentoAlternativa alternativa(Alternativa a, double valor) =>
        InvestimentoAlternativa(
          alternativa: a,
          investimento: valor,
          porLinha: _div(valor, p.linhas),
          porHa: _div(valor, p.areaHa),
          porHaAno: _div(valor, p.areaHa * p.vidaSafras),
          diferencaJassy: valor - inv,
        );

    return ResultadoRoi(
      premissas: p,
      fixos: fixos,
      receitaBruta: receita,
      cenarios: {for (final c in CenarioRoi.values) c: cenario(c)},
      alternativas: [
        alternativa(Alternativa.jassy, inv),
        alternativa(Alternativa.concorrente, p.concorrente),
        alternativa(
          Alternativa.plantadeiraNova,
          _max0(p.plantadeiraNova - p.valorPlantadeiraAtual),
        ),
      ],
    );
  }
}
