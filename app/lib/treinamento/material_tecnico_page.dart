import 'package:flutter/material.dart';

import '../desligamento/desligamento_page.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import 'treinamento_dados.dart';
import 'treinamento_page.dart';

/// Ferramenta usada no campo, na instalação ou na regulagem.
class FerramentaCampo {
  final String titulo;
  final String resumo;
  final IconData icone;
  final Widget Function() tela;

  const FerramentaCampo({
    required this.titulo,
    required this.resumo,
    required this.icone,
    required this.tela,
  });
}

final ferramentasCampo = <FerramentaCampo>[
  FerramentaCampo(
    titulo: 'Desligamento de linha',
    resumo:
        'Monitor e licenças, medidas da plantadeira e ajuste do liga e '
        'desliga no campo',
    icone: Icons.tune,
    tela: () => const DesligamentoPage(),
  ),
];

/// Entrada do Material técnico (equipe e revenda): as ferramentas de campo e
/// a capacitação, cada uma num card.
class MaterialTecnicoPage extends StatelessWidget {
  const MaterialTecnicoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final perguntas = modulosTreino.fold<int>(
      0,
      (s, m) => s + m.perguntas.length,
    );
    void abrir(Widget tela) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
    return _Lista(
      titulo: 'Material técnico',
      intro:
          'Linha Elétric: ferramentas para instalar e regular no campo e a '
          'capacitação com aulas e testes.',
      filhos: [
        _CartaoGrande(
          titulo: 'Ferramentas de campo',
          resumo: 'Para configurar e regular a máquina na hora',
          detalhe: ferramentasCampo.length == 1
              ? '1 ferramenta: ${ferramentasCampo.single.titulo}'
              : '${ferramentasCampo.length} ferramentas',
          icone: Icons.handyman_outlined,
          escuro: true,
          aoAbrir: () => abrir(const FerramentasCampoPage()),
        ),
        _CartaoGrande(
          titulo: 'Capacitação',
          resumo: 'Produto, instalação, regulagem, configuração e alarmes',
          detalhe: '${modulosTreino.length} módulos · $perguntas perguntas',
          icone: Icons.school_outlined,
          aoAbrir: () => abrir(CapacitacaoPage()),
        ),
      ],
      rodape:
          'Fonte: treinamento da Linha Elétric, manuais do Selenium e do '
          'Titanium Elétric e tutoriais J.Assy de monitores ISOBUS.',
    );
  }
}

/// As ferramentas de campo, uma por card.
class FerramentasCampoPage extends StatelessWidget {
  const FerramentasCampoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _Lista(
      titulo: 'Ferramentas de campo',
      intro:
          'Para usar na máquina do cliente: configurar, medir e ajustar. '
          'Nada fica salvo.',
      filhos: [
        for (final f in ferramentasCampo)
          _CartaoGrande(
            titulo: f.titulo,
            resumo: f.resumo,
            icone: f.icone,
            escuro: true,
            aoAbrir: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => f.tela())),
          ),
      ],
    );
  }
}

class _Lista extends StatelessWidget {
  final String titulo;
  final String intro;
  final List<Widget> filhos;
  final String? rodape;

  const _Lista({
    required this.titulo,
    required this.intro,
    required this.filhos,
    this.rodape,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CabecalhoFluxo(titulo: titulo),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    Text(
                      intro,
                      style: const TextStyle(fontSize: 16, color: Cores.tinta),
                    ),
                    const SizedBox(height: 16),
                    for (final f in filhos) ...[f, const SizedBox(height: 12)],
                    if (rodape != null)
                      Text(
                        rodape!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Cores.textoSecundario,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de entrada: escuro para ferramentas, branco para a capacitação.
class _CartaoGrande extends StatelessWidget {
  final String titulo;
  final String resumo;
  final String? detalhe;
  final IconData icone;
  final bool escuro;
  final VoidCallback aoAbrir;

  const _CartaoGrande({
    required this.titulo,
    required this.resumo,
    required this.icone,
    required this.aoAbrir,
    this.detalhe,
    this.escuro = false,
  });

  @override
  Widget build(BuildContext context) {
    final corTitulo = escuro ? Cores.branco : Cores.tinta;
    final corResumo = escuro ? const Color(0xFFCFE8C9) : Cores.textoSecundario;
    return Semantics(
      button: true,
      label: titulo,
      child: Material(
        color: escuro ? Cores.verdeEscuro : Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: escuro ? BorderSide.none : const BorderSide(color: Cores.borda),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoAbrir,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: escuro ? Cores.verde : Cores.verdeClaro,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icone,
                    size: 30,
                    color: escuro ? Cores.branco : Cores.verdeTexto,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontFamily: fonteTitulo,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: corTitulo,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        resumo,
                        style: TextStyle(fontSize: 14, color: corResumo),
                      ),
                      if (detalhe != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          detalhe!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: escuro ? Cores.verdeVivo : Cores.verdeTexto,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: corTitulo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
