import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:consultor_campo/avaliacao/avaliacao_estado.dart';
import 'package:consultor_campo/avaliacao/avaliacao_pdf.dart';
import 'package:consultor_campo/avaliacao/avaliacao_pdf_page.dart';
import 'package:consultor_campo/avaliacao/resultado_page.dart';
import 'package:consultor_campo/roi/proposta/proposta_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

const _id = Identificacao(
  cliente: 'Fazenda Boa Vista',
  talhao: 'Talhão 3',
  data: '20/11/2026',
  plantadeira: 'Plantadeira 13 linhas, disco 64 furos',
  cultura: Cultura.soja,
  sementesPorMetro: 14,
  espacamentoLinhasM: 0.5,
  produtividadeScHa: 65,
  area: 120,
);

/// Leituras acumuladas de uma linha de 10 m em torno do ideal, com algumas
/// falhas e duplas (sorteio com semente fixa).
List<double> _linha(int semente, {double falhas = 0.04, double duplas = 0.04}) {
  final rnd = math.Random(semente);
  final ideal = 100 / _id.sementesPorMetro;
  final leituras = <double>[];
  var pos = 0.0;
  while (pos < 1000) {
    final sorteio = rnd.nextDouble();
    final passo = sorteio < duplas
        ? ideal * (0.1 + rnd.nextDouble() * 0.3)
        : sorteio < duplas + falhas
        ? ideal * (1.7 + rnd.nextDouble() * 1.3)
        : ideal * (0.75 + rnd.nextDouble() * 0.5);
    pos += passo;
    leituras.add(double.parse(pos.toStringAsFixed(1)));
  }
  return leituras;
}

AvaliacaoEstado _estado() => AvaliacaoEstado(
  _id,
  linhas: [
    _linha(1),
    _linha(2),
    _linha(3, falhas: 0.12),
    _linha(4),
    _linha(5, duplas: 0.08),
  ],
);

int _paginas(List<int> bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length;

void main() {
  test('histograma: faixas de 1/4 do ideal, limites nas bordas', () {
    const ideal = 10.0;
    final h = histogramaEspacamentos([
      1,
      4.9,
      5,
      10,
      15,
      15.1,
      29.9,
      30,
      80,
    ], ideal);
    expect(h, hasLength(13));
    expect(h.first.inicioCm, 0);
    expect(h.last.fimCm, isNull);
    // 0,5× ideal (5 cm) já é aceitável; 1,5× (15 cm) também.
    expect(h[1].classe, ClasseEspacamento.dupla); // 2,5–5
    expect(h[2].classe, ClasseEspacamento.aceitavel); // 5–7,5
    expect(h[5].classe, ClasseEspacamento.aceitavel); // 12,5–15
    expect(h[6].classe, ClasseEspacamento.falha); // 15–17,5
    expect(h[0].quantidade, 1); // 1
    expect(h[1].quantidade, 1); // 4,9
    expect(h[2].quantidade, 1); // 5
    expect(h[4].quantidade, 1); // 10
    expect(h[6].quantidade, 2); // 15 e 15,1
    expect(h[11].quantidade, 1); // 29,9
    expect(h[12].quantidade, 2); // 30 e 80
    expect(h.fold<int>(0, (s, f) => s + f.quantidade), 9);
  });

  test('nome do arquivo com cliente e talhão', () {
    expect(
      nomeArquivoAvaliacao(_id),
      'Avaliacao_plantio_Fazenda_Boa_Vista_Talhão_3.pdf',
    );
  });

  testWidgets('gera o relatório com e sem prejuízo', (tester) async {
    await tester.runAsync(() async {
      final recursos = await RecursosPdf.carregar();
      final estado = _estado();
      expect(estado.resultado.linhasCompletas, 5);
      final prejuizo = PrejuizoCalc.calcular(
        calcularPerda(estado),
        ParametrosPrejuizo(
          precoSacaReais: 120,
          areaHa: _id.areaHa,
          precoSacoSementeReais: 380,
          sementesPorSaco: 200000,
          sementesPorHa: _id.parametros.populacaoPorHa,
        ),
      );
      for (final (nome, pj) in [('sem_rs', null), ('com_rs', prejuizo)]) {
        final bytes = await gerarAvaliacaoPdf(
          estado: estado,
          recursos: recursos,
          prejuizo: pj,
          data: DateTime(2026, 11, 25),
        );
        expect(latin1.decode(bytes.take(4).toList()), '%PDF');
        // Para ver o exemplo: PDF_SAIDA=<pasta> flutter test ...
        final saida = Platform.environment['PDF_SAIDA'];
        if (saida != null) {
          File('$saida/avaliacao_$nome.pdf').writeAsBytesSync(bytes);
        }
        expect(_paginas(bytes), inInclusiveRange(2, 4), reason: nome);
      }

      // Uma linha só: aviso de amostra pequena, sem erro.
      final pequena = AvaliacaoEstado(_id, linhas: [_linha(9)]);
      final bytes = await gerarAvaliacaoPdf(
        estado: pequena,
        recursos: recursos,
      );
      expect(_paginas(bytes), greaterThanOrEqualTo(1));
    });
  });
}
