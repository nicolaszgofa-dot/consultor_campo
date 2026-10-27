import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'concorrencia_dados.dart';

const unidadesPreco = ['por linha', 'por unidade', 'por kit', 'plantadeira'];

const condicoesPreco = [
  'À vista',
  'A prazo',
  'Safra',
  'Com instalação',
  'Não sei',
];

const fontesPreco = [
  'Proposta mostrada pelo produtor',
  'Revenda ou concessionária',
  'Anúncio na internet',
  'Feira ou evento',
  'Conversa com produtor',
];

/// Preço de concorrente que o vendedor encontrou no campo.
class PrecoConcorrente {
  final String concorrenteId;
  final double preco;
  final String unidade;
  final String condicao;
  final String fonte;
  final String local;
  final DateTime data;
  final String? observacao;
  final String? informadoPor;

  const PrecoConcorrente({
    required this.concorrenteId,
    required this.preco,
    required this.unidade,
    required this.condicao,
    required this.fonte,
    required this.local,
    required this.data,
    this.observacao,
    this.informadoPor,
  });

  static PrecoConcorrente? fromJson(Map<String, dynamic> j) {
    final data = DateTime.tryParse(j['data'] as String? ?? '');
    final preco = (j['preco'] as num?)?.toDouble();
    final id = j['concorrente'] as String?;
    if (data == null || preco == null || id == null) return null;
    return PrecoConcorrente(
      concorrenteId: id,
      preco: preco,
      unidade: j['unidade'] as String? ?? unidadesPreco.first,
      condicao: j['condicao'] as String? ?? 'Não sei',
      fonte: j['fonte'] as String? ?? '',
      local: j['local'] as String? ?? '',
      data: data,
      observacao: j['obs'] as String?,
      informadoPor: j['quem'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'concorrente': concorrenteId,
    'preco': preco,
    'unidade': unidade,
    'condicao': condicao,
    'fonte': fonte,
    'local': local,
    'data': data.toIso8601String(),
    if (observacao != null) 'obs': observacao,
    if (informadoPor != null) 'quem': informadoPor,
  };
}

/// Resumo dos preços de um produto numa mesma unidade.
class ResumoPreco {
  final String concorrenteId;
  final String unidade;
  final List<PrecoConcorrente> precos;

  const ResumoPreco(this.concorrenteId, this.unidade, this.precos);

  double get media =>
      precos.map((p) => p.preco).reduce((a, b) => a + b) / precos.length;
  double get minimo =>
      precos.map((p) => p.preco).reduce((a, b) => a < b ? a : b);
  double get maximo =>
      precos.map((p) => p.preco).reduce((a, b) => a > b ? a : b);
  DateTime get ultimo =>
      precos.map((p) => p.data).reduce((a, b) => a.isAfter(b) ? a : b);
}

/// Preços da concorrência guardados no aparelho.
class PrecosConcorrenciaEstado extends ChangeNotifier {
  static const _chave = 'concorrencia.precos.v1';

  final precos = <PrecoConcorrente>[];
  bool carregado = false;

  /// Linha de produto do filtro; nula = todas.
  String? linha;

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chave);
    precos.clear();
    if (texto != null) {
      for (final j in jsonDecode(texto) as List) {
        final p = PrecoConcorrente.fromJson(j as Map<String, dynamic>);
        if (p != null) precos.add(p);
      }
    }
    carregado = true;
    notifyListeners();
  }

  void filtrar(String? novaLinha) {
    linha = novaLinha;
    notifyListeners();
  }

  /// Preços do filtro atual, do mais recente para o mais antigo.
  List<PrecoConcorrente> get filtrados {
    final lista = [
      for (final p in precos)
        if (linha == null ||
            concorrentePorId(p.concorrenteId)?.linha.id == linha)
          p,
    ]..sort((a, b) => b.data.compareTo(a.data));
    return lista;
  }

  /// Um resumo por produto e unidade (kit e linha não se misturam).
  List<ResumoPreco> get resumos {
    final grupos = <(String, String), List<PrecoConcorrente>>{};
    for (final p in filtrados) {
      grupos.putIfAbsent((p.concorrenteId, p.unidade), () => []).add(p);
    }
    return [
      for (final e in grupos.entries) ResumoPreco(e.key.$1, e.key.$2, e.value),
    ];
  }

  Future<void> adicionar(PrecoConcorrente p) async {
    precos.add(p);
    linha = concorrentePorId(p.concorrenteId)?.linha.id;
    notifyListeners();
    await _gravar();
  }

  Future<void> remover(PrecoConcorrente p) async {
    precos.remove(p);
    notifyListeners();
    await _gravar();
  }

  Future<void> _gravar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode([for (final p in precos) p.toJson()]),
    );
  }
}
