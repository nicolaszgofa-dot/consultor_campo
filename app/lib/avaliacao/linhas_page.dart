import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'avaliacao_estado.dart';
import 'resultado_page.dart';

class LinhasPage extends StatefulWidget {
  final AvaliacaoEstado estado;

  const LinhasPage({super.key, required this.estado});

  @override
  State<LinhasPage> createState() => _LinhasPageState();
}

class _LinhasPageState extends State<LinhasPage> {
  final _leitura = TextEditingController();
  final _foco = FocusNode();
  String? _erro;

  @override
  void dispose() {
    _leitura.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _adicionar() {
    final valor = lerNumero(_leitura.text);
    final erro = valor == null
        ? 'Digite a leitura da trena em cm.'
        : widget.estado.adicionarLeitura(valor);
    setState(() => _erro = erro);
    if (erro == null) _leitura.clear();
    _foco.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.estado,
      builder: (context, _) {
        final estado = widget.estado;
        final r = estado.resultado;
        final atual = r.linhas[estado.linhaAtual];
        final faltam = RegrasAvaliacao.linhasRecomendadas - r.linhasCompletas;

        return TelaFluxo(
          titulo: 'Leituras da trena',
          passo: 2,
          filhos: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                Text(
                  '${r.linhasCompletas} de ${RegrasAvaliacao.linhasRecomendadas} '
                  'linhas completas',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'recomendado: 5 linhas × 10 m',
                  style: TextStyle(fontSize: 13, color: Cores.textoSecundario),
                ),
              ],
            ),
            _AbasLinhas(estado: estado, resultado: r),
            _PainelLinha(
              indice: estado.linhaAtual,
              linha: atual,
              leitura: _leitura,
              foco: _foco,
              erro: _erro,
              aoAdicionar: _adicionar,
              aoDesfazer: estado.removerUltima,
            ),
          ],
          rodape: r.temResultado
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (r.amostraPequena) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: Cores.atencao,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Amostra pequena: ${faltam == 1 ? 'falta 1 linha' : 'faltam $faltam linhas'} '
                              'para o recomendado.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Cores.atencao,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ResultadoPage(estado: estado),
                        ),
                      ),
                      child: Text(
                        r.linhasCompletas == 1
                            ? 'Ver resultado da 1 linha'
                            : 'Ver resultado das ${r.linhasCompletas} linhas',
                      ),
                    ),
                  ],
                )
              : Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Cores.neutro,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Complete 1 linha de 10 m para ver o resultado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Cores.textoSecundario,
                        ),
                      ),
                      Text(
                        'Recomendado: ${RegrasAvaliacao.linhasRecomendadas} '
                        'linhas',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Cores.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _AbasLinhas extends StatelessWidget {
  final AvaliacaoEstado estado;
  final ResultadoAvaliacao resultado;

  const _AbasLinhas({required this.estado, required this.resultado});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < resultado.linhas.length; i++)
          _Aba(
            nome: 'L${i + 1}',
            // A fonte do app não tem o ✓; a aba verde já marca a completa.
            detalhe: resultado.linhas[i].completa
                ? '10 m'
                : '${numeroBr(resultado.linhas[i].comprimentoCm / 100)} m',
            ativa: i == estado.linhaAtual,
            completa: resultado.linhas[i].completa,
            aoTocar: () => estado.selecionar(i),
          ),
        SizedBox(
          width: 58,
          height: 54,
          child: OutlinedButton(
            onPressed: estado.adicionarLinha,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: const BorderSide(color: Cores.cinza),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(
              Icons.add,
              color: Cores.textoSecundario,
              semanticLabel: 'Adicionar linha extra',
            ),
          ),
        ),
      ],
    );
  }
}

class _Aba extends StatelessWidget {
  final String nome;
  final String detalhe;
  final bool ativa;
  final bool completa;
  final VoidCallback aoTocar;

  const _Aba({
    required this.nome,
    required this.detalhe,
    required this.ativa,
    required this.completa,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final fundo = ativa
        ? Cores.verdeEscuro
        : completa
        ? Cores.verdeClaro
        : Cores.branco;
    final texto = ativa
        ? Cores.branco
        : completa
        ? Cores.verdeTexto
        : Cores.tinta;
    return Semantics(
      selected: ativa,
      button: true,
      label: 'Linha ${nome.substring(1)}, $detalhe',
      child: Material(
        color: fundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: ativa
                ? Cores.verdeEscuro
                : completa
                ? const Color(0xFF9FD9A6)
                : Cores.cinza,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: aoTocar,
          child: SizedBox(
            width: 58,
            height: 54,
            child: ExcludeSemantics(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nome,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: texto,
                    ),
                  ),
                  Text(
                    detalhe,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: texto,
                    ),
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

class _PainelLinha extends StatelessWidget {
  final int indice;
  final LinhaAvaliada linha;
  final TextEditingController leitura;
  final FocusNode foco;
  final String? erro;
  final VoidCallback aoAdicionar;
  final VoidCallback aoDesfazer;

  const _PainelLinha({
    required this.indice,
    required this.linha,
    required this.leitura,
    required this.foco,
    required this.erro,
    required this.aoAdicionar,
    required this.aoDesfazer,
  });

  @override
  Widget build(BuildContext context) {
    final metros = linha.comprimentoCm / 100;
    final cor = linha.completa ? Cores.verdeTexto : Cores.atencao;
    final espacamentos = linha.resultado.espacamentos;
    final recentes = espacamentos.length > 12
        ? espacamentos.sublist(espacamentos.length - 12)
        : espacamentos;

    return CartaoBranco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Linha ${indice + 1} · '
                '${linha.completa ? 'completa' : 'em andamento'}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${numeroBr(metros)} de 10 m',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (metros / 10).clamp(0, 1).toDouble(),
              minHeight: 8,
              color: linha.completa ? Cores.verde : Cores.atencao,
              backgroundColor: Cores.neutro,
              semanticsLabel: '${numeroBr(metros)} de 10 metros',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: leitura,
                  focusNode: foco,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => aoAdicionar(),
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Leitura da trena (cm)',
                    errorText: erro,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: aoAdicionar,
                style: FilledButton.styleFrom(minimumSize: const Size(96, 56)),
                child: const Text('Adicionar'),
              ),
            ],
          ),
          if (recentes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final e in recentes) _Espacamento(e)],
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 12,
              children: [
                _Legenda(cor: Cores.verde, texto: 'aceitável'),
                _Legenda(cor: Cores.falha, texto: 'falha'),
                _Legenda(cor: Cores.dupla, texto: 'dupla'),
              ],
            ),
          ],
          const Divider(height: 24, color: Cores.neutro),
          Row(
            children: [
              Expanded(
                child: Indicador(rotulo: 'Plantas', valor: '${linha.plantas}'),
              ),
              Expanded(
                child: Indicador(
                  rotulo: 'Falhas',
                  valor: '${linha.contagem.plantasFaltando}',
                  corRotulo: Cores.falha,
                ),
              ),
              Expanded(
                child: Indicador(
                  rotulo: 'Duplas',
                  valor: '${linha.contagem.plantasAMais}',
                  corRotulo: Cores.dupla,
                ),
              ),
              Expanded(
                child: Indicador(
                  rotulo: 'CV',
                  valor: linha.plantas < 2
                      ? '–'
                      : percentual(linha.resultado.cvPercentual, 0),
                ),
              ),
            ],
          ),
          if (linha.plantas > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: aoDesfazer,
                icon: const Icon(Icons.undo, size: 18),
                label: const Text('Remover última leitura'),
                style: TextButton.styleFrom(foregroundColor: Cores.verdeTexto),
              ),
            ),
        ],
      ),
    );
  }
}

class _Espacamento extends StatelessWidget {
  final Espacamento e;

  const _Espacamento(this.e);

  @override
  Widget build(BuildContext context) {
    final (fundo, texto, nome) = switch (e.classe) {
      ClasseEspacamento.aceitavel => (
        Cores.verdeClaro,
        Cores.verdeTexto,
        'aceitável',
      ),
      ClasseEspacamento.falha => (Cores.falha, Cores.branco, 'falha'),
      ClasseEspacamento.dupla => (Cores.dupla, Cores.branco, 'dupla'),
    };
    return Semantics(
      label: '${numeroBr(e.valorCm)} centímetros, $nome',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minWidth: 46),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: fundo,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            numeroBr(e.valorCm),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: texto,
            ),
          ),
        ),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  final Color cor;
  final String texto;

  const _Legenda({required this.cor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(fontSize: 13, color: Cores.textoSecundario),
        ),
      ],
    );
  }
}
