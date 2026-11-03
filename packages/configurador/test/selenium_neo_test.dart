// Selenium Neo: docs/configurador/especificacao.md.
import 'package:configurador/configurador.dart';
import 'package:flutter_test/flutter_test.dart';

ResultadoConfiguracao neo(
  int linhas,
  List<int> secoes, {
  TipoPlantadeira tipo = TipoPlantadeira.autotransportavel,
  BocalNeo? bocal,
  bool? agregado,
  Adaptacao? adaptacao,
  int? caixas,
}) => RegrasConfigurador.configurar(
  EntradaConfiguracao(
    tecnologia: Tecnologia.seleniumNeo,
    tipo: tipo,
    totalLinhas: linhas,
    linhasPorSecao: secoes,
    bocalNeo: bocal,
    neoComLevelOuCommander: agregado,
    adaptacao: adaptacao,
    caixasSemente: caixas,
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

  test('sem velocidade e população os discos ficam pendentes', () {
    final r = neo(8, [8], tipo: TipoPlantadeira.solteira);
    for (final c in CulturaNeo.values) {
      final d = r.item(Componentes.discoNeo(c))!;
      expect(d.status, StatusItem.pendente);
      expect(d.quantidade, 8);
    }
    // Solteira sem adaptação: não leva peneira de soja.
    expect(r.item(Componentes.peneiraSojaNeo), isNull);
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

  test('acima de 22 linhas, alternador de 250 A até 56 linhas', () {
    final r = neo(23, [12, 11]);
    expect(r.item(Componentes.alternador250), isNotNull);
    expect(r.item(Componentes.alternador100), isNull);
    expect(r.bloqueada, isFalse);
    expect(r.distribuicao!.saidas.every((s) => s.linhas <= 5), isTrue);

    final r56 = neo(56, [19, 19, 18]);
    expect(r56.bloqueada, isFalse);
    expect(r56.distribuicao!.saidas, hasLength(lessThanOrEqualTo(12)));
    expect(
      RegrasConfigurador.limiteDoAlternador(r56.entrada),
      RegrasConfigurador.linhasMaximasNeo,
    );

    final r57 = neo(57, [19, 19, 19]);
    expect(r57.bloqueada, isTrue);
    expect(r57.validacoes.first.mensagem, contains('56 linhas'));
  });

  test('com Level ou Commander no alternador de 250 A: até 38 linhas', () {
    expect(
      RegrasConfigurador.perguntarAgregadoNeo(neo(22, [22]).entrada),
      isFalse,
    );
    expect(
      RegrasConfigurador.perguntarAgregadoNeo(neo(23, [12, 11]).entrada),
      isTrue,
    );
    final r38 = neo(38, [19, 19], agregado: true);
    expect(r38.bloqueada, isFalse);
    expect(RegrasConfigurador.limiteDoAlternador(r38.entrada), 38);
    final r39 = neo(39, [20, 19], agregado: true);
    expect(r39.bloqueada, isTrue);
    expect(
      r39.validacoes.map((v) => v.mensagem),
      contains(contains('até 38 linhas')),
    );
    expect(neo(39, [20, 19], agregado: false).bloqueada, isFalse);
  });

  test('peneira de soja só na S-2100 caixa central, uma por caixa', () {
    const s2100 = Adaptacao('John Deere', 'S-2100 linha chapa');
    const db = Adaptacao('John Deere', 'DB linha chapa');
    final caixa = TipoPlantadeira.caixaCentral;

    final semCaixas = neo(
      24,
      [12, 12],
      tipo: caixa,
      adaptacao: s2100,
    ).item(Componentes.peneiraSojaNeo)!;
    expect(semCaixas.status, StatusItem.pendente);
    expect(semCaixas.pendencia, contains('caixas de semente'));

    final duas = neo(
      24,
      [12, 12],
      tipo: caixa,
      adaptacao: s2100,
      caixas: 2,
    ).item(Componentes.peneiraSojaNeo)!;
    expect(duas.quantidade, 2);
    expect(duas.status, StatusItem.definido);

    expect(
      neo(
        24,
        [12, 12],
        tipo: caixa,
        adaptacao: db,
      ).item(Componentes.peneiraSojaNeo),
      isNull,
    );
    expect(
      neo(24, [12, 12], adaptacao: s2100).item(Componentes.peneiraSojaNeo),
      isNull,
    );
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
