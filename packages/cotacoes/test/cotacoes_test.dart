import 'dart:convert';
import 'dart:io';

import 'package:cotacoes/cotacoes.dart';
import 'package:flutter_test/flutter_test.dart';

Cotacao praca(
  String local,
  String uf,
  double preco, {
  TipoCotacao tipo = TipoCotacao.praca,
  DateTime? data,
}) => Cotacao(
  produto: Produto.soja,
  tipo: tipo,
  uf: uf,
  local: local,
  preco: preco,
  data: data ?? DateTime(2026, 10, 2),
  fonte: 'teste',
);

Cotacao conab(String uf, double preco) => Cotacao(
  produto: Produto.soja,
  tipo: TipoCotacao.conabUf,
  uf: uf,
  preco: preco,
  data: DateTime(2026, 10, 2),
  inicio: DateTime(2026, 9, 28),
  fonte: 'Conab',
);

void main() {
  final lucas = cidadePorNome('Lucas do Rio Verde', 'MT')!;
  final sorriso = cidadePorNome('Sorriso', 'MT')!;

  test('distância Sorriso–Lucas do Rio Verde fica perto de 60 km', () {
    expect(distanciaKm(sorriso, lucas), closeTo(60, 5));
  });

  group('preço da cidade', () {
    test('cotação da própria cidade vem primeiro', () {
      final r = precoDaCidade(sorriso, [
        praca('Sorriso', 'MT', 139.9),
        praca('Lucas do Rio Verde', 'MT', 150),
        conab('MT', 142.2),
      ])!;
      expect(r.origem, OrigemPreco.local);
      expect(r.preco, 139.9);
    });

    test('preço informado mais recente vale como local', () {
      final r = precoDaCidade(sorriso, [
        praca('Sorriso', 'MT', 139.9),
        praca(
          'Sorriso',
          'MT',
          141,
          tipo: TipoCotacao.informado,
          data: DateTime(2026, 10, 3),
        ),
      ])!;
      expect(r.origem, OrigemPreco.informado);
      expect(r.preco, 141);
    });

    test('sem praça na cidade, estima pelas próximas com peso 1/d²', () {
      final r = precoDaCidade(lucas, [
        praca('Sorriso', 'MT', 140),
        praca('Tangará da Serra', 'MT', 150),
      ])!;
      expect(r.origem, OrigemPreco.estimado);
      expect(r.pracas.first.cidade.nome, 'Sorriso');
      // Sorriso está a ~60 km e Tangará a ~245 km: pesa bem mais.
      expect(r.preco, greaterThan(140));
      expect(r.preco, lessThan(141));
    });

    test('portos e indicadores ficam fora da estimativa', () {
      final r = precoDaCidade(lucas, [
        praca('Sorriso', 'MT', 140, tipo: TipoCotacao.porto),
        praca('Sorriso', 'MT', 150, tipo: TipoCotacao.indicador),
        conab('MT', 142.2),
      ])!;
      expect(r.origem, OrigemPreco.conab);
      expect(r.preco, 142.2);
    });

    test('praça além do raio não conta', () {
      final r = precoDaCidade(lucas, [
        praca('Rondonópolis', 'MT', 130),
        conab('MT', 142.2),
      ], raioKm: 250)!;
      expect(r.origem, OrigemPreco.conab);
    });

    test('nada disponível: nulo', () {
      expect(precoDaCidade(lucas, [conab('GO', 139)]), isNull);
    });
  });

  test('busca ignora acentos e maiúsculas', () {
    expect(buscarCidades('jatai').map((c) => c.nome), ['Jataí']);
    expect(buscarCidades('l'), isEmpty);
  });

  group('feed', () {
    test('ida e volta em JSON', () {
      final feed = FeedCotacoes(
        geradoEm: DateTime.utc(2026, 10, 2, 21, 5),
        cotacoes: [praca('Sorriso', 'MT', 139.9), conab('MT', 142.2)],
      );
      final volta = FeedCotacoes.fromJson(
        jsonDecode(jsonEncode(feed.toJson())) as Map<String, dynamic>,
      )!;
      expect(volta.cotacoes, hasLength(2));
      expect(volta.cotacoes.last.inicio, DateTime(2026, 9, 28));
      expect(volta.geradoEm, feed.geradoEm);
    });

    test('linha de produto desconhecido é ignorada; versão errada é nula', () {
      final feed = FeedCotacoes.fromJson({
        'versao': 1,
        'geradoEm': '2026-10-02T18:05:00-03:00',
        'cotacoes': [
          {
            'produto': 'trigo',
            'tipo': 'praca',
            'preco': 80,
            'data': '2026-10-02',
          },
        ],
      })!;
      expect(feed.cotacoes, isEmpty);
      expect(FeedCotacoes.fromJson({'versao': 99}), isNull);
    });

    test('o feed embutido no app é válido e toda praça tem cidade', () {
      final texto = File('../../app/assets/cotacoes/cotacoes.json')
          .readAsStringSync();
      final feed = FeedCotacoes.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      )!;
      expect(feed.cotacoes.length, greaterThan(60));
      for (final c in feed.cotacoes.where((c) => c.local != null)) {
        expect(cidadePorNome(c.local!, c.uf), isNotNull, reason: c.local);
      }
      for (final p in Produto.values) {
        expect(
          feed.doProduto(p).where((c) => c.tipo == TipoCotacao.conabUf),
          isNotEmpty,
        );
      }
    });
  });
}
