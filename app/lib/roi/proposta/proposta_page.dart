import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:roi/roi.dart';

import '../../configurador/configurador_widgets.dart';
import '../../tema.dart';
import '../../ui/componentes.dart';
import '../../ui/formatos.dart';
import 'proposta_dados.dart';
import 'proposta_pdf.dart';

/// O que o vendedor preenche para gerar a proposta com o ROI. Nada de preço
/// vem preenchido: linhas e valor por linha partem do que ele digitou no ROI
/// (o valor só quando o investimento dividido pelas linhas fecha em centavos).
class PropostaPage extends StatefulWidget {
  final PremissasRoi premissas;
  final CenarioRoi cenario;

  const PropostaPage({
    super.key,
    required this.premissas,
    required this.cenario,
  });

  @override
  State<PropostaPage> createState() => _PropostaPageState();
}

class _ParcelaCampos {
  final fracao = TextEditingController();
  final quando = TextEditingController();

  void dispose() {
    fracao.dispose();
    quando.dispose();
  }
}

class _PropostaPageState extends State<PropostaPage> {
  ProdutoProposta? _produto;
  Fornecimento _fornecimento = Fornecimento.completo;

  late final Map<String, TextEditingController> _c = {
    for (final k in [
      'plantadeira',
      'linhas',
      'valor',
      'impostos',
      'cliente',
      'documento',
      'inscricao',
      'telefone',
      'email',
      'cidade',
      'consultor',
      'contato',
      'entrada',
      'validade',
      'prazo',
      'local',
      'agente',
      'garantia',
    ])
      k: TextEditingController(),
  };
  final List<_ParcelaCampos> _parcelas = [];
  bool _tentou = false;

  @override
  void initState() {
    super.initState();
    final p = widget.premissas;
    if (p.linhas > 0) {
      _c['linhas']!.text = numeroBr(p.linhas, 0);
      // Só sugere o valor por linha se a divisão fecha em centavos; senão o
      // total da proposta sairia diferente do investimento digitado.
      final porLinha = (p.investimento / p.linhas * 100).round() / 100;
      if (p.investimento > 0 &&
          (porLinha * p.linhas - p.investimento).abs() < 0.005) {
        _c['valor']!.text = numeroBr(porLinha, 2);
      }
    }
    for (final c in _c.values) {
      c.addListener(_mudou);
    }
  }

  void _mudou() => setState(() {});

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    for (final p in _parcelas) {
      p.dispose();
    }
    super.dispose();
  }

  String _t(String k) => _c[k]!.text.trim();
  double _pctCampo(TextEditingController c) => (lerNumero(c.text) ?? 0) / 100;

  int get _linhas => (lerReais(_t('linhas')) ?? 0).round();
  double get _valor => lerReais(_t('valor')) ?? 0;

  double get _somaPagamento =>
      _pctCampo(_c['entrada']!) +
      _parcelas.fold(0.0, (s, p) => s + _pctCampo(p.fracao));

  bool get _temPagamento =>
      _t('entrada').isNotEmpty ||
      _parcelas.any((p) => p.fracao.text.isNotEmpty);

  /// O que falta para gerar. Vazio = pode gerar.
  List<String> get _pendencias => [
    if (_produto == null) 'Escolha o produto.',
    if (_linhas <= 0) 'Informe o número de linhas.',
    if (_valor <= 0) 'Informe o valor por linha.',
    if (_t('plantadeira').isEmpty) 'Informe a plantadeira.',
    if (_t('cliente').isEmpty) 'Informe o cliente.',
    if (_t('cidade').isEmpty) 'Informe a cidade da proposta.',
    if (_t('consultor').isEmpty) 'Informe o consultor.',
    if (_temPagamento && (_somaPagamento - 1).abs() > 0.0001)
      'Entrada e parcelas precisam somar 100% '
          '(hoje: ${percentual(_somaPagamento * 100, 0)}).',
  ];

  DadosProposta _dados() => DadosProposta(
    itens: [
      ItemProposta(
        produto: _produto!,
        fornecimento: _fornecimento,
        plantadeira: _t('plantadeira'),
        linhas: _linhas,
        valorLinha: _valor,
      ),
    ],
    impostos: _t('impostos'),
    cliente: _t('cliente'),
    documento: _t('documento'),
    inscricao: _t('inscricao'),
    telefone: _t('telefone'),
    email: _t('email'),
    cidade: _t('cidade'),
    data: DateTime.now(),
    consultor: _t('consultor'),
    contatoConsultor: _t('contato'),
    entrada: _pctCampo(_c['entrada']!),
    parcelas: [
      for (final p in _parcelas)
        if (_pctCampo(p.fracao) > 0)
          (fracao: _pctCampo(p.fracao), quando: p.quando.text.trim()),
    ],
    validade: _t('validade'),
    prazo: _t('prazo'),
    local: _t('local'),
    agente: _t('agente'),
    garantia: _t('garantia'),
  );

  void _gerar() {
    setState(() => _tentou = true);
    if (_pendencias.isNotEmpty) return;
    final dados = _dados();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PreviaProposta(
          dados: dados,
          premissas: widget.premissas,
          cenario: widget.cenario,
        ),
      ),
    );
  }

  Widget _campo(
    String chave,
    String rotulo, {
    String? dica,
    bool numero = false,
    TextInputType? teclado,
    String? sufixo,
  }) => TextField(
    key: ValueKey('proposta-$chave'),
    controller: _c[chave],
    keyboardType: numero
        ? const TextInputType.numberWithOptions(decimal: true)
        : teclado,
    inputFormatters: numero
        ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
        : null,
    decoration: InputDecoration(
      labelText: rotulo,
      hintText: dica,
      suffixText: sufixo,
    ),
  );

  Widget _par(Widget a, Widget b) => LayoutBuilder(
    builder: (context, box) => box.maxWidth >= 520
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 12),
              Expanded(child: b),
            ],
          )
        : Column(children: [a, const SizedBox(height: 12), b]),
  );

  Widget _secao(String titulo, List<Widget> filhos) => CartaoBranco(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RotuloSecao(titulo),
        const SizedBox(height: 8),
        for (var i = 0; i < filhos.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          filhos[i],
        ],
      ],
    ),
  );

  Widget _chips<T>(
    List<T> opcoes,
    T? escolhida,
    String Function(T) rotulo,
    ValueChanged<T> aoEscolher,
  ) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final o in opcoes)
        ChoiceChip(
          label: Text(rotulo(o)),
          selected: o == escolhida,
          showCheckmark: false,
          selectedColor: Cores.verdeEscuro,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: o == escolhida ? Cores.branco : Cores.tinta,
          ),
          onSelected: (_) => setState(() => aoEscolher(o)),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final total = _linhas * _valor;
    final investimentoRoi = widget.premissas.investimento;
    final mudaRoi =
        total > 0 && investimentoRoi > 0 && (total - investimentoRoi).abs() > 1;
    final pendencias = _pendencias;
    final soma = _somaPagamento;

    return TelaFluxo(
      titulo: 'Proposta comercial',
      filhos: [
        _secao('Produto', [
          _chips(
            ProdutoProposta.values.where((p) => p.porLinha).toList(),
            _produto,
            (p) => p.nome,
            (p) {
              _produto = p;
              if (!p.fornecimentos.containsKey(_fornecimento)) {
                _fornecimento = Fornecimento.completo;
              }
            },
          ),
          if (_produto != null)
            _chips(
              _produto!.fornecimentos.keys.toList(),
              _fornecimento,
              (f) => _produto!.fornecimentos[f]!,
              (f) => _fornecimento = f,
            ),
          _campo('plantadeira', 'Plantadeira', dica: 'Ex.: Tatu PST'),
          _par(
            _campo('linhas', 'Linhas', numero: true),
            _campo('valor', 'Valor por linha', numero: true, sufixo: 'R\$'),
          ),
          _campo(
            'impostos',
            'Impostos e frete (opcional)',
            dica: 'Ex.: + Difal + Frete',
          ),
          if (total > 0)
            Text(
              'Total: ${reais(total)} · ${valorPorExtenso(total)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Cores.verdeTexto,
              ),
            ),
          if (mudaRoi)
            Aviso(
              'O retorno do PDF usa o total da proposta '
              '(${reais(total, 0)}) no lugar do investimento do ROI '
              '(${reais(investimentoRoi, 0)}).',
              tipo: TipoAviso.info,
            ),
        ]),
        const SizedBox(height: 12),
        _secao('Cliente', [
          _campo('cliente', 'Nome do cliente ou fazenda'),
          _par(
            _campo('documento', 'CPF/CNPJ (opcional)'),
            _campo('inscricao', 'Inscrição estadual (opcional)'),
          ),
          _par(
            _campo(
              'telefone',
              'Telefone (opcional)',
              teclado: TextInputType.phone,
            ),
            _campo(
              'email',
              'E-mail (opcional)',
              teclado: TextInputType.emailAddress,
            ),
          ),
          _campo('cidade', 'Cidade da proposta', dica: 'Ex.: Caldas Novas'),
          _par(
            _campo('consultor', 'Consultor'),
            _campo(
              'contato',
              'Contato do consultor (opcional)',
              teclado: TextInputType.phone,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _secao('Pagamento', [
          _campo('entrada', 'Entrada', numero: true, sufixo: '%'),
          for (final (i, p) in _parcelas.indexed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: p.fracao,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText: '${i + 1}ª parcela',
                      suffixText: '%',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: p.quando,
                    decoration: const InputDecoration(
                      labelText: 'Vencimento',
                      hintText: 'Ex.: 30/04/2027',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remover parcela',
                  onPressed: () => setState(() {
                    _parcelas.removeAt(i).dispose();
                  }),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _parcelas.add(_ParcelaCampos())),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar parcela'),
            ),
          ),
          if (_temPagamento && total > 0)
            Text(
              'Somando ${percentual(soma * 100, 0)} do total',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: (soma - 1).abs() > 0.0001
                    ? TipoAviso.atencao.cor
                    : Cores.verdeTexto,
              ),
            ),
        ]),
        const SizedBox(height: 12),
        _secao('Demais condições (opcionais)', [
          _par(
            _campo('validade', 'Validade da proposta', dica: 'Ex.: 15 dias'),
            _campo('prazo', 'Prazo de entrega', dica: 'Ex.: 30 dias'),
          ),
          _par(
            _campo('local', 'Local de entrega', dica: 'Ex.: A combinar'),
            _campo('agente', 'Agente financeiro'),
          ),
          _campo('garantia', 'Garantia', dica: 'Ex.: 1 ano'),
        ]),
        if (_tentou && pendencias.isNotEmpty) ...[
          const SizedBox(height: 12),
          Aviso(pendencias.join('\n'), tipo: TipoAviso.erro),
        ],
      ],
      rodape: FilledButton.icon(
        onPressed: _gerar,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Gerar PDF'),
      ),
    );
  }
}

class _PreviaProposta extends StatelessWidget {
  final DadosProposta dados;
  final PremissasRoi premissas;
  final CenarioRoi cenario;

  const _PreviaProposta({
    required this.dados,
    required this.premissas,
    required this.cenario,
  });

  @override
  Widget build(BuildContext context) {
    final nome = dados.cliente
        .replaceAll(RegExp(r'[^A-Za-zÀ-ú0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return Scaffold(
      appBar: AppBar(title: const Text('Proposta em PDF')),
      body: PdfPreview(
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: 'Proposta_JAssy_$nome.pdf',
        build: (_) async => gerarPropostaPdf(
          dados: dados,
          premissas: premissas,
          cenario: cenario,
          recursos: await RecursosPdf.carregar(),
        ),
      ),
    );
  }
}
