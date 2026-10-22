import '../perda/perda_calc.dart' show Cultura;

/// Plantas que emergiram em cada linha num dia de marcação (só as novas).
class RegistroEmergencia {
  final DateTime data;
  final List<int> novasPorLinha;

  const RegistroEmergencia({required this.data, required this.novasPorLinha});

  int get total => novasPorLinha.fold(0, (s, n) => s + n);
}

class ParametrosEmergencia {
  final Cultura cultura;
  final DateTime dataPlantio;
  final int linhas;
  final double comprimentoLinhaM;
  final double sementesPorMetro;

  const ParametrosEmergencia({
    required this.cultura,
    required this.dataPlantio,
    required this.linhas,
    required this.comprimentoLinhaM,
    required this.sementesPorMetro,
  });

  double get esperadasPorLinha => comprimentoLinhaM * sementesPorMetro;

  double get plantasEsperadas => linhas * esperadasPorLinha;
}

/// Redução do potencial produtivo da planta (%) pelos dias de atraso em
/// relação às primeiras plantas emergidas. Padrão: referência J.Assy para
/// milho (35% com 1 dia, 85% com 3 dias); 2 dias é interpolado.
/// Fontes: docs/base-conhecimento/emergencia.md.
class CoeficientesEmergencia {
  final double atraso1Dia;
  final double atraso2Dias;
  final double atraso3DiasOuMais;

  const CoeficientesEmergencia({
    this.atraso1Dia = 35,
    this.atraso2Dias = 60,
    this.atraso3DiasOuMais = 85,
  });

  double perdaPorPlanta(int diasDeAtraso) => switch (diasDeAtraso) {
        <= 0 => 0,
        1 => atraso1Dia,
        2 => atraso2Dias,
        _ => atraso3DiasOuMais,
      };
}

/// Plantas emergidas num dia de marcação.
class DiaEmergencia {
  final DateTime data;
  final int dap;

  /// 1 = primeiro dia com emergência; 2 = um dia depois; e assim por diante.
  final int diaDeEmergencia;
  final List<int> novasPorLinha;

  const DiaEmergencia({
    required this.data,
    required this.dap,
    required this.diaDeEmergencia,
    required this.novasPorLinha,
  });

  int get total => novasPorLinha.fold(0, (s, n) => s + n);
}

class ResultadoEmergencia {
  final ParametrosEmergencia parametros;

  /// Dias com plantas emergidas, em ordem de data.
  final List<DiaEmergencia> dias;
  final List<int> emergidasPorLinha;
  final List<int> dia1PorLinha;

  /// Redução do potencial produtivo da lavoura (%), ponderada pelas plantas.
  /// Nula quando a cultura não tem coeficiente (soja).
  final double? perdaPotencialPercentual;

  const ResultadoEmergencia({
    required this.parametros,
    required this.dias,
    required this.emergidasPorLinha,
    required this.dia1PorLinha,
    required this.perdaPotencialPercentual,
  });

  int get emergidas => emergidasPorLinha.fold(0, (s, n) => s + n);

  int? get dapPrimeiraEmergencia => dias.isEmpty ? null : dias.first.dap;

  /// Emergidas em relação às sementes distribuídas.
  double get percentualEmergencia => parametros.plantasEsperadas == 0
      ? 0
      : emergidas * 100 / parametros.plantasEsperadas;

  /// Plantas por dia de emergência (1, 2, 3 e 4 ou mais).
  int plantasNoDia(int dia) => dias
      .where(
          (d) => dia >= 4 ? d.diaDeEmergencia >= 4 : d.diaDeEmergencia == dia)
      .fold(0, (s, d) => s + d.total);

  double percentualNoDia(int dia) =>
      emergidas == 0 ? 0 : plantasNoDia(dia) * 100 / emergidas;

  double percentualDia1NaLinha(int linha) => emergidasPorLinha[linha] == 0
      ? 0
      : dia1PorLinha[linha] * 100 / emergidasPorLinha[linha];

  /// Linha com menor % no dia 1, quando fica 10 pontos ou mais abaixo da
  /// média das linhas. Nula quando nenhuma se destaca.
  int? linhaMaisTardia({double margemPontos = 10}) {
    final medidas = [
      for (var i = 0; i < emergidasPorLinha.length; i++)
        if (emergidasPorLinha[i] > 0) i,
    ];
    if (medidas.length < 2) return null;
    final media =
        medidas.fold<double>(0, (s, i) => s + percentualDia1NaLinha(i)) /
            medidas.length;
    var pior = medidas.first;
    for (final i in medidas) {
      if (percentualDia1NaLinha(i) < percentualDia1NaLinha(pior)) pior = i;
    }
    return media - percentualDia1NaLinha(pior) >= margemPontos ? pior : null;
  }
}

class EmergenciaCalc {
  /// Dias após o plantio, contando só as datas (sem horas).
  static int dap(DateTime plantio, DateTime data) =>
      DateTime(data.year, data.month, data.day)
          .difference(DateTime(plantio.year, plantio.month, plantio.day))
          .inDays;

  static ResultadoEmergencia calcular(
    ParametrosEmergencia p,
    List<RegistroEmergencia> registros, {
    CoeficientesEmergencia coeficientes = const CoeficientesEmergencia(),
  }) {
    // Junta marcações da mesma data e descarta dias sem planta nova.
    final porData = <int, List<int>>{};
    for (final r in registros) {
      final d = dap(p.dataPlantio, r.data);
      final soma = porData.putIfAbsent(d, () => List.filled(p.linhas, 0));
      for (var i = 0; i < p.linhas && i < r.novasPorLinha.length; i++) {
        soma[i] += r.novasPorLinha[i];
      }
    }
    final daps = porData.keys
        .where((d) => porData[d]!.any((n) => n > 0))
        .toList()
      ..sort();

    final primeiro = daps.isEmpty ? 0 : daps.first;
    final dias = [
      for (final d in daps)
        DiaEmergencia(
          data: DateTime(
            p.dataPlantio.year,
            p.dataPlantio.month,
            p.dataPlantio.day + d,
          ),
          dap: d,
          diaDeEmergencia: d - primeiro + 1,
          novasPorLinha: List.unmodifiable(porData[d]!),
        ),
    ];

    final emergidas = List.filled(p.linhas, 0);
    final dia1 = List.filled(p.linhas, 0);
    var perdaPonderada = 0.0;
    for (final dia in dias) {
      for (var i = 0; i < p.linhas; i++) {
        emergidas[i] += dia.novasPorLinha[i];
        if (dia.diaDeEmergencia == 1) dia1[i] += dia.novasPorLinha[i];
      }
      perdaPonderada +=
          dia.total * coeficientes.perdaPorPlanta(dia.diaDeEmergencia - 1);
    }
    final total = emergidas.fold(0, (s, n) => s + n);

    return ResultadoEmergencia(
      parametros: p,
      dias: dias,
      emergidasPorLinha: emergidas,
      dia1PorLinha: dia1,
      perdaPotencialPercentual: p.cultura == Cultura.milho && total > 0
          ? perdaPonderada / total
          : null,
    );
  }
}
