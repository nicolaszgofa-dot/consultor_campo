import 'dart:convert';

import 'package:cotacoes/cotacoes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Endereço do feed. Hoje é o próprio arquivo do repositório; quando o
/// coletor existir, troca só este endereço.
final urlFeedCotacoes = Uri.parse(
  'https://raw.githubusercontent.com/nicolaszgofa-dot/consultor_campo/main/'
  'app/assets/cotacoes/cotacoes.json',
);

const assetFeedCotacoes = 'assets/cotacoes/cotacoes.json';

/// De onde vieram as cotações mostradas.
enum OrigemFeed { internet, salvo, embutido }

typedef BuscarTexto = Future<String> Function(Uri url);

Future<String> _buscarHttp(Uri url) async {
  final r = await http.get(url).timeout(const Duration(seconds: 10));
  if (r.statusCode != 200) throw http.ClientException('HTTP ${r.statusCode}');
  return utf8.decode(r.bodyBytes);
}

/// Cotações na tela: guarda o último feed no aparelho, atualiza quando há
/// internet e mantém os preços informados pelo vendedor.
class CotacoesEstado extends ChangeNotifier {
  static const _chaveFeed = 'cotacoes.feed.v1';
  static const _chaveInformados = 'cotacoes.informados.v1';
  static const _chaveMinhaCidade = 'cotacoes.minhaCidade.v1';

  final BuscarTexto _buscar;
  final Future<String> Function() _embutido;
  final DateTime Function() _agora;

  CotacoesEstado({
    BuscarTexto? buscar,
    Future<String> Function()? embutido,
    DateTime Function()? agora,
  }) : _buscar = buscar ?? _buscarHttp,
       _embutido = embutido ?? (() => rootBundle.loadString(assetFeedCotacoes)),
       _agora = agora ?? DateTime.now;

  FeedCotacoes? feed;
  OrigemFeed? origem;

  /// Quando o aparelho recebeu o feed da internet pela última vez.
  DateTime? recebidoEm;
  bool atualizando = false;

  /// A última tentativa de atualizar falhou (sem internet ou fora do ar).
  bool semConexao = false;

  final informados = <Cotacao>[];
  Cidade? minhaCidade;

  Produto produto = Produto.soja;
  String uf = 'MT';
  Cidade? cidade;

  bool get carregado => feed != null;

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString(_chaveFeed);
    if (salvo != null) {
      final j = jsonDecode(salvo) as Map<String, dynamic>;
      feed = FeedCotacoes.fromJson(j['feed'] as Map<String, dynamic>);
      recebidoEm = DateTime.tryParse(j['recebidoEm'] as String? ?? '');
      if (feed != null) origem = OrigemFeed.salvo;
    }
    if (feed == null) {
      feed = FeedCotacoes.fromJson(
        jsonDecode(await _embutido()) as Map<String, dynamic>,
      );
      origem = OrigemFeed.embutido;
    }
    final inf = prefs.getString(_chaveInformados);
    if (inf != null) {
      informados
        ..clear()
        ..addAll([
          for (final c in jsonDecode(inf) as List)
            ?Cotacao.fromJson(c as Map<String, dynamic>),
        ]);
    }
    final minha = prefs.getStringList(_chaveMinhaCidade);
    if (minha != null && minha.length == 2) {
      minhaCidade = cidadePorNome(minha[0], minha[1]);
    }
    if (minhaCidade != null) {
      uf = minhaCidade!.uf;
      cidade = minhaCidade;
    }
    notifyListeners();
    await atualizar();
  }

  Future<void> atualizar() async {
    if (atualizando) return;
    atualizando = true;
    notifyListeners();
    try {
      final texto = await _buscar(urlFeedCotacoes);
      final novo = FeedCotacoes.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      );
      if (novo == null) throw const FormatException('feed inválido');
      // Nunca troca por um feed mais antigo que o que já está no aparelho.
      if (feed == null || !novo.geradoEm.isBefore(feed!.geradoEm)) {
        feed = novo;
      }
      origem = OrigemFeed.internet;
      recebidoEm = _agora();
      semConexao = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _chaveFeed,
        jsonEncode({
          'recebidoEm': recebidoEm!.toIso8601String(),
          'feed': feed!.toJson(),
        }),
      );
    } catch (_) {
      semConexao = true;
    } finally {
      atualizando = false;
      notifyListeners();
    }
  }

  /// Cotações do produto escolhido, com as informadas no aparelho.
  List<Cotacao> get cotacoes => [
    ...?feed?.doProduto(produto),
    for (final c in informados)
      if (c.produto == produto) c,
  ];

  /// Data da cotação de praça mais recente do produto.
  DateTime? get ultimaCotacao {
    DateTime? d;
    for (final c in cotacoes) {
      if (c.tipo == TipoCotacao.conabUf) continue;
      if (d == null || c.data.isAfter(d)) d = c.data;
    }
    return d;
  }

  /// Cotação de antes do último dia útil: o vendedor precisa saber.
  bool get desatualizado {
    final d = ultimaCotacao;
    if (d == null) return false;
    var util = _agora();
    util = DateTime(util.year, util.month, util.day);
    do {
      util = util.subtract(const Duration(days: 1));
    } while (util.weekday > DateTime.friday);
    return d.isBefore(util);
  }

  void escolherProduto(Produto p) {
    produto = p;
    notifyListeners();
  }

  void escolherUf(String novo) {
    uf = novo;
    cidade = minhaCidade?.uf == novo ? minhaCidade : null;
    notifyListeners();
  }

  void escolherCidade(Cidade c) {
    uf = c.uf;
    cidade = c;
    notifyListeners();
  }

  Future<void> definirMinhaCidade(Cidade c) async {
    minhaCidade = c;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chaveMinhaCidade, [c.nome, c.uf]);
  }

  Future<void> informar({
    required Produto produto,
    required Cidade cidade,
    required double preco,
    required String fonte,
    required DateTime data,
    String? informadoPor,
  }) async {
    informados.add(
      Cotacao(
        produto: produto,
        tipo: TipoCotacao.informado,
        uf: cidade.uf,
        local: cidade.nome,
        preco: preco,
        data: data,
        fonte: fonte,
        informadoPor: informadoPor,
      ),
    );
    this.produto = produto;
    escolherCidade(cidade);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveInformados,
      jsonEncode([for (final c in informados) c.toJson()]),
    );
  }

  Future<void> removerInformado(Cotacao c) async {
    informados.remove(c);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveInformados,
      jsonEncode([for (final c in informados) c.toJson()]),
    );
  }
}
