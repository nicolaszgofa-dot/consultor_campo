import 'package:flutter/foundation.dart';

import 'pecas_dados.dart';

class ItemLista {
  final Peca peca;
  final String produto;
  int quantidade;

  ItemLista(this.peca, this.produto, [this.quantidade = 1]);
}

/// Lista de peças montada na hora para mandar ao cliente ou à fábrica.
/// Fica só na memória: some ao sair da tela (não há servidor ainda).
class ListaPecas extends ChangeNotifier {
  /// No app da revenda a lista vira um pedido de reposição para a J.Assy.
  final bool pedido;

  ListaPecas({this.pedido = false});

  final _itens = <String, ItemLista>{};

  List<ItemLista> get itens => List.unmodifiable(_itens.values);
  int get totalPecas => _itens.values.fold(0, (s, i) => s + i.quantidade);
  bool get vazia => _itens.isEmpty;

  // Há códigos repetidos no catálogo com descrições diferentes.
  static String _chave(Peca p) => '${p.codigo}|${p.descricao}';

  bool contem(Peca p) => _itens.containsKey(_chave(p));

  int quantidade(Peca p) => _itens[_chave(p)]?.quantidade ?? 0;

  void adicionar(Peca p, String produto) {
    final atual = _itens[_chave(p)];
    if (atual == null) {
      _itens[_chave(p)] = ItemLista(p, produto);
    } else {
      atual.quantidade++;
    }
    notifyListeners();
  }

  void mudarQuantidade(Peca p, int delta) {
    final atual = _itens[_chave(p)];
    if (atual == null) return;
    atual.quantidade += delta;
    if (atual.quantidade <= 0) _itens.remove(_chave(p));
    notifyListeners();
  }

  void remover(Peca p) {
    if (_itens.remove(_chave(p)) != null) notifyListeners();
  }

  void limpar() {
    _itens.clear();
    notifyListeners();
  }

  /// Texto do pedido da revenda: quem pede, total e as peças.
  String comoPedido({
    required String revenda,
    String cidade = '',
    String observacao = '',
  }) {
    final b = StringBuffer('Pedido de peças de reposição J.Assy\n')
      ..write('Revenda: $revenda\n');
    if (cidade.isNotEmpty) b.write('Cidade: $cidade\n');
    b.write('Total: $totalPecas ${totalPecas == 1 ? 'peça' : 'peças'}\n');
    if (observacao.isNotEmpty) b.write('Observação: $observacao\n');
    return (b.toString() + _itensComoTexto()).trimRight();
  }

  /// Texto para colar no WhatsApp ou no e-mail.
  String comoTexto() =>
      ('Peças de reposição J.Assy\n${_itensComoTexto()}').trimRight();

  String _itensComoTexto() {
    final b = StringBuffer();
    final produtos = {for (final i in _itens.values) i.produto};
    for (final produto in produtos) {
      b.write('\n$produto\n');
      for (final i in _itens.values.where((i) => i.produto == produto)) {
        b.write('${i.quantidade}x ${i.peca.codigo} - ${i.peca.descricao}\n');
      }
    }
    return b.toString().trimRight();
  }
}
