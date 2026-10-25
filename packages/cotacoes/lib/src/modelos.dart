/// Grãos com cotação. Novos produtos entram aqui e no feed.
enum Produto {
  soja('Soja'),
  milho('Milho');

  final String nome;

  const Produto(this.nome);

  static Produto? porId(String id) {
    for (final p in values) {
      if (p.name == id) return p;
    }
    return null;
  }
}

/// De onde vem o preço. Só praças e preços informados entram na estimativa:
/// porto, indicador e futuro têm outra base de preço.
enum TipoCotacao {
  praca('praca', 'Praça'),
  porto('porto', 'Porto'),
  indicador('indicador', 'Indicador'),
  futuro('futuro', 'Futuro'),
  conabUf('conab_uf', 'Conab UF'),
  informado('informado', 'Informado');

  final String id;
  final String rotulo;

  const TipoCotacao(this.id, this.rotulo);

  bool get entraNaEstimativa =>
      this == TipoCotacao.praca || this == TipoCotacao.informado;

  /// Referência nacional, sem cidade: mostrada acima do mapa.
  bool get referenciaNacional =>
      this == TipoCotacao.indicador || this == TipoCotacao.futuro;

  static TipoCotacao? porId(String id) {
    for (final t in values) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// Uma cotação no formato único do feed, seja qual for a fonte.
class Cotacao {
  final Produto produto;
  final TipoCotacao tipo;

  /// UF da praça ou do preço estadual. Nula em referência nacional.
  final String? uf;

  /// Cidade da praça (nome igual ao da lista de cidades).
  final String? local;

  /// Quem cotou ou nome da referência (ex.: "Ceres", "Indicador Paraná").
  final String? detalhe;

  /// R$ por saca de 60 kg.
  final double preco;

  /// Variação em % sobre a cotação anterior. Nula quando a fonte não traz.
  final double? variacao;

  /// Dia da cotação; no preço semanal, o último dia da semana.
  final DateTime data;

  /// Primeiro dia da semana, só no preço semanal.
  final DateTime? inicio;

  final String fonte;

  /// Quem informou, só nos preços informados pela equipe.
  final String? informadoPor;

  const Cotacao({
    required this.produto,
    required this.tipo,
    this.uf,
    this.local,
    this.detalhe,
    required this.preco,
    this.variacao,
    required this.data,
    this.inicio,
    required this.fonte,
    this.informadoPor,
  });

  static Cotacao? fromJson(Map<String, dynamic> j) {
    final produto = Produto.porId(j['produto'] as String? ?? '');
    final tipo = TipoCotacao.porId(j['tipo'] as String? ?? '');
    final preco = (j['preco'] as num?)?.toDouble();
    final data = DateTime.tryParse(j['data'] as String? ?? '');
    // Linha que o app não entende (produto novo, por exemplo) fica de fora.
    if (produto == null || tipo == null || preco == null || data == null) {
      return null;
    }
    final inicio = j['inicio'] as String?;
    return Cotacao(
      produto: produto,
      tipo: tipo,
      uf: j['uf'] as String?,
      local: j['local'] as String?,
      detalhe: j['detalhe'] as String?,
      preco: preco,
      variacao: (j['variacao'] as num?)?.toDouble(),
      data: data,
      inicio: inicio == null ? null : DateTime.tryParse(inicio),
      fonte: j['fonte'] as String? ?? '',
      informadoPor: j['informadoPor'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'produto': produto.name,
    'tipo': tipo.id,
    if (uf != null) 'uf': uf,
    if (local != null) 'local': local,
    if (detalhe != null) 'detalhe': detalhe,
    'preco': preco,
    if (variacao != null) 'variacao': variacao,
    'data': _dia(data),
    if (inicio != null) 'inicio': _dia(inicio!),
    'fonte': fonte,
    if (informadoPor != null) 'informadoPor': informadoPor,
  };
}

String _dia(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// O feed inteiro: o que o coletor publica e o app guarda no aparelho.
class FeedCotacoes {
  static const versaoAtual = 1;

  final DateTime geradoEm;
  final List<Cotacao> cotacoes;

  const FeedCotacoes({required this.geradoEm, required this.cotacoes});

  /// Nulo se o texto não for um feed desta versão.
  static FeedCotacoes? fromJson(Map<String, dynamic> j) {
    if (j['versao'] != versaoAtual) return null;
    final gerado = DateTime.tryParse(j['geradoEm'] as String? ?? '');
    final lista = j['cotacoes'];
    if (gerado == null || lista is! List) return null;
    return FeedCotacoes(
      geradoEm: gerado,
      cotacoes: [
        for (final c in lista)
          if (c is Map<String, dynamic>) ?Cotacao.fromJson(c),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'versao': versaoAtual,
    'geradoEm': geradoEm.toIso8601String(),
    'cotacoes': [for (final c in cotacoes) c.toJson()],
  };

  List<Cotacao> doProduto(Produto p) => [
    for (final c in cotacoes)
      if (c.produto == p) c,
  ];
}

const nomesUf = {
  'AC': 'Acre',
  'AL': 'Alagoas',
  'AM': 'Amazonas',
  'AP': 'Amapá',
  'BA': 'Bahia',
  'CE': 'Ceará',
  'DF': 'Distrito Federal',
  'ES': 'Espírito Santo',
  'GO': 'Goiás',
  'MA': 'Maranhão',
  'MG': 'Minas Gerais',
  'MS': 'Mato Grosso do Sul',
  'MT': 'Mato Grosso',
  'PA': 'Pará',
  'PB': 'Paraíba',
  'PE': 'Pernambuco',
  'PI': 'Piauí',
  'PR': 'Paraná',
  'RJ': 'Rio de Janeiro',
  'RN': 'Rio Grande do Norte',
  'RO': 'Rondônia',
  'RR': 'Roraima',
  'RS': 'Rio Grande do Sul',
  'SC': 'Santa Catarina',
  'SE': 'Sergipe',
  'SP': 'São Paulo',
  'TO': 'Tocantins',
};
