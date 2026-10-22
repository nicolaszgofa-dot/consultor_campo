// Exemplo do protótipo: soja, 5 linhas de 10 m a 14 sementes/m (700 plantas
// esperadas), 57 plantas faltando e 28 a mais em duplas; 65 sc/ha, saca a
// R$ 125, 500 ha, semente a R$ 380 por saco de 200 mil.
import 'package:avaliacao_plantio/src/perda/perda_calc.dart';
import 'package:avaliacao_plantio/src/perda/prejuizo_calc.dart';
import 'package:flutter_test/flutter_test.dart';

String f(double v, [int casas = 2]) => v.toStringAsFixed(casas);

void main() {
  final perda = PerdaCalc.calcularDeContagem(
    cultura: Cultura.soja,
    contagem: const ContagemPlantas(
      plantasEsperadas: 700,
      plantasFaltando: 57,
      plantasAMais: 28,
    ),
    desvioPadraoCm: 3.3,
    cvPercentual: 44,
    produtividadeEsperadaKgHa: 65 * 60,
  );
  const parametros = ParametrosPrejuizo(
    precoSacaReais: 125,
    areaHa: 500,
    precoSacoSementeReais: 380,
    sementesPorSaco: 200000,
    sementesPorHa: 280000,
  );
  final r = PrejuizoCalc.calcular(perda, parametros);

  test('sementes a mais nas duplas', () {
    expect(r.sementesExtrasHa, 11200);
    expect(f(r.de(Cenario.medio).sementesReaisHa), '21.28');
  });

  test('cenário médio', () {
    final c = r.de(Cenario.medio);
    expect(f(c.perdaSacasHa), '4.46');
    expect(f(c.produtividadeReaisHa), '557.84');
    expect(f(c.totalReaisHa), '579.12');
    expect(f(r.totalSafraReais(Cenario.medio), 0), '289560');
  });

  test('faixa entre os cenários', () {
    expect(f(r.totalSafraReais(Cenario.otimista), 0), '195484');
    expect(f(r.totalSafraReais(Cenario.pessimista), 0), '363787');
  });

  test('sem duplas não há desperdício de sementes', () {
    final semDuplas = PerdaCalc.calcularDeContagem(
      cultura: Cultura.soja,
      contagem: const ContagemPlantas(
        plantasEsperadas: 700,
        plantasFaltando: 57,
        plantasAMais: 0,
      ),
      desvioPadraoCm: 3,
      cvPercentual: 40,
      produtividadeEsperadaKgHa: 3900,
    );
    final p = PrejuizoCalc.calcular(semDuplas, parametros);
    expect(p.de(Cenario.medio).sementesReaisHa, 0);
  });
}
