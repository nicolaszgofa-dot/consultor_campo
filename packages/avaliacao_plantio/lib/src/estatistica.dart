import 'dart:math' as math;

/// Tolerância para comparações de ponto flutuante nos limites de classificação.
const double epsilon = 1e-9;

double media(List<double> valores) {
  if (valores.isEmpty) return 0;
  return valores.reduce((a, b) => a + b) / valores.length;
}

/// Desvio padrão amostral (divisor n − 1). Retorna 0 com menos de 2 valores.
double desvioPadraoAmostral(List<double> valores) {
  if (valores.length < 2) return 0;
  final m = media(valores);
  final somaQuadrados = valores.fold<double>(
    0,
    (soma, v) => soma + (v - m) * (v - m),
  );
  return math.sqrt(somaQuadrados / (valores.length - 1));
}

/// Coeficiente de variação em %. Multiplica antes de dividir para evitar
/// erros como 7 / 100 * 100 = 7.000000000000001.
double coeficienteVariacao(double desvio, double media) {
  if (media == 0) return 0;
  return desvio * 100 / media;
}

/// Arredonda para [casas] casas decimais.
double arredondar(double valor, [int casas = 1]) {
  final fator = math.pow(10, casas);
  return (valor * fator).round() / fator;
}
