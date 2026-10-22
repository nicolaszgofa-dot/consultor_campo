import 'package:avaliacao_plantio/src/emergencia/emergencia_calc.dart';
import 'package:avaliacao_plantio/src/perda/perda_calc.dart';
import 'package:flutter_test/flutter_test.dart';

final plantio = DateTime(2026, 10, 1);

ParametrosEmergencia parametros(Cultura cultura) => ParametrosEmergencia(
      cultura: cultura,
      dataPlantio: plantio,
      linhas: 5,
      comprimentoLinhaM: 10,
      sementesPorMetro: 2.2,
    );

RegistroEmergencia dia(int dap, List<int> novas) => RegistroEmergencia(
    data: plantio.add(Duration(days: dap)), novasPorLinha: novas);

// Milho: 80 plantas no 5º DAP, 15 no 6º, nada no 7º, 5 no 8º.
final registrosMilho = [
  dia(4, [0, 0, 0, 0, 0]),
  dia(5, [16, 16, 16, 16, 16]),
  dia(6, [3, 3, 3, 3, 3]),
  dia(7, [0, 0, 0, 0, 0]),
  dia(8, [0, 0, 0, 0, 5]),
];

void main() {
  test('dias após o plantio ignoram as horas', () {
    expect(EmergenciaCalc.dap(plantio, DateTime(2026, 10, 6, 23, 59)), 5);
    expect(
        EmergenciaCalc.dap(DateTime(2026, 10, 1, 18), DateTime(2026, 10, 2, 6)),
        1);
  });

  test('dia de emergência conta a partir da primeira planta', () {
    final r =
        EmergenciaCalc.calcular(parametros(Cultura.milho), registrosMilho);
    expect(r.dapPrimeiraEmergencia, 5);
    expect(r.dias.map((d) => d.dap), [5, 6, 8]);
    expect(r.dias.map((d) => d.diaDeEmergencia), [1, 2, 4]);
    expect(r.emergidas, 100);
    expect(r.plantasNoDia(1), 80);
    expect(r.plantasNoDia(2), 15);
    expect(r.plantasNoDia(3), 0);
    expect(r.plantasNoDia(4), 5);
    expect(r.percentualNoDia(1), 80);
  });

  test('emergência em relação às sementes distribuídas', () {
    final r =
        EmergenciaCalc.calcular(parametros(Cultura.milho), registrosMilho);
    // 5 linhas × 10 m × 2,2 sementes/m = 110 esperadas.
    expect(r.parametros.plantasEsperadas, closeTo(110, 1e-9));
    expect(r.percentualEmergencia.toStringAsFixed(1), '90.9');
  });

  test('perda de potencial no milho: 15 plantas a +1 dia, 5 a +3 dias', () {
    final r =
        EmergenciaCalc.calcular(parametros(Cultura.milho), registrosMilho);
    // (15 × 35% + 5 × 85%) ÷ 100 plantas = 9,5%.
    expect(r.perdaPotencialPercentual, closeTo(9.5, 1e-9));
  });

  test('soja ainda sem coeficiente de perda', () {
    final r = EmergenciaCalc.calcular(parametros(Cultura.soja), registrosMilho);
    expect(r.perdaPotencialPercentual, isNull);
    expect(r.percentualNoDia(1), 80);
  });

  test('marcações da mesma data são somadas', () {
    final r = EmergenciaCalc.calcular(parametros(Cultura.milho), [
      dia(5, [10, 0, 0, 0, 0]),
      dia(5, [2, 0, 0, 0, 0]),
    ]);
    expect(r.dias.single.total, 12);
  });

  test('aponta a linha com mais plantas tardias', () {
    final r =
        EmergenciaCalc.calcular(parametros(Cultura.milho), registrosMilho);
    expect(r.percentualDia1NaLinha(0).toStringAsFixed(1), '84.2');
    expect(r.percentualDia1NaLinha(4).toStringAsFixed(1), '66.7');
    expect(r.linhaMaisTardia(), 4);
  });

  test('sem destaque quando as linhas emergem por igual', () {
    final r = EmergenciaCalc.calcular(parametros(Cultura.milho), [
      dia(5, [10, 10, 10, 10, 10]),
      dia(6, [1, 1, 1, 1, 1]),
    ]);
    expect(r.linhaMaisTardia(), isNull);
  });

  test('sem plantas emergidas', () {
    final r = EmergenciaCalc.calcular(parametros(Cultura.milho), [
      dia(3, [0, 0, 0, 0, 0]),
    ]);
    expect(r.emergidas, 0);
    expect(r.dias, isEmpty);
    expect(r.perdaPotencialPercentual, isNull);
  });
}
