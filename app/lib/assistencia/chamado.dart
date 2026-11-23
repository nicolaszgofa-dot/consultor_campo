/// Chamado de assistência ou garantia aberto pela revenda. Fica só na
/// memória: vira texto para enviar à J.Assy (não há servidor ainda).
library;

enum TipoChamado {
  assistencia('Assistência técnica'),
  garantia('Garantia');

  final String nome;

  const TipoChamado(this.nome);
}

/// Produtos do portfólio que podem ter chamado.
const produtosChamado = [
  'Titanium (mecânico)',
  'Titanium Elétric',
  'Selenium Elétric',
  'Selenium Neo',
  'Júpiter',
  'Level',
  'Commander',
  'Outro',
];

class Chamado {
  final TipoChamado tipo;
  final String revenda;
  final String contato;
  final String cliente;
  final String cidade;
  final String produto;
  final String plantadeira;
  final String numeroSerie;
  final String instalacao;
  final String linhas;
  final String problema;
  final String jaFeito;

  const Chamado({
    required this.tipo,
    required this.revenda,
    required this.contato,
    required this.cliente,
    required this.cidade,
    required this.produto,
    required this.problema,
    this.plantadeira = '',
    this.numeroSerie = '',
    this.instalacao = '',
    this.linhas = '',
    this.jaFeito = '',
  });

  /// O que falta para o chamado poder ser enviado.
  List<String> get faltando => [
    if (revenda.trim().isEmpty) 'revenda',
    if (contato.trim().isEmpty) 'contato',
    if (cliente.trim().isEmpty) 'cliente',
    if (produto.trim().isEmpty) 'produto',
    if (problema.trim().isEmpty) 'problema',
  ];

  bool get completo => faltando.isEmpty;

  /// Texto para colar no WhatsApp ou no e-mail do pós-venda.
  String comoTexto() {
    final b = StringBuffer('Chamado de ${tipo.nome.toLowerCase()} J.Assy\n\n');
    void linha(String rotulo, String valor) {
      if (valor.trim().isNotEmpty) b.write('$rotulo: ${valor.trim()}\n');
    }

    linha('Revenda', revenda);
    linha('Contato', contato);
    b.write('\n');
    linha('Cliente', cliente);
    linha('Cidade', cidade);
    linha('Produto', produto);
    linha('Plantadeira', plantadeira);
    linha('Nº de série / lote', numeroSerie);
    linha('Instalação', instalacao);
    linha('Linhas com problema', linhas);
    b.write('\nProblema:\n${problema.trim()}\n');
    if (jaFeito.trim().isNotEmpty) {
      b.write('\nO que já foi feito:\n${jaFeito.trim()}\n');
    }
    b.write('\nFotos e vídeos seguem nesta conversa.');
    return b.toString();
  }
}
