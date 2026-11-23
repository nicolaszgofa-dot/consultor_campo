import 'package:consultor_campo/assistencia/assistencia_page.dart';
import 'package:consultor_campo/assistencia/chamado.dart';
import 'package:consultor_campo/funcionalidades.dart';
import 'package:consultor_campo/pecas/lista_pecas.dart';
import 'package:consultor_campo/pecas/pecas_dados.dart';
import 'package:consultor_campo/pecas/pecas_page.dart';
import 'package:consultor_campo/perfil.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sem PERFIL o app compilado é o da equipe', () {
    expect(perfil, Perfil.equipe);
    expect(nomeApp, 'JA Campo');
    expect(
      funcionalidades.map((f) => f.titulo),
      contains('Inteligência de mercado'),
    );
  });

  test('app da revenda: tira as funções internas e põe as dela', () {
    final titulos = funcionalidadesRevenda().map((f) => f.titulo).toList();
    for (final fora in const [
      'Inteligência de mercado',
      'Playbook',
      'Material técnico',
      'Relatórios',
    ]) {
      expect(titulos, isNot(contains(fora)), reason: fora);
    }
    expect(
      titulos,
      containsAll(const [
        'Avaliação de plantio',
        'Configurador',
        'ROI',
        'Proposta comercial',
        'Pedido de peças',
        'Assistência e garantia',
        'Regulagem e instalação',
        'Treinamento da revenda',
        'Conceito',
      ]),
    );
    // Regulagem e treinamento esperam o material técnico.
    final emBreve = funcionalidadesRevenda()
        .where((f) => f.emBreve)
        .map((f) => f.titulo);
    expect(emBreve, ['Regulagem e instalação', 'Treinamento da revenda']);
  });

  test('pedido de peças: cabeçalho da revenda e as peças', () {
    final l = ListaPecas(pedido: true);
    final c = produtosPecas.first.conjuntos.first;
    l
      ..adicionar(c.pecas[0], 'Selenium Elétric')
      ..adicionar(c.pecas[0], 'Selenium Elétric');
    final t = l.comoPedido(
      revenda: 'Revenda Exemplo',
      cidade: 'Rio Verde – GO',
      observacao: 'Urgente',
    );
    expect(t, startsWith('Pedido de peças de reposição J.Assy'));
    expect(t, contains('Revenda: Revenda Exemplo'));
    expect(t, contains('Total: 2 peças'));
    expect(t, contains('2x ${c.pecas[0].codigo}'));
    // A lista comum continua igual.
    expect(l.comoTexto(), startsWith('Peças de reposição J.Assy'));
  });

  test('chamado: obrigatórios e texto para o pós-venda', () {
    const vazio = Chamado(
      tipo: TipoChamado.garantia,
      revenda: '',
      contato: '',
      cliente: '',
      cidade: '',
      produto: '',
      problema: '',
    );
    expect(vazio.faltando, [
      'revenda',
      'contato',
      'cliente',
      'produto',
      'problema',
    ]);
    const c = Chamado(
      tipo: TipoChamado.garantia,
      revenda: 'Revenda Exemplo',
      contato: 'João, (64) 99999-0000',
      cliente: 'Fazenda Boa Vista',
      cidade: 'Rio Verde – GO',
      produto: 'Selenium Elétric',
      linhas: '3 de 24',
      problema: 'Motor não responde na linha 7.',
    );
    expect(c.completo, isTrue);
    final t = c.comoTexto();
    expect(t, startsWith('Chamado de garantia J.Assy'));
    expect(t, contains('Produto: Selenium Elétric'));
    expect(t, contains('Linhas com problema: 3 de 24'));
    expect(t, isNot(contains('Nº de série')));
  });

  testWidgets('pedido de peças abre com o título e o rodapé de pedido', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: const PecasPage(modoPedido: true),
      ),
    );
    expect(find.text('Pedido de peças'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'kit visor');
    await tester.pump();
    await tester.tap(find.byTooltip('Pôr na lista').first);
    await tester.pump();
    expect(find.text('1 peça no pedido'), findsOneWidget);
    expect(find.text('Ver pedido'), findsOneWidget);
  });

  testWidgets('assistência: aponta o que falta e copia quando completo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? copiado;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (chamada) async {
        if (chamada.method == 'Clipboard.setData') {
          copiado = (chamada.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(theme: temaConsultor(), home: const AssistenciaPage()),
    );
    await tester.tap(find.text('Copiar chamado'));
    await tester.pump();
    expect(find.textContaining('Falta preencher: revenda'), findsOneWidget);

    Future<void> preencher(String rotulo, String valor) =>
        tester.enterText(find.widgetWithText(TextField, rotulo), valor);
    await preencher('Revenda', 'Revenda Exemplo');
    await preencher('Contato (nome e telefone)', 'João');
    await preencher('Cliente (produtor ou fazenda)', 'Fazenda Boa Vista');
    await preencher('O que está acontecendo', 'Motor não responde.');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selenium Elétric').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copiar chamado'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Falta preencher'), findsNothing);
    expect(copiado, startsWith('Chamado de assistência técnica J.Assy'));
    expect(copiado, contains('Produto: Selenium Elétric'));
    expect(tester.takeException(), isNull);
  });
}
