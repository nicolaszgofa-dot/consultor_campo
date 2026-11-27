import 'package:consultor_campo/conceito/conceitos.dart';
import 'package:consultor_campo/tema.dart';
import 'package:consultor_campo/treinamento/treinamento_dados.dart';
import 'package:consultor_campo/treinamento/treinamento_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _rotulo(String texto) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == texto,
);

void main() {
  test('módulos com aulas e 4 perguntas válidas', () {
    expect(modulosTreino, hasLength(6));
    for (final m in modulosTreino) {
      expect(m.aulas, isNotEmpty, reason: m.titulo);
      expect(m.perguntas, hasLength(4), reason: m.titulo);
      for (final p in m.perguntas) {
        expect(p.opcoes.length, greaterThanOrEqualTo(2), reason: p.enunciado);
        expect(p.correta, inInclusiveRange(0, p.opcoes.length - 1));
        expect(p.opcoes.toSet(), hasLength(p.opcoes.length));
      }
    }
  });

  test('as imagens das aulas existem nos assets', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final imagens = [
      for (final m in modulosTreino)
        for (final a in m.aulas)
          for (final b in a.blocos)
            if (b is Imagem) b.asset,
    ];
    expect(imagens, isNotEmpty);
    for (final i in imagens) {
      final dados = await rootBundle.load(i);
      expect(dados.lengthInBytes, greaterThan(0), reason: i);
    }
  });

  test('tabela de alarmes vem do catálogo do simulador', () {
    final alarmes = modulosTreino.firstWhere((m) => m.titulo == 'Alarmes');
    final tabela = alarmes.aulas
        .firstWhere((a) => a.titulo == 'Os alarmes mais comuns')
        .blocos
        .whereType<Tabela>()
        .single;
    expect(
      tabela.linhas.first,
      contains('Linha XX - Fim de Sementes ou Entupimento'),
    );
    expect(tabela.linhas.every((l) => l[1].isNotEmpty), isTrue);
  });

  testWidgets('percorre as aulas, faz o teste e refaz', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const modulo = ModuloTreino(
      titulo: 'Módulo de teste',
      resumo: 'Resumo',
      icone: Icons.school,
      aulas: [
        Aula(titulo: 'Primeira aula', blocos: [Paragrafo('Texto 1')]),
        Aula(titulo: 'Segunda aula', blocos: [Paragrafo('Texto 2')]),
      ],
      perguntas: [
        Pergunta(
          enunciado: 'Quanto é 1 + 1?',
          opcoes: ['2', '3'],
          correta: 0,
          explicacao: 'Soma simples.',
        ),
        Pergunta(
          enunciado: 'Cor do LED plantando?',
          opcoes: ['Vermelho', 'Verde rápido'],
          correta: 1,
          explicacao: 'Verde piscando rápido.',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: CapacitacaoPage(modulos: const [modulo]),
      ),
    );
    expect(find.text('2 aulas · 2 perguntas'), findsOneWidget);
    await tester.tap(_rotulo('Módulo de teste'));
    await tester.pumpAndSettle();

    expect(find.text('Primeira aula'), findsOneWidget);
    expect(find.text('PASSO 1 DE 3'), findsOneWidget);
    await tester.tap(find.text('Próxima aula'));
    await tester.pumpAndSettle();
    expect(find.text('Segunda aula'), findsOneWidget);
    await tester.tap(find.text('Fazer o teste'));
    await tester.pumpAndSettle();
    expect(find.text('PASSO 3 DE 3'), findsOneWidget);

    // Uma certa e uma errada.
    await tester.tap(_rotulo('2'));
    await tester.tap(_rotulo('Vermelho'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Soma simples', findRichText: true), findsOne);
    expect(find.text('1 de 2 certas'), findsOneWidget);

    // Resposta travada: tocar de novo não muda nada.
    await tester.tap(_rotulo('Verde rápido'));
    await tester.pumpAndSettle();
    expect(find.text('1 de 2 certas'), findsOneWidget);

    await tester.tap(find.text('Refazer o teste'));
    await tester.pumpAndSettle();
    expect(find.textContaining('certas'), findsNothing);
    await tester.tap(_rotulo('2'));
    await tester.tap(_rotulo('Verde rápido'));
    await tester.pumpAndSettle();
    expect(find.text('2 de 2 certas'), findsOneWidget);
    expect(find.text('Módulo concluído.'), findsOneWidget);

    await tester.tap(find.text('Concluir'));
    await tester.pumpAndSettle();
    expect(find.text('Capacitação'), findsOneWidget);
  });

  testWidgets('as aulas reais abrem sem erro de layout', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final m in modulosTreino) {
      await tester.pumpWidget(
        MaterialApp(
          theme: temaConsultor(),
          home: ModuloPage(key: ValueKey(m.titulo), modulo: m),
        ),
      );
      for (var i = 0; i < m.aulas.length; i++) {
        await tester.pumpAndSettle();
        expect(find.text(m.aulas[i].titulo), findsWidgets);
        await tester.tap(
          find.text(i == m.aulas.length - 1 ? 'Fazer o teste' : 'Próxima aula'),
        );
      }
      await tester.pumpAndSettle();
      expect(find.text('Teste do módulo'.toUpperCase()), findsOneWidget);
      expect(tester.takeException(), isNull, reason: m.titulo);
    }
  });
}
