import '../plantabilidade/plantabilidade_calc.dart';

/// Estimativa de perda de produtividade por plantio desuniforme.
///
/// Coeficientes e fontes: docs/base-conhecimento/parametros-perda.md.
/// - Soja: falhas e duplas (Fiss et al., 2018).
/// - Milho: desvio padrão dos espaçamentos (Nielsen, Purdue).
/// - Feijão: CV dos espaçamentos (Bisognin et al., 2019).
enum Cultura { soja, milho, feijao }

enum Cenario { otimista, medio, pessimista }

/// Um valor por cenário.
class PorCenario {
  final double otimista;
  final double medio;
  final double pessimista;

  const PorCenario({
    required this.otimista,
    required this.medio,
    required this.pessimista,
  });

  const PorCenario.unico(double valor)
      : otimista = valor,
        medio = valor,
        pessimista = valor;

  double de(Cenario cenario) => switch (cenario) {
        Cenario.otimista => otimista,
        Cenario.medio => medio,
        Cenario.pessimista => pessimista,
      };
}

/// Coeficientes de perda. Os valores padrão vêm da literatura; uma empresa com
/// ensaios próprios pode substituí-los.
class CoeficientesPerda {
  /// Soja: perda (%) por ponto percentual de plantas faltando em falhas.
  final PorCenario sojaFatorFalhas;

  /// Soja: perda (%) por ponto percentual de plantas a mais em duplas.
  final PorCenario sojaFatorDuplas;

  /// Milho: perda em kg/ha por cm de desvio padrão acima da referência.
  final PorCenario milhoKgHaPorCm;

  /// Milho: desvio padrão alcançável com plantadeira bem regulada (cm).
  final double milhoDvReferenciaCm;

  /// Feijão: perda (%) por ponto de CV dos espaçamentos.
  final PorCenario feijaoPercentualPorPontoCv;

  const CoeficientesPerda({
    this.sojaFatorFalhas = const PorCenario(
      otimista: 0.49,
      medio: 0.74,
      pessimista: 0.93,
    ),
    this.sojaFatorDuplas = const PorCenario(
      otimista: 0.14,
      medio: 0.21,
      pessimista: 0.28,
    ),
    this.milhoKgHaPorCm = const PorCenario(
      otimista: 30,
      medio: 62,
      pessimista: 84,
    ),
    this.milhoDvReferenciaCm = 5,
    this.feijaoPercentualPorPontoCv = const PorCenario.unico(0.44),
  });
}

/// Plantas faltando e a mais na linha medida, em relação ao espaçamento ideal.
class ContagemPlantas {
  final double plantasEsperadas;
  final int plantasFaltando;
  final int plantasAMais;

  const ContagemPlantas({
    required this.plantasEsperadas,
    required this.plantasFaltando,
    required this.plantasAMais,
  });

  double get percentualFaltando =>
      plantasEsperadas == 0 ? 0 : plantasFaltando * 100 / plantasEsperadas;

  double get percentualAMais =>
      plantasEsperadas == 0 ? 0 : plantasAMais * 100 / plantasEsperadas;
}

class PerdaCenario {
  final Cenario cenario;
  final double percentual;
  final double kgHa;

  const PerdaCenario({
    required this.cenario,
    required this.percentual,
    required this.kgHa,
  });

  /// Sacas de 60 kg por hectare.
  double get sacasHa => kgHa / 60;
}

class ResultadoPerda {
  final Cultura cultura;
  final double produtividadeEsperadaKgHa;
  final ContagemPlantas contagem;

  /// Desvio padrão dos espaçamentos (cm) e CV (%) usados no cálculo.
  final double desvioPadraoCm;
  final double cvPercentual;
  final List<PerdaCenario> cenarios;

  const ResultadoPerda({
    required this.cultura,
    required this.produtividadeEsperadaKgHa,
    required this.contagem,
    required this.desvioPadraoCm,
    required this.cvPercentual,
    required this.cenarios,
  });

  PerdaCenario de(Cenario cenario) =>
      cenarios.firstWhere((c) => c.cenario == cenario);
}

class PerdaCalc {
  /// Conta plantas faltando (soma, em cada falha, das plantas que caberiam no
  /// vão) e plantas a mais (uma por dupla) no trecho medido.
  static ContagemPlantas contarPlantas(
    List<Espacamento> espacamentos,
    double idealCm,
  ) {
    if (espacamentos.isEmpty || idealCm <= 0) {
      return const ContagemPlantas(
        plantasEsperadas: 0,
        plantasFaltando: 0,
        plantasAMais: 0,
      );
    }
    final comprimento = espacamentos.fold<double>(0, (s, e) => s + e.valorCm);
    var faltando = 0;
    var aMais = 0;
    for (final e in espacamentos) {
      switch (e.classe) {
        case ClasseEspacamento.falha:
          final vaga = (e.valorCm / idealCm).round() - 1;
          faltando += vaga < 1 ? 1 : vaga;
        case ClasseEspacamento.dupla:
          aMais++;
        case ClasseEspacamento.aceitavel:
          break;
      }
    }
    return ContagemPlantas(
      plantasEsperadas: comprimento / idealCm,
      plantasFaltando: faltando,
      plantasAMais: aMais,
    );
  }

  static double perdaSojaPercentual(
    double percentualFaltando,
    double percentualAMais,
    Cenario cenario, [
    CoeficientesPerda coef = const CoeficientesPerda(),
  ]) =>
      _limitar(
        coef.sojaFatorFalhas.de(cenario) * percentualFaltando +
            coef.sojaFatorDuplas.de(cenario) * percentualAMais,
      );

  static double perdaMilhoKgHa(
    double desvioPadraoCm,
    Cenario cenario, [
    CoeficientesPerda coef = const CoeficientesPerda(),
  ]) {
    final excesso = desvioPadraoCm - coef.milhoDvReferenciaCm;
    return excesso <= 0 ? 0 : coef.milhoKgHaPorCm.de(cenario) * excesso;
  }

  static double perdaFeijaoPercentual(
    double cvPercentual,
    Cenario cenario, [
    CoeficientesPerda coef = const CoeficientesPerda(),
  ]) =>
      _limitar(coef.feijaoPercentualPorPontoCv.de(cenario) * cvPercentual);

  /// Estima a perda nos três cenários a partir de uma avaliação de
  /// plantabilidade. [produtividadeEsperadaKgHa] é o potencial da lavoura.
  static ResultadoPerda calcular({
    required Cultura cultura,
    required ParametrosPlantabilidade parametros,
    required ResultadoPlantabilidade plantabilidade,
    required double produtividadeEsperadaKgHa,
    CoeficientesPerda coeficientes = const CoeficientesPerda(),
  }) =>
      calcularDeContagem(
        cultura: cultura,
        contagem: contarPlantas(
          plantabilidade.espacamentos,
          parametros.espacamentoIdealCm,
        ),
        desvioPadraoCm: plantabilidade.desvioPadraoCm,
        cvPercentual: plantabilidade.cvPercentual,
        produtividadeEsperadaKgHa: produtividadeEsperadaKgHa,
        coeficientes: coeficientes,
      );

  /// Mesma estimativa a partir de valores já agregados (por exemplo, várias
  /// linhas avaliadas somadas).
  static ResultadoPerda calcularDeContagem({
    required Cultura cultura,
    required ContagemPlantas contagem,
    required double desvioPadraoCm,
    required double cvPercentual,
    required double produtividadeEsperadaKgHa,
    CoeficientesPerda coeficientes = const CoeficientesPerda(),
  }) {
    if (produtividadeEsperadaKgHa <= 0) {
      throw ArgumentError.value(
        produtividadeEsperadaKgHa,
        'produtividadeEsperadaKgHa',
        'deve ser maior que zero',
      );
    }
    final dp = desvioPadraoCm;
    final cv = cvPercentual;

    PerdaCenario cenario(Cenario c) {
      final double percentual;
      switch (cultura) {
        case Cultura.soja:
          percentual = perdaSojaPercentual(
            contagem.percentualFaltando,
            contagem.percentualAMais,
            c,
            coeficientes,
          );
        case Cultura.milho:
          percentual = _limitar(
            perdaMilhoKgHa(dp, c, coeficientes) *
                100 /
                produtividadeEsperadaKgHa,
          );
        case Cultura.feijao:
          percentual = perdaFeijaoPercentual(cv, c, coeficientes);
      }
      return PerdaCenario(
        cenario: c,
        percentual: percentual,
        kgHa: percentual * produtividadeEsperadaKgHa / 100,
      );
    }

    return ResultadoPerda(
      cultura: cultura,
      produtividadeEsperadaKgHa: produtividadeEsperadaKgHa,
      contagem: contagem,
      desvioPadraoCm: dp,
      cvPercentual: cv,
      cenarios: [for (final c in Cenario.values) cenario(c)],
    );
  }

  static double _limitar(double percentual) =>
      percentual < 0 ? 0 : (percentual > 100 ? 100 : percentual);
}
