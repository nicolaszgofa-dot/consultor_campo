/// Números no formato brasileiro: vírgula decimal e ponto de milhar.
String numeroBr(double valor, [int casas = 1]) {
  final texto = valor.abs().toStringAsFixed(casas);
  final partes = texto.split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  final sinal = valor < 0 && texto != (0).toStringAsFixed(casas) ? '-' : '';
  return casas > 0 ? '$sinal$inteiro,${partes[1]}' : '$sinal$inteiro';
}

String percentual(double valor, [int casas = 1]) =>
    '${numeroBr(valor, casas)}%';

String reais(double valor, [int casas = 2]) => 'R\$ ${numeroBr(valor, casas)}';

String dataBr(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Lê uma data digitada como dd/mm/aaaa. Nula se inválida.
DateTime? lerData(String texto) {
  final partes = texto.trim().split('/');
  if (partes.length != 3) return null;
  final dia = int.tryParse(partes[0]);
  final mes = int.tryParse(partes[1]);
  final ano = int.tryParse(partes[2]);
  if (dia == null || mes == null || ano == null || ano < 2000) return null;
  final d = DateTime(ano, mes, dia);
  return d.day == dia && d.month == mes ? d : null;
}

/// Lê um número digitado com vírgula ou ponto ("0,50", "1.200,5", "0.5").
double? lerNumero(String texto) {
  var t = texto.replaceAll('R\$', '').replaceAll(' ', '').trim();
  if (t.isEmpty) return null;
  if (t.contains(',')) {
    t = t.replaceAll('.', '').replaceAll(',', '.');
  }
  return double.tryParse(t);
}
