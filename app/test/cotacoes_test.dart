import 'dart:io';

import 'package:consultor_campo/cotacoes/cotacoes_estado.dart';
import 'package:consultor_campo/cotacoes/cotacoes_page.dart';
import 'package:consultor_campo/main.dart';
import 'package:consultor_campo/tema.dart';
import 'package:cotacoes/cotacoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final feedEmbutido = File('assets/cotacoes/cotacoes.json').readAsStringSync();

/// Feed "da internet": o embutido com outra data e Sorriso a 150.
String feedNovo() => feedEmbutido
    .replaceFirst('2026-10-02T18:05:00-03:00', '2026-10-05T18:05:00-03:00')
    .replaceFirst('"preco": 139.9', '"preco": 150.0');

CotacoesEstado estadoTeste({String? Function()? internet, DateTime? agora}) =>
    CotacoesEstado(
      buscar: (_) async {
        final t = internet?.call();
        if (t == null) throw const SocketException('sem internet');
        return t;
      },
      embutido: () async => feedEmbutido,
      agora: () => agora ?? DateTime(2026, 10, 3, 9),
    );

void tela(WidgetTester tester, Size tamanho) {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> abrir(WidgetTester tester, CotacoesEstado estado) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: temaConsultor(),
      home: CotacoesPage(estado: estado),
    ),
  );
  await tester.runAsync(estado.carregar);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testesMapa();

  group('estado', () {
    test('sem internet e sem nada salvo, usa o feed do app', () async {
      final e = estadoTeste();
      await e.carregar();
      expect(e.origem, OrigemFeed.embutido);
      expect(e.semConexao, isTrue);
      expect(e.cotacoes, isNotEmpty);
    });

    test('com internet atualiza, guarda e mantém sem internet', () async {
      var online = true;
      final e = estadoTeste(internet: () => online ? feedNovo() : null);
      await e.carregar();
      expect(e.origem, OrigemFeed.internet);
      expect(e.recebidoEm, DateTime(2026, 10, 3, 9));
      final sorriso = cidadePorNome('Sorriso', 'MT')!;
      expect(precoDaCidade(sorriso, e.cotacoes)!.preco, 150);

      online = false;
      final depois = estadoTeste(internet: () => null);
      await depois.carregar();
      expect(depois.origem, OrigemFeed.salvo);
      expect(depois.semConexao, isTrue);
      expect(depois.recebidoEm, DateTime(2026, 10, 3, 9));
      expect(precoDaCidade(sorriso, depois.cotacoes)!.preco, 150);
    });

    test('não troca por um feed mais antigo', () async {
      final e = estadoTeste(internet: feedNovo);
      await e.carregar();
      final velho = estadoTeste(internet: () => feedEmbutido);
      await velho.carregar();
      expect(velho.feed!.geradoEm, DateTime.parse('2026-10-05T18:05:00-03:00'));
    });

    test('avisa quando a cotação é de antes do último dia útil', () async {
      // Sexta 02/10; segunda 05/10 ainda vale a de sexta.
      final segunda = estadoTeste(agora: DateTime(2026, 10, 5, 9));
      await segunda.carregar();
      expect(segunda.desatualizado, isFalse);
      final terca = estadoTeste(agora: DateTime(2026, 10, 6, 9));
      await terca.carregar();
      expect(terca.desatualizado, isTrue);
    });

    test('preço informado fica salvo e vira a cotação da cidade', () async {
      final e = estadoTeste();
      await e.carregar();
      final lucas = cidadePorNome('Lucas do Rio Verde', 'MT')!;
      expect(precoDaCidade(lucas, e.cotacoes)!.origem, OrigemPreco.estimado);
      await e.informar(
        produto: Produto.soja,
        cidade: lucas,
        preco: 141.5,
        fonte: 'Cerealista Boa Safra',
        data: DateTime(2026, 10, 3),
        informadoPor: 'Ana',
      );
      await e.definirMinhaCidade(lucas);

      final outra = estadoTeste();
      await outra.carregar();
      final p = precoDaCidade(lucas, outra.cotacoes)!;
      expect(p.origem, OrigemPreco.informado);
      expect(p.preco, 141.5);
      expect(outra.minhaCidade, lucas);
      expect(outra.uf, 'MT');
    });
  });

  testWidgets('o menu abre a Inteligência de mercado, na aba Cotações', (
    tester,
  ) async {
    tela(tester, const Size(800, 2600));
    await tester.pumpWidget(const ConsultorCampoApp());
    await tester.tap(find.text('Inteligência de mercado'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CotacoesPage), findsOneWidget);
  });

  testWidgets('tablet: mapa, estado escolhido e cidade estimada', (
    tester,
  ) async {
    tela(tester, const Size(1194, 1400));
    final e = estadoTeste();
    await abrir(tester, e);

    expect(find.text('Mato Grosso'), findsOneWidget);
    expect(
      find.textContaining('Em conceito', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Tangará da Serra'), findsOneWidget);
    expect(find.textContaining('Sem internet'), findsOneWidget);
    expect(find.textContaining('Cotações de 02/10/2026'), findsNothing);

    await tester.tap(find.text('Lucas do Rio Verde'));
    await tester.pumpAndSettle();
    expect(find.text('Cidade selecionada'), findsOneWidget);
    expect(find.textContaining('Estimado de Sorriso'), findsWidgets);

    await tester.tap(find.text('Usar como minha região'));
    await tester.pumpAndSettle();
    expect(find.text('Sua região'), findsOneWidget);

    await tester.tap(find.textContaining(RegExp(r'^GO'), findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Goiás'), findsOneWidget);
    expect(find.text('Rio Verde'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('celular: lista de estados abre o detalhe', (tester) async {
    tela(tester, const Size(390, 2400));
    final e = estadoTeste();
    await abrir(tester, e);
    await tester.tap(
      find.textContaining(RegExp(r'^Paraná'), findRichText: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('Marechal Cândido Rondon'), findsOneWidget);
    expect(
      find.textContaining('Em conceito', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Indicador Paranaguá · Cepea'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('informar preço valida e salva', (tester) async {
    tela(tester, const Size(1194, 1400));
    final e = estadoTeste();
    await abrir(tester, e);

    await tester.tap(find.text('Informar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar preço'));
    await tester.pump();
    expect(find.text('Escolha o local da cotação.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Local'), 'sinop');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sinop – MT').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Preço'), '141,50');
    await tester.enterText(
      find.widgetWithText(TextField, 'Nome da fonte'),
      'Boa Safra',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Data'),
      '03/10/2026',
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Salvar preço'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(e.informados, hasLength(1));
    expect(e.informados.single.fonte, 'Cooperativa Boa Safra');
    expect(find.text('Sinop'), findsWidgets);
    expect(find.text('Informado'), findsWidgets);
  });
}

void testesMapa() {
  testWidgets('celular: tocar no estado do mapa abre o detalhe', (
    tester,
  ) async {
    tela(tester, const Size(390, 2400));
    final e = estadoTeste();
    await abrir(tester, e);
    await tester.tap(find.bySemanticsLabel('BA 145,8'));
    await tester.pumpAndSettle();
    expect(e.uf, 'BA');
    expect(find.text('Luís Eduardo Magalhães'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
