// Casos de docs/base-conhecimento/parametros-perda.md e docs/especificacao-calculos.md.
import 'package:flutter_test/flutter_test.dart';
import 'package:avaliacao_plantio/src/perda/perda_calc.dart';
import 'package:avaliacao_plantio/src/plantabilidade/plantabilidade_calc.dart';

const parametros = ParametrosPlantabilidade(
  sementesPorMetro: 4,
  espacamentoLinhasM: 0.5,
);

String f(double v, [int casas = 1]) => v.toStringAsFixed(casas);

ResultadoPerda calcular(
  Cultura cultura,
  List<double> leituras, {
  double produtividade = 3600,
  CoeficientesPerda coeficientes = const CoeficientesPerda(),
}) =>
    PerdaCalc.calcular(
      cultura: cultura,
      parametros: parametros,
      plantabilidade: PlantabilidadeCalc.calcular(parametros, leituras),
      produtividadeEsperadaKgHa: produtividade,
      coeficientes: coeficientes,
    );

void main() {
  group('contagem de plantas', () {
    test('falhas contam as plantas que caberiam no vão; duplas, uma a mais',
        () {
      // Espaçamentos 25, 50 (falha de 1), 25, 10 (dupla), 15, 75 (falha de 2).
      final r = PlantabilidadeCalc.calcular(parametros, [
        25,
        75,
        100,
        110,
        125,
        200,
      ]);
      final c = PerdaCalc.contarPlantas(r.espacamentos, 25);
      expect(c.plantasEsperadas, 8);
      expect(c.plantasFaltando, 3);
      expect(c.plantasAMais, 1);
      expect(c.percentualFaltando, 37.5);
      expect(c.percentualAMais, 12.5);
    });

    test('falha logo acima do limite conta pelo menos uma planta', () {
      final r = PlantabilidadeCalc.calcular(parametros, [37.6]);
      expect(r.espacamentos.single.classe, ClasseEspacamento.falha);
      expect(PerdaCalc.contarPlantas(r.espacamentos, 25).plantasFaltando, 1);
    });

    test('sem leituras não há plantas', () {
      final c = PerdaCalc.contarPlantas(const [], 25);
      expect(c.plantasEsperadas, 0);
      expect(c.percentualFaltando, 0);
    });
  });

  group('soja (Fiss et al., 2018)', () {
    test('exemplo da base de conhecimento: 10,7% faltando, 7,1% a mais', () {
      String p(Cenario c) => f(PerdaCalc.perdaSojaPercentual(10.7, 7.1, c));
      expect(p(Cenario.otimista), '6.2');
      expect(p(Cenario.medio), '9.4');
      expect(p(Cenario.pessimista), '11.9');
    });

    test('calcula a partir das leituras da trena', () {
      final r = calcular(Cultura.soja, [25, 75, 100, 110, 125, 200]);
      expect(f(r.de(Cenario.otimista).percentual, 3), '20.125');
      expect(f(r.de(Cenario.medio).percentual, 3), '30.375');
      expect(f(r.de(Cenario.pessimista).percentual, 3), '38.375');
      expect(f(r.de(Cenario.medio).kgHa), '1093.5');
      expect(f(r.de(Cenario.medio).sacasHa, 2), '18.23');
    });

    test('linha perfeita não tem perda', () {
      final r = calcular(Cultura.soja, [25, 50, 75, 100]);
      for (final c in r.cenarios) {
        expect(c.percentual, 0);
      }
    });

    test('perda é limitada a 100%', () {
      expect(PerdaCalc.perdaSojaPercentual(150, 0, Cenario.pessimista), 100);
    });
  });

  group('milho (Nielsen, Purdue)', () {
    test('exemplo da base de conhecimento: DV 9 cm', () {
      expect(PerdaCalc.perdaMilhoKgHa(9, Cenario.otimista), 120);
      expect(PerdaCalc.perdaMilhoKgHa(9, Cenario.medio), 248);
      expect(PerdaCalc.perdaMilhoKgHa(9, Cenario.pessimista), 336);
    });

    test('DV até a referência de 5 cm não gera perda', () {
      expect(PerdaCalc.perdaMilhoKgHa(5, Cenario.pessimista), 0);
      expect(PerdaCalc.perdaMilhoKgHa(3, Cenario.medio), 0);
    });

    test('calcula a partir das leituras (DV 15 cm)', () {
      final r = calcular(
        Cultura.milho,
        [10, 35, 75],
        produtividade: 10000,
      );
      expect(f(r.desvioPadraoCm, 2), '15.00');
      expect(f(r.de(Cenario.otimista).kgHa), '300.0');
      expect(f(r.de(Cenario.medio).kgHa), '620.0');
      expect(f(r.de(Cenario.pessimista).kgHa), '840.0');
      expect(f(r.de(Cenario.medio).percentual), '6.2');
    });
  });

  group('feijão (Bisognin et al., 2019)', () {
    test('4,4% a cada 10 pontos de CV', () {
      expect(f(PerdaCalc.perdaFeijaoPercentual(10, Cenario.medio)), '4.4');
      expect(f(PerdaCalc.perdaFeijaoPercentual(20, Cenario.medio)), '8.8');
    });

    test('calcula a partir das leituras (CV 28,3%)', () {
      final r = calcular(Cultura.feijao, [20, 50], produtividade: 2000);
      expect(f(r.cvPercentual), '28.3');
      expect(f(r.de(Cenario.medio).percentual, 2), '12.45');
      expect(f(r.de(Cenario.medio).kgHa), '248.9');
    });
  });

  test('coeficientes da empresa substituem os da literatura', () {
    final r = calcular(
      Cultura.milho,
      [10, 35, 75],
      produtividade: 10000,
      coeficientes: const CoeficientesPerda(
        milhoKgHaPorCm: PorCenario.unico(100),
        milhoDvReferenciaCm: 3,
      ),
    );
    expect(f(r.de(Cenario.medio).kgHa), '1200.0');
  });

  test('produtividade esperada precisa ser maior que zero', () {
    expect(
      () => calcular(Cultura.soja, [25, 50], produtividade: 0),
      throwsArgumentError,
    );
  });
}
