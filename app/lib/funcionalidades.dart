import 'package:flutter/material.dart';

import 'avaliacao_plantio_menu.dart';
import 'em_breve_page.dart';

class Funcionalidade {
  final String titulo;
  final String descricao;
  final IconData icone;
  final bool disponivel;
  final WidgetBuilder abrir;

  const Funcionalidade({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.disponivel,
    required this.abrir,
  });
}

Funcionalidade _emBreve(String titulo, String descricao, IconData icone) =>
    Funcionalidade(
      titulo: titulo,
      descricao: descricao,
      icone: icone,
      disponivel: false,
      abrir: (_) =>
          EmBrevePage(titulo: titulo, descricao: descricao, icone: icone),
    );

/// Funcionalidades da tela inicial, na ordem em que aparecem.
/// Para ativar uma funcionalidade, troque o `_emBreve` pela tela real.
final funcionalidades = <Funcionalidade>[
  _emBreve(
    'Configurador',
    'Monte a configuração do equipamento para cada cliente.',
    Icons.tune,
  ),
  Funcionalidade(
    titulo: 'Avaliação de plantio',
    descricao: 'Plantabilidade e dose de fertilizante na linha.',
    icone: Icons.grass,
    disponivel: true,
    abrir: (_) => const AvaliacaoPlantioMenu(),
  ),
  _emBreve(
    'ROI',
    'Retorno do investimento para apresentar ao produtor.',
    Icons.trending_up,
  ),
  _emBreve(
    'Material técnico',
    'Catálogos, manuais e fichas técnicas para consulta no campo.',
    Icons.menu_book,
  ),
  _emBreve(
    'Relatórios',
    'Avaliações salvas e relatórios para enviar ao cliente.',
    Icons.description,
  ),
];
