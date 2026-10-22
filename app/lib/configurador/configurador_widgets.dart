import 'package:flutter/material.dart';

import '../tema.dart';

enum TipoAviso {
  info(Cores.neutro, Cores.tinta, Icons.info_outline),
  ok(Cores.verdeClaro, Cores.verdeTexto, Icons.check_circle_outline),
  atencao(Color(0xFFFDF0E7), Color(0xFF9A3412), Icons.warning_amber_rounded),
  erro(Color(0xFFFDECEA), Color(0xFF8A1C12), Icons.error_outline);

  final Color fundo;
  final Color cor;
  final IconData icone;

  const TipoAviso(this.fundo, this.cor, this.icone);
}

/// Faixa colorida com ícone e texto.
class Aviso extends StatelessWidget {
  final String texto;
  final TipoAviso tipo;

  const Aviso(this.texto, {super.key, this.tipo = TipoAviso.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tipo.fundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tipo.icone, color: tipo.cor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: tipo.cor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botões de menos e mais em volta de um número.
class Contador extends StatelessWidget {
  final int valor;
  final VoidCallback? aoMenos;
  final VoidCallback? aoMais;
  final double tamanho;
  final String rotulo;

  const Contador({
    super.key,
    required this.valor,
    required this.aoMenos,
    required this.aoMais,
    required this.rotulo,
    this.tamanho = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BotaoContador(
          icone: Icons.remove,
          dica: 'Menos $rotulo',
          tamanho: tamanho,
          cheio: false,
          aoTocar: aoMenos,
        ),
        SizedBox(
          width: tamanho * 1.1,
          child: Text(
            '$valor',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fonteTitulo,
              fontSize: tamanho * 0.55,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _BotaoContador(
          icone: Icons.add,
          dica: 'Mais $rotulo',
          tamanho: tamanho,
          cheio: true,
          aoTocar: aoMais,
        ),
      ],
    );
  }
}

class _BotaoContador extends StatelessWidget {
  final IconData icone;
  final String dica;
  final double tamanho;
  final bool cheio;
  final VoidCallback? aoTocar;

  const _BotaoContador({
    required this.icone,
    required this.dica,
    required this.tamanho,
    required this.cheio,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final ativo = aoTocar != null;
    return Tooltip(
      message: dica,
      child: Material(
        color: cheio && ativo ? Cores.verdeEscuro : Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tamanho * 0.25),
          side: BorderSide(
            color: ativo ? Cores.verdeEscuro : Cores.borda,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(tamanho * 0.25),
          onTap: aoTocar,
          child: SizedBox(
            width: tamanho,
            height: tamanho,
            child: Icon(
              icone,
              size: tamanho * 0.5,
              color: !ativo
                  ? Cores.cinza
                  : cheio
                  ? Cores.branco
                  : Cores.verdeEscuro,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão selecionável grande (tecnologia, tipo de plantadeira).
class CartaoOpcao extends StatelessWidget {
  final bool selecionado;
  final VoidCallback aoTocar;
  final Widget child;

  const CartaoOpcao({
    super.key,
    required this.selecionado,
    required this.aoTocar,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selecionado,
      button: true,
      child: Material(
        color: Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selecionado ? Cores.verde : Cores.borda,
            width: selecionado ? 3 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(padding: const EdgeInsets.all(14), child: child),
        ),
      ),
    );
  }
}

/// Resposta sim ou não com botões grandes. [valor] nulo = sem resposta.
class SimNao extends StatelessWidget {
  final bool? valor;
  final ValueChanged<bool> aoEscolher;

  const SimNao({super.key, required this.valor, required this.aoEscolher});

  @override
  Widget build(BuildContext context) {
    Widget botao(String texto, bool resposta) {
      final ativo = valor == resposta;
      return Expanded(
        child: Semantics(
          selected: ativo,
          button: true,
          child: Material(
            color: ativo ? Cores.verdeEscuro : Cores.branco,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: ativo ? Cores.verdeEscuro : Cores.cinza),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => aoEscolher(resposta),
              child: SizedBox(
                height: 52,
                child: Center(
                  child: Text(
                    texto,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ativo ? Cores.branco : Cores.tinta,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        botao('Sim', true),
        const SizedBox(width: 10),
        botao('Não', false),
      ],
    );
  }
}

/// Etiqueta pequena arredondada.
class Etiqueta extends StatelessWidget {
  final String texto;
  final Color fundo;
  final Color cor;

  const Etiqueta(
    this.texto, {
    super.key,
    this.fundo = Cores.verdeClaro,
    this.cor = Cores.verdeTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cor),
      ),
    );
  }
}

/// Cores das seções nas barras e no mapa de saídas.
const coresSecao = [
  Cores.verdeTexto,
  Cores.cinzaEscuro,
  Cores.verdeEscuro,
  Cores.textoSecundario,
  Cores.verde,
];

Color corDaSecao(int indice) => coresSecao[indice % coresSecao.length];
