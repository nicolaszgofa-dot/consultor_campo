import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'desenho_geometria.dart';
import 'desligamento_dados.dart';

/// Configuração do desligamento de linha: monitor e ativações, geometria da
/// plantadeira e o ajuste fino no campo. Nada fica salvo.
class DesligamentoPage extends StatefulWidget {
  final int abaInicial;

  /// Abre o tutorial em vídeo (nos testes, um falso).
  final Future<bool> Function(Uri)? abrirLink;

  const DesligamentoPage({super.key, this.abaInicial = 0, this.abrirLink});

  @override
  State<DesligamentoPage> createState() => _DesligamentoPageState();
}

class _DesligamentoPageState extends State<DesligamentoPage> {
  /// Monitor escolhido na aba Monitor; a aba No campo usa os campos dele.
  AjusteMonitor? _monitor;

  @override
  Widget build(BuildContext context) {
    final abaInicial = widget.abaInicial;
    return DefaultTabController(
      length: 3,
      initialIndex: abaInicial,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: Cores.verdeEscuro,
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Voltar',
                            color: Cores.branco,
                            icon: const Icon(Icons.chevron_left, size: 30),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Desligamento de linha',
                              style: TextStyle(
                                fontFamily: fonteTitulo,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Cores.branco,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const TabBar(
                      indicatorColor: Cores.verdeVivo,
                      indicatorWeight: 4,
                      labelColor: Cores.branco,
                      unselectedLabelColor: Cores.cinza,
                      dividerColor: Colors.transparent,
                      labelStyle: TextStyle(
                        fontFamily: 'Barlow',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: [
                        Tab(text: 'Monitor'),
                        Tab(text: 'Geometria'),
                        Tab(text: 'No campo'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AbaMonitor(
                    monitor: _monitor,
                    aoEscolher: (m) => setState(() => _monitor = m),
                    abrirLink: widget.abrirLink,
                  ),
                  const _AbaGeometria(),
                  _AbaAjuste(monitor: _monitor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conteúdo rolável centralizado, igual nas três abas.
class _Rolagem extends StatelessWidget {
  final List<Widget> filhos;

  const _Rolagem(this.filhos);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            for (var i = 0; i < filhos.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              filhos[i],
            ],
          ],
        ),
      ),
    );
  }
}

const _corpo = TextStyle(fontSize: 15.5, height: 1.4, color: Cores.tinta);
const _pequeno = TextStyle(fontSize: 13, color: Cores.textoSecundario);

Widget _itens(List<String> itens, {bool numerados = false}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    for (var i = 0; i < itens.length; i++)
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: numerados
                  ? Text('${i + 1}.', style: _corpo)
                  : const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(Icons.circle, size: 6, color: Cores.verde),
                    ),
            ),
            Expanded(child: Text(itens[i], style: _corpo)),
          ],
        ),
      ),
  ],
);

// ---------------------------------------------------------------------------
// Aba 1: monitor.
// ---------------------------------------------------------------------------

class _AbaMonitor extends StatelessWidget {
  final AjusteMonitor? monitor;
  final ValueChanged<AjusteMonitor> aoEscolher;
  final Future<bool> Function(Uri)? abrirLink;

  const _AbaMonitor({
    required this.monitor,
    required this.aoEscolher,
    this.abrirLink,
  });

  @override
  Widget build(BuildContext context) {
    final m = monitor;
    return _Rolagem([
      const Text(
        'Escolha o monitor do trator para ver as licenças, onde fica o corte '
        'de seção e o campo do ajuste fino de liga e desliga.',
        style: _corpo,
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final a in ajustesMonitores)
            ChoiceChip(
              label: Text(a.nome),
              selected: a == m,
              onSelected: (_) => aoEscolher(a),
            ),
        ],
      ),
      if (m != null) _detalhe(context, m),
      const RotuloSecao('Antes de ir para o campo'),
      CartaoBranco(child: _itens(checklistDesligamento)),
      const Text(
        'Valor de partida: a John Deere cita, para plantadeiras, 0,5 a 1,0 s '
        'para ligar e 0,3 s para desligar. Não é um valor medido no Elétric: '
        'confirme no campo, na aba No campo.',
        style: _pequeno,
      ),
    ]);
  }

  Widget _detalhe(BuildContext context, AjusteMonitor a) {
    final c = a.compatibilidade;
    final campo = a.campo;
    return CartaoBranco(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            a.nome,
            style: const TextStyle(
              fontFamily: fonteTitulo,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          _Selo(conferencia: a.conferencia),
          const SizedBox(height: 10),
          const RotuloSecao('Licenças'),
          Text(a.ativacoes, style: _corpo),
          const SizedBox(height: 4),
          Text(
            'Controle de seção: ${c.controleSecao} · Task Controller: '
            '${c.taskController} · máximo de seções: ${c.maximoSecoes}',
            style: _pequeno,
          ),
          const SizedBox(height: 12),
          const RotuloSecao('Passo a passo'),
          const SizedBox(height: 4),
          _itens(a.passos, numerados: a.passos.length > 1),
          if (campo != null) ...[
            const SizedBox(height: 6),
            const RotuloSecao('Ajuste fino'),
            const SizedBox(height: 4),
            Text(
              'Ligar: ${campo.ligar}\nDesligar: ${campo.desligar}\n'
              'Em ${campo.emMetros ? 'metros' : 'segundos'}',
              style: _corpo.copyWith(fontWeight: FontWeight.w600),
            ),
            if (campo.observacao != null)
              Text(campo.observacao!, style: _pequeno),
          ],
          if (a.video case final v?) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  (abrirLink ??
                  (u) => launchUrl(u, mode: LaunchMode.externalApplication))(
                    Uri.parse(v),
                  ),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Ver o tutorial em vídeo'),
            ),
          ],
          const SizedBox(height: 8),
          Text('Fonte: ${a.fonte}', style: _pequeno),
        ],
      ),
    );
  }
}

class _Selo extends StatelessWidget {
  final Conferencia conferencia;

  const _Selo({required this.conferencia});

  @override
  Widget build(BuildContext context) {
    final ok = conferencia.conferido;
    final cor = ok ? Cores.verdeTexto : Cores.atencao;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ok ? Cores.verdeClaro : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.verified_outlined : Icons.help_outline,
            size: 16,
            color: cor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              conferencia.selo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Aba 2: geometria.
// ---------------------------------------------------------------------------

class _AbaGeometria extends StatefulWidget {
  const _AbaGeometria();

  @override
  State<_AbaGeometria> createState() => _AbaGeometriaState();
}

class _AbaGeometriaState extends State<_AbaGeometria>
    with AutomaticKeepAliveClientMixin {
  var _g = const GeometriaPlantadeira();
  final _linhas = TextEditingController();
  final _espacamento = TextEditingController();
  final _engate = TextEditingController();
  final _curta = TextEditingController();
  final _longa = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    for (final c in [_linhas, _espacamento, _engate, _curta, _longa]) {
      c.dispose();
    }
    super.dispose();
  }

  void _ler() {
    final n = int.tryParse(_linhas.text.trim()) ?? 0;
    setState(() {
      _g = _g.copiar(
        linhas: n,
        espacamentoM: lerNumero(_espacamento.text) ?? 0,
        engateRodaM: lerNumero(_engate.text) ?? 0,
        rodaSaidaCurtaM: lerNumero(_curta.text) ?? 0,
        rodaSaidaLongaM: lerNumero(_longa.text) ?? 0,
        longas: {
          for (final i in _g.longas)
            if (i < n) i,
        },
      );
    });
  }

  Widget _campo(
    TextEditingController c,
    String rotulo, {
    String? ajuda,
    bool inteiro = false,
  }) => TextField(
    controller: c,
    keyboardType: TextInputType.numberWithOptions(decimal: !inteiro),
    decoration: InputDecoration(
      labelText: rotulo,
      helperText: ajuda,
      helperMaxLines: 2,
    ),
    onChanged: (_) => _ler(),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final g = _g;
    return _Rolagem([
      const Text(
        'Medidas da plantadeira para o terminal J.Assy (Configurações > '
        'Implemento). Com elas, o monitor sabe onde cada linha solta a '
        'semente e liga e desliga no ponto certo.',
        style: _corpo,
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final t in TipoLinhas.values)
            ChoiceChip(
              label: Text(t.titulo),
              selected: t == g.tipo,
              onSelected: (_) => setState(() => _g = _g.copiar(tipo: t)),
            ),
        ],
      ),
      Text(g.tipo.descricao, style: _pequeno),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _campo(_linhas, 'Nº de linhas', inteiro: true)),
          const SizedBox(width: 10),
          Expanded(
            child: _campo(_espacamento, 'Entre linhas (m)', ajuda: 'ex.: 0,50'),
          ),
        ],
      ),
      _campo(
        _engate,
        'Engate até as rodas (m)',
        ajuda: 'Do ponto de engate até o eixo das rodas do implemento',
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _campo(
              _curta,
              g.temLongas ? 'Saída curta (m)' : 'Rodas até saída (m)',
              ajuda: g.temLongas ? 'Das rodas até a saída' : null,
            ),
          ),
          if (g.temLongas) ...[
            const SizedBox(width: 10),
            Expanded(
              child: _campo(
                _longa,
                'Saída longa (m)',
                ajuda: 'Das rodas até a saída',
              ),
            ),
          ],
        ],
      ),
      if (g.tipo == TipoLinhas.desencontradas)
        Row(
          children: [
            const Text('Linha 1 é', style: _corpo),
            const SizedBox(width: 12),
            Expanded(
              child: Seletor<bool>(
                opcoes: const [false, true],
                selecionada: g.primeiraLonga,
                rotulo: (l) => l ? 'Longa' : 'Curta',
                aoEscolher: (l) =>
                    setState(() => _g = _g.copiar(primeiraLonga: l)),
              ),
            ),
          ],
        ),
      if (g.tipo == TipoLinhas.personalizadas)
        const Text(
          'Toque nas linhas do desenho para marcar quais são longas.',
          style: _pequeno,
        ),
      CartaoBranco(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: DesenhoGeometria(
          g: g,
          aoTocarLinha: g.tipo == TipoLinhas.personalizadas
              ? (i) => setState(() {
                  final l = {..._g.longas};
                  l.contains(i) ? l.remove(i) : l.add(i);
                  _g = _g.copiar(longas: l);
                })
              : null,
        ),
      ),
      for (final a in g.avisos)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 8),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: Cores.atencao,
              ),
            ),
            Expanded(
              child: Text(a, style: _corpo.copyWith(color: Cores.atencao)),
            ),
          ],
        ),
      if (g.completa)
        _ResultadoGeometria(g: g)
      else
        Text('Falta: ${g.faltando.join(', ')}.', style: _pequeno),
      const RotuloSecao('Como medir'),
      _itens(const [
        'Plantadeira no chão, aberta e alinhada com o trator.',
        'Engate: do ponto de engate (pino da barra de tração) até o centro do '
            'eixo das rodas do implemento.',
        'Saída: do eixo das rodas até onde a semente cai no sulco, numa linha '
            'curta e numa longa.',
        'Meça na máquina, não no catálogo.',
      ]),
    ]);
  }
}

class _ResultadoGeometria extends StatelessWidget {
  final GeometriaPlantadeira g;

  const _ResultadoGeometria({required this.g});

  @override
  Widget build(BuildContext context) {
    String m(double v) => '${numeroBr(v, 2)} m';
    final linhas = <(String, String)>[
      ('Tipo', g.tipo.titulo),
      ('Linhas', '${g.linhas}'),
      ('Entre linhas', m(g.espacamentoM)),
      ('Engate - rodas', m(g.engateRodaM)),
      if (g.temLongas) ...[
        ('Rodas - saída curta', m(g.rodaSaidaCurtaM)),
        ('Rodas - saída longa', m(g.rodaSaidaLongaM)),
      ] else
        ('Rodas - saída', m(g.rodaSaidaCurtaM)),
      if (g.tipo == TipoLinhas.desencontradas)
        ('Primeira linha', g.primeiraLonga ? 'Longa' : 'Curta'),
      if (g.temLongas)
        ('Curtas / longas', '${g.quantidadeCurtas} / ${g.quantidadeLongas}'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Cores.verdeClaro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Para digitar no terminal',
            style: TextStyle(
              fontFamily: fonteTitulo,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Cores.verdeEscuro,
            ),
          ),
          const Text('Configurações > Implemento', style: _pequeno),
          const SizedBox(height: 8),
          for (final (r, v) in linhas)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(child: Text(r, style: _corpo)),
                  Text(
                    v,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            'Largura de trabalho: ${numeroBr(g.larguraM, 2)} m',
            style: _pequeno,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Aba 3: ajuste no campo.
// ---------------------------------------------------------------------------

class _AbaAjuste extends StatefulWidget {
  /// Monitor escolhido na aba Monitor (nulo: resposta genérica).
  final AjusteMonitor? monitor;

  const _AbaAjuste({required this.monitor});

  @override
  State<_AbaAjuste> createState() => _AbaAjusteState();
}

class _AbaAjusteState extends State<_AbaAjuste>
    with AutomaticKeepAliveClientMixin {
  Ocorrencia? _ocorrencia;
  final _distancia = TextEditingController();
  final _velocidade = TextEditingController();
  final _atual = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    for (final c in [_distancia, _velocidade, _atual]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final monitor = widget.monitor;
    final emMetros = monitor?.campo?.emMetros ?? false;
    final correcao = CorrecaoTempo.calcular(
      ocorrencia: _ocorrencia,
      distanciaM: lerNumero(_distancia.text),
      velocidadeKmh: lerNumero(_velocidade.text),
    );
    return _Rolagem([
      const Text(
        'Passe na cabeceira em velocidade constante, cruzando uma área já '
        'plantada, e confira no chão onde a linha parou e voltou a plantar.',
        style: _corpo,
      ),
      Text(
        monitor == null
            ? 'Escolha o monitor na aba Monitor para ver o campo exato a '
                  'mexer.'
            : 'Monitor: ${monitor.nome}'
                  '${monitor.campo == null ? '' : ' (ajuste em ${emMetros ? 'metros' : 'segundos'})'}',
        style: _pequeno.copyWith(fontWeight: FontWeight.w600),
      ),
      const RotuloSecao('O que aconteceu?'),
      LayoutBuilder(
        builder: (context, box) {
          final largura = box.maxWidth >= 480
              ? (box.maxWidth - 10) / 2
              : box.maxWidth;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final o in Ocorrencia.values)
                SizedBox(
                  width: largura,
                  child: _CartaoOcorrencia(
                    o: o,
                    selecionada: o == _ocorrencia,
                    aoTocar: () => setState(() => _ocorrencia = o),
                  ),
                ),
            ],
          );
        },
      ),
      TextField(
        controller: _distancia,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Medido no chão (m)',
          helperText: 'Tamanho da falha ou da sobra',
        ),
        onChanged: (_) => setState(() {}),
      ),
      TextField(
        controller: _velocidade,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Velocidade (km/h)',
          helperText: 'Da passada medida',
        ),
        onChanged: (_) => setState(() {}),
      ),
      TextField(
        controller: _atual,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Valor atual no monitor, opcional',
          helperText: monitor?.campo == null
              ? 'Em segundos, para calcular o novo valor'
              : 'Em ${emMetros ? 'metros' : 'segundos'}, para calcular o '
                    'novo valor',
        ),
        onChanged: (_) => setState(() {}),
      ),
      if (correcao == null)
        const Text(
          'Escolha o que aconteceu e informe a distância e a velocidade.',
          style: _pequeno,
        )
      else
        _ResultadoAjuste(
          c: correcao,
          monitor: monitor,
          atual: lerNumero(_atual.text),
        ),
      const RotuloSecao('Como medir'),
      _itens(const [
        'Mantenha a velocidade de plantio constante ao entrar e sair da área '
            'plantada.',
        'Marque a borda da área já plantada.',
        'Meça da borda até a última semente (ao desligar) ou até a primeira '
            'semente (ao ligar).',
        'Ajuste um valor de cada vez e passe de novo para conferir.',
      ]),
      const Text(
        'Conta: tempo = distância ÷ velocidade (km/h ÷ 3,6). Nos ajustes de '
        'tempo (atraso, latência, olhar adiante), valor maior manda o comando '
        'mais cedo.',
        style: _pequeno,
      ),
    ]);
  }
}

class _CartaoOcorrencia extends StatelessWidget {
  final Ocorrencia o;
  final bool selecionada;
  final VoidCallback aoTocar;

  const _CartaoOcorrencia({
    required this.o,
    required this.selecionada,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = o.deixaFalha ? Cores.falha : Cores.dupla;
    return Semantics(
      button: true,
      selected: selecionada,
      label: o.titulo,
      excludeSemantics: true,
      child: Material(
        color: selecionada ? Cores.verdeClaro : Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selecionada ? Cores.verde : Cores.borda,
            width: selecionada ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(o.descricao, style: _pequeno),
                const SizedBox(height: 4),
                Text(
                  'No chão: ${o.resultadoNoChao}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultadoAjuste extends StatelessWidget {
  final CorrecaoTempo c;
  final AjusteMonitor? monitor;
  final double? atual;

  const _ResultadoAjuste({
    required this.c,
    required this.monitor,
    required this.atual,
  });

  static const _claro = Color(0xFFCFE8C9);

  @override
  Widget build(BuildContext context) {
    final instrucao = c.instrucaoPara(monitor?.campo);
    final quando = c.aumentar ? 'mais cedo' : 'mais tarde';
    final comando = c.ocorrencia.desligar ? 'Desligar' : 'Ligar';

    final String acao;
    final double? novo;
    final String unidade;
    if (instrucao != null) {
      final v = numeroBr(instrucao.valor, 2);
      acao =
          '${instrucao.aumentar ? 'Aumente' : 'Diminua'} '
          '"${instrucao.campo}" em $v ${instrucao.unidade}';
      novo = instrucao.novoValor(atual);
      unidade = instrucao.unidade;
    } else {
      acao =
          'Nos ajustes de tempo (atraso, latência, olhar adiante): '
          '${c.aumentar ? 'aumente' : 'diminua'} '
          '${numeroBr(c.segundos, 2)} s. Nos de distância: '
          '${numeroBr(c.distanciaM, 2)} m.';
      novo = c.novoValor(atual);
      unidade = 's';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Cores.verdeEscuro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$comando $quando',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _claro,
            ),
          ),
          Text(
            '${numeroBr(c.segundos, 2)} s',
            style: const TextStyle(
              fontFamily: fonteTitulo,
              fontSize: 44,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: Cores.branco,
            ),
          ),
          Text(
            '${numeroBr(c.distanciaM, 2)} m a '
            '${numeroBr(c.velocidadeKmh, 1)} km/h '
            '(${numeroBr(c.velocidadeMs, 2)} m/s)',
            style: const TextStyle(fontSize: 13.5, color: _claro),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Cores.branco,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (monitor != null && instrucao != null)
                  Text('No ${monitor!.nome}:', style: _pequeno),
                Text(
                  acao,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Cores.tinta,
                  ),
                ),
                if (novo != null)
                  Text(
                    'De ${numeroBr(atual!, 2)} $unidade para '
                    '${numeroBr(novo, 2)} $unidade',
                    style: _corpo,
                  ),
                if (monitor?.campo?.observacao case final o?)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(o, style: _pequeno),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A linha ${c.ocorrencia.desligar ? 'desligou' : 'ligou'} '
            '${c.ocorrencia.adiantado ? 'cedo' : 'tarde'} e deixou '
            '${c.ocorrencia.resultadoNoChao}.',
            style: const TextStyle(fontSize: 13.5, color: _claro),
          ),
        ],
      ),
    );
  }
}
