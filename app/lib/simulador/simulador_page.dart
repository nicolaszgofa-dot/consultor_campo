import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/icones_modulos.dart';

/// Protótipo navegável das telas do sistema Elétric (Adobe XD).
final simuladorEletric = Uri.parse(
  'https://xd.adobe.com/view/3f284216-b6a3-4de3-b087-694c4e50d7bb-6a7b/'
  '?fullscreen&hints=off',
);

/// Apresenta o simulador e abre o protótipo no navegador (ele roda fora do
/// app e precisa de internet).
class SimuladorPage extends StatelessWidget {
  /// Troca a abertura do link nos testes.
  final Future<bool> Function(Uri)? abrirLink;

  const SimuladorPage({super.key, this.abrirLink});

  Future<void> _abrir(BuildContext context) async {
    final mensageiro = ScaffoldMessenger.of(context);
    var abriu = false;
    try {
      abriu =
          await (abrirLink ??
              (u) => launchUrl(u, mode: LaunchMode.externalApplication))(
            simuladorEletric,
          );
    } catch (_) {
      abriu = false;
    }
    if (!abriu) {
      mensageiro.showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir o simulador. Confira a internet e tente '
            'de novo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const dicas = [
      'Toque nos botões da tela como no monitor do trator.',
      'Funciona melhor com o celular deitado ou no tablet.',
      'Precisa de internet: o simulador abre no navegador.',
    ];
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoFluxo(titulo: 'Simulador Elétric'),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    CartaoBranco(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Cores.verdeClaro,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const IconeDoModulo(IconeModulo.simulador),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Telas do sistema Elétric',
                                  style: TextStyle(
                                    fontFamily: fonteTitulo,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Simulação do que o operador vê no monitor '
                                  'ISOBUS do trator com o Titanium e o '
                                  'Selenium Elétric. Use para mostrar ao '
                                  'produtor como o sistema funciona antes da '
                                  'instalação.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    color: Cores.textoSecundario,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final d in dicas)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: Cores.verdeTexto,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _abrir(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Abrir simulador'),
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
