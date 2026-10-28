import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import 'roi_estado.dart';
import 'proposta/proposta_page.dart';
import 'roi_etapas.dart';

/// ROI do retrofit em 7 etapas: 5 de premissas, resultado e comparativo. No
/// tablet as etapas ficam numa coluna à esquerda; no celular, na barra do
/// cabeçalho.
class RoiPage extends StatefulWidget {
  final RoiEstado? estado;

  const RoiPage({super.key, this.estado});

  @override
  State<RoiPage> createState() => _RoiPageState();
}

class _RoiPageState extends State<RoiPage> {
  late final RoiEstado _estado = widget.estado ?? RoiEstado();

  @override
  void dispose() {
    if (widget.estado == null) _estado.dispose();
    super.dispose();
  }

  Widget _conteudo() => switch (_estado.etapa) {
    RoiEstado.etapaResultado => EtapaResultadoRoi(estado: _estado),
    RoiEstado.etapaComparativo => EtapaComparativoRoi(estado: _estado),
    final e => EtapaPremissasRoi(
      key: ValueKey(e),
      estado: _estado,
      grupo: gruposRoi[e],
    ),
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _estado,
      builder: (context, _) {
        final pagina = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: ListView(
              key: ValueKey(_estado.etapa),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [_conteudo()],
            ),
          ),
        );
        return PopScope(
          canPop: _estado.etapa == 0,
          onPopInvokedWithResult: (saiu, _) {
            if (!saiu) _estado.voltar();
          },
          child: Scaffold(
            body: Column(
              children: [
                CabecalhoFluxo(
                  titulo: RoiEstado.nomesEtapas[_estado.etapa],
                  passo: _estado.etapa + 1,
                  totalPassos: RoiEstado.nomesEtapas.length,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => box.maxWidth >= 900
                        ? Row(
                            children: [
                              _Trilho(estado: _estado),
                              Expanded(child: pagina),
                            ],
                          )
                        : pagina,
                  ),
                ),
                _Rodape(estado: _estado),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Trilho extends StatelessWidget {
  final RoiEstado estado;

  const _Trilho({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Cores.branco,
        border: Border(right: BorderSide(color: Cores.borda)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          for (var i = 0; i < RoiEstado.nomesEtapas.length; i++)
            _ItemTrilho(
              numero: i + 1,
              nome: RoiEstado.nomesEtapas[i],
              feita: i < estado.etapa,
              atual: i == estado.etapa,
              aoTocar: i < estado.etapa ? () => estado.irPara(i) : null,
            ),
        ],
      ),
    );
  }
}

class _ItemTrilho extends StatelessWidget {
  final int numero;
  final String nome;
  final bool feita;
  final bool atual;
  final VoidCallback? aoTocar;

  const _ItemTrilho({
    required this.numero,
    required this.nome,
    required this.feita,
    required this.atual,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final (fundoBolinha, corBolinha) = atual
        ? (Cores.verdeEscuro, Cores.branco)
        : feita
        ? (Cores.verde, Cores.verdeEscuro)
        : (Cores.neutro, Cores.textoSecundario);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: atual ? Cores.verdeClaro : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: fundoBolinha,
                    shape: BoxShape.circle,
                  ),
                  child: feita
                      ? Icon(Icons.check, size: 18, color: corBolinha)
                      : Text(
                          '$numero',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: corBolinha,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nome,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: atual ? FontWeight.w700 : FontWeight.w500,
                      color: atual || feita
                          ? Cores.tinta
                          : Cores.textoSecundario,
                    ),
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

class _Rodape extends StatelessWidget {
  final RoiEstado estado;

  const _Rodape({required this.estado});

  void _abrirProposta(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          PropostaPage(premissas: estado.premissas, cenario: estado.cenario),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final rotulo = switch (estado.etapa) {
      4 => 'Ver resultado',
      RoiEstado.etapaResultado => 'Comparar alternativas',
      _ => 'Continuar',
    };
    return Container(
      decoration: const BoxDecoration(
        color: Cores.branco,
        border: Border(top: BorderSide(color: Cores.borda)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              if (estado.etapa > 0)
                OutlinedButton(
                  onPressed: estado.voltar,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(64, 52),
                    foregroundColor: Cores.tinta,
                    side: const BorderSide(color: Cores.cinza),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Voltar',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (estado.etapa == RoiEstado.etapaResultado)
                      OutlinedButton.icon(
                        onPressed: () => _abrirProposta(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(64, 52),
                          foregroundColor: Cores.tinta,
                          side: const BorderSide(color: Cores.cinza),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Proposta'),
                      ),
                    if (estado.etapa < RoiEstado.etapaComparativo)
                      FilledButton(
                        onPressed: estado.bloqueio == null
                            ? estado.avancar
                            : null,
                        child: Text(
                          rotulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => _abrirProposta(context),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Gerar proposta'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
