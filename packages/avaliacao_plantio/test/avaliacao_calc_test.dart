import 'package:avaliacao_plantio/src/avaliacao/avaliacao_calc.dart';
import 'package:avaliacao_plantio/src/plantabilidade/plantabilidade_calc.dart';
import 'package:flutter_test/flutter_test.dart';

// 4 sementes/m → espaçamento ideal de 25 cm; 10 m = 40 plantas esperadas.
const parametros = ParametrosPlantabilidade(
  sementesPorMetro: 4,
  espacamentoLinhasM: 0.5,
);

List<double> linhaPerfeita([double ate = 1000]) => [
      for (var cm = 25.0; cm <= ate; cm += 25) cm,
    ];

/// Linha de 10 m com [falhas] falhas de uma planta (leituras removidas).
List<double> linhaComFalhas(int falhas) {
  final remover = {for (var i = 1; i <= falhas; i++) i * 100.0};
  return linhaPerfeita().where((cm) => !remover.contains(cm)).toList();
}

void main() {
  test('5 linhas perfeitas de 10 m: amostra completa e 100% no lugar certo',
      () {
    final r = AvaliacaoCalc.calcular(parametros, [
      for (var i = 0; i < 5; i++) linhaPerfeita(),
    ]);
    expect(r.linhasCompletas, 5);
    expect(r.temResultado, isTrue);
    expect(r.amostraPequena, isFalse);
    expect(r.total.plantasEsperadas, 200);
    expect(r.plantas, 200);
    expect(r.percentualNoLugarCerto, 100);
    expect(r.cvPercentual, 0);
    expect(r.linhaComMaisFalhas(), isNull);
  });

  test('linha com menos de 10 m não conta; 4 linhas = amostra pequena', () {
    final r = AvaliacaoCalc.calcular(parametros, [
      for (var i = 0; i < 4; i++) linhaPerfeita(),
      linhaPerfeita(975),
    ]);
    expect(r.linhas.last.completa, isFalse);
    expect(r.linhasCompletas, 4);
    expect(r.temResultado, isTrue);
    expect(r.amostraPequena, isTrue);
  });

  test('sem nenhuma linha de 10 m não há resultado', () {
    final r = AvaliacaoCalc.calcular(parametros, [linhaPerfeita(975)]);
    expect(r.temResultado, isFalse);
  });

  test('falha e dupla numa linha', () {
    // Espaçamentos 25, 50 (falha de 1 planta), 25, 10 (dupla), 15, depois 25.
    final leituras = <double>[
      25,
      75,
      100,
      110,
      125,
      for (var cm = 150.0; cm <= 1000; cm += 25) cm,
    ];
    final linha = AvaliacaoCalc.calcular(parametros, [leituras]).linhas.single;
    expect(linha.completa, isTrue);
    expect(linha.contagem.plantasEsperadas, 40);
    expect(linha.contagem.plantasFaltando, 1);
    expect(linha.contagem.plantasAMais, 1);
    expect(linha.percentualNoLugarCerto, 95);
  });

  test('soma as linhas no total', () {
    final r = AvaliacaoCalc.calcular(parametros, [
      linhaComFalhas(1),
      linhaComFalhas(1),
      linhaComFalhas(1),
      linhaComFalhas(1),
      linhaComFalhas(5),
    ]);
    expect(r.total.plantasEsperadas, 200);
    expect(r.total.plantasFaltando, 9);
    expect(r.percentualNoLugarCerto.toStringAsFixed(1), '95.5');
  });

  test('aponta a linha que concentra as falhas', () {
    final r = AvaliacaoCalc.calcular(parametros, [
      linhaComFalhas(1),
      linhaComFalhas(1),
      linhaComFalhas(1),
      linhaComFalhas(1),
      linhaComFalhas(5),
    ]);
    final pior = r.linhaComMaisFalhas()!;
    expect(pior.indice, 4);
    expect(pior.acimaDaMedia.toStringAsFixed(0), '178');
  });

  test('sem destaque quando as linhas têm falhas parecidas', () {
    final r = AvaliacaoCalc.calcular(parametros, [
      for (var i = 0; i < 5; i++) linhaComFalhas(2),
    ]);
    expect(r.linhaComMaisFalhas(), isNull);
  });
}
