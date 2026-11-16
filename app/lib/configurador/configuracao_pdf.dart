import 'dart:typed_data';

import 'package:configurador/configurador.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../roi/proposta/proposta_dados.dart';
import '../roi/proposta/proposta_pdf.dart';
import '../ui/formatos.dart';

/// Quem recebe a configuração. Tudo opcional e nada fica salvo.
class IdentificacaoConfiguracao {
  final String cliente;
  final String local;
  final String consultor;

  const IdentificacaoConfiguracao({
    this.cliente = '',
    this.local = '',
    this.consultor = '',
  });
}

abstract final class _C {
  static const tinta = PdfColor.fromInt(0xFF1D1D1B);
  static const secundario = PdfColor.fromInt(0xFF5F6165);
  static const verde = PdfColor.fromInt(0xFF2AA437);
  static const verdeEscuro = PdfColor.fromInt(0xFF112C02);
  static const verdeTexto = PdfColor.fromInt(0xFF1D7A28);
  static const verdeClaro = PdfColor.fromInt(0xFFE5F5E7);
  static const verdeSuave = PdfColor.fromInt(0xFF9FD3A6);
  static const atencao = PdfColor.fromInt(0xFF9A5B00);
  static const atencaoClaro = PdfColor.fromInt(0xFFFBF1E1);
  static const neutro = PdfColor.fromInt(0xFFF4F5F5);
  static const borda = PdfColor.fromInt(0xFFDCDFE1);
  static const cinza = PdfColor.fromInt(0xFFA2A8AD);
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

String _data(DateTime d) => '${d.day} de ${_meses[d.month - 1]} de ${d.year}';

ProdutoProposta _produto(Tecnologia t) => switch (t) {
  Tecnologia.titaniumEletric => ProdutoProposta.titanium,
  Tecnologia.seleniumEletric => ProdutoProposta.selenium,
  Tecnologia.seleniumNeo => ProdutoProposta.neo,
};

/// Resumo da máquina em pares rótulo → valor, na ordem do PDF.
List<(String, String)> resumoDaMaquina(EntradaConfiguracao e) {
  final secoes = e.secoes;
  return [
    ('Tecnologia', e.tecnologia.nome),
    ('Plantadeira', e.tipo.nome),
    (
      'Linhas',
      secoes.length > 1
          ? '${e.totalLinhas} em ${secoes.length} seções (${secoes.join(' + ')})'
          : '${e.totalLinhas}',
    ),
    if (e.adaptacao case final a?) ('Adaptação', '${a.marca} · ${a.modelo}'),
    if (e.temAlternador != null)
      (
        'Alimentação',
        e.temAlternador!
            ? 'Alternador hidráulico'
                  '${e.alternadorNaFrente == null
                      ? ''
                      : e.alternadorNaFrente!
                      ? ', na frente'
                      : ', atrás'}'
            : 'Direto da bateria',
      ),
    if (e.tecnologia.temKitConversao)
      ('Kit de conversão', e.kitConversao ? 'Sim' : 'Não'),
    if (e.velocidadePlantio != null)
      ('Velocidade de plantio', '${numeroBr(e.velocidadePlantio!, 1)} km/h'),
    if (e.populacaoSoja != null)
      ('População de soja', '${numeroBr(e.populacaoSoja!, 1)} sementes/m'),
    if (e.populacaoMilho != null)
      ('População de milho', '${numeroBr(e.populacaoMilho!, 1)} sementes/m'),
  ];
}

/// PDF com a configuração gerada: resumo da máquina, lista de itens,
/// distribuição das saídas do alternador e observações. Sem preços.
Future<Uint8List> gerarConfiguracaoPdf({
  required ResultadoConfiguracao resultado,
  required RecursosPdf recursos,
  IdentificacaoConfiguracao identificacao = const IdentificacaoConfiguracao(),
  DateTime? data,
}) {
  final m = _Montador(
    resultado,
    recursos,
    identificacao,
    data ?? DateTime.now(),
  );
  final tecnologia = resultado.entrada.tecnologia.nome;
  final doc = pw.Document(
    title:
        'Configuração $tecnologia'
        '${identificacao.cliente.isEmpty ? '' : ' – ${identificacao.cliente}'}',
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
        padding: const pw.EdgeInsets.only(bottom: 14),
        child: m.topo(capa: ctx.pageNumber == 1),
      ),
      footer: (ctx) => m.rodape(ctx.pageNumber, ctx.pagesCount),
      build: (_) => [
        m.capa(),
        pw.SizedBox(height: 14),
        ...m.itens(),
        if (resultado.distribuicao case final d? when d.saidas.isNotEmpty) ...[
          pw.SizedBox(height: 14),
          pw.Inseparable(child: m.saidas(d)),
        ],
        if (m.observacoes.isNotEmpty) ...[
          pw.SizedBox(height: 14),
          pw.Inseparable(child: m.observacoesBloco()),
        ],
      ],
    ),
  );
  return doc.save();
}

class _Montador {
  final ResultadoConfiguracao r;
  final RecursosPdf f;
  final IdentificacaoConfiguracao id;
  final DateTime data;

  _Montador(this.r, this.f, this.id, this.data);

  EntradaConfiguracao get e => r.entrada;

  List<Validacao> get observacoes => [
    for (final v in r.validacoes)
      if (v.nivel != NivelValidacao.erro) v,
  ];

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
              ? [if (id.local.isNotEmpty) id.local, _data(data)].join(', ')
              : 'Configuração · ${e.tecnologia.nome}',
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
          'Gerada pelo configurador do Consultor de Campo. Confira com a '
          'engenharia J.Assy antes de fechar o pedido.',
          style: t(7.5, cor: _C.secundario),
        ),
        pw.Text('$pagina de $total', style: t(7.5, cor: _C.secundario)),
      ],
    ),
  );

  /// Título, foto do produto, identificação e resumo da máquina.
  pw.Widget capa() {
    final imagem = f.imagens[_produto(e.tecnologia)];
    final pendentes = r.pendentes.length;
    final quem = [
      if (id.cliente.isNotEmpty) ('Cliente', id.cliente),
      if (id.consultor.isNotEmpty) ('Consultor', id.consultor),
    ];
    // A tecnologia já está no título.
    final resumo = resumoDaMaquina(e).skip(1).toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'CONFIGURAÇÃO DO EQUIPAMENTO',
                    style: t(9, fonte: f.semi, cor: _C.verdeTexto, espaco: 0.7),
                  ),
                  pw.Text(
                    '${e.tecnologia.nome} · ${e.totalLinhas} linhas',
                    style: t(24, fonte: f.titulo),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${linhasDoPedido(r).length} itens na lista'
                    '${pendentes > 0 ? ' · $pendentes pendentes' : ''}',
                    style: t(10, cor: _C.secundario),
                  ),
                  if (quem.isNotEmpty) ...[
                    pw.SizedBox(height: 10),
                    for (final (rotulo, valor) in quem)
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: '$rotulo: ',
                              style: t(10, cor: _C.secundario),
                            ),
                            pw.TextSpan(
                              text: valor,
                              style: t(10, fonte: f.semi),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (imagem != null)
              pw.Image(pw.MemoryImage(imagem), height: 80, width: 130),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(14, 9, 14, 3),
          decoration: pw.BoxDecoration(
            color: _C.neutro,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Wrap(
            spacing: 18,
            children: [
              for (final (rotulo, valor) in resumo)
                pw.SizedBox(
                  width: 150,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          rotulo.toUpperCase(),
                          style: t(
                            7,
                            fonte: f.negrito,
                            cor: _C.secundario,
                            espaco: 0.5,
                          ),
                        ),
                        pw.Text(valor, style: t(10.5, fonte: f.semi)),
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

  /// Tabela dos itens; o cabeçalho fica junto da primeira linha.
  List<pw.Widget> itens() {
    pw.Widget celula(
      String texto, {
      bool cabecalho = false,
      bool direita = false,
    }) => pw.Text(
      texto,
      textAlign: direita ? pw.TextAlign.right : pw.TextAlign.left,
      style: cabecalho
          ? t(7.5, fonte: f.negrito, cor: _C.secundario, espaco: 0.5)
          : t(10, fonte: f.semi),
    );

    final pedido = linhasDoPedido(r);

    pw.Widget linha(LinhaPedido i, int n) {
      final pendente = i.pendente;
      final comprimento = i.comprimento == null ? '' : '${i.comprimento} m';
      final nome = i.nome;
      final codigo = i.codigo;
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4.5, horizontal: 8),
        decoration: pw.BoxDecoration(
          color: pendente ? _C.atencaoClaro : null,
          border: const pw.Border(
            bottom: pw.BorderSide(color: _C.borda, width: 0.6),
          ),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(
              width: 18,
              child: pw.Text('$n', style: t(9, cor: _C.secundario)),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  celula(nome),
                  if (pendente && i.pendencia != null)
                    pw.Text(
                      i.pendencia!,
                      style: t(8, fonte: f.semi, cor: _C.atencao),
                    ),
                ],
              ),
            ),
            pw.SizedBox(
              width: 78,
              child: pw.Text(
                codigo ?? '–',
                textAlign: pw.TextAlign.right,
                style: codigo == null
                    ? t(9.5, cor: _C.cinza)
                    : t(9.5, fonte: f.semi, cor: _C.verdeTexto),
              ),
            ),
            pw.SizedBox(
              width: 84,
              child: pw.Text(
                pendente && comprimento.isEmpty ? 'a definir' : comprimento,
                textAlign: pw.TextAlign.right,
                style: t(9.5, cor: pendente ? _C.atencao : _C.tinta),
              ),
            ),
            pw.SizedBox(
              width: 40,
              child: pw.Text(
                '${i.quantidade}',
                textAlign: pw.TextAlign.right,
                style: t(13, fonte: f.titulo),
              ),
            ),
          ],
        ),
      );
    }

    final cabecalho = pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _C.verdeEscuro, width: 1),
        ),
      ),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 18, child: celula('#', cabecalho: true)),
          pw.Expanded(child: celula('ITEM', cabecalho: true)),
          pw.SizedBox(
            width: 78,
            child: celula('CÓDIGO', cabecalho: true, direita: true),
          ),
          pw.SizedBox(
            width: 84,
            child: celula('COMPRIMENTO', cabecalho: true, direita: true),
          ),
          pw.SizedBox(
            width: 40,
            child: celula('QTD.', cabecalho: true, direita: true),
          ),
        ],
      ),
    );
    return [
      pw.Inseparable(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _rotulo('Lista de itens'),
            cabecalho,
            if (pedido.isNotEmpty) linha(pedido.first, 1),
          ],
        ),
      ),
      for (final (n, i) in pedido.indexed.skip(1)) linha(i, n + 1),
    ];
  }

  /// Saídas do alternador: faixa com as linhas de cada saída, por seção.
  pw.Widget saidas(DistribuicaoSaidas d) {
    // Trechos em ordem: (saída, seção, linhas).
    final trechos = <(int, int, int)>[
      for (final s in d.saidas)
        for (final (k, secao) in s.secoes.indexed)
          (s.numero, secao, s.trechos[k]),
    ];
    final cores = [_C.verde, _C.verdeSuave];
    final faixa = <pw.Widget>[];
    int? secaoAnterior;
    for (final (saida, secao, n) in trechos) {
      if (secaoAnterior != null && secao != secaoAnterior) {
        faixa.add(pw.SizedBox(width: 6));
      }
      secaoAnterior = secao;
      faixa.add(
        pw.Expanded(
          flex: n,
          child: pw.Container(
            height: 22,
            margin: const pw.EdgeInsets.symmetric(horizontal: 0.6),
            alignment: pw.Alignment.center,
            color: cores[(saida - 1) % 2],
            child: pw.Text(
              'S$saida',
              style: t(
                8,
                fonte: f.negrito,
                cor: (saida - 1) % 2 == 0 ? PdfColors.white : _C.verdeEscuro,
              ),
            ),
          ),
        ),
      );
    }
    final porSaida = e.tecnologia.linhasPorSaida;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _rotulo('Saídas do alternador'),
        pw.Text(
          '${d.saidas.length} ${d.saidas.length == 1 ? 'saída' : 'saídas'}, '
          'até $porSaida linhas por saída'
          '${e.secoes.length > 1 ? '. Os espaços separam as seções.' : '.'}',
          style: t(9, cor: _C.secundario),
        ),
        pw.SizedBox(height: 6),
        pw.Row(children: faixa),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 10,
          runSpacing: 2,
          children: [
            for (final s in d.saidas)
              pw.SizedBox(
                width: 124,
                child: pw.Text(
                  'S${s.numero}: linhas ${s.primeiraLinha}–${s.ultimaLinha}'
                  '${e.secoes.length > 1 ? ', seção ${s.secoes.join(' e ')}' : ''}',
                  style: t(8.5),
                ),
              ),
          ],
        ),
      ],
    );
  }

  pw.Widget observacoesBloco() => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _rotulo('Observações'),
      for (final v in observacoes)
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 5),
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: v.nivel == NivelValidacao.aviso
                ? _C.atencaoClaro
                : _C.verdeClaro,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            v.mensagem,
            style: t(
              9,
              cor: v.nivel == NivelValidacao.aviso ? _C.atencao : _C.verdeTexto,
            ),
          ),
        ),
    ],
  );
}
