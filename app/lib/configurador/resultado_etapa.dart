import 'package:configurador/configurador.dart';
import 'package:flutter/material.dart';

import '../tema.dart';
import 'configurador_estado.dart';
import 'configurador_widgets.dart';

class EtapaResultado extends StatelessWidget {
  final ConfiguradorEstado estado;

  const EtapaResultado({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final resultado = estado.resultado;
    final pendentes = resultado.pendentes.length;
    final avisos = resultado.validacoes
        .where((v) => v.nivel == NivelValidacao.aviso)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            Etiqueta('${resultado.itens.length - pendentes} definidos'),
            if (pendentes > 0)
              Etiqueta(
                '$pendentes aguardam o comprimento',
                fundo: TipoAviso.atencao.fundo,
                cor: TipoAviso.atencao.cor,
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (final item in resultado.itens) ...[
          _ItemResultado(item: item, estado: estado),
          const SizedBox(height: 8),
        ],
        for (final v in avisos) ...[
          Aviso(v.mensagem, tipo: TipoAviso.atencao),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ItemResultado extends StatelessWidget {
  final ItemConfiguracao item;
  final ConfiguradorEstado estado;

  const _ItemResultado({required this.item, required this.estado});

  bool get _pendente => item.status == StatusItem.pendente;

  @override
  Widget build(BuildContext context) {
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.componente,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        Text(
          item.motivo,
          style: const TextStyle(fontSize: 14, color: Cores.textoSecundario),
        ),
        if (_pendente && item.pendencia != null)
          Text(
            item.pendencia!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TipoAviso.atencao.cor,
            ),
          ),
        if (item.observacao != null)
          Text(
            item.observacao!,
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Cores.textoSecundario,
            ),
          ),
      ],
    );

    final numero = Text(
      '${item.quantidade}',
      style: const TextStyle(
        fontFamily: fonteTitulo,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    );
    final quantidade = item.quantidadeRecomendada == null
        ? numero
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              numero,
              Text(
                'Recomendado: ${item.quantidadeRecomendada}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Cores.textoSecundario,
                ),
              ),
            ],
          );

    // Chicote painel: quantos de cada comprimento.
    final porComprimento = item.quantidadeRecomendada == null
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final m in item.opcoesComprimento)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 48,
                        child: Text(
                          '$m m',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Contador(
                        valor: item.quantidadesPorComprimento[m] ?? 0,
                        rotulo: 'um chicote painel de $m m',
                        tamanho: 34,
                        aoMenos: (item.quantidadesPorComprimento[m] ?? 0) > 0
                            ? () => estado.ajustarChicotePainel(m, -1)
                            : null,
                        aoMais: () => estado.ajustarChicotePainel(m, 1),
                      ),
                    ],
                  ),
                ),
            ],
          );

    final comprimentos = item.opcoesComprimento.isEmpty
        ? null
        : porComprimento ??
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final m in item.opcoesComprimento)
                    _BotaoComprimento(
                      metros: m,
                      escolhido:
                          estado.comprimentoEscolhido(item.componente) == m,
                      sugerido: item.comprimentoSugerido == m,
                      aoTocar: () =>
                          estado.escolherComprimento(item.componente, m),
                    ),
                ],
              );

    final situacao = _pendente
        ? Etiqueta(
            'Pendente',
            fundo: TipoAviso.atencao.fundo,
            cor: TipoAviso.atencao.cor,
          )
        : const Etiqueta('Definido');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _pendente ? TipoAviso.atencao.cor.withAlpha(90) : Cores.borda,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          if (box.maxWidth >= 640) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: info),
                const SizedBox(width: 12),
                SizedBox(width: 140, child: quantidade),
                SizedBox(width: 200, child: comprimentos ?? const SizedBox()),
                const SizedBox(width: 8),
                SizedBox(width: 84, child: situacao),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: info),
                  const SizedBox(width: 8),
                  situacao,
                ],
              ),
              const SizedBox(height: 8),
              quantidade,
              if (comprimentos != null) ...[
                const SizedBox(height: 8),
                comprimentos,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BotaoComprimento extends StatelessWidget {
  final int metros;
  final bool escolhido;
  final bool sugerido;
  final VoidCallback aoTocar;

  const _BotaoComprimento({
    required this.metros,
    required this.escolhido,
    required this.sugerido,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final Color fundo, cor, borda;
    if (escolhido) {
      (fundo, cor, borda) = (
        Cores.verdeEscuro,
        Cores.branco,
        Cores.verdeEscuro,
      );
    } else if (sugerido) {
      (fundo, cor, borda) = (Cores.verdeClaro, Cores.verdeTexto, Cores.verde);
    } else {
      (fundo, cor, borda) = (Cores.branco, Cores.tinta, Cores.borda);
    }
    return Semantics(
      selected: escolhido,
      button: true,
      label: '$metros m${sugerido ? ', sugerido' : ''}',
      child: ExcludeSemantics(
        child: Material(
          color: fundo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: borda,
              width: sugerido || escolhido ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: aoTocar,
            child: SizedBox(
              width: 56,
              height: 40,
              child: Center(
                child: Text(
                  '$metros m',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
