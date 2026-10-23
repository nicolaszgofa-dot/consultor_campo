import 'package:configurador/configurador.dart';
import 'package:flutter/foundation.dart';

enum EtapaConfigurador {
  tecnologia('Tecnologia', 'Qual tecnologia será configurada?'),
  tipo('Tipo de plantadeira', 'Qual é o tipo da plantadeira?'),
  linhas('Número de linhas', 'Quantas linhas tem a plantadeira?'),
  secoes('Seções', 'Quantas seções fecham separadas?'),
  alimentacao('Alimentação', 'Alimentação elétrica'),
  acessorios('Acessórios do dosador', 'Acessórios do dosador'),
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

  /// Kit conversão: depois de escolhido, o vendedor diz se é para Titanium
  /// ou Selenium, e o resto do fluxo segue o da tecnologia escolhida.
  bool kitConversao = false;
  TipoPlantadeira? tipo;
  int totalLinhas = 0;
  List<int> secoes = [];
  bool? temAlternador;
  bool? alternadorNaFrente;
  int? comprimentoIsobus;
  int? comprimentoMangueiras;

  /// Chicotes painel escolhidos: comprimento em metros → quantidade.
  Map<int, int>? chicotesPainel;

  bool? reservatorioPipoqueira;
  BocalTitanium? bocalTitanium;
  BocalSelenium? bocalSelenium;

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
    comprimentoIsobus: comprimentoIsobus,
    comprimentoMangueiras: comprimentoMangueiras,
    chicotesPainel: chicotesPainel,
    reservatorioPipoqueira: reservatorioPipoqueira,
    bocalTitanium: bocalTitanium,
    bocalSelenium: bocalSelenium,
  );

  ResultadoConfiguracao get resultado => RegrasConfigurador.configurar(entrada);

  bool get perguntarAlternador =>
      RegrasConfigurador.perguntarAlternador(totalLinhas, entrada.tipo);

  bool get usaAlternador => RegrasConfigurador.usaAlternador(entrada);

  /// Ex.: "Titanium Elétric · Autotransportável · 55 linhas".
  String get resumo => [
    if (kitConversao) 'Kit conversão',
    ?tecnologia?.nome,
    ?tipo?.nome,
    if (totalLinhas > 0) '$totalLinhas linhas',
  ].join(' · ');

  /// Por que não dá para sair da etapa atual. Nulo = pode avançar.
  String? get bloqueio => switch (etapa) {
    EtapaConfigurador.tecnologia =>
      tecnologia != null
          ? null
          : kitConversao
          ? 'Escolha se o kit conversão é para Titanium ou Selenium.'
          : 'Escolha a tecnologia.',
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
    EtapaConfigurador.acessorios => _bloqueioAcessorios,
    EtapaConfigurador.resultado => null,
  };

  String? get _bloqueioAcessorios => switch (tecnologia) {
    Tecnologia.titaniumEletric =>
      reservatorioPipoqueira == null
          ? 'Responda se terá reservatório de sementes pipoqueira.'
          : reservatorioPipoqueira! && bocalTitanium == null
          ? 'Escolha o bocal do reservatório.'
          : null,
    Tecnologia.seleniumEletric =>
      bocalSelenium == null ? 'Escolha o kit bocal de sementes.' : null,
    null => 'Escolha a tecnologia.',
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
    kitConversao = false;
    tecnologia = t;
    notifyListeners();
  }

  /// Escolhe o kit conversão; a tecnologia do kit vem em seguida.
  void escolherKitConversao() {
    if (kitConversao) return;
    kitConversao = true;
    tecnologia = null;
    notifyListeners();
  }

  void escolherTecnologiaDoKit(Tecnologia t) {
    kitConversao = true;
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

  void responderPipoqueira(bool sim) {
    reservatorioPipoqueira = sim;
    if (!sim) bocalTitanium = null;
    notifyListeners();
  }

  void escolherBocalTitanium(BocalTitanium b) {
    bocalTitanium = b;
    notifyListeners();
  }

  void escolherBocalSelenium(BocalSelenium b) {
    bocalSelenium = b;
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
    }
    notifyListeners();
  }

  int? comprimentoEscolhido(String componente) => switch (componente) {
    Componentes.caboIsobus => comprimentoIsobus,
    Componentes.mangueiras => comprimentoMangueiras,
    _ => null,
  };

  /// Soma [delta] aos chicotes painel de [metros], partindo do que o
  /// resultado mostra (inclusive o padrão sem alternador).
  void ajustarChicotePainel(int metros, int delta) {
    final atual = Map<int, int>.of(
      resultado.item(Componentes.chicotePainel)?.quantidadesPorComprimento ??
          const {},
    );
    final novo = (atual[metros] ?? 0) + delta;
    if (novo < 0) return;
    atual[metros] = novo;
    chicotesPainel = atual;
    notifyListeners();
  }

  /// A recomendação de chicote painel muda com a máquina: descarta a escolha.
  void _mudouMaquina() {
    chicotesPainel = null;
    notifyListeners();
  }
}
