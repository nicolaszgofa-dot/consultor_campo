import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../roi/proposta/proposta_pdf.dart';
import 'avaliacao_estado.dart';
import 'avaliacao_pdf.dart';

/// Nome do arquivo: cliente e talhão, sem acentos problemáticos.
String nomeArquivoAvaliacao(Identificacao id) {
  final base = [
    if (id.cliente.isNotEmpty) id.cliente,
    if (id.talhao.isNotEmpty) id.talhao,
  ].join('_');
  final limpo = (base.isEmpty ? nomeCultura(id.cultura) : base)
      .replaceAll(RegExp(r'[^A-Za-zÀ-ú0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return 'Avaliacao_plantio_$limpo.pdf';
}

/// Prévia do relatório interno da avaliação, para compartilhar ou imprimir.
class PreviaAvaliacaoPdf extends StatelessWidget {
  final AvaliacaoEstado estado;
  final Cenario cenario;
  final ResultadoPrejuizo? prejuizo;

  const PreviaAvaliacaoPdf({
    super.key,
    required this.estado,
    this.cenario = Cenario.medio,
    this.prejuizo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatório da avaliação')),
      body: PdfPreview(
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: nomeArquivoAvaliacao(estado.identificacao),
        build: (_) async => gerarAvaliacaoPdf(
          estado: estado,
          recursos: await RecursosPdf.carregar(),
          cenario: cenario,
          prejuizo: prejuizo,
        ),
      ),
    );
  }
}

void abrirRelatorioAvaliacao(
  BuildContext context,
  AvaliacaoEstado estado, {
  Cenario cenario = Cenario.medio,
  ResultadoPrejuizo? prejuizo,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PreviaAvaliacaoPdf(
        estado: estado,
        cenario: cenario,
        prejuizo: prejuizo,
      ),
    ),
  );
}
