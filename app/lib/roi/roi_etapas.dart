import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roi/roi.dart';

import '../configurador/configurador_widgets.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'roi_estado.dart';

String _reais(double? v) => v == null ? '–' : reais(v, 0);
String _safras(double? v) =>
    v == null ? '–' : '${numeroBr(v, 2)} ${v == 1 ? 'safra' : 'safras'}';
String _pct(double? v) => v == null ? '–' : percentual(v * 100);

/// Abre o cartão "Como apresentar ao cliente".
void mostrarComoApresentar(BuildContext context, String titulo, String texto) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMO APRESENTAR AO CLIENTE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Cores.verdeTexto,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: const TextStyle(
              fontFamily: fonteTitulo,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Text(texto, style: const TextStyle(fontSize: 17, height: 1.45)),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );
}

/// Botão "?" que abre o cartão de apresentação.
class BotaoApresentar extends StatelessWidget {
  final String titulo;
  final String texto;
  final Color cor;

  const BotaoApresentar({
    super.key,
    required this.titulo,
    required this.texto,
    this.cor = Cores.verdeTexto,
  });

  BotaoApresentar.de(
    (String, String) t, {
    Key? key,
    Color cor = Cores.verdeTexto,
  }) : this(key: key, titulo: t.$1, texto: t.$2, cor: cor);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Como apresentar: $titulo',
      onPressed: () => mostrarComoApresentar(context, titulo, texto),
      icon: Icon(Icons.help_outline, color: cor),
    );
  }
}

class EtapaPremissasRoi extends StatelessWidget {
  final RoiEstado estado;
  final GrupoRoi grupo;

  const EtapaPremissasRoi({
    super.key,
    required this.estado,
    required this.grupo,
  });

  @override
  Widget build(BuildContext context) {
    final bloqueio = estado.bloqueio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CartaoBranco(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
          child: Column(
            children: [
              for (var i = 0; i < grupo.campos.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: Cores.fundo),
                _CampoRoi(
                  key: ValueKey(grupo.campos[i].chave),
                  estado: estado,
                  campo: grupo.campos[i],
                ),
              ],
            ],
          ),
        ),
        if (bloqueio != null && estado.editou) ...[
          const SizedBox(height: 12),
          Aviso(bloqueio, tipo: TipoAviso.erro),
        ],
      ],
    );
  }
}

class _CampoRoi extends StatefulWidget {
  final RoiEstado estado;
  final CampoRoi campo;

  const _CampoRoi({super.key, required this.estado, required this.campo});

  @override
  State<_CampoRoi> createState() => _CampoRoiState();
}

class _CampoRoiState extends State<_CampoRoi> {
  late final _controle = TextEditingController(
    text: widget.estado.texto(widget.campo.chave),
  );

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.campo;
    final digitado = widget.estado.texto(c.chave).isNotEmpty;
    final erro = digitado ? widget.estado.erro(c) : null;
    final rotulo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                c.obrigatorio ? '${c.rotulo} *' : c.rotulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            BotaoApresentar(titulo: c.rotulo, texto: c.apresentar),
          ],
        ),
        Text(
          c.dica,
          style: const TextStyle(fontSize: 14, color: Cores.textoSecundario),
        ),
      ],
    );
    final entrada = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: TextField(
            controller: _controle,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: '0',
              errorText: erro,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (t) => widget.estado.mudar(c.chave, t),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 76,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              c.unidade,
              style: const TextStyle(
                fontSize: 14,
                color: Cores.textoSecundario,
              ),
            ),
          ),
        ),
      ],
    );
    final escolhido = widget.estado.atalhoEscolhido(c);
    final atalhos = c.atalhos.isEmpty
        ? null
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (nome, valor) in c.atalhos)
                ChoiceChip(
                  label: Text('$nome · $valor%'),
                  selected: nome == escolhido,
                  showCheckmark: false,
                  selectedColor: Cores.verdeEscuro,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: nome == escolhido ? Cores.branco : Cores.tinta,
                  ),
                  onSelected: (_) {
                    _controle.text = valor;
                    widget.estado.mudar(c.chave, valor);
                  },
                ),
            ],
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, box) => box.maxWidth >= 560
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: rotulo),
                      const SizedBox(width: 16),
                      entrada,
                    ],
                  ),
                  if (atalhos != null) ...[const SizedBox(height: 10), atalhos],
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  rotulo,
                  const SizedBox(height: 8),
                  entrada,
                  if (atalhos != null) ...[const SizedBox(height: 8), atalhos],
                ],
              ),
      ),
    );
  }
}

class EtapaResultadoRoi extends StatelessWidget {
  final RoiEstado estado;

  const EtapaResultadoRoi({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final r = estado.resultado;
    final atual = r.cenarios[estado.cenario]!;
    final vida = r.premissas.vidaSafras;
    final fontes = [
      ('Plantabilidade', atual.plantabilidade, Cores.verdeEscuro),
      ('Taxa variável', r.fixos.taxaVariavel, Cores.verdeTexto),
      ('Sobreposição', r.fixos.sobreposicao, Cores.verde),
      ('Operação/manutenção', r.fixos.operacao, Cores.cinzaEscuro),
      ('Compensação em curvas', r.fixos.curvas, Cores.cinza),
    ];
    final maior = fontes.map((f) => f.$2).fold(1.0, math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in CenarioRoi.values)
                    ChoiceChip(
                      label: Text(
                        '${c.nome} · ${percentual(c.recuperacao * 100)}',
                      ),
                      selected: c == estado.cenario,
                      onSelected: (_) => estado.escolherCenario(c),
                      selectedColor: Cores.verdeEscuro,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c == estado.cenario ? Cores.branco : Cores.tinta,
                      ),
                      showCheckmark: false,
                    ),
                ],
              ),
            ),
            BotaoApresentar.de(ApresentarRoi.cenarios),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, box) {
            final colunas = box.maxWidth >= 720 ? 4 : 2;
            final largura = (box.maxWidth - 12 * (colunas - 1)) / colunas;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final k in [
                  (
                    ApresentarRoi.beneficio,
                    _reais(atual.beneficioSafra),
                    'Soma das 5 fontes',
                    true,
                  ),
                  (
                    ApresentarRoi.payback,
                    _safras(atual.payback),
                    'Investimento ÷ benefício',
                    false,
                  ),
                  (
                    ApresentarRoi.roi,
                    _pct(atual.roiAnual),
                    'Benefício ÷ investimento',
                    false,
                  ),
                  (
                    (
                      'Em ${numeroBr(vida, 0)} safras',
                      ApresentarRoi.horizonte.$2,
                    ),
                    _reais(atual.beneficioHorizonte),
                    'Retorno líquido: ${_pct(atual.retornoLiquido)}',
                    false,
                  ),
                ])
                  SizedBox(
                    width: largura,
                    child: _Indicador(
                      titulo: k.$1.$1,
                      apresentar: k.$1,
                      valor: k.$2,
                      nota: k.$3,
                      destaque: k.$4,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: RotuloSecao('De onde vem o benefício (por safra)'),
                  ),
                  BotaoApresentar.de(ApresentarRoi.fontes),
                ],
              ),
              for (final f in fontes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 170,
                        child: Text(f.$1, style: const TextStyle(fontSize: 15)),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: f.$2 <= 0 ? 0 : f.$2 / maior,
                            minHeight: 16,
                            color: f.$3,
                            backgroundColor: Cores.neutro,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          _reais(f.$2),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(color: Cores.neutro),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total por safra',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    _reais(atual.beneficioSafra),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RotuloSecao('Comparar cenários'),
              const SizedBox(height: 6),
              for (final c in CenarioRoi.values)
                _LinhaCenario(
                  resultado: r.cenarios[c]!,
                  ativo: c == estado.cenario,
                ),
              const Divider(color: Cores.neutro),
              for (final (rotulo, valor) in [
                ('Receita bruta da área', _reais(r.receitaBruta)),
                ('Investimento por linha', _reais(r.jassy.porLinha)),
                ('Investimento por ha (1º ano)', _reais(r.jassy.porHa)),
                ('Custo por ha/ano', _reais(r.jassy.porHaAno)),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          rotulo,
                          style: const TextStyle(color: Cores.textoSecundario),
                        ),
                      ),
                      Text(
                        valor,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Indicador extends StatelessWidget {
  final String titulo;
  final (String, String) apresentar;
  final String valor;
  final String nota;
  final bool destaque;

  const _Indicador({
    required this.titulo,
    required this.apresentar,
    required this.valor,
    required this.nota,
    required this.destaque,
  });

  @override
  Widget build(BuildContext context) {
    final fundo = destaque ? Cores.verdeEscuro : Cores.verdeClaro;
    final cor = destaque ? Cores.branco : Cores.verdeEscuro;
    final corRotulo = destaque ? Cores.cinza : Cores.verdeTexto;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 12),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: corRotulo,
                  ),
                ),
              ),
              BotaoApresentar(
                titulo: apresentar.$1,
                texto: apresentar.$2,
                cor: corRotulo,
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: TextStyle(
                fontFamily: fonteTitulo,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: cor,
              ),
            ),
          ),
          Text(nota, style: TextStyle(fontSize: 13, color: corRotulo)),
        ],
      ),
    );
  }
}

class _LinhaCenario extends StatelessWidget {
  final ResultadoCenario resultado;
  final bool ativo;

  const _LinhaCenario({required this.resultado, required this.ativo});

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(
      fontSize: 15,
      fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: ativo ? Cores.verdeClaro : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(resultado.cenario.nome, style: estilo)),
          SizedBox(
            width: 120,
            child: Text(
              _reais(resultado.beneficioSafra),
              textAlign: TextAlign.right,
              style: estilo,
            ),
          ),
          SizedBox(
            width: 96,
            child: Text(
              _safras(resultado.payback),
              textAlign: TextAlign.right,
              style: estilo,
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              _pct(resultado.roiAnual),
              textAlign: TextAlign.right,
              style: estilo,
            ),
          ),
        ],
      ),
    );
  }
}

class EtapaComparativoRoi extends StatelessWidget {
  final RoiEstado estado;

  const EtapaComparativoRoi({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final r = estado.resultado;
    final cores = {
      Alternativa.jassy: Cores.verde,
      Alternativa.concorrente: Cores.cinzaEscuro,
      Alternativa.plantadeiraNova: Cores.verdeEscuro,
    };
    final maior = r.alternativas.map((a) => a.investimento).fold(1.0, math.max);
    final provavel = r.cenarios[CenarioRoi.provavel]!;
    final indicadores = [
      ('Diferença J.Assy x concorrente', _reais(r.diferencaConcorrente)),
      ('Diferença por ha no 1º ano', _reais(r.diferencaConcorrentePorHa)),
      ('Diferença por ha/ano', _reais(r.diferencaConcorrentePorHaAno)),
      ('Capital evitado vs plantadeira nova', _reais(r.capitalEvitado)),
      ('Payback no cenário provável', _safras(provavel.payback)),
      ('Benefício provável no horizonte', _reais(provavel.beneficioHorizonte)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: RotuloSecao('Investimento líquido por alternativa'),
                  ),
                  BotaoApresentar.de(ApresentarRoi.alternativas),
                ],
              ),
              for (final a in r.alternativas)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.alternativa.nome,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            _reais(a.investimento),
                            style: const TextStyle(
                              fontFamily: fonteTitulo,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        a.alternativa.observacao,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Cores.textoSecundario,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: a.investimento <= 0
                              ? 0
                              : a.investimento / maior,
                          minHeight: 22,
                          color: cores[a.alternativa],
                          backgroundColor: Cores.neutro,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(child: RotuloSecao('Por linha e por hectare')),
                  BotaoApresentar.de(ApresentarRoi.tabela),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  horizontalMargin: 0,
                  columns: const [
                    DataColumn(label: Text('Alternativa')),
                    DataColumn(label: Text('R\$/linha'), numeric: true),
                    DataColumn(label: Text('R\$/ha'), numeric: true),
                    DataColumn(label: Text('R\$/ha/ano'), numeric: true),
                    DataColumn(
                      label: Text('Diferença vs J.Assy'),
                      numeric: true,
                    ),
                  ],
                  rows: [
                    for (final a in r.alternativas)
                      DataRow(
                        cells: [
                          DataCell(Text(a.alternativa.nome)),
                          DataCell(Text(_reais(a.porLinha))),
                          DataCell(Text(_reais(a.porHa))),
                          DataCell(Text(_reais(a.porHaAno))),
                          DataCell(
                            Text(
                              a.diferencaJassy == 0
                                  ? '–'
                                  : '${a.diferencaJassy > 0 ? '+' : '−'} '
                                        '${_reais(a.diferencaJassy.abs())}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: a.diferencaJassy > 0
                                    ? Cores.verdeTexto
                                    : a.diferencaJassy < 0
                                    ? TipoAviso.atencao.cor
                                    : Cores.textoSecundario,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, box) {
            final colunas = box.maxWidth >= 640 ? 3 : 2;
            final largura = (box.maxWidth - 12 * (colunas - 1)) / colunas;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final (rotulo, valor) in indicadores)
                  SizedBox(
                    width: largura,
                    child: CartaoBranco(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rotulo,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Cores.textoSecundario,
                            ),
                          ),
                          Text(
                            valor,
                            style: const TextStyle(
                              fontFamily: fonteTitulo,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
