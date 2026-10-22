import 'package:flutter/material.dart';

import 'funcionalidades.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Consultor de Campo')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final colunas = constraints.maxWidth >= 900
              ? 3
              : constraints.maxWidth >= 520
              ? 2
              : 1;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('O que você quer fazer?', style: texto.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Escolha uma funcionalidade.',
                style: texto.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: colunas,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: colunas == 1 ? 3.2 : 1.9,
                children: [
                  for (final f in funcionalidades) CartaoFuncionalidade(f),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class CartaoFuncionalidade extends StatelessWidget {
  final Funcionalidade funcionalidade;

  const CartaoFuncionalidade(this.funcionalidade, {super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    final f = funcionalidade;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: f.disponivel ? cores.primaryContainer : null,
      child: InkWell(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: f.abrir)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                f.icone,
                size: 40,
                color: f.disponivel ? cores.primary : cores.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            f.titulo,
                            style: texto.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!f.disponivel) ...[
                          const SizedBox(width: 8),
                          const _EmBreve(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      f.descricao,
                      style: texto.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmBreve extends StatelessWidget {
  const _EmBreve();

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Em breve', style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
