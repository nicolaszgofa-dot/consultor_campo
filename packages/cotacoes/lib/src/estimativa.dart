import 'dart:math' as math;

import 'cidades.dart';
import 'modelos.dart';

/// Distância em linha reta (km) entre duas cidades.
double distanciaKm(Cidade a, Cidade b) {
  const r = 6371.0;
  const g = math.pi / 180;
  final dLat = (b.lat - a.lat) * g;
  final dLon = (b.lon - a.lon) * g;
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(a.lat * g) *
          math.cos(b.lat * g) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.sqrt(h));
}

enum OrigemPreco {
  local('Praça'),
  informado('Informado'),
  estimado('Estimado'),
  conab('Conab UF');

  final String rotulo;

  const OrigemPreco(this.rotulo);
}

class PracaProxima {
  final Cotacao cotacao;
  final Cidade cidade;
  final double km;

  const PracaProxima(this.cotacao, this.cidade, this.km);
}

/// Preço de uma cidade e de onde ele veio.
class PrecoCidade {
  final double preco;
  final OrigemPreco origem;

  /// Cotação usada quando o preço é da própria cidade ou da Conab.
  final Cotacao? cotacao;

  /// Praças usadas na estimativa, da mais próxima para a mais distante.
  final List<PracaProxima> pracas;

  const PrecoCidade({
    required this.preco,
    required this.origem,
    this.cotacao,
    this.pracas = const [],
  });
}

const raioEstimativaKm = 250.0;

/// Preço da cidade, nesta ordem:
/// 1. cotação da própria cidade (praça ou informada; a mais recente);
/// 2. estimado: praças e informados até [raioKm], com peso 1/distância²;
/// 3. média Conab do estado.
/// Nulo se nada disso existir.
PrecoCidade? precoDaCidade(
  Cidade cidade,
  List<Cotacao> cotacoes, {
  double raioKm = raioEstimativaKm,
}) {
  final validas = cotacoes.where((c) => c.tipo.entraNaEstimativa).toList();

  final locais =
      validas.where((c) => c.local == cidade.nome && c.uf == cidade.uf).toList()
        ..sort((a, b) => b.data.compareTo(a.data));
  if (locais.isNotEmpty) {
    final c = locais.first;
    return PrecoCidade(
      preco: c.preco,
      origem: c.tipo == TipoCotacao.informado
          ? OrigemPreco.informado
          : OrigemPreco.local,
      cotacao: c,
    );
  }

  final proximas = <PracaProxima>[];
  for (final c in validas) {
    final outra = c.local == null ? null : cidadePorNome(c.local!, c.uf);
    if (outra == null) continue;
    final km = distanciaKm(cidade, outra);
    if (km <= raioKm) proximas.add(PracaProxima(c, outra, km));
  }
  if (proximas.isNotEmpty) {
    proximas.sort((a, b) => a.km.compareTo(b.km));
    var soma = 0.0;
    var pesos = 0.0;
    for (final p in proximas) {
      // 10 km de piso: praça vizinha não pesa infinito.
      final peso = 1 / math.pow(math.max(p.km, 10), 2);
      soma += p.cotacao.preco * peso;
      pesos += peso;
    }
    return PrecoCidade(
      preco: soma / pesos,
      origem: OrigemPreco.estimado,
      pracas: proximas,
    );
  }

  final conab = conabDoEstado(cidade.uf, cotacoes);
  if (conab != null) {
    return PrecoCidade(
      preco: conab.preco,
      origem: OrigemPreco.conab,
      cotacao: conab,
    );
  }
  return null;
}

/// Preço semanal Conab mais recente do estado.
Cotacao? conabDoEstado(String uf, List<Cotacao> cotacoes) {
  Cotacao? melhor;
  for (final c in cotacoes) {
    if (c.tipo == TipoCotacao.conabUf && c.uf == uf) {
      if (melhor == null || c.data.isAfter(melhor.data)) melhor = c;
    }
  }
  return melhor;
}
