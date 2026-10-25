import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:consultor_campo/avaliacao/avaliacao_estado.dart';
import 'package:consultor_campo/avaliacao/linhas_page.dart';
import 'package:consultor_campo/em_breve_page.dart';
import 'package:consultor_campo/main.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tela alta o bastante para não precisar rolar nos testes.
void telaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

// 4 sementes/m → espaçamento ideal de 25 cm.
List<double> linhaPerfeita() => [for (var cm = 25.0; cm <= 1000; cm += 25) cm];

List<double> linhaComFalhas(int falhas) {
  final remover = {for (var i = 1; i <= falhas; i++) i * 100.0};
  return linhaPerfeita().where((cm) => !remover.contains(cm)).toList();
}

const identificacao = Identificacao(
  talhao: 'T-07',
  cultura: Cultura.soja,
  sementesPorMetro: 4,
  espacamentoLinhasM: 0.5,
  produtividadeScHa: 65,
  area: 500,
);

Future<void> abrirLinhas(WidgetTester tester, AvaliacaoEstado estado) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: temaConsultor(),
      home: LinhasPage(estado: estado),
    ),
  );
}

void main() {
  testWidgets('menu inicial com as oito funcionalidades', (tester) async {
    telaAlta(tester);
    await tester.pumpWidget(const ConsultorCampoApp());

    final titulos = [
      'Avaliação de plantio',
      'Configurador',
      'ROI',
      'Mercado',
      'Playbook',
      'Conceito',
      'Material técnico',
      'Relatórios',
    ];
    for (final t in titulos) {
      expect(find.text(t), findsOneWidget);
    }
    expect(find.text('EM BREVE'), findsNWidgets(5));
    // Nenhuma funcionalidade em destaque: todos os cartões do mesmo tamanho.
    final tamanhos = {
      for (final t in titulos)
        tester.getSize(
          find.ancestor(of: find.text(t), matching: find.byType(InkWell)).first,
        ),
    };
    expect(tamanhos, hasLength(1));
  });

  testWidgets('funcionalidade em breve abre a tela provisória', (tester) async {
    telaAlta(tester);
    await tester.pumpWidget(const ConsultorCampoApp());
    await tester.tap(find.text('Relatórios'));
    await tester.pumpAndSettle();
    expect(find.byType(EmBrevePage), findsOneWidget);
  });

  testWidgets('identificação leva às leituras da trena', (tester) async {
    telaAlta(tester);
    await tester.pumpWidget(const ConsultorCampoApp());
    await tester.tap(find.text('Avaliação de plantio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova avaliação de plantio'));
    await tester.pumpAndSettle();

    Future<void> preencher(String rotulo, String valor) =>
        tester.enterText(find.widgetWithText(TextFormField, rotulo), valor);
    await preencher('Talhão', 'T-07');
    await preencher('Sementes/m', '4');
    await preencher('Entre linhas (m)', '0,5');
    await preencher('sc/ha esperadas', '65');
    await preencher('Área', '500');
    await tester.pump();
    expect(find.text('25,0 cm'), findsOneWidget);
    expect(find.text('80.000 pl/ha'), findsOneWidget);

    await tester.tap(find.text('Começar leituras'));
    await tester.pumpAndSettle();
    expect(find.byType(LinhasPage), findsOneWidget);
    expect(find.text('0 de 5 linhas completas'), findsOneWidget);
    expect(find.text('Faltam 5 linhas'), findsOneWidget);

    final campo = find.widgetWithText(TextField, 'Leitura da trena (cm)');
    await tester.enterText(campo, '25');
    await tester.tap(find.text('Adicionar'));
    await tester.pump();
    expect(find.text('25,0'), findsOneWidget);

    await tester.enterText(campo, '20');
    await tester.tap(find.text('Adicionar'));
    await tester.pump();
    expect(find.text('A leitura deve ser maior que 25,0 cm.'), findsOneWidget);
  });

  testWidgets('identificação pede os valores obrigatórios', (tester) async {
    telaAlta(tester);
    await tester.pumpWidget(const ConsultorCampoApp());
    await tester.tap(find.text('Avaliação de plantio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova avaliação de plantio'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Entre linhas (m)'),
      '50',
    );
    await tester.tap(find.text('Começar leituras'));
    await tester.pump();
    expect(
      find.text('Parece centímetros. Use metros, ex.: 0,50'),
      findsOneWidget,
    );
    expect(find.byType(LinhasPage), findsNothing);
  });

  testWidgets('resultado bloqueado com menos de 5 linhas de 10 m', (
    tester,
  ) async {
    telaAlta(tester);
    final estado = AvaliacaoEstado(
      identificacao,
      linhas: [for (var i = 0; i < 4; i++) linhaPerfeita(), <double>[]],
    );
    await abrirLinhas(tester, estado);
    expect(find.text('4 de 5 linhas completas'), findsOneWidget);
    expect(find.text('Falta completar 1 linha'), findsOneWidget);
    expect(find.textContaining('Ver resultado'), findsNothing);
  });

  testWidgets('resultado e prejuízo com 5 linhas', (tester) async {
    telaAlta(tester);
    final estado = AvaliacaoEstado(
      identificacao,
      linhas: [for (var i = 0; i < 4; i++) linhaPerfeita(), linhaComFalhas(5)],
    );
    await abrirLinhas(tester, estado);
    await tester.tap(find.text('Ver resultado das 5 linhas'));
    await tester.pumpAndSettle();

    // 200 plantas esperadas, 5 faltando → 97,5% no lugar certo.
    expect(find.text('97,5%'), findsOneWidget);
    expect(find.textContaining('Linha 5 tem 400% mais falhas'), findsOneWidget);
    // Soja, médio: 0,74 × 2,5% = 1,85% de 65 sc/ha = 1,2 sc/ha.
    expect(find.text('1,2'), findsOneWidget);
    expect(find.text('sc/ha · 1,9%'), findsOneWidget);

    await tester.tap(find.text('Calcular prejuízo em R\$'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Informe o preço da saca'), findsOneWidget);

    Future<void> preencher(String rotulo, String valor) =>
        tester.enterText(find.widgetWithText(TextField, rotulo), valor);
    await preencher('Preço da saca (R\$)', '125');
    await preencher('Saco de semente (R\$)', '380');
    await preencher('Sementes por saco', '200000');
    await tester.pump();

    // 1,2025 sc/ha × R$ 125 × 500 ha; sem duplas, sem desperdício.
    expect(find.text('R\$ 150,31'), findsNWidgets(2));
    expect(find.text('R\$ 75.156'), findsOneWidget);
    expect(find.text('R\$ 0,00'), findsOneWidget);
  });
}
