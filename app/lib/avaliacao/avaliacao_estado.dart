import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:flutter/foundation.dart';

import '../ui/formatos.dart';

enum UnidadeArea {
  hectare('ha', 1),
  alqueirePaulista('alq. paulista', 2.42),
  alqueireMineiro('alq. mineiro', 4.84);

  final String rotulo;

  /// Hectares por unidade.
  final double hectares;

  const UnidadeArea(this.rotulo, this.hectares);
}

String nomeCultura(Cultura c) => switch (c) {
  Cultura.soja => 'Soja',
  Cultura.milho => 'Milho',
  Cultura.feijao => 'Feijão',
};

class Identificacao {
  final String cliente;
  final String talhao;
  final String data;
  final String plantadeira;
  final Cultura cultura;
  final double sementesPorMetro;
  final double espacamentoLinhasM;
  final double produtividadeScHa;
  final double area;
  final UnidadeArea unidade;

  const Identificacao({
    this.cliente = '',
    this.talhao = '',
    this.data = '',
    this.plantadeira = '',
    required this.cultura,
    required this.sementesPorMetro,
    required this.espacamentoLinhasM,
    required this.produtividadeScHa,
    required this.area,
    this.unidade = UnidadeArea.hectare,
  });

  double get areaHa => area * unidade.hectares;

  double get produtividadeKgHa => produtividadeScHa * 60;

  ParametrosPlantabilidade get parametros => ParametrosPlantabilidade(
    sementesPorMetro: sementesPorMetro,
    espacamentoLinhasM: espacamentoLinhasM,
  );
}

/// Leituras de trena de uma avaliação em andamento.
class AvaliacaoEstado extends ChangeNotifier {
  final Identificacao identificacao;
  final List<List<double>> _linhas;
  int _atual = 0;

  AvaliacaoEstado(this.identificacao, {List<List<double>>? linhas})
    : _linhas =
          linhas ??
          [
            for (var i = 0; i < RegrasAvaliacao.linhasRecomendadas; i++)
              <double>[],
          ];

  int get linhaAtual => _atual;

  int get quantidadeLinhas => _linhas.length;

  ResultadoAvaliacao get resultado =>
      AvaliacaoCalc.calcular(identificacao.parametros, _linhas);

  void selecionar(int indice) {
    _atual = indice;
    notifyListeners();
  }

  void adicionarLinha() {
    _linhas.add(<double>[]);
    _atual = _linhas.length - 1;
    notifyListeners();
  }

  /// Adiciona uma leitura na linha atual. Retorna a mensagem de erro, ou nulo.
  /// Ao completar 10 m, passa para a próxima linha incompleta.
  String? adicionarLeitura(double cm) {
    final linha = _linhas[_atual];
    final ultima = linha.isEmpty ? 0.0 : linha.last;
    if (cm <= ultima) {
      return 'A leitura deve ser maior que ${numeroBr(ultima)} cm.';
    }
    linha.add(cm);
    final limite = RegrasAvaliacao.comprimentoMinimoCm;
    if (ultima < limite && cm >= limite) {
      final proxima = _linhas.indexWhere((l) => l.isEmpty || l.last < limite);
      if (proxima >= 0) _atual = proxima;
    }
    notifyListeners();
    return null;
  }

  void removerUltima() {
    final linha = _linhas[_atual];
    if (linha.isEmpty) return;
    linha.removeLast();
    notifyListeners();
  }
}
