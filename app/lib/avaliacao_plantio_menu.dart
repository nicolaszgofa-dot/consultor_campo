import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

class AvaliacaoPlantioMenu extends StatelessWidget {
  const AvaliacaoPlantioMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliação de plantio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Opcao(
            titulo: 'Plantabilidade',
            descricao: 'Duplas, falhas, CV e população a partir da trena.',
            icone: Icons.straighten,
            tela: PlantabilidadePage(),
          ),
          _Opcao(
            titulo: 'Fertilizante',
            descricao: 'Dose por linha, tolerância de 5% e CV da distribuição.',
            icone: Icons.scale,
            tela: FertilizantePage(),
          ),
        ],
      ),
    );
  }
}

class _Opcao extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final Widget tela;

  const _Opcao({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.tela,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icone, size: 32),
        title: Text(titulo),
        subtitle: Text(descricao),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela)),
      ),
    );
  }
}
