import 'dart:convert';

import 'package:consultor_campo/proposta/proposta_estado.dart';
import 'package:consultor_campo/proposta/proposta_fluxo_page.dart';
import 'package:consultor_campo/proposta/propostas_page.dart';
import 'package:consultor_campo/roi/proposta/proposta_dados.dart';
import 'package:consultor_campo/roi/proposta/proposta_pdf.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'proposta_test.dart' show dadosExemplo;
import 'roi_test.dart' show estadoExemplo, exemplo, tela;

const _itens = [
  ItemProposta(
    produto: ProdutoProposta.titanium,
    fornecimento: Fornecimento.completo,
    plantadeira: 'Tatu PST',
    linhas: 17,
    valorLinha: 8500,
    valorCampanha: 6500,
  ),
  ItemProposta(
    produto: ProdutoProposta.neo,
    fornecimento: Fornecimento.completo,
    plantadeira: 'Stara Absoluta',
    linhas: 12,
    valorLinha: 11900,
  ),
];

int _paginas(List<int> bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length;

Future<void> _abrir(WidgetTester tester, Widget tela0) async {
  await tester.pumpWidget(MaterialApp(theme: temaConsultor(), home: tela0));
  await tester.pumpAndSettle();
}

Future<void> _digitar(WidgetTester tester, String rotulo, String texto) async {
  await tester.enterText(find.widgetWithText(TextField, rotulo), texto);
  await tester.pump();
}

void main() {
  testesNovosProdutos();

  test('vários itens, campanha e economia', () {
    final d = dadosExemplo(itens: _itens);
    expect(d.total, 17 * 6500 + 12 * 11900);
    expect(d.totalTabela, 17 * 8500 + 12 * 11900);
    expect(d.economia, 17 * 2000);
    expect(d.linhas, 29);
    expect(d.produtoUnico, isNull);
    expect(dadosExemplo().produtoUnico, ProdutoProposta.titanium);
  });

  test('o ROI da proposta usa o total e as linhas dos itens', () {
    final e = PropostaEstado()
      ..adicionar(ProdutoProposta.selenium)
      ..mudarItem(0, (i) {
        i.plantadeira = 'Tatu PST';
        i.linhas = '66';
        i.valorLinha = '7.300';
      });
    expect(e.pendenciasRoi, hasLength(2));
    e.prepararRoi();
    exemplo.forEach((k, v) {
      if (k != 'inv' && k != 'linhas') e.roi.mudar(k, v);
    });
    expect(e.pendenciasRoi, isEmpty);
    expect(e.roi.texto('inv'), '481.800,00');
    expect(e.premissasRoi.investimento, 481800);
    expect(e.premissasRoi.linhas, 66);
    e.dispose();
  });

  testWidgets('PDF com vários itens, com e sem o retorno', (tester) async {
    await tester.runAsync(() async {
      final recursos = await RecursosPdf.carregar();
      final semRetorno = await gerarPropostaPdf(
        dados: dadosExemplo(itens: _itens),
        recursos: recursos,
      );
      expect(_paginas(semRetorno), inInclusiveRange(2, 4));
      final comRetorno = await gerarPropostaPdf(
        dados: dadosExemplo(itens: _itens),
        premissas: estadoExemplo().premissas,
        recursos: recursos,
      );
      expect(_paginas(comRetorno), greaterThan(_paginas(semRetorno)));
      final soCapa = await gerarPropostaPdf(
        dados: DadosProposta(
          itens: _itens,
          paginasProdutos: false,
          cliente: 'Fazenda Santa Rita',
          cidade: 'Caldas Novas',
          data: DateTime(2026, 10, 28),
          consultor: 'Ana Souza',
        ),
        recursos: recursos,
      );
      expect(_paginas(soCapa), lessThanOrEqualTo(_paginas(semRetorno)));
    });
  });

  testWidgets('histórico só em conceito, sem nada salvo', (tester) async {
    tela(tester, const Size(1194, 1400));
    await _abrir(tester, const PropostasPage());
    expect(find.textContaining('nada é registrado nem salvo'), findsOneWidget);
    expect(find.textContaining('EXEMPLO'), findsWidgets);
    expect(find.text('Nova proposta'), findsOneWidget);
  });

  testWidgets('fluxo: cliente, itens com campanha e condições', (tester) async {
    tela(tester, const Size(1194, 2400));
    final e = PropostaEstado();
    addTearDown(e.dispose);
    await _abrir(tester, PropostaFluxoPage(estado: e));

    expect(find.text('Informe o cliente.'), findsOneWidget);
    await _digitar(tester, 'Nome do cliente ou fazenda', 'Fazenda Santa Rita');
    await _digitar(tester, 'Cidade da proposta', 'Caldas Novas');
    await _digitar(tester, 'Consultor', 'Ana Souza');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(e.etapa, 1);
    expect(find.text('Adicione pelo menos um produto.'), findsOneWidget);

    await tester.tap(find.text('Titanium Elétric'));
    await tester.pumpAndSettle();
    expect(find.text('Só motorização'), findsOneWidget);
    await _digitar(tester, 'Plantadeira', 'Tatu PST');
    await _digitar(tester, 'Linhas', '17');
    await _digitar(tester, 'Valor por linha (tabela)', '8500');
    await _digitar(tester, 'Valor de campanha (opcional)', '6500');
    expect(find.textContaining('Condição especial: R\$ 110.500,00'), findsOne);
    expect(find.text('R\$ 34.000'), findsOneWidget); // economia
    expect(e.bloqueio, isNull);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await _digitar(tester, 'Entrada', '20');
    expect(find.textContaining('somar 100%'), findsOneWidget);
    await tester.tap(find.text('Adicionar parcela'));
    await tester.pumpAndSettle();
    await _digitar(tester, '1ª parcela', '80');
    expect(e.bloqueio, isNull);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retorno do investimento'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Informe a área plantada no ROI.'),
      findsWidgets,
    );
    expect(find.text('Preencher o ROI'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sair pergunta antes de descartar', (tester) async {
    tela(tester, const Size(1194, 1400));
    await _abrir(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PropostaFluxoPage(),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await _digitar(tester, 'Nome do cliente ou fazenda', 'Fazenda Santa Rita');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Descartar esta proposta?'), findsOneWidget);
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget);
  });
}

void testesNovosProdutos() {
  test('Commander é por seção e não conta como linha de plantio', () {
    expect(ProdutoProposta.commander.porLinha, isFalse);
    expect(ProdutoProposta.commander.unidades, 'seções');
    final d = dadosExemplo(
      itens: const [
        ItemProposta(
          produto: ProdutoProposta.titanium,
          fornecimento: Fornecimento.completo,
          plantadeira: 'Tatu PST',
          linhas: 17,
          valorLinha: 6500,
        ),
        ItemProposta(
          produto: ProdutoProposta.jupiter,
          fornecimento: Fornecimento.completo,
          plantadeira: 'Tatu PST',
          linhas: 17,
          valorLinha: 1500,
        ),
        ItemProposta(
          produto: ProdutoProposta.commander,
          fornecimento: Fornecimento.completo,
          plantadeira: 'Tatu PST',
          linhas: 4,
          valorLinha: 9000,
        ),
        ItemProposta(
          produto: ProdutoProposta.selenium,
          fornecimento: Fornecimento.completo,
          plantadeira: 'Stara Absoluta',
          linhas: 12,
          valorLinha: 7300,
        ),
      ],
    );
    // Titanium e Júpiter na mesma Tatu não somam duas vezes.
    expect(d.linhas, 17 + 12);
    expect(d.total, 17 * 6500 + 17 * 1500 + 4 * 9000 + 12 * 7300);
  });

  testWidgets('PDF com Júpiter, Level e Commander', (tester) async {
    await tester.runAsync(() async {
      final recursos = await RecursosPdf.carregar();
      expect(
        recursos.imagens.keys,
        containsAll([
          ProdutoProposta.jupiter,
          ProdutoProposta.level,
          ProdutoProposta.commander,
        ]),
      );
      for (final produto in [
        ProdutoProposta.jupiter,
        ProdutoProposta.level,
        ProdutoProposta.commander,
      ]) {
        final bytes = await gerarPropostaPdf(
          dados: dadosExemplo(produto: produto),
          recursos: recursos,
        );
        expect(_paginas(bytes), inInclusiveRange(2, 3), reason: produto.nome);
      }
    });
  });
}
