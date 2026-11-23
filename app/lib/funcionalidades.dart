import 'package:flutter/material.dart';

import 'assistencia/assistencia_page.dart';
import 'avaliacao/avaliacao_hub_page.dart';
import 'conceito/conceito_page.dart';
import 'configurador/configurador_page.dart';
import 'inteligencia/inteligencia_page.dart';
import 'pecas/pecas_page.dart';
import 'perfil.dart';
import 'proposta/propostas_page.dart';
import 'roi/roi_page.dart';
import 'ui/icones_modulos.dart';

class Funcionalidade {
  final String titulo;
  final String descricao;
  final IconeModulo icone;

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

/// Funcionalidades da versão compilada (ver perfil.dart), na ordem da tela
/// inicial, todas com o mesmo peso. Como [ehRevenda] é constante, a lista da
/// outra versão (e as telas que só ela usa) fica fora do app.
final List<Funcionalidade> funcionalidades = ehRevenda
    ? funcionalidadesRevenda()
    : funcionalidadesEquipe();

/// App da equipe J.Assy.
List<Funcionalidade> funcionalidadesEquipe() => [
  Funcionalidade(
    titulo: 'Avaliação de plantio',
    descricao: 'Plantio, fertilizante e emergência',
    icone: IconeModulo.plantio,
    tela: () => const AvaliacaoHubPage(),
  ),
  Funcionalidade(
    titulo: 'Configurador',
    descricao: 'Configuração do equipamento para cada cliente',
    icone: IconeModulo.configurador,
    tela: () => const ConfiguradorPage(),
  ),
  Funcionalidade(
    titulo: 'ROI',
    descricao: 'Retorno do investimento para o produtor',
    icone: IconeModulo.roi,
    tela: () => const RoiPage(),
  ),
  Funcionalidade(
    titulo: 'Proposta comercial',
    descricao: 'Proposta em PDF com produtos, condições e retorno',
    icone: IconeModulo.proposta,
    tela: () => const PropostasPage(),
  ),
  Funcionalidade(
    titulo: 'Inteligência de mercado',
    descricao: 'Cotações, concorrência e preços encontrados no campo',
    icone: IconeModulo.mercado,
    tela: () => const InteligenciaPage(),
  ),
  Funcionalidade(
    titulo: 'Peças de reposição',
    descricao: 'Vista explodida e códigos das peças de cada produto',
    icone: IconeModulo.pecas,
    tela: () => const PecasPage(),
  ),
  const Funcionalidade(
    titulo: 'Playbook',
    descricao: 'Roteiro da visita e argumentos para o cliente',
    icone: IconeModulo.playbook,
  ),
  Funcionalidade(
    titulo: 'Conceito',
    descricao: 'Conceitos técnicos por trás das tecnologias J.Assy',
    icone: IconeModulo.conceito,
    tela: () => const ConceitoPage(),
  ),
  const Funcionalidade(
    titulo: 'Material técnico',
    descricao: 'Catálogos, manuais e fichas técnicas',
    icone: IconeModulo.materialTecnico,
  ),
  const Funcionalidade(
    titulo: 'Relatórios',
    descricao: 'Avaliações salvas e relatórios enviados',
    icone: IconeModulo.relatorios,
  ),
];

/// App das revendas parceiras: sem Inteligência de mercado, Playbook,
/// Material técnico e Relatórios; com pedido de peças, assistência e
/// garantia, regulagem e treinamento.
List<Funcionalidade> funcionalidadesRevenda() => [
  Funcionalidade(
    titulo: 'Avaliação de plantio',
    descricao: 'Plantio, fertilizante e emergência',
    icone: IconeModulo.plantio,
    tela: () => const AvaliacaoHubPage(),
  ),
  Funcionalidade(
    titulo: 'Configurador',
    descricao: 'Configuração do equipamento para cada cliente',
    icone: IconeModulo.configurador,
    tela: () => const ConfiguradorPage(),
  ),
  Funcionalidade(
    titulo: 'ROI',
    descricao: 'Retorno do investimento para o produtor',
    icone: IconeModulo.roi,
    tela: () => const RoiPage(),
  ),
  Funcionalidade(
    titulo: 'Proposta comercial',
    descricao: 'Proposta em PDF com produtos, condições e retorno',
    icone: IconeModulo.proposta,
    tela: () => const PropostasPage(),
  ),
  Funcionalidade(
    titulo: 'Pedido de peças',
    descricao: 'Vista explodida, códigos e pedido de reposição',
    icone: IconeModulo.pedido,
    tela: () => const PecasPage(modoPedido: true),
  ),
  Funcionalidade(
    titulo: 'Assistência e garantia',
    descricao: 'Chamado de assistência ou garantia para a J.Assy',
    icone: IconeModulo.assistencia,
    tela: () => const AssistenciaPage(),
  ),
  const Funcionalidade(
    titulo: 'Regulagem e instalação',
    descricao: 'Passo a passo de instalação e regulagem dos produtos',
    icone: IconeModulo.regulagem,
  ),
  const Funcionalidade(
    titulo: 'Treinamento da revenda',
    descricao: 'Produtos e técnica para vendedores e mecânicos',
    icone: IconeModulo.treinamento,
  ),
  Funcionalidade(
    titulo: 'Conceito',
    descricao: 'Conceitos técnicos por trás das tecnologias J.Assy',
    icone: IconeModulo.conceito,
    tela: () => const ConceitoPage(),
  ),
];
