import 'dart:math' as math;
import 'dart:typed_data';

import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../roi/proposta/proposta_pdf.dart';
import '../ui/formatos.dart';
import 'avaliacao_estado.dart';
import 'resultado_page.dart';

/// Uma faixa do histograma de espaçamentos.
class FaixaEspacamento {
  /// Início da faixa, em cm (inclusivo).
  final double inicioCm;

  /// Fim da faixa, em cm (exclusivo); nulo na última faixa ("ou mais").
  final double? fimCm;
  final int quantidade;
  final ClasseEspacamento classe;

  const FaixaEspacamento({
    required this.inicioCm,
    required this.fimCm,
    required this.quantidade,
    required this.classe,
  });
}

/// Histograma dos espaçamentos medidos. As faixas têm 1/4 do espaçamento
/// ideal, de 0 a 3× o ideal, mais uma faixa "3× ou mais". Assim os limites
/// de dupla (0,5×) e de falha (1,5×) caem na borda de uma faixa.
List<FaixaEspacamento> histogramaEspacamentos(
  Iterable<double> espacamentosCm,
  double idealCm,
) {
  const porIdeal = 4;
  const faixas = 3 * porIdeal; // até 3× o ideal
  final largura = idealCm / porIdeal;
  final contagem = List<int>.filled(faixas + 1, 0);
  for (final e in espacamentosCm) {
    // Pequena folga para um valor exatamente na borda cair na faixa de cima,
    // como na classificação (os limites são aceitáveis).
    final i = ((e + 1e-9) / largura).floor();
    contagem[math.min(math.max(i, 0), faixas)]++;
  }
  ClasseEspacamento classe(int i) {
    final meio = (i + 0.5) / porIdeal; // em múltiplos do ideal
    if (meio < PlantabilidadeCalc.limiteDupla) return ClasseEspacamento.dupla;
    if (meio > PlantabilidadeCalc.limiteFalha) return ClasseEspacamento.falha;
    return ClasseEspacamento.aceitavel;
  }

  return [
    for (var i = 0; i <= faixas; i++)
      FaixaEspacamento(
        inicioCm: i * largura,
        fimCm: i == faixas ? null : (i + 1) * largura,
        quantidade: contagem[i],
        classe: classe(i),
      ),
  ];
}

abstract final class _C {
  static const tinta = PdfColor.fromInt(0xFF1D1D1B);
  static const secundario = PdfColor.fromInt(0xFF5F6165);
  static const verde = PdfColor.fromInt(0xFF2AA437);
  static const verdeEscuro = PdfColor.fromInt(0xFF112C02);
  static const verdeTexto = PdfColor.fromInt(0xFF1D7A28);
  static const falha = PdfColor.fromInt(0xFFB43C0C);
  static const dupla = PdfColor.fromInt(0xFF1D4ED8);
  static const prejuizo = PdfColor.fromInt(0xFFB42318);
  static const prejuizoClaro = PdfColor.fromInt(0xFFFDECEA);
  static const atencao = PdfColor.fromInt(0xFF9A5B00);
  static const atencaoClaro = PdfColor.fromInt(0xFFFBF1E1);
  static const neutro = PdfColor.fromInt(0xFFF4F5F5);
  static const neutroEscuro = PdfColor.fromInt(0xFFE8EAEB);
  static const borda = PdfColor.fromInt(0xFFDCDFE1);
}

PdfColor _corDoPercentual(double p) => p >= 95
    ? _C.verdeTexto
    : p >= 85
    ? _C.atencao
    : _C.prejuizo;

PdfColor _corDaClasse(ClasseEspacamento c) => switch (c) {
  ClasseEspacamento.aceitavel => _C.verde,
  ClasseEspacamento.dupla => _C.dupla,
  ClasseEspacamento.falha => _C.falha,
};

String _fonteDaPerda(Cultura c) => switch (c) {
  Cultura.soja =>
    'Soja: perda pelas falhas e duplas da trena (Fiss et al., 2018).',
  Cultura.milho =>
    'Milho: perda pelo desvio padrão dos espaçamentos acima de 5 cm '
        '(Nielsen, Purdue).',
  Cultura.feijao =>
    'Feijão: perda pelo CV dos espaçamentos (Bisognin et al., 2019).',
};

/// Relatório interno da avaliação de plantio: identificação, resultado
/// geral, tabela por linha, histograma dos espaçamentos, perda estimada,
/// prejuízo (quando os preços foram informados) e as leituras da trena.
Future<Uint8List> gerarAvaliacaoPdf({
  required AvaliacaoEstado estado,
  required RecursosPdf recursos,
  Cenario cenario = Cenario.medio,
  ResultadoPrejuizo? prejuizo,
  DateTime? data,
}) {
  final m = _Montador(
    estado,
    recursos,
    cenario,
    prejuizo,
    data ?? DateTime.now(),
  );
  final id = estado.identificacao;
  final doc = pw.Document(
    title: 'Avaliação de plantio – ${m.nome}',
    author: 'J.Assy',
    theme: pw.ThemeData.withFont(
      base: recursos.regular,
      bold: recursos.negrito,
    ),
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(34, 26, 34, 20),
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      header: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: m.topo(capa: ctx.pageNumber == 1),
      ),
      footer: (ctx) => m.rodape(ctx.pageNumber, ctx.pagesCount),
      build: (_) => [
        m.capa(),
        if (m.r.amostraPequena) ...[pw.SizedBox(height: 8), m.avisoAmostra()],
        pw.SizedBox(height: 12),
        pw.Inseparable(child: m.resultadoGeral()),
        pw.SizedBox(height: 14),
        ...m.porLinha(),
        pw.SizedBox(height: 14),
        pw.Inseparable(child: m.histograma()),
        pw.SizedBox(height: 14),
        pw.Inseparable(child: m.perda(id.cultura)),
        if (prejuizo != null) ...[
          pw.SizedBox(height: 14),
          pw.Inseparable(child: m.prejuizoBloco(prejuizo)),
        ],
        pw.SizedBox(height: 14),
        ...m.leituras(),
      ],
    ),
  );
  return doc.save();
}

class _Montador {
  final AvaliacaoEstado estado;
  final RecursosPdf f;
  final Cenario cenario;
  final ResultadoPrejuizo? prejuizo;
  final DateTime data;
  final ResultadoAvaliacao r;

  _Montador(this.estado, this.f, this.cenario, this.prejuizo, this.data)
    : r = estado.resultado;

  Identificacao get id => estado.identificacao;

  /// Linhas com leitura (abas vazias não entram).
  List<(int, LinhaAvaliada)> get medidas => [
    for (final (i, l) in r.linhas.indexed)
      if (l.plantas > 0) (i, l),
  ];

  String get nome => [
    if (id.cliente.isNotEmpty) id.cliente,
    if (id.talhao.isNotEmpty) id.talhao,
    if (id.cliente.isEmpty && id.talhao.isEmpty) nomeCultura(id.cultura),
  ].join(' · ');

  pw.TextStyle t(
    double tamanho, {
    pw.Font? fonte,
    PdfColor cor = _C.tinta,
    double? espaco,
  }) => pw.TextStyle(
    font: fonte ?? f.regular,
    fontSize: tamanho,
    color: cor,
    letterSpacing: espaco,
  );

  pw.Widget _rotulo(String texto) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(
      texto.toUpperCase(),
      style: t(8.2, fonte: f.negrito, cor: _C.secundario, espaco: 0.7),
    ),
  );

  pw.Widget _nota(String texto) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 5),
    child: pw.Text(texto, style: t(7.8, cor: _C.secundario)),
  );

  pw.Widget topo({required bool capa}) => pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 8),
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(
          color: capa ? _C.verdeEscuro : _C.borda,
          width: capa ? 1.5 : 0.75,
        ),
      ),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(pw.MemoryImage(f.logo), height: capa ? 34 : 22),
        pw.Text(
          capa
              ? 'Relatório interno · gerado em ${dataBr(data)}'
              : 'Avaliação de plantio · $nome',
          style: t(9, cor: _C.secundario),
        ),
      ],
    ),
  );

  pw.Widget rodape(int pagina, int total) => pw.Container(
    margin: const pw.EdgeInsets.only(top: 12),
    padding: const pw.EdgeInsets.only(top: 6),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _C.borda, width: 0.75)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Uso interno J.Assy. Medição com trena no JA Campo; perda e '
          'prejuízo são estimativas.',
          style: t(7.5, cor: _C.secundario),
        ),
        pw.Text('$pagina de $total', style: t(7.5, cor: _C.secundario)),
      ],
    ),
  );

  pw.Widget _par(String rotulo, String valor, {double largura = 118}) =>
      pw.SizedBox(
        width: largura,
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                rotulo.toUpperCase(),
                style: t(
                  6.8,
                  fonte: f.negrito,
                  cor: _C.secundario,
                  espaco: 0.5,
                ),
              ),
              pw.Text(valor, style: t(10.5, fonte: f.semi)),
            ],
          ),
        ),
      );

  /// Título e identificação da avaliação.
  pw.Widget capa() {
    final p = id.parametros;
    final area =
        '${numeroBr(id.area, id.area % 1 == 0 ? 0 : 1)} '
        '${id.unidade.rotulo}'
        '${id.unidade == UnidadeArea.hectare ? '' : ' (${numeroBr(id.areaHa, 1)} ha)'}';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          'AVALIAÇÃO DE PLANTIO · ${nomeCultura(id.cultura).toUpperCase()}',
          style: t(9, fonte: f.semi, cor: _C.verdeTexto, espaco: 0.7),
        ),
        pw.Text(nome, style: t(24, fonte: f.titulo)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(14, 9, 14, 1),
          decoration: pw.BoxDecoration(
            color: _C.neutro,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Wrap(
            spacing: 6,
            children: [
              if (id.data.isNotEmpty) _par('Data da avaliação', id.data),
              if (id.plantadeira.isNotEmpty)
                _par('Plantadeira', id.plantadeira, largura: 242),
              _par('Sementes por metro', numeroBr(id.sementesPorMetro, 1)),
              _par(
                'Espaçamento entre linhas',
                '${numeroBr(id.espacamentoLinhasM, 2)} m',
              ),
              _par(
                'Espaçamento ideal',
                '${numeroBr(p.espacamentoIdealCm, 1)} cm',
              ),
              _par(
                'População teórica',
                '${numeroBr(p.populacaoPorHa, 0)} pl/ha',
              ),
              _par(
                'Produtividade esperada',
                '${numeroBr(id.produtividadeScHa, 0)} sc/ha',
              ),
              _par('Área', area),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget avisoAmostra() {
    final n = r.linhasCompletas;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _C.atencaoClaro,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        'Amostra pequena: ${n == 1 ? '1 linha' : '$n linhas'} de 10 m, de '
        '${RegrasAvaliacao.linhasRecomendadas} recomendadas. Resultado pouco '
        'confiável.',
        style: t(9, fonte: f.semi, cor: _C.atencao),
      ),
    );
  }

  /// % no lugar certo, faixa colorida e os indicadores técnicos.
  pw.Widget resultadoGeral() {
    final noLugar = r.percentualNoLugarCerto;
    final pctFalhas = r.total.percentualFaltando;
    final pctDuplas = r.total.percentualAMais;
    final comprimentoM = medidas.fold<double>(
      0,
      (s, l) => s + l.$2.comprimentoCm / 100,
    );
    final espacamentos = [
      for (final (_, l) in medidas) ...l.resultado.espacamentos,
    ];
    int contar(ClasseEspacamento c) =>
        espacamentos.where((e) => e.classe == c).length;
    final aceitaveis = espacamentos.isEmpty
        ? 0.0
        : contar(ClasseEspacamento.aceitavel) / espacamentos.length * 100;
    final populacaoMedida = r.mediaCm > 0
        ? 100 / r.mediaCm * id.parametros.metrosLinearesPorHa
        : 0.0;

    pw.Widget faixa(double p, PdfColor cor) {
      final flex = (p * 10).round();
      if (flex <= 0) return pw.SizedBox();
      return pw.Expanded(
        flex: flex,
        child: pw.Container(height: 10, color: cor),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _rotulo('Resultado geral'),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              percentual(noLugar),
              style: t(40, fonte: f.titulo, cor: _corDoPercentual(noLugar)),
            ),
            pw.SizedBox(width: 10),
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                'das plantas no lugar certo',
                style: t(10, cor: _C.secundario),
              ),
            ),
            pw.Spacer(),
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                '${medidas.length == 1 ? '1 linha' : '${medidas.length} linhas'}'
                ' · ${numeroBr(comprimentoM, 1)} m · '
                '${numeroBr(r.total.plantasEsperadas, 0)} plantas esperadas',
                style: t(9, cor: _C.secundario),
              ),
            ),
          ],
        ),
        pw.ClipRRect(
          horizontalRadius: 5,
          verticalRadius: 5,
          child: pw.Row(
            children: [
              faixa(noLugar, _C.verde),
              faixa(pctFalhas, _C.falha),
              faixa(pctDuplas, _C.dupla),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Wrap(
          spacing: 6,
          children: [
            _indicador(
              'Falhas',
              '${r.total.plantasFaltando} · ${percentual(pctFalhas)}',
              cor: _C.falha,
            ),
            _indicador(
              'Duplas',
              '${r.total.plantasAMais} · ${percentual(pctDuplas)}',
              cor: _C.dupla,
            ),
            _indicador('CV', percentual(r.cvPercentual)),
            _indicador('Desvio padrão', '${numeroBr(r.desvioPadraoCm, 1)} cm'),
            _indicador(
              'Espaçamento médio',
              '${numeroBr(r.mediaCm, 1)} cm',
              detalhe:
                  'ideal ${numeroBr(id.parametros.espacamentoIdealCm, 1)} cm',
            ),
            _indicador(
              'Espaçamentos aceitáveis',
              percentual(aceitaveis),
              detalhe: '${espacamentos.length} medidos',
            ),
            _indicador(
              'População medida',
              '${numeroBr(populacaoMedida, 0)} pl/ha',
              detalhe: 'teórica ${numeroBr(id.parametros.populacaoPorHa, 0)}',
            ),
            _indicador('Plantas medidas', '${r.plantas}'),
          ],
        ),
        _nota(
          '"No lugar certo" conta plantas: cada falha abre vagas pelo tamanho '
          'do espaço e cada dupla é uma planta a mais. "Aceitáveis" conta '
          'espaçamentos entre 0,5× e 1,5× o ideal.',
        ),
      ],
    );
  }

  pw.Widget _indicador(
    String rotulo,
    String valor, {
    PdfColor cor = _C.secundario,
    String? detalhe,
  }) => pw.Container(
    width: 124,
    margin: const pw.EdgeInsets.only(bottom: 6),
    padding: const pw.EdgeInsets.fromLTRB(8, 5, 8, 5),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _C.borda, width: 0.75),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          rotulo.toUpperCase(),
          style: t(6.8, fonte: f.negrito, cor: cor, espaco: 0.4),
        ),
        pw.Text(valor, style: t(12, fonte: f.titulo)),
        if (detalhe != null)
          pw.Text(detalhe, style: t(7.5, cor: _C.secundario)),
      ],
    ),
  );

  /// Tabela por linha; a linha com mais falhas sai destacada.
  List<pw.Widget> porLinha() {
    final pior = r.linhaComMaisFalhas();
    const larguras = <double>[34, 42, 42, 50, 44, 40, 52, 44, 44];
    const cabecalhos = [
      'LINHA',
      'METROS',
      'PLANTAS',
      'MÉDIA CM',
      'DV CM',
      'CV',
      'ACEITÁV.',
      'FALHAS',
      'DUPLAS',
    ];
    pw.Widget celula(
      String texto,
      double largura, {
      pw.TextStyle? estilo,
      bool esquerda = false,
    }) => pw.SizedBox(
      width: largura,
      child: pw.Text(
        texto,
        textAlign: esquerda ? pw.TextAlign.left : pw.TextAlign.right,
        style: estilo ?? t(9.5),
      ),
    );

    pw.Widget linha(int i, LinhaAvaliada l) {
      final p = l.percentualNoLugarCerto;
      final res = l.resultado;
      final destaque = pior != null && pior.indice == i;
      final valores = [
        'L${i + 1}',
        numeroBr(l.comprimentoCm / 100, 1),
        '${l.plantas}',
        l.plantas < 2 ? '–' : numeroBr(res.mediaCm, 1),
        l.plantas < 2 ? '–' : numeroBr(res.desvioPadraoCm, 1),
        l.plantas < 2 ? '–' : percentual(res.cvPercentual, 0),
        percentual(res.percentualAceitaveis, 0),
        '${l.contagem.plantasFaltando}',
        '${l.contagem.plantasAMais}',
      ];
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: pw.BoxDecoration(
          color: destaque ? _C.atencaoClaro : null,
          border: const pw.Border(
            bottom: pw.BorderSide(color: _C.borda, width: 0.6),
          ),
        ),
        child: pw.Row(
          children: [
            for (final (k, v) in valores.indexed)
              celula(
                v,
                larguras[k],
                esquerda: k == 0,
                estilo: k == 0
                    ? t(9.5, fonte: f.semi)
                    : k == 7
                    ? t(9.5, fonte: f.semi, cor: _C.falha)
                    : k == 8
                    ? t(9.5, fonte: f.semi, cor: _C.dupla)
                    : null,
              ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Stack(
                children: [
                  pw.Container(height: 7, color: _C.neutroEscuro),
                  pw.Container(
                    height: 7,
                    width: 70 * (p / 100).clamp(0, 1),
                    color: _corDoPercentual(p),
                  ),
                ],
              ),
            ),
            pw.SizedBox(
              width: 38,
              child: pw.Text(
                percentual(p, 0),
                textAlign: pw.TextAlign.right,
                style: t(9.5, fonte: f.semi, cor: _corDoPercentual(p)),
              ),
            ),
          ],
        ),
      );
    }

    final cabecalho = pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _C.verdeEscuro)),
      ),
      child: pw.Row(
        children: [
          for (final (k, c) in cabecalhos.indexed)
            celula(
              c,
              larguras[k],
              esquerda: k == 0,
              estilo: t(6.8, fonte: f.negrito, cor: _C.secundario, espaco: 0.4),
            ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              'NO LUGAR CERTO',
              textAlign: pw.TextAlign.right,
              style: t(6.8, fonte: f.negrito, cor: _C.secundario, espaco: 0.4),
            ),
          ),
        ],
      ),
    );
    final lista = medidas;
    return [
      pw.Inseparable(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _rotulo('Por linha'),
            cabecalho,
            if (lista.isNotEmpty) linha(lista.first.$1, lista.first.$2),
          ],
        ),
      ),
      for (final (i, l) in lista.skip(1)) linha(i, l),
      if (pior != null)
        _nota(
          'Linha ${pior.indice + 1} tem ${numeroBr(pior.acimaDaMedia, 0)}% mais '
          'falhas que a média das linhas: conferir disco e dosador dessa linha.',
        ),
    ];
  }

  /// Histograma dos espaçamentos com a faixa aceitável.
  pw.Widget histograma() {
    final ideal = id.parametros.espacamentoIdealCm;
    final valores = [
      for (final (_, l) in medidas)
        for (final e in l.resultado.espacamentos) e.valorCm,
    ];
    final faixas = histogramaEspacamentos(valores, ideal);
    final maior = faixas.map((f) => f.quantidade).fold(0, math.max);
    const altura = 110.0;
    String limite(double v) => numeroBr(v, v < 10 ? 1 : 0);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _rotulo('Distribuição dos espaçamentos'),
        pw.Text(
          '${valores.length} espaçamentos. Ideal ${numeroBr(ideal, 1)} cm; '
          'aceitável de ${numeroBr(ideal * PlantabilidadeCalc.limiteDupla, 1)} '
          'a ${numeroBr(ideal * PlantabilidadeCalc.limiteFalha, 1)} cm.',
          style: t(9, cor: _C.secundario),
        ),
        pw.SizedBox(height: 8),
        pw.SizedBox(
          height: altura + 14,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              for (final fx in faixas)
                pw.Expanded(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      if (fx.quantidade > 0)
                        pw.Text(
                          '${fx.quantidade}',
                          style: t(7, cor: _C.secundario),
                        ),
                      pw.Container(
                        height: maior == 0
                            ? 0
                            : math.max(
                                fx.quantidade > 0 ? 1.5 : 0,
                                altura * fx.quantidade / maior,
                              ),
                        margin: const pw.EdgeInsets.symmetric(horizontal: 1.5),
                        color: _corDaClasse(fx.classe),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        pw.Container(height: 0.75, color: _C.secundario),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            for (final fx in faixas)
              pw.Expanded(
                child: pw.Text(
                  fx.fimCm == null
                      ? '${limite(fx.inicioCm)}+'
                      : limite(fx.inicioCm),
                  textAlign: pw.TextAlign.center,
                  style: t(6.8, cor: _C.secundario),
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          children: [
            for (final (nome, cor) in [
              ('Duplas (< 0,5× ideal)', _C.dupla),
              ('Aceitáveis', _C.verde),
              ('Falhas (> 1,5× ideal)', _C.falha),
            ]) ...[
              pw.Container(width: 8, height: 8, color: cor),
              pw.SizedBox(width: 4),
              pw.Text(nome, style: t(8, cor: _C.secundario)),
              pw.SizedBox(width: 14),
            ],
            pw.Spacer(),
            pw.Text('cm (início da faixa)', style: t(7.5, cor: _C.secundario)),
          ],
        ),
      ],
    );
  }

  /// Perda estimada nos três cenários.
  pw.Widget perda(Cultura cultura) {
    final p = calcularPerda(estado);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _rotulo('Perda estimada de produtividade'),
        pw.Row(
          children: [
            for (final (k, c) in Cenario.values.indexed) ...[
              if (k > 0) pw.SizedBox(width: 8),
              pw.Expanded(
                child: _cenarioCartao(
                  nomeCenario(c),
                  '${numeroBr(p.de(c).sacasHa, 1)} sc/ha',
                  '${numeroBr(p.de(c).percentual, 1)}% · '
                      '${numeroBr(p.de(c).kgHa, 0)} kg/ha',
                  c == cenario,
                ),
              ),
            ],
          ],
        ),
        _nota(
          '${_fonteDaPerda(cultura)} Produtividade esperada: '
          '${numeroBr(id.produtividadeScHa, 0)} sc/ha. Cenário em destaque: o '
          'escolhido no app.',
        ),
      ],
    );
  }

  pw.Widget _cenarioCartao(
    String nome,
    String valor,
    String detalhe,
    bool ativo,
  ) => pw.Container(
    padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 7),
    decoration: pw.BoxDecoration(
      color: ativo ? _C.prejuizoClaro : null,
      border: pw.Border.all(
        color: ativo ? _C.prejuizo : _C.borda,
        width: ativo ? 1.5 : 0.75,
      ),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          nome.toUpperCase(),
          style: t(
            7,
            fonte: f.negrito,
            cor: ativo ? _C.prejuizo : _C.secundario,
            espaco: 0.5,
          ),
        ),
        pw.Text(
          valor,
          style: t(16, fonte: f.titulo, cor: ativo ? _C.prejuizo : _C.tinta),
        ),
        pw.Text(detalhe, style: t(8, cor: _C.secundario)),
      ],
    ),
  );

  /// Prejuízo em R$ por hectare e na área, nos três cenários.
  pw.Widget prejuizoBloco(ResultadoPrejuizo pj) {
    final par = pj.parametros;
    pw.Widget celula(
      String texto, {
      bool cabecalho = false,
      bool ativo = false,
    }) => pw.Expanded(
      child: pw.Text(
        texto,
        textAlign: pw.TextAlign.right,
        style: cabecalho
            ? t(6.8, fonte: f.negrito, cor: _C.secundario, espaco: 0.4)
            : t(
                9.5,
                fonte: ativo ? f.semi : f.regular,
                cor: ativo ? _C.prejuizo : _C.tinta,
              ),
      ),
    );
    pw.Widget linha(
      String rotulo,
      List<String> valores, {
      bool total = false,
    }) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: pw.BoxDecoration(
        color: total ? _C.neutro : null,
        border: const pw.Border(
          bottom: pw.BorderSide(color: _C.borda, width: 0.6),
        ),
      ),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 170,
            child: pw.Text(
              rotulo,
              style: t(9.5, fonte: total ? f.semi : f.regular),
            ),
          ),
          for (final (k, v) in valores.indexed)
            celula(v, ativo: Cenario.values[k] == cenario),
        ],
      ),
    );
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _rotulo('Prejuízo estimado'),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _C.verdeEscuro)),
          ),
          child: pw.Row(
            children: [
              pw.SizedBox(width: 170),
              for (final c in Cenario.values)
                celula(nomeCenario(c).toUpperCase(), cabecalho: true),
            ],
          ),
        ),
        linha('Produtividade perdida (R\$/ha)', [
          for (final c in Cenario.values) reais(pj.de(c).produtividadeReaisHa),
        ]),
        linha('Sementes desperdiçadas (R\$/ha)', [
          for (final c in Cenario.values) reais(pj.de(c).sementesReaisHa),
        ]),
        linha('Prejuízo por hectare', [
          for (final c in Cenario.values) reais(pj.de(c).totalReaisHa),
        ], total: true),
        linha('Na área (${numeroBr(par.areaHa, 1)} ha)', [
          for (final c in Cenario.values) reais(pj.totalSafraReais(c), 0),
        ], total: true),
        _nota(
          'Saca a ${reais(par.precoSacaReais)}; saco de semente a '
          '${reais(par.precoSacoSementeReais)} com '
          '${numeroBr(par.sementesPorSaco, 0)} sementes. Desperdício: '
          '${numeroBr(pj.sementesExtrasHa, 0)} sementes/ha a mais nas duplas '
          '(só as duplas; sobreposição não entra).',
        ),
      ],
    );
  }

  /// Anexo com as leituras acumuladas da trena, linha a linha.
  List<pw.Widget> leituras() => [
    pw.Inseparable(child: _rotulo('Anexo · leituras da trena (cm acumulados)')),
    for (final (i, l) in medidas)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: 'L${i + 1} (${l.plantas}): ',
                style: t(7.5, fonte: f.semi),
              ),
              pw.TextSpan(
                text: [for (final v in l.leiturasCm) numeroBr(v, 1)].join('  '),
                style: t(7.2, cor: _C.secundario),
              ),
            ],
          ),
        ),
      ),
  ];
}
