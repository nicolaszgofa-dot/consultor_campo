import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:roi/roi.dart';

import '../configurador/configurador_widgets.dart';
import '../roi/proposta/proposta_dados.dart';
import '../roi/proposta/proposta_pdf.dart';
import '../roi/roi_page.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'proposta_estado.dart';

/// Nova proposta comercial em 5 etapas. Nada é salvo: ao sair, os dados se
/// perdem (o app pergunta antes).
class PropostaFluxoPage extends StatefulWidget {
  final PropostaEstado? estado;

  const PropostaFluxoPage({super.key, this.estado});

  @override
  State<PropostaFluxoPage> createState() => _PropostaFluxoPageState();
}

class _PropostaFluxoPageState extends State<PropostaFluxoPage> {
  late final PropostaEstado _estado = widget.estado ?? PropostaEstado();

  @override
  void dispose() {
    if (widget.estado == null) _estado.dispose();
    super.dispose();
  }

  Future<void> _sair() async {
    if (_estado.etapa > 0) return _estado.voltar();
    final navegador = Navigator.of(context);
    if (!_estado.editou) return navegador.pop();
    final descartar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar esta proposta?'),
        content: const Text(
          'A proposta não é salva no aparelho. Ao sair, o que foi preenchido '
          'se perde.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (descartar == true) navegador.pop();
  }

  Widget _conteudo() => switch (_estado.etapa) {
    0 => _EtapaCliente(estado: _estado),
    1 => _EtapaItens(estado: _estado),
    2 => _EtapaCondicoes(estado: _estado),
    _ => _EtapaAnexos(estado: _estado),
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _estado,
      builder: (context, _) {
        final previa = _estado.etapa == PropostaEstado.etapaPrevia;
        final pagina = previa
            ? _Previa(estado: _estado)
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView(
                    key: ValueKey(_estado.etapa),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [_conteudo()],
                  ),
                ),
              );
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (saiu, _) {
            if (!saiu) _sair();
          },
          child: Scaffold(
            body: Column(
              children: [
                CabecalhoFluxo(
                  titulo: PropostaEstado.nomesEtapas[_estado.etapa],
                  passo: _estado.etapa + 1,
                  totalPassos: PropostaEstado.nomesEtapas.length,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => box.maxWidth >= 900
                        ? Row(
                            children: [
                              _Trilho(estado: _estado),
                              Expanded(child: pagina),
                            ],
                          )
                        : pagina,
                  ),
                ),
                if (!previa) _Rodape(estado: _estado),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Trilho extends StatelessWidget {
  final PropostaEstado estado;

  const _Trilho({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Cores.branco,
        border: Border(right: BorderSide(color: Cores.borda)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        children: [
          for (var i = 0; i < PropostaEstado.nomesEtapas.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                color: i == estado.etapa
                    ? Cores.verdeClaro
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: i < estado.etapa ? () => estado.irPara(i) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: i == estado.etapa
                              ? Cores.verdeEscuro
                              : i < estado.etapa
                              ? Cores.verde
                              : Cores.neutro,
                          child: i < estado.etapa
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Cores.verdeEscuro,
                                )
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: i == estado.etapa
                                        ? Cores.branco
                                        : Cores.textoSecundario,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            PropostaEstado.nomesEtapas[i],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: i == estado.etapa
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: i <= estado.etapa
                                  ? Cores.tinta
                                  : Cores.textoSecundario,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Rodape extends StatelessWidget {
  final PropostaEstado estado;

  const _Rodape({required this.estado});

  @override
  Widget build(BuildContext context) {
    final bloqueio = estado.bloqueio;
    return Container(
      decoration: const BoxDecoration(
        color: Cores.branco,
        border: Border(top: BorderSide(color: Cores.borda)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              if (estado.etapa > 0) ...[
                OutlinedButton(
                  onPressed: estado.voltar,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(64, 52),
                    foregroundColor: Cores.tinta,
                    side: const BorderSide(color: Cores.cinza),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Voltar'),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  bloqueio ??
                      '${estado.itens.length} '
                          '${estado.itens.length == 1 ? 'item' : 'itens'} · '
                          '${reais(estado.total, 0)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: bloqueio == null
                        ? Cores.textoSecundario
                        : TipoAviso.erro.cor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: bloqueio == null ? estado.avancar : null,
                child: Text(
                  estado.etapa == PropostaEstado.etapaPrevia - 1
                      ? 'Ver prévia'
                      : 'Continuar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Campos ----------------------------------------------------------------------

/// Campo de texto com o próprio controlador, partindo do valor atual.
class _Campo extends StatefulWidget {
  final String valor;
  final String rotulo;
  final String? dica;
  final bool numero;
  final String? sufixo;
  final TextInputType? teclado;
  final ValueChanged<String> aoMudar;

  const _Campo({
    super.key,
    required this.valor,
    required this.rotulo,
    required this.aoMudar,
    this.dica,
    this.numero = false,
    this.sufixo,
    this.teclado,
  });

  @override
  State<_Campo> createState() => _CampoState();
}

class _CampoState extends State<_Campo> {
  late final _controle = TextEditingController(text: widget.valor);

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controle,
      keyboardType: widget.numero
          ? const TextInputType.numberWithOptions(decimal: true)
          : widget.teclado,
      inputFormatters: widget.numero
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : null,
      decoration: InputDecoration(
        labelText: widget.rotulo,
        hintText: widget.dica,
        suffixText: widget.sufixo,
      ),
      onChanged: widget.aoMudar,
    );
  }
}

Widget _campo(
  PropostaEstado e,
  String chave,
  String rotulo, {
  String? dica,
  bool numero = false,
  String? sufixo,
  TextInputType? teclado,
}) => _Campo(
  key: ValueKey('proposta-$chave'),
  valor: e.texto(chave),
  rotulo: rotulo,
  dica: dica,
  numero: numero,
  sufixo: sufixo,
  teclado: teclado,
  aoMudar: (t) => e.mudar(chave, t),
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

Widget _chip(String rotulo, bool ativo, VoidCallback aoTocar) => ChoiceChip(
  label: Text(rotulo),
  selected: ativo,
  showCheckmark: false,
  selectedColor: Cores.verdeEscuro,
  labelStyle: TextStyle(
    fontWeight: FontWeight.w700,
    color: ativo ? Cores.branco : Cores.tinta,
  ),
  onSelected: (_) => aoTocar(),
);

// Etapas ----------------------------------------------------------------------

class _EtapaCliente extends StatelessWidget {
  final PropostaEstado estado;

  const _EtapaCliente({required this.estado});

  @override
  Widget build(BuildContext context) {
    final e = estado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _secao('Cliente', [
          _campo(e, 'cliente', 'Nome do cliente ou fazenda'),
          _par(
            _campo(e, 'documento', 'CPF/CNPJ (opcional)'),
            _campo(e, 'inscricao', 'Inscrição estadual (opcional)'),
          ),
          _par(
            _campo(
              e,
              'telefone',
              'Telefone (opcional)',
              teclado: TextInputType.phone,
            ),
            _campo(
              e,
              'email',
              'E-mail (opcional)',
              teclado: TextInputType.emailAddress,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _secao('Proposta', [
          _campo(e, 'cidade', 'Cidade da proposta', dica: 'Ex.: Caldas Novas'),
          _par(
            _campo(e, 'consultor', 'Consultor'),
            _campo(
              e,
              'contato',
              'Contato do consultor (opcional)',
              teclado: TextInputType.phone,
            ),
          ),
        ]),
      ],
    );
  }
}

class _EtapaItens extends StatelessWidget {
  final PropostaEstado estado;

  const _EtapaItens({required this.estado});

  @override
  Widget build(BuildContext context) {
    final e = estado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, item) in e.itens.indexed) ...[
          _CartaoItem(key: ObjectKey(item), estado: e, indice: i),
          const SizedBox(height: 12),
        ],
        _secao(e.itens.isEmpty ? 'Escolha o produto' : 'Adicionar produto', [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in ProdutoProposta.values)
                OutlinedButton.icon(
                  onPressed: () => e.adicionar(p),
                  icon: const Icon(Icons.add),
                  label: Text(p.nome),
                ),
            ],
          ),
          const Text(
            'Nenhum valor vem preenchido. O Commander é cobrado por seção; os '
            'demais, por linha.',
            style: TextStyle(fontSize: 13, color: Cores.textoSecundario),
          ),
        ]),
        if (e.total > 0) ...[
          const SizedBox(height: 12),
          _Totalizador(estado: e),
        ],
      ],
    );
  }
}

class _CartaoItem extends StatelessWidget {
  final PropostaEstado estado;
  final int indice;

  const _CartaoItem({super.key, required this.estado, required this.indice});

  @override
  Widget build(BuildContext context) {
    final item = estado.itens[indice];
    void mudar(void Function(ItemEdicao) m) => estado.mudarItem(indice, m);
    final campanha = item.campanhaNum;
    return CartaoBranco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.produto.nome,
                  style: const TextStyle(
                    fontFamily: fonteTitulo,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remover ${item.produto.nome}',
                onPressed: () => estado.remover(indice),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          if (item.produto.fornecimentos.length > 1)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final MapEntry(key: f, value: nome)
                    in item.produto.fornecimentos.entries)
                  _chip(
                    nome,
                    f == item.fornecimento,
                    () => mudar((i) => i.fornecimento = f),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          _par(
            _Campo(
              valor: item.plantadeira,
              rotulo: 'Plantadeira',
              dica: 'Ex.: Tatu PST',
              aoMudar: (t) => mudar((i) => i.plantadeira = t),
            ),
            _Campo(
              valor: item.linhas,
              rotulo: _maiuscula(item.produto.unidades),
              numero: true,
              aoMudar: (t) => mudar((i) => i.linhas = t),
            ),
          ),
          const SizedBox(height: 12),
          _par(
            _Campo(
              valor: item.valorLinha,
              rotulo: 'Valor por ${item.produto.unidade} (tabela)',
              numero: true,
              sufixo: 'R\$',
              aoMudar: (t) => mudar((i) => i.valorLinha = t),
            ),
            _Campo(
              valor: item.valorCampanha,
              rotulo: 'Valor de campanha (opcional)',
              numero: true,
              sufixo: 'R\$',
              aoMudar: (t) => mudar((i) => i.valorCampanha = t),
            ),
          ),
          if (item.total > 0) ...[
            const SizedBox(height: 10),
            Text(
              campanha == null
                  ? 'Total do item: ${reais(item.total)}'
                  : 'Condição especial: ${reais(item.total)} '
                        '(sem campanha ${reais(item.linhasNum * item.valorNum)})',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Cores.verdeTexto,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Totalizador extends StatelessWidget {
  final PropostaEstado estado;

  const _Totalizador({required this.estado});

  @override
  Widget build(BuildContext context) {
    final tabela = estado.itens.fold(
      0.0,
      (s, i) => s + i.linhasNum * i.valorNum,
    );
    final economia = tabela - estado.total;
    Widget valor(String t, String v, {bool vivo = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: Cores.cinza,
          ),
        ),
        Text(
          v,
          style: TextStyle(
            fontFamily: fonteTitulo,
            fontSize: vivo ? 28 : 20,
            fontWeight: FontWeight.w700,
            color: vivo ? Cores.verdeVivo : Cores.branco,
          ),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Cores.verdeEscuro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 28,
            runSpacing: 8,
            children: [
              if (economia > 0.004) ...[
                valor('Sem campanha', reais(tabela, 0)),
                valor('Economia do cliente', reais(economia, 0)),
              ],
              valor('Total da proposta', reais(estado.total), vivo: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valorPorExtenso(estado.total),
            style: const TextStyle(color: Cores.verdeClaro),
          ),
        ],
      ),
    );
  }
}

class _EtapaCondicoes extends StatelessWidget {
  final PropostaEstado estado;

  const _EtapaCondicoes({required this.estado});

  @override
  Widget build(BuildContext context) {
    final e = estado;
    final soma = e.somaPagamento;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _secao('Valor', [
          Text(
            'Total: ${reais(e.total)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          _campo(
            e,
            'impostos',
            'Impostos e frete (opcional)',
            dica: 'Ex.: + Difal + Frete',
          ),
        ]),
        const SizedBox(height: 12),
        _secao('Pagamento', [
          _campo(e, 'entrada', 'Entrada', numero: true, sufixo: '%'),
          for (final (i, (fracao, quando)) in e.parcelas.indexed)
            Row(
              key: ValueKey('parcela-$i-${e.parcelas.length}'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Campo(
                    valor: fracao,
                    rotulo: '${i + 1}ª parcela',
                    numero: true,
                    sufixo: '%',
                    aoMudar: (t) => e.mudarParcela(i, fracao: t),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _Campo(
                    valor: quando,
                    rotulo: 'Vencimento',
                    dica: 'Ex.: 30/04/2027',
                    aoMudar: (t) => e.mudarParcela(i, quando: t),
                  ),
                ),
                IconButton(
                  tooltip: 'Remover parcela',
                  onPressed: () => e.removerParcela(i),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: e.adicionarParcela,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar parcela'),
            ),
          ),
          if (e.temPagamento)
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
            _campo(e, 'validade', 'Validade da proposta', dica: 'Ex.: 15 dias'),
            _campo(e, 'prazo', 'Prazo de entrega', dica: 'Ex.: 30 dias'),
          ),
          _par(
            _campo(e, 'local', 'Local de entrega', dica: 'Ex.: A combinar'),
            _campo(e, 'agente', 'Agente financeiro'),
          ),
          _campo(e, 'garantia', 'Garantia', dica: 'Ex.: 1 ano'),
        ]),
      ],
    );
  }
}

class _EtapaAnexos extends StatelessWidget {
  final PropostaEstado estado;

  const _EtapaAnexos({required this.estado});

  Future<void> _abrirRoi(BuildContext context) async {
    estado.prepararRoi();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoiPage(estado: estado.roi, naProposta: true),
      ),
    );
    // O ROI mudou fora desta tela: redesenha com o resultado novo.
    estado.anexos();
  }

  @override
  Widget build(BuildContext context) {
    final e = estado;
    final pendencias = e.pendenciasRoi;
    final roiPronto = pendencias.isEmpty;
    final r = roiPronto ? CalculadoraRoi.calcular(e.premissasRoi) : null;
    final cenario = r?.cenarios[e.roi.cenario];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CartaoBranco(
          child: Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: e.paginasProdutos,
              onChanged: (v) => e.anexos(produtos: v),
              title: const Text(
                'Páginas dos produtos',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Uma página por produto: prova de campo, benefícios e o que '
                'vem no sistema.',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: e.comRetorno,
                  onChanged: (v) => e.anexos(retorno: v),
                  title: const Text(
                    'Retorno do investimento',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Curva de payback, composição do ganho e cenários, com o '
                    'total da proposta como investimento.',
                  ),
                ),
              ),
              if (e.comRetorno) ...[
                const SizedBox(height: 8),
                if (cenario != null)
                  Text(
                    'ROI preenchido: ${numeroBr(e.premissasRoi.areaHa, 0)} ha, '
                    'cenário ${e.roi.cenario.nome.toLowerCase()}, '
                    '${reais(cenario.beneficioSafra, 0)} por safra.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Cores.verdeTexto,
                    ),
                  )
                else
                  Text(
                    pendencias.join(' '),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: TipoAviso.atencao.cor,
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _abrirRoi(context),
                      icon: const Icon(Icons.trending_up),
                      label: Text(
                        roiPronto ? 'Revisar o ROI' : 'Preencher o ROI',
                      ),
                    ),
                    if (roiPronto)
                      for (final c in CenarioRoi.values)
                        _chip(
                          c.nome,
                          c == e.roi.cenario,
                          () => e
                            ..roi.escolherCenario(c)
                            ..anexos(),
                        ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Opacity(
          opacity: 0.6,
          child: CartaoBranco(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avaliação de plantio do cliente · próxima etapa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Duplas, falhas e CV medidos na fazenda, como prova na '
                  'própria máquina do cliente.',
                  style: TextStyle(color: Cores.textoSecundario),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Previa extends StatelessWidget {
  final PropostaEstado estado;

  const _Previa({required this.estado});

  @override
  Widget build(BuildContext context) {
    final dados = estado.dados(DateTime.now());
    final nome = dados.cliente
        .replaceAll(RegExp(r'[^A-Za-zÀ-ú0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Aviso(
            'Nada desta proposta fica salvo: depois de imprimir ou '
            'compartilhar o PDF, os dados são descartados.',
            tipo: TipoAviso.atencao,
          ),
        ),
        Expanded(
          child: PdfPreview(
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            pdfFileName: 'Proposta_JAssy_$nome.pdf',
            build: (_) async => gerarPropostaPdf(
              dados: dados,
              premissas: estado.comRetorno ? estado.roi.premissas : null,
              cenario: estado.roi.cenario,
              recursos: await RecursosPdf.carregar(),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: estado.voltar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Voltar e editar'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _maiuscula(String t) => t[0].toUpperCase() + t.substring(1);
