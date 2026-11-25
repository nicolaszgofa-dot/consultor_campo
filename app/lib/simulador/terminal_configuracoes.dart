part of 'terminal_eletric.dart';

// Telas de configuração do terminal, desenhadas a partir das capturas do
// treinamento da Linha Elétric (fundo cinza claro, campos brancos).

const _cinzaClaro = Color(0xFFCCCCCC);
const _verdeSelecao = Color(0xFFA5F07A);
const _travado = Color(0xFF8A8A8A);

final _rot = _mono.copyWith(fontSize: 14, color: Colors.black);

/// Número com vírgula, como nas telas de configuração.
String _v(double v, int casas) => v.toStringAsFixed(casas).replaceAll('.', ',');

extension on TelaConfig {
  ParteTerminal get parte => switch (this) {
    TelaConfig.sistema => ParteTerminal.cfgSistema,
    TelaConfig.dosagem => ParteTerminal.cfgDosagem,
    TelaConfig.implemento => ParteTerminal.cfgImplemento,
    TelaConfig.filtro => ParteTerminal.cfgFiltro,
    TelaConfig.fonteVelocidade => ParteTerminal.cfgFonteVelocidade,
    TelaConfig.enderecamento => ParteTerminal.cfgEnderecamento,
    TelaConfig.energia => ParteTerminal.cfgEnergia,
    TelaConfig.levante => ParteTerminal.cfgLevante,
  };

  IconData get icone => switch (this) {
    TelaConfig.sistema => Icons.settings,
    TelaConfig.dosagem => Icons.grain,
    TelaConfig.implemento => Icons.agriculture,
    TelaConfig.filtro => Icons.filter_alt,
    TelaConfig.fonteVelocidade => Icons.speed,
    TelaConfig.enderecamento => Icons.wifi_tethering,
    TelaConfig.energia => Icons.battery_charging_full,
    TelaConfig.levante => Icons.height,
  };
}

/// Campo numérico editável de uma tela de configuração.
class _Campo {
  final String id;
  final String rotulo;
  final String unidade;
  final String prefixo;
  final int casas;
  final double passo;
  final double minimo;
  final double maximo;

  /// Parâmetro de engenharia: só com o cadeado aberto.
  final bool restrito;
  final double Function(TerminalEstado) ler;
  final void Function(TerminalEstado, double) gravar;

  const _Campo(
    this.id,
    this.rotulo, {
    required this.ler,
    required this.gravar,
    required this.passo,
    required this.minimo,
    required this.maximo,
    this.casas = 0,
    this.unidade = '',
    this.prefixo = '',
    this.restrito = false,
  });

  void mudar(TerminalEstado e, int sinal) {
    final novo = (ler(e) + passo * sinal).clamp(minimo, maximo);
    e.mudar(() => gravar(e, double.parse(novo.toStringAsFixed(casas))));
  }
}

final _camposSistema = [
  _Campo(
    'secoes',
    'Maximo de secoes do monitor',
    passo: 1,
    minimo: 1,
    maximo: 255,
    ler: (e) => e.maximoSecoesMonitor.toDouble(),
    gravar: (e, v) => e.maximoSecoesMonitor = v.round(),
  ),
];

final _camposDosagem = [
  _Campo(
    'furos',
    'Numero de furos no disco',
    passo: 1,
    minimo: 4,
    maximo: 120,
    ler: (e) => e.furosDisco.toDouble(),
    gravar: (e, v) => e.furosDisco = v.round(),
  ),
  _Campo(
    'falhas',
    'Maximo de Falhas',
    unidade: '(%)',
    casas: 1,
    passo: 0.5,
    minimo: 0,
    maximo: 50,
    ler: (e) => e.maximoFalhas,
    gravar: (e, v) => e.maximoFalhas = v,
  ),
  _Campo(
    'duplos',
    'Maximo de Duplos',
    unidade: '(%)',
    casas: 1,
    passo: 0.5,
    minimo: 0,
    maximo: 50,
    ler: (e) => e.maximoDuplos,
    gravar: (e, v) => e.maximoDuplos = v,
  ),
  _Campo(
    'popMax',
    'Populacao Maxima',
    prefixo: '+',
    unidade: '(%)',
    passo: 1,
    minimo: 0,
    maximo: 100,
    ler: (e) => e.populacaoMaximaPct,
    gravar: (e, v) => e.populacaoMaximaPct = v,
  ),
  _Campo(
    'popMin',
    'Populacao Minima',
    prefixo: '−',
    unidade: '(%)',
    passo: 1,
    minimo: 0,
    maximo: 100,
    ler: (e) => e.populacaoMinimaPct,
    gravar: (e, v) => e.populacaoMinimaPct = v,
  ),
  _Campo(
    'distribuicao',
    'Distribuicao Minima',
    unidade: '(%)',
    casas: 1,
    passo: 0.5,
    minimo: 0,
    maximo: 100,
    ler: (e) => e.distribuicaoMinima,
    gravar: (e, v) => e.distribuicaoMinima = v,
  ),
  _Campo(
    'cv',
    'CV Maximo',
    unidade: '(%)',
    passo: 1,
    minimo: 0,
    maximo: 100,
    ler: (e) => e.cvMaximo,
    gravar: (e, v) => e.cvMaximo = v,
  ),
  _Campo(
    'distancia',
    'Distancia de medidas',
    unidade: '(m)',
    passo: 10,
    minimo: 10,
    maximo: 1000,
    ler: (e) => e.distanciaMedidasM,
    gravar: (e, v) => e.distanciaMedidasM = v,
  ),
  _Campo(
    'ajuste',
    'Ajuste de Populacao',
    casas: 2,
    passo: 0.01,
    minimo: 0.5,
    maximo: 2,
    ler: (e) => e.ajustePopulacao,
    gravar: (e, v) => e.ajustePopulacao = v,
  ),
  _Campo(
    'singulacao',
    'Singulacao Critica',
    unidade: '(%)',
    restrito: true,
    passo: 1,
    minimo: 0,
    maximo: 100,
    ler: (e) => e.singulacaoCritica,
    gravar: (e, v) => e.singulacaoCritica = v,
  ),
  _Campo(
    'sujeira',
    'Porcentagem Sujeira',
    unidade: '(%)',
    restrito: true,
    passo: 1,
    minimo: 0,
    maximo: 100,
    ler: (e) => e.porcentagemSujeira,
    gravar: (e, v) => e.porcentagemSujeira = v,
  ),
];

final _camposImplemento = [
  _Campo(
    'linhas',
    'Numero de Linhas',
    passo: 1,
    minimo: 1,
    maximo: 60,
    ler: (e) => e.numeroLinhas.toDouble(),
    gravar: (e, v) => e.mudarNumeroLinhas(v.round()),
  ),
  _Campo(
    'espacamento',
    'Distancia Entre Linhas',
    unidade: 'm',
    casas: 2,
    passo: 0.05,
    minimo: 0.15,
    maximo: 1.5,
    ler: (e) => e.espacamentoLinhasM,
    gravar: (e, v) => e.espacamentoLinhasM = v,
  ),
  _Campo(
    'engate',
    'D. Engate-Roda',
    unidade: 'm',
    casas: 2,
    passo: 0.05,
    minimo: 0,
    maximo: 15,
    ler: (e) => e.engateRodaM,
    gravar: (e, v) => e.engateRodaM = v,
  ),
  _Campo(
    'saidaCurta',
    'Roda-Saida Curta',
    unidade: 'm',
    casas: 2,
    passo: 0.05,
    minimo: 0,
    maximo: 15,
    ler: (e) => e.rodaSaidaCurtaM,
    gravar: (e, v) => e.rodaSaidaCurtaM = v,
  ),
  _Campo(
    'saidaLonga',
    'Roda-Saida Longa',
    unidade: 'm',
    casas: 2,
    passo: 0.05,
    minimo: 0,
    maximo: 15,
    ler: (e) => e.rodaSaidaLongaM,
    gravar: (e, v) => e.rodaSaidaLongaM = v,
  ),
  _Campo(
    'linhaCurta',
    'Numero Linha Curta',
    passo: 1,
    minimo: 0,
    maximo: 60,
    ler: (e) => e.numeroLinhaCurta.toDouble(),
    gravar: (e, v) => e.numeroLinhaCurta = v.round().clamp(0, e.numeroLinhas),
  ),
];

final _camposFiltro = [
  _Campo(
    'tPartida',
    'Tempo de Partida (segundos)',
    casas: 1,
    passo: 0.1,
    minimo: 0,
    maximo: 5,
    ler: (e) => e.tempoPartidaS,
    gravar: (e, v) => e.tempoPartidaS = v,
  ),
  _Campo(
    'vPartida',
    'Velocidade de Partida(km/h)',
    casas: 1,
    passo: 0.1,
    minimo: 0,
    maximo: 10,
    ler: (e) => e.velocidadePartidaKmh,
    gravar: (e, v) => e.velocidadePartidaKmh = v,
  ),
  _Campo(
    'tParada',
    'Tempo de Parada (segundos)',
    casas: 1,
    passo: 0.1,
    minimo: 0,
    maximo: 5,
    ler: (e) => e.tempoParadaS,
    gravar: (e, v) => e.tempoParadaS = v,
  ),
  _Campo(
    'vParada',
    'Velocidade de Parada (km/h)',
    casas: 1,
    passo: 0.1,
    minimo: 0,
    maximo: 10,
    ler: (e) => e.velocidadeParadaKmh,
    gravar: (e, v) => e.velocidadeParadaKmh = v,
  ),
];

final _campoDop = _Campo(
  'dop',
  'Valor maximo de DOP',
  passo: 1,
  minimo: 1,
  maximo: 99,
  ler: (e) => e.dopMaximo,
  gravar: (e, v) => e.dopMaximo = v,
);

final _campoVelocidadeManual = _Campo(
  'velocidade',
  'Velocidade',
  unidade: 'Km/h',
  casas: 1,
  passo: 0.5,
  minimo: 0,
  maximo: 20,
  ler: (e) => e.velocidadeKmh,
  gravar: (e, v) => e.velocidadeKmh = v,
);

final _campoRadar = _Campo(
  'radar',
  'Constante de Ajuste',
  casas: 4,
  passo: 0.001,
  minimo: 0,
  maximo: 10,
  ler: (e) => e.constanteRadar,
  gravar: (e, v) => e.constanteRadar = v,
);

final _camposEnergia = [
  _Campo(
    'rotMin',
    'Rotacao Minima (RPM)',
    passo: 100,
    minimo: 500,
    maximo: 9000,
    ler: (e) => e.rotacaoMinima.toDouble(),
    gravar: (e, v) => e.rotacaoMinima = v.round(),
  ),
  _Campo(
    'rotMax',
    'Rotacao Maxima (RPM)',
    passo: 100,
    minimo: 500,
    maximo: 9000,
    ler: (e) => e.rotacaoMaxima.toDouble(),
    gravar: (e, v) => e.rotacaoMaxima = v.round(),
  ),
];

final _campoLinhaEndereco = _Campo(
  'linhaEndereco',
  'Linha',
  passo: 1,
  minimo: 1,
  maximo: 60,
  ler: (e) => e.linhaEndereco + 1.0,
  gravar: (e, v) {
    e.linhaEndereco = (v.round() - 1).clamp(0, e.numeroLinhas - 1);
    e.enderecoLido = null;
  },
);

final _todosCampos = {
  for (final c in [
    ..._camposSistema,
    ..._camposDosagem,
    ..._camposImplemento,
    ..._camposFiltro,
    ..._camposEnergia,
    _campoDop,
    _campoVelocidadeManual,
    _campoRadar,
    _campoLinhaEndereco,
  ])
    c.id: c,
};

/// Menu e telas de configuração (ocupam a metade esquerda do terminal).
class _TelaConfig extends StatelessWidget {
  final TerminalEstado e;
  final bool explicando;
  final ValueChanged<ParteTerminal> aoExplicar;

  const _TelaConfig({
    required this.e,
    required this.explicando,
    required this.aoExplicar,
  });

  /// No modo explicação, a área inteira explica a tela em vez de agir.
  Widget _explicavel(ParteTerminal parte, Widget filho) {
    if (!explicando) return filho;
    return Semantics(
      button: true,
      label: parte.titulo,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => aoExplicar(parte),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AbsorbPointer(child: filho),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _T.destaque.withValues(alpha: 0.10),
                  border: Border.all(color: _T.destaque, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = e.config;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 72,
          color: _T.fundo,
          padding: const EdgeInsets.only(left: 22),
          child: Row(
            children: [
              if (c != null) ...[
                Semantics(
                  button: true,
                  label: 'Voltar ao menu de configurações',
                  child: GestureDetector(
                    onTap: e.voltarConfig,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: c == TelaConfig.dosagem
                            ? const Color(0xFF2E9E3E)
                            : const Color(0xFF4A4A4A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: _T.texto,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                c == TelaConfig.dosagem ? 'Dosagem' : 'Configuracoes',
                style: _mono.copyWith(
                  fontSize: 20,
                  color: const Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: c == null
              ? _menu()
              : _explicavel(
                  c.parte,
                  Stack(
                    children: [
                      Positioned.fill(
                        child: ColoredBox(
                          color: _cinzaClaro,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 14, 16, 10),
                            child: _conteudo(c),
                          ),
                        ),
                      ),
                      if (e.campoEditando != null) _editor(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _menu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in TelaConfig.values)
          Semantics(
            button: true,
            label: c.titulo,
            child: GestureDetector(
              onTap: explicando
                  ? () => aoExplicar(c.parte)
                  : () => e.abrirConfig(c),
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: _cinzaClaro,
                  border: explicando
                      ? Border.all(color: _T.destaque, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(c.icone, size: 24, color: const Color(0xFF444444)),
                    const SizedBox(width: 20),
                    Text(c.titulo, style: _rot),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _conteudo(TelaConfig c) => switch (c) {
    TelaConfig.sistema => _sistema(),
    TelaConfig.dosagem => _lista(_camposDosagem, 280, altura: 33),
    TelaConfig.implemento => _implemento(),
    TelaConfig.filtro => _filtro(),
    TelaConfig.fonteVelocidade => _fonteVelocidade(),
    TelaConfig.enderecamento => _enderecamento(),
    TelaConfig.energia => _energia(),
    TelaConfig.levante => _levante(),
  };

  Widget _titulo(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(t, style: _rot.copyWith(fontSize: 19)),
  );

  Widget _texto(String t) =>
      Text(t, style: _rot.copyWith(fontSize: 13, height: 1.25));

  Widget _campo(_Campo c, double larguraRotulo, {double altura = 32}) =>
      _LinhaCampo(e: e, c: c, larguraRotulo: larguraRotulo, altura: altura);

  Widget _lista(
    List<_Campo> campos,
    double larguraRotulo, {
    double altura = 32,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final c in campos) _campo(c, larguraRotulo, altura: altura),
    ],
  );

  Widget _caixa(
    String rotulo,
    bool marcada,
    VoidCallback alternar, {
    String? descricao,
  }) {
    return Semantics(
      button: true,
      checked: marcada,
      label: descricao ?? rotulo,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => e.mudar(alternar),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(rotulo, style: _rot),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  border: Border.all(color: const Color(0xFF555555)),
                ),
                child: marcada
                    ? const Icon(Icons.check, size: 24, color: Colors.black)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Seletor verde (lista de opções), como Fonte de Velocidade e Energia.
  Widget _seletor(String id, String valor, String rotulo) {
    return Semantics(
      button: true,
      label: rotulo,
      child: GestureDetector(
        onTap: () => e.editarCampo(id),
        child: Row(
          children: [
            Container(
              width: 176,
              height: 26,
              color: const Color(0xFF99FF99),
              padding: const EdgeInsets.only(left: 2),
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: _rot.copyWith(
                  fontSize: 17,
                  color: const Color(0xFF1B7A1B),
                ),
              ),
            ),
            Container(
              width: 64,
              height: 26,
              color: const Color(0xFF9CCC9C),
              child: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sistema() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _titulo('Sistema'),
      const SizedBox(height: 10),
      _texto('Versao: 01.54\nHardware: G'),
      Row(
        children: [
          _texto('ID:'),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _texto('12345678'),
          ),
        ],
      ),
      const Spacer(),
      _texto('Ajustes de Compatibilidade'),
      const SizedBox(height: 10),
      _caixa(
        'Taxa Variavel GS3:',
        e.taxaVariavelGs3,
        () => e.taxaVariavelGs3 = !e.taxaVariavelGs3,
        descricao: 'Taxa Variavel GS3',
      ),
      const SizedBox(height: 4),
      _campo(_camposSistema.single, 260),
      const SizedBox(height: 40),
    ],
  );

  Widget _implemento() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _titulo('Implemento'),
      const SizedBox(height: 6),
      _lista(_camposImplemento, 270),
      const SizedBox(height: 14),
      _caixa('Titanium', e.titanium, () => e.titanium = !e.titanium),
    ],
  );

  Widget _filtro() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _titulo('Filtro de Dinamica'),
      _lista(_camposFiltro, 290),
      _caixa(
        'Habilitar:',
        e.filtroHabilitado,
        () => e.filtroHabilitado = !e.filtroHabilitado,
        descricao: 'Habilitar filtro de dinamica',
      ),
    ],
  );

  Widget _fonteVelocidade() {
    final f = e.fonteVelocidade;
    final sem = e.semSinalGps && f.gps;
    final vel = sem ? '0.00' : e.velocidadeKmh.toStringAsFixed(2);
    final agora = DateTime.now();
    String d(int n) => n.toString().padLeft(2, '0');
    final dataHora =
        '${d(agora.day)}/${d(agora.month)}/${agora.year} '
        '${d(agora.hour)}:${d(agora.minute)}:${d(agora.second)}';
    final largura = e.numeroLinhas * e.espacamentoLinhasM;
    final km = (e.hectares * 10 / largura).toStringAsFixed(1);
    final detalhes = switch (f) {
      FonteVelocidade.gpsEcu => [
        _campo(_campoDop, 180),
        const SizedBox(height: 8),
        _texto(
          'Dia/Hora: $dataHora (0.9Hz)\n\n'
          'Latitude: ${sem ? '0.000000' : '-25.095000'} (10.0Hz)\n'
          'Longitude: ${sem ? '0.000000' : '-50.162000'}\n'
          'Altitude: ${sem ? '0.0' : '975.0'}\n'
          'HDOP:${sem ? '99.99' : '0.80'} - '
          'VDOP:${sem ? '99.99' : '1.10'} (1.0Hz)\n'
          'Satelites: ${sem ? 0 : 14}\n\n'
          'Velocidade: $vel km/h (10.0Hz)\n'
          'Direcao: ${sem ? '0.0' : '87.0'} Graus\n\n'
          'Odometro Parcial: $km km (0.9Hz)\n'
          'Total: $km km',
        ),
      ],
      FonteVelocidade.gpsIsobus => [
        _texto(
          'Dia/Hora: ${sem ? '0/0/0  0:0:0' : dataHora}\n\n'
          'Latitude:  ${sem ? '0.00000' : '-25.09500'} Graus\n'
          'Longitude: ${sem ? '0.00000' : '-50.16200'} Graus\n'
          'Velocidade: $vel km/h',
        ),
      ],
      FonteVelocidade.manual => [_campo(_campoVelocidadeManual, 110)],
      FonteVelocidade.radar => [
        _campo(_campoRadar, 190),
        const SizedBox(height: 6),
        _texto(
          'Frequencia Lida: Hz\n'
          'Proporcao configurada: Km/h\n'
          'Velocidade: $vel Km/h',
        ),
      ],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('Fonte de velocidade'),
        const SizedBox(height: 10),
        _seletor('fonte', f.nome, 'Escolher a fonte de velocidade'),
        const SizedBox(height: 14),
        ...detalhes,
      ],
    );
  }

  Widget _enderecamento() {
    Widget botao(String t, VoidCallback a, {bool aceso = false}) => Semantics(
      button: true,
      label: t,
      child: GestureDetector(
        onTap: a,
        child: Container(
          width: 140,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: aceso ? const Color(0xFFA5D6A7) : const Color(0xFFDDDDDD),
            border: Border.all(
              color: aceso ? const Color(0xFF2E9E3E) : const Color(0xFF555555),
              width: aceso ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(t, style: _rot.copyWith(fontSize: 13)),
        ),
      ),
    );
    final lido = e.enderecoLido;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('Enderecamento'),
        _campo(_campoLinhaEndereco, 110),
        Row(
          children: [
            SizedBox(width: 110, child: Text('Endereco:', style: _rot)),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(e.endereco(e.linhaEndereco), style: _rot),
            ),
          ],
        ),
        const Spacer(),
        if (e.lendoEndereco) ...[
          Text('Lendo ..', style: _rot),
          const SizedBox(height: 10),
          Text('Contagem: ${e.contagemLeitura}', style: _rot),
          const SizedBox(height: 10),
          botao('Encostar o ima', e.encostarIma),
        ] else if (lido != null) ...[
          Text('Endereco: $lido', style: _rot),
          const SizedBox(height: 10),
          Text('Linha: ${e.linhaEndereco + 1}', style: _rot),
        ],
        const Spacer(),
        Row(
          children: [
            botao('Ler', e.lerEndereco, aceso: e.lendoEndereco),
            const Spacer(),
            if (e.lendoEndereco)
              botao('Cancelar', e.cancelarLeitura)
            else
              botao('Gravar', e.gravarEndereco),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _energia() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _titulo('Energia'),
      const SizedBox(height: 16),
      _seletor('energia', e.energia.nome, 'Escolher a fonte de energia'),
      const SizedBox(height: 40),
      if (e.energia == FonteEnergia.alternador) _lista(_camposEnergia, 250),
    ],
  );

  Widget _levante() {
    String estado(bool habilitado) => !habilitado
        ? 'Desabilitado'
        : e.plantando
        ? 'Plantando'
        : 'Manobra';
    Widget par(int n, bool hab, bool inv, VoidCallback h, VoidCallback i) =>
        Row(
          children: [
            _caixa('Habilitar', hab, h, descricao: 'Habilitar sensor $n'),
            const SizedBox(width: 22),
            _caixa(
              'Inverter Logica',
              inv,
              i,
              descricao: 'Inverter logica do sensor $n',
            ),
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('Sensor de Levante'),
        Text('Sensor 1: ${estado(e.sensor1Habilitado)}', style: _rot),
        par(
          1,
          e.sensor1Habilitado,
          e.sensor1Invertido,
          () => e.sensor1Habilitado = !e.sensor1Habilitado,
          () => e.sensor1Invertido = !e.sensor1Invertido,
        ),
        const SizedBox(height: 6),
        Text('Sensor 2: ${estado(e.sensor2Habilitado)}', style: _rot),
        par(
          2,
          e.sensor2Habilitado,
          e.sensor2Invertido,
          () => e.sensor2Habilitado = !e.sensor2Habilitado,
          () => e.sensor2Invertido = !e.sensor2Invertido,
        ),
        const SizedBox(height: 6),
        Text('Sensor Manual:', style: _rot),
        _caixa(
          'Habilitar',
          e.levanteManual,
          () => e.levanteManual = !e.levanteManual,
          descricao: 'Habilitar sensor manual',
        ),
        const SizedBox(height: 6),
        Text(
          'Estado Manobra: ${e.plantando ? 'Plantando' : 'Manobra'}',
          style: _rot,
        ),
        _caixa(
          'Ambos para Manobra',
          !e.bastaUmEmManobra,
          () => e.bastaUmEmManobra = false,
        ),
        _caixa(
          'Basta 1 em Manobra',
          e.bastaUmEmManobra,
          () => e.bastaUmEmManobra = true,
        ),
      ],
    );
  }

  /// Edição do campo aberto: lista de opções ou + e − com o valor.
  Widget _editor() {
    final id = e.campoEditando!;
    if (id == 'fonte' || id == 'energia') {
      final opcoes = id == 'fonte'
          ? [
              for (final f in FonteVelocidade.values)
                (f.nome, f == e.fonteVelocidade, () => e.fonteVelocidade = f),
            ]
          : [
              for (final f in FonteEnergia.values)
                (f.nome, f == e.energia, () => e.energia = f),
            ];
      return Positioned(
        left: 24,
        top: 52,
        width: 240,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF555555)),
            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black45)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (nome, atual, escolher) in opcoes)
                Semantics(
                  button: true,
                  label: nome,
                  child: GestureDetector(
                    onTap: () {
                      e.mudar(escolher);
                      e.editarCampo(null);
                    },
                    child: Container(
                      height: 26,
                      color: atual ? _verdeSelecao : Colors.white,
                      padding: const EdgeInsets.only(left: 4),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        nome,
                        style: _rot.copyWith(
                          fontSize: 17,
                          color: atual ? const Color(0xFF1B7A1B) : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    final c = _todosCampos[id];
    if (c == null) return const SizedBox.shrink();
    Widget botao(String t, VoidCallback a, String rotulo) => Semantics(
      button: true,
      label: rotulo,
      child: GestureDetector(
        onTap: a,
        child: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF555555)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            t,
            style: _mono.copyWith(fontSize: 24, color: Colors.black),
          ),
        ),
      ),
    );
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 112,
      child: Container(
        color: _T.fundo,
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    c.rotulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _mono.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${c.prefixo}${_v(c.ler(e), c.casas)} ${c.unidade}'
                          .trim(),
                      style: _mono.copyWith(fontSize: 38),
                    ),
                  ),
                ],
              ),
            ),
            botao('−', () => c.mudar(e, -1), 'Diminuir valor'),
            const SizedBox(width: 8),
            botao('+', () => c.mudar(e, 1), 'Aumentar valor'),
            const SizedBox(width: 8),
            botao('OK', () => e.editarCampo(null), 'Confirmar valor'),
          ],
        ),
      ),
    );
  }
}

/// Linha "Rótulo: [valor] unidade" de uma tela de configuração.
class _LinhaCampo extends StatelessWidget {
  final TerminalEstado e;
  final _Campo c;
  final double larguraRotulo;
  final double altura;

  const _LinhaCampo({
    required this.e,
    required this.c,
    required this.larguraRotulo,
    this.altura = 32,
  });

  @override
  Widget build(BuildContext context) {
    final travado = c.restrito && !e.engenhariaLiberada;
    final editando = e.campoEditando == c.id;
    final cor = travado ? _travado : Colors.black;
    return Semantics(
      button: !travado,
      label: c.rotulo,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: travado ? null : () => e.editarCampo(c.id),
        child: SizedBox(
          height: altura,
          child: Row(
            children: [
              SizedBox(
                width: larguraRotulo,
                child: Text(
                  '${c.rotulo}:',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: _rot.copyWith(color: cor),
                ),
              ),
              SizedBox(
                width: 14,
                child: Text(c.prefixo, style: _rot.copyWith(color: cor)),
              ),
              Container(
                width: 66,
                height: 22,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 4),
                color: travado
                    ? const Color(0xFFBDBDBD)
                    : editando
                    ? _verdeSelecao
                    : Colors.white,
                child: Text(
                  _v(c.ler(e), c.casas),
                  style: _rot.copyWith(color: cor),
                ),
              ),
              const SizedBox(width: 4),
              Text(c.unidade, style: _rot.copyWith(color: cor)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela que pede a senha dos parâmetros de engenharia.
class _TelaSenha extends StatelessWidget {
  final TerminalEstado e;
  final bool explicando;
  final ValueChanged<ParteTerminal> aoExplicar;

  const _TelaSenha({
    required this.e,
    required this.explicando,
    required this.aoExplicar,
  });

  @override
  Widget build(BuildContext context) {
    Widget botao(Widget filho, VoidCallback a, String rotulo, double w) =>
        Semantics(
          button: true,
          label: rotulo,
          child: GestureDetector(
            onTap: explicando ? () => aoExplicar(ParteTerminal.senha) : a,
            child: Container(
              width: w,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF555555)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: filho,
            ),
          ),
        );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: explicando ? () => aoExplicar(ParteTerminal.senha) : null,
      child: Container(
        decoration: BoxDecoration(
          color: _T.fundo,
          border: explicando ? Border.all(color: _T.destaque, width: 2) : null,
        ),
        child: Stack(
          children: [
            Positioned(
              right: 12,
              top: 10,
              child: botao(
                const Icon(Icons.close, color: Colors.black),
                e.fecharSenha,
                'Fechar senha',
                42,
              ),
            ),
            Positioned(
              left: 40,
              top: 118,
              child: Text(
                'Digite a senha de acesso:',
                style: _mono.copyWith(
                  fontSize: 18,
                  color: const Color(0xFFBDBDBD),
                ),
              ),
            ),
            Positioned(
              left: 144,
              top: 190,
              width: 192,
              height: 64,
              child: Container(
                color: const Color(0xFF66CC66),
                alignment: Alignment.center,
                child: Text(
                  '****',
                  style: _mono.copyWith(
                    fontSize: 36,
                    color: const Color(0xFFCCFFCC),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 190,
              top: 280,
              child: botao(
                Text('OK', style: _rot.copyWith(fontSize: 18)),
                e.liberarEngenharia,
                'Confirmar senha',
                100,
              ),
            ),
            Positioned(
              left: 40,
              right: 40,
              top: 350,
              child: Text(
                'Simulador: qualquer senha libera.',
                textAlign: TextAlign.center,
                style: _mono.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
