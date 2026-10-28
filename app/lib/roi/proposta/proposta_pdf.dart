import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:roi/roi.dart';

import '../../ui/formatos.dart';
import 'proposta_dados.dart';

/// Fontes e imagens do PDF, carregadas uma vez dos assets.
class RecursosPdf {
  final pw.Font regular;
  final pw.Font medio;
  final pw.Font semi;
  final pw.Font negrito;
  final pw.Font titulo;
  final Uint8List logo;
  final Map<ProdutoProposta, Uint8List> imagens;

  const RecursosPdf({
    required this.regular,
    required this.medio,
    required this.semi,
    required this.negrito,
    required this.titulo,
    required this.logo,
    required this.imagens,
  });

  static Future<RecursosPdf> carregar([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    Future<pw.Font> fonte(String nome) async =>
        pw.Font.ttf(await b.load('assets/fonts/$nome.ttf'));
    Future<Uint8List> bytes(String caminho) async =>
        (await b.load(caminho)).buffer.asUint8List();
    return RecursosPdf(
      regular: await fonte('Barlow-Regular'),
      medio: await fonte('Barlow-Medium'),
      semi: await fonte('Barlow-SemiBold'),
      negrito: await fonte('Barlow-Bold'),
      titulo: await fonte('BarlowSemiCondensed-Bold'),
      logo: await bytes('assets/proposta/logo_jassy.png'),
      imagens: {
        for (final p in ProdutoProposta.values)
          p: await _paraPng(await bytes(p.imagem)),
      },
    );
  }
}

/// O PDF não lê WebP: decodifica e regrava em PNG.
Future<Uint8List> _paraPng(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes, targetWidth: 640);
  final quadro = await codec.getNextFrame();
  final png = await quadro.image.toByteData(format: ui.ImageByteFormat.png);
  quadro.image.dispose();
  return png!.buffer.asUint8List();
}

abstract final class _C {
  static const tinta = PdfColor.fromInt(0xFF1D1D1B);
  static const secundario = PdfColor.fromInt(0xFF5F6165);
  static const verde = PdfColor.fromInt(0xFF2AA437);
  static const verdeVivo = PdfColor.fromInt(0xFF21DD12);
  static const verdeEscuro = PdfColor.fromInt(0xFF112C02);
  static const verdeTexto = PdfColor.fromInt(0xFF1D7A28);
  static const verdeClaro = PdfColor.fromInt(0xFFE5F5E7);
  static const verdeSuave = PdfColor.fromInt(0xFFBFD9B9);
  static const cinza = PdfColor.fromInt(0xFFA2A8AD);
  static const cinzaEscuro = PdfColor.fromInt(0xFF75777B);
  static const neutro = PdfColor.fromInt(0xFFE8EAEB);
  static const borda = PdfColor.fromInt(0xFFDCDFE1);
  static const branco = PdfColors.white;

  // Tons já misturados sobre o verde-escuro (o PDF fica sem transparência).
  static const areaGrafico = PdfColor.fromInt(0xFF1A5614);
  static const gradeGrafico = PdfColor.fromInt(0xFF2E4520);
  static const divisorEscuro = PdfColor.fromInt(0xFF35482B);
}

const _meses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

String _dataExtensa(DateTime d) =>
    '${d.day} de ${_meses[d.month - 1]} de ${d.year}';
String _mil(double v) => 'R\$ ${numeroBr(v / 1000, 0)} mil';
String _safras(double? v) =>
    v == null ? '–' : '${numeroBr(v, 1)} ${v >= 2 ? 'safras' : 'safra'}';
String _pct(double? v, [int casas = 0]) =>
    v == null ? '–' : percentual(v * 100, casas);

/// Gera a proposta comercial com o ROI: proposta, retorno, produto, condições
/// e anexo com as premissas. O investimento do ROI é o total da proposta.
Future<Uint8List> gerarPropostaPdf({
  required DadosProposta dados,
  required PremissasRoi premissas,
  required CenarioRoi cenario,
  required RecursosPdf recursos,
}) {
  final p = premissasDaProposta(premissas, dados);
  final r = CalculadoraRoi.calcular(p);
  final doc = pw.Document(
    title: 'Proposta comercial – ${dados.cliente}',
    author: 'J.Assy',
    theme: pw.ThemeData.withFont(
      base: recursos.regular,
      bold: recursos.negrito,
    ),
  );
  final m = _Montador(dados, p, r, cenario, recursos);
  final paginas = [m.proposta, m.retorno, m.produto, m.condicoes, m.anexo];
  for (var i = 0; i < paginas.length; i++) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(34, 26, 34, 20),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            m.topo(capa: i == 0),
            pw.SizedBox(height: 14),
            pw.Expanded(child: paginas[i]()),
            m.rodape(i, paginas.length),
          ],
        ),
      ),
    );
  }
  return doc.save();
}

class _Montador {
  final DadosProposta d;
  final PremissasRoi p;
  final ResultadoRoi r;
  final CenarioRoi cenario;
  final RecursosPdf f;

  _Montador(this.d, this.p, this.r, this.cenario, this.f);

  ResultadoCenario get c => r.cenarios[cenario]!;
  bool get temComparativo => p.concorrente > 0 || p.plantadeiraNova > 0;

  pw.TextStyle _t(
    double tamanho, {
    pw.Font? fonte,
    PdfColor cor = _C.tinta,
    double? espaco,
    double? altura,
  }) => pw.TextStyle(
    font: fonte ?? f.regular,
    fontSize: tamanho,
    color: cor,
    letterSpacing: espaco,
    lineSpacing: altura,
  );

  pw.Widget _icone(
    IconeProposta i, {
    PdfColor cor = _C.verdeTexto,
    double t = 16,
  }) => pw.SvgImage(svg: i.svg(_hex(cor)), width: t, height: t);

  pw.Widget _iconeRedondo(IconeProposta i, double t) => pw.Container(
    width: t,
    height: t,
    alignment: pw.Alignment.center,
    decoration: const pw.BoxDecoration(
      color: _C.verdeClaro,
      shape: pw.BoxShape.circle,
    ),
    child: _icone(i, t: t * 0.55),
  );

  pw.Widget _rotulo(String texto) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(
      texto.toUpperCase(),
      style: _t(8.2, fonte: f.negrito, cor: _C.secundario, espaco: 0.7),
    ),
  );

  pw.Widget _tituloPagina(String sobre, String titulo) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        sobre.toUpperCase(),
        style: _t(9, fonte: f.semi, cor: _C.verdeTexto, espaco: 0.7),
      ),
      pw.Text(titulo, style: _t(20, fonte: f.titulo)),
    ],
  );

  /// Barra horizontal proporcional, sem depender da largura disponível.
  pw.Widget _barra(
    double fracao,
    PdfColor cor,
    double altura, {
    pw.Widget? texto,
  }) {
    final cheio = (fracao.clamp(0.0, 1.0) * 1000).round();
    return pw.ClipRRect(
      horizontalRadius: 2,
      verticalRadius: 2,
      child: pw.Container(
        height: altura,
        color: _C.neutro,
        child: pw.Stack(
          children: [
            pw.Row(
              children: [
                if (cheio > 0)
                  pw.Expanded(
                    flex: cheio,
                    child: pw.Container(color: cor),
                  ),
                if (cheio < 1000)
                  pw.Expanded(flex: 1000 - cheio, child: pw.SizedBox()),
              ],
            ),
            if (texto != null)
              pw.Positioned(left: 6, top: (altura - 10) / 2, child: texto),
          ],
        ),
      ),
    );
  }

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
              ? '${d.cidade}, ${_dataExtensa(d.data)}'
              : '${d.cliente} · Proposta comercial',
          style: _t(9, cor: _C.secundario),
        ),
      ],
    ),
  );

  pw.Widget rodape(int i, int total) {
    const textos = [
      'Apresentamos nossa proposta para o fornecimento dos produtos acima. '
          'Condições na página 4.',
      'Estimativa calculada com as premissas informadas pelo cliente '
          '(página 5). Não é garantia de resultado.',
      'Resultados de pesquisa citados conforme as fontes indicadas. Na sua '
          'fazenda, meça com a Avaliação de plantio.',
      'Faturamento sujeito à análise de crédito.',
      'Estimativa calculada com as premissas acima, informadas pelo cliente. '
          'Não é garantia de resultado.',
    ];
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _C.borda, width: 0.75)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(textos[i], style: _t(7.8, cor: _C.secundario)),
          ),
          pw.SizedBox(width: 16),
          pw.Text(
            'Página ${i + 1} de $total',
            style: _t(7.8, cor: _C.secundario),
          ),
        ],
      ),
    );
  }

  // 1. Proposta -------------------------------------------------------------

  pw.Widget proposta() {
    final dadosCliente = [
      ('CPF/CNPJ', d.documento),
      ('Insc. Est.', d.inscricao),
      ('Tel.', d.telefone),
      ('E-mail', d.email),
    ].where((x) => x.$2.trim().isNotEmpty).toList();
    final caracts = d.produto.caracteristicas;
    final impostos = d.impostos.trim();

    pw.Widget caixaValor(
      String t,
      String v,
      String nota, {
      bool total = false,
    }) => pw.Expanded(
      flex: total ? 13 : 10,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: total
            ? null
            : const pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: _C.divisorEscuro),
                ),
              ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              t.toUpperCase(),
              style: _t(8, fonte: f.semi, cor: _C.verdeSuave, espaco: 0.5),
            ),
            pw.Text(
              v,
              style: _t(
                total ? 24 : 19,
                fonte: f.titulo,
                cor: total ? _C.verdeVivo : _C.branco,
              ),
            ),
            if (nota.isNotEmpty)
              pw.Text(nota, style: _t(8.5, cor: _C.verdeClaro)),
          ],
        ),
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _tituloPagina('Proposta comercial', 'Modernização da plantadeira'),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: pw.BoxDecoration(
            color: _C.neutro,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PREPARADO PARA',
                style: _t(8, fonte: f.semi, cor: _C.secundario, espaco: 0.5),
              ),
              pw.Text(d.cliente, style: _t(14, fonte: f.titulo)),
              if (dadosCliente.isNotEmpty) pw.SizedBox(height: 3),
              pw.Wrap(
                spacing: 18,
                runSpacing: 2,
                children: [
                  for (final (rotulo, valor) in dadosCliente)
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: '$rotulo: ',
                            style: _t(9.5, cor: _C.secundario),
                          ),
                          pw.TextSpan(
                            text: valor,
                            style: _t(9.5, fonte: f.semi),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 168,
              height: 168,
              decoration: pw.BoxDecoration(
                color: _C.verdeClaro,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Stack(
                alignment: pw.Alignment.center,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Image(pw.MemoryImage(f.imagens[d.produto]!)),
                  ),
                  pw.Positioned(
                    bottom: 4,
                    child: pw.Text(
                      'Foto meramente ilustrativa',
                      style: _t(6.5, cor: _C.secundario),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${d.linhas} ${d.produto.itemProposta[d.fornecimento]}'
                        .toUpperCase(),
                    style: _t(
                      9.5,
                      fonte: f.negrito,
                      cor: _C.verdeTexto,
                      espaco: 0.4,
                    ),
                  ),
                  pw.Text(d.produto.nome, style: _t(26, fonte: f.titulo)),
                  pw.SizedBox(height: 4),
                  pw.Text(d.produto.descricao, style: _t(9.8, altura: 1.5)),
                  pw.SizedBox(height: 8),
                  for (var i = 0; i < caracts.length; i += 2)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Row(
                        children: [
                          for (final (icone, texto) in caracts.skip(i).take(2))
                            pw.Expanded(
                              child: pw.Row(
                                children: [
                                  _iconeRedondo(icone, 20),
                                  pw.SizedBox(width: 6),
                                  pw.Expanded(
                                    child: pw.Text(
                                      texto,
                                      style: _t(9, fonte: f.medio),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _C.borda, width: 0.75),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            children: [
              _icone(IconeProposta.ferramenta, t: 18),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.RichText(
                  text: pw.TextSpan(
                    style: _t(10),
                    children: [
                      const pw.TextSpan(text: 'Será instalado na plantadeira '),
                      pw.TextSpan(
                        text: '${d.plantadeira} de ${d.linhas} linhas',
                        style: _t(10, fonte: f.negrito),
                      ),
                      const pw.TextSpan(
                        text: ', na fazenda, pela equipe da J.Assy.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 14),
        pw.Container(
          decoration: pw.BoxDecoration(
            color: _C.verdeEscuro,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              caixaValor('Valor por linha', reais(d.valorLinha), impostos),
              caixaValor('Linhas', '${d.linhas}', d.plantadeira),
              caixaValor(
                'Valor total',
                reais(d.total),
                [valorPorExtenso(d.total), impostos].join(' ').trim(),
                total: true,
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        if (c.payback != null)
          pw.Container(
            padding: const pw.EdgeInsets.only(left: 10, top: 3, bottom: 3),
            decoration: const pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(color: _C.verde, width: 3)),
            ),
            child: pw.Row(
              children: [
                _icone(IconeProposta.calendario, cor: _C.verde, t: 22),
                pw.SizedBox(width: 9),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      style: _t(10.5),
                      children: [
                        pw.TextSpan(
                          text:
                              'No cenário ${cenario.nome.toLowerCase()}, o '
                              'investimento se paga em ',
                        ),
                        pw.TextSpan(
                          text: _safras(c.payback),
                          style: _t(14, fonte: f.titulo, cor: _C.verdeTexto),
                        ),
                        const pw.TextSpan(text: ' e devolve '),
                        pw.TextSpan(
                          text: _mil(c.beneficioHorizonte),
                          style: _t(14, fonte: f.titulo, cor: _C.verdeTexto),
                        ),
                        pw.TextSpan(
                          text:
                              ' em ${numeroBr(p.vidaSafras, 0)} safras. Veja '
                              'na página 2.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // 2. Retorno --------------------------------------------------------------

  pw.Widget retorno() {
    final fontes = [
      (
        'Plantabilidade',
        c.plantabilidade,
        _C.verdeEscuro,
        'Menos falhas e duplas',
      ),
      (
        'Taxa variável',
        r.fixos.taxaVariavel,
        _C.verdeTexto,
        'Semente na dose certa',
      ),
      (
        'Sobreposição',
        r.fixos.sobreposicao,
        _C.verde,
        'Linha a linha nas cabeceiras',
      ),
      ('Operação', r.fixos.operacao, _C.cinzaEscuro, 'Manutenção e operação'),
      ('Curvas', r.fixos.curvas, _C.cinza, 'Espaçamento nas curvas'),
    ].where((x) => x.$2 > 0).toList();
    final soma = fontes.fold(0.0, (s, x) => s + x.$2);
    final maior = CenarioRoi.values
        .map((x) => r.cenarios[x]!.beneficioSafra)
        .fold(0.0, math.max);

    pw.Widget pilula(IconeProposta i, String v, String t) => pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _C.borda, width: 0.75),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Row(
          children: [
            _icone(i, cor: _C.verde, t: 21),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(v, style: _t(17, fonte: f.titulo)),
                  pw.Text(t, style: _t(8.5, cor: _C.secundario)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _tituloPagina(
          'Retorno do investimento',
          'Quanto o retrofit devolve para a fazenda',
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: _C.verdeEscuro,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 10,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Com o ${d.produto.nome}, a fazenda ganha em '
                      '${numeroBr(p.vidaSafras, 0)} safras',
                      style: _t(9.8, cor: _C.verdeSuave),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _mil(c.beneficioHorizonte),
                      style: _t(34, fonte: f.titulo, cor: _C.branco),
                    ),
                    pw.Text(
                      '${_mil(c.beneficioSafra)} por safra, para um '
                      'investimento de ${_mil(p.investimento)}.',
                      style: _t(10.5, cor: _C.verdeClaro),
                    ),
                    pw.SizedBox(height: 9),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      color: _C.divisorEscuro,
                      child: pw.Text(
                        'CENÁRIO ${cenario.nome.toUpperCase()}',
                        style: _t(
                          8,
                          fonte: f.semi,
                          cor: _C.verdeClaro,
                          espaco: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(flex: 13, child: _graficoPayback()),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pilula(
              IconeProposta.calendario,
              _safras(c.payback),
              'para o investimento se pagar',
            ),
            pw.SizedBox(width: 8),
            pilula(
              IconeProposta.curva,
              _pct(c.roiAnual),
              'de retorno por safra sobre o investimento',
            ),
            pw.SizedBox(width: 8),
            pilula(
              IconeProposta.mapa,
              p.areaHa > 0
                  ? 'R\$ ${numeroBr(c.beneficioSafra / p.areaHa, 0)}/ha'
                  : '–',
              'de ganho por hectare em cada safra',
            ),
          ],
        ),
        pw.SizedBox(height: 18),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _rotulo('De onde vem o ganho por safra'),
                  pw.Row(
                    children: [
                      _graficoRosca([
                        for (final x in fontes) (x.$2, x.$3),
                      ], soma),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            for (final (nome, v, cor, nota) in fontes)
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 4),
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Container(
                                      width: 7,
                                      height: 7,
                                      margin: const pw.EdgeInsets.only(top: 2),
                                      color: cor,
                                    ),
                                    pw.SizedBox(width: 6),
                                    pw.Expanded(
                                      child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(nome, style: _t(9.5)),
                                          pw.Text(
                                            nota,
                                            style: _t(8, cor: _C.secundario),
                                          ),
                                        ],
                                      ),
                                    ),
                                    pw.Text(
                                      _pct(v / soma),
                                      style: _t(9.5, fonte: f.negrito),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _rotulo('Ganho por safra em cada cenário'),
                  for (final x in CenarioRoi.values)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 66,
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 3),
                              child: pw.Text(
                                x.nome,
                                style: _t(
                                  9.5,
                                  fonte: x == cenario ? f.negrito : f.regular,
                                ),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                              children: [
                                _barra(
                                  maior > 0
                                      ? r.cenarios[x]!.beneficioSafra / maior
                                      : 0,
                                  x == cenario ? _C.verde : _C.cinza,
                                  16,
                                  texto: pw.Text(
                                    _mil(r.cenarios[x]!.beneficioSafra),
                                    style: _t(
                                      8.5,
                                      fonte: f.negrito,
                                      cor: _C.branco,
                                    ),
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  'Paga em ${_safras(r.cenarios[x]!.payback)} · '
                                  'recupera ${_pct(x.recuperacao, 1)} da receita',
                                  style: _t(8, cor: _C.secundario),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Ganho acumulado safra a safra contra a linha do investimento.
  pw.Widget _graficoPayback() {
    const w = 270.0, h = 142.0, ml = 36.0, mr = 8.0, mt = 12.0, mb = 20.0;
    const iw = w - ml - mr, ih = h - mt - mb;
    final vida = math.max(1, p.vidaSafras.round());
    final topo = math.max(c.beneficioSafra * vida, p.investimento) * 1.08;
    final passo = topo > 1.2e6
        ? 500000.0
        : (topo > 500000 ? 250000.0 : 100000.0);
    double x(double s) => ml + s / vida * iw;
    double y(double v) => mt + ih - (topo > 0 ? v / topo * ih : 0); // de cima

    final rotulos = <pw.Widget>[];
    for (var v = 0.0; v <= topo; v += passo) {
      rotulos.add(
        pw.Positioned(
          left: 0,
          top: y(v) - 5,
          child: pw.SizedBox(
            width: ml - 5,
            child: pw.Text(
              v == 0 ? '0' : '${numeroBr(v / 1000, 0)} mil',
              textAlign: pw.TextAlign.right,
              style: _t(7, cor: _C.verdeSuave),
            ),
          ),
        ),
      );
    }
    for (var s = 0; s <= vida; s++) {
      rotulos.add(
        pw.Positioned(
          left: x(s.toDouble()) - 20,
          top: h - 13,
          child: pw.SizedBox(
            width: 40,
            child: pw.Text(
              s == 0 ? 'Hoje' : '$sª safra',
              textAlign: pw.TextAlign.center,
              style: _t(7, cor: _C.verdeSuave),
            ),
          ),
        ),
      );
    }
    rotulos.add(
      pw.Positioned(
        left: ml + 3,
        top: y(p.investimento) - 12,
        child: pw.Text(
          'Investimento ${_mil(p.investimento)}',
          style: _t(7.8, fonte: f.semi, cor: _C.branco),
        ),
      ),
    );
    final pb = c.payback;
    if (pb != null && pb <= vida) {
      final px = x(pb);
      final aDireita = px > w - 90;
      rotulos.add(
        pw.Positioned(
          left: aDireita ? px - 96 : px + 7,
          top: y(p.investimento) + 5,
          child: pw.SizedBox(
            width: 90,
            child: pw.Text(
              'Pago em ${_safras(pb)}',
              textAlign: aDireita ? pw.TextAlign.right : pw.TextAlign.left,
              style: _t(8.2, fonte: f.negrito, cor: _C.branco),
            ),
          ),
        ),
      );
    }

    return pw.SizedBox(
      width: w,
      height: h,
      child: pw.Stack(
        children: [
          pw.CustomPaint(
            size: const PdfPoint(w, h),
            painter: (g, _) {
              double yy(double v) => h - y(v); // origem do PDF embaixo
              g.setLineWidth(0.6);
              g.setStrokeColor(_C.gradeGrafico);
              for (var v = 0.0; v <= topo; v += passo) {
                g.moveTo(ml, yy(v));
                g.lineTo(w - mr, yy(v));
              }
              g.strokePath();

              g.setFillColor(_C.areaGrafico);
              g.moveTo(x(0), yy(0));
              for (var s = 0; s <= vida; s++) {
                g.lineTo(x(s.toDouble()), yy(c.beneficioSafra * s));
              }
              g.lineTo(x(vida.toDouble()), yy(0));
              g.closePath();
              g.fillPath();

              g.setStrokeColor(_C.verdeVivo);
              g.setLineWidth(1.8);
              g.moveTo(x(0), yy(0));
              for (var s = 1; s <= vida; s++) {
                g.lineTo(x(s.toDouble()), yy(c.beneficioSafra * s));
              }
              g.strokePath();

              g.setStrokeColor(_C.branco);
              g.setLineWidth(1.1);
              g.setLineDashPattern([4, 3]);
              g.moveTo(ml, yy(p.investimento));
              g.lineTo(w - mr, yy(p.investimento));
              g.strokePath();
              g.setLineDashPattern();

              if (pb != null && pb <= vida) {
                g.setLineWidth(0.7);
                g.moveTo(x(pb), yy(p.investimento));
                g.lineTo(x(pb), yy(0));
                g.strokePath();
                g.setFillColor(_C.verdeEscuro);
                g.drawEllipse(x(pb), yy(p.investimento), 5.5, 5.5);
                g.fillPath();
                g.setFillColor(_C.verdeVivo);
                g.drawEllipse(x(pb), yy(p.investimento), 4, 4);
                g.fillPath();
              }
              g.setFillColor(_C.verdeVivo);
              g.drawEllipse(
                x(vida.toDouble()),
                yy(c.beneficioSafra * vida),
                3,
                3,
              );
              g.fillPath();
            },
          ),
          ...rotulos,
        ],
      ),
    );
  }

  /// Rosca da composição do ganho, desenhada em segmentos de anel.
  pw.Widget _graficoRosca(List<(double, PdfColor)> partes, double soma) {
    const t = 108.0, raio = 50.0, espessura = 19.0;
    return pw.SizedBox(
      width: t,
      height: t,
      child: pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          pw.CustomPaint(
            size: const PdfPoint(t, t),
            painter: (g, _) {
              if (soma <= 0) return;
              const cx = t / 2, cy = t / 2, ri = raio - espessura;
              var inicio = math.pi / 2; // começa no topo, sentido horário
              for (final (v, cor) in partes) {
                final angulo = v / soma * 2 * math.pi;
                final folga = partes.length > 1 ? 0.025 : 0.0;
                final a0 = inicio - folga / 2, a1 = inicio - angulo + folga / 2;
                final passos = math.max(4, (angulo / 0.05).ceil());
                g.setFillColor(cor);
                for (var i = 0; i <= passos; i++) {
                  final a = a0 + (a1 - a0) * i / passos;
                  final px = cx + raio * math.cos(a),
                      py = cy + raio * math.sin(a);
                  i == 0 ? g.moveTo(px, py) : g.lineTo(px, py);
                }
                for (var i = passos; i >= 0; i--) {
                  final a = a0 + (a1 - a0) * i / passos;
                  g.lineTo(cx + ri * math.cos(a), cy + ri * math.sin(a));
                }
                g.closePath();
                g.fillPath();
                inicio -= angulo;
              }
            },
          ),
          pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(_mil(soma), style: _t(12.5, fonte: f.titulo)),
              pw.Text('por safra', style: _t(7.5, cor: _C.secundario)),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Produto --------------------------------------------------------------

  pw.Widget produto() {
    final itens = d.produto.sistema[d.fornecimento]!;
    final porColuna = (itens.length / 3).ceil();
    final beneficios = d.produto.beneficios;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _tituloPagina('O que muda na plantadeira', d.produto.nome),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.only(left: 10, top: 4, bottom: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: _C.verde, width: 3)),
          ),
          child: pw.Row(
            children: [
              pw.Text(
                d.produto.provaNumero,
                style: _t(30, fonte: f.titulo, cor: _C.verdeTexto),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(d.produto.provaTexto, style: _t(10.5)),
                    pw.Text(
                      d.produto.provaFonte,
                      style: _t(8, cor: _C.secundario),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        _rotulo('Benefícios para a fazenda'),
        for (var i = 0; i < beneficios.length; i += 2)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (final (j, b) in beneficios.skip(i).take(2).indexed) ...[
                  if (j > 0) pw.SizedBox(width: 8),
                  pw.Expanded(child: _cartaoBeneficio(b)),
                ],
              ],
            ),
          ),
        pw.SizedBox(height: 10),
        _rotulo('O sistema é composto por'),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (var col = 0; col < 3; col++) ...[
              if (col > 0) pw.SizedBox(width: 14),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    for (final item
                        in itens.skip(col * porColuna).take(porColuna))
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 3.5),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: _C.borda, width: 0.5),
                          ),
                        ),
                        child: pw.Row(
                          children: [
                            _icone(IconeProposta.check, cor: _C.verde, t: 10),
                            pw.SizedBox(width: 6),
                            pw.Expanded(child: pw.Text(item, style: _t(9.5))),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: pw.BoxDecoration(
            color: _C.neutro,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.RichText(
            text: pw.TextSpan(
              style: _t(8.8),
              children: [
                const pw.TextSpan(
                  text:
                      'Para o desligamento linha a linha e a taxa variável, o ',
                ),
                pw.TextSpan(
                  text: 'Controlador de Tarefas',
                  style: _t(8.8, fonte: f.negrito),
                ),
                const pw.TextSpan(
                  text:
                      ' precisa estar liberado no monitor do trator. A '
                      'liberação é feita pela concessionária.',
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: pw.BoxDecoration(
            color: _C.verdeClaro,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            children: [
              _icone(IconeProposta.escudo, t: 24),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Solução completa J.Assy',
                      style: _t(11.5, fonte: f.titulo),
                    ),
                    pw.Text(
                      'Dosador e motor elétrico no mesmo pacote, com um '
                      'fornecedor só respondendo pelos dois. O motor sozinho '
                      'não corrige um dosador gasto.',
                      style: _t(9.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _cartaoBeneficio(BeneficioProduto b) {
    final valor = b.fonte == null ? null : valorDaFonte(r, cenario, b.fonte!);
    final rotulo = switch (b.fonte) {
      FonteRoi.plantabilidade => 'em plantabilidade',
      FonteRoi.sobreposicao => 'em sobreposição',
      FonteRoi.taxaVariavel => 'em semente',
      FonteRoi.curvas => 'nas curvas',
      FonteRoi.operacao => 'em operação',
      null => '',
    };
    return pw.Container(
      height: 92,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _C.borda, width: 0.75),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _iconeRedondo(b.icone, 28),
          pw.SizedBox(width: 9),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(b.titulo, style: _t(12, fonte: f.titulo)),
                pw.SizedBox(height: 2),
                pw.Text(b.texto, style: _t(8.8, cor: _C.secundario)),
                if (valor != null && valor > 0) ...[
                  pw.Spacer(),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    color: _C.verdeClaro,
                    child: pw.Text(
                      '${_mil(valor)} por safra $rotulo',
                      style: _t(8.8, fonte: f.negrito, cor: _C.verdeTexto),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Condições ------------------------------------------------------------

  pw.Widget condicoes() {
    final impostos = d.impostos.trim();
    final valores = d.valoresPagamento;
    final etapas = [
      if (d.entrada > 0) ('Entrada', d.entrada, 'Na assinatura'),
      for (final (i, x) in d.parcelas.indexed)
        ('${i + 1}ª parcela', x.fracao, x.quando),
    ];
    final linhas = [
      ('Validade da proposta', d.validade),
      ('Prazo de entrega', d.prazo),
      ('Local de entrega', d.local),
      ('Agente financeiro', d.agente),
    ].where((x) => x.$2.trim().isNotEmpty).toList();

    pw.Widget condicao((String, String) x) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _C.neutro)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(x.$1, style: _t(10, cor: _C.secundario)),
          ),
          pw.Text(x.$2, style: _t(10, fonte: f.semi)),
        ],
      ),
    );

    pw.Widget termo(IconeProposta i, String titulo, String texto) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _icone(i, t: 17),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                style: _t(9.5),
                children: [
                  pw.TextSpan(
                    text: '$titulo ',
                    style: _t(9.5, fonte: f.negrito),
                  ),
                  pw.TextSpan(text: texto),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    pw.Widget assinatura(String nome, String detalhe) => pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.only(top: 5),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _C.tinta, width: 0.75)),
        ),
        child: pw.Column(
          children: [
            pw.Text(nome, style: _t(9.5, fonte: f.negrito)),
            pw.Text(
              detalhe,
              textAlign: pw.TextAlign.center,
              style: _t(8.5, cor: _C.secundario),
            ),
          ],
        ),
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _tituloPagina('Condições', 'Valor e forma de pagamento'),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: pw.BoxDecoration(
            color: _C.verdeEscuro,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'VALOR TOTAL DA PROPOSTA',
                    style: _t(
                      8.5,
                      fonte: f.semi,
                      cor: _C.verdeSuave,
                      espaco: 0.5,
                    ),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: reais(d.total),
                          style: _t(25, fonte: f.titulo, cor: _C.verdeVivo),
                        ),
                        if (impostos.isNotEmpty)
                          pw.TextSpan(
                            text: '  $impostos',
                            style: _t(13, fonte: f.titulo, cor: _C.branco),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Text(
                  [valorPorExtenso(d.total), impostos].join(' ').trim(),
                  textAlign: pw.TextAlign.right,
                  style: _t(9.8, cor: _C.verdeClaro),
                ),
              ),
            ],
          ),
        ),
        if (etapas.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _rotulo('Pagamento'),
          pw.Stack(
            children: [
              pw.Positioned(
                left: 30,
                right: 30,
                top: 11,
                child: pw.Container(height: 2, color: _C.borda),
              ),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  for (final (i, (nome, fracao, quando)) in etapas.indexed)
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Container(
                            width: 24,
                            height: 24,
                            alignment: pw.Alignment.center,
                            decoration: pw.BoxDecoration(
                              color: i == 0 ? _C.verdeEscuro : _C.verde,
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(color: _C.branco, width: 2),
                            ),
                            child: pw.Text(
                              _pct(fracao),
                              style: _t(7.5, fonte: f.titulo, cor: _C.branco),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            nome.toUpperCase(),
                            style: _t(
                              8,
                              fonte: f.semi,
                              cor: _C.secundario,
                              espaco: 0.4,
                            ),
                          ),
                          pw.Text(
                            reais(valores[i]),
                            style: _t(14, fonte: f.titulo),
                          ),
                          pw.Text(quando, style: _t(9, cor: _C.secundario)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
        if (linhas.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          for (var i = 0; i < linhas.length; i += 2)
            pw.Row(
              children: [
                pw.Expanded(child: condicao(linhas[i])),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: i + 1 < linhas.length
                      ? condicao(linhas[i + 1])
                      : pw.SizedBox(),
                ),
              ],
            ),
        ],
        pw.SizedBox(height: 16),
        termo(
          IconeProposta.ferramenta,
          'Instalação:',
          'os equipamentos são instalados na fazenda pela equipe da J.Assy, '
              'com entrega técnica e laudo técnico de responsabilidade pelo '
              'funcionamento.',
        ),
        if (d.garantia.trim().isNotEmpty)
          termo(
            IconeProposta.escudo,
            'Garantia:',
            'equipamentos com ${d.garantia.trim()} de garantia.',
          ),
        pw.Spacer(),
        pw.Row(
          children: [
            assinatura(
              d.consultor,
              [
                'Consultor J.Assy',
                d.contatoConsultor,
              ].where((x) => x.trim().isNotEmpty).join(' · '),
            ),
            pw.SizedBox(width: 36),
            assinatura(d.cliente, 'De acordo'),
          ],
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  // 5. Anexo ----------------------------------------------------------------

  pw.Widget anexo() {
    final alternativas = [
      (
        'Retrofit J.Assy',
        p.investimento,
        _C.verde,
        '${d.produto.nome} na plantadeira atual',
      ),
      if (temComparativo) ...[
        (
          'Concorrente',
          p.concorrente,
          _C.cinzaEscuro,
          'Escopo e funcionalidades a comparar',
        ),
        (
          'Plantadeira nova',
          r.alternativa(Alternativa.plantadeiraNova).investimento,
          _C.verdeEscuro,
          'Capital a mais depois de vender a atual',
        ),
      ],
    ];
    final maior = alternativas.map((a) => a.$2).fold(0.0, math.max);
    final grupos = [
      (
        'Fazenda e produção',
        [
          ('Área plantada', '${numeroBr(p.areaHa, 0)} ha'),
          ('Linhas', numeroBr(p.linhas, 0)),
          ('Produtividade', '${numeroBr(p.produtividadeScHa, 0)} sc/ha'),
          ('Preço da saca', reais(p.precoSaca)),
        ],
      ),
      (
        'Sementes',
        [
          ('População', '${numeroBr(p.populacao, 0)}/ha'),
          ('Semente', '${reais(p.precoMilSementes)}/mil'),
          ('Sobreposição', _pct(p.sobreposicao, 1)),
          ('Redução esperada', _pct(p.reducaoSobreposicao)),
        ],
      ),
      (
        'Taxa variável',
        [
          ('Área da zona', '${numeroBr(p.areaZonaHa, 0)} ha'),
          ('População atual', '${numeroBr(p.populacaoAtualZona, 0)}/ha'),
          ('Prescrita', '${numeroBr(p.populacaoPrescrita, 0)}/ha'),
        ],
      ),
      (
        'Curvas e operação',
        [
          ('Área em curvas', _pct(p.areaCurvas, 1)),
          ('Perda sem compensação', _pct(p.perdaCurvas, 1)),
          ('Economia operacional', '${reais(p.economiaOperacional, 0)}/safra'),
        ],
      ),
      (
        'Investimento',
        [
          ('Retrofit J.Assy (proposta)', reais(p.investimento, 0)),
          if (temComparativo) ...[
            ('Concorrente', reais(p.concorrente, 0)),
            ('Plantadeira nova', reais(p.plantadeiraNova, 0)),
            ('Plantadeira atual', reais(p.valorPlantadeiraAtual, 0)),
          ],
          ('Vida econômica', '${numeroBr(p.vidaSafras, 0)} safras'),
        ],
      ),
      (
        'Cenário escolhido',
        [
          ('Cenário', cenario.nome),
          ('Recuperação da receita', _pct(cenario.recuperacao, 1)),
          ('Receita bruta da área', reais(r.receitaBruta, 0)),
        ],
      ),
    ];

    pw.Widget grupo((String, List<(String, String)>) g) => pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            g.$1.toUpperCase(),
            style: _t(8, fonte: f.negrito, cor: _C.verdeTexto, espaco: 0.5),
          ),
          pw.SizedBox(height: 3),
          for (final (rotulo, valor) in g.$2)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: _C.borda, width: 0.5),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(rotulo, style: _t(8.8, cor: _C.secundario)),
                  ),
                  pw.Text(valor, style: _t(8.8, fonte: f.semi)),
                ],
              ),
            ),
        ],
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _tituloPagina('Anexo', 'Base do cálculo de retorno'),
        pw.SizedBox(height: 14),
        if (temComparativo) ...[
          _rotulo('Quanto custa cada caminho'),
          for (final (nome, valor, cor, nota) in alternativas)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 7),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 96,
                    child: pw.Text(nome, style: _t(10, fonte: f.negrito)),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        _barra(maior > 0 ? valor / maior : 0, cor, 18),
                        pw.SizedBox(height: 2),
                        pw.Text(nota, style: _t(8, cor: _C.secundario)),
                      ],
                    ),
                  ),
                  pw.SizedBox(
                    width: 92,
                    child: pw.Text(
                      reais(valor, 0),
                      textAlign: pw.TextAlign.right,
                      style: _t(13, fonte: f.titulo),
                    ),
                  ),
                ],
              ),
            ),
          if (r.capitalEvitado > 0)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 4),
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 10,
              ),
              decoration: pw.BoxDecoration(
                color: _C.verdeClaro,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                children: [
                  _icone(IconeProposta.semente, t: 24),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    reais(r.capitalEvitado, 0),
                    style: _t(20, fonte: f.titulo, cor: _C.verdeTexto),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Text(
                      'de capital que fica na fazenda ao modernizar em vez de '
                      'trocar a plantadeira',
                      style: _t(9.5),
                    ),
                  ),
                ],
              ),
            ),
          pw.SizedBox(height: 18),
        ],
        _rotulo('Premissas usadas no cálculo'),
        for (var i = 0; i < grupos.length; i += 3) ...[
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final (j, g) in grupos.skip(i).take(3).indexed) ...[
                if (j > 0) pw.SizedBox(width: 18),
                grupo(g),
              ],
            ],
          ),
          pw.SizedBox(height: 14),
        ],
      ],
    );
  }
}

String _hex(PdfColor c) {
  String dois(double v) => (v * 255).round().toRadixString(16).padLeft(2, '0');
  return '#${dois(c.red)}${dois(c.green)}${dois(c.blue)}';
}
