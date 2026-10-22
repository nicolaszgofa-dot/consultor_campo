import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

class Modulo {
  final String titulo;
  final String descricao;
  final IconData icone;
  final WidgetBuilder abrir;

  const Modulo({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.abrir,
  });
}

/// Módulos disponíveis. Um novo módulo entra aqui.
final modulos = <Modulo>[
  Modulo(
    titulo: 'Plantabilidade',
    descricao: 'Duplas, falhas, CV e população a partir da trena.',
    icone: Icons.grass,
    abrir: (_) => const PlantabilidadePage(),
  ),
  Modulo(
    titulo: 'Fertilizante',
    descricao: 'Dose por linha, tolerância de 5% e CV da distribuição.',
    icone: Icons.scale,
    abrir: (_) => const FertilizantePage(),
  ),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Consultor de Campo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Avaliação de plantio', style: texto.titleMedium),
          const SizedBox(height: 8),
          for (final modulo in modulos)
            Card(
              child: ListTile(
                leading: Icon(modulo.icone, size: 32),
                title: Text(modulo.titulo),
                subtitle: Text(modulo.descricao),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: modulo.abrir)),
              ),
            ),
        ],
      ),
    );
  }
}
