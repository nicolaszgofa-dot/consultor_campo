import 'package:configurador/configurador.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('código no fim do nome sai do nome', () {
    expect(nomeECodigo('Condutor de sementes retrabalhado JD1 - 20000000608'), (
      nome: 'Condutor de sementes retrabalhado JD1',
      codigo: '20000000608',
    ));
    expect(
      nomeECodigo('Subconjunto disco/anel soja 35 furos Neo 26 (20000002332)'),
      (
        nome: 'Subconjunto disco/anel soja 35 furos Neo 26',
        codigo: '20000002332',
      ),
    );
    expect(nomeECodigo(Componentes.peneiraSojaNeo), (
      nome: 'Kit peneira soja JD2100',
      codigo: '30000001673',
    ));
  });

  test('códigos da engenharia; o que falta fica sem código', () {
    expect(nomeECodigo(BocalSelenium.gravidade.nome).codigo, '30000000681');
    expect(nomeECodigo(BocalSelenium.engateRapido.nome).codigo, '30000000360');
    expect(nomeECodigo(Componentes.ecu).codigo, '30000000052');
    expect(nomeECodigo(Componentes.sensorSemente).codigo, '30000001634');
    expect(nomeECodigo(Componentes.alternador250).codigo, '30000001346');
    expect(nomeECodigo(Componentes.alternador100).codigo, isNull);
    // A ECU do Neo tem código próprio.
    expect(
      nomeECodigo(Componentes.ecu, tecnologia: Tecnologia.seleniumNeo).codigo,
      '30000000057',
    );
    expect(
      nomeECodigo(
        Componentes.ecu,
        tecnologia: Tecnologia.titaniumEletric,
      ).codigo,
      '30000000052',
    );
    expect(
      nomeECodigo(Componentes.caboIsobus, comprimento: 14).codigo,
      '30000000947',
    );
    expect(nomeECodigo(Componentes.caboIsobus).codigo, isNull);
  });

  test('condutor da adaptação sai com código na configuração', () {
    final r = RegrasConfigurador.configurar(
      const EntradaConfiguracao(
        tecnologia: Tecnologia.seleniumEletric,
        tipo: TipoPlantadeira.solteira,
        totalLinhas: 12,
        linhasPorSecao: [12],
        adaptacao: Adaptacao(
          'John Deere',
          'S-2100 SN abaixo de 99.999 (linha chapa)',
        ),
      ),
    );
    final codigos = r.itens.map((i) => nomeECodigo(i.componente).codigo);
    expect(codigos, contains('20000000608'));
  });

  test('chicote painel vira uma linha por comprimento', () {
    final r = RegrasConfigurador.configurar(
      const EntradaConfiguracao(
        tecnologia: Tecnologia.seleniumEletric,
        tipo: TipoPlantadeira.autotransportavel,
        totalLinhas: 24,
        linhasPorSecao: [12, 12],
        temAlternador: true,
        alternadorNaFrente: true,
        comprimentoIsobus: 11,
        comprimentoMangueiras: 12,
        chicotesPainel: {4: 1, 14: 2},
      ),
    );
    final linhas = linhasDoPedido(r);
    final painel = linhas
        .where((l) => l.nome == Componentes.chicotePainel)
        .map((l) => (l.comprimento, l.codigo, l.quantidade));
    expect(painel, [(4, '30000000613', 1), (14, '30000000611', 2)]);
    final isobus = linhas.firstWhere((l) => l.nome == Componentes.caboIsobus);
    expect(isobus.codigo, '30000000521');
    final mangueiras = linhas.firstWhere(
      (l) => l.nome == Componentes.mangueiras,
    );
    expect(mangueiras.codigo, '30000000647');
  });

  test('reservatório pipoqueira sai com o bocal, num código só', () {
    final r = RegrasConfigurador.configurar(
      const EntradaConfiguracao(
        tecnologia: Tecnologia.titaniumEletric,
        tipo: TipoPlantadeira.solteira,
        totalLinhas: 12,
        linhasPorSecao: [12],
        reservatorioPipoqueira: true,
        bocalTitanium: BocalTitanium.pol30,
      ),
    );
    final linhas = linhasDoPedido(r);
    expect(linhas.where((l) => l.nome == BocalTitanium.pol30.nome), isEmpty);
    final reservatorio = linhas.firstWhere(
      (l) => l.nome.startsWith(Componentes.reservatorioPipoqueira),
    );
    expect(reservatorio.codigo, '30000000751');
    expect(
      reservatorio.nome,
      'Reservatório de sementes pipoqueira bocal 3,0 pol',
    );
  });
}
