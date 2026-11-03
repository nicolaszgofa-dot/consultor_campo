// Selenium Neo: docs/configurador/especificacao.md.
import 'package:configurador/configurador.dart';
import 'package:flutter_test/flutter_test.dart';

ResultadoConfiguracao neo(
  int linhas,
  List<int> secoes, {
  TipoPlantadeira tipo = TipoPlantadeira.autotransportavel,
  BocalNeo? bocal,
}) => RegrasConfigurador.configurar(
  EntradaConfiguracao(
    tecnologia: Tecnologia.seleniumNeo,
    tipo: tipo,
    totalLinhas: linhas,
    linhasPorSecao: secoes,
    bocalNeo: bocal,
  ),
);

void main() {
  test('conjunto dosador e esteira no lugar do conjunto e do sensor', () {
    final r = neo(12, [6, 6], bocal: BocalNeo.gravidade);
    expect(r.item('Conjunto dosador Selenium Neo')?.quantidade, 12);
    expect(r.item(Componentes.esteiraNeo)?.quantidade, 12);
    expect(r.item(Componentes.sensorSemente), isNull);
    expect(r.item(Componentes.condutorSelenium), isNull);
    expect(r.item(BocalNeo.gravidade.nome)?.quantidade, 12);
    // Mesmos chicotes do Selenium Elétric: por seção, de 4 e de 1 linha.
    expect(r.item(Componentes.chicote4)?.quantidade, 2);
    expect(r.item(Componentes.chicote1)?.quantidade, 4);
  });

  test('discos ficam pendentes com as 4 opções', () {
    final d = neo(8, [
      8,
    ], tipo: TipoPlantadeira.solteira).item(Componentes.discoNeo)!;
    expect(d.status, StatusItem.pendente);
    expect(d.quantidade, 8);
    for (final opcao in Componentes.discosNeo) {
      expect(d.pendencia, contains(opcao));
    }
  });

  test('bocal de pressão positiva vem no dosador: sem item, com aviso', () {
    final r = neo(8, [8], bocal: BocalNeo.pressaoPositiva);
    expect(r.item(BocalNeo.pressaoPositiva.nome), isNull);
    expect(r.item(Componentes.bocalNeo), isNull);
    expect(
      r.validacoes.map((v) => v.mensagem),
      contains(contains('pressão positiva já vem')),
    );
  });

  test('alternador sempre usado, mesmo na solteira pequena', () {
    expect(
      RegrasConfigurador.perguntarAlternador(
        6,
        TipoPlantadeira.solteira,
        Tecnologia.seleniumNeo,
      ),
      isFalse,
    );
    final r = neo(6, [6], tipo: TipoPlantadeira.solteira);
    expect(r.item(Componentes.alternador100)?.quantidade, 1);
    expect(r.item(Componentes.caboBateria), isNull);
  });

  test('5 linhas por saída: 22 linhas no alternador de 100 A', () {
    final r = neo(22, [22], tipo: TipoPlantadeira.solteira);
    expect(r.item(Componentes.alternador100), isNotNull);
    expect(r.item(Componentes.alternador250), isNull);
    final saidas = r.distribuicao!.saidas;
    expect(saidas, hasLength(5));
    expect(saidas.every((s) => s.linhas <= 5), isTrue);
  });

  test('acima de 22 linhas, alternador de 250 A até 55 linhas', () {
    final r = neo(23, [12, 11]);
    expect(r.item(Componentes.alternador250), isNotNull);
    expect(r.item(Componentes.alternador100), isNull);
    expect(r.bloqueada, isFalse);
    expect(r.distribuicao!.saidas.every((s) => s.linhas <= 5), isTrue);

    final r55 = neo(55, [19, 18, 18]);
    expect(r55.bloqueada, isFalse);
    expect(r55.distribuicao!.saidas, hasLength(lessThanOrEqualTo(11)));

    final r56 = neo(56, [19, 19, 18]);
    expect(r56.bloqueada, isTrue);
    expect(r56.validacoes.first.mensagem, contains('55 linhas'));
  });

  test('só as 4 adaptações John Deere e sem kit conversão', () {
    expect(adaptacoes[Tecnologia.seleniumNeo], {
      'John Deere': [
        'S-2100 linha chapa',
        'S-2100 linha fundida',
        'DB linha chapa',
        'DB linha fundida',
      ],
    });
    expect(Tecnologia.seleniumNeo.temKitConversao, isFalse);
    expect(Tecnologia.seleniumEletric.linhasPorSaida, 10);
  });

  test('Selenium Elétric continua com 10 linhas por saída', () {
    final r = RegrasConfigurador.configurar(
      const EntradaConfiguracao(
        tecnologia: Tecnologia.seleniumEletric,
        tipo: TipoPlantadeira.solteira,
        totalLinhas: 22,
        linhasPorSecao: [22],
      ),
    );
    expect(r.item(Componentes.alternador), isNotNull);
    expect(r.distribuicao!.saidas, hasLength(3));
  });
}
