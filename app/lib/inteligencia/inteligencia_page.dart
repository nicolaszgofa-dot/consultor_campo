import 'package:flutter/material.dart';

import '../cotacoes/cotacoes_estado.dart';
import '../cotacoes/cotacoes_page.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import 'concorrencia_view.dart';
import 'precos_estado.dart';
import 'precos_view.dart';

/// Inteligência de mercado: cotações, concorrência por linha de produto e
/// preços da concorrência encontrados no campo.
class InteligenciaPage extends StatefulWidget {
  final CotacoesEstado? cotacoes;
  final PrecosConcorrenciaEstado? precos;
  final int abaInicial;

  const InteligenciaPage({
    super.key,
    this.cotacoes,
    this.precos,
    this.abaInicial = 0,
  });

  @override
  State<InteligenciaPage> createState() => _InteligenciaPageState();
}

class _InteligenciaPageState extends State<InteligenciaPage> {
  late final PrecosConcorrenciaEstado _precos =
      widget.precos ?? PrecosConcorrenciaEstado();

  @override
  void initState() {
    super.initState();
    if (!_precos.carregado) _precos.carregar();
  }

  @override
  void dispose() {
    if (widget.precos == null) _precos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.abaInicial,
      child: Scaffold(
        body: Column(
          children: [
            const CabecalhoFluxo(titulo: 'Inteligência de mercado'),
            Material(
              color: Cores.branco,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Cores.verdeEscuro,
                unselectedLabelColor: Cores.textoSecundario,
                indicatorColor: Cores.verde,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(text: 'Cotações'),
                  Tab(text: 'Concorrência'),
                  Tab(text: 'Preços da concorrência'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                // O mapa e as tabelas têm gestos próprios.
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CotacoesPage(estado: widget.cotacoes, comCabecalho: false),
                  const ConcorrenciaView(),
                  PrecosView(estado: _precos),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
