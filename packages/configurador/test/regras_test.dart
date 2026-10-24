// Casos de docs/configurador/especificacao.md.
import 'package:configurador/configurador.dart';
import 'package:flutter_test/flutter_test.dart';

ResultadoConfiguracao configurar(
  int linhas,
  List<int> secoes, {
  bool? alternador,
  Tecnologia tecnologia = Tecnologia.titaniumEletric,
  TipoPlantadeira tipo = TipoPlantadeira.autotransportavel,
  int? isobus,
  int? mangueiras,
  Map<int, int>? painel,
  bool? naFrente,
  bool? pipoqueira,
  BocalTitanium? bocalTitanium,
  BocalSelenium? bocalSelenium,
}) => RegrasConfigurador.configurar(
  EntradaConfiguracao(
    tecnologia: tecnologia,
    tipo: tipo,
    totalLinhas: linhas,
    linhasPorSecao: secoes,
    temAlternador: alternador,
    alternadorNaFrente: naFrente,
    comprimentoIsobus: isobus,
    comprimentoMangueiras: mangueiras,
    chicotesPainel: painel,
    reservatorioPipoqueira: pipoqueira,
    bocalTitanium: bocalTitanium,
    bocalSelenium: bocalSelenium,
  ),
);

/// Itens próprios de cada tecnologia (discos, reservatório, bocais).
const itensDaTecnologia = {
  Componentes.discoMilhoTitanium,
  Componentes.discoSojaTitanium,
  Componentes.reservatorioPipoqueira,
  Componentes.bocalPipoqueira,
  Componentes.discoSojaSelenium,
  Componentes.discoMilhoSelenium,
  Componentes.bocalSelenium,
  Componentes.condutorSelenium,
};

int? qtd(ResultadoConfiguracao r, String componente) =>
    r.item(componente)?.quantidade;

List<(int, int)> faixas(DistribuicaoSaidas d) => [
  for (final s in d.saidas) (s.primeiraLinha, s.ultimaLinha),
];

void main() {
  testesKitConversao();
  testesAdaptacao();
  testesCondutorSelenium();
  testesSfil();
  test('8 linhas sem alternador: itens obrigatórios e cabo da bateria', () {
    final r = configurar(
      8,
      const [],
      alternador: false,
      tipo: TipoPlantadeira.solteira,
    );
    expect(r.bloqueada, isFalse);
    expect(r.item(Componentes.ecu)!.quantidade, 1);
    expect(r.item(Componentes.sensorLevante)!.quantidade, 1);
    expect(r.item(Componentes.sensorSemente)!.quantidade, 8);
    expect(r.item(Componentes.caboIsobus)!.status, StatusItem.pendente);
    expect(r.item(Componentes.caboBateria)!.quantidade, 1);
    expect(r.item(Componentes.alternador), isNull);
    expect(r.distribuicao, isNull);
  });

  test('regras pendentes nunca aparecem como definidas', () {
    final r = configurar(
      8,
      const [],
      alternador: false,
      tipo: TipoPlantadeira.solteira,
    );
    expect(
      r.pendentes.map((i) => i.componente),
      contains(Componentes.caboIsobus),
    );
    for (final p in r.pendentes) {
      expect(p.pendencia, isNotNull);
    }
  });

  test('um conjunto da tecnologia por linha', () {
    expect(
      qtd(
        configurar(
          8,
          const [],
          alternador: false,
          tipo: TipoPlantadeira.solteira,
        ),
        'Conjunto Titanium Elétric',
      ),
      8,
    );
    final s = configurar(
      8,
      const [],
      alternador: false,
      tipo: TipoPlantadeira.solteira,
      tecnologia: Tecnologia.seleniumEletric,
    );
    expect(qtd(s, 'Conjunto Selenium Elétric'), 8);
  });

  test('chicotes de uma seção: 17 = 4 de 4 + 1 de 1; 11 = 2 de 4 + 3 de 1', () {
    expect(RegrasConfigurador.chicotesDaSecao(17), (quatro: 4, um: 1));
    expect(RegrasConfigurador.chicotesDaSecao(11), (quatro: 2, um: 3));
  });

  test('45 linhas (17 + 17 + 11): 10 chicotes de 4 e 5 de 1', () {
    final r = configurar(45, [17, 17, 11]);
    expect(qtd(r, Componentes.chicote4), 10);
    expect(qtd(r, Componentes.chicote1), 5);
  });

  test('chicotes são calculados por seção, não pelo total da máquina', () {
    // Pelo total seriam 11 de 4 + 1 de 1: errado para uma máquina que fecha.
    final r = configurar(45, [17, 17, 11]);
    final total = RegrasConfigurador.chicotesDaSecao(45);
    expect(total, (quatro: 11, um: 1));
    expect(qtd(r, Componentes.chicote4), isNot(total.quatro));
  });

  test('os chicotes cobrem todas as linhas', () {
    for (var n = 1; n <= 60; n++) {
      final r = configurar(
        n,
        const [],
        alternador: true,
        tipo: TipoPlantadeira.solteira,
      );
      final linhas =
          4 * (qtd(r, Componentes.chicote4) ?? 0) +
          (qtd(r, Componentes.chicote1) ?? 0);
      expect(linhas, n, reason: '$n');
    }
  });

  test('30 linhas (10 + 10 + 10): 3 chicotes painel, 6 de 4 e 6 de 1', () {
    final r = configurar(30, [10, 10, 10]);
    expect(r.item(Componentes.chicotePainel)!.quantidadeRecomendada, 3);
    expect(qtd(r, Componentes.chicote4), 6);
    expect(qtd(r, Componentes.chicote1), 6);
  });

  test('45 linhas (17 + 17 + 11): chicote painel recomendado = 6 saídas', () {
    final p = configurar(45, [17, 17, 11]).item(Componentes.chicotePainel)!;
    expect(p.quantidadeRecomendada, 6);
    // Nada é escolhido sozinho: o vendedor decide os tamanhos.
    expect(p.quantidade, 0);
    expect(p.status, StatusItem.pendente);
    expect(p.pendencia, contains('Recomendado: 6'));
  });

  test('55 linhas: chicote painel por saída e a cada troca de seção', () {
    final r = configurar(55, [21, 21, 13]);
    expect(r.distribuicao!.trechos, [10, 9, 2, 7, 9, 5, 4, 9]);
    final p = r.item(Componentes.chicotePainel)!;
    expect(p.quantidadeRecomendada, 8);
    expect(p.motivo, contains('6 saídas usadas + 2 trocas de seção'));
    expect(qtd(r, Componentes.chicote4), 13);
    expect(qtd(r, Componentes.chicote1), 3);
  });

  test('chicote painel: quantidade de cada comprimento', () {
    final r = configurar(55, [21, 21, 13], painel: {4: 3, 9: 4, 14: 1});
    final p = r.item(Componentes.chicotePainel)!;
    expect(p.quantidadesPorComprimento, {4: 3, 9: 4, 14: 1});
    expect(p.quantidade, 8);
    expect(p.status, StatusItem.definido);
    expect(r.validacoes.where((v) => v.mensagem.contains('Chicote')), isEmpty);
  });

  test('chicote painel diferente da recomendação gera aviso', () {
    final r = configurar(55, [21, 21, 13], painel: {9: 7, 14: 0});
    final p = r.item(Componentes.chicotePainel)!;
    expect(p.quantidadesPorComprimento, {9: 7});
    expect(p.quantidade, 7);
    expect(r.bloqueada, isFalse);
    expect(
      r.validacoes.map((v) => v.mensagem),
      contains('Chicote painel: 7 escolhidos, recomendado 8.'),
    );
  });

  test('chicote painel com tamanho inexistente ou negativo bloqueia', () {
    expect(configurar(30, [10, 10, 10], painel: {5: 1}).bloqueada, isTrue);
    expect(configurar(30, [10, 10, 10], painel: {4: -1}).bloqueada, isTrue);
  });

  test('sem alternador: cabo da bateria obrigatório, chicotes por seção', () {
    final r = configurar(
      8,
      const [],
      alternador: false,
      tipo: TipoPlantadeira.solteira,
    );
    expect(r.item(Componentes.caboBateria)!.motivo, contains('Obrigatório'));
    expect(qtd(r, Componentes.chicote4), 2);
    expect(r.item(Componentes.chicote1), isNull);
    expect(r.item(Componentes.mangueiras), isNull);
    final p = r.item(Componentes.chicotePainel)!;
    expect(p.quantidade, 2);
    expect(p.quantidadesPorComprimento, {4: 2});
    expect(p.status, StatusItem.definido);
    expect(p.motivo, contains('Obrigatório'));
  });

  test('sem alternador: 2 chicotes painel de 4 m, ajustáveis', () {
    final r = configurar(
      12,
      const [],
      alternador: false,
      tipo: TipoPlantadeira.solteira,
    );
    expect(qtd(r, Componentes.chicotePainel), 2);
    final ajustado = configurar(
      12,
      const [],
      alternador: false,
      tipo: TipoPlantadeira.solteira,
      painel: {4: 1, 9: 1},
    );
    expect(
      ajustado.item(Componentes.chicotePainel)!.quantidadesPorComprimento,
      {4: 1, 9: 1},
    );
  });

  (int?, int?) sugestao(ResultadoConfiguracao r) => (
    r.item(Componentes.caboIsobus)!.comprimentoSugerido,
    r.item(Componentes.mangueiras)?.comprimentoSugerido,
  );

  test('sugestão de ISOBUS e mangueiras por tipo de máquina', () {
    expect(sugestao(configurar(30, const [], tipo: TipoPlantadeira.solteira)), (
      5,
      6,
    ));
    expect(
      sugestao(
        configurar(30, [10, 10, 10], tipo: TipoPlantadeira.caixaCentral),
      ),
      (17, 15),
    );
    for (final tipo in [
      TipoPlantadeira.autotransportavel,
      TipoPlantadeira.tandem,
    ]) {
      expect(
        sugestao(configurar(30, [10, 10, 10], tipo: tipo, naFrente: true)),
        (5, 6),
        reason: tipo.nome,
      );
      expect(
        sugestao(configurar(30, [10, 10, 10], tipo: tipo, naFrente: false)),
        (11, 12),
        reason: tipo.nome,
      );
    }
  });

  test('autotransportável e tandem perguntam onde fica o alternador', () {
    final a = configurar(30, [10, 10, 10]);
    expect(
      RegrasConfigurador.perguntaAlternadorNaFrente(a.entrada),
      'A máquina permite instalar o alternador no cabeçalho?',
    );
    expect(sugestao(a), (null, null));
    expect(a.item(Componentes.caboIsobus)!.pendencia, contains('cabeçalho'));
    final t = configurar(30, [10, 10, 10], tipo: TipoPlantadeira.tandem);
    expect(
      RegrasConfigurador.perguntaAlternadorNaFrente(t.entrada),
      'A máquina permite instalar o alternador no tandem?',
    );
    final c = configurar(30, [10, 10, 10], tipo: TipoPlantadeira.caixaCentral);
    expect(RegrasConfigurador.perguntaAlternadorNaFrente(c.entrada), isNull);
  });

  test('sugestão não define o item e sempre pede para confirmar a máquina', () {
    final r = configurar(30, [10, 10, 10], naFrente: true);
    final isobus = r.item(Componentes.caboIsobus)!;
    expect(isobus.status, StatusItem.pendente);
    expect(isobus.comprimento, isNull);
    expect(isobus.pendencia, contains('Sugerido: 5 m'));
    expect(isobus.observacao, contains('confirmar as características'));
    final escolhido = configurar(30, [10, 10, 10], naFrente: true, isobus: 5);
    final definido = escolhido.item(Componentes.caboIsobus)!;
    expect(definido.status, StatusItem.definido);
    expect(definido.observacao, contains('confirmar as características'));
  });

  test('comprimentos ficam pendentes até o vendedor escolher', () {
    final r = configurar(30, [10, 10, 10]);
    for (final c in [
      Componentes.caboIsobus,
      Componentes.chicotePainel,
      Componentes.mangueiras,
    ]) {
      final i = r.item(c)!;
      expect(i.status, StatusItem.pendente, reason: c);
      expect(i.comprimento, isNull, reason: c);
      expect(i.quantidadesPorComprimento, isEmpty, reason: c);
      expect(i.opcoesComprimento, isNotEmpty, reason: c);
    }
    expect(
      r.item(Componentes.caboIsobus)!.pendencia,
      contains('5, 11, 14 ou 17 m'),
    );
  });

  test('comprimentos escolhidos ficam definidos', () {
    final r = configurar(
      30,
      [10, 10, 10],
      isobus: 11,
      painel: {9: 3},
      mangueiras: 12,
      pipoqueira: false,
    );
    expect(r.pendentes, isEmpty);
    expect(r.item(Componentes.caboIsobus)!.comprimento, 11);
    expect(r.item(Componentes.mangueiras)!.comprimento, 12);
  });

  test('comprimento que não existe bloqueia', () {
    final r = configurar(30, [10, 10, 10], isobus: 10);
    expect(r.bloqueada, isTrue);
    expect(
      r.validacoes.single.mensagem,
      'Cabo ISOBUS não tem 10 m. Opções: 5, 11, 14 ou 17 m.',
    );
  });

  test('solteira de até 12 linhas: é preciso responder sobre o alternador', () {
    final r = configurar(12, const [], tipo: TipoPlantadeira.solteira);
    expect(r.bloqueada, isTrue);
    expect(
      r.validacoes.single.mensagem,
      'Responda se a máquina terá alternador hidráulico.',
    );
    const solteira = TipoPlantadeira.solteira;
    expect(RegrasConfigurador.perguntarAlternador(12, solteira), isTrue);
    expect(RegrasConfigurador.perguntarAlternador(13, solteira), isFalse);
  });

  test('máquinas com seções separadas sempre têm alternador', () {
    for (final tipo in [
      TipoPlantadeira.autotransportavel,
      TipoPlantadeira.caixaCentral,
      TipoPlantadeira.tandem,
    ]) {
      expect(
        RegrasConfigurador.perguntarAlternador(8, tipo),
        isFalse,
        reason: tipo.nome,
      );
      final r = configurar(8, [4, 4], tipo: tipo);
      expect(r.bloqueada, isFalse, reason: tipo.nome);
      expect(
        r.item(Componentes.alternador)!.motivo,
        'Obrigatório em ${tipo.nome.toLowerCase()}.',
      );
      expect(r.item(Componentes.caboBateria), isNull, reason: tipo.nome);
    }
  });

  test('solteira de 12 linhas com alternador: duas saídas', () {
    final r = configurar(
      12,
      const [],
      alternador: true,
      tipo: TipoPlantadeira.solteira,
    );
    expect(r.item(Componentes.alternador)!.motivo, contains('Escolhido'));
    expect(r.item(Componentes.caboBateria), isNull);
    expect(r.distribuicao!.modo, ModoDistribuicao.porSecao);
    expect(faixas(r.distribuicao!), [(1, 6), (7, 12)]);
  });

  test('solteira a partir de 13 linhas: alternador obrigatório', () {
    final r = configurar(13, const [], tipo: TipoPlantadeira.solteira);
    expect(r.bloqueada, isFalse);
    expect(r.item(Componentes.alternador)!.motivo, contains('13 linhas'));
    expect(faixas(r.distribuicao!), [(1, 7), (8, 13)]);
  });

  test('30 linhas em 3 seções de 10: uma saída por seção', () {
    final r = configurar(30, [10, 10, 10]);
    expect(r.distribuicao!.modo, ModoDistribuicao.porSecao);
    expect(r.distribuicao!.saidas, hasLength(3));
    expect(r.validacoes, isEmpty);
  });

  test('55 linhas (21 + 21 + 13): distribuição global com aviso', () {
    final r = configurar(55, [21, 21, 13]);
    expect(r.bloqueada, isFalse);
    expect(r.item(Componentes.sensorSemente)!.quantidade, 55);
    final d = r.distribuicao!;
    expect(d.modo, ModoDistribuicao.global);
    expect(d.saidas.map((s) => s.linhas), [10, 9, 9, 9, 9, 9]);
    expect(faixas(d), [
      (1, 10),
      (11, 19),
      (20, 28),
      (29, 37),
      (38, 46),
      (47, 55),
    ]);
    expect(d.saidasQueMisturamSecoes.map((s) => s.numero), [3, 5]);
    expect(d.saidas[2].secoes, [1, 2]);
    expect(d.saidas[4].secoes, [2, 3]);
    expect(
      r.validacoes.where((v) => v.nivel == NivelValidacao.aviso),
      hasLength(2),
    );
  });

  test('nenhuma saída passa de 10 linhas', () {
    for (var n = 1; n <= 60; n++) {
      final d = RegrasConfigurador.distribuirSaidas([n])!;
      expect(d.saidas.every((s) => s.linhas <= 10), isTrue, reason: '$n');
      expect(d.saidas.length, lessThanOrEqualTo(6), reason: '$n');
      expect(d.saidas.fold(0, (t, s) => t + s.linhas), n, reason: '$n');
    }
  });

  test('acima de 60 linhas a configuração é bloqueada', () {
    final r = configurar(61, [21, 20, 20]);
    expect(r.bloqueada, isTrue);
    expect(r.validacoes.first.mensagem, contains('capacidade'));
    expect(r.distribuicao, isNull);
  });

  test('soma das seções diferente do total', () {
    final r = configurar(45, [20, 20]);
    expect(r.bloqueada, isTrue);
    expect(
      r.validacoes.single.mensagem,
      'A soma das seções (40) é diferente do total de linhas (45).',
    );
  });

  test('seção vazia', () {
    final r = configurar(20, [20, 0]);
    expect(
      r.validacoes.map((v) => v.mensagem),
      contains('Toda seção precisa ter pelo menos 1 linha.'),
    );
  });

  test('só a solteira tem seção única', () {
    expect(TipoPlantadeira.values.where((t) => !t.secoesSeparadas), [
      TipoPlantadeira.solteira,
    ]);
  });

  test('solteira: a máquina inteira é uma seção', () {
    final r = configurar(
      8,
      const [],
      alternador: false,
      tipo: TipoPlantadeira.solteira,
    );
    expect(r.bloqueada, isFalse);
    expect(r.entrada.secoes, [8]);
    expect(r.item(Componentes.sensorSemente)!.quantidade, 8);
  });

  test('solteira ignora seções informadas', () {
    final r = configurar(20, [5, 5], tipo: TipoPlantadeira.solteira);
    expect(r.bloqueada, isFalse);
    expect(faixas(r.distribuicao!), [(1, 10), (11, 20)]);
  });

  test('solteira de 55 linhas: 6 saídas sem aviso de mistura', () {
    final r = configurar(55, const [], tipo: TipoPlantadeira.solteira);
    final d = r.distribuicao!;
    expect(d.modo, ModoDistribuicao.porSecao);
    expect(d.saidas.map((s) => s.linhas), [10, 9, 9, 9, 9, 9]);
    expect(r.validacoes, isEmpty);
  });

  test('caixa central e tandem exigem as seções', () {
    for (final tipo in [TipoPlantadeira.caixaCentral, TipoPlantadeira.tandem]) {
      final r = configurar(30, const [], tipo: tipo);
      expect(
        r.validacoes.map((v) => v.mensagem),
        contains('Informe as seções da máquina.'),
        reason: tipo.nome,
      );
    }
  });

  test('Titanium e Selenium usam os mesmos componentes de instalação', () {
    final t = configurar(55, [21, 21, 13]);
    final s = configurar(55, [
      21,
      21,
      13,
    ], tecnologia: Tecnologia.seleniumEletric);
    // Fora o conjunto, os discos e os bocais, que são de cada tecnologia.
    Iterable<(String, int)> instalacao(ResultadoConfiguracao r) => r.itens
        .skip(1)
        .where((i) => !itensDaTecnologia.contains(i.componente))
        .where((i) => !i.componente.startsWith('Condutor de sementes'))
        .where((i) => !BocalTitanium.values.any((b) => b.nome == i.componente))
        .where((i) => !BocalSelenium.values.any((b) => b.nome == i.componente))
        .map((i) => (i.componente, i.quantidade));
    expect(instalacao(s), instalacao(t));
  });

  group('itens de cada tecnologia', () {
    test('Titanium: discos de milho e soja, um por linha', () {
      final r = configurar(45, [17, 17, 11], pipoqueira: false);
      expect(qtd(r, Componentes.discoMilhoTitanium), 45);
      expect(qtd(r, Componentes.discoSojaTitanium), 45);
      expect(r.item(Componentes.discoSojaSelenium), isNull);
      expect(r.item(Componentes.reservatorioPipoqueira), isNull);
    });

    test('Titanium: sem resposta da pipoqueira fica pendente', () {
      final p = configurar(45, [
        17,
        17,
        11,
      ]).item(Componentes.reservatorioPipoqueira)!;
      expect(p.status, StatusItem.pendente);
      expect(p.pendencia, contains('pipoqueira'));
    });

    test('Titanium com pipoqueira: reservatório e bocal por linha', () {
      final semBocal = configurar(45, [17, 17, 11], pipoqueira: true);
      expect(qtd(semBocal, Componentes.reservatorioPipoqueira), 45);
      expect(
        semBocal.item(Componentes.bocalPipoqueira)!.status,
        StatusItem.pendente,
      );
      for (final b in BocalTitanium.values) {
        final r = configurar(
          45,
          [17, 17, 11],
          pipoqueira: true,
          bocalTitanium: b,
        );
        expect(qtd(r, b.nome), 45, reason: b.nome);
        expect(r.item(Componentes.bocalPipoqueira), isNull);
      }
    });

    test('Selenium: discos de soja e milho e o kit bocal escolhido', () {
      final pendente = configurar(30, [
        10,
        10,
        10,
      ], tecnologia: Tecnologia.seleniumEletric);
      expect(qtd(pendente, Componentes.discoSojaSelenium), 30);
      expect(qtd(pendente, Componentes.discoMilhoSelenium), 30);
      expect(
        pendente.item(Componentes.bocalSelenium)!.status,
        StatusItem.pendente,
      );
      expect(pendente.item(Componentes.discoMilhoTitanium), isNull);
      final r = configurar(
        30,
        [10, 10, 10],
        tecnologia: Tecnologia.seleniumEletric,
        bocalSelenium: BocalSelenium.engateRapido,
        // Resposta do Titanium é ignorada no Selenium.
        pipoqueira: true,
      );
      expect(
        qtd(r, 'Kit bocal de sementes Selenium engate rápido com tela dupla'),
        30,
      );
      expect(r.item(Componentes.reservatorioPipoqueira), isNull);
    });
  });
}

void testesKitConversao() {
  group('kit conversão', () {
    ResultadoConfiguracao kit(Tecnologia t) => RegrasConfigurador.configurar(
      EntradaConfiguracao(
        tecnologia: t,
        tipo: TipoPlantadeira.autotransportavel,
        totalLinhas: 30,
        linhasPorSecao: const [10, 10, 10],
        kitConversao: true,
      ),
    );

    test('Titanium: kit no lugar do conjunto, sem discos nem pipoqueira', () {
      final r = kit(Tecnologia.titaniumEletric);
      expect(qtd(r, 'Kit conversão Titanium Elétric'), 30);
      expect(r.item('Conjunto Titanium Elétric'), isNull);
      for (final c in itensDaTecnologia) {
        expect(r.item(c), isNull, reason: c);
      }
      expect(qtd(r, Componentes.sensorSemente), 30);
    });

    test('Selenium: kit G3 no lugar do conjunto, sem discos nem bocal', () {
      final r = kit(Tecnologia.seleniumEletric);
      expect(qtd(r, 'Kit conversão Selenium G3 p/ Selenium Elétric'), 30);
      expect(r.item('Conjunto Selenium Elétric'), isNull);
      for (final c in itensDaTecnologia) {
        expect(r.item(c), isNull, reason: c);
      }
    });
  });
}

void testesAdaptacao() {
  group('adaptação', () {
    test('catálogo: 14 marcas e 32 modelos no Titanium', () {
      final t = adaptacoes[Tecnologia.titaniumEletric]!;
      expect(t, hasLength(14));
      expect(t.values.fold(0, (s, m) => s + m.length), 32);
    });

    test('catálogo: 11 marcas e 37 modelos no Selenium, sem eixo flexível', () {
      final s = adaptacoes[Tecnologia.seleniumEletric]!;
      expect(s, hasLength(11));
      expect(s.values.fold(0, (n, m) => n + m.length), 37);
      for (final modelos in s.values) {
        for (final m in modelos) {
          expect(m, isNot(contains('flexível')));
        }
      }
    });

    test('marcas em ordem alfabética, Tatu Marchesan e CNH', () {
      for (final t in Tecnologia.values) {
        final marcas = adaptacoes[t]!.keys.toList();
        expect(
          marcas,
          [...marcas]
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
        );
        expect(marcas, isNot(contains('Tatu')));
      }
      expect(adaptacoes[Tecnologia.seleniumEletric]!.keys, contains('CNH'));
    });

    test('adaptação de outra tecnologia bloqueia', () {
      EntradaConfiguracao entrada(Adaptacao a) => EntradaConfiguracao(
        tecnologia: Tecnologia.seleniumEletric,
        tipo: TipoPlantadeira.solteira,
        totalLinhas: 20,
        adaptacao: a,
      );
      expect(
        RegrasConfigurador.validar(
          entrada(const Adaptacao('CNH', 'S-2200 Easy Riser')),
        ),
        isEmpty,
      );
      final erros = RegrasConfigurador.validar(
        entrada(const Adaptacao('Stara', 'ST2')),
      );
      expect(erros.single.mensagem, contains('não existe para Selenium'));
    });
  });
}

void testesCondutorSelenium() {
  group('condutor de sementes do Selenium', () {
    ResultadoConfiguracao selenium(Adaptacao? a, {bool kit = false}) =>
        RegrasConfigurador.configurar(
          EntradaConfiguracao(
            tecnologia: Tecnologia.seleniumEletric,
            tipo: TipoPlantadeira.solteira,
            totalLinhas: 20,
            adaptacao: a,
            kitConversao: kit,
          ),
        );

    test('toda adaptação do Selenium tem condutor', () {
      final catalogo = adaptacoes[Tecnologia.seleniumEletric]!;
      for (final MapEntry(key: marca, value: modelos) in catalogo.entries) {
        for (final modelo in modelos) {
          expect(
            condutoresSelenium[marca]?[modelo],
            isNotNull,
            reason: '$marca · $modelo',
          );
        }
      }
      expect(condutoresSelenium.values.fold(0, (n, m) => n + m.length), 37);
    });

    test('retrabalhado: entra o condutor da adaptação, um por linha', () {
      final r = selenium(const Adaptacao('Horsch', 'Maestro Duo 36.50'));
      final c = r.item('Condutor de sementes retrabalhado JD1 - 20000000608')!;
      expect(c.quantidade, 20);
      expect(c.status, StatusItem.definido);
      expect(c.motivo, contains('Horsch · Maestro Duo 36.50'));
    });

    test('original: não gera item, só um aviso informativo', () {
      final r = selenium(const Adaptacao('CNH', 'S-2200 Easy Riser'));
      expect(
        r.itens.where((i) => i.componente.startsWith('Condutor')),
        isEmpty,
      );
      final info = r.validacoes.where((v) => v.nivel == NivelValidacao.info);
      expect(
        info.single.mensagem,
        'A adaptação CNH · S-2200 Easy Riser usa o condutor de sementes '
        'original da plantadeira.',
      );
      expect(info.single.bloqueia, isFalse);
      expect(r.pendentes, isNot(contains(Componentes.condutorSelenium)));
    });

    test('retrabalhado não gera aviso de condutor original', () {
      final r = selenium(const Adaptacao('Kuhn', 'PDM/PD Máxima 1200'));
      expect(
        r.validacoes.where((v) => v.nivel == NivelValidacao.info),
        isEmpty,
      );
    });

    test('exemplos da lista', () {
      String condutor(String marca, String modelo) =>
          condutoresSelenium[marca]![modelo]!;
      expect(
        condutor('Jumil', '2980 Pantográfica'),
        'Condutor de sementes retrabalhado JM3 - 30000000002',
      );
      expect(
        condutor('Tatu Marchesan', 'COP CE Suprema'),
        'Condutor de sementes retrabalhado - 20000000568',
      );
      expect(
        condutor('Vence Tudo', 'Macanuda Top Fertilizante Série 02'),
        'Condutor de sementes retrabalhado VT1 - 20000000654',
      );
    });

    test('sem adaptação fica pendente; kit e Titanium não têm', () {
      final p = selenium(null).item(Componentes.condutorSelenium)!;
      expect(p.status, StatusItem.pendente);
      final kit = selenium(null, kit: true);
      expect(
        kit.itens.where((i) => i.componente.startsWith('Condutor')),
        isEmpty,
      );
      final titanium = configurar(30, [10, 10, 10], pipoqueira: false);
      expect(
        titanium.itens.where((i) => i.componente.startsWith('Condutor')),
        isEmpty,
      );
    });
  });
}

void testesSfil() {
  test('SFIL é modelo de Tatu Marchesan, Stara e Semeato, não marca', () {
    final t = adaptacoes[Tecnologia.titaniumEletric]!;
    expect(t.containsKey('SFIL'), isFalse);
    final comSfil = [
      for (final MapEntry(key: marca, value: modelos) in t.entries)
        if (modelos.contains('SFIL')) marca,
    ];
    expect(comSfil, ['Semeato', 'Stara', 'Tatu Marchesan']);
  });
}
