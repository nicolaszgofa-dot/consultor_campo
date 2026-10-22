import 'package:configurador/configurador.dart';
import 'package:flutter/foundation.dart';

enum EtapaConfigurador {
  tecnologia('Tecnologia', 'Qual tecnologia será configurada?'),
  tipo('Tipo de plantadeira', 'Qual é o tipo da plantadeira?'),
  linhas('Número de linhas', 'Quantas linhas tem a plantadeira?'),
  secoes('Seções', 'Quantas seções fecham separadas?'),
  alimentacao('Alimentação', 'Alimentação elétrica'),
  resultado('Resultado', 'Configuração gerada');

  final String nome;
  final String pergunta;

  const EtapaConfigurador(this.nome, this.pergunta);
}

/// Respostas do vendedor e etapa atual do Configurador. As regras ficam no
/// pacote `configurador`; aqui só se guarda o que foi respondido.
class ConfiguradorEstado extends ChangeNotifier {
  EtapaConfigurador etapa = EtapaConfigurador.tecnologia;

  Tecnologia? tecnologia;
  TipoPlantadeira? tipo;
  int totalLinhas = 0;
  List<int> secoes = [];
  bool? temAlternador;
  bool? alternadorNaFrente;
  int? comprimentoIsobus;
  int? comprimentoChicotePainel;
  int? comprimentoMangueiras;
  int? quantidadeChicotePainel;

  /// Etapas do fluxo: a solteira pula a de seções.
  List<EtapaConfigurador> get etapas => [
    for (final e in EtapaConfigurador.values)
      if (e != EtapaConfigurador.secoes || (tipo?.secoesSeparadas ?? true)) e,
  ];

  int get indice => etapas.indexOf(etapa);

  EntradaConfiguracao get entrada => EntradaConfiguracao(
    tecnologia: tecnologia ?? Tecnologia.titaniumEletric,
    tipo: tipo ?? TipoPlantadeira.autotransportavel,
    totalLinhas: totalLinhas,
    linhasPorSecao: secoes,
    temAlternador: temAlternador,
    alternadorNaFrente: alternadorNaFrente,
    quantidadeChicotePainel: quantidadeChicotePainel,
    comprimentoIsobus: comprimentoIsobus,
    comprimentoChicotePainel: comprimentoChicotePainel,
    comprimentoMangueiras: comprimentoMangueiras,
  );

  ResultadoConfiguracao get resultado => RegrasConfigurador.configurar(entrada);

  bool get perguntarAlternador =>
      RegrasConfigurador.perguntarAlternador(totalLinhas, entrada.tipo);

  bool get usaAlternador => RegrasConfigurador.usaAlternador(entrada);

  /// Ex.: "Titanium Elétric · Autotransportável · 55 linhas".
  String get resumo => [
    ?tecnologia?.nome,
    ?tipo?.nome,
    if (totalLinhas > 0) '$totalLinhas linhas',
  ].join(' · ');

  /// Por que não dá para sair da etapa atual. Nulo = pode avançar.
  String? get bloqueio => switch (etapa) {
    EtapaConfigurador.tecnologia =>
      tecnologia == null ? 'Escolha a tecnologia.' : null,
    EtapaConfigurador.tipo =>
      tipo == null ? 'Escolha o tipo da plantadeira.' : null,
    EtapaConfigurador.linhas =>
      totalLinhas < 1
          ? 'Informe o número de linhas.'
          : totalLinhas > RegrasConfigurador.capacidadeMaxima
          ? 'Acima de ${RegrasConfigurador.capacidadeMaxima} linhas passa da '
                'capacidade de um alternador (6 saídas × 10 linhas). '
                'Fale com a engenharia.'
          : null,
    EtapaConfigurador.secoes => _bloqueioSecoes,
    EtapaConfigurador.alimentacao =>
      perguntarAlternador && temAlternador == null
          ? 'Responda se a máquina terá alternador hidráulico.'
          : null,
    EtapaConfigurador.resultado => null,
  };

  String? get _bloqueioSecoes {
    if (secoes.isEmpty) return 'Informe as seções da máquina.';
    if (secoes.any((s) => s < 1)) {
      return 'Toda seção precisa ter pelo menos 1 linha.';
    }
    final soma = secoes.fold(0, (s, n) => s + n);
    if (soma != totalLinhas) {
      return 'A soma das seções ($soma) é diferente do total de linhas '
          '($totalLinhas).';
    }
    return null;
  }

  void avancar() {
    if (bloqueio != null || indice >= etapas.length - 1) return;
    etapa = etapas[indice + 1];
    if (etapa == EtapaConfigurador.secoes && secoes.isEmpty) {
      secoes = [(totalLinhas + 1) ~/ 2, totalLinhas ~/ 2];
    }
    notifyListeners();
  }

  void voltar() {
    if (indice <= 0) return;
    etapa = etapas[indice - 1];
    notifyListeners();
  }

  /// Volta para uma etapa já feita.
  void irPara(EtapaConfigurador e) {
    final alvo = etapas.indexOf(e);
    if (alvo < 0 || alvo >= indice) return;
    etapa = e;
    notifyListeners();
  }

  void escolherTecnologia(Tecnologia t) {
    tecnologia = t;
    notifyListeners();
  }

  void escolherTipo(TipoPlantadeira t) {
    tipo = t;
    alternadorNaFrente = null;
    _mudouMaquina();
  }

  void definirLinhas(int n) {
    totalLinhas = n < 0 ? 0 : n;
    _mudouMaquina();
  }

  void adicionarSecao() {
    secoes = [...secoes, 1];
    _mudouMaquina();
  }

  void removerSecao() {
    if (secoes.length <= 1) return;
    secoes = secoes.sublist(0, secoes.length - 1);
    _mudouMaquina();
  }

  void mudarSecao(int i, int delta) {
    final novo = secoes[i] + delta;
    if (novo < 1) return;
    secoes = [...secoes]..[i] = novo;
    _mudouMaquina();
  }

  void responderAlternador(bool sim) {
    temAlternador = sim;
    _mudouMaquina();
  }

  void responderAlternadorNaFrente(bool sim) {
    alternadorNaFrente = sim;
    notifyListeners();
  }

  /// Escolhe ou desmarca o comprimento de um item vendido por tamanho.
  void escolherComprimento(String componente, int metros) {
    int? alterna(int? atual) => atual == metros ? null : metros;
    switch (componente) {
      case Componentes.caboIsobus:
        comprimentoIsobus = alterna(comprimentoIsobus);
      case Componentes.mangueiras:
        comprimentoMangueiras = alterna(comprimentoMangueiras);
      case Componentes.chicotePainel:
        comprimentoChicotePainel = alterna(comprimentoChicotePainel);
    }
    notifyListeners();
  }

  int? comprimentoEscolhido(String componente) => switch (componente) {
    Componentes.caboIsobus => comprimentoIsobus,
    Componentes.mangueiras => comprimentoMangueiras,
    Componentes.chicotePainel => comprimentoChicotePainel,
    _ => null,
  };

  void ajustarChicotePainel(int quantidade) {
    if (quantidade < 1) return;
    quantidadeChicotePainel = quantidade;
    notifyListeners();
  }

  /// A recomendação de chicote painel muda com a máquina: descarta o ajuste.
  void _mudouMaquina() {
    quantidadeChicotePainel = null;
    notifyListeners();
  }
}
