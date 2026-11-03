/// Guia de seleção de disco do Selenium Neo (soja e milho): qual disco usar
/// para cada população e velocidade de plantio. Fonte: tabelas da J.Assy,
/// válidas só para o dosador Selenium Neo.
library;

enum CulturaNeo {
  soja(
    'Soja',
    baixa: DiscoNeo(
      'Subconjunto disco/anel soja 35 furos Neo 26',
      codigo: '20000002332',
      furos: 35,
    ),
    alta: DiscoNeo(
      'Subconjunto disco/anel soja 70 furos Neo 26',
      codigo: '20000002333',
      furos: 70,
    ),
  ),
  milho(
    'Milho',
    baixa: DiscoNeo(
      'Subconjunto disco/anel milho 14 furos Neo 26',
      codigo: '20000002335',
      furos: 14,
    ),
    alta: DiscoNeo(
      'Subconjunto disco/anel milho 28 furos Neo 26',
      codigo: '20000002340',
      furos: 28,
    ),
  );

  final String nome;

  /// Disco de baixa taxa (baixa velocidade) e de alta taxa (alta velocidade).
  final DiscoNeo baixa;
  final DiscoNeo alta;

  const CulturaNeo(this.nome, {required this.baixa, required this.alta});

  /// Populações das linhas da tabela, em sementes por metro.
  List<double> get populacoes => switch (this) {
    soja => [for (var p = 6.0; p <= 34; p += 2) p],
    milho => [for (var p = 1.0; p <= 8; p += 0.5) p],
  };

  List<String> get _tabela => switch (this) {
    soja => _soja,
    milho => _milho,
  };
}

class DiscoNeo {
  final String nome;
  final String codigo;
  final int furos;

  const DiscoNeo(this.nome, {required this.codigo, required this.furos});

  /// Nome com o código, como entra no resultado.
  String get componente => '$nome ($codigo)';
}

/// Resposta da tabela para uma população e velocidade.
enum IndicacaoDisco {
  /// Só o disco de baixa taxa.
  baixa,

  /// Só o disco de alta taxa.
  alta,

  /// Os dois funcionam; o preferido é o de baixa taxa.
  ambosBaixa,

  /// Os dois funcionam; o preferido é o de alta taxa.
  ambosAlta,

  /// Fora da faixa de operação dos discos.
  fora,
}

class RecomendacaoDisco {
  final CulturaNeo cultura;
  final IndicacaoDisco indicacao;

  /// Linha e coluna usadas na tabela (o valor informado arredondado para
  /// cima, o lado mais exigente). Nulas quando fora da tabela.
  final double? populacaoTabela;
  final int? velocidadeTabela;

  const RecomendacaoDisco(
    this.cultura,
    this.indicacao, {
    this.populacaoTabela,
    this.velocidadeTabela,
  });

  /// Disco que entra no resultado. Nulo quando fora da faixa.
  DiscoNeo? get disco => switch (indicacao) {
    IndicacaoDisco.baixa || IndicacaoDisco.ambosBaixa => cultura.baixa,
    IndicacaoDisco.alta || IndicacaoDisco.ambosAlta => cultura.alta,
    IndicacaoDisco.fora => null,
  };

  bool get osDoisFuncionam =>
      indicacao == IndicacaoDisco.ambosBaixa ||
      indicacao == IndicacaoDisco.ambosAlta;
}

/// Velocidades das colunas, em km/h.
const velocidadesTabelaNeo = [
  2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, //
];

// Uma linha por população, uma letra por velocidade (2 a 20 km/h):
// a = só baixa taxa, A = só alta taxa, b = os dois (prefere baixa),
// B = os dois (prefere alta), - = fora da faixa.
// dart format off
const _soja = [
  'aaaaaaaaaaaaaaabbbb', //  6 sem/m
  'aaaaaaaaaaabbbbbBBB', //  8
  'aaaaaaaaabbbbBBBBAA', // 10
  'aaaaaaabbbBBBBAAAAA', // 12
  'aaaaaabbbBBAAAAAAAA', // 14
  'aaaaabbBBBAAAAAAAAA', // 16
  'aaaabbBBBAAAAAAAAAA', // 18
  'aaaabbBBAAAAAAAAA--', // 20
  'aaabbBBAAAAAAAA----', // 22
  'aaabBBAAAAAAAA-----', // 24
  'aabbBAAAAAAA-------', // 26
  'aabbBAAAAAA--------', // 28
  'aabBBAAAAAA--------', // 30
  'aabBAAAAAA---------', // 32
  'abbBAAAAA----------', // 34
];

const _milho = [
  '----aaaaaaaaaaaaaaa', // 1 sem/m
  '--aaaaaaaaaaabbbbbB', // 1,5
  '-aaaaaaaabbbbBBBBAA', // 2
  '-aaaaaabbbBBBAAAAAA', // 2,5
  'aaaaaabbBBBAAAAAAAA', // 3
  'aaaaabbBBAAAAAAAAAA', // 3,5
  'aaaabbBBAAAAAAAAA--', // 4
  'aaabbBBAAAAAAAA----', // 4,5
  'aaabBBAAAAAAAA-----', // 5
  'aabbBAAAAAAA-------', // 5,5
  'aabBBAAAAAA--------', // 6
  'aabBAAAAAA---------', // 6,5
  'aabBAAAAA----------', // 7
  'abBAAAAAA----------', // 7,5
  'abBAAAAA-----------', // 8
];
// dart format on

/// Disco recomendado para a [cultura] na [populacao] (sementes por metro) e
/// [velocidade] (km/h). Entre duas linhas ou colunas, vale a de cima: mais
/// sementes e mais velocidade pedem mais do disco.
RecomendacaoDisco recomendarDiscoNeo(
  CulturaNeo cultura, {
  required double populacao,
  required double velocidade,
}) {
  final populacoes = cultura.populacoes;
  final linha = populacoes.indexWhere((p) => p >= populacao - 1e-9);
  final coluna = velocidadesTabelaNeo.indexWhere((v) => v >= velocidade - 1e-9);
  if (populacao <= 0 || velocidade <= 0 || linha < 0 || coluna < 0) {
    return RecomendacaoDisco(cultura, IndicacaoDisco.fora);
  }
  final indicacao = switch (cultura._tabela[linha][coluna]) {
    'a' => IndicacaoDisco.baixa,
    'A' => IndicacaoDisco.alta,
    'b' => IndicacaoDisco.ambosBaixa,
    'B' => IndicacaoDisco.ambosAlta,
    _ => IndicacaoDisco.fora,
  };
  return RecomendacaoDisco(
    cultura,
    indicacao,
    populacaoTabela: populacoes[linha],
    velocidadeTabela: velocidadesTabelaNeo[coluna],
  );
}
