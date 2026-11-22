import 'package:consultor_campo/avaliacao/avaliacao_rapida_page.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cálculo (casos de docs/especificacao-calculos.md, 4 sementes/m)', () {
    test('P1: tudo aceitável, CV 0', () {
      final r = ResultadoRapido.calcular([
        25,
        50,
        75,
        100,
      ], sementesPorMetro: 4);
      expect(r.aceitaveis, 100);
      expect(r.cvPercentual, closeTo(0, 1e-9));
    });

    test('P3: duplas 40%, CV 2,9%', () {
      final r = ResultadoRapido.calcular([
        12,
        24.4,
        36.9,
        49.5,
        62.5,
      ], sementesPorMetro: 4);
      expect(r.duplas, closeTo(40, 1e-9));
      expect(r.cvPercentual, closeTo(2.9, 0.05));
    });

    test('P6: um terço de cada classe, CV 60%', () {
      final r = ResultadoRapido.calcular([10, 35, 75], sementesPorMetro: 4);
      expect(r.aceitaveis, closeTo(33.33, 0.01));
      expect(r.falhas, closeTo(33.33, 0.01));
      expect(r.duplas, closeTo(33.33, 0.01));
      expect(r.cvPercentual, closeTo(60, 0.01));
    });

    test('sem sementes por metro: só o CV', () {
      final r = ResultadoRapido.calcular([10, 35, 75]);
      expect(r.cvPercentual, closeTo(60, 0.01));
      expect(r.aceitaveis, isNull);
      expect(r.classificados, isNull);
    });

    test('sem leituras não mostra porcentagens', () {
      final r = ResultadoRapido.calcular([], sementesPorMetro: 4);
      expect(r.aceitaveis, isNull);
      expect(r.cvPercentual, isNull);
    });

    test('uma leitura não tem CV', () {
      final r = ResultadoRapido.calcular([25], sementesPorMetro: 4);
      expect(r.n, 1);
      expect(r.cvPercentual, isNull);
    });
  });

  testWidgets('digita as leituras e vê CV e as classes na hora', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: temaConsultor(), home: const AvaliacaoRapidaPage()),
    );

    final leitura = find.widgetWithText(TextField, 'Leitura da trena (cm)');
    Future<void> adicionar(String v) async {
      await tester.enterText(leitura, v);
      await tester.tap(find.text('Adicionar'));
      await tester.pump();
    }

    await adicionar('10');
    expect(find.textContaining('informe ao menos 2 leituras'), findsOneWidget);
    await adicionar('35');
    await adicionar('75');
    expect(find.text('60,0%'), findsOneWidget);

    // Leitura menor que a anterior é recusada.
    await adicionar('50');
    expect(find.text('A leitura deve ser maior que 75,0 cm.'), findsOneWidget);

    // Com as sementes por metro, aparecem as classes.
    await tester.enterText(
      find.widgetWithText(TextField, 'Sementes por metro'),
      '4',
    );
    await tester.pump();
    expect(find.text('Espaçamento ideal: 25,0 cm'), findsOneWidget);
    expect(find.text('33%'), findsNWidgets(3));

    await tester.ensureVisible(find.text('Remover última leitura'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover última leitura'));
    await tester.pump();
    expect(find.textContaining('2 espaçamentos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
