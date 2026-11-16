import 'package:configurador/configurador.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../roi/proposta/proposta_pdf.dart';
import 'configuracao_pdf.dart';

/// Pede a identificação (opcional) e abre a prévia do PDF da configuração.
Future<void> abrirPdfConfiguracao(
  BuildContext context,
  ResultadoConfiguracao resultado,
) async {
  final id = await showDialog<IdentificacaoConfiguracao>(
    context: context,
    builder: (_) => const _DialogoIdentificacao(),
  );
  if (id == null || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PreviaConfiguracaoPdf(resultado: resultado, id: id),
    ),
  );
}

class _DialogoIdentificacao extends StatefulWidget {
  const _DialogoIdentificacao();

  @override
  State<_DialogoIdentificacao> createState() => _DialogoIdentificacaoState();
}

class _DialogoIdentificacaoState extends State<_DialogoIdentificacao> {
  final _cliente = TextEditingController();
  final _local = TextEditingController();
  final _consultor = TextEditingController();

  @override
  void dispose() {
    _cliente.dispose();
    _local.dispose();
    _consultor.dispose();
    super.dispose();
  }

  void _gerar() => Navigator.of(context).pop(
    IdentificacaoConfiguracao(
      cliente: _cliente.text.trim(),
      local: _local.text.trim(),
      consultor: _consultor.text.trim(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    InputDecoration campo(String rotulo) => InputDecoration(labelText: rotulo);
    return AlertDialog(
      title: const Text('Relatório da configuração'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Os campos são opcionais e aparecem no topo do PDF. Nada fica '
              'salvo no app.',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _cliente,
              textCapitalization: TextCapitalization.words,
              decoration: campo('Cliente'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _local,
              textCapitalization: TextCapitalization.words,
              decoration: campo('Cidade ou fazenda'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _consultor,
              textCapitalization: TextCapitalization.words,
              decoration: campo('Consultor'),
              onSubmitted: (_) => _gerar(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _gerar, child: const Text('Gerar PDF')),
      ],
    );
  }
}

class PreviaConfiguracaoPdf extends StatelessWidget {
  final ResultadoConfiguracao resultado;
  final IdentificacaoConfiguracao id;

  const PreviaConfiguracaoPdf({
    super.key,
    required this.resultado,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final base = id.cliente.isEmpty
        ? resultado.entrada.tecnologia.nome
        : id.cliente;
    final nome = base
        .replaceAll(RegExp(r'[^A-Za-zÀ-ú0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return Scaffold(
      appBar: AppBar(title: const Text('Configuração em PDF')),
      body: PdfPreview(
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: 'Configuracao_JAssy_$nome.pdf',
        build: (_) async => gerarConfiguracaoPdf(
          resultado: resultado,
          identificacao: id,
          recursos: await RecursosPdf.carregar(),
        ),
      ),
    );
  }
}
