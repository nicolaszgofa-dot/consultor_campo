import 'package:consultor_campo/funcionalidades.dart';
import 'package:consultor_campo/simulador/explicacoes.dart';
import 'package:consultor_campo/simulador/simulador_page.dart';
import 'package:consultor_campo/simulador/terminal_estado.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget com o rótulo de acessibilidade (as partes tocáveis do terminal).
Finder _rotulo(String rotulo) => find
    .byWidgetPredicate((w) => w is Semantics && w.properties.label == rotulo)
    .first;

void main() {
  test('simulador nos dois apps, logo depois de Conceito', () {
    for (final lista in [funcionalidadesEquipe(), funcionalidadesRevenda()]) {
      final titulos = lista.map((f) => f.titulo).toList();
      final i = titulos.indexOf('Simulador Elétric');
      expect(i, greaterThan(0));
      expect(titulos[i - 1], 'Conceito');
      expect(lista[i].emBreve, isFalse);
    }
  });

  test('link do protótipo em tela cheia e sem dicas', () {
    expect(simuladorEletric.host, 'xd.adobe.com');
    expect(simuladorEletric.query, 'fullscreen&hints=off');
  });

  group('simulação do terminal', () {
    test('taxa por linha perto da taxa alvo, médias e população', () {
      final t = TerminalEstado();
      final m = t.media;
      expect(m.taxa, closeTo(t.taxaAlvo, 0.5));
      expect(m.singulacao, greaterThan(95));
      expect(m.cv, inInclusiveRange(5, 60));
      // População em mil plantas/ha: taxa × 10 / espaçamento entre linhas.
      expect(
        t.valor(Grafico.populacao, 0),
        closeTo(t.leituras[0].taxa * 20, 1e-9),
      );
      t.dispose();
    });

    test('ajuste de taxa em passos de 0,1 sem/m', () {
      final t = TerminalEstado()
        ..mudarTaxa(0.1)
        ..mudarTaxa(0.1);
      expect(t.taxaAlvo, closeTo(14.2, 1e-9));
      t.mudarTaxa(-1);
      expect(t.taxaAlvo, closeTo(13.2, 1e-9));
      t.dispose();
    });

    test('entupimento: linha parada e alarme do manual', () {
      final t = TerminalEstado()..entupir(6);
      expect(t.leituras[6].taxa, 0);
      expect(
        t.alarmes.first.texto,
        'Linha 07 - Fim de Sementes ou Entupimento',
      );
      // Em manobra o alarme não aparece.
      t.alternarPlantar();
      expect(t.plantando, isFalse);
      expect(t.alarmes, isEmpty);
      t.dispose();
    });

    test('linha desligada sai das médias e liga o ícone de seção', () {
      final t = TerminalEstado()..alternarLinha(0);
      expect(t.linhaLigada(0), isFalse);
      expect(t.secaoDesligada, isTrue);
      expect(t.leituras[0].taxa, 0);
      expect(t.media.taxa, greaterThan(10));
      t.dispose();
    });

    test('gráficos alternam as cinco grandezas', () {
      final t = TerminalEstado();
      final vistos = <Grafico>{};
      for (var i = 0; i < 5; i++) {
        vistos.add(t.graficoCima);
        t.trocarGraficoCima();
      }
      expect(vistos, Grafico.values.toSet());
      t.dispose();
    });
  });

  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1300, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: SimuladorPage(animar: false, abrirLink: (_) async => true),
      ),
    );
  }

  testWidgets('modo explicação mostra o texto da parte tocada', (tester) async {
    await abrir(tester);
    await tester.tap(find.text('Explicar a tela'));
    await tester.pump();
    await tester.tap(_rotulo(ParteTerminal.cv.titulo));
    await tester.pump();
    expect(find.text(ParteTerminal.cv.titulo), findsWidgets);
    expect(find.textContaining('CV dos espaçamentos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar em TAXA abre o ajuste e o + sobe a taxa', (tester) async {
    await abrir(tester);
    await tester.tap(_rotulo(ParteTerminal.taxa.titulo));
    await tester.pump();
    expect(find.text('14,00'), findsOneWidget);
    await tester.tap(_rotulo('Aumentar taxa'));
    await tester.pump();
    expect(find.text('14,10'), findsOneWidget);
    await tester.tap(_rotulo('Fechar ajuste da taxa'));
    await tester.pump();
    expect(find.text('14,10'), findsNothing);
  });

  testWidgets('entupir a linha 7 acende o alarme na barra', (tester) async {
    await abrir(tester);
    await tester.tap(find.text('Entupir a linha 7'));
    await tester.pump();
    expect(
      find.text('Linha 07 - Fim de Sementes ou Entupimento'),
      findsOneWidget,
    );
  });

  testWidgets('abrir o protótipo chama o link; avisa se falhar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1300, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Uri? aberto;
    var resposta = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: SimuladorPage(
          animar: false,
          abrirLink: (u) async {
            aberto = u;
            return resposta;
          },
        ),
      ),
    );
    await tester.tap(find.text('Abrir protótipo (Adobe XD)'));
    await tester.pump();
    expect(aberto, simuladorEletric);
    expect(find.textContaining('Não foi possível'), findsNothing);

    resposta = false;
    await tester.tap(find.text('Abrir protótipo (Adobe XD)'));
    await tester.pump();
    expect(find.textContaining('Não foi possível abrir'), findsOneWidget);
  });
}
