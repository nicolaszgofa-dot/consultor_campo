import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';

/// Resultado da avaliação rápida de uma linha. O CV não precisa das sementes
/// por metro; as classes (aceitável, falha, dupla) precisam do espaçamento
/// ideal, que sai delas.
class ResultadoRapido {
  final List<double> espacamentosCm;
  final double? cvPercentual;

  /// Nulos sem as sementes por metro.
  final List<Espacamento>? classificados;
  final double? aceitaveis;
  final double? falhas;
  final double? duplas;

  const ResultadoRapido._({
    required this.espacamentosCm,
    required this.cvPercentual,
    this.classificados,
    this.aceitaveis,
    this.falhas,
    this.duplas,
  });

  int get n => espacamentosCm.length;

  /// [leiturasCm] são as leituras acumuladas da trena, com o zero na
  /// primeira planta.
  factory ResultadoRapido.calcular(
    List<double> leiturasCm, {
    double? sementesPorMetro,
  }) {
    final espacamentos = <double>[];
    var anterior = 0.0;
    for (final l in leiturasCm) {
      espacamentos.add(arredondar(l - anterior));
      anterior = l;
    }
    // CV pede ao menos dois espaçamentos (desvio padrão amostral).
    final cv = espacamentos.length < 2
        ? null
        : coeficienteVariacao(
            desvioPadraoAmostral(espacamentos),
            media(espacamentos),
          );
    // Sem sementes por metro ou sem leituras, não há classes para mostrar.
    if (sementesPorMetro == null ||
        sementesPorMetro <= 0 ||
        leiturasCm.isEmpty) {
      return ResultadoRapido._(espacamentosCm: espacamentos, cvPercentual: cv);
    }
    final ideal = 100 / sementesPorMetro;
    final classes = PlantabilidadeCalc.espacamentosDasLeituras(
      leiturasCm,
      ideal,
    );
    double pct(ClasseEspacamento c) =>
        classes.where((e) => e.classe == c).length * 100 / classes.length;
    return ResultadoRapido._(
      espacamentosCm: espacamentos,
      cvPercentual: cv,
      classificados: classes,
      aceitaveis: pct(ClasseEspacamento.aceitavel),
      falhas: pct(ClasseEspacamento.falha),
      duplas: pct(ClasseEspacamento.dupla),
    );
  }
}

/// Avaliação rápida de campo: uma linha, uma tela, sem identificação e sem
/// salvar. Mostra o CV dos espaçamentos e as % de aceitáveis, falhas e duplas.
class AvaliacaoRapidaPage extends StatefulWidget {
  const AvaliacaoRapidaPage({super.key});

  @override
  State<AvaliacaoRapidaPage> createState() => _AvaliacaoRapidaPageState();
}

class _AvaliacaoRapidaPageState extends State<AvaliacaoRapidaPage> {
  final _sementes = TextEditingController();
  final _leitura = TextEditingController();
  final _foco = FocusNode();
  final _leituras = <double>[];
  String? _erro;

  double? get _sementesPorMetro {
    final v = lerNumero(_sementes.text);
    return v != null && v > 0 ? v : null;
  }

  @override
  void dispose() {
    _sementes.dispose();
    _leitura.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _adicionar() {
    final valor = lerNumero(_leitura.text);
    final ultima = _leituras.isEmpty ? 0.0 : _leituras.last;
    setState(() {
      if (valor == null) {
        _erro = 'Informe a leitura em cm.';
      } else if (valor <= ultima) {
        _erro = 'A leitura deve ser maior que ${numeroBr(ultima)} cm.';
      } else {
        _erro = null;
        _leituras.add(valor);
        _leitura.clear();
      }
    });
    _foco.requestFocus();
  }

  void _desfazer() {
    if (_leituras.isEmpty) return;
    setState(() => _leituras.removeLast());
  }

  void _limpar() {
    setState(() {
      _leituras.clear();
      _leitura.clear();
      _erro = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sementes = _sementesPorMetro;
    final r = ResultadoRapido.calcular(_leituras, sementesPorMetro: sementes);
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoFluxo(titulo: 'Avaliação rápida'),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  children: [
                    TextField(
                      controller: _sementes,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Sementes por metro',
                        helperText: sementes == null
                            ? 'Necessário para separar aceitáveis, falhas e duplas'
                            : 'Espaçamento ideal: ${numeroBr(100 / sementes)} cm',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PainelResultado(resultado: r),
                    const SizedBox(height: 14),
                    _Entrada(
                      leitura: _leitura,
                      foco: _foco,
                      erro: _erro,
                      proxima: _leituras.isEmpty ? 0 : _leituras.last,
                      aoAdicionar: _adicionar,
                    ),
                    if (r.n > 0) ...[
                      const SizedBox(height: 12),
                      _Espacamentos(resultado: r),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: [
                          TextButton.icon(
                            onPressed: _desfazer,
                            icon: const Icon(Icons.undo, size: 18),
                            label: const Text('Remover última leitura'),
                            style: TextButton.styleFrom(
                              foregroundColor: Cores.verdeTexto,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _limpar,
                            icon: const Icon(Icons.restart_alt, size: 18),
                            label: const Text('Nova linha'),
                            style: TextButton.styleFrom(
                              foregroundColor: Cores.verdeTexto,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Text(
                      'Estique a trena com o zero na primeira planta e digite a '
                      'posição de cada planta seguinte. Nada fica salvo. Para '
                      'várias linhas, perda em sacas e relatório, use a '
                      'avaliação de plantio completa.',
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

class _PainelResultado extends StatelessWidget {
  final ResultadoRapido resultado;

  const _PainelResultado({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final r = resultado;
    String pct(double? v) => v == null ? '–' : percentual(v, 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Cores.verdeEscuro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                r.cvPercentual == null ? '–' : percentual(r.cvPercentual!, 1),
                style: const TextStyle(
                  fontFamily: fonteTitulo,
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: Cores.branco,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    r.cvPercentual == null
                        ? 'CV dos espaçamentos · informe ao menos 2 leituras'
                        : 'CV dos espaçamentos · ${r.n} espaçamentos',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFD3EBD0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Taxa(
                  rotulo: 'Aceitáveis',
                  valor: pct(r.aceitaveis),
                  cor: Cores.verdeVivo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Taxa(
                  rotulo: 'Falhas',
                  valor: pct(r.falhas),
                  cor: const Color(0xFFFFB38A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Taxa(
                  rotulo: 'Duplas',
                  valor: pct(r.duplas),
                  cor: const Color(0xFFA9C1FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Taxa extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color cor;

  const _Taxa({required this.rotulo, required this.valor, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x2EFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontFamily: fonteTitulo,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Cores.branco,
            ),
          ),
        ],
      ),
    );
  }
}

class _Entrada extends StatelessWidget {
  final TextEditingController leitura;
  final FocusNode foco;
  final String? erro;
  final double proxima;
  final VoidCallback aoAdicionar;

  const _Entrada({
    required this.leitura,
    required this.foco,
    required this.erro,
    required this.proxima,
    required this.aoAdicionar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: leitura,
            focusNode: foco,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => aoAdicionar(),
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Leitura da trena (cm)',
              hintText: 'maior que ${numeroBr(proxima)}',
              errorText: erro,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: aoAdicionar,
          style: FilledButton.styleFrom(minimumSize: const Size(96, 56)),
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

/// Espaçamentos medidos, do mais recente ao mais antigo; coloridos quando há
/// sementes por metro para classificar.
class _Espacamentos extends StatelessWidget {
  final ResultadoRapido resultado;

  const _Espacamentos({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final classes = resultado.classificados;
    final itens = <(double, ClasseEspacamento?)>[
      for (var i = 0; i < resultado.n; i++)
        (resultado.espacamentosCm[i], classes?[i].classe),
    ].reversed.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (valor, classe) in itens)
              _Chip(valor: valor, classe: classe),
          ],
        ),
        if (classes != null) ...[
          const SizedBox(height: 8),
          const Wrap(
            spacing: 12,
            children: [
              _Legenda(cor: Cores.verde, texto: 'aceitável'),
              _Legenda(cor: Cores.falha, texto: 'falha'),
              _Legenda(cor: Cores.dupla, texto: 'dupla'),
            ],
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final double valor;
  final ClasseEspacamento? classe;

  const _Chip({required this.valor, required this.classe});

  @override
  Widget build(BuildContext context) {
    final (fundo, texto, nome) = switch (classe) {
      ClasseEspacamento.aceitavel => (
        Cores.verdeClaro,
        Cores.verdeTexto,
        ', aceitável',
      ),
      ClasseEspacamento.falha => (Cores.falha, Cores.branco, ', falha'),
      ClasseEspacamento.dupla => (Cores.dupla, Cores.branco, ', dupla'),
      null => (Cores.neutro, Cores.tinta, ''),
    };
    return Semantics(
      label: '${numeroBr(valor)} centímetros$nome',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minWidth: 46),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: fundo,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            numeroBr(valor),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: texto,
            ),
          ),
        ),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  final Color cor;
  final String texto;

  const _Legenda({required this.cor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(fontSize: 13, color: Cores.textoSecundario),
        ),
      ],
    );
  }
}
