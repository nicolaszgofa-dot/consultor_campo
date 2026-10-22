import 'package:flutter/material.dart';

import '../ui/comum.dart';
import 'plantabilidade_calc.dart';

class PlantabilidadePage extends StatefulWidget {
  const PlantabilidadePage({super.key});

  @override
  State<PlantabilidadePage> createState() => _PlantabilidadePageState();
}

class _PlantabilidadePageState extends State<PlantabilidadePage> {
  final _formKey = GlobalKey<FormState>();
  final _sementes = TextEditingController();
  final _espacamento = TextEditingController();
  final _leitura = TextEditingController();
  final _leituras = <double>[];
  ParametrosPlantabilidade? _parametros;

  @override
  void dispose() {
    _sementes.dispose();
    _espacamento.dispose();
    _leitura.dispose();
    super.dispose();
  }

  void _confirmarParametros() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _parametros = ParametrosPlantabilidade(
        sementesPorMetro: lerNumero(_sementes.text)!,
        espacamentoLinhasM: lerNumero(_espacamento.text)!,
      );
    });
  }

  void _adicionarLeitura() {
    final valor = lerNumero(_leitura.text);
    final ultima = _leituras.isEmpty ? 0.0 : _leituras.last;
    if (valor == null || valor <= ultima) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A leitura deve ser maior que a anterior.'),
        ),
      );
      return;
    }
    setState(() {
      _leituras.add(valor);
      _leitura.clear();
    });
  }

  void _removerUltima() {
    if (_leituras.isEmpty) return;
    setState(() => _leituras.removeLast());
  }

  void _reiniciar() {
    setState(() {
      _leituras.clear();
      _leitura.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final parametros = _parametros;
    final resultado = parametros == null || _leituras.isEmpty
        ? null
        : PlantabilidadeCalc.calcular(parametros, _leituras);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantabilidade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar medições',
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
                  CampoNumero(
                    controller: _sementes,
                    rotulo: 'Sementes por metro',
                  ),
                  const SizedBox(height: 12),
                  CampoNumero(
                    controller: _espacamento,
                    rotulo: 'Espaçamento entre linhas (m)',
                    validator: (v) {
                      final valor = lerNumero(v ?? '');
                      if (valor == null || valor <= 0) return 'Valor inválido';
                      if (PlantabilidadeCalc.pareceCentimetros(valor)) {
                        return 'Parece que você digitou em centímetros. '
                            'Use metros, ex.: 0,50';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _confirmarParametros,
                      child: const Text('Confirmar parâmetros'),
                    ),
                  ),
                  if (parametros != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        Etiqueta(
                          'Esp. ideal: ${formatar(parametros.espacamentoIdealCm)} cm',
                          cor: corOk,
                        ),
                        Etiqueta(
                          'm linear/ha: ${formatarInteiro(parametros.metrosLinearesPorHa)}',
                          cor: corOk,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Secao(
            titulo: 'ADICIONAR MEDIÇÃO',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estique a trena com o zero na primeira planta e informe a '
                  'posição de cada planta seguinte.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _leitura,
                        enabled: parametros != null,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: parametros == null
                              ? 'Confirme os parâmetros primeiro'
                              : 'Leitura da trena (cm)',
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _adicionarLeitura(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      heroTag: null,
                      onPressed: parametros == null ? null : _adicionarLeitura,
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (resultado != null) ...[
            Secao(
              titulo: 'RESULTADOS',
              child: Column(
                children: [
                  Center(
                    child: Text(
                      '${formatar(resultado.cvPercentual)}%',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Center(child: Text('CV')),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Média: ${formatar(resultado.mediaCm, 2)} cm  |  '
                      'DV: ${formatar(resultado.desvioPadraoCm, 2)}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Etiqueta(
                        'Aceitáveis: ${formatar(resultado.percentualAceitaveis)}%',
                        cor: corOk,
                      ),
                      Etiqueta(
                        'Falhas: ${formatar(resultado.percentualFalhas)}%',
                        cor: corAlerta,
                      ),
                      Etiqueta(
                        'Duplas: ${formatar(resultado.percentualDuplas)}%',
                        cor: corAlerta,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'População: ${formatarInteiro(resultado.populacaoPorHa)} plantas/ha',
                    style: const TextStyle(
                      color: corOk,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final e in resultado.espacamentos.reversed)
                  CartaoValor(
                    titulo: formatar(e.valorCm),
                    subtitulo: 'trena ${formatar(e.leituraTrenaCm)}',
                    ok: e.classe == ClasseEspacamento.aceitavel,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _removerUltima,
                icon: const Icon(Icons.undo),
                label: const Text('Remover última leitura'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
