import 'package:flutter/material.dart';

import 'avaliacao/avaliacao_hub_page.dart';
import 'configurador/configurador_page.dart';
import 'roi/roi_page.dart';

class Funcionalidade {
  final String titulo;
  final String descricao;
  final IconData icone;

  /// Tela que a funcionalidade abre. Nula = ainda em breve.
  final Widget Function()? tela;

  const Funcionalidade({
    required this.titulo,
    required this.descricao,
    required this.icone,
    this.tela,
  });

  bool get emBreve => tela == null;
}

/// Funcionalidades na ordem da tela inicial, todas com o mesmo peso.
final funcionalidades = <Funcionalidade>[
  Funcionalidade(
    titulo: 'Avaliação de plantio',
    descricao: 'Plantio, fertilizante e emergência',
    icone: Icons.straighten,
    tela: () => const AvaliacaoHubPage(),
  ),
  Funcionalidade(
    titulo: 'Configurador',
    descricao: 'Configuração do equipamento para cada cliente',
    icone: Icons.tune,
    tela: () => const ConfiguradorPage(),
  ),
  Funcionalidade(
    titulo: 'ROI',
    descricao: 'Retorno do investimento para o produtor',
    icone: Icons.trending_up,
    tela: () => const RoiPage(),
  ),
  const Funcionalidade(
    titulo: 'Material técnico',
    descricao: 'Catálogos, manuais e fichas técnicas',
    icone: Icons.menu_book_outlined,
  ),
  const Funcionalidade(
    titulo: 'Relatórios',
    descricao: 'Avaliações salvas e relatórios enviados',
    icone: Icons.description_outlined,
  ),
];
