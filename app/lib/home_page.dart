import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

import 'avaliacao/identificacao_page.dart';
import 'em_breve_page.dart';
import 'funcionalidades.dart';
import 'tema.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _abrir(BuildContext context, Widget tela) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _Cabecalho(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _CartaoAvaliacao(
                      aoAbrir: () => _abrir(context, const IdentificacaoPage()),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () =>
                            _abrir(context, const FertilizantePage()),
                        icon: const Icon(Icons.scale_outlined),
                        label: const Text('Calculadora de fertilizante'),
                        style: TextButton.styleFrom(
                          foregroundColor: Cores.verdeTexto,
                          textStyle: const TextStyle(
                            fontFamily: 'Barlow',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final f in emBreve) ...[
                      _CartaoEmBreve(
                        funcionalidade: f,
                        aoAbrir: () => _abrir(
                          context,
                          EmBrevePage(
                            titulo: f.titulo,
                            descricao: f.descricao,
                            icone: f.icone,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
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

class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Cores.verdeEscuro,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Cores.verde,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco, color: Cores.verdeEscuro),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'CONSULTOR DE CAMPO',
                    style: TextStyle(
                      color: Cores.cinza,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'O que vamos fazer hoje?',
                style: TextStyle(
                  fontFamily: fonteTitulo,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: Cores.branco,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Escolha uma funcionalidade',
                style: TextStyle(fontSize: 15, color: Cores.cinza),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartaoAvaliacao extends StatelessWidget {
  final VoidCallback aoAbrir;

  const _CartaoAvaliacao({required this.aoAbrir});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Cores.verde,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: aoAbrir,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Cores.verdeEscuro,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.straighten,
                      color: Cores.verdeVivo,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avaliação de plantio',
                          style: TextStyle(
                            fontFamily: fonteTitulo,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Cores.verdeEscuro,
                          ),
                        ),
                        Text(
                          'Plantabilidade com trena, perda e prejuízo em R\$',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Cores.verdeEscuro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Cores.verdeEscuro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nova avaliação',
                      style: TextStyle(
                        color: Cores.branco,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.chevron_right, color: Cores.branco),
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

class _CartaoEmBreve extends StatelessWidget {
  final Funcionalidade funcionalidade;
  final VoidCallback aoAbrir;

  const _CartaoEmBreve({required this.funcionalidade, required this.aoAbrir});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Cores.branco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Cores.borda),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: aoAbrir,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Cores.neutro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(funcionalidade.icone, color: Cores.cinzaEscuro),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          funcionalidade.titulo,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Cores.neutro,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'EM BREVE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: Cores.textoSecundario,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      funcionalidade.descricao,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Cores.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Cores.cinza),
            ],
          ),
        ),
      ),
    );
  }
}
