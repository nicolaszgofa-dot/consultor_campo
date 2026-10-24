import 'package:consultor_campo/main.dart';
import 'package:consultor_campo/roi/roi_estado.dart';
import 'package:consultor_campo/roi/roi_page.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roi/roi.dart';

void tela(WidgetTester tester, Size tamanho) {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Exemplo da planilha, digitado como o vendedor digitaria.
const exemplo = {
  'area': '2.000',
  'linhas': '66',
  'prod': '65',
  'preco': '125',
  'pop': '300.000',
  'semente': '2,50',
  'sob': '3',
  'red': '85',
  'zona': '500',
  'popAtual': '300000',
  'popPresc': '250000',
  'curvas': '15',
  'perda': '0,5',
  'oper': '20.000',
  'inv': '480.000',
  'conc': '220.000',
  'nova': '1.500.000',
  'atual': '600.000',
  'vida': '3',
};

RoiEstado estadoExemplo() {
  final e = RoiEstado();
  exemplo.forEach(e.mudar);
  return e;
}

void main() {
  group('estado', () {
    test('lê números com ponto de milhar e vírgula decimal', () {
      expect(lerValorRoi('1.500.000'), 1500000);
      expect(lerValorRoi('2,50'), 2.5);
      expect(lerValorRoi('1.500.000,75'), 1500000.75);
      expect(lerValorRoi('0.5'), 0.5);
      expect(lerValorRoi(''), isNull);
    });

    test('o exemplo da planilha dá o mesmo resultado', () {
      final r = estadoExemplo().resultado;
      final p = r.cenarios[CenarioRoi.provavel]!;
      expect(p.beneficioSafra, closeTo(295437.5, 1e-6));
      expect(p.payback, closeTo(1.6247091178337212, 1e-9));
      expect(r.jassy.porLinha, closeTo(7272.727272727273, 1e-6));
    });

    test('obrigatórios e percentuais bloqueiam o avanço', () {
      final e = RoiEstado();
      expect(e.bloqueio, 'Área plantada: Obrigatório.');
      e.mudar('area', '2000');
      expect(e.bloqueio, isNull);
      e.avancar();
      e.mudar('sob', '120');
      expect(e.bloqueio, 'Sobreposição atual: Entre 0 e 100%.');
      e.avancar();
      expect(e.etapa, 1);
      e.mudar('sob', '3');
      e.avancar();
      expect(e.etapa, 2);
    });

    test('na etapa de investimento pede retrofit e vida econômica', () {
      final e = RoiEstado()
        ..mudar('area', '10')
        ..etapa = 4;
      expect(e.bloqueio, 'Retrofit J.Assy: Obrigatório.');
      e.mudar('inv', '100');
      expect(e.bloqueio, 'Vida econômica: Obrigatório.');
      e.mudar('vida', '0');
      expect(e.bloqueio, 'Vida econômica: Precisa ser maior que zero.');
    });
  });

  testWidgets('o menu abre o ROI sem preços preenchidos', (tester) async {
    tela(tester, const Size(800, 2600));
    await tester.pumpWidget(const ConsultorCampoApp());
    await tester.tap(find.text('ROI'));
    await tester.pumpAndSettle();
    expect(find.byType(RoiPage), findsOneWidget);
    expect(find.text('Fazenda e produção'), findsOneWidget);
    final campos = tester.widgetList<TextField>(find.byType(TextField));
    expect(campos.every((c) => c.controller!.text.isEmpty), isTrue);
  });

  testWidgets('preenche a primeira etapa e o ? mostra como apresentar', (
    tester,
  ) async {
    tela(tester, const Size(430, 2400));
    final estado = RoiEstado();
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: RoiPage(estado: estado),
      ),
    );
    final continuar = find.widgetWithText(FilledButton, 'Continuar');
    expect(tester.widget<FilledButton>(continuar).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '2.000');
    await tester.pump();
    expect(estado.premissas.areaHa, 2000);
    expect(tester.widget<FilledButton>(continuar).onPressed, isNotNull);

    await tester.tap(find.byTooltip('Como apresentar: Área plantada'));
    await tester.pumpAndSettle();
    expect(find.text('COMO APRESENTAR AO CLIENTE'), findsOneWidget);
    expect(find.textContaining('área efetivamente plantada'), findsOneWidget);
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    await tester.tap(continuar);
    await tester.pumpAndSettle();
    expect(find.text('Sementes e sobreposição'), findsOneWidget);
    expect(find.text('PASSO 2 DE 7'), findsOneWidget);
  });

  testWidgets('tablet: resultado e comparativo do exemplo', (tester) async {
    tela(tester, const Size(1194, 834));
    final estado = estadoExemplo()..etapa = RoiEstado.etapaResultado;
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: RoiPage(estado: estado),
      ),
    );
    await tester.pumpAndSettle();

    for (final n in RoiEstado.nomesEtapas) {
      expect(find.text(n), findsWidgets, reason: n);
    }
    expect(find.text('R\$ 295.438'), findsWidgets);
    expect(find.text('1,62 safras'), findsWidgets);
    expect(find.text('61,5%'), findsWidgets);
    expect(find.textContaining('Retorno líquido: 84,6%'), findsOneWidget);

    await tester.tap(find.text('Conservador · 0,5%'));
    await tester.pump();
    expect(find.text('R\$ 214.188'), findsWidgets);

    await tester.tap(find.text('Comparar alternativas'));
    await tester.pumpAndSettle();
    expect(find.text('R\$ 900.000'), findsWidgets);
    expect(find.text('R\$ 420.000'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
