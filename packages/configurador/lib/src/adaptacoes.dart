import 'regras.dart';

/// Marca e modelo da plantadeira que recebe a adaptação.
class Adaptacao {
  final String marca;
  final String modelo;

  const Adaptacao(this.marca, this.modelo);

  @override
  bool operator ==(Object other) =>
      other is Adaptacao && other.marca == marca && other.modelo == modelo;

  @override
  int get hashCode => Object.hash(marca, modelo);

  @override
  String toString() => '$marca · $modelo';
}

/// Adaptações disponíveis por tecnologia: marca → modelos, em ordem
/// alfabética de marca. Fonte: guias de montagem Titanium e Selenium; no
/// Selenium só entram as opções de acionamento elétrico. Quando o guia não
/// traz modelo, o nome da marca é o modelo.
const adaptacoes = <Tecnologia, Map<String, List<String>>>{
  Tecnologia.titaniumEletric: {
    'AGCO': [
      'Pantográfica condutor quadrado',
      'Pivotada condutor quadrado',
      'Pantográfica condutor redondo',
      'Pivotada condutor redondo',
    ],
    'Baldan': ['Baldan', 'PPS', 'SPA/PLB'],
    'Fankhauser': ['5040/5045 e 5046'],
    'Genius': ['Genius'],
    'Imasa': ['Imasa'],
    'John Deere': ['1100/KF', 'Radial meter'],
    'Jumil': ['Jumil'],
    'KF': ['A partir de 2018'],
    'Kuhn': ['Kuhn'],
    'Planticenter': ['G3', 'G4', 'G5', 'G6'],
    'Semeato': [
      'SMH/SSM',
      'Sol Quadra / Sol Tower',
      'Land Master',
      'PSL',
      'TATU/Semeato/SFIL',
    ],
    'SFIL': ['TATU/Semeato/SFIL'],
    'Stara': ['ST1', 'ST2', 'ST3'],
    'Tatu Marchesan': [
      'USAP (antiga)',
      'USAP S-0120 (nova)',
      'TATU/Semeato/SFIL',
    ],
    'Vence Tudo': ['Vence Tudo'],
  },
  Tecnologia.seleniumEletric: {
    'AGCO': [
      'Pantográfica – Chassi novo (cx. única)',
      'Momentum',
      'Pantográfica – Chassi novo (cx. individual)',
    ],
    'CNH': ['S-2200 Easy Riser', 'S-3200 Easy Riser'],
    'Horsch': ['Maestro Duo 36.50'],
    'Jacto': ['Meridia 200'],
    'John Deere': [
      'S-2100 SN abaixo de 99.999 (linha chapa)',
      'S-2100 SN acima de 100.000 (linha fundido)',
      'S-1100 SN acima de 100.000 (linha fundido)',
      'S-1100 SN abaixo de 99.999 (cx. individual)',
      'S-1100 SN abaixo de 99.999 (cx. suspensa)',
      'S-9200 Vacumeter/Radial meter',
      'S-9200 Vacumeter/Radial meter (cx. individual)',
    ],
    'Jumil': [
      '3090 (a partir de 2009) / 3090 SS / 7090 / 8090 SS (até 2009)',
      '2980 Pantográfica',
      '3070 Chassis entre Setembro/2012 e Março/2015 (cx. individual)',
      '3070/2670 Chassis Março/2017 – Atual (cx. suspensa)',
      '3070/2670 Chassis Março/2017 – Atual (cx. individual)',
      '7090 Chassi 2980 Pantográfica (cx. individual)',
      '7090 Chassi 2980 Pantográfica (cx. suspensa)',
      '2980 Pivotada anterior a 2005 (cx. individual)',
      '2980 Pivotada anterior a 2005 (cx. suspensa)',
      '2640 (cx. suspensa)',
    ],
    'Kuhn': ['PDM/PD Máxima 1200', 'Prime e Prime AT P'],
    'Semeato': [
      'Sol TT – Chassi vermelho',
      'Sol TT – Chassi preto',
      'Sol TT V02 – Ponto de fixação reto',
    ],
    'Stara': ['Princesa', 'Vitória'],
    'Tatu Marchesan': ['Ultraflex', 'COP CE Suprema', 'USAP Chassi S-0120'],
    'Vence Tudo': [
      'Panther',
      'Panther Mecânica para Pneumática',
      'Macanuda Top Fertilizante Série 02',
    ],
  },
};

/// Se [a] existe no catálogo da tecnologia [t].
/// A plantadeira mantém o condutor de sementes dela: não gera item, só um
/// aviso informativo no resultado.
const condutorOriginal = 'Condutor de sementes original';
const _original = condutorOriginal;
const _jd1 = 'Condutor de sementes retrabalhado JD1 - 20000000608';
const _jm1 = 'Condutor de sementes retrabalhado JM1 - 20000000653';
const _jm3 = 'Condutor de sementes retrabalhado JM3 - 30000000002';
const _kh1 = 'Condutor de sementes retrabalhado KH1 - 20000000526';
const _sm4 = 'Condutor de sementes retrabalhado SM4 - 20000000621';
const _vt1 = 'Condutor de sementes retrabalhado VT1 - 20000000654';

/// Condutor de sementes de cada adaptação do Selenium Elétric (marca →
/// modelo → condutor), um por linha.
const condutoresSelenium = <String, Map<String, String>>{
  'AGCO': {
    'Pantográfica – Chassi novo (cx. única)': _original,
    'Momentum': _original,
    'Pantográfica – Chassi novo (cx. individual)': _original,
  },
  'CNH': {'S-2200 Easy Riser': _original, 'S-3200 Easy Riser': _original},
  'Horsch': {'Maestro Duo 36.50': _jd1},
  'Jacto': {'Meridia 200': _original},
  'John Deere': {
    'S-2100 SN abaixo de 99.999 (linha chapa)': _jd1,
    'S-2100 SN acima de 100.000 (linha fundido)': _jd1,
    'S-1100 SN acima de 100.000 (linha fundido)': _original,
    'S-1100 SN abaixo de 99.999 (cx. individual)': _original,
    'S-1100 SN abaixo de 99.999 (cx. suspensa)': _original,
    'S-9200 Vacumeter/Radial meter': _jd1,
    'S-9200 Vacumeter/Radial meter (cx. individual)': _jd1,
  },
  'Jumil': {
    '3090 (a partir de 2009) / 3090 SS / 7090 / 8090 SS (até 2009)': _jm1,
    '2980 Pantográfica': _jm3,
    '3070 Chassis entre Setembro/2012 e Março/2015 (cx. individual)': _original,
    '3070/2670 Chassis Março/2017 – Atual (cx. suspensa)': _original,
    '3070/2670 Chassis Março/2017 – Atual (cx. individual)': _original,
    '7090 Chassi 2980 Pantográfica (cx. individual)': _jm3,
    '7090 Chassi 2980 Pantográfica (cx. suspensa)': _jm3,
    '2980 Pivotada anterior a 2005 (cx. individual)': _original,
    '2980 Pivotada anterior a 2005 (cx. suspensa)': _original,
    '2640 (cx. suspensa)': _original,
  },
  'Kuhn': {'PDM/PD Máxima 1200': _kh1, 'Prime e Prime AT P': _original},
  'Semeato': {
    'Sol TT – Chassi vermelho': _sm4,
    'Sol TT – Chassi preto': _sm4,
    'Sol TT V02 – Ponto de fixação reto': _sm4,
  },
  'Stara': {'Princesa': _original, 'Vitória': _original},
  'Tatu Marchesan': {
    'Ultraflex': _jd1,
    'COP CE Suprema': 'Condutor de sementes retrabalhado - 20000000568',
    'USAP Chassi S-0120': _jd1,
  },
  'Vence Tudo': {
    'Panther': _vt1,
    'Panther Mecânica para Pneumática': _vt1,
    'Macanuda Top Fertilizante Série 02': _vt1,
  },
};

bool adaptacaoValida(Tecnologia t, Adaptacao a) =>
    adaptacoes[t]?[a.marca]?.contains(a.modelo) ?? false;
