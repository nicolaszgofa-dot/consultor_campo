import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import 'conceitos.dart';

/// Lista dos conceitos técnicos, no mesmo estilo de cartões da tela inicial.
class ConceitoPage extends StatelessWidget {
  const ConceitoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoFluxo(titulo: 'Conceito'),
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
                      mainAxisExtent: colunas == 1 ? 120 : 180,
                      children: [
                        for (final c in conceitos)
                          _CartaoConceito(
                            conceito: c,
                            compacto: colunas == 1,
                            aoAbrir: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ConceitoDetalhePage(conceito: c),
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

class _CartaoConceito extends StatelessWidget {
  final Conceito conceito;
  final bool compacto;
  final VoidCallback aoAbrir;

  const _CartaoConceito({
    required this.conceito,
    required this.compacto,
    required this.aoAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final icone = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Cores.verdeClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(conceito.icone, size: 28, color: Cores.verdeTexto),
    );
    final textos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          conceito.titulo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: fonteTitulo,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          conceito.resumo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Cores.textoSecundario),
        ),
      ],
    );
    return Semantics(
      button: true,
      label: conceito.titulo,
      child: Material(
        color: Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Cores.borda),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoAbrir,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: compacto
                ? Row(
                    children: [
                      icone,
                      const SizedBox(width: 14),
                      Expanded(child: textos),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [icone, const Spacer(), textos],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Texto de um conceito, montado a partir dos blocos.
class ConceitoDetalhePage extends StatelessWidget {
  final Conceito conceito;

  const ConceitoDetalhePage({super.key, required this.conceito});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CabecalhoFluxo(titulo: conceito.titulo),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    for (final b in conceito.blocos) ...[
                      _BlocoConceito(bloco: b),
                      const SizedBox(height: 12),
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
}

class _BlocoConceito extends StatelessWidget {
  final Bloco bloco;

  const _BlocoConceito({required this.bloco});

  @override
  Widget build(BuildContext context) {
    const corpo = TextStyle(fontSize: 17, height: 1.45, color: Cores.tinta);
    return switch (bloco) {
      Paragrafo(:final texto) => Text(texto, style: corpo),
      Subtitulo(:final texto) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          texto,
          style: const TextStyle(
            fontFamily: fonteTitulo,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Lista(:final itens) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final i in itens)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 9, right: 10),
                    child: Icon(Icons.circle, size: 7, color: Cores.verde),
                  ),
                  Expanded(child: Text(i, style: corpo)),
                ],
              ),
            ),
        ],
      ),
      Formula(:final texto) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Cores.verdeClaro,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Cores.verdeEscuro,
          ),
        ),
      ),
      // Colunas dividem a largura e o texto quebra: nada fica escondido.
      Tabela(:final cabecalho, :final linhas) => CartaoBranco(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: const TableBorder(
            horizontalInside: BorderSide(color: Cores.neutro),
          ),
          children: [
            TableRow(
              children: [
                for (final c in cabecalho)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: Text(
                      c,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Cores.textoSecundario,
                      ),
                    ),
                  ),
              ],
            ),
            for (final l in linhas)
              TableRow(
                children: [
                  for (final v in l)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                      child: Text(v, style: const TextStyle(fontSize: 15)),
                    ),
                ],
              ),
          ],
        ),
      ),
      Nota(:final texto) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 8),
            child: Icon(
              Icons.info_outline,
              size: 18,
              color: Cores.textoSecundario,
            ),
          ),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Cores.textoSecundario,
              ),
            ),
          ),
        ],
      ),
    };
  }
}
