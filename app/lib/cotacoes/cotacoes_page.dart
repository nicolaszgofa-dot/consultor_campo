import 'package:cotacoes/cotacoes.dart';
import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'cotacoes_estado.dart';
import 'informar_preco.dart';
import 'mapa_uf.dart';

/// Mercado: cotação da saca por praça e por estado, com estimativa para as
/// cidades sem praça e preços informados pelo vendedor.
class CotacoesPage extends StatefulWidget {
  final CotacoesEstado? estado;

  /// Falso dentro de outra tela que já tem cabeçalho (aba da Inteligência
  /// de mercado).
  final bool comCabecalho;

  const CotacoesPage({super.key, this.estado, this.comCabecalho = true});

  @override
  State<CotacoesPage> createState() => _CotacoesPageState();
}

class _CotacoesPageState extends State<CotacoesPage> {
  late final CotacoesEstado _estado = widget.estado ?? CotacoesEstado();

  @override
  void initState() {
    super.initState();
    if (!_estado.carregado) _estado.carregar();
  }

  @override
  void dispose() {
    if (widget.estado == null) _estado.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conteudo = ListenableBuilder(
      listenable: _estado,
      builder: (context, _) {
        if (!_estado.carregado) {
          return const Center(child: CircularProgressIndicator());
        }
        return LayoutBuilder(
          builder: (context, box) => box.maxWidth >= 900
              ? _Largo(estado: _estado)
              : _Estreito(estado: _estado),
        );
      },
    );
    if (!widget.comCabecalho) return conteudo;
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoFluxo(titulo: 'Mercado'),
          Expanded(child: conteudo),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- layouts

class _Largo extends StatelessWidget {
  final CotacoesEstado estado;

  const _Largo({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 460,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 10, 24),
                children: [
                  _Topo(estado: estado),
                  const SizedBox(height: 14),
                  CartaoBranco(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Referencias(estado: estado),
                        const SizedBox(height: 14),
                        _Mapa(estado: estado),
                        const SizedBox(height: 10),
                        _Legenda(estado: estado),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _NotaFontes(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 16, 20, 24),
                children: [_DetalheUf(estado: estado)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Estreito extends StatelessWidget {
  final CotacoesEstado estado;

  const _Estreito({required this.estado});

  @override
  Widget build(BuildContext context) {
    final cidade = estado.cidade ?? estado.minhaCidade;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _Topo(estado: estado),
        if (cidade != null) ...[
          const SizedBox(height: 12),
          _CartaoCidade(estado: estado, cidade: cidade),
        ],
        const SizedBox(height: 14),
        _Referencias(estado: estado),
        const SizedBox(height: 14),
        CartaoBranco(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Mapa(estado: estado, abrirAoTocar: true),
              const SizedBox(height: 8),
              _Legenda(estado: estado),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const RotuloSecao('Por estado · Conab, produtor'),
        const SizedBox(height: 6),
        _ListaEstados(estado: estado),
        const SizedBox(height: 12),
        const _NotaFontes(),
      ],
    );
  }
}

/// Estado aberto a partir da lista, no celular.
class _UfPage extends StatelessWidget {
  final CotacoesEstado estado;

  const _UfPage({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListenableBuilder(
            listenable: estado,
            builder: (context, _) =>
                CabecalhoFluxo(titulo: nomesUf[estado.uf] ?? estado.uf),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: estado,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  const AlertaConceito(),
                  const SizedBox(height: 12),
                  Seletor<Produto>(
                    opcoes: Produto.values,
                    selecionada: estado.produto,
                    rotulo: (p) => p.nome,
                    aoEscolher: estado.escolherProduto,
                  ),
                  const SizedBox(height: 12),
                  _DetalheUf(estado: estado, comCabecalho: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- topo

/// O Mercado ainda é um conceito: os preços não servem de referência.
class AlertaConceito extends StatelessWidget {
  const AlertaConceito({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Cores.prejuizo),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Cores.prejuizo),
            SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Em conceito. ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text:
                          'Esta tela ainda está em teste. Os preços e as '
                          'estimativas não devem ser considerados como certos '
                          'nem usados em negociação.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 14, color: Color(0xFF7A1A12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Topo extends StatelessWidget {
  final CotacoesEstado estado;

  const _Topo({required this.estado});

  @override
  Widget build(BuildContext context) {
    final ultima = estado.ultimaCotacao;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AlertaConceito(),
        const SizedBox(height: 12),
        _BarraStatus(estado: estado),
        if (estado.desatualizado && ultima != null) ...[
          const SizedBox(height: 8),
          _Aviso(
            'Cotações de ${dataBr(ultima)}. '
            '${estado.semConexao ? 'Conecte à internet e atualize' : 'A fonte ainda não publicou valores mais novos'}.',
          ),
        ],
        const SizedBox(height: 12),
        Seletor<Produto>(
          opcoes: Produto.values,
          selecionada: estado.produto,
          rotulo: (p) => p.nome,
          aoEscolher: estado.escolherProduto,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Busca(estado: estado)),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () => abrirInformarPreco(context, estado),
                icon: const Icon(Icons.add),
                label: const Text('Informar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BarraStatus extends StatelessWidget {
  final CotacoesEstado estado;

  const _BarraStatus({required this.estado});

  @override
  Widget build(BuildContext context) {
    final String texto;
    final Color cor;
    if (estado.atualizando) {
      texto = 'Atualizando…';
      cor = Cores.cinza;
    } else if (estado.origem == OrigemFeed.internet) {
      texto = 'Atualizado ${_diaHora(estado.recebidoEm!)}';
      cor = Cores.verde;
    } else if (estado.recebidoEm != null) {
      texto =
          'Sem internet · valores salvos em ${_diaHora(estado.recebidoEm!)}';
      cor = Cores.atencao;
    } else {
      texto =
          'Sem internet · valores do app, de '
          '${_diaHora(estado.feed!.geradoEm.toLocal())}';
      cor = Cores.atencao;
    }
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 14, color: Cores.textoSecundario),
          ),
        ),
        TextButton.icon(
          onPressed: estado.atualizando ? null : estado.atualizar,
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text('Atualizar'),
        ),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  final String texto;

  const _Aviso(this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.schedule, size: 18, color: Color(0xFF7A4800)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14, color: Color(0xFF7A4800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Busca extends StatefulWidget {
  final CotacoesEstado estado;

  const _Busca({required this.estado});

  @override
  State<_Busca> createState() => _BuscaState();
}

class _BuscaState extends State<_Busca> {
  final _controle = TextEditingController();

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultados = buscarCidades(_controle.text, limite: 6);
    final cotacoes = widget.estado.cotacoes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: TextField(
            controller: _controle,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar cidade',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              filled: true,
              fillColor: Cores.branco,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Cores.borda),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Cores.borda),
              ),
            ),
          ),
        ),
        if (resultados.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Cores.branco,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Cores.borda),
            ),
            child: Column(
              children: [
                for (final c in resultados)
                  _ResultadoBusca(
                    cidade: c,
                    preco: precoDaCidade(c, cotacoes),
                    aoTocar: () {
                      _controle.clear();
                      FocusScope.of(context).unfocus();
                      widget.estado.escolherCidade(c);
                      if (MediaQuery.sizeOf(context).width < 900) {
                        _abrirUf(context, widget.estado);
                      }
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ResultadoBusca extends StatelessWidget {
  final Cidade cidade;
  final PrecoCidade? preco;
  final VoidCallback aoTocar;

  const _ResultadoBusca({
    required this.cidade,
    required this.preco,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: cidade.nome,
                    children: [
                      TextSpan(
                        text: ' · ${cidade.uf}',
                        style: const TextStyle(color: Cores.textoSecundario),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (preco != null) ...[
                Text(
                  numeroBr(preco!.preco, 2),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                EtiquetaOrigem.daOrigem(preco!.origem),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------- mapa e estados

const _claro = Color(0xFFDDF1DF);
const _escuro = Color(0xFF145A1D);

(double, double)? _faixa(Map<String, Cotacao> conab) {
  if (conab.isEmpty) return null;
  final v = conab.values.map((c) => c.preco);
  return (v.reduce((a, b) => a < b ? a : b), v.reduce((a, b) => a > b ? a : b));
}

Map<String, Cotacao> _conabPorUf(List<Cotacao> cotacoes) => {
  for (final uf in nomesUf.keys) uf: ?conabDoEstado(uf, cotacoes),
};

Color _corDoPreco(double preco, (double, double) faixa) {
  final (min, max) = faixa;
  final f = max > min ? (preco - min) / (max - min) : 0.5;
  return f < 0.5
      ? Color.lerp(_claro, Cores.verde, f * 2)!
      : Color.lerp(Cores.verde, _escuro, (f - 0.5) * 2)!;
}

class _Mapa extends StatelessWidget {
  final CotacoesEstado estado;

  /// No celular, tocar no estado já abre o detalhe.
  final bool abrirAoTocar;

  const _Mapa({required this.estado, this.abrirAoTocar = false});

  @override
  Widget build(BuildContext context) {
    final conab = _conabPorUf(estado.cotacoes);
    final faixa = _faixa(conab);
    return MapaBrasil(
      // Estreito demais para o preço caber em todas as etiquetas.
      mostrarValores: MediaQuery.sizeOf(context).width >= 600,
      valores: {
        for (final e in conab.entries) e.key: numeroBr(e.value.preco, 1),
      },
      cores: {
        if (faixa != null)
          for (final e in conab.entries)
            e.key: _corDoPreco(e.value.preco, faixa),
      },
      selecionado: estado.uf,
      aoEscolher: (uf) {
        estado.escolherUf(uf);
        if (abrirAoTocar) _abrirUf(context, estado);
      },
    );
  }
}

class _Legenda extends StatelessWidget {
  final CotacoesEstado estado;

  const _Legenda({required this.estado});

  @override
  Widget build(BuildContext context) {
    final conab = _conabPorUf(estado.cotacoes);
    final faixa = _faixa(conab);
    final semana = conab['MT'] ?? (conab.isEmpty ? null : conab.values.first);
    const estilo = TextStyle(fontSize: 13, color: Cores.textoSecundario);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (faixa != null)
          Row(
            children: [
              Text(numeroBr(faixa.$1, 1), style: estilo),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [_claro, Cores.verde, _escuro],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(numeroBr(faixa.$2, 1), style: estilo),
            ],
          ),
        const SizedBox(height: 4),
        Text(
          'Preço ao produtor por estado · Conab'
          '${semana == null ? '' : ', ${_semana(semana)}'} · R\$/sc 60 kg',
          style: estilo,
        ),
      ],
    );
  }
}

class _ListaEstados extends StatelessWidget {
  final CotacoesEstado estado;

  const _ListaEstados({required this.estado});

  @override
  Widget build(BuildContext context) {
    final cotacoes = estado.cotacoes;
    final conab = _conabPorUf(cotacoes);
    // Estados com preço primeiro, cada grupo em ordem alfabética.
    final ufs = nomesUf.keys.toList()
      ..sort((a, b) {
        final semA = conab[a] == null, semB = conab[b] == null;
        if (semA != semB) return semA ? 1 : -1;
        return nomesUf[a]!.compareTo(nomesUf[b]!);
      });
    return CartaoBranco(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          for (final uf in ufs)
            _LinhaEstado(
              uf: uf,
              conab: conab[uf],
              pracas: _pracasDoUf(uf, cotacoes).length,
              ultima: uf == ufs.last,
              aoTocar: () {
                estado.escolherUf(uf);
                _abrirUf(context, estado);
              },
            ),
        ],
      ),
    );
  }
}

void _abrirUf(BuildContext context, CotacoesEstado estado) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => _UfPage(estado: estado)));
}

class _LinhaEstado extends StatelessWidget {
  final String uf;
  final Cotacao? conab;
  final int pracas;
  final bool ultima;
  final VoidCallback aoTocar;

  const _LinhaEstado({
    required this.uf,
    required this.conab,
    required this.pracas,
    required this.ultima,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(
          border: ultima
              ? null
              : const Border(bottom: BorderSide(color: Cores.neutro)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                uf,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Cores.verdeTexto,
                ),
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: nomesUf[uf],
                  children: [
                    if (pracas > 0)
                      TextSpan(
                        text: pracas == 1 ? ' · 1 praça' : ' · $pracas praças',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Cores.textoSecundario,
                        ),
                      ),
                  ],
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (conab == null)
              const Text(
                'sem dado',
                style: TextStyle(color: Cores.textoSecundario),
              )
            else ...[
              Text(
                numeroBr(conab!.preco, 2),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              _Variacao(conab!.variacao),
            ],
            const Icon(Icons.chevron_right, color: Cores.cinza),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- detalhe

List<Cotacao> _pracasDoUf(String uf, List<Cotacao> cotacoes) =>
    cotacoes
        .where(
          (c) =>
              c.uf == uf &&
              c.tipo != TipoCotacao.conabUf &&
              c.tipo != TipoCotacao.futuro,
        )
        .toList()
      ..sort((a, b) => b.preco.compareTo(a.preco));

class _DetalheUf extends StatelessWidget {
  final CotacoesEstado estado;
  final bool comCabecalho;

  const _DetalheUf({required this.estado, this.comCabecalho = true});

  @override
  Widget build(BuildContext context) {
    final cotacoes = estado.cotacoes;
    final uf = estado.uf;
    final conab = conabDoEstado(uf, cotacoes);
    final pracas = _pracasDoUf(uf, cotacoes);
    final comCotacao = {
      for (final c in pracas)
        if (c.tipo.entraNaEstimativa) c.local,
    };
    final estimadas = [
      for (final c in cidades)
        if (c.uf == uf && !comCotacao.contains(c.nome))
          if (precoDaCidade(c, cotacoes) case final p?) (c, p),
    ];
    final cidade = estado.cidade?.uf == uf ? estado.cidade : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CartaoBranco(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Cores.verdeClaro,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  uf,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Cores.verdeTexto,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  comCabecalho ? nomesUf[uf]! : estado.produto.nome,
                  style: const TextStyle(
                    fontFamily: fonteTitulo,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Rótulo quebra em duas linhas no celular; o preço não.
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      conab == null
                          ? 'Conab · sem dado'
                          : 'Conab · ${_semana(conab)}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Cores.textoSecundario,
                      ),
                    ),
                  ),
                  if (conab != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          numeroBr(conab.preco, 2),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _Variacao(conab.variacao),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        if (cidade != null) ...[
          const SizedBox(height: 12),
          _CartaoCidade(estado: estado, cidade: cidade),
        ],
        const SizedBox(height: 16),
        RotuloSecao('Praças com cotação · ${pracas.length}'),
        const SizedBox(height: 4),
        if (pracas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Nenhuma praça com cotação neste estado. Vale a média Conab, '
              'ou informe um preço.',
              style: TextStyle(fontSize: 15, color: Cores.textoSecundario),
            ),
          )
        else
          CartaoBranco(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                for (var i = 0; i < pracas.length; i++)
                  _LinhaPraca(
                    cotacao: pracas[i],
                    ultima: i == pracas.length - 1,
                    aoRemover: pracas[i].tipo == TipoCotacao.informado
                        ? () => estado.removerInformado(pracas[i])
                        : null,
                  ),
              ],
            ),
          ),
        if (estimadas.isNotEmpty) ...[
          const SizedBox(height: 16),
          const RotuloSecao('Outras cidades · estimado'),
          const SizedBox(height: 2),
          Text(
            'Média das praças até ${raioEstimativaKm.round()} km, com mais '
            'peso para as mais próximas. Sem praça perto, vale a média Conab '
            'do estado.',
            style: const TextStyle(fontSize: 13, color: Cores.textoSecundario),
          ),
          const SizedBox(height: 6),
          CartaoBranco(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                for (var i = 0; i < estimadas.length; i++)
                  _LinhaEstimada(
                    cidade: estimadas[i].$1,
                    preco: estimadas[i].$2,
                    ultima: i == estimadas.length - 1,
                    aoTocar: () => estado.escolherCidade(estimadas[i].$1),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CartaoCidade extends StatelessWidget {
  final CotacoesEstado estado;
  final Cidade cidade;

  const _CartaoCidade({required this.estado, required this.cidade});

  @override
  Widget build(BuildContext context) {
    final preco = precoDaCidade(cidade, estado.cotacoes);
    final minha = estado.minhaCidade == cidade;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FCF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Cores.verde, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      minha ? 'Sua região' : 'Cidade selecionada',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Cores.verdeTexto,
                      ),
                    ),
                    Text(
                      '${cidade.nome}, ${cidade.uf}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (preco != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      numeroBr(preco.preco, 2),
                      style: const TextStyle(
                        fontFamily: fonteTitulo,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'R\$/sc 60 kg',
                      style: TextStyle(
                        fontSize: 12,
                        color: Cores.textoSecundario,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (preco == null)
            const Text(
              'Sem cotação nem média Conab para esta cidade.',
              style: TextStyle(fontSize: 14, color: Cores.textoSecundario),
            )
          else
            Row(
              children: [
                EtiquetaOrigem.daOrigem(preco.origem),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _explicacao(preco),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Cores.textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
          if (!minha)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => estado.definirMinhaCidade(cidade),
                icon: const Icon(Icons.place_outlined, size: 20),
                label: const Text('Usar como minha região'),
              ),
            ),
        ],
      ),
    );
  }
}

String _explicacao(PrecoCidade p) {
  switch (p.origem) {
    case OrigemPreco.local:
      final c = p.cotacao!;
      return 'Cotação da praça · ${c.detalhe ?? c.fonte} · ${_dia(c.data)}';
    case OrigemPreco.informado:
      final c = p.cotacao!;
      return 'Informado: ${c.fonte}'
          '${c.informadoPor == null ? '' : ' · ${c.informadoPor}'} · ${_dia(c.data)}';
    case OrigemPreco.estimado:
      final perto = p.pracas
          .take(2)
          .map((x) => '${x.cidade.nome} (${x.km.round()} km)')
          .join(' e ');
      final mais = p.pracas.length > 2 ? ' e mais ${p.pracas.length - 2}' : '';
      return 'Estimado de $perto$mais';
    case OrigemPreco.conab:
      return 'Sem praça perto: média Conab do estado, ${_semana(p.cotacao!)}';
  }
}

class _LinhaPraca extends StatelessWidget {
  final Cotacao cotacao;
  final bool ultima;
  final VoidCallback? aoRemover;

  const _LinhaPraca({
    required this.cotacao,
    required this.ultima,
    this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final c = cotacao;
    final informado = c.tipo == TipoCotacao.informado;
    final detalhe = informado
        ? [c.fonte, ?c.informadoPor].join(' · ')
        : [?c.detalhe, c.fonte].join(' · ');
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      decoration: BoxDecoration(
        border: ultima
            ? null
            : const Border(bottom: BorderSide(color: Cores.neutro)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.local ?? c.detalhe ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    detalhe,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Cores.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          ),
          EtiquetaOrigem.doTipo(c.tipo),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                numeroBr(c.preco, 2),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (c.variacao != null) ...[
                    _Variacao(c.variacao),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    _dia(c.data),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Cores.textoSecundario,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (aoRemover != null)
            IconButton(
              tooltip: 'Remover preço informado',
              onPressed: aoRemover,
              icon: const Icon(Icons.delete_outline, color: Cores.cinzaEscuro),
            ),
        ],
      ),
    );
  }
}

class _LinhaEstimada extends StatelessWidget {
  final Cidade cidade;
  final PrecoCidade preco;
  final bool ultima;
  final VoidCallback aoTocar;

  const _LinhaEstimada({
    required this.cidade,
    required this.preco,
    required this.ultima,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          border: ultima
              ? null
              : const Border(bottom: BorderSide(color: Cores.neutro)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cidade.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _explicacao(preco),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Cores.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            EtiquetaOrigem.daOrigem(preco.origem),
            const SizedBox(width: 10),
            Text(
              numeroBr(preco.preco, 2),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Referencias extends StatelessWidget {
  final CotacoesEstado estado;

  const _Referencias({required this.estado});

  @override
  Widget build(BuildContext context) {
    final refs = estado.cotacoes.where((c) => c.tipo.referenciaNacional);
    if (refs.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final r in refs)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Cores.fundo,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Cores.neutro),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${r.detalhe ?? r.local} · ${r.fonte}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Cores.textoSecundario,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      numeroBr(r.preco, 2),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _Variacao(r.variacao),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NotaFontes extends StatelessWidget {
  const _NotaFontes();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Fontes: praças, Notícias Agrícolas; indicadores, Cepea e B3; '
      'estados, Conab (preço semanal ao produtor). Preços em R\$ por saca '
      'de 60 kg. Preços informados ficam salvos neste aparelho.',
      style: TextStyle(fontSize: 12, color: Cores.textoSecundario),
    );
  }
}

// ---------------------------------------------------------- pequenos

/// Etiqueta que diz de onde vem o preço, para o vendedor saber o quanto
/// confiar nele.
class EtiquetaOrigem extends StatelessWidget {
  final String texto;
  final Color fundo;
  final Color cor;
  final bool tracejada;

  const EtiquetaOrigem._(
    this.texto,
    this.fundo,
    this.cor, {
    this.tracejada = false,
  });

  factory EtiquetaOrigem.doTipo(TipoCotacao t) => switch (t) {
    TipoCotacao.praca => EtiquetaOrigem._(
      t.rotulo,
      Cores.verdeClaro,
      Cores.verdeTexto,
    ),
    TipoCotacao.porto => EtiquetaOrigem._(
      t.rotulo,
      const Color(0xFFE3EBFB),
      Cores.dupla,
    ),
    TipoCotacao.informado => EtiquetaOrigem._(
      t.rotulo,
      const Color(0xFFFFF4E0),
      const Color(0xFF7A4800),
    ),
    _ => EtiquetaOrigem._(t.rotulo, Cores.neutro, Cores.tinta),
  };

  factory EtiquetaOrigem.daOrigem(OrigemPreco o) => switch (o) {
    OrigemPreco.local => EtiquetaOrigem.doTipo(TipoCotacao.praca),
    OrigemPreco.informado => EtiquetaOrigem.doTipo(TipoCotacao.informado),
    OrigemPreco.estimado => EtiquetaOrigem._(
      o.rotulo,
      Cores.branco,
      Cores.textoSecundario,
      tracejada: true,
    ),
    OrigemPreco.conab => EtiquetaOrigem._(o.rotulo, Cores.neutro, Cores.tinta),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(6),
        border: tracejada ? Border.all(color: Cores.cinza) : null,
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cor),
      ),
    );
  }
}

class _Variacao extends StatelessWidget {
  final double? valor;

  const _Variacao(this.valor);

  @override
  Widget build(BuildContext context) {
    final v = valor;
    if (v == null) return const SizedBox.shrink();
    final (fundo, cor) = v == 0
        ? (Cores.neutro, Cores.tinta)
        : v > 0
        ? (const Color(0xFFDDF1DF), _escuro)
        : (const Color(0xFFFDE7E5), Cores.prejuizo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${v > 0 ? '+' : ''}${numeroBr(v, 2)}%',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cor),
      ),
    );
  }
}

String _dois(int n) => n.toString().padLeft(2, '0');

String _dia(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}';

String _diaHora(DateTime d) =>
    '${_dia(d)} às ${_dois(d.hour)}:${_dois(d.minute)}';

String _semana(Cotacao c) =>
    c.inicio == null ? _dia(c.data) : 'sem. ${_dia(c.inicio!)}–${_dia(c.data)}';
