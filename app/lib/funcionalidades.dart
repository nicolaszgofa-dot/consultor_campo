import 'package:flutter/material.dart';

class Funcionalidade {
  final String titulo;
  final String descricao;
  final IconData icone;

  const Funcionalidade({
    required this.titulo,
    required this.descricao,
    required this.icone,
  });
}

/// Funcionalidades ainda em desenvolvimento, na ordem da tela inicial.
/// A avaliação de plantio fica em destaque, fora desta lista.
const emBreve = <Funcionalidade>[
  Funcionalidade(
    titulo: 'Configurador',
    descricao: 'Configuração do equipamento para cada cliente',
    icone: Icons.tune,
  ),
  Funcionalidade(
    titulo: 'ROI',
    descricao: 'Retorno do investimento para o produtor',
    icone: Icons.trending_up,
  ),
  Funcionalidade(
    titulo: 'Material técnico',
    descricao: 'Catálogos, manuais e fichas técnicas',
    icone: Icons.menu_book_outlined,
  ),
  Funcionalidade(
    titulo: 'Relatórios',
    descricao: 'Avaliações salvas e relatórios enviados',
    icone: Icons.description_outlined,
  ),
];
