import 'package:flutter/material.dart';

import '../avaliacao/avaliacao_estado.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'avaliacao_emergencia.dart';
import 'emergencia_page.dart';
import 'nova_emergencia_page.dart';

/// Aba de emergência: explica o método e lista as avaliações salvas.
class EmergenciaAba extends StatefulWidget {
  final RepositorioEmergencia repositorio;

  const EmergenciaAba({super.key, required this.repositorio});

  @override
  State<EmergenciaAba> createState() => _EmergenciaAbaState();
}

class _EmergenciaAbaState extends State<EmergenciaAba> {
  late Future<List<AvaliacaoEmergencia>> _lista = widget.repositorio.listar();

  void _recarregar() {
    if (!mounted) return;
    setState(() {
      _lista = widget.repositorio.listar();
    });
  }

  Future<void> _nova() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NovaEmergenciaPage(repositorio: widget.repositorio),
      ),
    );
    _recarregar();
  }

  Future<void> _abrir(AvaliacaoEmergencia a) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            EmergenciaPage(repositorio: widget.repositorio, avaliacao: a),
      ),
    );
    _recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: FutureBuilder<List<AvaliacaoEmergencia>>(
          future: _lista,
          builder: (context, snap) {
            final avaliacoes = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _ComoFunciona(),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _nova,
                  child: const Text('Nova avaliação de emergência'),
                ),
                if (avaliacoes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const RotuloSecao('Avaliações em andamento'),
                  const SizedBox(height: 8),
                  for (final a in avaliacoes) ...[
                    _CartaoAvaliacao(avaliacao: a, aoAbrir: () => _abrir(a)),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ComoFunciona extends StatelessWidget {
  const _ComoFunciona();

  @override
  Widget build(BuildContext context) {
    const passos = [
      'Marque com estacas um trecho de cada linha logo após o plantio.',
      'Quando surgirem as primeiras plantas, volte todo dia no mesmo horário.',
      'Conte só as plantas novas de cada linha e registre no app.',
      'O app separa as plantas pelo dia em que emergiram e mostra a perda.',
    ];
    return CartaoBranco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergência dia após dia',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Planta que emerge depois das vizinhas vira planta dominada e '
            'produz menos. No milho, 1 dia de atraso já reduz cerca de 35% '
            'do potencial da planta.',
            style: TextStyle(fontSize: 14, color: Cores.textoSecundario),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < passos.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Cores.verdeEscuro,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Cores.branco,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      passos[i],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CartaoAvaliacao extends StatelessWidget {
  final AvaliacaoEmergencia avaliacao;
  final VoidCallback aoAbrir;

  const _CartaoAvaliacao({required this.avaliacao, required this.aoAbrir});

  @override
  Widget build(BuildContext context) {
    final r = avaliacao.resultado;
    final titulo = avaliacao.talhao.isEmpty ? 'Sem talhão' : avaliacao.talhao;
    return Material(
      color: Cores.branco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Cores.borda),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: aoAbrir,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$titulo · ${nomeCultura(avaliacao.cultura)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Plantio em ${dataBr(avaliacao.dataPlantio)} · '
                      '${avaliacao.registros.length} marcações',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Cores.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              if (r.emergidas > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      percentual(r.percentualNoDia(1)),
                      style: TextStyle(
                        fontFamily: fonteTitulo,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: corDoPercentual(r.percentualNoDia(1)),
                      ),
                    ),
                    const Text(
                      'no 1º dia',
                      style: TextStyle(
                        fontSize: 12,
                        color: Cores.textoSecundario,
                      ),
                    ),
                  ],
                ),
              const Icon(Icons.chevron_right, color: Cores.cinza),
            ],
          ),
        ),
      ),
    );
  }
}
