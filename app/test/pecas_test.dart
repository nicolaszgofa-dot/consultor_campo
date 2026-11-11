import 'package:consultor_campo/pecas/lista_pecas.dart';
import 'package:consultor_campo/pecas/pecas_dados.dart';
import 'package:consultor_campo/pecas/pecas_page.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('áreas dos códigos ficam dentro da imagem', () {
    for (final p in produtosPecas) {
      for (final c in p.conjuntos) {
        final imagem = Rect.fromLTWH(0, 0, c.largura, c.altura);
        for (final peca in c.pecas) {
          expect(
            imagem.contains(peca.area.topLeft) &&
                imagem.contains(peca.area.bottomRight),
            isTrue,
            reason: '${peca.codigo} fora de ${c.titulo}',
          );
          expect(peca.codigo, matches(RegExp(r'^\d{11}$')));
        }
      }
    }
  });

  test('busca por código, por palavras e sem acento', () {
    expect(
      buscarPecas('30000000615').single.peca.descricao,
      contains('motor Doga'),
    );
    expect(buscarPecas('roseta milho').length, 2);
    expect(buscarPecas('FEIJAO').length, 2);
    expect(buscarPecas('escovaflex').single.produto.nome, 'Titanium Elétric');
    expect(buscarPecas('motor doga').length, 3);
    expect(buscarPecas('   '), isEmpty);
    expect(buscarPecas('inexistente'), isEmpty);
  });

  test('lista soma quantidades e gera o texto', () {
    final l = ListaPecas();
    final c = produtosPecas.first.conjuntos.first;
    l
      ..adicionar(c.pecas[0], 'Selenium Elétric')
      ..adicionar(c.pecas[0], 'Selenium Elétric')
      ..adicionar(c.pecas[1], 'Selenium Elétric');
    expect(l.totalPecas, 3);
    expect(l.comoTexto(), contains('2x ${c.pecas[0].codigo}'));
    l.mudarQuantidade(c.pecas[1], -1);
    expect(l.itens, hasLength(1));
  });

  testWidgets('produto, conjunto, toque no código e lista', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: temaConsultor(), home: const PecasPage()),
    );
    expect(find.text('Em breve'), findsNWidgets(4));

    await tester.tap(find.text('Selenium Elétric'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Motorização Elétric'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Motorização Elétric'));
    await tester.pumpAndSettle();

    // Toque no código do motor no desenho destaca a linha da lista.
    await tester.tap(
      find
          .byWidgetPredicate(
            (w) =>
                w is Semantics &&
                (w.properties.label ?? '').startsWith('30000000615'),
          )
          .first,
    );
    await tester.pumpAndSettle();
    final linha = tester.widget<LinhaPeca>(
      find.ancestor(
        of: find.text('Kit motor Doga 100 RPM Selenium Elétric'),
        matching: find.byType(LinhaPeca),
      ),
    );
    expect(linha.selecionada, isTrue);

    await tester.tap(
      find.descendant(
        of: find.byWidget(linha),
        matching: find.byTooltip('Pôr na lista'),
      ),
    );
    await tester.pump();
    expect(find.text('1 peça na lista'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('busca abre o conjunto com a peça destacada', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: temaConsultor(), home: const PecasPage()),
    );
    await tester.enterText(find.byType(TextField), 'kit visor');
    await tester.pump();
    expect(find.text('1 PEÇA ENCONTRADA'), findsOneWidget);
    await tester.tap(find.text('Kit visor Selenium'));
    await tester.pumpAndSettle();
    expect(find.text('Corpo do dosador'), findsOneWidget);
    final linha = tester.widget<LinhaPeca>(
      find.ancestor(
        of: find.text('Kit visor Selenium'),
        matching: find.byType(LinhaPeca),
      ),
    );
    expect(linha.selecionada, isTrue);
    expect(tester.takeException(), isNull);
  });
}
