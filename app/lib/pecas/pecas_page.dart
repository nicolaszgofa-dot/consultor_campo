import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import 'lista_pecas.dart';
import 'pecas_dados.dart';

/// Entrada das peças de reposição: busca por código ou nome e produtos.
class PecasPage extends StatefulWidget {
  final List<ProdutoPecas>? produtos;

  const PecasPage({super.key, this.produtos});

  @override
  State<PecasPage> createState() => _PecasPageState();
}

class _PecasPageState extends State<PecasPage> {
  final _lista = ListaPecas();
  final _busca = TextEditingController();

  List<ProdutoPecas> get _produtos => widget.produtos ?? produtosPecas;

  @override
  void dispose() {
    _lista.dispose();
    _busca.dispose();
    super.dispose();
  }

  void _abrirConjunto(ProdutoPecas p, ConjuntoPecas c, [Peca? peca]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConjuntoPecasPage(
          produto: p,
          conjunto: c,
          lista: _lista,
          inicial: peca,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final termo = _busca.text.trim();
    final resultados = buscarPecas(termo, _produtos);
    return Scaffold(
      bottomNavigationBar: BarraListaPecas(lista: _lista),
      body: Column(
        children: [
          const CabecalhoFluxo(titulo: 'Peças de reposição'),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    TextField(
                      controller: _busca,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar por código ou nome da peça',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: termo.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Limpar busca',
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() => _busca.clear()),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (termo.isNotEmpty)
                      ..._resultados(resultados)
                    else ...[
                      const RotuloSecao('Produtos'),
                      const SizedBox(height: 10),
                      _GradeProdutos(
                        produtos: _produtos,
                        aoAbrir: (p) => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProdutoPecasPage(produto: p, lista: _lista),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _resultados(List<ResultadoPeca> resultados) {
    if (resultados.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Nenhuma peça encontrada. Por enquanto só o Selenium Elétric '
            'tem o catálogo cadastrado.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Cores.textoSecundario),
          ),
        ),
      ];
    }
    return [
      RotuloSecao(
        resultados.length == 1
            ? '1 peça encontrada'
            : '${resultados.length} peças encontradas',
      ),
      const SizedBox(height: 10),
      CartaoBranco(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (final (i, r) in resultados.indexed) ...[
              if (i > 0) const Divider(height: 1),
              LinhaPeca(
                peca: r.peca,
                detalhe: '${r.produto.nome} · ${r.conjunto.titulo}',
                lista: _lista,
                produto: r.produto.nome,
                aoTocar: () => _abrirConjunto(r.produto, r.conjunto, r.peca),
              ),
            ],
          ],
        ),
      ),
    ];
  }
}

class _GradeProdutos extends StatelessWidget {
  final List<ProdutoPecas> produtos;
  final ValueChanged<ProdutoPecas> aoAbrir;

  const _GradeProdutos({required this.produtos, required this.aoAbrir});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final colunas = box.maxWidth >= 840
            ? 3
            : box.maxWidth >= 480
            ? 2
            : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: colunas,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 104,
          children: [
            for (final p in produtos)
              _CartaoProduto(produto: p, aoAbrir: () => aoAbrir(p)),
          ],
        );
      },
    );
  }
}

class _CartaoProduto extends StatelessWidget {
  final ProdutoPecas produto;
  final VoidCallback aoAbrir;

  const _CartaoProduto({required this.produto, required this.aoAbrir});

  @override
  Widget build(BuildContext context) {
    final emBreve = produto.emBreve;
    final pecas = produto.conjuntos.fold(0, (s, c) => s + c.pecas.length);
    return Semantics(
      button: !emBreve,
      label: produto.nome,
      child: Material(
        color: Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Cores.borda),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: emBreve ? null : aoAbrir,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Opacity(
                  opacity: emBreve ? 0.45 : 1,
                  child: Image.asset(produto.icone, width: 72, height: 72),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        produto.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: fonteTitulo,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: emBreve ? Cores.textoSecundario : Cores.tinta,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        emBreve
                            ? 'Em breve'
                            : '${produto.conjuntos.length} conjuntos · '
                                  '$pecas peças',
                        style: TextStyle(
                          fontSize: 14,
                          color: emBreve
                              ? Cores.textoSecundario
                              : Cores.verdeTexto,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!emBreve)
                  const Icon(Icons.chevron_right, color: Cores.cinzaEscuro),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Conjuntos de um produto, cada um com a miniatura da vista explodida.
class ProdutoPecasPage extends StatelessWidget {
  final ProdutoPecas produto;
  final ListaPecas lista;

  const ProdutoPecasPage({
    super.key,
    required this.produto,
    required this.lista,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BarraListaPecas(lista: lista),
      body: Column(
        children: [
          CabecalhoFluxo(titulo: produto.nome),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final colunas = box.maxWidth >= 840
                        ? 3
                        : box.maxWidth >= 520
                        ? 2
                        : 1;
                    return GridView.count(
                      padding: const EdgeInsets.all(20),
                      crossAxisCount: colunas,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: colunas == 1 ? 300 : 340,
                      children: [
                        for (final c in produto.conjuntos)
                          _CartaoConjunto(
                            conjunto: c,
                            aoAbrir: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ConjuntoPecasPage(
                                  produto: produto,
                                  conjunto: c,
                                  lista: lista,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoConjunto extends StatelessWidget {
  final ConjuntoPecas conjunto;
  final VoidCallback aoAbrir;

  const _CartaoConjunto({required this.conjunto, required this.aoAbrir});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: conjunto.titulo,
      child: Material(
        color: Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Cores.borda),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoAbrir,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(conjunto.imagem, fit: BoxFit.contain),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conjunto.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: fonteTitulo,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${conjunto.pecas.length} peças · ${conjunto.resumo}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Cores.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vista explodida com os códigos tocáveis e a lista das peças.
class ConjuntoPecasPage extends StatefulWidget {
  final ProdutoPecas produto;
  final ConjuntoPecas conjunto;
  final ListaPecas lista;

  /// Peça já destacada ao abrir (vinda da busca).
  final Peca? inicial;

  const ConjuntoPecasPage({
    super.key,
    required this.produto,
    required this.conjunto,
    required this.lista,
    this.inicial,
  });

  @override
  State<ConjuntoPecasPage> createState() => _ConjuntoPecasPageState();
}

class _ConjuntoPecasPageState extends State<ConjuntoPecasPage> {
  final _zoom = TransformationController();
  final _chaves = <Peca, GlobalKey>{};
  Peca? _selecionada;
  Size _vista = Size.zero;

  ConjuntoPecas get _c => widget.conjunto;

  @override
  void initState() {
    super.initState();
    for (final p in _c.pecas) {
      _chaves[p] = GlobalKey();
    }
    final inicial = widget.inicial;
    if (inicial != null) {
      _selecionada = inicial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _aproximar(inicial);
        _mostrarNaLista(inicial);
      });
    }
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  /// Toque no desenho: destaca e leva a lista até a peça.
  void _tocarNoDesenho(Peca p) {
    setState(() => _selecionada = p);
    _mostrarNaLista(p);
  }

  /// Toque na lista: destaca e aproxima o desenho na peça.
  void _tocarNaLista(Peca p) {
    setState(() => _selecionada = p);
    _aproximar(p);
  }

  void _mostrarNaLista(Peca p) {
    final ctx = _chaves[p]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.3,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  void _aproximar(Peca p) {
    if (_vista.isEmpty) return;
    final vw = _vista.width, vh = _vista.height;
    final s = (vw / _c.largura) < (vh / _c.altura)
        ? vw / _c.largura
        : vh / _c.altura;
    final ox = (vw - _c.largura * s) / 2, oy = (vh - _c.altura * s) / 2;
    final cx = p.area.center.dx * s + ox, cy = p.area.center.dy * s + oy;
    // Aproxima até o desenho ficar ~3x maior que o original (máx. 4x).
    final z = (3 / s).clamp(1.0, 4.0);
    final tx = (vw / 2 - cx * z).clamp(vw - vw * z, 0.0);
    final ty = (vh / 2 - cy * z).clamp(vh - vh * z, 0.0);
    _zoom.value = Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(z, z, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final desenho = _VistaExplodida(
      conjunto: _c,
      selecionada: _selecionada,
      zoom: _zoom,
      aoTocar: _tocarNoDesenho,
      aoMedir: (s) => _vista = s,
    );
    final lista = ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      children: [
        for (final (i, p) in _c.pecas.indexed) ...[
          if (i > 0) const Divider(height: 1),
          LinhaPeca(
            key: _chaves[p],
            peca: p,
            lista: widget.lista,
            produto: widget.produto.nome,
            selecionada: identical(p, _selecionada),
            aoTocar: () => _tocarNaLista(p),
          ),
        ],
      ],
    );
    return Scaffold(
      bottomNavigationBar: BarraListaPecas(lista: widget.lista),
      body: Column(
        children: [
          CabecalhoFluxo(titulo: _c.titulo),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final largo = box.maxWidth >= 860;
                final painelLista = Material(color: Cores.branco, child: lista);
                if (largo) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: desenho),
                      const VerticalDivider(width: 1),
                      SizedBox(width: 420, child: painelLista),
                    ],
                  );
                }
                return Column(
                  children: [
                    Expanded(flex: 11, child: desenho),
                    const Divider(height: 1),
                    Expanded(flex: 9, child: painelLista),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VistaExplodida extends StatelessWidget {
  final ConjuntoPecas conjunto;
  final Peca? selecionada;
  final TransformationController zoom;
  final ValueChanged<Peca> aoTocar;
  final ValueChanged<Size> aoMedir;

  const _VistaExplodida({
    required this.conjunto,
    required this.selecionada,
    required this.zoom,
    required this.aoTocar,
    required this.aoMedir,
  });

  @override
  Widget build(BuildContext context) {
    final c = conjunto;
    return ColoredBox(
      color: Cores.branco,
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, box) {
                aoMedir(box.biggest);
                return InteractiveViewer(
                  transformationController: zoom,
                  maxScale: 6,
                  child: SizedBox.fromSize(
                    size: box.biggest,
                    child: FittedBox(
                      child: SizedBox(
                        width: c.largura,
                        height: c.altura,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(c.imagem, fit: BoxFit.fill),
                            ),
                            for (final p in c.pecas)
                              Positioned.fromRect(
                                rect: p.area.inflate(4),
                                child: _AlvoPeca(
                                  peca: p,
                                  selecionada: identical(p, selecionada),
                                  aoTocar: () => aoTocar(p),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 12,
            right: 60,
            bottom: 10,
            child: IgnorePointer(
              child: Text(
                'Toque num código para ver a peça. Use dois dedos para '
                'ampliar.',
                style: TextStyle(
                  fontSize: 13,
                  color: Cores.textoSecundario.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 4,
            child: IconButton(
              tooltip: 'Ver o desenho inteiro',
              icon: const Icon(Icons.zoom_out_map),
              onPressed: () => zoom.value = Matrix4.identity(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlvoPeca extends StatelessWidget {
  final Peca peca;
  final bool selecionada;
  final VoidCallback aoTocar;

  const _AlvoPeca({
    required this.peca,
    required this.selecionada,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${peca.codigo} ${peca.descricao}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: aoTocar,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selecionada
                  ? Cores.verdeVivo.withValues(alpha: 0.28)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              border: selecionada
                  ? Border.all(color: Cores.verdeEscuro, width: 2.5)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Linha de uma peça: código, descrição e botão de pôr na lista.
class LinhaPeca extends StatelessWidget {
  final Peca peca;
  final String? detalhe;
  final ListaPecas lista;
  final String produto;
  final bool selecionada;
  final VoidCallback aoTocar;

  const LinhaPeca({
    super.key,
    required this.peca,
    required this.lista,
    required this.produto,
    required this.aoTocar,
    this.detalhe,
    this.selecionada = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionada ? Cores.verdeClaro : Colors.transparent,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peca.codigo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Cores.verdeTexto,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      peca.descricao,
                      style: const TextStyle(fontSize: 16, height: 1.25),
                    ),
                    if (detalhe != null)
                      Text(
                        detalhe!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Cores.textoSecundario,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Copiar código',
                icon: const Icon(Icons.copy, size: 20),
                color: Cores.cinzaEscuro,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: peca.codigo));
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text('Código ${peca.codigo} copiado')),
                    );
                },
              ),
              ListenableBuilder(
                listenable: lista,
                builder: (context, _) {
                  final qtd = lista.quantidade(peca);
                  return IconButton(
                    tooltip: qtd == 0
                        ? 'Pôr na lista'
                        : 'Pôr mais uma na lista ($qtd)',
                    onPressed: () => lista.adicionar(peca, produto),
                    icon: qtd == 0
                        ? const Icon(Icons.add_circle_outline)
                        : Badge(
                            label: Text('$qtd'),
                            backgroundColor: Cores.verdeEscuro,
                            child: const Icon(Icons.playlist_add_check),
                          ),
                    color: Cores.verdeTexto,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra no rodapé com o total da lista; abre a lista para ajustar e copiar.
class BarraListaPecas extends StatelessWidget {
  final ListaPecas lista;

  const BarraListaPecas({super.key, required this.lista});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lista,
      builder: (context, _) {
        if (lista.vazia) return const SizedBox.shrink();
        final n = lista.totalPecas;
        return Material(
          color: Cores.verdeEscuro,
          child: SafeArea(
            top: false,
            child: InkWell(
              onTap: () => mostrarListaPecas(context, lista),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.playlist_add_check, color: Cores.branco),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        n == 1 ? '1 peça na lista' : '$n peças na lista',
                        style: const TextStyle(
                          color: Cores.branco,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Text(
                      'Ver lista',
                      style: TextStyle(
                        color: Cores.verdeVivo,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> mostrarListaPecas(BuildContext context, ListaPecas lista) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Cores.branco,
    builder: (context) => ListenableBuilder(
      listenable: lista,
      builder: (context, _) {
        if (lista.vazia) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).pop();
          });
          return const SizedBox(height: 80);
        }
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Text(
                  'Lista de peças',
                  style: TextStyle(
                    fontFamily: fonteTitulo,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'A lista não fica salva: copie e mande antes de sair.',
                  style: TextStyle(fontSize: 14, color: Cores.textoSecundario),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final i in lista.itens)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 8, 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i.peca.codigo,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Cores.verdeTexto,
                                    ),
                                  ),
                                  Text(
                                    i.peca.descricao,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Tirar uma',
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () =>
                                  lista.mudarQuantidade(i.peca, -1),
                            ),
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${i.quantidade}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Pôr mais uma',
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => lista.mudarQuantidade(i.peca, 1),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: lista.limpar,
                      child: const Text('Limpar'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar lista'),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: lista.comoTexto()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Lista copiada. Cole no WhatsApp ou no e-mail.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
