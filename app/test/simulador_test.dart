import 'package:consultor_campo/funcionalidades.dart';
import 'package:consultor_campo/simulador/simulador_page.dart';
import 'package:consultor_campo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('abrir simulador chama o link; avisa se falhar', (tester) async {
    Uri? aberto;
    var resposta = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: temaConsultor(),
        home: SimuladorPage(
          abrirLink: (u) async {
            aberto = u;
            return resposta;
          },
        ),
      ),
    );
    await tester.tap(find.text('Abrir simulador'));
    await tester.pump();
    expect(aberto, simuladorEletric);
    expect(find.textContaining('Não foi possível'), findsNothing);

    resposta = false;
    await tester.tap(find.text('Abrir simulador'));
    await tester.pump();
    expect(find.textContaining('Não foi possível abrir'), findsOneWidget);
  });
}
