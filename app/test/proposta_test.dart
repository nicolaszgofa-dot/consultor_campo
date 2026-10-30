import 'dart:convert';

import 'package:consultor_campo/roi/proposta/proposta_dados.dart';
import 'package:consultor_campo/roi/proposta/proposta_page.dart';
import 'package:consultor_campo/roi/proposta/proposta_pdf.dart';
import 'package:consultor_campo/roi/roi_estado.dart';
import 'package:consultor_campo/roi/roi_page.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roi/roi.dart';

import 'roi_test.dart' show estadoExemplo, tela;

DadosProposta dadosExemplo({
  ProdutoProposta produto = ProdutoProposta.titanium,
  Fornecimento fornecimento = Fornecimento.completo,
  List<ItemProposta>? itens,
}) => DadosProposta(
  itens:
      itens ??
      [
        ItemProposta(
          produto: produto,
          fornecimento: fornecimento,
          plantadeira: 'Tatu PST',
          linhas: 66,
          valorLinha: 7300,
        ),
      ],
  impostos: '+ Difal',
  cliente: 'Fazenda Santa Rita',
  documento: '000.000.000-00',
  cidade: 'Caldas Novas',
  data: DateTime(2026, 10, 27),
  consultor: 'Ana Souza',
  contatoConsultor: '(64) 99999-1111',
  entrada: 0.2,
  parcelas: [
    (fracao: 0.4, quando: '30/04/2027'),
    (fracao: 0.4, quando: '30/09/2027'),
  ],
  validade: '15 dias',
  prazo: '30 dias',
  local: 'A combinar',
  garantia: '1 ano',
);

void main() {
  group('dados', () {
    test('total, parcelas e investimento do ROI vêm da proposta', () {
      final d = dadosExemplo();
      expect(d.total, 481800);
      expect(d.valoresPagamento, [96360, 192720, 192720]);
      final p = premissasDaProposta(estadoExemplo().premissas, d);
      expect(p.investimento, 481800);
      expect(p.linhas, 66);
      expect(p.areaHa, 2000);
    });

    test('cada produto tem os textos e a lista do sistema dos modelos', () {
      for (final produto in ProdutoProposta.values) {
        expect(produto.beneficios, hasLength(4), reason: produto.nome);
        expect(produto.caracteristicas, hasLength(6), reason: produto.nome);
        for (final f in produto.fornecimentos.keys) {
          final sistema = produto.sistema[f] ?? const [];
          if (sistema.isNotEmpty) {
            expect(sistema, contains('Frete e instalação'));
          }
          expect(produto.itemProposta[f], isNotEmpty);
        }
      }
      expect(
        ProdutoProposta.selenium.beneficios.map((b) => b.titulo),
        isNot(contains('Várias culturas')),
      );
    });
  });

  testWidgets('gera o PDF em até 4 páginas para os dois produtos', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final recursos = await RecursosPdf.carregar();
      for (final produto in ProdutoProposta.values) {
        for (final f in produto.fornecimentos.keys) {
          final bytes = await gerarPropostaPdf(
            dados: dadosExemplo(produto: produto, fornecimento: f),
            premissas: estadoExemplo().premissas,
            cenario: CenarioRoi.provavel,
            recursos: recursos,
          );
          final texto = latin1.decode(bytes);
          expect(texto.startsWith('%PDF'), isTrue);
          expect(
            RegExp(r'/Type\s*/Page\b').allMatches(texto).length,
            inInclusiveRange(3, 4),
            reason: '${produto.nome} $f',
          );
        }
      }
    });
  });

  testWidgets('a proposta só gera com produto, preço, cliente e 100%', (
    tester,
  ) async {
    tela(tester, const Size(1194, 3000));
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: PropostaPage(
          premissas: estadoExemplo().premissas,
          cenario: CenarioRoi.provavel,
        ),
      ),
    );

    // Linhas vêm do ROI; o valor por linha só quando 480.000 / 66 fecharia em
    // centavos (aqui não fecha).
    expect(find.text('66'), findsOneWidget);
    expect(find.text('7.272,73'), findsNothing);

    await tester.tap(find.text('Gerar PDF'));
    await tester.pump();
    expect(find.textContaining('Escolha o produto.'), findsOneWidget);
    expect(find.textContaining('Informe o cliente.'), findsOneWidget);

    await tester.tap(find.text('Selenium Elétric'));
    await tester.pump();
    expect(find.text('Conversão do Selenium G3'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('proposta-valor')),
      '7300',
    );
    await tester.enterText(
      find.byKey(const ValueKey('proposta-entrada')),
      '20',
    );
    await tester.pump();
    expect(find.textContaining('Quatrocentos e oitenta e um mil'), findsOne);
    expect(find.textContaining('usa o total da proposta'), findsOneWidget);
    expect(find.textContaining('somar 100%'), findsOneWidget);
    expect(find.textContaining('Escolha o produto.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resultado e comparativo abrem a proposta', (tester) async {
    tela(tester, const Size(1194, 834));
    final estado = estadoExemplo()..etapa = RoiEstado.etapaResultado;
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: RoiPage(estado: estado),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Proposta'), findsOneWidget);

    await tester.tap(find.text('Comparar alternativas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gerar proposta'));
    await tester.pumpAndSettle();
    expect(find.text('Proposta comercial'), findsOneWidget);
    expect(find.text('Gerar PDF'), findsOneWidget);
  });
}
