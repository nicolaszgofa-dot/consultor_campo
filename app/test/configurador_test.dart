import 'package:configurador/configurador.dart';
import 'package:consultor_campo/configurador/configurador_estado.dart';
import 'package:consultor_campo/configurador/configurador_page.dart';
import 'package:consultor_campo/main.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void tela(WidgetTester tester, Size tamanho) {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> abrir(WidgetTester tester, ConfiguradorEstado estado) =>
    tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: ConfiguradorPage(estado: estado),
      ),
    );

/// Autotransportável de 55 linhas (21 + 21 + 13) já no resultado.
ConfiguradorEstado autotransportavel55() {
  final e = ConfiguradorEstado()
    ..escolherTecnologia(Tecnologia.titaniumEletric)
    ..avancar()
    ..escolherTipo(TipoPlantadeira.autotransportavel)
    ..avancar()
    ..definirLinhas(55)
    ..avancar();
  e.secoes = [21, 21, 13];
  e
    ..avancar()
    ..responderAlternadorNaFrente(true)
    ..avancar();
  return e;
}

void main() {
  group('estado', () {
    test('a solteira pula a etapa de seções', () {
      final e = ConfiguradorEstado();
      expect(e.etapas, hasLength(6));
      e.escolherTipo(TipoPlantadeira.solteira);
      expect(e.etapas, isNot(contains(EtapaConfigurador.secoes)));
      expect(e.etapas, hasLength(5));
    });

    test('não avança sem resposta', () {
      final e = ConfiguradorEstado();
      e.avancar();
      expect(e.etapa, EtapaConfigurador.tecnologia);
      expect(e.bloqueio, 'Escolha a tecnologia.');
    });

    test('acima de 60 linhas bloqueia', () {
      final e = ConfiguradorEstado()
        ..escolherTecnologia(Tecnologia.seleniumEletric)
        ..avancar()
        ..escolherTipo(TipoPlantadeira.tandem)
        ..avancar()
        ..definirLinhas(61);
      expect(e.bloqueio, contains('Fale com a engenharia'));
      e.avancar();
      expect(e.etapa, EtapaConfigurador.linhas);
    });

    test('seções começam divididas ao meio e precisam somar o total', () {
      final e = ConfiguradorEstado()
        ..escolherTecnologia(Tecnologia.titaniumEletric)
        ..avancar()
        ..escolherTipo(TipoPlantadeira.caixaCentral)
        ..avancar()
        ..definirLinhas(45)
        ..avancar();
      expect(e.etapa, EtapaConfigurador.secoes);
      expect(e.secoes, [23, 22]);
      e.adicionarSecao();
      expect(e.bloqueio, contains('(46)'));
    });

    test('chicotes por seção vêm do motor de regras', () {
      final e = ConfiguradorEstado()
        ..tecnologia = Tecnologia.titaniumEletric
        ..tipo = TipoPlantadeira.autotransportavel
        ..totalLinhas = 45
        ..secoes = [17, 17, 11];
      final r = e.resultado;
      expect(r.item(Componentes.chicote4)!.quantidade, 10);
      expect(r.item(Componentes.chicote1)!.quantidade, 5);
    });

    test('ajuste do chicote painel volta à recomendação se a máquina muda', () {
      final e = autotransportavel55()..ajustarChicotePainel(7);
      expect(e.resultado.item(Componentes.chicotePainel)!.quantidade, 7);
      e.mudarSecao(0, 1);
      expect(e.quantidadeChicotePainel, isNull);
    });
  });

  testWidgets('o menu abre o Configurador', (tester) async {
    tela(tester, const Size(800, 2600));
    await tester.pumpWidget(const ConsultorCampoApp());
    await tester.tap(find.text('Configurador'));
    await tester.pumpAndSettle();
    expect(find.byType(ConfiguradorPage), findsOneWidget);
    expect(find.text('Qual tecnologia será configurada?'), findsOneWidget);
  });

  testWidgets('solteira de 8 linhas sem alternador, do início ao fim', (
    tester,
  ) async {
    tela(tester, const Size(430, 2400));
    final estado = ConfiguradorEstado();
    await abrir(tester, estado);

    await tester.tap(find.text('Titanium Elétric'));
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Qual é o tipo da plantadeira?'), findsOneWidget);

    await tester.tap(find.text('Solteira'));
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('PASSO 3 DE 5'), findsOneWidget);

    await tester.tap(find.text('8'));
    await tester.pump();
    expect(find.textContaining('Até 12 linhas o alternador'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // A solteira pula as seções e vai direto para a alimentação.
    expect(find.text('Alimentação elétrica'), findsOneWidget);
    final verConfiguracao = find.widgetWithText(
      FilledButton,
      'Ver configuração',
    );
    expect(tester.widget<FilledButton>(verConfiguracao).onPressed, isNull);
    await tester.tap(find.text('Não'));
    await tester.pump();
    expect(find.textContaining('2 chicotes painel de 4 m'), findsOneWidget);
    await tester.tap(verConfiguracao);
    await tester.pumpAndSettle();

    expect(find.text('Configuração gerada'), findsOneWidget);
    expect(find.text(Componentes.caboBateria), findsOneWidget);
    expect(find.text(Componentes.chicotePainel), findsOneWidget);
    expect(find.text(Componentes.alternador), findsNothing);
    expect(find.text('1 pendentes'), findsOneWidget);

    // Escolher o comprimento do ISOBUS fecha a última pendência.
    await tester.tap(find.bySemanticsLabel('5 m, sugerido'));
    await tester.pump();
    expect(find.text('Gerar relatório'), findsOneWidget);
  });

  testWidgets('voltar do cabeçalho volta uma etapa', (tester) async {
    tela(tester, const Size(430, 2400));
    final estado = ConfiguradorEstado()
      ..escolherTecnologia(Tecnologia.seleniumEletric)
      ..avancar();
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ConfiguradorPage(estado: estado),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Qual é o tipo da plantadeira?'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Qual tecnologia será configurada?'), findsOneWidget);
    expect(find.byType(ConfiguradorPage), findsOneWidget);
  });

  testWidgets('tablet: etapas na lateral e resultado de 55 linhas', (
    tester,
  ) async {
    tela(tester, const Size(1194, 834));
    final estado = autotransportavel55();
    await abrir(tester, estado);
    await tester.pumpAndSettle();

    for (final e in EtapaConfigurador.values) {
      expect(find.text(e.nome), findsOneWidget, reason: e.nome);
    }
    expect(find.text('Configuração gerada'), findsOneWidget);
    expect(find.text('3 pendentes'), findsOneWidget);
    expect(find.text('Recomendado: 8'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Mais um chicote painel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mais um chicote painel'));
    await tester.pump();
    expect(estado.quantidadeChicotePainel, 9);

    await tester.scrollUntilVisible(
      find.textContaining('Saída 3 (linhas 20 a 28)'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('Saída 5 (linhas 38 a 46)'), findsOneWidget);

    // Etapa já feita pode ser reaberta pela lateral.
    await tester.tap(find.text('Seções'));
    await tester.pumpAndSettle();
    expect(find.text('Quantas seções fecham separadas?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('alimentação do autotransportável sugere comprimentos', (
    tester,
  ) async {
    tela(tester, const Size(1194, 834));
    final estado = autotransportavel55()..voltar();
    estado.alternadorNaFrente = null;
    await abrir(tester, estado);
    await tester.pumpAndSettle();

    expect(
      find.text('A máquina permite instalar o alternador no cabeçalho?'),
      findsOneWidget,
    );
    expect(find.textContaining('Responda à pergunta acima'), findsOneWidget);
    await tester.tap(find.text('Não'));
    await tester.pump();
    expect(
      find.textContaining('cabo ISOBUS 11 m e mangueiras 12 m'),
      findsOneWidget,
    );
    expect(find.text('Saída 6'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
