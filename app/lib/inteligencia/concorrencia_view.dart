import 'package:flutter/material.dart';

import '../avaliacao/avaliacao_hub_page.dart';
import '../configurador/configurador_page.dart';
import '../roi/roi_page.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import 'componentes_inteligencia.dart';
import 'concorrencia_dados.dart';

enum FormatoConcorrencia { batalha, tecnica }

/// Aba Concorrência: ficha de batalha ou ficha técnica de cada linha de
/// produto.
class ConcorrenciaView extends StatefulWidget {
  const ConcorrenciaView({super.key});

  @override
  State<ConcorrenciaView> createState() => _ConcorrenciaViewState();
}

class _ConcorrenciaViewState extends State<ConcorrenciaView> {
  LinhaProduto _linha = linhasProduto.first;
  var _formato = FormatoConcorrencia.batalha;
  final _concorrente = <String, String>{};

  @override
  Widget build(BuildContext context) {
    final concId = _concorrente[_linha.id] ?? _linha.concorrentes.first.id;
    final conc = _linha.concorrentes.firstWhere((c) => c.id == concId);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1140),
        child: LayoutBuilder(
          builder: (context, box) {
            final largo = box.maxWidth >= 760;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                const AlertaConceitoInteligencia(
                  'Rascunho para o time comercial validar. Não usar como '
                  'informação certa em negociação.',
                ),
                const SizedBox(height: 14),
                const TituloSecao('Linha de produto'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final l in linhasProduto)
                      OpcaoChip(
                        texto: l.nome,
                        ativo: l == _linha,
                        aoTocar: () => setState(() => _linha = l),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedButton<FormatoConcorrencia>(
                  segments: const [
                    ButtonSegment(
                      value: FormatoConcorrencia.batalha,
                      label: Text('Ficha de batalha'),
                    ),
                    ButtonSegment(
                      value: FormatoConcorrencia.tecnica,
                      label: Text('Ficha técnica'),
                    ),
                  ],
                  selected: {_formato},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _formato = s.first),
                ),
                const SizedBox(height: 14),
                if (_formato == FormatoConcorrencia.batalha)
                  _FichaBatalha(
                    linha: _linha,
                    concorrente: conc,
                    largo: largo,
                    aoEscolher: (c) =>
                        setState(() => _concorrente[_linha.id] = c.id),
                  )
                else
                  _FichaTecnica(linha: _linha),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --------------------------------------------------------- ficha de batalha

class _FichaBatalha extends StatelessWidget {
  final LinhaProduto linha;
  final Concorrente concorrente;
  final bool largo;
  final ValueChanged<Concorrente> aoEscolher;

  const _FichaBatalha({
    required this.linha,
    required this.concorrente,
    required this.largo,
    required this.aoEscolher,
  });

  @override
  Widget build(BuildContext context) {
    final objecoes = [...linha.objecoesComuns, ...concorrente.objecoes];
    final ganhamos = _Cartao(
      titulo: 'Onde ganhamos',
      cor: Cores.verdeTexto,
      filhos: [
        for (final g in linha.ganhamos)
          ItemMarcado(
            texto: g,
            icone: Icons.check,
            fundo: const Color(0xFFDDF1DF),
            cor: const Color(0xFF145A1D),
          ),
      ],
    );
    final ataca = _Cartao(
      titulo: 'Onde ${concorrente.nome} ataca',
      cor: Cores.atencao,
      filhos: [
        for (final a in concorrente.ataca)
          ItemMarcado(
            texto: a,
            icone: Icons.priority_high,
            fundo: const Color(0xFFFFF1D6),
            cor: const Color(0xFF7A4800),
          ),
      ],
    );
    final respostas = _Cartao(
      titulo: 'Objeções e respostas',
      filhos: [for (final o in objecoes) _ObjecaoResposta(objecao: o)],
    );
    final perguntas = _Cartao(
      titulo: 'Perguntas para o produtor',
      filhos: [
        for (var i = 0; i < linha.perguntas.length; i++)
          _Numerado(numero: i + 1, texto: linha.perguntas[i]),
      ],
    );
    final provasApp = _Cartao(
      titulo: 'Prove no cliente, com o app',
      filhos: [
        for (var i = 0; i < linha.provasApp.length; i++)
          _ProvaAppBotao(numero: i + 1, prova: linha.provasApp[i]),
      ],
    );

    Widget emDuas(Widget a, Widget b) => largo
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: a),
                const SizedBox(width: 14),
                Expanded(child: b),
              ],
            ),
          )
        : Column(children: [a, const SizedBox(height: 14), b]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Tese(linha: linha, largo: largo),
        if (linha.destaque != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Cores.verdeClaro,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA9DDB0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Cores.verdeTexto),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    linha.destaque!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Cores.verdeEscuro,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        const TituloSecao('Contra'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in linha.concorrentes)
              OpcaoChip(
                texto: c.nome,
                ativo: c == concorrente,
                aoTocar: () => aoEscolher(c),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          concorrente.produto,
          style: const TextStyle(fontSize: 14, color: Cores.textoSecundario),
        ),
        const SizedBox(height: 14),
        if (largo)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [ganhamos, const SizedBox(height: 14), ataca],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: respostas),
              ],
            ),
          )
        else ...[
          ganhamos,
          const SizedBox(height: 14),
          ataca,
          const SizedBox(height: 14),
          respostas,
        ],
        const SizedBox(height: 14),
        _ProvaCientifica(linha: linha, largo: largo),
        const SizedBox(height: 14),
        emDuas(perguntas, provasApp),
        const SizedBox(height: 12),
        const Text(
          'Fatos dos concorrentes: sites e imprensa (26/10/2026); números deles '
          'são do fabricante. Estudos: base de conhecimento J.Assy. Respostas e '
          'perguntas são sugestões para o time comercial revisar.',
          style: TextStyle(fontSize: 12, color: Cores.textoSecundario),
        ),
      ],
    );
  }
}

class _Tese extends StatelessWidget {
  final LinhaProduto linha;
  final bool largo;

  const _Tese({required this.linha, required this.largo});

  @override
  Widget build(BuildContext context) {
    final texto = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOSSA TESE · ${linha.jassy.toUpperCase()}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Color(0xFF9FE09A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          linha.tese,
          style: const TextStyle(
            fontFamily: fonteTitulo,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: Cores.branco,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          linha.apoio,
          style: const TextStyle(fontSize: 15, color: Color(0xFFD3EBD0)),
        ),
      ],
    );
    final numero = Container(
      width: largo ? 230 : double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x2EFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            linha.numero,
            style: const TextStyle(
              fontFamily: fonteTitulo,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              height: 1,
              color: Color(0xFF9FE09A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            linha.numeroTexto,
            style: const TextStyle(fontSize: 14, color: Cores.branco),
          ),
          const SizedBox(height: 4),
          Text(
            linha.numeroFonte,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9FE09A)),
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Cores.verdeEscuro,
        borderRadius: BorderRadius.circular(18),
      ),
      child: largo
          ? Row(
              children: [
                Expanded(child: texto),
                const SizedBox(width: 18),
                numero,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [texto, const SizedBox(height: 12), numero],
            ),
    );
  }
}

class _Cartao extends StatelessWidget {
  final String titulo;
  final Color cor;
  final List<Widget> filhos;

  const _Cartao({
    required this.titulo,
    this.cor = Cores.textoSecundario,
    required this.filhos,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoBranco(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TituloSecao(titulo, cor: cor),
          const SizedBox(height: 6),
          ...filhos,
        ],
      ),
    );
  }
}

class _ObjecaoResposta extends StatelessWidget {
  final Objecao objecao;

  const _ObjecaoResposta({required this.objecao});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Cores.neutro)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“${objecao.objecao}”',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            objecao.resposta,
            style: const TextStyle(fontSize: 15, height: 1.45),
          ),
          if (objecao.confirmar) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1D6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Confirmar com a engenharia J.Assy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7A4800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProvaCientifica extends StatelessWidget {
  final LinhaProduto linha;
  final bool largo;

  const _ProvaCientifica({required this.linha, required this.largo});

  @override
  Widget build(BuildContext context) {
    final cartoes = [for (final p in linha.provas) _CartaoProva(prova: p)];
    return CartaoBranco(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TituloSecao('Prova científica', cor: Cores.dupla),
          const SizedBox(height: 2),
          const Text(
            'Estudos de universidades da base de conhecimento J.Assy',
            style: TextStyle(fontSize: 13, color: Cores.textoSecundario),
          ),
          const SizedBox(height: 10),
          if (largo)
            for (var i = 0; i < cartoes.length; i += 2) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cartoes[i]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: i + 1 < cartoes.length
                          ? cartoes[i + 1]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ]
          else
            for (final c in cartoes) ...[c, const SizedBox(height: 10)],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF2D49B)),
            ),
            child: Text.rich(
              TextSpan(
                text: 'Cuidado ao usar: ',
                style: const TextStyle(fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text: linha.cuidado,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF5C3A00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoProva extends StatelessWidget {
  final Prova prova;

  const _CartaoProva({required this.prova});

  @override
  Widget build(BuildContext context) {
    final (fundo, cor) = prova.tipo.aFavor
        ? (const Color(0xFFDDF1DF), const Color(0xFF145A1D))
        : prova.tipo == TipoProva.cuidado
        ? (const Color(0xFFFFF1D6), const Color(0xFF7A4800))
        : (Cores.neutro, Cores.tinta);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5DEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _Etiqueta(prova.fonte, Cores.dupla, Cores.branco),
              _Etiqueta(prova.tipo.rotulo, fundo, cor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            prova.achado,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              text: 'Como usar: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
              children: [
                TextSpan(
                  text: prova.uso,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
              ],
            ),
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF3F4145),
            ),
          ),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color fundo;
  final Color cor;

  const _Etiqueta(this.texto, this.fundo, this.cor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cor),
      ),
    );
  }
}

class _Numerado extends StatelessWidget {
  final int numero;
  final String texto;

  const _Numerado({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Cores.verdeEscuro,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$numero',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Cores.branco,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Abre a ferramenta do app citada na prova.
Widget? _telaDaProva(String titulo) {
  if (titulo.startsWith('Avaliação')) return const AvaliacaoHubPage();
  if (titulo == 'ROI') return const RoiPage();
  if (titulo == 'Configurador') return const ConfiguradorPage();
  return null;
}

class _ProvaAppBotao extends StatelessWidget {
  final int numero;
  final ProvaApp prova;

  const _ProvaAppBotao({required this.numero, required this.prova});

  @override
  Widget build(BuildContext context) {
    final tela = _telaDaProva(prova.titulo);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFFF7FCF7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Cores.borda),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: tela == null
              ? null
              : () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => tela)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Cores.verdeClaro,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$numero',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Cores.verdeTexto,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prova.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        prova.texto,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Cores.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tela != null)
                  const Icon(Icons.chevron_right, color: Cores.verdeTexto),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------- ficha técnica

class _FichaTecnica extends StatelessWidget {
  final LinhaProduto linha;

  const _FichaTecnica({required this.linha});

  @override
  Widget build(BuildContext context) {
    final n = linha.produtos.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (linha.destaque != null) ...[
          Text(
            linha.destaque!,
            style: const TextStyle(fontSize: 15, color: Cores.verdeEscuro),
          ),
          const SizedBox(height: 10),
        ],
        CartaoBranco(
          padding: EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, box) {
              const criterio = 150.0;
              const coluna = 170.0;
              final cabe = box.maxWidth >= criterio + n * coluna;
              final tabela = Table(
                defaultVerticalAlignment:
                    TableCellVerticalAlignment.intrinsicHeight,
                columnWidths: {
                  0: const FixedColumnWidth(criterio),
                  for (var i = 1; i <= n; i++)
                    i: cabe
                        ? const FlexColumnWidth()
                        : const FixedColumnWidth(coluna),
                },
                border: const TableBorder(
                  horizontalInside: BorderSide(color: Cores.neutro),
                  verticalInside: BorderSide(color: Cores.neutro),
                ),
                children: [
                  TableRow(
                    children: [
                      const _Celula(child: TituloSecao('Critério')),
                      for (final p in linha.produtos) _Cabecalho(produto: p),
                    ],
                  ),
                  for (final (id, nome) in linha.criterios)
                    TableRow(
                      decoration: BoxDecoration(
                        color: id == 'oferta' ? const Color(0xFFFFFBEA) : null,
                      ),
                      children: [
                        _Celula(
                          child: Text(
                            nome,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        for (final p in linha.produtos)
                          _Celula(
                            fundo: p.jassy ? const Color(0xFFF3FAF4) : null,
                            child: _ValorCelula(celula: p.valores[id] ?? ni()),
                          ),
                      ],
                    ),
                ],
              );
              return cabe
                  ? tabela
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: tabela,
                    );
            },
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Verde: tem, segundo o fabricante. Cinza: não informado, a fonte pública não '
          'diz, confirme antes de usar com cliente.',
          style: TextStyle(fontSize: 13, color: Cores.textoSecundario),
        ),
        const SizedBox(height: 10),
        const TituloSecao('Fontes · levantadas em 26/10/2026'),
        const SizedBox(height: 4),
        for (final f in linha.fontes)
          Text(
            '${f.rotulo}: ${f.url}',
            style: const TextStyle(fontSize: 13, color: Cores.textoSecundario),
          ),
      ],
    );
  }
}

class _Celula extends StatelessWidget {
  final Widget child;
  final Color? fundo;

  const _Celula({required this.child, this.fundo});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fundo,
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final ProdutoTecnico produto;

  const _Cabecalho({required this.produto});

  @override
  Widget build(BuildContext context) {
    final noMercado =
        produto.situacao == 'No mercado' || produto.situacao == 'De fábrica';
    return _Celula(
      fundo: produto.jassy ? const Color(0xFFF3FAF4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Etiqueta(
            produto.marca.toUpperCase(),
            produto.jassy ? Cores.verde : Cores.neutro,
            produto.jassy ? Cores.branco : const Color(0xFF3F4145),
          ),
          const SizedBox(height: 4),
          Text(
            produto.nome,
            style: const TextStyle(
              fontFamily: fonteTitulo,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          Text(
            produto.situacao,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: noMercado ? Cores.verdeTexto : Cores.atencao,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValorCelula extends StatelessWidget {
  final Celula celula;

  const _ValorCelula({required this.celula});

  @override
  Widget build(BuildContext context) {
    final (icone, fundo, cor) = switch (celula.tipo) {
      TipoCelula.tem => (
        Icons.check,
        const Color(0xFFDDF1DF),
        const Color(0xFF145A1D),
      ),
      TipoCelula.naoInformado => (
        Icons.question_mark,
        Cores.neutro,
        Cores.textoSecundario,
      ),
      TipoCelula.info => (
        Icons.circle,
        Colors.transparent,
        Cores.textoSecundario,
      ),
    };
    final ni = celula.tipo == TipoCelula.naoInformado;
    final texto = ni
        ? (celula.texto == null
              ? 'Não informado'
              : 'Não informado; ${celula.texto}')
        : celula.texto!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
          child: Icon(
            icone,
            size: celula.tipo == TipoCelula.info ? 6 : 13,
            color: cor,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: ni ? Cores.textoSecundario : Cores.tinta,
            ),
          ),
        ),
      ],
    );
  }
}
