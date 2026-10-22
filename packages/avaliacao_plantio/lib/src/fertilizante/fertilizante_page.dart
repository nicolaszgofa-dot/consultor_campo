import 'package:flutter/material.dart';

import '../ui/comum.dart';
import 'fertilizante_calc.dart';

class FertilizantePage extends StatefulWidget {
  const FertilizantePage({super.key});

  @override
  State<FertilizantePage> createState() => _FertilizantePageState();
}

class _FertilizantePageState extends State<FertilizantePage> {
  final _formKey = GlobalKey<FormState>();
  final _dose = TextEditingController();
  final _espacamento = TextEditingController();
  final _distancia = TextEditingController();
  final _linhas = TextEditingController();
  ParametrosFertilizante? _parametros;

  /// Gramas por linha; null = linha ainda não preenchida.
  List<double?> _gramas = [];

  @override
  void dispose() {
    _dose.dispose();
    _espacamento.dispose();
    _distancia.dispose();
    _linhas.dispose();
    super.dispose();
  }

  void _gerarLinhas() {
    if (!_formKey.currentState!.validate()) return;
    final parametros = ParametrosFertilizante(
      doseKgHa: lerNumero(_dose.text)!,
      espacamentoLinhasM: lerNumero(_espacamento.text)!,
      distanciaColetaM: lerNumero(_distancia.text)!,
      numeroLinhas: lerNumero(_linhas.text)!.round(),
    );
    setState(() {
      _parametros = parametros;
      _gramas = List<double?>.filled(parametros.numeroLinhas, null);
    });
  }

  void _reiniciar() {
    setState(() {
      _parametros = null;
      _gramas = [];
    });
  }

  Future<void> _editarLinha(int indice) async {
    final controller = TextEditingController(
      text: _gramas[indice] == null ? '' : formatar(_gramas[indice]!),
    );
    final valor = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Linha ${indice + 1}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Gramas coletadas'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, lerNumero(controller.text)),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (valor != null && valor >= 0) {
      setState(() => _gramas[indice] = valor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parametros = _parametros;
    final preenchidas = _gramas.whereType<double>().toList();
    final resultado = parametros == null
        ? null
        : FertilizanteCalc.calcular(parametros, preenchidas);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertilizante'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recomeçar',
            onPressed: _reiniciar,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Secao(
            titulo: 'PARÂMETROS',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CampoNumero(
                          controller: _dose,
                          rotulo: 'Kg/hectare',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CampoNumero(
                          controller: _espacamento,
                          rotulo: 'Espaç. linhas (m)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CampoNumero(
                          controller: _distancia,
                          rotulo: 'Distância coleta (m)',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CampoNumero(
                          controller: _linhas,
                          rotulo: 'Nº de linhas',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _gerarLinhas,
                      child: const Text('Gerar linhas'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (parametros != null) ...[
            Secao(
              titulo: 'REFERÊNCIA',
              child: Center(
                child: Column(
                  children: [
                    Text(
                      formatar(parametros.idealPorAmostraG, 2),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: corOk,
                      ),
                    ),
                    const Text('Ideal por amostra (g)'),
                  ],
                ),
              ),
            ),
            Secao(
              titulo: 'COLETA POR LINHA',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${preenchidas.length} de ${_gramas.length} linhas preenchidas',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _gramas.length; i++)
                        CartaoValor(
                          titulo: 'L. ${i + 1}',
                          subtitulo: _gramas[i] == null
                              ? 'toque p/ informar'
                              : '${formatar(_gramas[i]!)} g',
                          ok: _gramas[i] == null ||
                              FertilizanteCalc.linhaDentroDaTolerancia(
                                _gramas[i]!,
                                parametros.idealPorAmostraG,
                              ),
                          onTap: () => _editarLinha(i),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (resultado != null)
            Secao(
              titulo: 'RESULTADO',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${formatar(resultado.cvPercentual)}%',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: resultado.dentroDoPadrao ? corOk : corAlerta,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        resultado.dentroDoPadrao
                            ? 'Dentro do padrão'
                            : 'Atenção',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: resultado.dentroDoPadrao ? corOk : corAlerta,
                        ),
                      ),
                    ],
                  ),
                  const Text('CV'),
                  const SizedBox(height: 8),
                  Text(
                    'Média ${formatar(resultado.mediaG, 2)} g  |  '
                    'DP ${formatar(resultado.desvioPadraoG, 2)} g  |  '
                    '${preenchidas.length} amostras',
                  ),
                  Text('Dose real: ${formatar(resultado.doseRealKgHa)} kg/ha'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
