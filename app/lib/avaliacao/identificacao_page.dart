import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'avaliacao_estado.dart';
import 'linhas_page.dart';

class IdentificacaoPage extends StatefulWidget {
  const IdentificacaoPage({super.key});

  @override
  State<IdentificacaoPage> createState() => _IdentificacaoPageState();
}

class _IdentificacaoPageState extends State<IdentificacaoPage> {
  final _form = GlobalKey<FormState>();
  final _cliente = TextEditingController();
  final _talhao = TextEditingController();
  final _data = TextEditingController(text: _hoje());
  final _plantadeira = TextEditingController();
  final _sementes = TextEditingController();
  final _espacamento = TextEditingController();
  final _produtividade = TextEditingController();
  final _area = TextEditingController();
  var _cultura = Cultura.soja;
  var _unidade = UnidadeArea.hectare;

  static String _hoje() {
    final d = DateTime.now();
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}/${d.year}';
  }

  @override
  void dispose() {
    for (final c in [
      _cliente,
      _talhao,
      _data,
      _plantadeira,
      _sementes,
      _espacamento,
      _produtividade,
      _area,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _positivo(String? v) =>
      (lerNumero(v ?? '') ?? 0) > 0 ? null : 'Informe um valor';

  String? _validarEspacamento(String? v) {
    final valor = lerNumero(v ?? '');
    if (valor == null || valor <= 0) return 'Informe em metros, ex.: 0,50';
    if (PlantabilidadeCalc.pareceCentimetros(valor)) {
      return 'Parece centímetros. Use metros, ex.: 0,50';
    }
    return null;
  }

  void _comecar() {
    if (!_form.currentState!.validate()) return;
    final id = Identificacao(
      cliente: _cliente.text.trim(),
      talhao: _talhao.text.trim(),
      data: _data.text.trim(),
      plantadeira: _plantadeira.text.trim(),
      cultura: _cultura,
      sementesPorMetro: lerNumero(_sementes.text)!,
      espacamentoLinhasM: lerNumero(_espacamento.text)!,
      produtividadeScHa: lerNumero(_produtividade.text)!,
      area: lerNumero(_area.text)!,
      unidade: _unidade,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LinhasPage(estado: AvaliacaoEstado(id)),
      ),
    );
  }

  Widget _campo(
    TextEditingController c,
    String rotulo, {
    bool numero = false,
    String? Function(String?)? validar,
  }) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: rotulo),
      keyboardType: numero
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: validar,
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spm = lerNumero(_sementes.text);
    final esp = lerNumero(_espacamento.text);
    final derivados =
        spm != null &&
            spm > 0 &&
            esp != null &&
            esp > 0 &&
            !PlantabilidadeCalc.pareceCentimetros(esp)
        ? ParametrosPlantabilidade(
            sementesPorMetro: spm,
            espacamentoLinhasM: esp,
          )
        : null;

    return Form(
      key: _form,
      child: TelaFluxo(
        titulo: 'Nova avaliação de plantio',
        passo: 1,
        filhos: [
          const RotuloSecao('Lavoura'),
          _campo(_cliente, 'Cliente e fazenda'),
          Row(
            children: [
              Expanded(child: _campo(_talhao, 'Talhão')),
              const SizedBox(width: 10),
              Expanded(child: _campo(_data, 'Data')),
            ],
          ),
          Seletor<Cultura>(
            opcoes: Cultura.values,
            selecionada: _cultura,
            rotulo: nomeCultura,
            aoEscolher: (c) => setState(() => _cultura = c),
          ),
          _campo(_plantadeira, 'Plantadeira e configuração'),
          const SizedBox(height: 4),
          const RotuloSecao('Regulagem e potencial'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _campo(
                  _sementes,
                  'Sementes/m',
                  numero: true,
                  validar: _positivo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _campo(
                  _espacamento,
                  'Entre linhas (m)',
                  numero: true,
                  validar: _validarEspacamento,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _campo(
                  _produtividade,
                  'sc/ha esperadas',
                  numero: true,
                  validar: _positivo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _campo(_area, 'Área', numero: true, validar: _positivo),
              ),
            ],
          ),
          Seletor<UnidadeArea>(
            opcoes: UnidadeArea.values,
            selecionada: _unidade,
            rotulo: (u) => u.rotulo,
            aoEscolher: (u) => setState(() => _unidade = u),
          ),
          if (derivados != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Cores.verdeClaro,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Derivado(
                    rotulo: 'População alvo',
                    valor: '${numeroBr(derivados.populacaoPorHa, 0)} pl/ha',
                  ),
                  _Derivado(
                    rotulo: 'Espaçamento ideal',
                    valor: '${numeroBr(derivados.espacamentoIdealCm)} cm',
                    direita: true,
                  ),
                ],
              ),
            ),
        ],
        rodape: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.straighten, size: 18, color: Cores.textoSecundario),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Avaliação com trena: no mínimo 5 linhas de 10 m.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Cores.textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _comecar,
              child: const Text('Começar leituras'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Derivado extends StatelessWidget {
  final String rotulo;
  final String valor;
  final bool direita;

  const _Derivado({
    required this.rotulo,
    required this.valor,
    this.direita = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: direita
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: const TextStyle(fontSize: 13, color: Cores.verdeTexto),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontFamily: fonteTitulo,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
