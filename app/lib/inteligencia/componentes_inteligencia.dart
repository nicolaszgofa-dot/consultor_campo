import 'package:flutter/material.dart';

import '../tema.dart';

/// Botão de opção compacto, para listas que quebram linha (linhas de
/// produto, concorrentes, filtros).
class OpcaoChip extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback aoTocar;

  const OpcaoChip({
    super.key,
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 15,
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

/// Faixa vermelha: a tela ainda é conceito.
class AlertaConceitoInteligencia extends StatelessWidget {
  final String texto;

  const AlertaConceitoInteligencia(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Cores.prejuizo),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Cores.prejuizo),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Em conceito. ',
                style: const TextStyle(fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text: texto,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF7A1A12)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Título de seção em caixa alta, na cor indicada.
class TituloSecao extends StatelessWidget {
  final String texto;
  final Color cor;

  const TituloSecao(this.texto, {super.key, this.cor = Cores.textoSecundario});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: cor,
      ),
    );
  }
}

/// Item de lista com ícone redondo à esquerda.
class ItemMarcado extends StatelessWidget {
  final String texto;
  final IconData icone;
  final Color fundo;
  final Color cor;

  const ItemMarcado({
    super.key,
    required this.texto,
    required this.icone,
    required this.fundo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
            child: Icon(icone, size: 15, color: cor),
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
