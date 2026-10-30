import 'package:flutter/foundation.dart';
import 'package:roi/roi.dart';

import '../roi/proposta/proposta_dados.dart';
import '../roi/roi_estado.dart';
import '../ui/formatos.dart';

/// Um produto em edição: o texto como digitado.
class ItemEdicao {
  ProdutoProposta produto;
  Fornecimento fornecimento;
  String plantadeira = '';
  String linhas = '';
  String valorLinha = '';

  /// Vazio = sem condição de campanha.
  String valorCampanha = '';

  ItemEdicao(this.produto) : fornecimento = produto.fornecimentos.keys.first;

  int get linhasNum => (lerReais(linhas) ?? 0).round();
  double get valorNum => lerReais(valorLinha) ?? 0;
  double? get campanhaNum =>
      valorCampanha.trim().isEmpty ? null : lerReais(valorCampanha);

  double get total => linhasNum * (campanhaNum ?? valorNum);

  String? get erro {
    final nome = produto.nome;
    if (plantadeira.trim().isEmpty) return '$nome: informe a plantadeira.';
    if (linhasNum <= 0) {
      return '$nome: informe o número de ${produto.unidades}.';
    }
    if (valorNum <= 0) {
      return '$nome: informe o valor por ${produto.unidade}.';
    }
    final campanha = campanhaNum;
    if (valorCampanha.trim().isNotEmpty &&
        (campanha == null || campanha <= 0)) {
      return '$nome: valor de campanha inválido.';
    }
    return null;
  }

  ItemProposta get item => ItemProposta(
    produto: produto,
    fornecimento: fornecimento,
    plantadeira: plantadeira.trim(),
    linhas: linhasNum,
    valorLinha: valorNum,
    valorCampanha: campanhaNum,
  );
}

/// Proposta comercial separada, em 5 etapas. Fica só na memória: nada é
/// registrado nem salvo até existir um servidor.
class PropostaEstado extends ChangeNotifier {
  static const etapaPrevia = 4;
  static const nomesEtapas = [
    'Cliente',
    'Itens',
    'Condições',
    'Anexos',
    'Prévia',
  ];

  int etapa = 0;

  final Map<String, String> campos = {};
  final List<ItemEdicao> itens = [];
  final List<(String, String)> parcelas = [];

  bool paginasProdutos = true;
  bool comRetorno = false;

  /// Premissas do ROI preenchidas para esta proposta.
  final RoiEstado roi = RoiEstado();

  String texto(String chave) => campos[chave] ?? '';

  /// Se o vendedor já preencheu algo (para confirmar antes de descartar).
  bool get editou =>
      campos.values.any((v) => v.trim().isNotEmpty) || itens.isNotEmpty;

  void mudar(String chave, String valor) {
    campos[chave] = valor;
    notifyListeners();
  }

  void adicionar(ProdutoProposta produto) {
    itens.add(ItemEdicao(produto));
    notifyListeners();
  }

  void remover(int i) {
    itens.removeAt(i);
    notifyListeners();
  }

  void mudarItem(int i, void Function(ItemEdicao) mudanca) {
    mudanca(itens[i]);
    notifyListeners();
  }

  void adicionarParcela() {
    parcelas.add(('', ''));
    notifyListeners();
  }

  void mudarParcela(int i, {String? fracao, String? quando}) {
    final (f, q) = parcelas[i];
    parcelas[i] = (fracao ?? f, quando ?? q);
    notifyListeners();
  }

  void removerParcela(int i) {
    parcelas.removeAt(i);
    notifyListeners();
  }

  void anexos({bool? produtos, bool? retorno}) {
    paginasProdutos = produtos ?? paginasProdutos;
    comRetorno = retorno ?? comRetorno;
    notifyListeners();
  }

  double get total => itens.fold(0, (s, i) => s + i.total);

  /// Linhas de plantio (sem somar duas vezes a mesma plantadeira).
  int get linhas => dados(DateTime(2000)).linhas;

  double _pct(String t) => (lerNumero(t) ?? 0) / 100;
  double get entrada => _pct(texto('entrada'));
  double get somaPagamento =>
      entrada + parcelas.fold(0.0, (s, p) => s + _pct(p.$1));
  bool get temPagamento =>
      texto('entrada').trim().isNotEmpty ||
      parcelas.any((p) => p.$1.trim().isNotEmpty);

  /// O ROI com o investimento e as linhas da proposta. Antes de abrir o ROI,
  /// [prepararRoi] já coloca esses valores nos campos.
  PremissasRoi get premissasRoi =>
      premissasDaProposta(roi.premissas, dados(DateTime(2000)));

  /// O que falta no ROI para entrar na proposta. Vazio = pode usar.
  List<String> get pendenciasRoi => [
    if (roi.premissas.areaHa <= 0) 'Informe a área plantada no ROI.',
    if (roi.premissas.vidaSafras <= 0) 'Informe a vida econômica no ROI.',
  ];

  void prepararRoi() {
    if (total > 0) roi.mudar('inv', numeroBr(total, 2));
    if (linhas > 0) roi.mudar('linhas', '$linhas');
  }

  /// Por que não dá para sair da etapa atual. Nulo = pode avançar.
  String? get bloqueio => switch (etapa) {
    0 => [
      if (texto('cliente').trim().isEmpty) 'Informe o cliente.',
      if (texto('cidade').trim().isEmpty) 'Informe a cidade da proposta.',
      if (texto('consultor').trim().isEmpty) 'Informe o consultor.',
    ].firstOrNull,
    1 =>
      itens.isEmpty
          ? 'Adicione pelo menos um produto.'
          : itens.map((i) => i.erro).nonNulls.firstOrNull,
    2 =>
      temPagamento && (somaPagamento - 1).abs() > 0.0001
          ? 'Entrada e parcelas precisam somar 100% '
                '(hoje: ${percentual(somaPagamento * 100, 0)}).'
          : null,
    3 => comRetorno ? pendenciasRoi.firstOrNull : null,
    _ => null,
  };

  void avancar() {
    if (bloqueio != null || etapa >= etapaPrevia) return;
    etapa++;
    notifyListeners();
  }

  void voltar() {
    if (etapa == 0) return;
    etapa--;
    notifyListeners();
  }

  void irPara(int e) {
    if (e < 0 || e >= etapa) return;
    etapa = e;
    notifyListeners();
  }

  DadosProposta dados(DateTime data) => DadosProposta(
    itens: [for (final i in itens) i.item],
    impostos: texto('impostos').trim(),
    paginasProdutos: paginasProdutos,
    cliente: texto('cliente').trim(),
    documento: texto('documento').trim(),
    inscricao: texto('inscricao').trim(),
    telefone: texto('telefone').trim(),
    email: texto('email').trim(),
    cidade: texto('cidade').trim(),
    data: data,
    consultor: texto('consultor').trim(),
    contatoConsultor: texto('contato').trim(),
    entrada: entrada,
    parcelas: [
      for (final (f, q) in parcelas)
        if (_pct(f) > 0) (fracao: _pct(f), quando: q.trim()),
    ],
    validade: texto('validade').trim(),
    prazo: texto('prazo').trim(),
    local: texto('local').trim(),
    agente: texto('agente').trim(),
    garantia: texto('garantia').trim(),
  );

  @override
  void dispose() {
    roi.dispose();
    super.dispose();
  }
}
