import 'package:flutter/material.dart';

import '../conceito/conceito_page.dart';
import '../simulador/referencias_terminal.dart';
import '../simulador/simulador_page.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import 'treinamento_dados.dart';

/// Material técnico (equipe e revenda): módulos da Linha Elétric com
/// treinamento, instalação e regulagem, cada um com aulas
/// curtas e um teste no fim. Nada fica salvo (sem servidor, sem histórico).
class TreinamentoPage extends StatelessWidget {
  final List<ModuloTreino> modulos;

  TreinamentoPage({super.key, List<ModuloTreino>? modulos})
    : modulos = modulos ?? modulosTreino;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoFluxo(titulo: 'Material técnico'),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    const Text(
                      'Linha Elétric: produto, instalação, regulagem, configuração '
                      'e alarmes. Cada módulo tem aulas curtas e um teste de 4 '
                      'perguntas no fim.',
                      style: TextStyle(fontSize: 16, color: Cores.tinta),
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < modulos.length; i++) ...[
                      _CartaoModulo(
                        numero: i + 1,
                        modulo: modulos[i],
                        aoAbrir: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ModuloPage(modulo: modulos[i]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const Text(
                      'Fonte: treinamento da Linha Elétric e manuais do '
                      'Selenium e do Titanium Elétric. O resultado dos testes não '
                      'fica salvo.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Cores.textoSecundario,
                      ),
                    ),
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

class _CartaoModulo extends StatelessWidget {
  final int numero;
  final ModuloTreino modulo;
  final VoidCallback aoAbrir;

  const _CartaoModulo({
    required this.numero,
    required this.modulo,
    required this.aoAbrir,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: modulo.titulo,
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Cores.verdeClaro,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(modulo.icone, size: 28, color: Cores.verdeTexto),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MÓDULO $numero',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Cores.textoSecundario,
                        ),
                      ),
                      Text(
                        modulo.titulo,
                        style: const TextStyle(
                          fontFamily: fonteTitulo,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        modulo.resumo,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Cores.textoSecundario,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${modulo.aulas.length} aulas · '
                        '${modulo.perguntas.length} perguntas',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Cores.verdeTexto,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Cores.cinzaEscuro),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Um módulo: as aulas em sequência e, no último passo, o teste.
class ModuloPage extends StatefulWidget {
  final ModuloTreino modulo;

  const ModuloPage({super.key, required this.modulo});

  @override
  State<ModuloPage> createState() => _ModuloPageState();
}

class _ModuloPageState extends State<ModuloPage> {
  var _passo = 0;

  /// Opção escolhida em cada pergunta (nula = ainda sem resposta).
  late List<int?> _respostas = _semRespostas();

  final _rolagem = ScrollController();

  List<int?> _semRespostas() =>
      List<int?>.filled(widget.modulo.perguntas.length, null);

  int get _totalPassos => widget.modulo.aulas.length + 1;
  bool get _noTeste => _passo == widget.modulo.aulas.length;

  void _irPara(int passo) {
    setState(() => _passo = passo);
    if (_rolagem.hasClients) _rolagem.jumpTo(0);
  }

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.modulo;
    return Scaffold(
      body: Column(
        children: [
          CabecalhoFluxo(
            titulo: m.titulo,
            passo: _passo + 1,
            totalPassos: _totalPassos,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  controller: _rolagem,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: _noTeste ? _teste() : _aula(m.aulas[_passo]),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      if (_passo > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _irPara(_passo - 1),
                            child: const Text('Anterior'),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        flex: 2,
                        child: _noTeste
                            ? FilledButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Concluir'),
                              )
                            : FilledButton(
                                onPressed: () => _irPara(_passo + 1),
                                child: Text(
                                  _passo == m.aulas.length - 1
                                      ? 'Fazer o teste'
                                      : 'Próxima aula',
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _aula(Aula aula) => [
    RotuloSecao('Aula ${_passo + 1} de ${widget.modulo.aulas.length}'),
    const SizedBox(height: 4),
    Text(
      aula.titulo,
      style: const TextStyle(
        fontFamily: fonteTitulo,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    ),
    const SizedBox(height: 12),
    for (final b in aula.blocos) ...[
      BlocoConceito(bloco: b),
      const SizedBox(height: 12),
    ],
    if (aula.atalho case final a?)
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () =>
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => _telaDoAtalho(a))),
          icon: Icon(a.icone),
          label: Text(a.rotulo),
        ),
      ),
  ];

  Widget _telaDoAtalho(Atalho a) => switch (a) {
    Atalho.simulador => const SimuladorPage(),
    Atalho.alarmes => const AlarmesTerminalPage(),
    Atalho.monitores => const MonitoresCompativeisPage(),
  };

  List<Widget> _teste() {
    final perguntas = widget.modulo.perguntas;
    final respondidas = _respostas.whereType<int>().length;
    final certas = [
      for (var i = 0; i < perguntas.length; i++)
        if (_respostas[i] == perguntas[i].correta) i,
    ].length;
    final fim = respondidas == perguntas.length;
    return [
      const RotuloSecao('Teste do módulo'),
      const SizedBox(height: 4),
      const Text(
        'Escolha uma resposta em cada pergunta.',
        style: TextStyle(fontSize: 16, color: Cores.textoSecundario),
      ),
      const SizedBox(height: 12),
      for (var i = 0; i < perguntas.length; i++) ...[
        _CartaoPergunta(
          numero: i + 1,
          pergunta: perguntas[i],
          resposta: _respostas[i],
          aoResponder: (op) => setState(() => _respostas[i] = op),
        ),
        const SizedBox(height: 12),
      ],
      if (fim)
        _Resultado(
          certas: certas,
          total: perguntas.length,
          aoRefazer: () => setState(() {
            _respostas = _semRespostas();
            if (_rolagem.hasClients) _rolagem.jumpTo(0);
          }),
        ),
    ];
  }
}

class _CartaoPergunta extends StatelessWidget {
  final int numero;
  final Pergunta pergunta;
  final int? resposta;
  final ValueChanged<int> aoResponder;

  const _CartaoPergunta({
    required this.numero,
    required this.pergunta,
    required this.resposta,
    required this.aoResponder,
  });

  @override
  Widget build(BuildContext context) {
    final respondida = resposta != null;
    final acertou = resposta == pergunta.correta;
    return CartaoBranco(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$numero. ${pergunta.enunciado}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          for (var o = 0; o < pergunta.opcoes.length; o++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Opcao(
                texto: pergunta.opcoes[o],
                estado: !respondida
                    ? _EstadoOpcao.livre
                    : o == pergunta.correta
                    ? _EstadoOpcao.certa
                    : o == resposta
                    ? _EstadoOpcao.errada
                    : _EstadoOpcao.apagada,
                aoTocar: respondida ? null : () => aoResponder(o),
              ),
            ),
          if (respondida)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1, right: 8),
                  child: Icon(
                    acertou ? Icons.check_circle : Icons.info_outline,
                    size: 20,
                    color: acertou ? Cores.verdeTexto : Cores.falha,
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: acertou ? 'Certo. ' : 'Não é essa. ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: acertou ? Cores.verdeTexto : Cores.falha,
                          ),
                        ),
                        TextSpan(text: pergunta.explicacao),
                      ],
                    ),
                    style: const TextStyle(fontSize: 15, color: Cores.tinta),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

enum _EstadoOpcao { livre, certa, errada, apagada }

class _Opcao extends StatelessWidget {
  final String texto;
  final _EstadoOpcao estado;
  final VoidCallback? aoTocar;

  const _Opcao({required this.texto, required this.estado, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final (fundo, borda, cor, icone) = switch (estado) {
      _EstadoOpcao.livre => (
        Cores.branco,
        Cores.borda,
        Cores.tinta,
        Icons.radio_button_unchecked,
      ),
      _EstadoOpcao.certa => (
        Cores.verdeClaro,
        Cores.verde,
        Cores.verdeTexto,
        Icons.check_circle,
      ),
      _EstadoOpcao.errada => (
        const Color(0xFFFBEAE4),
        Cores.falha,
        Cores.falha,
        Icons.cancel,
      ),
      _EstadoOpcao.apagada => (
        Cores.branco,
        Cores.neutro,
        Cores.textoSecundario,
        Icons.radio_button_unchecked,
      ),
    };
    return Semantics(
      button: aoTocar != null,
      label: texto,
      excludeSemantics: true,
      child: Material(
        color: fundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borda, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icone, size: 20, color: cor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(fontSize: 16, color: cor),
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

class _Resultado extends StatelessWidget {
  final int certas;
  final int total;
  final VoidCallback aoRefazer;

  const _Resultado({
    required this.certas,
    required this.total,
    required this.aoRefazer,
  });

  @override
  Widget build(BuildContext context) {
    final tudo = certas == total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tudo ? Cores.verdeClaro : Cores.neutro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$certas de $total certas',
            style: TextStyle(
              fontFamily: fonteTitulo,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: tudo ? Cores.verdeTexto : Cores.tinta,
            ),
          ),
          Text(
            tudo
                ? 'Módulo concluído.'
                : 'Releia as aulas e refaça o teste quando quiser.',
            style: const TextStyle(fontSize: 15),
          ),
          if (!tudo) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: aoRefazer,
              icon: const Icon(Icons.refresh),
              label: const Text('Refazer o teste'),
            ),
          ],
        ],
      ),
    );
  }
}
