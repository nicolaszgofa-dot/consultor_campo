/// Contas da proposta comercial que sai junto com o ROI: valor por extenso e
/// divisão do total em parcelas. Regras: docs/roi/proposta.md.
library;

const _unidades = [
  '',
  'um',
  'dois',
  'três',
  'quatro',
  'cinco',
  'seis',
  'sete',
  'oito',
  'nove',
  'dez',
  'onze',
  'doze',
  'treze',
  'quatorze',
  'quinze',
  'dezesseis',
  'dezessete',
  'dezoito',
  'dezenove',
];
const _dezenas = [
  '',
  '',
  'vinte',
  'trinta',
  'quarenta',
  'cinquenta',
  'sessenta',
  'setenta',
  'oitenta',
  'noventa',
];
const _centenas = [
  '',
  'cento',
  'duzentos',
  'trezentos',
  'quatrocentos',
  'quinhentos',
  'seiscentos',
  'setecentos',
  'oitocentos',
  'novecentos',
];

/// 1 a 999 por extenso.
String _ate999(int n) {
  if (n == 100) return 'cem';
  final partes = <String>[];
  final c = n ~/ 100, r = n % 100;
  if (c > 0) partes.add(_centenas[c]);
  if (r > 0 && r < 20) partes.add(_unidades[r]);
  if (r >= 20) {
    final u = r % 10;
    partes.add(_dezenas[r ~/ 10] + (u > 0 ? ' e ${_unidades[u]}' : ''));
  }
  return partes.join(' e ');
}

/// Valor em reais por extenso, com inicial maiúscula, como nas propostas
/// ("Cento e dez mil e quinhentos reais").
String valorPorExtenso(double valor) {
  final centavosTotais = (valor * 100).round();
  final reais = centavosTotais ~/ 100;
  final centavos = centavosTotais % 100;

  final grupos = [
    (reais ~/ 1000000000 % 1000, 'bilhão', 'bilhões'),
    (reais ~/ 1000000 % 1000, 'milhão', 'milhões'),
    (reais ~/ 1000 % 1000, 'mil', 'mil'),
    (reais % 1000, '', ''),
  ].where((g) => g.$1 > 0).toList();

  final ditos = [
    for (final (n, um, varios) in grupos)
      if (um == 'mil' && n == 1)
        'mil'
      else
        '${_ate999(n)}${um.isEmpty ? '' : ' ${n == 1 ? um : varios}'}',
  ];

  var texto = '';
  if (ditos.isNotEmpty) {
    // O último grupo leva "e" quando é menor que 100 ou centena redonda
    // ("mil e quinhentos", "mil e vinte"); senão, só espaço ("mil cento e dez").
    final ultimo = reais % 1000;
    final liga = ditos.length > 1 && (ultimo < 100 || ultimo % 100 == 0)
        ? ' e '
        : ' ';
    texto = ditos.length == 1
        ? ditos.first
        : '${ditos.sublist(0, ditos.length - 1).join(', ')}$liga${ditos.last}';
    if (reais % 1000000 == 0) texto += ' de';
    texto += reais == 1 ? ' real' : ' reais';
  }
  if (centavos > 0) {
    final c = '${_ate999(centavos)} ${centavos == 1 ? 'centavo' : 'centavos'}';
    texto = texto.isEmpty ? c : '$texto e $c';
  }
  if (texto.isEmpty) texto = 'zero real';
  return texto[0].toUpperCase() + texto.substring(1);
}

/// Divide o total pelas frações (0,2 = 20%), em centavos. A diferença do
/// arredondamento fica na última parcela, para a soma bater com o total.
List<double> dividirEmParcelas(double total, List<double> fracoes) {
  if (fracoes.isEmpty) return [];
  final centavos = (total * 100).round();
  final partes = [for (final f in fracoes) (centavos * f).round()];
  partes[partes.length - 1] += centavos - partes.fold(0, (a, b) => a + b);
  return [for (final p in partes) p / 100];
}
