import 'package:consultor_campo/desligamento/desligamento_dados.dart';
import 'package:consultor_campo/desligamento/desligamento_page.dart';
import 'package:consultor_campo/simulador/referencias_terminal.dart';
import 'package:consultor_campo/tema.dart';
import 'package:consultor_campo/treinamento/treinamento_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _rotulo(String texto) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == texto,
);

void main() {
  test('cada monitor compatível tem o seu ajuste', () {
    expect(
      ajustesMonitores.map((a) => a.modelo),
      monitoresCompativeis.map((m) => m.modelo),
    );
    for (final a in ajustesMonitores) {
      expect(a.passos, isNotEmpty, reason: a.modelo);
      expect(a.compatibilidade.modelo, a.modelo);
    }
    // Só o que foi conferido no manual do fabricante leva o selo.
    expect(ajustesMonitores.where((a) => a.confirmado).map((a) => a.modelo), [
      'GS4',
    ]);
  });

  group('ajuste no campo', () {
    test('o que fica no chão em cada caso', () {
      expect(Ocorrencia.desligouAntes.deixaFalha, isTrue);
      expect(Ocorrencia.desligouDepois.deixaFalha, isFalse);
      expect(Ocorrencia.ligouAntes.deixaFalha, isFalse);
      expect(Ocorrencia.ligouDepois.deixaFalha, isTrue);
    });

    test('tempo = distância ÷ velocidade, com o sentido certo', () {
      // 1 m a 7,2 km/h (2 m/s) = 0,5 s.
      final atrasou = CorrecaoTempo.calcular(
        ocorrencia: Ocorrencia.desligouDepois,
        distanciaM: 1,
        velocidadeKmh: 7.2,
      )!;
      expect(atrasou.segundos, closeTo(0.5, 1e-9));
      expect(atrasou.aumentar, isTrue);
      expect(atrasou.qualTempo, 'desligar');
      expect(atrasou.novoValor(0.3), closeTo(0.8, 1e-9));

      final adiantou = CorrecaoTempo.calcular(
        ocorrencia: Ocorrencia.ligouAntes,
        distanciaM: 1,
        velocidadeKmh: 7.2,
      )!;
      expect(adiantou.aumentar, isFalse);
      expect(adiantou.qualTempo, 'ligar');
      expect(adiantou.novoValor(0.8), closeTo(0.3, 1e-9));
      // Nunca fica negativo.
      expect(adiantou.novoValor(0.2), 0);
      expect(adiantou.novoValor(null), isNull);
    });

    test('sem dado completo não calcula', () {
      expect(
        CorrecaoTempo.calcular(
          ocorrencia: null,
          distanciaM: 1,
          velocidadeKmh: 7,
        ),
        isNull,
      );
      expect(
        CorrecaoTempo.calcular(
          ocorrencia: Ocorrencia.ligouDepois,
          distanciaM: 1,
          velocidadeKmh: 0,
        ),
        isNull,
      );
    });
  });

  group('geometria', () {
    const base = GeometriaPlantadeira(
      linhas: 6,
      espacamentoM: 0.5,
      engateRodaM: 3.2,
      rodaSaidaCurtaM: 1.1,
    );

    test('encontradas: completa, largura e nenhuma longa', () {
      expect(base.completa, isTrue);
      expect(base.larguraM, 3);
      expect(base.quantidadeLongas, 0);
      expect(base.avisos, isEmpty);
    });

    test('desencontradas alternam a partir da primeira linha', () {
      final d = base.copiar(
        tipo: TipoLinhas.desencontradas,
        rodaSaidaLongaM: 1.7,
      );
      expect(
        [for (var i = 0; i < 6; i++) d.ehLonga(i)],
        [false, true, false, true, false, true],
      );
      final d1 = d.copiar(primeiraLonga: true);
      expect(d1.ehLonga(0), isTrue);
      expect(d1.quantidadeLongas, 3);
    });

    test('falta e avisos', () {
      final d = base.copiar(tipo: TipoLinhas.desencontradas);
      expect(d.faltando, ['rodas até a saída longa']);
      final invertida = d.copiar(rodaSaidaLongaM: 0.9);
      expect(
        invertida.avisos,
        contains('A saída longa deve ficar mais longe das rodas que a curta.'),
      );
      expect(
        base.copiar(espacamentoM: 50).avisos.single,
        contains('em metros'),
      );
      final p = base.copiar(
        tipo: TipoLinhas.personalizadas,
        rodaSaidaLongaM: 2,
      );
      expect(p.avisos.single, contains('marque no desenho'));
      expect(p.copiar(longas: {1, 4}).quantidadeLongas, 2);
    });
  });

  testWidgets('três abas: monitor, geometria e ajuste', (tester) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: temaConsultor(), home: const DesligamentoPage()),
    );

    // Monitor.
    await tester.tap(find.text('John Deere GS4'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Retardo mecânico'), findsWidgets);
    expect(find.text('Conferido no manual do fabricante'), findsOneWidget);
    await tester.tap(find.text('Hexagon Ti7 e Ti10'));
    await tester.pumpAndSettle();
    expect(find.text('Confira no manual do monitor'), findsOneWidget);

    // Geometria.
    await tester.tap(find.text('Geometria'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Falta:'), findsOneWidget);
    Future<void> campo(String rotulo, String v) =>
        tester.enterText(find.widgetWithText(TextField, rotulo), v);
    await campo('Nº de linhas', '12');
    await campo('Entre linhas (m)', '0,5');
    await campo('Engate até as rodas (m)', '3,2');
    await campo('Rodas até saída (m)', '1,1');
    await tester.pump();
    expect(find.text('Para digitar no terminal'), findsOneWidget);
    expect(find.text('Largura de trabalho: 6,00 m'), findsOneWidget);

    // Ajuste no campo.
    await tester.tap(find.text('No campo'));
    await tester.pumpAndSettle();
    await tester.tap(_rotulo('Desligou depois'));
    await campo('Medido no chão (m)', '1');
    await campo('Velocidade (km/h)', '7,2');
    await campo('Tempo atual no monitor (s), opcional', '0,3');
    await tester.pump();
    expect(find.text('Aumente o tempo de desligar'), findsOneWidget);
    expect(find.text('+ 0,50 s'), findsOneWidget);
    expect(find.text('De 0,30 s para 0,80 s'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('o Material técnico abre a ferramenta', (tester) async {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: temaConsultor(), home: TreinamentoPage()),
    );
    await tester.tap(_rotulo('Desligamento de linha'));
    await tester.pumpAndSettle();
    expect(find.byType(DesligamentoPage), findsOneWidget);
  });
}
