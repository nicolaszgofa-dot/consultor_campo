import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/material.dart';

import '../avaliacao/avaliacao_estado.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import '../ui/formatos.dart';
import 'avaliacao_emergencia.dart';
import 'emergencia_page.dart';

class NovaEmergenciaPage extends StatefulWidget {
  final RepositorioEmergencia repositorio;

  const NovaEmergenciaPage({super.key, required this.repositorio});

  @override
  State<NovaEmergenciaPage> createState() => _NovaEmergenciaPageState();
}

class _NovaEmergenciaPageState extends State<NovaEmergenciaPage> {
  final _form = GlobalKey<FormState>();
  final _talhao = TextEditingController();
  final _plantio = TextEditingController(text: dataBr(DateTime.now()));
  final _sementes = TextEditingController();
  final _linhas = TextEditingController(text: '5');
  final _comprimento = TextEditingController(text: '10');
  var _cultura = Cultura.milho;

  @override
  void dispose() {
    for (final c in [_talhao, _plantio, _sementes, _linhas, _comprimento]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _positivo(String? v) =>
      (lerNumero(v ?? '') ?? 0) > 0 ? null : 'Informe um valor';

  Future<void> _comecar() async {
    if (!_form.currentState!.validate()) return;
    final avaliacao = AvaliacaoEmergencia(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      talhao: _talhao.text.trim(),
      cultura: _cultura,
      dataPlantio: lerData(_plantio.text)!,
      sementesPorMetro: lerNumero(_sementes.text)!,
      linhas: lerNumero(_linhas.text)!.round(),
      comprimentoLinhaM: lerNumero(_comprimento.text)!,
    );
    await widget.repositorio.salvar(avaliacao);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EmergenciaPage(
          repositorio: widget.repositorio,
          avaliacao: avaliacao,
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController c,
    String rotulo, {
    bool numero = false,
    String? Function(String?)? validar,
  }) => TextFormField(
    controller: c,
    decoration: InputDecoration(labelText: rotulo),
    keyboardType: numero
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    validator: validar,
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: TelaFluxo(
        titulo: 'Nova avaliação de emergência',
        filhos: [
          const RotuloSecao('Lavoura'),
          _campo(_talhao, 'Talhão'),
          Seletor<Cultura>(
            opcoes: Cultura.values,
            selecionada: _cultura,
            rotulo: nomeCultura,
            aoEscolher: (c) => setState(() => _cultura = c),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _campo(
                  _plantio,
                  'Data do plantio',
                  validar: (v) {
                    final d = lerData(v ?? '');
                    if (d == null) return 'Use dd/mm/aaaa';
                    if (d.isAfter(DateTime.now())) return 'Data futura';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _campo(
                  _sementes,
                  'Sementes/m',
                  numero: true,
                  validar: _positivo,
                ),
              ),
            ],
          ),
          const RotuloSecao('Trecho marcado'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _campo(
                  _linhas,
                  'Linhas',
                  numero: true,
                  validar: (v) {
                    final n = lerNumero(v ?? '');
                    return n == null || n < 1 || n > 20 ? 'De 1 a 20' : null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _campo(
                  _comprimento,
                  'Metros por linha',
                  numero: true,
                  validar: _positivo,
                ),
              ),
            ],
          ),
          const Text(
            'Marque o trecho com estacas para voltar nas mesmas plantas todos '
            'os dias.',
            style: TextStyle(fontSize: 14, color: Cores.textoSecundario),
          ),
        ],
        rodape: FilledButton(
          onPressed: _comecar,
          child: const Text('Começar marcação'),
        ),
      ),
    );
  }
}
