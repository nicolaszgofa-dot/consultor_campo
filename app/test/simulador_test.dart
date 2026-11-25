import 'package:consultor_campo/funcionalidades.dart';
import 'package:consultor_campo/simulador/explicacoes.dart';
import 'package:consultor_campo/simulador/referencias_terminal.dart';
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

    test('limites da Dosagem acendem os alarmes do manual', () {
      final t = TerminalEstado();
      expect(t.alarmes, isEmpty);
      // Pressão de ar alta: duplos acima de 10% e distribuição abaixo de 90.
      t.mudar(() => t.pressaoArAlta = true);
      final textos = t.alarmes.map((a) => a.texto).toList();
      expect(textos, contains(matches(r'^Linha \d\d - Excesso de Duplos$')));
      expect(
        t.alarmes.map((a) => a.tipo),
        contains(TipoAlarme.distribuicaoRuim),
      );
      // Subir o máximo de duplos tira esse alarme.
      t.mudar(() => t.maximoDuplos = 50);
      expect(
        t.alarmes.map((a) => a.tipo),
        isNot(contains(TipoAlarme.excessoDuplos)),
      );
      t.dispose();
    });

    test('ajuste de população acima de 1 acende o ganho de população', () {
      final t = TerminalEstado()..mudar(() {});
      expect(t.alarmes, isEmpty);
      final antes = t.media.taxa;
      final t2 = TerminalEstado();
      t2.mudar(() => t2.ajustePopulacao = 1.1);
      expect(
        t2.alarmes.map((a) => a.tipo),
        contains(TipoAlarme.ganhoPopulacao),
      );
      expect(t2.media.taxa, greaterThan(antes));
      t.dispose();
      t2.dispose();
    });

    test('energia: alternador parado só alarma com alternador', () {
      final t = TerminalEstado()..mudar(() {});
      t.mudar(() => t.alternadorParado = true);
      expect(t.rotacaoAlternador, 0);
      expect(t.alarmes.first.tipo, TipoAlarme.alternadorDesligado);
      expect(t.alarmes.first.critico, isTrue);
      t.mudar(() => t.energia = FonteEnergia.bateria);
      expect(t.alarmes, isEmpty);
      // Rotação abaixo da mínima configurada.
      t.mudar(() {
        t.energia = FonteEnergia.alternador;
        t.alternadorParado = false;
        t.rotacaoMinima = 6000;
      });
      expect(t.alarmes.first.tipo, TipoAlarme.baixaRotacaoAlternador);
      t.dispose();
    });

    test('sem GPS: alarme só com a fonte em GPS', () {
      final t = TerminalEstado()..mudar(() {});
      t.mudar(() => t.semSinalGps = true);
      expect(t.alarmes.single.tipo, TipoAlarme.fonteVelocidadeAusente);
      t.mudar(() => t.fonteVelocidade = FonteVelocidade.manual);
      expect(t.alarmes, isEmpty);
      t.dispose();
    });

    test('parado (abaixo da velocidade de parada) os dosadores param', () {
      final t = TerminalEstado()..entupir(6);
      t.mudarVelocidade(0.5);
      expect(t.dosando, isFalse);
      expect(t.media.taxa, 0);
      expect(t.alarmes, isEmpty);
      t.mudarVelocidade(6);
      expect(t.dosando, isTrue);
      t.dispose();
    });

    test('número de linhas e endereçamento', () {
      final t = TerminalEstado()..mudarNumeroLinhas(30);
      expect(t.numeroLinhas, 30);
      expect(t.leituras, hasLength(30));
      expect(t.linhaLigada(29), isTrue);
      t.mudarNumeroLinhas(9);
      expect(t.numeroLinhas, 9);

      final antigo = t.endereco(0);
      t.lerEndereco();
      t.atualizar();
      expect(t.contagemLeitura, 1);
      t.encostarIma();
      expect(t.lendoEndereco, isFalse);
      expect(t.enderecoLido, hasLength(8));
      t.gravarEndereco();
      expect(t.endereco(0), t.enderecoLido);
      expect(t.endereco(0), isNot(antigo));
      t.dispose();
    });

    test('catálogo de alarmes: textos por linha e soluções', () {
      expect(
        const Alarme(TipoAlarme.excessoFalhas, linha: 2).texto,
        'Linha 03 - Excesso de Falhas',
      );
      expect(TipoAlarme.values.length, greaterThanOrEqualTo(28));
      expect(TipoAlarme.falhaRotacao.solucao, 'Fazer a troca do motor.');
      expect(monitoresCompativeis, hasLength(9));
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

  /// Toca num item do painel, rolando até ele se preciso.
  Future<void> tocarNoPainel(WidgetTester tester, String texto) async {
    await tester.ensureVisible(find.text(texto));
    await tester.pumpAndSettle();
    await tester.tap(find.text(texto));
    await tester.pump();
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
    await tocarNoPainel(tester, 'Entupir a linha 7');
    // Na barra do terminal e no cartão do painel.
    expect(
      find.text('Linha 07 - Fim de Sementes ou Entupimento'),
      findsNWidgets(2),
    );
  });

  testWidgets('configurações: Dosagem edita o campo com + e −', (tester) async {
    await abrir(tester);
    await tester.tap(_rotulo(ParteTerminal.configuracoes.titulo));
    await tester.pump();
    await tester.tap(_rotulo('Dosagem e Sensoriamento'));
    await tester.pump();
    expect(find.text('Numero de furos no disco:'), findsOneWidget);
    expect(find.text('10,0'), findsNWidgets(2)); // falhas e duplos

    await tester.tap(_rotulo('Maximo de Duplos'));
    await tester.pump();
    await tester.tap(_rotulo('Aumentar valor'));
    await tester.pump();
    expect(find.text('10,5'), findsOneWidget);
    await tester.tap(_rotulo('Confirmar valor'));
    await tester.pump();
    expect(find.text('Aumentar valor'), findsNothing);

    // Voltar ao menu.
    await tester.tap(_rotulo('Voltar ao menu de configurações'));
    await tester.pump();
    expect(find.text('Sensor de Levante'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cadeado: engenharia só edita depois da senha', (tester) async {
    await abrir(tester);
    await tester.tap(_rotulo(ParteTerminal.configuracoes.titulo));
    await tester.pump();
    await tester.tap(_rotulo('Dosagem e Sensoriamento'));
    await tester.pump();
    // Travado: tocar não abre a edição.
    await tester.tap(_rotulo('Singulacao Critica'));
    await tester.pump();
    expect(find.text('Singulacao Critica'), findsNothing);

    await tester.tap(_rotulo('Liberar parâmetros de engenharia'));
    await tester.pump();
    expect(find.text('Digite a senha de acesso:'), findsOneWidget);
    await tester.tap(_rotulo('Confirmar senha'));
    await tester.pump();
    await tester.tap(_rotulo('Singulacao Critica'));
    await tester.pump();
    expect(find.text('Singulacao Critica'), findsOneWidget); // no editor
    expect(tester.takeException(), isNull);
  });

  testWidgets('fonte de velocidade: escolher Manual na lista', (tester) async {
    await abrir(tester);
    await tester.tap(_rotulo(ParteTerminal.configuracoes.titulo));
    await tester.pump();
    await tester.tap(_rotulo('Fonte de Velocidade'));
    await tester.pump();
    expect(find.text('GPS ISOBUS'), findsOneWidget);
    await tester.tap(_rotulo('Escolher a fonte de velocidade'));
    await tester.pump();
    await tester.tap(_rotulo('MANUAL'));
    await tester.pump();
    expect(find.text('Velocidade:'), findsOneWidget);
    expect(find.text('MANUAL'), findsWidgets); // seletor e tecla A
    expect(tester.takeException(), isNull);
  });

  testWidgets('cada tela de configuração abre sem erro', (tester) async {
    await abrir(tester);
    await tester.tap(_rotulo(ParteTerminal.configuracoes.titulo));
    await tester.pump();
    for (final c in TelaConfig.values) {
      await tester.tap(_rotulo(c.titulo));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: c.titulo);
      await tester.tap(_rotulo('Voltar ao menu de configurações'));
      await tester.pump();
    }
  });

  testWidgets('alarme ativo aparece no painel com o que fazer', (tester) async {
    await abrir(tester);
    await tocarNoPainel(tester, 'Parar o alternador');
    expect(
      find.text('Alternador desligado - Consumindo Baterias'),
      findsWidgets,
    );
    expect(
      find.textContaining('Ligar o alternador', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('listas de alarmes e de monitores abrem', (tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: temaConsultor(), home: const AlarmesTerminalPage()),
    );
    expect(find.text('Sensor Ausente'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: const MonitoresCompativeisPage(),
      ),
    );
    expect(find.text('John Deere GS3'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
    await tocarNoPainel(tester, 'Abrir protótipo (Adobe XD)');
    expect(aberto, simuladorEletric);
    expect(find.textContaining('Não foi possível'), findsNothing);

    resposta = false;
    await tocarNoPainel(tester, 'Abrir protótipo (Adobe XD)');
    expect(find.textContaining('Não foi possível abrir'), findsOneWidget);
  });
}
