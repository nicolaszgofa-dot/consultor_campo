// Casos validados no app de referência (testes A1–A10 e B1–B4).
import 'package:flutter_test/flutter_test.dart';
import 'package:avaliacao_plantio/src/fertilizante/fertilizante_calc.dart';

ParametrosFertilizante parametros(double doseKgHa, int linhas) =>
    ParametrosFertilizante(
      doseKgHa: doseKgHa,
      espacamentoLinhasM: 0.5,
      distanciaColetaM: 10,
      numeroLinhas: linhas,
    );

String f(double v, [int casas = 1]) => v.toStringAsFixed(casas);

List<bool> cores(List<double> gramas, double ideal) => gramas
    .map((g) => FertilizanteCalc.linhaDentroDaTolerancia(g, ideal))
    .toList();

void main() {
  group('ideal por amostra', () {
    test('300 kg/ha → 150 g', () {
      expect(parametros(300, 2).idealPorAmostraG, 150);
    });
    test('250 kg/ha → 125 g', () {
      expect(parametros(250, 3).idealPorAmostraG, 125);
    });
    test('200 kg/ha → 100 g', () {
      expect(parametros(200, 3).idealPorAmostraG, 100);
    });
  });

  test('menos de 2 linhas não gera resultado', () {
    expect(FertilizanteCalc.calcular(parametros(300, 2), [150]), isNull);
  });

  test('A1: amostras iguais → CV 0%, dentro do padrão, dose real 300', () {
    final r = FertilizanteCalc.calcular(parametros(300, 2), [150, 150])!;
    expect(f(r.cvPercentual), '0.0');
    expect(r.status, StatusFertilizante.dentroDoPadrao);
    expect(f(r.doseRealKgHa), '300.0');
  });

  test('A2: desvio amostral, CV 9,4% → atenção', () {
    final r = FertilizanteCalc.calcular(parametros(300, 2), [140, 160])!;
    expect(f(r.mediaG, 2), '150.00');
    expect(f(r.desvioPadraoG, 2), '14.14');
    expect(f(r.cvPercentual), '9.4');
    expect(r.status, StatusFertilizante.atencao);
    expect(cores([140, 160], 150), [false, false]);
  });

  test('A3: CV 20%, cores em relação ao ideal de 150 g', () {
    final r = FertilizanteCalc.calcular(parametros(300, 3), [120, 150, 180])!;
    expect(f(r.desvioPadraoG, 2), '30.00');
    expect(f(r.cvPercentual), '20.0');
    expect(r.status, StatusFertilizante.atencao);
    expect(cores([120, 150, 180], 150), [false, true, false]);
  });

  test('A4: dose desejada muda só as cores, não o CV', () {
    final p = parametros(250, 3);
    final r = FertilizanteCalc.calcular(p, [120, 150, 180])!;
    expect(f(r.cvPercentual), '20.0');
    expect(cores([120, 150, 180], p.idealPorAmostraG), [true, false, false]);
  });

  test('A5: tolerância ±5% com limite incluído', () {
    const gramas = [94.0, 95.0, 96.0, 104.0, 105.0, 106.0];
    expect(cores(gramas, 100), [false, true, true, true, true, false]);
    final r = FertilizanteCalc.calcular(parametros(200, 6), gramas)!;
    expect(f(r.desvioPadraoG, 2), '5.55');
    expect(f(r.cvPercentual), '5.5');
    expect(r.status, StatusFertilizante.dentroDoPadrao);
  });

  group('limite de CV < 7% (A6–A9, B1–B4)', () {
    final casos = <List<double>, (String, StatusFertilizante)>{
      [99, 100, 101]: ('1.0', StatusFertilizante.dentroDoPadrao),
      [97, 100, 103]: ('3.0', StatusFertilizante.dentroDoPadrao),
      [95, 100, 105]: ('5.0', StatusFertilizante.dentroDoPadrao),
      [94, 100, 106]: ('6.0', StatusFertilizante.dentroDoPadrao),
      [93.5, 100, 106.5]: ('6.5', StatusFertilizante.dentroDoPadrao),
      [93.1, 100, 106.9]: ('6.9', StatusFertilizante.dentroDoPadrao),
      [93, 100, 107]: ('7.0', StatusFertilizante.atencao),
      [60, 100, 140]: ('40.0', StatusFertilizante.atencao),
    };
    casos.forEach((gramas, esperado) {
      test('$gramas → CV ${esperado.$1}%', () {
        final r = FertilizanteCalc.calcular(parametros(200, 3), gramas)!;
        expect(f(r.cvPercentual), esperado.$1);
        expect(r.status, esperado.$2);
      });
    });
  });

  test('A10: três amostras iguais → CV 0%, dentro do padrão', () {
    final r = FertilizanteCalc.calcular(parametros(200, 3), [100, 100, 100])!;
    expect(r.cvPercentual, 0);
    expect(r.status, StatusFertilizante.dentroDoPadrao);
  });
}
