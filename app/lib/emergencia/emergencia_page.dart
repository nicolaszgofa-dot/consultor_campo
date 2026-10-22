import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

import '../avaliacao/avaliacao_estado.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'avaliacao_emergencia.dart';

/// Cor da bandeira de cada dia de emergência (dia 1, 2, 3, 4 ou mais).
Color corDoDia(int dia) => switch (dia) {
  <= 1 => Cores.verde,
  2 => Cores.dupla,
  3 => Cores.atencao,
  _ => Cores.prejuizo,
};

Color textoDoDia(int dia) => dia <= 1 ? Cores.verdeEscuro : Cores.branco;

String nomeDoDia(int dia) => dia >= 4 ? 'Dia 4+' : 'Dia $dia';

class EmergenciaPage extends StatefulWidget {
  final RepositorioEmergencia repositorio;
  final AvaliacaoEmergencia avaliacao;

  const EmergenciaPage({
    super.key,
    required this.repositorio,
    required this.avaliacao,
  });

  @override
  State<EmergenciaPage> createState() => _EmergenciaPageState();
}

class _EmergenciaPageState extends State<EmergenciaPage> {
  late AvaliacaoEmergencia _avaliacao = widget.avaliacao;
  final _data = TextEditingController(text: dataBr(DateTime.now()));
  late List<int> _novas;
  String? _erroData;

  @override
  void initState() {
    super.initState();
    _carregarDia();
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  DateTime? get _dataEscolhida => lerData(_data.text);

  /// Mostra os números já salvos da data escolhida, ou zeros.
  void _carregarDia() {
    final d = _dataEscolhida;
    final salvo = d == null ? null : _avaliacao.registroDe(d);
    _novas = salvo == null
        ? List.filled(_avaliacao.linhas, 0)
        : [
            for (var i = 0; i < _avaliacao.linhas; i++)
              i < salvo.novasPorLinha.length ? salvo.novasPorLinha[i] : 0,
          ];
  }

  String? _validarData(DateTime? d) {
    if (d == null) return 'Use dd/mm/aaaa';
    if (d.isBefore(_avaliacao.dataPlantio)) return 'Antes do plantio';
    if (d.isAfter(DateTime.now())) return 'Data futura';
    return null;
  }

  Future<void> _salvar() async {
    final d = _dataEscolhida;
    final erro = _validarData(d);
    setState(() => _erroData = erro);
    if (erro != null) return;
    final nova = _avaliacao.comRegistro(
      RegistroEmergencia(data: d!, novasPorLinha: List.of(_novas)),
    );
    await widget.repositorio.salvar(nova);
    if (!mounted) return;
    setState(() => _avaliacao = nova);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Marcação de ${dataBr(d)} salva')));
  }

  /// Dia de emergência que a data escolhida representa.
  int _diaDaData(ResultadoEmergencia r, DateTime d) {
    final primeiro = r.dapPrimeiraEmergencia;
    final dap = EmergenciaCalc.dap(_avaliacao.dataPlantio, d);
    if (primeiro == null || dap < primeiro) return 1;
    return dap - primeiro + 1;
  }

  @override
  Widget build(BuildContext context) {
    final a = _avaliacao;
    final r = a.resultado;
    final d = _dataEscolhida;
    final dap = d == null ? null : EmergenciaCalc.dap(a.dataPlantio, d);
    final diaAtual = d == null ? 1 : _diaDaData(r, d);
    final totalDia = _novas.fold(0, (s, n) => s + n);

    return TelaFluxo(
      titulo: a.talhao.isEmpty ? 'Emergência' : 'Emergência · ${a.talhao}',
      filhos: [
        Text(
          '${nomeCultura(a.cultura)} · plantio em ${dataBr(a.dataPlantio)} · '
          '${a.linhas} linhas de ${numeroBr(a.comprimentoLinhaM, a.comprimentoLinhaM % 1 == 0 ? 0 : 1)} m · '
          '${numeroBr(a.parametros.plantasEsperadas, 0)} sementes',
          style: const TextStyle(fontSize: 14, color: Cores.textoSecundario),
        ),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Marcação do dia',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _data,
                      decoration: InputDecoration(
                        labelText: 'Data',
                        errorText: _erroData,
                      ),
                      onChanged: (_) => setState(() {
                        _erroData = null;
                        _carregarDia();
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dap == null ? '–' : '$dap DAP',
                        style: const TextStyle(
                          fontFamily: fonteTitulo,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _Bandeira(dia: diaAtual),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Conte só as plantas que apareceram desde a última marcação.',
                style: TextStyle(fontSize: 13, color: Cores.textoSecundario),
              ),
              const SizedBox(height: 4),
              for (var i = 0; i < a.linhas; i++)
                _ContadorLinha(
                  linha: i + 1,
                  valor: _novas[i],
                  cor: corDoDia(diaAtual),
                  aoMudar: (v) => setState(() => _novas[i] = v),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _salvar,
                child: Text('Salvar marcação ($totalDia plantas novas)'),
              ),
            ],
          ),
        ),
        if (a.registros.isNotEmpty) _Historico(avaliacao: a, resultado: r),
        if (r.emergidas > 0) _Resultado(resultado: r),
      ],
    );
  }
}

class _Bandeira extends StatelessWidget {
  final int dia;

  const _Bandeira({required this.dia});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: corDoDia(dia),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        nomeDoDia(dia),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textoDoDia(dia),
        ),
      ),
    );
  }
}

class _ContadorLinha extends StatelessWidget {
  final int linha;
  final int valor;
  final Color cor;
  final ValueChanged<int> aoMudar;

  const _ContadorLinha({
    required this.linha,
    required this.valor,
    required this.cor,
    required this.aoMudar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Linha $linha',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          _BotaoContador(
            icone: Icons.remove,
            rotulo: 'Menos uma planta na linha $linha',
            cor: cor,
            cheio: false,
            aoTocar: valor > 0 ? () => aoMudar(valor - 1) : null,
          ),
          SizedBox(
            width: 52,
            child: Text(
              '$valor',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: fonteTitulo,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _BotaoContador(
            icone: Icons.add,
            rotulo: 'Mais uma planta na linha $linha',
            cor: cor,
            cheio: true,
            aoTocar: () => aoMudar(valor + 1),
          ),
        ],
      ),
    );
  }
}

class _BotaoContador extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final Color cor;
  final bool cheio;
  final VoidCallback? aoTocar;

  const _BotaoContador({
    required this.icone,
    required this.rotulo,
    required this.cor,
    required this.cheio,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final ativo = aoTocar != null;
    final fundo = cheio ? cor : Cores.branco;
    final frente = cheio
        ? (cor == Cores.verde ? Cores.verdeEscuro : Cores.branco)
        : cor;
    return SizedBox(
      width: 52,
      height: 52,
      child: Material(
        color: ativo ? fundo : Cores.neutro,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: ativo ? cor : Cores.borda, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: aoTocar,
          child: Icon(
            icone,
            color: ativo ? frente : Cores.cinza,
            semanticLabel: rotulo,
          ),
        ),
      ),
    );
  }
}

class _Historico extends StatelessWidget {
  final AvaliacaoEmergencia avaliacao;
  final ResultadoEmergencia resultado;

  const _Historico({required this.avaliacao, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final primeiro = resultado.dapPrimeiraEmergencia;
    return CartaoBranco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RotuloSecao('Marcações'),
          const SizedBox(height: 6),
          for (final reg in avaliacao.registros)
            Builder(
              builder: (context) {
                final dap = EmergenciaCalc.dap(avaliacao.dataPlantio, reg.data);
                final dia = primeiro == null || dap < primeiro
                    ? null
                    : dap - primeiro + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${dataBr(reg.data)} · $dap DAP',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      if (reg.total > 0 && dia != null) ...[
                        _Bandeira(dia: dia),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        reg.total == 0 ? 'sem plantas' : '+${reg.total}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Resultado extends StatelessWidget {
  final ResultadoEmergencia resultado;

  const _Resultado({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final r = resultado;
    final dia1 = r.percentualNoDia(1);
    final tardia = r.linhaMaisTardia();
    final perda = r.perdaPotencialPercentual;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                percentual(dia1),
                style: TextStyle(
                  fontFamily: fonteTitulo,
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: corDoPercentual(dia1),
                ),
              ),
              const Text(
                'das plantas emergiram no 1º dia',
                style: TextStyle(fontSize: 14, color: Cores.textoSecundario),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  height: 14,
                  child: Row(
                    children: [
                      for (var dia = 1; dia <= 4; dia++)
                        if (r.plantasNoDia(dia) > 0)
                          Expanded(
                            flex: r.plantasNoDia(dia),
                            child: ColoredBox(color: corDoDia(dia)),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var dia = 1; dia <= 4; dia++)
                    Expanded(
                      child: Indicador(
                        rotulo: nomeDoDia(dia),
                        valor:
                            '${r.plantasNoDia(dia)} · '
                            '${percentual(r.percentualNoDia(dia), 0)}',
                        corRotulo: dia == 1 ? Cores.verdeTexto : corDoDia(dia),
                      ),
                    ),
                ],
              ),
              const Divider(height: 24, color: Cores.neutro),
              Text(
                'Emergidas: ${r.emergidas} de '
                '${numeroBr(r.parametros.plantasEsperadas, 0)} sementes '
                '(${percentual(r.percentualEmergencia)})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RotuloSecao('Plantas do 1º dia por linha'),
              const SizedBox(height: 8),
              for (var i = 0; i < r.emergidasPorLinha.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          'L${i + 1}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: (r.percentualDia1NaLinha(i) / 100)
                                .clamp(0, 1)
                                .toDouble(),
                            minHeight: 10,
                            color: corDoPercentual(r.percentualDia1NaLinha(i)),
                            backgroundColor: Cores.neutro,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          r.emergidasPorLinha[i] == 0
                              ? '–'
                              : percentual(r.percentualDia1NaLinha(i)),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (tardia != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF0E7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Linha ${tardia + 1} tem mais plantas tardias que as '
                    'outras: conferir a força na linha (downforce). O LoadPin '
                    'mede e o Level corrige a pressão linha a linha.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (perda != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Cores.prejuizo,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Redução estimada do potencial produtivo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFE4E0),
                  ),
                ),
                Text(
                  percentual(perda),
                  style: const TextStyle(
                    fontFamily: fonteTitulo,
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: Cores.branco,
                  ),
                ),
                const Text(
                  'Por planta atrasada: 35% com 1 dia, 60% com 2 dias e 85% '
                  'com 3 dias ou mais em relação às primeiras.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFFFE4E0)),
                ),
              ],
            ),
          )
        else
          const CartaoBranco(
            child: Text(
              'Ainda sem coeficiente de perda por atraso para esta cultura. '
              'Acompanhe o % de plantas emergidas no 1º dia.',
              style: TextStyle(fontSize: 14, color: Cores.textoSecundario),
            ),
          ),
      ],
    );
  }
}
