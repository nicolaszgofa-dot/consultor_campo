import 'package:flutter/material.dart';

import '../tema.dart';

/// Cabeçalho escuro das telas do fluxo, com o passo atual (1 a 4).
class CabecalhoFluxo extends StatelessWidget {
  final String titulo;
  final int? passo;
  final int totalPassos;

  const CabecalhoFluxo({
    super.key,
    required this.titulo,
    this.passo,
    this.totalPassos = 4,
  });

  @override
  Widget build(BuildContext context) {
    final podeVoltar = Navigator.of(context).canPop();
    return Container(
      color: Cores.verdeEscuro,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (podeVoltar)
                    IconButton(
                      tooltip: 'Voltar',
                      color: Cores.branco,
                      icon: const Icon(Icons.chevron_left, size: 30),
                      onPressed: () => Navigator.of(context).maybePop(),
                    )
                  else
                    const SizedBox(height: 48),
                  const Spacer(),
                  if (passo != null)
                    Text(
                      'PASSO $passo DE $totalPassos',
                      style: const TextStyle(
                        color: Cores.cinza,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontFamily: fonteTitulo,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: Cores.branco,
                      ),
                    ),
                    if (passo != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          for (var i = 1; i <= totalPassos; i++) ...[
                            if (i > 1) const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: i <= passo!
                                      ? Cores.verdeVivo
                                      : Cores.passoPendente,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
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

/// Estrutura comum das telas do fluxo: cabeçalho, conteúdo rolável e rodapé.
class TelaFluxo extends StatelessWidget {
  final String titulo;
  final int? passo;
  final List<Widget> filhos;
  final Widget? rodape;

  const TelaFluxo({
    super.key,
    required this.titulo,
    this.passo,
    required this.filhos,
    this.rodape,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CabecalhoFluxo(titulo: titulo, passo: passo),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  children: [
                    for (var i = 0; i < filhos.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      filhos[i],
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (rodape != null)
            SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: SizedBox(width: double.infinity, child: rodape),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CartaoBranco extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CartaoBranco({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Cores.borda),
      ),
      child: child,
    );
  }
}

class RotuloSecao extends StatelessWidget {
  final String texto;

  const RotuloSecao(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: Cores.textoSecundario,
      ),
    );
  }
}

/// Número grande com rótulo pequeno embaixo ou em cima.
class Indicador extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color corRotulo;

  const Indicador({
    super.key,
    required this.rotulo,
    required this.valor,
    this.corRotulo = Cores.textoSecundario,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: corRotulo,
          ),
        ),
        Text(
          valor,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Grupo de opções lado a lado (ex.: cultura, cenário).
class Seletor<T> extends StatelessWidget {
  final List<T> opcoes;
  final T selecionada;
  final String Function(T) rotulo;
  final ValueChanged<T> aoEscolher;

  const Seletor({
    super.key,
    required this.opcoes,
    required this.selecionada,
    required this.rotulo,
    required this.aoEscolher,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < opcoes.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _BotaoOpcao(
              texto: rotulo(opcoes[i]),
              ativo: opcoes[i] == selecionada,
              aoTocar: () => aoEscolher(opcoes[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _BotaoOpcao extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback aoTocar;

  const _BotaoOpcao({
    required this.texto,
    required this.ativo,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: ativo,
      button: true,
      child: Material(
        color: ativo ? Cores.verdeEscuro : Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: ativo ? Cores.verdeEscuro : Cores.cinza),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: aoTocar,
          child: SizedBox(
            height: 46,
            child: Center(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ativo ? Cores.branco : Cores.tinta,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
