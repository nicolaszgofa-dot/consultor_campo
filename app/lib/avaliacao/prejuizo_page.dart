import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'avaliacao_estado.dart';
import 'resultado_page.dart';

class PrejuizoPage extends StatefulWidget {
  final AvaliacaoEstado estado;
  final Cenario cenarioInicial;

  const PrejuizoPage({
    super.key,
    required this.estado,
    this.cenarioInicial = Cenario.medio,
  });

  @override
  State<PrejuizoPage> createState() => _PrejuizoPageState();
}

class _PrejuizoPageState extends State<PrejuizoPage> {
  final _precoSaca = TextEditingController();
  final _precoSemente = TextEditingController();
  final _sementesPorSaco = TextEditingController();
  late var _cenario = widget.cenarioInicial;

  @override
  void dispose() {
    _precoSaca.dispose();
    _precoSemente.dispose();
    _sementesPorSaco.dispose();
    super.dispose();
  }

  Widget _campo(TextEditingController c, String rotulo, {String? ajuda}) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: rotulo, helperText: ajuda),
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.estado.identificacao;
    final precoSaca = lerNumero(_precoSaca.text);
    final precoSemente = lerNumero(_precoSemente.text);
    final porSaco = lerNumero(_sementesPorSaco.text);
    final pronto =
        (precoSaca ?? 0) > 0 && (precoSemente ?? 0) > 0 && (porSaco ?? 0) > 0;

    final prejuizo = pronto
        ? PrejuizoCalc.calcular(
            calcularPerda(widget.estado),
            ParametrosPrejuizo(
              precoSacaReais: precoSaca!,
              areaHa: id.areaHa,
              precoSacoSementeReais: precoSemente!,
              sementesPorSaco: porSaco!,
              sementesPorHa: id.parametros.populacaoPorHa,
            ),
          )
        : null;

    return TelaFluxo(
      titulo: 'Prejuízo em R\$',
      passo: 4,
      filhos: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _campo(_precoSaca, 'Preço da saca (R\$)')),
            const SizedBox(width: 10),
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Área'),
                child: Text(
                  '${numeroBr(id.area, id.area % 1 == 0 ? 0 : 1)} '
                  '${id.unidade.rotulo}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _campo(_precoSemente, 'Saco de semente (R\$)')),
            const SizedBox(width: 10),
            Expanded(
              child: _campo(
                _sementesPorSaco,
                'Sementes por saco',
                ajuda: 'ex.: 200000',
              ),
            ),
          ],
        ),
        Seletor<Cenario>(
          opcoes: Cenario.values,
          selecionada: _cenario,
          rotulo: nomeCenario,
          aoEscolher: (c) => setState(() => _cenario = c),
        ),
        if (prejuizo == null)
          const CartaoBranco(
            child: Text(
              'Informe o preço da saca e da semente para calcular o prejuízo.',
              style: TextStyle(fontSize: 15, color: Cores.textoSecundario),
            ),
          )
        else ...[
          _Detalhe(
            prejuizo: prejuizo,
            cenario: _cenario,
            precoSaca: precoSaca!,
          ),
          _Destaque(prejuizo: prejuizo, cenario: _cenario, id: id),
        ],
        const Text(
          'Estimativa a partir das falhas e duplas medidas na trena. O '
          'desperdício considera só as sementes a mais nas duplas.',
          style: TextStyle(fontSize: 12, color: Cores.textoSecundario),
        ),
      ],
    );
  }
}

class _Detalhe extends StatelessWidget {
  final ResultadoPrejuizo prejuizo;
  final Cenario cenario;
  final double precoSaca;

  const _Detalhe({
    required this.prejuizo,
    required this.cenario,
    required this.precoSaca,
  });

  @override
  Widget build(BuildContext context) {
    final c = prejuizo.de(cenario);
    return CartaoBranco(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          _Linha(
            titulo: 'Produtividade perdida',
            detalhe:
                '${numeroBr(c.perdaSacasHa, 2)} sc/ha × ${reais(precoSaca)}',
            valor: reais(c.produtividadeReaisHa),
          ),
          const Divider(height: 1, color: Cores.neutro),
          _Linha(
            titulo: 'Sementes desperdiçadas',
            detalhe:
                '${numeroBr(prejuizo.sementesExtrasHa, 0)} sementes/ha a mais '
                'nas duplas',
            valor: reais(c.sementesReaisHa),
          ),
          const Divider(height: 1, color: Cores.neutro),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Prejuízo por hectare',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  reais(c.totalReaisHa),
                  style: const TextStyle(
                    fontFamily: fonteTitulo,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Cores.prejuizo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final String titulo;
  final String detalhe;
  final String valor;

  const _Linha({
    required this.titulo,
    required this.detalhe,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detalhe,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Cores.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            valor,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Destaque extends StatelessWidget {
  final ResultadoPrejuizo prejuizo;
  final Cenario cenario;
  final Identificacao id;

  const _Destaque({
    required this.prejuizo,
    required this.cenario,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Cores.prejuizo,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Valor que a propriedade deixa de faturar nesta safra',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFE4E0),
            ),
          ),
          Text(
            reais(prejuizo.totalSafraReais(cenario), 0),
            style: const TextStyle(
              fontFamily: fonteTitulo,
              fontSize: 44,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: Cores.branco,
            ),
          ),
          Text(
            '${numeroBr(id.areaHa, id.areaHa % 1 == 0 ? 0 : 1)} ha · faixa de '
            '${reais(prejuizo.totalSafraReais(Cenario.otimista), 0)} a '
            '${reais(prejuizo.totalSafraReais(Cenario.pessimista), 0)}',
            style: const TextStyle(fontSize: 13, color: Color(0xFFFFE4E0)),
          ),
        ],
      ),
    );
  }
}
