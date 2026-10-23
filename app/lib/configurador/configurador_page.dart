import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import 'configurador_estado.dart';
import 'etapas.dart';
import 'resultado_etapa.dart';

/// Fluxo guiado do Configurador Técnico: uma etapa por vez. No tablet as
/// etapas ficam numa coluna à esquerda; no celular, na barra do cabeçalho.
class ConfiguradorPage extends StatefulWidget {
  final ConfiguradorEstado? estado;

  const ConfiguradorPage({super.key, this.estado});

  @override
  State<ConfiguradorPage> createState() => _ConfiguradorPageState();
}

class _ConfiguradorPageState extends State<ConfiguradorPage> {
  late final ConfiguradorEstado _estado = widget.estado ?? ConfiguradorEstado();

  @override
  void dispose() {
    if (widget.estado == null) _estado.dispose();
    super.dispose();
  }

  Widget _conteudo() => switch (_estado.etapa) {
    EtapaConfigurador.tecnologia => EtapaTecnologia(estado: _estado),
    EtapaConfigurador.tipo => EtapaTipo(estado: _estado),
    EtapaConfigurador.linhas => EtapaLinhas(estado: _estado),
    EtapaConfigurador.secoes => EtapaSecoes(estado: _estado),
    EtapaConfigurador.alimentacao => EtapaAlimentacao(estado: _estado),
    EtapaConfigurador.acessorios => EtapaAcessorios(estado: _estado),
    EtapaConfigurador.adaptacao => EtapaAdaptacao(estado: _estado),
    EtapaConfigurador.resultado => EtapaResultado(estado: _estado),
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _estado,
      builder: (context, _) {
        final etapas = _estado.etapas;
        final resumo = _estado.resumo;
        final pagina = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              key: ValueKey(_estado.etapa),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                if (resumo.isNotEmpty) ...[
                  Text(
                    resumo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Cores.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _conteudo(),
              ],
            ),
          ),
        );
        return PopScope(
          canPop: _estado.indice == 0,
          onPopInvokedWithResult: (saiu, _) {
            if (!saiu) _estado.voltar();
          },
          child: Scaffold(
            body: Column(
              children: [
                CabecalhoFluxo(
                  titulo: _estado.etapa.pergunta,
                  passo: _estado.indice + 1,
                  totalPassos: etapas.length,
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

/// Coluna de etapas do tablet. As etapas já feitas podem ser reabertas.
class _Trilho extends StatelessWidget {
  final ConfiguradorEstado estado;

  const _Trilho({required this.estado});

  @override
  Widget build(BuildContext context) {
    final etapas = estado.etapas;
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Cores.branco,
        border: Border(right: BorderSide(color: Cores.borda)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          for (var i = 0; i < etapas.length; i++)
            _ItemTrilho(
              numero: i + 1,
              nome: etapas[i].nome,
              feita: i < estado.indice,
              atual: i == estado.indice,
              aoTocar: i < estado.indice
                  ? () => estado.irPara(etapas[i])
                  : null,
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
  final ConfiguradorEstado estado;

  const _Rodape({required this.estado});

  @override
  Widget build(BuildContext context) {
    final noResultado = estado.etapa == EtapaConfigurador.resultado;
    final Widget principal;
    if (noResultado) {
      final pendentes = estado.resultado.pendentes.length;
      principal = FilledButton.icon(
        onPressed: pendentes > 0
            ? null
            : () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'O relatório em PDF chega na próxima versão do app.',
                  ),
                ),
              ),
        icon: const Icon(Icons.description_outlined),
        label: Text(
          pendentes > 0 ? '$pendentes pendentes' : 'Gerar relatório',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      principal = FilledButton(
        onPressed: estado.bloqueio == null ? estado.avancar : null,
        child: Text(
          estado.indice == estado.etapas.length - 2
              ? 'Ver configuração'
              : 'Continuar',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
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
              if (estado.indice > 0)
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
                child: Align(
                  alignment: Alignment.centerRight,
                  child: principal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
