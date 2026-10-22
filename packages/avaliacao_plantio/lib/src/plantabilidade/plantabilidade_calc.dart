import '../estatistica.dart';

enum ClasseEspacamento { aceitavel, dupla, falha }

class Espacamento {
  /// Distância até a planta anterior, em cm (arredondada a 0,1 cm).
  final double valorCm;

  /// Leitura acumulada da trena que gerou este espaçamento, em cm.
  final double leituraTrenaCm;
  final ClasseEspacamento classe;

  const Espacamento({
    required this.valorCm,
    required this.leituraTrenaCm,
    required this.classe,
  });
}

class ParametrosPlantabilidade {
  final double sementesPorMetro;
  final double espacamentoLinhasM;

  const ParametrosPlantabilidade({
    required this.sementesPorMetro,
    required this.espacamentoLinhasM,
  });

  double get espacamentoIdealCm => 100 / sementesPorMetro;

  double get metrosLinearesPorHa => 10000 / espacamentoLinhasM;

  /// População teórica: usa as sementes/m informadas, não as medidas.
  double get populacaoPorHa => sementesPorMetro * metrosLinearesPorHa;
}

class ResultadoPlantabilidade {
  final List<Espacamento> espacamentos;
  final double mediaCm;
  final double desvioPadraoCm;
  final double cvPercentual;
  final double percentualAceitaveis;
  final double percentualDuplas;
  final double percentualFalhas;
  final double populacaoPorHa;

  const ResultadoPlantabilidade({
    required this.espacamentos,
    required this.mediaCm,
    required this.desvioPadraoCm,
    required this.cvPercentual,
    required this.percentualAceitaveis,
    required this.percentualDuplas,
    required this.percentualFalhas,
    required this.populacaoPorHa,
  });

  int get numAmostras => espacamentos.length;

  int contar(ClasseEspacamento classe) =>
      espacamentos.where((e) => e.classe == classe).length;
}

class PlantabilidadeCalc {
  static const double limiteDupla = 0.5;
  static const double limiteFalha = 1.5;

  /// Espaçamento entre linhas acima deste valor provavelmente foi digitado
  /// em centímetros (ex.: 50 em vez de 0,50).
  static const double limiteSuspeitaCentimetros = 3.0;

  static bool pareceCentimetros(double espacamentoLinhasM) =>
      espacamentoLinhasM > limiteSuspeitaCentimetros;

  /// Dupla: < 0,5 × ideal. Falha: > 1,5 × ideal. Os limites são aceitáveis.
  static ClasseEspacamento classificar(double espacamentoCm, double idealCm) {
    if (espacamentoCm < limiteDupla * idealCm - epsilon) {
      return ClasseEspacamento.dupla;
    }
    if (espacamentoCm > limiteFalha * idealCm + epsilon) {
      return ClasseEspacamento.falha;
    }
    return ClasseEspacamento.aceitavel;
  }

  /// Converte leituras acumuladas da trena (zero na primeira planta) em
  /// espaçamentos classificados.
  static List<Espacamento> espacamentosDasLeituras(
    List<double> leiturasTrenaCm,
    double idealCm,
  ) {
    final resultado = <Espacamento>[];
    var anterior = 0.0;
    for (final leitura in leiturasTrenaCm) {
      final valor = arredondar(leitura - anterior);
      resultado.add(
        Espacamento(
          valorCm: valor,
          leituraTrenaCm: leitura,
          classe: classificar(valor, idealCm),
        ),
      );
      anterior = leitura;
    }
    return resultado;
  }

  static ResultadoPlantabilidade calcular(
    ParametrosPlantabilidade parametros,
    List<double> leiturasTrenaCm,
  ) {
    final espacamentos = espacamentosDasLeituras(
      leiturasTrenaCm,
      parametros.espacamentoIdealCm,
    );
    final valores = espacamentos.map((e) => e.valorCm).toList();
    final n = valores.length;
    final m = media(valores);
    final dp = desvioPadraoAmostral(valores);

    double percentual(ClasseEspacamento classe) => n == 0
        ? 0
        : espacamentos.where((e) => e.classe == classe).length * 100 / n;

    return ResultadoPlantabilidade(
      espacamentos: espacamentos,
      mediaCm: m,
      desvioPadraoCm: dp,
      cvPercentual: coeficienteVariacao(dp, m),
      percentualAceitaveis: percentual(ClasseEspacamento.aceitavel),
      percentualDuplas: percentual(ClasseEspacamento.dupla),
      percentualFalhas: percentual(ClasseEspacamento.falha),
      populacaoPorHa: parametros.populacaoPorHa,
    );
  }
}
