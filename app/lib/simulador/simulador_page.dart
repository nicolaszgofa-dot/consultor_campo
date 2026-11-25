import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import 'explicacoes.dart';
import 'referencias_terminal.dart';
import 'terminal_eletric.dart';
import 'terminal_estado.dart';

/// Protótipo navegável das telas do sistema Elétric (Adobe XD).
final simuladorEletric = Uri.parse(
  'https://xd.adobe.com/view/3f284216-b6a3-4de3-b087-694c4e50d7bb-6a7b/'
  '?fullscreen&hints=off',
);

/// Simulador do terminal ISOBUS do Elétric: a tela de trabalho com dados
/// simulados, o modo explicação e o protótipo do Adobe XD como alternativa.
class SimuladorPage extends StatefulWidget {
  /// Troca a abertura do link nos testes.
  final Future<bool> Function(Uri)? abrirLink;

  /// Nos testes a simulação não roda sozinha (sem relógio).
  final bool animar;

  const SimuladorPage({super.key, this.abrirLink, this.animar = true});

  @override
  State<SimuladorPage> createState() => _SimuladorPageState();
}

class _SimuladorPageState extends State<SimuladorPage> {
  final _terminal = TerminalEstado();
  var _explicando = false;
  ParteTerminal? _parte;

  @override
  void initState() {
    super.initState();
    if (widget.animar) _terminal.iniciar();
  }

  @override
  void dispose() {
    _terminal.dispose();
    super.dispose();
  }

  Future<void> _abrirPrototipo() async {
    final mensageiro = ScaffoldMessenger.of(context);
    var abriu = false;
    try {
      abriu =
          await (widget.abrirLink ??
              (u) => launchUrl(u, mode: LaunchMode.externalApplication))(
            simuladorEletric,
          );
    } catch (_) {
      abriu = false;
    }
    if (!abriu) {
      mensageiro.showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir o simulador. Confira a internet e tente '
            'de novo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final terminal = TerminalEletric(
      estado: _terminal,
      explicando: _explicando,
      aoExplicar: (p) => setState(() => _parte = p),
    );
    final painel = _Painel(
      terminal: _terminal,
      explicando: _explicando,
      parte: _parte,
      aoExplicar: (v) => setState(() {
        _explicando = v;
        if (!v) _parte = null;
      }),
      aoAbrirPrototipo: _abrirPrototipo,
    );
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoFluxo(titulo: 'Simulador Elétric'),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final largo = box.maxWidth >= 900;
                if (largo) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Center(child: terminal)),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 340,
                          child: SingleChildScrollView(child: painel),
                        ),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  children: [terminal, const SizedBox(height: 12), painel],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final _estiloBotao = OutlinedButton.styleFrom(
  minimumSize: const Size(64, 48),
  foregroundColor: Cores.verdeTexto,
  side: const BorderSide(color: Cores.verde),
);

class _Painel extends StatelessWidget {
  final TerminalEstado terminal;
  final bool explicando;
  final ParteTerminal? parte;
  final ValueChanged<bool> aoExplicar;
  final VoidCallback aoAbrirPrototipo;

  const _Painel({
    required this.terminal,
    required this.explicando,
    required this.parte,
    required this.aoExplicar,
    required this.aoAbrirPrototipo,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: terminal,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CartaoBranco(
            // SwitchListTile precisa de um Material entre ele e o cartão.
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: explicando,
                    onChanged: aoExplicar,
                    title: const Text(
                      'Explicar a tela',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Toque numa parte do terminal para ver o que ela mostra.',
                    ),
                  ),
                  if (explicando) ...[
                    const Divider(),
                    if (parte == null)
                      const Text(
                        'As partes com moldura amarela têm explicação.',
                        style: TextStyle(color: Cores.textoSecundario),
                      )
                    else ...[
                      Text(
                        parte!.titulo,
                        style: const TextStyle(
                          fontFamily: fonteTitulo,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        parte!.texto,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          CartaoBranco(
            // SwitchListTile precisa de um Material entre ele e o cartão.
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RotuloSecao('Simular no campo'),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: terminal.linhaEntupida != null,
                    onChanged: (v) => terminal.entupir(v ? 6 : null),
                    title: const Text('Entupir a linha 7'),
                    subtitle: const Text(
                      'Acende o alarme de fim de sementes ou entupimento.',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: terminal.pressaoArAlta,
                    onChanged: (v) =>
                        terminal.mudar(() => terminal.pressaoArAlta = v),
                    title: const Text('Pressão de ar alta'),
                    subtitle: const Text(
                      'O disco pega sementes duplas: excesso de duplos e '
                      'distribuição ruim.',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: terminal.alternadorParado,
                    onChanged: (v) =>
                        terminal.mudar(() => terminal.alternadorParado = v),
                    title: const Text('Parar o alternador'),
                    subtitle: const Text(
                      'Com a energia em Alternador: rotação zero e alarme.',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: terminal.semSinalGps,
                    onChanged: (v) =>
                        terminal.mudar(() => terminal.semSinalGps = v),
                    title: const Text('Perder o sinal de GPS'),
                    subtitle: const Text(
                      'Com a fonte em GPS: fonte de velocidade ausente.',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Velocidade: ${terminal.velocidadeKmh.toStringAsFixed(1)} '
                    'km/h',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: terminal.velocidadeKmh,
                    min: 0,
                    max: 16,
                    divisions: 32,
                    label: terminal.velocidadeKmh.toStringAsFixed(1),
                    onChanged: terminal.mudarVelocidade,
                  ),
                  const Text(
                    'No terminal: toque em TAXA para ajustar, no título do '
                    'gráfico para trocar a grandeza, numa barra para abrir a '
                    'linha, na tecla C para Plantar ou Manobrar e na tecla J '
                    'para as configurações.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Cores.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (terminal.alarmes case [final alarme, ...]) ...[
            const SizedBox(height: 12),
            CartaoAlarme(tipo: alarme.tipo, texto: alarme.texto),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AlarmesTerminalPage(),
              ),
            ),
            icon: const Icon(Icons.notification_important_outlined),
            label: const Text('Lista de alarmes'),
            style: _estiloBotao,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MonitoresCompativeisPage(),
              ),
            ),
            icon: const Icon(Icons.monitor),
            label: const Text('Monitores compatíveis'),
            style: _estiloBotao,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: aoAbrirPrototipo,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir protótipo (Adobe XD)'),
            style: _estiloBotao,
          ),
          const SizedBox(height: 8),
          const Text(
            'Dados simulados, para treinamento. Os valores do campo vêm do '
            'terminal no trator.',
            style: TextStyle(fontSize: 12, color: Cores.textoSecundario),
          ),
        ],
      ),
    );
  }
}
