// Casos validados no app de referência (testes P1–P6).
// Parâmetros comuns: 4 sementes/m, espaçamento 0,50 m.
import 'package:flutter_test/flutter_test.dart';
import 'package:avaliacao_plantio/src/plantabilidade/plantabilidade_calc.dart';

const parametros = ParametrosPlantabilidade(
  sementesPorMetro: 4,
  espacamentoLinhasM: 0.5,
);

String f(double v, [int casas = 1]) => v.toStringAsFixed(casas);

void main() {
  test('parâmetros derivados', () {
    expect(parametros.espacamentoIdealCm, 25.0);
    expect(parametros.metrosLinearesPorHa, 20000);
    expect(parametros.populacaoPorHa, 80000);
  });

  test('P1: espaçamentos perfeitos', () {
    final r = PlantabilidadeCalc.calcular(parametros, [25, 50, 75, 100]);
    expect(r.espacamentos.map((e) => e.valorCm), [25, 25, 25, 25]);
    expect(r.percentualAceitaveis, 100);
    expect(f(r.mediaCm, 2), '25.00');
    expect(f(r.cvPercentual), '0.0');
  });

  test('P2: referência vem das sementes/m informadas, não da média', () {
    final r = PlantabilidadeCalc.calcular(parametros, [40, 80, 120, 160]);
    expect(r.percentualFalhas, 100);
    expect(r.percentualAceitaveis, 0);
    expect(f(r.mediaCm, 2), '40.00');
    expect(f(r.desvioPadraoCm, 2), '0.00');
    expect(r.populacaoPorHa, 80000);
  });

  test('P3: limite de dupla (< 12,5 cm), 12,5 é aceitável', () {
    final r = PlantabilidadeCalc.calcular(parametros, [
      12,
      24.4,
      36.9,
      49.5,
      62.5,
    ]);
    expect(r.espacamentos.map((e) => e.valorCm), [12, 12.4, 12.5, 12.6, 13]);
    expect(r.espacamentos.map((e) => e.classe), [
      ClasseEspacamento.dupla,
      ClasseEspacamento.dupla,
      ClasseEspacamento.aceitavel,
      ClasseEspacamento.aceitavel,
      ClasseEspacamento.aceitavel,
    ]);
    expect(f(r.percentualDuplas), '40.0');
    expect(f(r.percentualAceitaveis), '60.0');
    expect(f(r.mediaCm, 2), '12.50');
    expect(f(r.desvioPadraoCm, 2), '0.36');
    expect(f(r.cvPercentual), '2.9');
  });

  test('P4: limite de falha (> 37,5 cm), 37,5 é aceitável', () {
    final r = PlantabilidadeCalc.calcular(parametros, [
      37,
      74.4,
      111.9,
      149.5,
      187.5,
    ]);
    expect(r.espacamentos.map((e) => e.valorCm), [37, 37.4, 37.5, 37.6, 38]);
    expect(r.espacamentos.map((e) => e.classe), [
      ClasseEspacamento.aceitavel,
      ClasseEspacamento.aceitavel,
      ClasseEspacamento.aceitavel,
      ClasseEspacamento.falha,
      ClasseEspacamento.falha,
    ]);
    expect(f(r.percentualFalhas), '40.0');
    expect(f(r.mediaCm, 2), '37.50');
    expect(f(r.desvioPadraoCm, 2), '0.36');
    expect(f(r.cvPercentual), '1.0');
  });

  test('P5: desvio padrão amostral (n − 1)', () {
    final r = PlantabilidadeCalc.calcular(parametros, [20, 50]);
    expect(r.percentualAceitaveis, 100);
    expect(f(r.mediaCm, 2), '25.00');
    expect(f(r.desvioPadraoCm, 2), '7.07');
    expect(f(r.cvPercentual), '28.3');
  });

  test('P6: uma de cada classe', () {
    final r = PlantabilidadeCalc.calcular(parametros, [10, 35, 75]);
    expect(r.espacamentos.map((e) => e.classe), [
      ClasseEspacamento.dupla,
      ClasseEspacamento.aceitavel,
      ClasseEspacamento.falha,
    ]);
    expect(f(r.percentualAceitaveis), '33.3');
    expect(f(r.percentualDuplas), '33.3');
    expect(f(r.percentualFalhas), '33.3');
    expect(f(r.desvioPadraoCm, 2), '15.00');
    expect(f(r.cvPercentual), '60.0');
  });

  test('aviso de espaçamento digitado em centímetros', () {
    expect(PlantabilidadeCalc.pareceCentimetros(0.5), isFalse);
    expect(PlantabilidadeCalc.pareceCentimetros(50), isTrue);
  });
}
