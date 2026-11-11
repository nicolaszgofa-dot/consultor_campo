import 'dart:ui' show Rect;

/// Peça de reposição numa vista explodida.
class Peca {
  final String codigo;
  final String descricao;

  /// Onde o código aparece na imagem, em pixels da imagem original.
  final Rect area;

  const Peca(this.codigo, this.descricao, this.area);
}

/// Conjunto com uma vista explodida e as peças marcadas nela.
class ConjuntoPecas {
  final String titulo;
  final String resumo;
  final String imagem;
  final double largura;
  final double altura;
  final List<Peca> pecas;

  const ConjuntoPecas({
    required this.titulo,
    required this.resumo,
    required this.imagem,
    required this.largura,
    required this.altura,
    required this.pecas,
  });
}

/// Produto do portfólio na tela de peças.
class ProdutoPecas {
  final String nome;
  final String icone;

  /// Vazio enquanto o catálogo do produto não foi cadastrado.
  final List<ConjuntoPecas> conjuntos;

  const ProdutoPecas({
    required this.nome,
    required this.icone,
    this.conjuntos = const [],
  });

  bool get emBreve => conjuntos.isEmpty;
}

/// Uma peça com o produto e o conjunto onde ela aparece (para a busca).
class ResultadoPeca {
  final ProdutoPecas produto;
  final ConjuntoPecas conjunto;
  final Peca peca;

  const ResultadoPeca(this.produto, this.conjunto, this.peca);
}

const _corpoDosador = ConjuntoPecas(
  titulo: 'Corpo do dosador',
  resumo: 'Bocais, entradas de ar, hopper, visor, rosetas e trava do disco',
  imagem: 'assets/pecas/selenium_corpo_dosador.jpg',
  largura: 698,
  altura: 773,
  pecas: [
    Peca(
      '30000000681',
      'Kit bocal de sementes Selenium gravidade',
      Rect.fromLTRB(299, 36, 369, 49),
    ),
    Peca(
      '30000000591',
      'Kit bocal de sementes Selenium gravidade bocal giratório 2,5 pol',
      Rect.fromLTRB(299, 56, 369, 69),
    ),
    Peca(
      '30000000573',
      'Kit bocal de sementes Selenium gravidade bocal giratório 3 pol',
      Rect.fromLTRB(299, 76, 369, 89),
    ),
    Peca(
      '30000000360',
      'Kit bocal de sementes Selenium engate rápido com tela dupla',
      Rect.fromLTRB(299, 96, 369, 109),
    ),
    Peca(
      '30000000638',
      'Kit entrada de ar frontal Selenium',
      Rect.fromLTRB(331, 166, 399, 180),
    ),
    Peca(
      '30000000639',
      'Kit entrada de ar traseira Selenium',
      Rect.fromLTRB(30, 387, 100, 400),
    ),
    Peca(
      '30000000645',
      'Kit hopper gravidade',
      Rect.fromLTRB(29, 454, 99, 467),
    ),
    Peca(
      '30000000485',
      'Kit hopper pressão positiva engate rápido',
      Rect.fromLTRB(29, 467, 99, 480),
    ),
    Peca(
      '30000000640',
      'Kit visor Selenium',
      Rect.fromLTRB(307, 350, 377, 363),
    ),
    Peca(
      '30000000639',
      'Kit Poliflow Selenium',
      Rect.fromLTRB(466, 404, 537, 417),
    ),
    Peca(
      '30000000671',
      'Kit tampa do condutor do corpo do dosador',
      Rect.fromLTRB(320, 580, 390, 593),
    ),
    Peca(
      '30000000642',
      'Kit roseta 28 furos milho Selenium',
      Rect.fromLTRB(99, 580, 169, 593),
    ),
    Peca(
      '30000000643',
      'Kit roseta 40 furos soja e feijão Selenium',
      Rect.fromLTRB(99, 602, 169, 615),
    ),
    Peca(
      '30000000644',
      'Kit roseta 55 furos sorgo e soja Selenium',
      Rect.fromLTRB(98, 624, 170, 637),
    ),
    Peca(
      '30000000374',
      'Kit roseta 80 furos canola Selenium',
      Rect.fromLTRB(99, 648, 169, 661),
    ),
    Peca(
      '30000000375',
      'Kit roseta 32 furos feijão jalo e amendoim Selenium',
      Rect.fromLTRB(99, 671, 169, 684),
    ),
    Peca(
      '30000000376',
      'Kit roseta milho doce e algodão 32 furos Selenium',
      Rect.fromLTRB(98, 694, 169, 707),
    ),
    Peca(
      '30000000641',
      'Kit trava do disco Selenium',
      Rect.fromLTRB(425, 721, 495, 734),
    ),
  ],
);

const _discoCondutores = ConjuntoPecas(
  titulo: 'Disco, condutores e tampa',
  resumo: 'Guarnições, condutores de semente, tampa e entradas de ar',
  imagem: 'assets/pecas/selenium_disco_condutores.png',
  largura: 557,
  altura: 838,
  pecas: [
    Peca(
      '30000000674',
      'Kit guarnição (manta) condutor, bocal alto',
      Rect.fromLTRB(105, 290, 177, 303),
    ),
    Peca(
      '30000000675',
      'Kit guarnição (manta) condutor, bocal baixo',
      Rect.fromLTRB(105, 311, 177, 324),
    ),
    Peca(
      '20000000686',
      'Condutor de semente Selenium',
      Rect.fromLTRB(132, 353, 204, 366),
    ),
    Peca(
      '20000000654',
      'Condutor de semente Selenium retrabalhado VT1',
      Rect.fromLTRB(132, 374, 204, 387),
    ),
    Peca(
      '20000000657',
      'Condutor de semente Selenium retrabalhado JM2 sem furo',
      Rect.fromLTRB(132, 397, 204, 410),
    ),
    Peca(
      '30000000002',
      'Condutor Selenium retrabalhado JM3 (sem furo)',
      Rect.fromLTRB(132, 417, 204, 430),
    ),
    Peca(
      '20000000602',
      'Condutor de semente Selenium retrabalhado VT2',
      Rect.fromLTRB(132, 439, 204, 452),
    ),
    Peca(
      '20000000608',
      'Condutor Selenium retrabalhado JD1 (com furo)',
      Rect.fromLTRB(132, 459, 204, 473),
    ),
    Peca(
      '20000000653',
      'Condutor de semente Selenium retrabalhado JM1',
      Rect.fromLTRB(132, 479, 204, 492),
    ),
    Peca(
      '20000000621',
      'Subconjunto condutor Selenium retrabalhado SM4 com furo',
      Rect.fromLTRB(132, 500, 204, 513),
    ),
    Peca(
      '20000000639',
      'Condutor de semente Selenium retrabalhado',
      Rect.fromLTRB(132, 519, 204, 532),
    ),
    Peca(
      '20000000568',
      'Condutor de semente Selenium retrabalhado com furo',
      Rect.fromLTRB(346, 457, 419, 470),
    ),
    Peca(
      '20000000525',
      'Condutor de semente Selenium retrabalhado KH1',
      Rect.fromLTRB(346, 491, 419, 504),
    ),
    Peca(
      '20000000526',
      'Condutor de semente Selenium retrabalhado KH1 com furo',
      Rect.fromLTRB(346, 517, 419, 530),
    ),
    Peca(
      '10000002025',
      'Subconjunto condutor de amendoim Selenium completo',
      Rect.fromLTRB(346, 558, 419, 571),
    ),
    Peca(
      '30000000004',
      'Condutor Selenium retrabalhado JM3 sem furo',
      Rect.fromLTRB(346, 588, 419, 601),
    ),
    Peca(
      '20000000621',
      'Subconjunto condutor Selenium retrabalhado SM4 sem furo',
      Rect.fromLTRB(346, 622, 419, 635),
    ),
    Peca(
      '30000000631',
      'Kit manopla da tampa Selenium',
      Rect.fromLTRB(252, 586, 325, 599),
    ),
    Peca(
      '30000000542',
      'Kit guarnição de vácuo Selenium V19',
      Rect.fromLTRB(40, 701, 114, 714),
    ),
    Peca(
      '30000000680',
      'Kit tampa do dosador Selenium',
      Rect.fromLTRB(121, 768, 195, 781),
    ),
    Peca(
      '30000000635',
      'Kit bocal de vácuo Selenium',
      Rect.fromLTRB(226, 789, 299, 802),
    ),
    Peca(
      '30000000636',
      'Kit entrada de ar superior Selenium',
      Rect.fromLTRB(395, 784, 469, 797),
    ),
  ],
);

const _motorEletric = ConjuntoPecas(
  titulo: 'Motorização Elétric',
  resumo: 'Motor, suporte, trilho do driver e capa de proteção',
  imagem: 'assets/pecas/selenium_eletric_motor.png',
  largura: 668,
  altura: 423,
  pecas: [
    Peca(
      '30000000617',
      'Kit subconjunto trilho driver Selenium Elétric',
      Rect.fromLTRB(88, 68, 179, 90),
    ),
    Peca(
      '30000000480',
      'Kit suporte motor Doga Selenium Elétric',
      Rect.fromLTRB(369, 82, 462, 105),
    ),
    Peca(
      '30000000615',
      'Kit motor Doga 100 RPM Selenium Elétric',
      Rect.fromLTRB(155, 143, 245, 166),
    ),
    Peca(
      '30000000618',
      'Kit capa de proteção externa do motor',
      Rect.fromLTRB(511, 277, 606, 299),
    ),
  ],
);

// Titanium: página 7 do manual do Titanium (jan.) e página 4 do manual do
// Titanium Elétric (rev. fev/12). Posições tiradas do texto do PDF.
const _dosadorTitanium = ConjuntoPecas(
  titulo: 'Dosador Titanium',
  resumo: 'Limitador, pescoço, visor, base, Poliflow, Escovaflex e antipulo',
  imagem: 'assets/pecas/titanium_dosador.png',
  largura: 803,
  altura: 1006,
  pecas: [
    Peca('30000000661', 'Limitador de peso', Rect.fromLTRB(638, 18, 752, 40)),
    Peca('30000000719', 'Protetor do visor', Rect.fromLTRB(632, 112, 746, 134)),
    Peca('30000000710', 'Pescoço', Rect.fromLTRB(612, 322, 727, 344)),
    Peca('30000000718', 'Visor', Rect.fromLTRB(603, 429, 717, 451)),
    Peca(
      '30000000717',
      'Kit Poliflow com 4 peças (as marcadas com * no desenho)',
      Rect.fromLTRB(111, 477, 226, 499),
    ),
    Peca('30000000715', 'Escovaflex', Rect.fromLTRB(620, 532, 734, 554)),
    Peca('30000000714', 'Trava da base', Rect.fromLTRB(669, 641, 784, 663)),
    Peca('30000000716', 'Antipulo', Rect.fromLTRB(555, 742, 670, 764)),
    Peca(
      '30000000712',
      'Kit adaptador de centro',
      Rect.fromLTRB(528, 816, 642, 838),
    ),
    Peca('30000000709', 'Base Titanium', Rect.fromLTRB(12, 773, 126, 795)),
  ],
);

const _motorTitanium = ConjuntoPecas(
  titulo: 'Motorização Elétric',
  resumo: 'Motor e driver do Titanium Elétric',
  imagem: 'assets/pecas/titanium_eletric_motor.png',
  largura: 803,
  altura: 702,
  pecas: [
    Peca(
      '30000000356',
      'Kit motor Doga 45 RPM cabeado',
      Rect.fromLTRB(33, 498, 202, 529),
    ),
    Peca(
      '30000000543',
      'Kit subconjunto driver Titanium Elétric Ativa',
      Rect.fromLTRB(494, 616, 663, 647),
    ),
  ],
);

/// Produtos na ordem do configurador. Os sem conjuntos aparecem "Em breve".
final produtosPecas = <ProdutoPecas>[
  ProdutoPecas(
    nome: 'Selenium Elétric',
    icone: 'assets/configurador/selenium_eletric.webp',
    conjuntos: [_corpoDosador, _discoCondutores, _motorEletric],
  ),
  ProdutoPecas(
    nome: 'Titanium Elétric',
    icone: 'assets/configurador/titanium_eletric.webp',
    conjuntos: [_dosadorTitanium, _motorTitanium],
  ),
  const ProdutoPecas(
    nome: 'Selenium Neo',
    icone: 'assets/configurador/selenium_neo.png',
  ),
  const ProdutoPecas(nome: 'Júpiter', icone: 'assets/configurador/jupiter.png'),
  const ProdutoPecas(
    nome: 'Commander',
    icone: 'assets/configurador/commander.png',
  ),
  const ProdutoPecas(nome: 'Level', icone: 'assets/configurador/level.png'),
];

/// Remove acentos e caixa para comparar textos digitados no campo.
String normalizar(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const para = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
  final b = StringBuffer();
  for (final c in s.split('')) {
    final i = de.indexOf(c);
    b.write(i >= 0 ? para[i] : c);
  }
  return b.toString().toLowerCase();
}

/// Peças cujo código ou descrição contém todas as palavras digitadas.
List<ResultadoPeca> buscarPecas(String termo, [List<ProdutoPecas>? produtos]) {
  final palavras = normalizar(termo)
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (palavras.isEmpty) return const [];
  return [
    for (final produto in produtos ?? produtosPecas)
      for (final conjunto in produto.conjuntos)
        for (final peca in conjunto.pecas)
          if (palavras.every(
            (p) =>
                peca.codigo.contains(p) ||
                normalizar(peca.descricao).contains(p),
          ))
            ResultadoPeca(produto, conjunto, peca),
  ];
}
