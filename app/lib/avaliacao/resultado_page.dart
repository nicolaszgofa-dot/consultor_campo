import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'avaliacao_estado.dart';
import 'prejuizo_page.dart';

String nomeCenario(Cenario c) => switch (c) {
  Cenario.otimista => 'Otimista',
  Cenario.medio => 'Médio',
  Cenario.pessimista => 'Pessimista',
};

/// Perda estimada de uma avaliação, pela regra da cultura.
ResultadoPerda calcularPerda(AvaliacaoEstado estado) {
  final r = estado.resultado;
  return PerdaCalc.calcularDeContagem(
    cultura: estado.identificacao.cultura,
    contagem: r.total,
    desvioPadraoCm: r.desvioPadraoCm,
    cvPercentual: r.cvPercentual,
    produtividadeEsperadaKgHa: estado.identificacao.produtividadeKgHa,
  );
}

class ResultadoPage extends StatefulWidget {
  final AvaliacaoEstado estado;

  const ResultadoPage({super.key, required this.estado});

  @override
  State<ResultadoPage> createState() => _ResultadoPageState();
}

class _ResultadoPageState extends State<ResultadoPage> {
  var _cenario = Cenario.medio;

  @override
  Widget build(BuildContext context) {
    final id = widget.estado.identificacao;
    final r = widget.estado.resultado;
    final perda = calcularPerda(widget.estado);
    final pctFalhas = r.total.percentualFaltando;
    final pctDuplas = r.total.percentualAMais;
    final noLugar = r.percentualNoLugarCerto;
    final pior = r.linhaComMaisFalhas();
    // Linhas vazias (abas criadas e não medidas) não entram na conta.
    final medidas = r.linhas.where((l) => l.plantas > 0).length;
    final comprimentoM = r.linhas.fold<double>(
      0,
      (s, l) => s + l.comprimentoCm / 100,
    );

    return TelaFluxo(
      titulo: id.talhao.isEmpty ? 'Resultado' : 'Resultado · ${id.talhao}',
      passo: 3,
      filhos: [
        if (r.amostraPequena) AvisoAmostra(linhasCompletas: r.linhasCompletas),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          percentual(noLugar),
                          style: TextStyle(
                            fontFamily: fonteTitulo,
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            color: corDoPercentual(noLugar),
                          ),
                        ),
                        const Text(
                          'das plantas no lugar certo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Cores.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${medidas == 1 ? '1 linha' : '$medidas linhas'} · '
                    '${numeroBr(comprimentoM, 0)} m\n'
                    '${numeroBr(r.total.plantasEsperadas, 0)} plantas esperadas',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Cores.textoSecundario,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Semantics(
                label:
                    'No lugar certo ${percentual(noLugar)}, falhas '
                    '${percentual(pctFalhas)}, duplas ${percentual(pctDuplas)}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SizedBox(
                    height: 14,
                    child: Row(
                      children: [
                        _Faixa(noLugar, Cores.verde),
                        _Faixa(pctFalhas, Cores.falha),
                        _Faixa(pctDuplas, Cores.dupla),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Indicador(
                      rotulo: 'Falhas',
                      valor:
                          '${r.total.plantasFaltando} · '
                          '${percentual(pctFalhas)}',
                      corRotulo: Cores.falha,
                    ),
                  ),
                  Expanded(
                    child: Indicador(
                      rotulo: 'Duplas',
                      valor:
                          '${r.total.plantasAMais} · ${percentual(pctDuplas)}',
                      corRotulo: Cores.dupla,
                    ),
                  ),
                  Expanded(
                    child: Indicador(
                      rotulo: 'CV · DV',
                      valor:
                          '${percentual(r.cvPercentual, 0)} · '
                          '${numeroBr(r.desvioPadraoCm)} cm',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RotuloSecao('Por linha'),
              const SizedBox(height: 8),
              for (var i = 0; i < r.linhas.length; i++)
                if (r.linhas[i].plantas > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: _BarraLinha(nome: 'L${i + 1}', linha: r.linhas[i]),
                  ),
              if (pior != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF0E7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Linha ${pior.indice + 1} tem '
                    '${numeroBr(pior.acimaDaMedia, 0)}% mais falhas que a '
                    'média das linhas: conferir disco e dosador dessa linha.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RotuloSecao('Perda estimada · ${nomeCultura(id.cultura)}'),
            Text(
              '${numeroBr(id.produtividadeScHa, 0)} sc/ha esperadas',
              style: const TextStyle(
                fontSize: 12,
                color: Cores.textoSecundario,
              ),
            ),
          ],
        ),
        Row(
          children: [
            for (final c in Cenario.values) ...[
              if (c != Cenario.otimista) const SizedBox(width: 8),
              Expanded(
                child: _CartaoCenario(
                  nome: nomeCenario(c),
                  sacas: perda.de(c).sacasHa,
                  percentual: perda.de(c).percentual,
                  ativo: c == _cenario,
                  aoTocar: () => setState(() => _cenario = c),
                ),
              ),
            ],
          ],
        ),
        Text(
          _fonte(id.cultura),
          style: const TextStyle(fontSize: 12, color: Cores.textoSecundario),
        ),
      ],
      rodape: FilledButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                PrejuizoPage(estado: widget.estado, cenarioInicial: _cenario),
          ),
        ),
        child: const Text('Calcular prejuízo em R\$'),
      ),
    );
  }

  String _fonte(Cultura c) => switch (c) {
    Cultura.soja =>
      'Calculado pelas falhas e duplas da trena (Fiss et al., 2018).',
    Cultura.milho =>
      'Calculado pelo desvio padrão dos espaçamentos acima de 5 cm '
          '(Nielsen, Purdue).',
    Cultura.feijao =>
      'Calculado pelo CV dos espaçamentos (Bisognin et al., 2019).',
  };
}

/// Menos linhas que o recomendado: o resultado sai, mas com cautela.
class AvisoAmostra extends StatelessWidget {
  final int linhasCompletas;

  const AvisoAmostra({super.key, required this.linhasCompletas});

  @override
  Widget build(BuildContext context) {
    final linhas = linhasCompletas == 1 ? '1 linha' : '$linhasCompletas linhas';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF2D49B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Cores.atencao),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Amostra pequena: ',
                style: const TextStyle(fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text:
                        '$linhas de 10 m, de ${RegrasAvaliacao.linhasRecomendadas} '
                        'recomendadas. O resultado é pouco confiável; complete '
                        'mais linhas antes de levar ao cliente.',
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF7A4800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Faixa extends StatelessWidget {
  final double percentual;
  final Color cor;

  const _Faixa(this.percentual, this.cor);

  @override
  Widget build(BuildContext context) {
    final flex = (percentual * 10).round();
    if (flex <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: ColoredBox(color: cor),
    );
  }
}

class _BarraLinha extends StatelessWidget {
  final String nome;
  final LinhaAvaliada linha;

  const _BarraLinha({required this.nome, required this.linha});

  @override
  Widget build(BuildContext context) {
    final p = linha.percentualNoLugarCerto;
    final cor = corDoPercentual(p);
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            nome,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: (p / 100).clamp(0, 1).toDouble(),
              minHeight: 10,
              color: cor,
              backgroundColor: Cores.neutro,
            ),
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(
            percentual(p),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            linha.plantas < 2
                ? 'CV –'
                : 'CV ${percentual(linha.resultado.cvPercentual, 0)}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, color: Cores.textoSecundario),
          ),
        ),
      ],
    );
  }
}

class _CartaoCenario extends StatelessWidget {
  final String nome;
  final double sacas;
  final double percentual;
  final bool ativo;
  final VoidCallback aoTocar;

  const _CartaoCenario({
    required this.nome,
    required this.sacas,
    required this.percentual,
    required this.ativo,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = ativo ? const Color(0xFF8A1C12) : Cores.tinta;
    return Semantics(
      selected: ativo,
      button: true,
      child: Material(
        color: ativo ? const Color(0xFFFDECEA) : Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: ativo ? Cores.prejuizo : Cores.borda,
            width: ativo ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cor,
                  ),
                ),
                Text(
                  numeroBr(sacas),
                  style: TextStyle(
                    fontFamily: fonteTitulo,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: cor,
                  ),
                ),
                Text(
                  'sc/ha · ${numeroBr(percentual)}%',
                  style: TextStyle(fontSize: 12, color: cor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
