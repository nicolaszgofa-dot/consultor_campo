import '../estatistica.dart';
import '../perda/perda_calc.dart';
import '../plantabilidade/plantabilidade_calc.dart';

/// Regras da avaliação com trena. Com pelo menos 1 linha completa o
/// resultado sai; abaixo de [linhasRecomendadas] ele vem com aviso de
/// amostra pequena.
class RegrasAvaliacao {
  static const int linhasRecomendadas = 5;
  static const double comprimentoMinimoCm = 1000;
}

/// Uma linha medida com trena.
class LinhaAvaliada {
  final List<double> leiturasCm;
  final ResultadoPlantabilidade resultado;
  final ContagemPlantas contagem;

  const LinhaAvaliada({
    required this.leiturasCm,
    required this.resultado,
    required this.contagem,
  });

  double get comprimentoCm => leiturasCm.isEmpty ? 0 : leiturasCm.last;

  bool get completa =>
      comprimentoCm >= RegrasAvaliacao.comprimentoMinimoCm - epsilon;

  int get plantas => leiturasCm.length;

  double get percentualNoLugarCerto => _noLugarCerto(contagem);
}

/// Todas as linhas de uma avaliação somadas.
class ResultadoAvaliacao {
  final List<LinhaAvaliada> linhas;
  final ContagemPlantas total;
  final double mediaCm;
  final double desvioPadraoCm;
  final double cvPercentual;

  const ResultadoAvaliacao({
    required this.linhas,
    required this.total,
    required this.mediaCm,
    required this.desvioPadraoCm,
    required this.cvPercentual,
  });

  int get linhasCompletas => linhas.where((l) => l.completa).length;

  /// Já dá para ver o resultado: pelo menos 1 linha de 10 m.
  bool get temResultado => linhasCompletas >= 1;

  /// Menos linhas que o recomendado: resultado pouco confiável.
  bool get amostraPequena =>
      linhasCompletas < RegrasAvaliacao.linhasRecomendadas;

  int get plantas => linhas.fold(0, (s, l) => s + l.plantas);

  double get percentualNoLugarCerto => _noLugarCerto(total);

  /// Linha com mais plantas faltando, quando ela passa da média em [margem]
  /// (0,3 = 30% acima). Nulo quando nenhuma se destaca.
  ({int indice, double acimaDaMedia})? linhaComMaisFalhas({
    double margem = 0.3,
  }) {
    final medidas = linhas.where((l) => l.plantas > 0).toList();
    if (medidas.length < 2) return null;
    final media =
        medidas.fold<int>(0, (s, l) => s + l.contagem.plantasFaltando) /
            medidas.length;
    if (media == 0) return null;
    var pior = 0;
    for (var i = 1; i < linhas.length; i++) {
      if (linhas[i].contagem.plantasFaltando >
          linhas[pior].contagem.plantasFaltando) {
        pior = i;
      }
    }
    final acima = linhas[pior].contagem.plantasFaltando / media - 1;
    return acima >= margem ? (indice: pior, acimaDaMedia: acima * 100) : null;
  }
}

double _noLugarCerto(ContagemPlantas c) {
  if (c.plantasEsperadas == 0) return 0;
  final p =
      100 - (c.plantasFaltando + c.plantasAMais) * 100 / c.plantasEsperadas;
  return p < 0 ? 0 : p;
}

class AvaliacaoCalc {
  /// Calcula cada linha e o total. [leiturasPorLinha] são as leituras
  /// acumuladas da trena de cada linha, em cm.
  static ResultadoAvaliacao calcular(
    ParametrosPlantabilidade parametros,
    List<List<double>> leiturasPorLinha,
  ) {
    final ideal = parametros.espacamentoIdealCm;
    final linhas = [
      for (final leituras in leiturasPorLinha)
        () {
          final r = PlantabilidadeCalc.calcular(parametros, leituras);
          return LinhaAvaliada(
            leiturasCm: List.unmodifiable(leituras),
            resultado: r,
            contagem: PerdaCalc.contarPlantas(r.espacamentos, ideal),
          );
        }(),
    ];

    var esperadas = 0.0;
    var faltando = 0;
    var aMais = 0;
    final todos = <double>[];
    for (final l in linhas) {
      esperadas += l.contagem.plantasEsperadas;
      faltando += l.contagem.plantasFaltando;
      aMais += l.contagem.plantasAMais;
      todos.addAll(l.resultado.espacamentos.map((e) => e.valorCm));
    }
    final m = media(todos);
    final dp = desvioPadraoAmostral(todos);

    return ResultadoAvaliacao(
      linhas: linhas,
      total: ContagemPlantas(
        plantasEsperadas: esperadas,
        plantasFaltando: faltando,
        plantasAMais: aMais,
      ),
      mediaCm: m,
      desvioPadraoCm: dp,
      cvPercentual: coeficienteVariacao(dp, m),
    );
  }
}
