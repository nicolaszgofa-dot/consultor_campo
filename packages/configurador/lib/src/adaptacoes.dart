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
    'Vence Tudo': ['Panther', 'Panther Mecânica para Pneumática'],
  },
};

/// Se [a] existe no catálogo da tecnologia [t].
bool adaptacaoValida(Tecnologia t, Adaptacao a) =>
    adaptacoes[t]?[a.marca]?.contains(a.modelo) ?? false;
