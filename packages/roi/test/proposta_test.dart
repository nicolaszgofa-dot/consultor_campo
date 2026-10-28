import 'package:flutter_test/flutter_test.dart';
import 'package:roi/roi.dart';

void main() {
  test('valor por extenso dos modelos de proposta', () {
    expect(valorPorExtenso(110500), 'Cento e dez mil e quinhentos reais');
    expect(valorPorExtenso(101400), 'Cento e um mil e quatrocentos reais');
    expect(valorPorExtenso(118300), 'Cento e dezoito mil e trezentos reais');
    expect(valorPorExtenso(76500), 'Setenta e seis mil e quinhentos reais');
    expect(
      valorPorExtenso(481800),
      'Quatrocentos e oitenta e um mil e oitocentos reais',
    );
  });

  test('valor por extenso: casos de borda', () {
    expect(valorPorExtenso(0), 'Zero real');
    expect(valorPorExtenso(1), 'Um real');
    expect(valorPorExtenso(100), 'Cem reais');
    expect(valorPorExtenso(1000), 'Mil reais');
    expect(valorPorExtenso(1020), 'Mil e vinte reais');
    expect(valorPorExtenso(1110), 'Mil cento e dez reais');
    expect(valorPorExtenso(1000000), 'Um milhão de reais');
    expect(
      valorPorExtenso(2350000),
      'Dois milhões e trezentos e cinquenta mil reais',
    );
    expect(
      valorPorExtenso(1234567.89),
      'Um milhão, duzentos e trinta e quatro mil quinhentos e sessenta e sete '
      'reais e oitenta e nove centavos',
    );
    expect(valorPorExtenso(0.5), 'Cinquenta centavos');
  });

  test('parcelas somam o total', () {
    expect(dividirEmParcelas(110500, [0.2, 0.4, 0.4]), [22100, 44200, 44200]);
    final p = dividirEmParcelas(100000.01, [1 / 3, 1 / 3, 1 / 3]);
    expect(p.fold(0.0, (a, b) => a + b), closeTo(100000.01, 1e-9));
    expect(dividirEmParcelas(1000, []), isEmpty);
  });
}
