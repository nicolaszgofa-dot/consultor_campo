import 'package:flutter/material.dart';

import 'em_breve_page.dart';
import 'funcionalidades.dart';
import 'tema.dart';

/// Tela inicial: todas as funcionalidades em cartões do mesmo tamanho.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _abrir(BuildContext context, Funcionalidade f) {
    final tela =
        f.tela?.call() ??
        EmBrevePage(titulo: f.titulo, descricao: f.descricao, icone: f.icone);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _Cabecalho(),
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
                      mainAxisExtent: colunas == 1 ? 150 : 200,
                      children: [
                        for (final f in funcionalidades)
                          _CartaoFuncionalidade(
                            funcionalidade: f,
                            compacto: colunas == 1,
                            aoAbrir: () => _abrir(context, f),
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

class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Cores.verdeEscuro,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Cores.verde,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.eco, color: Cores.verdeEscuro),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'CONSULTOR DE CAMPO',
                        style: TextStyle(
                          color: Cores.cinza,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'O que vamos fazer hoje?',
                    style: TextStyle(
                      fontFamily: fonteTitulo,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      color: Cores.branco,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Escolha uma funcionalidade',
                    style: TextStyle(fontSize: 16, color: Cores.cinza),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartaoFuncionalidade extends StatelessWidget {
  final Funcionalidade funcionalidade;
  final bool compacto;
  final VoidCallback aoAbrir;

  const _CartaoFuncionalidade({
    required this.funcionalidade,
    required this.compacto,
    required this.aoAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final f = funcionalidade;
    final icone = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: f.emBreve ? Cores.neutro : Cores.verdeClaro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        f.icone,
        size: 30,
        color: f.emBreve ? Cores.cinzaEscuro : Cores.verdeTexto,
      ),
    );
    final etiqueta = f.emBreve ? const _EmBreve() : const SizedBox.shrink();
    final titulo = Text(
      f.titulo,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: fonteTitulo,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );
    final textos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // No celular a etiqueta fica junto do título, sem apertar o nome.
        if (compacto && f.emBreve)
          Wrap(
            spacing: 8,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [titulo, etiqueta],
          )
        else
          titulo,
        const SizedBox(height: 2),
        Text(
          f.descricao,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, color: Cores.textoSecundario),
        ),
      ],
    );

    return Semantics(
      button: true,
      label: f.emBreve ? '${f.titulo}, em breve' : f.titulo,
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
            padding: const EdgeInsets.all(20),
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [icone, etiqueta],
                      ),
                      const Spacer(),
                      textos,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmBreve extends StatelessWidget {
  const _EmBreve();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Cores.neutro,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'EM BREVE',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: Cores.textoSecundario,
        ),
      ),
    );
  }
}
