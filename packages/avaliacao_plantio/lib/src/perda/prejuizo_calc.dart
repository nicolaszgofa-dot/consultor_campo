import 'perda_calc.dart';

/// Valores de mercado e área para converter a perda em reais.
class ParametrosPrejuizo {
  final double precoSacaReais;
  final double areaHa;
  final double precoSacoSementeReais;
  final double sementesPorSaco;

  /// Sementes distribuídas por hectare (população alvo).
  final double sementesPorHa;

  const ParametrosPrejuizo({
    required this.precoSacaReais,
    required this.areaHa,
    required this.precoSacoSementeReais,
    required this.sementesPorSaco,
    required this.sementesPorHa,
  });

  double get custoPorSemente =>
      sementesPorSaco <= 0 ? 0 : precoSacoSementeReais / sementesPorSaco;
}

class PrejuizoCenario {
  final Cenario cenario;
  final double perdaSacasHa;
  final double produtividadeReaisHa;
  final double sementesReaisHa;

  const PrejuizoCenario({
    required this.cenario,
    required this.perdaSacasHa,
    required this.produtividadeReaisHa,
    required this.sementesReaisHa,
  });

  double get totalReaisHa => produtividadeReaisHa + sementesReaisHa;
}

class ResultadoPrejuizo {
  final ParametrosPrejuizo parametros;

  /// Sementes a mais nas duplas, por hectare.
  final double sementesExtrasHa;
  final List<PrejuizoCenario> cenarios;

  const ResultadoPrejuizo({
    required this.parametros,
    required this.sementesExtrasHa,
    required this.cenarios,
  });

  PrejuizoCenario de(Cenario cenario) =>
      cenarios.firstWhere((c) => c.cenario == cenario);

  /// Valor que a propriedade deixa de faturar na safra, na área toda.
  double totalSafraReais(Cenario cenario) =>
      de(cenario).totalReaisHa * parametros.areaHa;
}

class PrejuizoCalc {
  /// Produtividade perdida (perda × preço da saca) mais o custo das sementes
  /// a mais nas duplas. Sobreposição ainda não entra no desperdício.
  static ResultadoPrejuizo calcular(
    ResultadoPerda perda,
    ParametrosPrejuizo parametros,
  ) {
    final sementesExtras =
        parametros.sementesPorHa * perda.contagem.percentualAMais / 100;
    final sementesReais = sementesExtras * parametros.custoPorSemente;
    return ResultadoPrejuizo(
      parametros: parametros,
      sementesExtrasHa: sementesExtras,
      cenarios: [
        for (final c in perda.cenarios)
          PrejuizoCenario(
            cenario: c.cenario,
            perdaSacasHa: c.sacasHa,
            produtividadeReaisHa: c.sacasHa * parametros.precoSacaReais,
            sementesReaisHa: sementesReais,
          ),
      ],
    );
  }
}
