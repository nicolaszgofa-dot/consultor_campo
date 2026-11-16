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

  test('bocais do Selenium pelo catálogo; o resto sem código', () {
    expect(nomeECodigo(BocalSelenium.gravidade.nome).codigo, '30000000681');
    expect(nomeECodigo(BocalSelenium.engateRapido.nome).codigo, '30000000360');
    expect(nomeECodigo(Componentes.ecu), (nome: 'Conjunto ECU', codigo: null));
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
}
