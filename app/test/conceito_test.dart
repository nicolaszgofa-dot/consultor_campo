import 'package:consultor_campo/conceito/conceito_page.dart';
import 'package:consultor_campo/conceito/conceitos.dart';
import 'package:consultor_campo/main.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void tela(WidgetTester tester, Size tamanho) {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  test('oito conceitos, todos com conteúdo', () {
    expect(conceitos.map((c) => c.titulo), [
      'Plantabilidade',
      'Estande de plantas',
      'Duplas e falhas',
      'Coeficiente de variação',
      'Singularização',
      'Perdas por plantio desuniforme',
      'Emergência uniforme',
      'Downforce',
    ]);
    for (final c in conceitos) {
      expect(c.blocos, isNotEmpty, reason: c.titulo);
      expect(
        c.blocos.whereType<Nota>(),
        isNotEmpty,
        reason: '${c.titulo}: fonte',
      );
    }
  });

  testWidgets('o menu abre o Conceito, que não está mais em breve', (
    tester,
  ) async {
    tela(tester, const Size(800, 2600));
    await tester.pumpWidget(const ConsultorCampoApp());
    expect(find.text('EM BREVE'), findsNWidgets(3));
    await tester.tap(find.text('Conceito'));
    await tester.pumpAndSettle();
    expect(find.byType(ConceitoPage), findsOneWidget);
    for (final c in conceitos) {
      expect(find.text(c.titulo), findsOneWidget, reason: c.titulo);
    }
  });

  for (final tamanho in const [Size(1194, 834), Size(390, 844)]) {
    testWidgets('todos os conceitos abrem sem erro em $tamanho', (
      tester,
    ) async {
      tela(tester, tamanho);
      for (final c in conceitos) {
        await tester.pumpWidget(
          MaterialApp(
            theme: temaConsultor(),
            home: ConceitoDetalhePage(conceito: c),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(c.titulo), findsWidgets, reason: c.titulo);
        expect(tester.takeException(), isNull, reason: c.titulo);
      }
    });
  }

  testWidgets('downforce mostra a fórmula do conceito J.Assy', (tester) async {
    tela(tester, const Size(1194, 1600));
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: ConceitoDetalhePage(
          conceito: conceitos.firstWhere((c) => c.titulo == 'Downforce'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Downforce = força aplicada + peso da linha − resistência do solo',
      ),
      findsOneWidget,
    );
    expect(find.text('Level (J.Assy)'), findsOneWidget);
  });
}
