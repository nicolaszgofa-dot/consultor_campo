import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'componentes_inteligencia.dart';
import 'concorrencia_dados.dart';
import 'precos_estado.dart';

/// Aba Preços da concorrência: o que o vendedor encontrou no campo.
class PrecosView extends StatelessWidget {
  final PrecosConcorrenciaEstado estado;

  const PrecosView({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        if (!estado.carregado) {
          return const Center(child: CircularProgressIndicator());
        }
        final resumos = estado.resumos;
        final lista = estado.filtrados;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1140),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                const AlertaConceitoInteligencia(
                  'Preços informados pela equipe, sem conferência. Não usar '
                  'como informação certa em negociação.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Preços encontrados no campo',
                          style: TextStyle(
                            fontFamily: fonteTitulo,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Proposta que o produtor mostrou, preço de revenda, '
                          'anúncio.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Cores.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) =>
                              InformarPrecoConcorrenteDialog(estado: estado),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Informar preço'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OpcaoChip(
                      texto: 'Todas',
                      ativo: estado.linha == null,
                      aoTocar: () => estado.filtrar(null),
                    ),
                    for (final l in linhasProduto)
                      OpcaoChip(
                        texto: l.nome,
                        ativo: estado.linha == l.id,
                        aoTocar: () => estado.filtrar(l.id),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                if (lista.isEmpty)
                  const CartaoBranco(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Nenhum preço informado ainda. Toque em "Informar preço" '
                      'para registrar o primeiro.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Cores.textoSecundario,
                      ),
                    ),
                  )
                else ...[
                  const TituloSecao('Resumo por produto'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final r in resumos) _CartaoResumo(resumo: r),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TituloSecao('Preços informados'),
                  const SizedBox(height: 6),
                  CartaoBranco(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        for (var i = 0; i < lista.length; i++)
                          _LinhaPreco(
                            preco: lista[i],
                            ultima: i == lista.length - 1,
                            aoRemover: () => estado.remover(lista[i]),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'Os preços ficam salvos neste aparelho. Para a equipe toda ver, '
                  'falta o servidor que recebe os envios.',
                  style: TextStyle(fontSize: 12, color: Cores.textoSecundario),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _nomeProduto(String id) {
  final c = concorrentePorId(id)?.concorrente;
  return c?.nome ?? id;
}

class _CartaoResumo extends StatelessWidget {
  final ResumoPreco resumo;

  const _CartaoResumo({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final linha = concorrentePorId(resumo.concorrenteId)?.linha.nome ?? '';
    final n = resumo.precos.length;
    return SizedBox(
      width: 300,
      child: CartaoBranco(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              linha,
              style: const TextStyle(
                fontSize: 12,
                color: Cores.textoSecundario,
              ),
            ),
            Text(
              _nomeProduto(resumo.concorrenteId),
              style: const TextStyle(
                fontFamily: fonteTitulo,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text.rich(
              TextSpan(
                text: reais(resumo.media),
                style: const TextStyle(
                  fontFamily: fonteTitulo,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: '  ${resumo.unidade} · média',
                    style: const TextStyle(
                      fontFamily: 'Barlow',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Cores.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${n == 1 ? 'um preço' : '${reais(resumo.minimo)} a ${reais(resumo.maximo)} · $n preços'}'
              ' · último em ${dataBr(resumo.ultimo)}',
              style: const TextStyle(
                fontSize: 13,
                color: Cores.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaPreco extends StatelessWidget {
  final PrecoConcorrente preco;
  final bool ultima;
  final VoidCallback aoRemover;

  const _LinhaPreco({
    required this.preco,
    required this.ultima,
    required this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final p = preco;
    final detalhes = [
      p.condicao,
      p.local,
      p.fonte,
      if (p.informadoPor != null) 'por ${p.informadoPor}',
      ?p.observacao,
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: ultima
            ? null
            : const Border(bottom: BorderSide(color: Cores.neutro)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nomeProduto(p.concorrenteId),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  detalhes,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Cores.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                reais(p.preco),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${p.unidade} · ${dataBr(p.data)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Cores.textoSecundario,
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Remover preço',
            onPressed: aoRemover,
            icon: const Icon(Icons.delete_outline, color: Cores.cinzaEscuro),
          ),
        ],
      ),
    );
  }
}

/// Formulário para registrar um preço de concorrente.
class InformarPrecoConcorrenteDialog extends StatefulWidget {
  final PrecosConcorrenciaEstado estado;

  const InformarPrecoConcorrenteDialog({super.key, required this.estado});

  @override
  State<InformarPrecoConcorrenteDialog> createState() =>
      _InformarPrecoConcorrenteDialogState();
}

class _InformarPrecoConcorrenteDialogState
    extends State<InformarPrecoConcorrenteDialog> {
  late LinhaProduto _linha = linhasProduto.firstWhere(
    (l) => l.id == widget.estado.linha,
    orElse: () => linhasProduto.first,
  );
  late Concorrente _concorrente = _linha.concorrentes.first;
  String _unidade = unidadesPreco.first;
  String _condicao = condicoesPreco.first;
  String _fonte = fontesPreco.first;
  final _preco = TextEditingController();
  final _local = TextEditingController();
  final _obs = TextEditingController();
  final _quem = TextEditingController();
  late final _data = TextEditingController(text: dataBr(DateTime.now()));
  String? _erro;

  @override
  void dispose() {
    _preco.dispose();
    _local.dispose();
    _obs.dispose();
    _quem.dispose();
    _data.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final preco = lerReais(_preco.text);
    final data = lerData(_data.text);
    final String? erro;
    if (preco == null || preco <= 0) {
      erro = 'Informe o preço.';
    } else if (_local.text.trim().isEmpty) {
      erro = 'Informe a cidade e a UF.';
    } else if (data == null) {
      erro = 'Data inválida. Use dd/mm/aaaa.';
    } else {
      erro = null;
    }
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }
    final obs = _obs.text.trim();
    final quem = _quem.text.trim();
    await widget.estado.adicionar(
      PrecoConcorrente(
        concorrenteId: _concorrente.id,
        preco: preco!,
        unidade: _unidade,
        condicao: _condicao,
        fonte: _fonte,
        local: _local.text.trim(),
        data: data!,
        observacao: obs.isEmpty ? null : obs,
        informadoPor: quem.isEmpty ? null : quem,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final campo = InputDecoration(
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
    DropdownButtonFormField<String> lista(
      String rotulo,
      String valor,
      List<String> opcoes,
      ValueChanged<String> aoMudar,
    ) => DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      decoration: campo.copyWith(labelText: rotulo),
      items: [
        for (final o in opcoes) DropdownMenuItem(value: o, child: Text(o)),
      ],
      onChanged: (v) {
        if (v != null) setState(() => aoMudar(v));
      },
    );
    return AlertDialog(
      title: const Text(
        'Informar preço da concorrência',
        style: TextStyle(fontFamily: fonteTitulo, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<LinhaProduto>(
                initialValue: _linha,
                isExpanded: true,
                decoration: campo.copyWith(labelText: 'Linha de produto'),
                items: [
                  for (final l in linhasProduto)
                    DropdownMenuItem(value: l, child: Text(l.nome)),
                ],
                onChanged: (l) {
                  if (l == null) return;
                  setState(() {
                    _linha = l;
                    _concorrente = l.concorrentes.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Concorrente>(
                key: ValueKey(_linha.id),
                initialValue: _concorrente,
                isExpanded: true,
                decoration: campo.copyWith(labelText: 'Concorrente e produto'),
                items: [
                  for (final c in _linha.concorrentes)
                    DropdownMenuItem(value: c, child: Text(c.nome)),
                ],
                onChanged: (c) {
                  if (c != null) setState(() => _concorrente = c);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _preco,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: campo.copyWith(
                        labelText: 'Preço',
                        prefixText: 'R\$ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: lista(
                      'Por',
                      _unidade,
                      unidadesPreco,
                      (v) => _unidade = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              lista(
                'Condição',
                _condicao,
                condicoesPreco,
                (v) => _condicao = v,
              ),
              const SizedBox(height: 12),
              lista('Onde viu', _fonte, fontesPreco, (v) => _fonte = v),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _local,
                      decoration: campo.copyWith(
                        labelText: 'Cidade – UF',
                        hintText: 'Ex.: Sorriso – MT',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _data,
                      keyboardType: TextInputType.datetime,
                      decoration: campo.copyWith(labelText: 'Data'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _obs,
                decoration: campo.copyWith(
                  labelText: 'Observação (opcional)',
                  hintText: 'Ex.: 24 linhas, inclui monitor',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _quem,
                decoration: campo.copyWith(labelText: 'Seu nome (opcional)'),
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
