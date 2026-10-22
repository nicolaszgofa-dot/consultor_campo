import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:consultor_campo/avaliacao/avaliacao_hub_page.dart';
import 'package:consultor_campo/emergencia/avaliacao_emergencia.dart';
import 'package:consultor_campo/emergencia/emergencia_page.dart';
import 'package:consultor_campo/tema.dart';
import 'package:consultor_campo/ui/formatos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void telaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

DateTime hojeMenos(int dias) {
  final h = DateTime.now();
  return DateTime(h.year, h.month, h.day - dias);
}

Future<void> abrirHub(WidgetTester tester, {int aba = 0}) => tester.pumpWidget(
  MaterialApp(
    theme: temaConsultor(),
    home: AvaliacaoHubPage(abaInicial: aba),
  ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('modelo', () {
    final a = AvaliacaoEmergencia(
      id: '1',
      talhao: 'T-01',
      cultura: Cultura.milho,
      dataPlantio: DateTime(2026, 10, 1),
      sementesPorMetro: 2.2,
      linhas: 2,
      comprimentoLinhaM: 10,
    );

    test('marcação na mesma data substitui a anterior', () {
      final b = a
          .comRegistro(
            RegistroEmergencia(
              data: DateTime(2026, 10, 6),
              novasPorLinha: [3, 3],
            ),
          )
          .comRegistro(
            RegistroEmergencia(
              data: DateTime(2026, 10, 6),
              novasPorLinha: [4, 4],
            ),
          );
      expect(b.registros, hasLength(1));
      expect(b.registros.single.total, 8);
    });

    test('ida e volta em JSON', () {
      final b = a.comRegistro(
        RegistroEmergencia(data: DateTime(2026, 10, 6), novasPorLinha: [3, 1]),
      );
      final c = AvaliacaoEmergencia.fromJson(b.toJson());
      expect(c.talhao, 'T-01');
      expect(c.cultura, Cultura.milho);
      expect(c.dataPlantio, DateTime(2026, 10, 1));
      expect(c.registros.single.novasPorLinha, [3, 1]);
    });

    test('datas digitadas', () {
      expect(lerData('06/10/2026'), DateTime(2026, 10, 6));
      expect(lerData('31/02/2026'), isNull);
      expect(lerData('6-10-2026'), isNull);
      expect(dataBr(DateTime(2026, 1, 5)), '05/01/2026');
    });
  });

  testWidgets('avaliação com três abas', (tester) async {
    telaAlta(tester);
    await abrirHub(tester);
    expect(find.text('Plantio'), findsOneWidget);
    expect(find.text('Fertilizante'), findsOneWidget);
    expect(find.text('Emergência'), findsOneWidget);
    expect(find.text('Nova avaliação de plantio'), findsOneWidget);

    await tester.tap(find.text('Emergência'));
    await tester.pumpAndSettle();
    expect(find.text('Emergência dia após dia'), findsOneWidget);
    expect(find.text('Nova avaliação de emergência'), findsOneWidget);
  });

  testWidgets('emergência marcada em dois dias', (tester) async {
    telaAlta(tester);
    await abrirHub(tester, aba: 2);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova avaliação de emergência'));
    await tester.pumpAndSettle();

    Future<void> preencher(String rotulo, String valor) =>
        tester.enterText(find.widgetWithText(TextFormField, rotulo), valor);
    await preencher('Talhão', 'T-01');
    await preencher('Data do plantio', dataBr(hojeMenos(7)));
    await preencher('Sementes/m', '2,2');
    await preencher('Linhas', '2');
    await tester.tap(find.text('Começar marcação'));
    await tester.pumpAndSettle();
    expect(find.byType(EmergenciaPage), findsOneWidget);
    expect(find.text('7 DAP'), findsOneWidget);

    // Ontem (6 DAP): 4 plantas na linha 1.
    final data = find.widgetWithText(TextField, 'Data');
    await tester.enterText(data, dataBr(hojeMenos(1)));
    await tester.pump();
    expect(find.text('6 DAP'), findsOneWidget);
    expect(find.text('Dia 1'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();
    }
    await tester.tap(find.text('Salvar marcação (4 plantas novas)'));
    await tester.pumpAndSettle();

    // Hoje (7 DAP): 1 planta na linha 2 → dia 2.
    await tester.enterText(data, dataBr(hojeMenos(0)));
    await tester.pump();
    expect(find.text('Dia 2'), findsWidgets);
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    await tester.tap(find.text('Salvar marcação (1 plantas novas)'));
    await tester.pumpAndSettle();

    expect(find.text('80,0%'), findsOneWidget);
    expect(
      find.textContaining('Linha 2 tem mais plantas tardias'),
      findsOneWidget,
    );
    // Milho: 1 planta com 1 dia de atraso em 5 → 35% ÷ 5 = 7%.
    expect(find.text('7,0%'), findsOneWidget);

    final salvas = await const RepositorioEmergencia().listar();
    expect(salvas, hasLength(1));
    expect(salvas.single.registros, hasLength(2));
  });
}
