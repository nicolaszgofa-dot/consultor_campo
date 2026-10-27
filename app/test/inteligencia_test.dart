import 'package:consultor_campo/inteligencia/concorrencia_dados.dart';
import 'package:consultor_campo/inteligencia/concorrencia_view.dart';
import 'package:consultor_campo/inteligencia/precos_estado.dart';
import 'package:consultor_campo/inteligencia/precos_view.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void tela(WidgetTester tester, Size tamanho) {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> abrir(WidgetTester tester, Widget filho) => tester.pumpWidget(
  MaterialApp(
    theme: temaConsultor(),
    home: Scaffold(body: filho),
  ),
);

PrecoConcorrente preco(String id, double valor, {String unidade = 'por kit'}) =>
    PrecoConcorrente(
      concorrenteId: id,
      preco: valor,
      unidade: unidade,
      condicao: 'À vista',
      fonte: fontesPreco.first,
      local: 'Sorriso – MT',
      data: DateTime(2026, 10, 20),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('dados', () {
    test('seis linhas, cada uma completa', () {
      expect(linhasProduto.map((l) => l.nome), [
        'Dosadores mecânicos',
        'Dosadores pneumáticos',
        'Motorização elétrica',
        'Dosador de esteira',
        'Dosadores de adubo',
        'Controle de pressão',
      ]);
      for (final l in linhasProduto) {
        expect(l.concorrentes, isNotEmpty, reason: l.nome);
        expect(l.provas, isNotEmpty, reason: l.nome);
        expect(l.produtos.where((p) => p.jassy), hasLength(1), reason: l.nome);
        for (final p in l.produtos) {
          for (final (id, _) in l.criterios) {
            expect(p.valores, contains(id), reason: '${l.nome} / ${p.nome}');
          }
        }
      }
    });

    test('ids de concorrente são únicos', () {
      final ids = [
        for (final l in linhasProduto)
          for (final c in l.concorrentes) c.id,
      ];
      expect(ids.toSet(), hasLength(ids.length));
      expect(concorrentePorId('orion')!.linha.id, 'motor');
    });

    test('nenhum preço de anúncio no app público', () {
      final r = RegExp(r'R\$ ?\d');
      for (final l in linhasProduto) {
        for (final c in l.concorrentes) {
          for (final a in c.ataca) {
            expect(r.hasMatch(a), isFalse, reason: a);
          }
        }
      }
    });
  });

  group('preços', () {
    test('guarda, resume por produto e unidade e filtra por linha', () async {
      final e = PrecosConcorrenciaEstado();
      await e.carregar();
      await e.adicionar(preco('x3', 2200));
      await e.adicionar(preco('x3', 2100));
      await e.adicionar(preco('x3', 120, unidade: 'por linha'));
      await e.adicionar(preco('orion', 3000));

      final outro = PrecosConcorrenciaEstado();
      await outro.carregar();
      expect(outro.precos, hasLength(4));

      outro.filtrar('mecanicos');
      expect(outro.filtrados, hasLength(3));
      final kit = outro.resumos.firstWhere((r) => r.unidade == 'por kit');
      expect(kit.media, 2150);
      expect(kit.minimo, 2100);
      expect(kit.maximo, 2200);
      expect(outro.resumos, hasLength(2));

      await outro.remover(outro.filtrados.first);
      final terceiro = PrecosConcorrenciaEstado();
      await terceiro.carregar();
      expect(terceiro.precos, hasLength(3));
    });
  });

  for (final tamanho in const [Size(1194, 3000), Size(390, 5000)]) {
    testWidgets('fichas de todas as linhas abrem sem erro em $tamanho', (
      tester,
    ) async {
      tela(tester, tamanho);
      await abrir(tester, const ConcorrenciaView());
      for (final l in linhasProduto) {
        await tester.tap(find.text(l.nome));
        await tester.pumpAndSettle();
        expect(find.textContaining(l.tese), findsOneWidget, reason: l.nome);
        for (final c in l.concorrentes) {
          await tester.tap(find.text(c.nome));
          await tester.pumpAndSettle();
          expect(find.text(c.produto), findsOneWidget);
        }
        await tester.tap(find.text('Ficha técnica'));
        await tester.pumpAndSettle();
        expect(find.text(l.criterios.first.$2), findsOneWidget);
        await tester.tap(find.text('Ficha de batalha'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: l.nome);
      }
    });
  }

  testWidgets('motorização: destaque dosador + motor e objeção da Orion', (
    tester,
  ) async {
    tela(tester, const Size(1194, 3000));
    await abrir(tester, const ConcorrenciaView());
    await tester.tap(find.text('Motorização elétrica'));
    await tester.pumpAndSettle();
    expect(find.textContaining('dosador + motor'), findsOneWidget);
    await tester.tap(find.text('Orion'));
    await tester.pumpAndSettle();
    expect(
      find.text('“A Orion promete 14% de produtividade.”'),
      findsOneWidget,
    );
    expect(find.text('Confirmar com a engenharia J.Assy'), findsOneWidget);
  });

  testWidgets('informar preço valida, salva e mostra no resumo', (
    tester,
  ) async {
    tela(tester, const Size(1194, 1600));
    final e = PrecosConcorrenciaEstado();
    await tester.runAsync(e.carregar);
    await abrir(tester, PrecosView(estado: e));
    expect(find.textContaining('Nenhum preço informado'), findsOneWidget);

    await tester.tap(find.text('Informar preço'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar preço'));
    await tester.pump();
    expect(find.text('Informe o preço.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Preço'), '2.200');
    await tester.enterText(
      find.widgetWithText(TextField, 'Cidade – UF'),
      'Cascavel – PR',
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Salvar preço'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(e.precos.single.preco, 2200);
    expect(e.precos.single.concorrenteId, 'x3');
    expect(find.text('TOPlanting TOP X3'), findsWidgets);
    expect(find.textContaining('2.200,00'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
