// Guia de seleção de disco do Selenium Neo: células conferidas nas tabelas.
import 'package:configurador/configurador.dart';
import 'package:flutter_test/flutter_test.dart';

IndicacaoDisco soja(double pop, double km) => recomendarDiscoNeo(
  CulturaNeo.soja,
  populacao: pop,
  velocidade: km,
).indicacao;

IndicacaoDisco milho(double pop, double km) => recomendarDiscoNeo(
  CulturaNeo.milho,
  populacao: pop,
  velocidade: km,
).indicacao;

void main() {
  test('soja: células da tabela', () {
    expect(soja(6, 2), IndicacaoDisco.baixa);
    expect(soja(6, 16), IndicacaoDisco.baixa);
    expect(soja(6, 17), IndicacaoDisco.ambosBaixa);
    expect(soja(8, 18), IndicacaoDisco.ambosAlta);
    expect(soja(10, 19), IndicacaoDisco.alta);
    expect(soja(16, 12), IndicacaoDisco.alta);
    expect(soja(20, 18), IndicacaoDisco.alta);
    expect(soja(20, 19), IndicacaoDisco.fora);
    expect(soja(34, 2), IndicacaoDisco.baixa);
    expect(soja(34, 3), IndicacaoDisco.ambosBaixa);
    expect(soja(34, 5), IndicacaoDisco.ambosAlta);
    expect(soja(34, 10), IndicacaoDisco.alta);
    expect(soja(34, 11), IndicacaoDisco.fora);
  });

  test('milho: células da tabela', () {
    expect(milho(1, 5), IndicacaoDisco.fora);
    expect(milho(1, 6), IndicacaoDisco.baixa);
    expect(milho(1.5, 19), IndicacaoDisco.ambosBaixa);
    expect(milho(1.5, 20), IndicacaoDisco.ambosAlta);
    expect(milho(2, 19), IndicacaoDisco.alta);
    expect(milho(3, 10), IndicacaoDisco.ambosAlta);
    expect(milho(5, 5), IndicacaoDisco.ambosBaixa);
    expect(milho(5, 15), IndicacaoDisco.alta);
    expect(milho(5, 16), IndicacaoDisco.fora);
    expect(milho(8, 3), IndicacaoDisco.ambosBaixa);
    expect(milho(8, 9), IndicacaoDisco.alta);
    expect(milho(8, 10), IndicacaoDisco.fora);
  });

  test('entre linhas e colunas vale a de cima', () {
    // 7 sem/m usa a linha de 8; 12,3 km/h usa a coluna de 13.
    final r = recomendarDiscoNeo(
      CulturaNeo.soja,
      populacao: 7,
      velocidade: 12.3,
    );
    expect(r.populacaoTabela, 8);
    expect(r.velocidadeTabela, 13);
    expect(r.indicacao, IndicacaoDisco.ambosBaixa);
    expect(soja(7, 12), IndicacaoDisco.baixa);
  });

  test('fora da tabela', () {
    expect(soja(36, 5), IndicacaoDisco.fora);
    expect(soja(10, 21), IndicacaoDisco.fora);
    expect(milho(8.5, 3), IndicacaoDisco.fora);
    expect(milho(0, 3), IndicacaoDisco.fora);
  });

  test('disco indicado e códigos', () {
    final r = recomendarDiscoNeo(
      CulturaNeo.milho,
      populacao: 3,
      velocidade: 10,
    );
    expect(r.disco, CulturaNeo.milho.alta);
    expect(r.osDoisFuncionam, isTrue);
    expect(CulturaNeo.soja.baixa.codigo, '20000002332');
    expect(CulturaNeo.soja.alta.codigo, '20000002333');
    expect(CulturaNeo.milho.baixa.codigo, '20000002335');
    expect(CulturaNeo.milho.alta.codigo, '20000002340');
  });

  test('no resultado: disco de cada cultura, um por linha', () {
    ResultadoConfiguracao configurar({double? soja, double? milho}) =>
        RegrasConfigurador.configurar(
          EntradaConfiguracao(
            tecnologia: Tecnologia.seleniumNeo,
            tipo: TipoPlantadeira.solteira,
            totalLinhas: 20,
            linhasPorSecao: const [20],
            velocidadePlantio: 8,
            populacaoSoja: soja,
            populacaoMilho: milho,
          ),
        );

    final r = configurar(soja: 14, milho: 3);
    // Soja 14 sem/m a 8 km/h: os dois, prefere 35. Milho 3 a 8: os dois, 14.
    final soja35 = r.item(CulturaNeo.soja.baixa.componente)!;
    expect(soja35.quantidade, 20);
    expect(soja35.status, StatusItem.definido);
    expect(soja35.motivo, contains('os dois discos funcionam'));
    expect(r.item(CulturaNeo.milho.baixa.componente)?.quantidade, 20);

    final fora = configurar(
      soja: 34,
      milho: 8,
    ).item(Componentes.discoNeo(CulturaNeo.soja));
    expect(fora, isNull);
    final foraMilho = RegrasConfigurador.configurar(
      const EntradaConfiguracao(
        tecnologia: Tecnologia.seleniumNeo,
        tipo: TipoPlantadeira.solteira,
        totalLinhas: 20,
        linhasPorSecao: [20],
        velocidadePlantio: 12,
        populacaoSoja: 10,
        populacaoMilho: 8,
      ),
    ).item(Componentes.discoNeo(CulturaNeo.milho))!;
    expect(foraMilho.status, StatusItem.pendente);
    expect(foraMilho.pendencia, contains('fora da faixa'));
  });
}
