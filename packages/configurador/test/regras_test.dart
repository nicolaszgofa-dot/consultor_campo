// Casos de docs/configurador/especificacao.md.
import 'package:configurador/configurador.dart';
import 'package:flutter_test/flutter_test.dart';

ResultadoConfiguracao configurar(
  int linhas,
  List<int> secoes, {
  bool? alternador,
  Tecnologia tecnologia = Tecnologia.titaniumEletric,
  TipoPlantadeira tipo = TipoPlantadeira.autotransportavel,
}) => RegrasConfigurador.configurar(
  EntradaConfiguracao(
    tecnologia: tecnologia,
    tipo: tipo,
    totalLinhas: linhas,
    linhasPorSecao: secoes,
    temAlternador: alternador,
  ),
);

List<(int, int)> faixas(DistribuicaoSaidas d) => [
  for (final s in d.saidas) (s.primeiraLinha, s.ultimaLinha),
];

void main() {
  test('8 linhas sem alternador: itens obrigatórios e cabo da bateria', () {
    final r = configurar(8, [8], alternador: false);
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
    final r = configurar(8, [8], alternador: false);
    expect(
      r.pendentes.map((i) => i.componente),
      containsAll([
        Componentes.caboIsobus,
        Componentes.chicotes,
        Componentes.caboPainel,
      ]),
    );
    for (final p in r.pendentes) {
      expect(p.pendencia, isNotNull);
    }
  });

  test('até 12 linhas é preciso responder sobre o alternador', () {
    final r = configurar(12, [6, 6]);
    expect(r.bloqueada, isTrue);
    expect(
      r.validacoes.single.mensagem,
      'Responda se a máquina terá alternador hidráulico.',
    );
    expect(RegrasConfigurador.perguntarAlternador(12), isTrue);
    expect(RegrasConfigurador.perguntarAlternador(13), isFalse);
  });

  test('12 linhas com alternador: duas saídas, uma por seção', () {
    final r = configurar(12, [6, 6], alternador: true);
    expect(r.item(Componentes.alternador)!.motivo, contains('Escolhido'));
    expect(r.item(Componentes.caboBateria), isNull);
    expect(r.distribuicao!.modo, ModoDistribuicao.porSecao);
    expect(faixas(r.distribuicao!), [(1, 6), (7, 12)]);
  });

  test('a partir de 13 linhas o alternador é obrigatório', () {
    final r = configurar(13, [13]);
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

  test('Selenium Elétric segue as mesmas regras nesta versão', () {
    final t = configurar(55, [21, 21, 13]);
    final s = configurar(55, [
      21,
      21,
      13,
    ], tecnologia: Tecnologia.seleniumEletric);
    expect(
      s.itens.map((i) => (i.componente, i.quantidade)),
      t.itens.map((i) => (i.componente, i.quantidade)),
    );
  });
}
