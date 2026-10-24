import 'package:flutter/foundation.dart';
import 'package:roi/roi.dart';

import '../ui/formatos.dart';

/// Um campo das premissas: o que perguntar, como levantar no cliente e como
/// apresentar o número.
class CampoRoi {
  final String chave;
  final String rotulo;
  final String unidade;

  /// Como levantar no cliente (coluna da planilha).
  final String dica;

  /// Como apresentar ao cliente (botão "?").
  final String apresentar;

  /// Digitado em % e usado em fração.
  final bool percentual;
  final bool obrigatorio;

  const CampoRoi(
    this.chave,
    this.rotulo,
    this.unidade,
    this.dica,
    this.apresentar, {
    this.percentual = false,
    this.obrigatorio = false,
  });
}

class GrupoRoi {
  final String titulo;
  final List<CampoRoi> campos;

  const GrupoRoi(this.titulo, this.campos);
}

const gruposRoi = [
  GrupoRoi('Fazenda e produção', [
    CampoRoi(
      'area',
      'Área plantada',
      'ha',
      'Área efetivamente plantada na safra',
      'Pergunte a área efetivamente plantada nesta safra, não a área total '
          'da fazenda. Todos os ganhos por hectare são multiplicados por ela, '
          'então é o número que mais pesa no resultado.',
      obrigatorio: true,
    ),
    CampoRoi(
      'linhas',
      'Número de linhas',
      'linhas',
      'Configuração da plantadeira',
      'Linhas da plantadeira que vai receber o retrofit. Serve para mostrar o '
          'investimento por linha, uma base fácil de comparar com outras '
          'propostas.',
    ),
    CampoRoi(
      'prod',
      'Produtividade média',
      'sc/ha',
      'Média real da fazenda',
      'Use a média real da fazenda, não a meta. Com o número do próprio '
          'cliente, o resultado fica mais fácil de defender.',
    ),
    CampoRoi(
      'preco',
      'Preço da commodity',
      'R\$/sc',
      'Preço de referência da negociação',
      'Preço da saca usado na negociação. Se o cliente achar alto, refaça com '
          'um preço menor e mostre que o retorno continua.',
    ),
  ]),
  GrupoRoi('Sementes e sobreposição', [
    CampoRoi(
      'pop',
      'População média',
      'sementes/ha',
      'População média adotada',
      'População de sementes por hectare que o cliente usa hoje. É a base da '
          'economia de semente na sobreposição.',
    ),
    CampoRoi(
      'semente',
      'Preço da semente',
      'R\$/mil sementes',
      'Preço efetivo do tratamento/lote',
      'Preço por mil sementes, já com tratamento. Quanto mais cara a semente, '
          'maior a economia ao evitar plantar duas vezes.',
    ),
    CampoRoi(
      'sob',
      'Sobreposição atual',
      '% da área',
      'Cabeceiras, recortes e manobras',
      'Parte da área plantada duas vezes em cabeceiras, recortes e manobras. '
          'Se o monitor do cliente registra esse dado, use o número dele.',
      percentual: true,
    ),
    CampoRoi(
      'red',
      'Redução esperada',
      '%',
      'Quanto o desligamento linha a linha pode eliminar',
      'Quanto da sobreposição o desligamento linha a linha elimina: cada '
          'linha desliga sozinha ao entrar em área já plantada. Mostre na '
          'cabeceira de um talhão do próprio cliente.',
      percentual: true,
    ),
  ]),
  GrupoRoi('Taxa variável', [
    CampoRoi(
      'zona',
      'Área de menor potencial',
      'ha',
      'Talhões ou zonas onde reduziria a população',
      'Área onde a prescrição agronômica reduz a população. Peça o mapa de '
          'produtividade ou de solo do cliente para chegar a esse número.',
    ),
    CampoRoi(
      'popAtual',
      'População atual na zona',
      'sementes/ha',
      'Taxa atual',
      'Taxa usada hoje nessa área. A diferença para a prescrita é semente que '
          'deixa de ser comprada.',
    ),
    CampoRoi(
      'popPresc',
      'População prescrita',
      'sementes/ha',
      'Taxa recomendada pela prescrição agronômica',
      'Taxa recomendada pela prescrição agronômica. Sem prescrição, deixe '
          'igual à atual: o ganho com taxa variável fica zero.',
    ),
  ]),
  GrupoRoi('Curvas e operação', [
    CampoRoi(
      'curvas',
      'Área afetada por curvas',
      '% da área',
      'Pivôs, contornos e talhões irregulares',
      'Parte da área com pivôs, contornos e talhões irregulares. Nas curvas, '
          'as linhas de dentro e de fora andam em velocidades diferentes e a '
          'distribuição de sementes muda.',
      percentual: true,
    ),
    CampoRoi(
      'perda',
      'Perda sem compensação',
      '% da receita',
      'Usar cenário conservador',
      'Perda de receita nas curvas quando cada linha não ajusta a dosagem à '
          'própria velocidade. Comece pelo valor conservador.',
      percentual: true,
    ),
    CampoRoi(
      'oper',
      'Economia operacional',
      'R\$/safra',
      'Correntes, transmissões, paradas etc.',
      'Gasto com correntes, transmissões e paradas que o acionamento '
          'elétrico elimina. Pergunte ao cliente quanto gastou na última '
          'safra.',
    ),
  ]),
  GrupoRoi('Investimento', [
    CampoRoi(
      'inv',
      'Retrofit J.Assy',
      'R\$',
      'Preço instalado da proposta',
      'Preço instalado da proposta. Apresente junto com o payback, para o '
          'cliente ver o investimento e o retorno lado a lado.',
      obrigatorio: true,
    ),
    CampoRoi(
      'conc',
      'Concorrente',
      'R\$',
      'Preço instalado comparável',
      'Preço instalado de uma solução concorrente. Compare só escopos '
          'equivalentes: mesmas funções e mesma quantidade de linhas.',
    ),
    CampoRoi(
      'nova',
      'Plantadeira nova',
      'R\$',
      'Preço da máquina nova comparável',
      'Preço de uma plantadeira nova equivalente. Mostra quanto capital o '
          'retrofit evita.',
    ),
    CampoRoi(
      'atual',
      'Valor da plantadeira atual',
      'R\$',
      'Valor de venda ou troca',
      'Quanto o cliente receberia vendendo ou dando a máquina atual na '
          'troca. Esse valor sai do custo da plantadeira nova.',
    ),
    CampoRoi(
      'vida',
      'Vida econômica',
      'safras',
      'Período para diluir o investimento',
      'Em quantas safras diluir o investimento. Use um horizonte que o '
          'próprio cliente considere realista.',
      obrigatorio: true,
    ),
  ]),
];

/// Como apresentar os indicadores e gráficos do resultado (botão "?").
abstract final class ApresentarRoi {
  static const cenarios = (
    'Cenários',
    'Conservador: apresentação inicial ou cliente cético. Provável: base da '
        'negociação. Potencial: limite superior, para mostrar a '
        'sensibilidade.',
  );
  static const beneficio = (
    'Benefício por safra',
    'Soma do que o retrofit traz em uma safra. Mostre de onde vem cada parte '
        'no gráfico abaixo, começando pela maior.',
  );
  static const payback = (
    'Payback',
    'Em quantas safras o benefício paga o investimento. Por exemplo, 1,6 '
        'safra quer dizer que o retrofit se paga antes do fim da segunda '
        'safra.',
  );
  static const roi = (
    'ROI anual',
    'Quanto o benefício de uma safra representa sobre o valor investido.',
  );
  static const horizonte = (
    'Benefício no horizonte',
    'Benefício somado em toda a vida econômica. O retorno líquido já '
        'desconta o investimento.',
  );
  static const fontes = (
    'De onde vem o benefício',
    'Plantabilidade: produtividade recuperada com plantio mais uniforme; se '
        'o cliente já fez a avaliação de plantio, use o resultado dela na '
        'conversa. Taxa variável e sobreposição: semente que deixa de ser '
        'comprada. Operação: manutenção evitada. Curvas: perda evitada nas '
        'curvas.',
  );
  static const alternativas = (
    'Investimento por alternativa',
    'Compare quanto o cliente precisa desembolsar em cada caminho. A '
        'plantadeira nova já desconta a venda da máquina atual.',
  );
  static const tabela = (
    'Por linha e por hectare',
    'Coloca as alternativas na mesma base. R\$/ha/ano dilui o investimento na '
        'vida econômica, o jeito mais justo de comparar.',
  );
}

/// Lê números digitados no formato brasileiro, inclusive com ponto de milhar
/// ("300.000", "1.500.000,00").
double? lerValorRoi(String texto) {
  final t = texto.replaceAll('R\$', '').replaceAll(' ', '').trim();
  if (RegExp(r'^\d{1,3}(\.\d{3})+(,\d+)?$').hasMatch(t)) {
    return lerNumero(t.replaceAll('.', '').replaceAll(',', '.'));
  }
  return lerNumero(t);
}

/// Etapas: 0 a 4 são os grupos de premissas, 5 o resultado, 6 o comparativo.
class RoiEstado extends ChangeNotifier {
  static const etapaResultado = 5;
  static const etapaComparativo = 6;
  static const nomesEtapas = [
    'Fazenda e produção',
    'Sementes e sobreposição',
    'Taxa variável',
    'Curvas e operação',
    'Investimento',
    'Resultado',
    'Comparativo',
  ];

  int etapa = 0;
  CenarioRoi cenario = CenarioRoi.provavel;

  /// Texto digitado em cada campo.
  final Map<String, String> valores = {};

  String texto(String chave) => valores[chave] ?? '';

  double _numero(String chave) => lerValorRoi(texto(chave)) ?? 0;

  double _campo(CampoRoi c) =>
      c.percentual ? _numero(c.chave) / 100 : _numero(c.chave);

  PremissasRoi get premissas {
    double v(String chave) => _campo(
      gruposRoi.expand((g) => g.campos).firstWhere((c) => c.chave == chave),
    );
    return PremissasRoi(
      areaHa: v('area'),
      linhas: v('linhas'),
      produtividadeScHa: v('prod'),
      precoSaca: v('preco'),
      populacao: v('pop'),
      precoMilSementes: v('semente'),
      sobreposicao: v('sob'),
      reducaoSobreposicao: v('red'),
      areaZonaHa: v('zona'),
      populacaoAtualZona: v('popAtual'),
      populacaoPrescrita: v('popPresc'),
      areaCurvas: v('curvas'),
      perdaCurvas: v('perda'),
      economiaOperacional: v('oper'),
      investimento: v('inv'),
      concorrente: v('conc'),
      plantadeiraNova: v('nova'),
      valorPlantadeiraAtual: v('atual'),
      vidaSafras: v('vida'),
    );
  }

  ResultadoRoi get resultado => CalculadoraRoi.calcular(premissas);

  /// Erro do campo: valor que não é número, obrigatório vazio ou percentual
  /// fora de 0 a 100.
  String? erro(CampoRoi c) {
    final t = texto(c.chave).trim();
    if (t.isEmpty) return c.obrigatorio ? 'Obrigatório.' : null;
    final v = lerValorRoi(t);
    if (v == null) return 'Número inválido.';
    if (v < 0) return 'Não pode ser negativo.';
    if (c.percentual && v > 100) return 'Entre 0 e 100%.';
    if (c.obrigatorio && v == 0) return 'Precisa ser maior que zero.';
    return null;
  }

  /// Por que não dá para sair da etapa atual. Nulo = pode avançar.
  String? get bloqueio {
    if (etapa > 4) return null;
    for (final c in gruposRoi[etapa].campos) {
      final e = erro(c);
      if (e != null) return '${c.rotulo}: $e';
    }
    return null;
  }

  void mudar(String chave, String texto) {
    valores[chave] = texto;
    notifyListeners();
  }

  void avancar() {
    if (bloqueio != null || etapa >= etapaComparativo) return;
    etapa++;
    notifyListeners();
  }

  void voltar() {
    if (etapa == 0) return;
    etapa--;
    notifyListeners();
  }

  /// Volta para uma etapa já feita.
  void irPara(int e) {
    if (e < 0 || e >= etapa) return;
    etapa = e;
    notifyListeners();
  }

  void escolherCenario(CenarioRoi c) {
    cenario = c;
    notifyListeners();
  }
}
