// Valores do exemplo da planilha Calculadora_ROI_Retrofit_JAssy.xlsx.
import 'package:flutter_test/flutter_test.dart';
import 'package:roi/roi.dart';

const exemplo = PremissasRoi(
  areaHa: 2000,
  linhas: 66,
  produtividadeScHa: 65,
  precoSaca: 125,
  populacao: 300000,
  precoMilSementes: 2.5,
  sobreposicao: 0.03,
  reducaoSobreposicao: 0.85,
  areaZonaHa: 500,
  populacaoAtualZona: 300000,
  populacaoPrescrita: 250000,
  areaCurvas: 0.15,
  perdaCurvas: 0.005,
  economiaOperacional: 20000,
  investimento: 480000,
  concorrente: 220000,
  plantadeiraNova: 1500000,
  valorPlantadeiraAtual: 600000,
  vidaSafras: 3,
);

Matcher perto(double v) => closeTo(v, 1e-6);

void main() {
  final r = CalculadoraRoi.calcular(exemplo);

  test('benefícios fixos da aba Calculadora', () {
    expect(r.fixos.sobreposicao, perto(38250));
    expect(r.fixos.taxaVariavel, perto(62500));
    expect(r.fixos.curvas, perto(12187.5));
    expect(r.fixos.operacao, perto(20000));
    expect(r.receitaBruta, perto(16250000));
  });

  test('cenários: plantabilidade, benefício, payback, ROI e horizonte', () {
    final esperado = {
      CenarioRoi.conservador: (
        81250.0,
        214187.5,
        2.2410271374379924,
        0.44622395833333334,
        642562.5,
      ),
      CenarioRoi.provavel: (
        162500.0,
        295437.5,
        1.6247091178337212,
        0.61549479166666665,
        886312.5,
      ),
      CenarioRoi.potencial: (
        325000.0,
        457937.5,
        1.0481779718848097,
        0.95403645833333328,
        1373812.5,
      ),
    };
    for (final MapEntry(key: c, value: e) in esperado.entries) {
      final x = r.cenarios[c]!;
      expect(x.plantabilidade, perto(e.$1), reason: c.nome);
      expect(x.beneficioSafra, perto(e.$2), reason: c.nome);
      expect(x.payback, perto(e.$3), reason: c.nome);
      expect(x.roiAnual, perto(e.$4), reason: c.nome);
      expect(x.beneficioHorizonte, perto(e.$5), reason: c.nome);
    }
  });

  test('retorno líquido no horizonte desconta o investimento', () {
    expect(
      r.cenarios[CenarioRoi.provavel]!.retornoLiquido,
      perto((886312.5 - 480000) / 480000),
    );
  });

  test('leitura comercial: por linha, por ha e por ha/ano', () {
    expect(r.jassy.porLinha, perto(7272.727272727273));
    expect(r.jassy.porHa, perto(240));
    expect(r.jassy.porHaAno, perto(80));
  });

  test('comparativo com concorrente e plantadeira nova', () {
    final c = r.alternativa(Alternativa.concorrente);
    expect(c.investimento, 220000);
    expect(c.porLinha, perto(3333.3333333333335));
    expect(c.porHa, perto(110));
    expect(c.porHaAno, perto(36.666666666666664));
    expect(c.diferencaJassy, -260000);
    final n = r.alternativa(Alternativa.plantadeiraNova);
    expect(n.investimento, 900000);
    expect(n.porLinha, perto(13636.363636363636));
    expect(n.porHa, perto(450));
    expect(n.porHaAno, perto(150));
    expect(n.diferencaJassy, 420000);
    expect(r.diferencaConcorrente, 260000);
    expect(r.diferencaConcorrentePorHa, perto(130));
    expect(r.diferencaConcorrentePorHaAno, perto(43.333333333333336));
    expect(r.capitalEvitado, 420000);
  });

  test('taxa variável nunca fica negativa', () {
    const p = PremissasRoi(
      areaZonaHa: 500,
      populacaoAtualZona: 250000,
      populacaoPrescrita: 300000,
      precoMilSementes: 2.5,
    );
    expect(CalculadoraRoi.beneficiosFixos(p).taxaVariavel, 0);
  });

  test('plantadeira nova mais barata que a atual não fica negativa', () {
    const p = PremissasRoi(
      areaHa: 100,
      investimento: 1,
      vidaSafras: 1,
      plantadeiraNova: 100,
      valorPlantadeiraAtual: 200,
    );
    final x = CalculadoraRoi.calcular(p);
    expect(x.alternativa(Alternativa.plantadeiraNova).investimento, 0);
    expect(x.capitalEvitado, 0);
  });

  test('sem área, investimento ou vida, os indicadores ficam vazios', () {
    final x = CalculadoraRoi.calcular(const PremissasRoi());
    final c = x.cenarios[CenarioRoi.provavel]!;
    expect(c.payback, isNull);
    expect(c.roiAnual, isNull);
    expect(x.jassy.porHa, isNull);
    expect(CalculadoraRoi.validar(const PremissasRoi()), [
      'Informe a área plantada.',
      'Informe o investimento do retrofit J.Assy.',
      'Informe a vida econômica em safras.',
    ]);
    expect(CalculadoraRoi.validar(exemplo), isEmpty);
  });

  test('percentual fora de 0 a 100% não passa', () {
    const p = PremissasRoi(
      areaHa: 1,
      investimento: 1,
      vidaSafras: 1,
      sobreposicao: 1.5,
    );
    expect(CalculadoraRoi.validar(p), [
      'Sobreposição atual precisa estar entre 0 e 100%.',
    ]);
  });
}
