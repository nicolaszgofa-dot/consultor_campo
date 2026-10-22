import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:consultor_campo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tela inicial lista os módulos', (tester) async {
    await tester.pumpWidget(const ConsultorCampoApp());

    expect(find.text('Consultor de Campo'), findsOneWidget);
    expect(find.text('Plantabilidade'), findsOneWidget);
    expect(find.text('Fertilizante'), findsOneWidget);
  });

  testWidgets('plantabilidade calcula a partir das leituras', (tester) async {
    await tester.pumpWidget(const ConsultorCampoApp());
    await tester.tap(find.text('Plantabilidade'));
    await tester.pumpAndSettle();
    expect(find.byType(PlantabilidadePage), findsOneWidget);

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), '4');
    await tester.enterText(campos.at(1), '0,5');
    await tester.tap(find.text('Confirmar parâmetros'));
    await tester.pump();
    expect(find.text('Esp. ideal: 25.0 cm'), findsOneWidget);

    for (final leitura in ['10', '35', '75']) {
      await tester.enterText(find.byType(TextField).last, leitura);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
    }
    expect(find.text('60.0%'), findsOneWidget);
    expect(find.text('Duplas: 33.3%'), findsOneWidget);
  });

  testWidgets('fertilizante mostra o ideal por amostra', (tester) async {
    await tester.pumpWidget(const ConsultorCampoApp());
    await tester.tap(find.text('Fertilizante'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), '300');
    await tester.enterText(campos.at(1), '0,5');
    await tester.enterText(campos.at(2), '10');
    await tester.enterText(campos.at(3), '2');
    await tester.tap(find.text('Gerar linhas'));
    await tester.pump();

    expect(find.text('150.00'), findsOneWidget);
    expect(find.text('0 de 2 linhas preenchidas'), findsOneWidget);
  });
}
