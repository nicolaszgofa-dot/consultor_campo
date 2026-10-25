import 'package:cotacoes/cotacoes.dart';
import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/formatos.dart';
import 'cotacoes_estado.dart';

const tiposFonte = [
  'Cooperativa',
  'Trading',
  'Cerealista',
  'Corretora',
  'Revenda',
  'Produtor',
  'Outro',
];

Future<void> abrirInformarPreco(BuildContext context, CotacoesEstado estado) {
  return showDialog<void>(
    context: context,
    builder: (_) => InformarPrecoDialog(estado: estado),
  );
}

/// O vendedor registra o preço que viu: produto, local, fonte e data.
class InformarPrecoDialog extends StatefulWidget {
  final CotacoesEstado estado;

  const InformarPrecoDialog({super.key, required this.estado});

  @override
  State<InformarPrecoDialog> createState() => _InformarPrecoDialogState();
}

class _InformarPrecoDialogState extends State<InformarPrecoDialog> {
  late Produto _produto = widget.estado.produto;
  late Cidade? _cidade = widget.estado.cidade ?? widget.estado.minhaCidade;
  String _tipo = tiposFonte.first;
  final _preco = TextEditingController();
  final _nomeFonte = TextEditingController();
  final _quem = TextEditingController();
  late final _data = TextEditingController(text: dataBr(DateTime.now()));
  String? _erro;

  @override
  void dispose() {
    _preco.dispose();
    _nomeFonte.dispose();
    _quem.dispose();
    _data.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final preco = lerNumero(_preco.text);
    final data = lerData(_data.text);
    final String? erro;
    if (_cidade == null) {
      erro = 'Escolha o local da cotação.';
    } else if (preco == null || preco <= 0) {
      erro = 'Informe o preço da saca.';
    } else if (_nomeFonte.text.trim().isEmpty) {
      erro = 'Informe o nome da fonte.';
    } else if (data == null) {
      erro = 'Data inválida. Use dd/mm/aaaa.';
    } else {
      erro = null;
    }
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }
    final quem = _quem.text.trim();
    await widget.estado.informar(
      produto: _produto,
      cidade: _cidade!,
      preco: preco!,
      fonte: '$_tipo ${_nomeFonte.text.trim()}',
      data: data!,
      informadoPor: quem.isEmpty ? null : quem,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final campo = InputDecoration(
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
    return AlertDialog(
      title: const Text(
        'Informar preço',
        style: TextStyle(fontFamily: fonteTitulo, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Fica salvo neste aparelho, com a fonte e a data, e entra '
                'na estimativa das cidades vizinhas.',
                style: TextStyle(fontSize: 14, color: Cores.textoSecundario),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<Produto>(
                initialValue: _produto,
                decoration: campo.copyWith(labelText: 'Produto'),
                items: [
                  for (final p in Produto.values)
                    DropdownMenuItem(value: p, child: Text(p.nome)),
                ],
                onChanged: (p) => setState(() => _produto = p ?? _produto),
              ),
              const SizedBox(height: 12),
              Autocomplete<Cidade>(
                initialValue: TextEditingValue(text: _cidade?.rotulo ?? ''),
                displayStringForOption: (c) => c.rotulo,
                optionsBuilder: (v) => buscarCidades(v.text),
                onSelected: (c) => setState(() => _cidade = c),
                fieldViewBuilder: (context, controle, foco, _) => TextField(
                  controller: controle,
                  focusNode: foco,
                  onChanged: (_) {
                    if (_cidade != null && controle.text != _cidade!.rotulo) {
                      setState(() => _cidade = null);
                    }
                  },
                  decoration: campo.copyWith(
                    labelText: 'Local',
                    hintText: 'Digite a cidade',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _preco,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: campo.copyWith(
                  labelText: 'Preço',
                  suffixText: 'R\$/sc 60 kg',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _tipo,
                      decoration: campo.copyWith(labelText: 'Tipo de fonte'),
                      items: [
                        for (final t in tiposFonte)
                          DropdownMenuItem(value: t, child: Text(t)),
                      ],
                      onChanged: (t) => setState(() => _tipo = t ?? _tipo),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _nomeFonte,
                      decoration: campo.copyWith(labelText: 'Nome da fonte'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _data,
                      keyboardType: TextInputType.datetime,
                      decoration: campo.copyWith(labelText: 'Data'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _quem,
                      decoration: campo.copyWith(
                        labelText: 'Seu nome (opcional)',
                      ),
                    ),
                  ),
                ],
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(
                  _erro!,
                  style: const TextStyle(
                    color: Cores.prejuizo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Salvar preço')),
      ],
    );
  }
}
