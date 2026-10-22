import 'package:flutter/material.dart';

const corOk = Color(0xFF2E7D32);
const corAlerta = Color(0xFFD32F2F);

/// Aceita vírgula ou ponto como separador decimal.
double? lerNumero(String texto) =>
    double.tryParse(texto.trim().replaceAll(',', '.'));

String formatar(double valor, [int casas = 1]) => valor.toStringAsFixed(casas);

/// Formata com separador de milhar ponto (ex.: 80.000).
String formatarInteiro(double valor) {
  final digitos = valor.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digitos[i]);
  }
  return buffer.toString();
}

class CampoNumero extends StatelessWidget {
  final TextEditingController controller;
  final String rotulo;
  final String? Function(String?)? validator;

  const CampoNumero({
    super.key,
    required this.controller,
    required this.rotulo,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: rotulo,
        border: const OutlineInputBorder(),
      ),
      validator: validator ??
          (v) => (lerNumero(v ?? '') ?? 0) > 0 ? null : 'Valor inválido',
    );
  }
}

class Secao extends StatelessWidget {
  final String titulo;
  final Widget child;

  const Secao({super.key, required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: corOk, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class Etiqueta extends StatelessWidget {
  final String texto;
  final Color cor;

  const Etiqueta(this.texto, {super.key, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        border: Border.all(color: cor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(color: cor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class CartaoValor extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final bool ok;
  final VoidCallback? onTap;

  const CartaoValor({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.ok,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = ok ? corOk : corAlerta;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: cor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(subtitulo, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
