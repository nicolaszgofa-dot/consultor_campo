import 'package:flutter/material.dart';

import '../configurador/configurador_widgets.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import 'proposta_fluxo_page.dart';

/// Situação de uma proposta no histórico (em conceito).
enum SituacaoProposta {
  gerada('Gerada', Cores.neutro, Cores.textoSecundario),
  enviada('Enviada', Color(0xFFE6EEFB), Cores.dupla),
  aceita('Aceita', Cores.verdeClaro, Cores.verdeTexto),
  perdida('Perdida', Color(0xFFFDECEA), Cores.prejuizo),
  vencida('Vencida', Color(0xFFFDF3E3), Cores.atencao);

  final String nome;
  final Color fundo;
  final Color cor;

  const SituacaoProposta(this.nome, this.fundo, this.cor);
}

/// Linhas ilustrativas do histórico: nada é salvo até existir um servidor.
const _exemplos = [
  (
    'P-2026-014',
    'Fazenda Santa Rita',
    'Selenium Elétric · 66 linhas',
    'R\$ 481.800',
    SituacaoProposta.enviada,
  ),
  (
    'P-2026-013',
    'Agropecuária Boa Vista',
    'Titanium Elétric · 17 linhas + Selenium Neo · 12 linhas',
    'R\$ 245.900',
    SituacaoProposta.gerada,
  ),
  (
    'P-2026-012',
    'Sítio Três Irmãos',
    'Titanium Elétric (só motorização) · 9 linhas',
    'R\$ 76.500',
    SituacaoProposta.aceita,
  ),
  (
    'P-2026-010',
    'Fazenda Esperança',
    'Titanium Elétric · 24 linhas · motivo: preço',
    'R\$ 204.000',
    SituacaoProposta.perdida,
  ),
];

/// Card "Proposta comercial". O histórico aparece só como conceito.
class PropostasPage extends StatelessWidget {
  const PropostasPage({super.key});

  void _nova(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const PropostaFluxoPage()));

  @override
  Widget build(BuildContext context) {
    return TelaFluxo(
      titulo: 'Proposta comercial',
      filhos: [
        const Aviso(
          'Em conceito: nada é registrado nem salvo. O histórico abaixo é '
          'ilustrativo e passa a funcionar quando houver um servidor. Hoje a '
          'proposta é gerada, compartilhada e descartada.',
          tipo: TipoAviso.atencao,
        ),
        Row(
          children: [
            const Expanded(child: RotuloSecao('Histórico (exemplo)')),
            Wrap(
              spacing: 6,
              children: [for (final s in SituacaoProposta.values) _Situacao(s)],
            ),
          ],
        ),
        Opacity(
          opacity: 0.6,
          child: Column(
            children: [
              for (final (num, cliente, itens, total, situacao) in _exemplos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CartaoBranco(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$num · EXEMPLO',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: Cores.textoSecundario,
                                ),
                              ),
                              Text(
                                cliente,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                itens,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Cores.textoSecundario,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _Situacao(situacao),
                            const SizedBox(height: 4),
                            Text(
                              total,
                              style: const TextStyle(
                                fontFamily: fonteTitulo,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Aviso(
          'Com servidor: abrir uma proposta mostra o PDF enviado, com nova '
          'versão, duplicar para outro cliente e mudar a situação. Ao marcar '
          '"Perdida", o vendedor informa o motivo.',
        ),
      ],
      rodape: FilledButton.icon(
        onPressed: () => _nova(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova proposta'),
      ),
    );
  }
}

class _Situacao extends StatelessWidget {
  final SituacaoProposta situacao;

  const _Situacao(this.situacao);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: situacao.fundo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        situacao.nome.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: situacao.cor,
        ),
      ),
    );
  }
}
