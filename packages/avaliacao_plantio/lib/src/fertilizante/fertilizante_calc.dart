import '../estatistica.dart';

enum StatusFertilizante { dentroDoPadrao, atencao }

class ParametrosFertilizante {
  final double doseKgHa;
  final double espacamentoLinhasM;
  final double distanciaColetaM;
  final int numeroLinhas;

  const ParametrosFertilizante({
    required this.doseKgHa,
    required this.espacamentoLinhasM,
    required this.distanciaColetaM,
    required this.numeroLinhas,
  });

  /// Gramas esperadas por linha: kg/ha × área coletada (m²) / 10.
  double get idealPorAmostraG =>
      doseKgHa * espacamentoLinhasM * distanciaColetaM / 10;
}

class ResultadoFertilizante {
  final double mediaG;
  final double desvioPadraoG;
  final double cvPercentual;
  final StatusFertilizante status;

  /// Dose real equivalente à média coletada, em kg/ha.
  final double doseRealKgHa;

  const ResultadoFertilizante({
    required this.mediaG,
    required this.desvioPadraoG,
    required this.cvPercentual,
    required this.status,
    required this.doseRealKgHa,
  });

  bool get dentroDoPadrao => status == StatusFertilizante.dentroDoPadrao;
}

class FertilizanteCalc {
  /// Tolerância de cada linha em relação ao ideal (±5%, limite incluído).
  static const double toleranciaLinha = 0.05;

  /// CV abaixo deste valor é "Dentro do padrão"; a partir dele, "Atenção".
  static const double limiteCv = 7.0;

  static bool linhaDentroDaTolerancia(double gramas, double idealG) =>
      (gramas - idealG).abs() <= toleranciaLinha * idealG + epsilon;

  static StatusFertilizante status(double cvPercentual) =>
      cvPercentual < limiteCv - epsilon
          ? StatusFertilizante.dentroDoPadrao
          : StatusFertilizante.atencao;

  /// Retorna null enquanto houver menos de 2 linhas preenchidas.
  /// Amostras idênticas dão CV = 0% ("Dentro do padrão"); o app original
  /// escondia o resultado nesse caso.
  static ResultadoFertilizante? calcular(
    ParametrosFertilizante parametros,
    List<double> gramasPorLinha,
  ) {
    if (gramasPorLinha.length < 2) return null;
    final m = media(gramasPorLinha);
    final dp = desvioPadraoAmostral(gramasPorLinha);
    final cv = coeficienteVariacao(dp, m);
    final areaM2 = parametros.espacamentoLinhasM * parametros.distanciaColetaM;
    return ResultadoFertilizante(
      mediaG: m,
      desvioPadraoG: dp,
      cvPercentual: cv,
      status: status(cv),
      doseRealKgHa: areaM2 == 0 ? 0 : m * 10 / areaM2,
    );
  }
}
