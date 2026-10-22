import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

import '../emergencia/avaliacao_emergencia.dart';
import '../emergencia/emergencia_aba.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import 'identificacao_page.dart';

/// Avaliação de plantio com três abas: plantio (trena), fertilizante e
/// emergência.
class AvaliacaoHubPage extends StatelessWidget {
  final int abaInicial;
  final RepositorioEmergencia repositorio;

  const AvaliacaoHubPage({
    super.key,
    this.abaInicial = 0,
    this.repositorio = const RepositorioEmergencia(),
  });

  @override
  Widget build(BuildContext context) {
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
                              'Avaliação de plantio',
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: [
                        Tab(text: 'Plantio'),
                        Tab(text: 'Fertilizante'),
                        Tab(text: 'Emergência'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const _AbaApresentacao(
                    icone: Icons.straighten,
                    titulo: 'Plantabilidade com trena',
                    texto:
                        'Falhas, duplas, CV e perda em sacas e em R\$. '
                        'Mínimo de 5 linhas de 10 m.',
                    botao: 'Nova avaliação de plantio',
                    tela: IdentificacaoPage(),
                  ),
                  const _AbaApresentacao(
                    icone: Icons.scale_outlined,
                    titulo: 'Distribuição de fertilizante',
                    texto:
                        'Gramas coletadas por linha, tolerância de 5% e CV '
                        'da distribuição.',
                    botao: 'Abrir calculadora de fertilizante',
                    tela: FertilizantePage(),
                  ),
                  EmergenciaAba(repositorio: repositorio),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbaApresentacao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String texto;
  final String botao;
  final Widget tela;

  const _AbaApresentacao({
    required this.icone,
    required this.titulo,
    required this.texto,
    required this.botao,
    required this.tela,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CartaoBranco(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Cores.verdeClaro,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icone, color: Cores.verdeTexto, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          texto,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Cores.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => tela)),
              child: Text(botao),
            ),
          ],
        ),
      ),
    );
  }
}
