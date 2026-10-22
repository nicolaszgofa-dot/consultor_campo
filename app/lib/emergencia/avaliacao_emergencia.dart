import 'dart:convert';

import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Avaliação de emergência acompanhada dia a dia (método de marcação).
class AvaliacaoEmergencia {
  final String id;
  final String talhao;
  final Cultura cultura;
  final DateTime dataPlantio;
  final double sementesPorMetro;
  final int linhas;
  final double comprimentoLinhaM;
  final List<RegistroEmergencia> registros;

  const AvaliacaoEmergencia({
    required this.id,
    required this.talhao,
    required this.cultura,
    required this.dataPlantio,
    required this.sementesPorMetro,
    required this.linhas,
    required this.comprimentoLinhaM,
    this.registros = const [],
  });

  ParametrosEmergencia get parametros => ParametrosEmergencia(
    cultura: cultura,
    dataPlantio: dataPlantio,
    linhas: linhas,
    comprimentoLinhaM: comprimentoLinhaM,
    sementesPorMetro: sementesPorMetro,
  );

  ResultadoEmergencia get resultado =>
      EmergenciaCalc.calcular(parametros, registros);

  RegistroEmergencia? registroDe(DateTime data) {
    for (final r in registros) {
      if (_mesmoDia(r.data, data)) return r;
    }
    return null;
  }

  /// Grava a marcação do dia, substituindo a que já existir na mesma data.
  AvaliacaoEmergencia comRegistro(RegistroEmergencia novo) {
    final outros = registros.where((r) => !_mesmoDia(r.data, novo.data));
    final todos = [...outros, novo]..sort((a, b) => a.data.compareTo(b.data));
    return AvaliacaoEmergencia(
      id: id,
      talhao: talhao,
      cultura: cultura,
      dataPlantio: dataPlantio,
      sementesPorMetro: sementesPorMetro,
      linhas: linhas,
      comprimentoLinhaM: comprimentoLinhaM,
      registros: List.unmodifiable(todos),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'talhao': talhao,
    'cultura': cultura.name,
    'dataPlantio': _data(dataPlantio),
    'sementesPorMetro': sementesPorMetro,
    'linhas': linhas,
    'comprimentoLinhaM': comprimentoLinhaM,
    'registros': [
      for (final r in registros)
        {'data': _data(r.data), 'novasPorLinha': r.novasPorLinha},
    ],
  };

  factory AvaliacaoEmergencia.fromJson(Map<String, dynamic> j) =>
      AvaliacaoEmergencia(
        id: j['id'] as String,
        talhao: j['talhao'] as String? ?? '',
        cultura: Cultura.values.byName(j['cultura'] as String),
        dataPlantio: DateTime.parse(j['dataPlantio'] as String),
        sementesPorMetro: (j['sementesPorMetro'] as num).toDouble(),
        linhas: j['linhas'] as int,
        comprimentoLinhaM: (j['comprimentoLinhaM'] as num).toDouble(),
        registros: [
          for (final r in j['registros'] as List)
            RegistroEmergencia(
              data: DateTime.parse(r['data'] as String),
              novasPorLinha: List<int>.from(r['novasPorLinha'] as List),
            ),
        ],
      );

  static String _data(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Guarda as avaliações de emergência no aparelho (no navegador, no
/// armazenamento local da página).
class RepositorioEmergencia {
  static const _chave = 'emergencias.v1';

  const RepositorioEmergencia();

  Future<List<AvaliacaoEmergencia>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chave);
    if (texto == null) return [];
    final lista = jsonDecode(texto) as List;
    return [
      for (final j in lista)
        AvaliacaoEmergencia.fromJson(j as Map<String, dynamic>),
    ];
  }

  Future<void> salvar(AvaliacaoEmergencia avaliacao) async {
    final todas = await listar();
    final i = todas.indexWhere((a) => a.id == avaliacao.id);
    if (i >= 0) {
      todas[i] = avaliacao;
    } else {
      todas.insert(0, avaliacao);
    }
    await _gravar(todas);
  }

  Future<void> excluir(String id) async {
    final todas = await listar()
      ..removeWhere((a) => a.id == id);
    await _gravar(todas);
  }

  Future<void> _gravar(List<AvaliacaoEmergencia> todas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode([for (final a in todas) a.toJson()]),
    );
  }
}
