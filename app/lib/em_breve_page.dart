import 'package:flutter/material.dart';

/// Tela provisória de uma funcionalidade que ainda não foi construída.
class EmBrevePage extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;

  const EmBrevePage({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icone, size: 64, color: cores.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'Em desenvolvimento',
                  style: texto.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  descricao,
                  style: texto.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Voltar ao início'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
