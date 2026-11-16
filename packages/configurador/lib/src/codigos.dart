import 'regras.dart';

// Códigos J.Assy passados pela engenharia (nov/2026) e, nos bocais do
// Selenium, conferidos com o catálogo de peças.
final Map<String, String> _codigos = {
  Componentes.kitConversao(Tecnologia.titaniumEletric): '30000000357',
  Componentes.conjunto(Tecnologia.seleniumEletric): '30000000697',
  // "Conjunto Titanium com kit montagem caixa de semente".
  Componentes.conjunto(Tecnologia.titaniumEletric): '30000000804',
  Componentes.discoSojaSelenium: '20000000597',
  Componentes.discoMilhoSelenium: '20000000573',
  Componentes.discoMilhoTitanium: '30000000256',
  Componentes.discoSojaTitanium: '30000000257',
  Componentes.ecu: '30000000052',
  Componentes.sensorLevante: '30000000429',
  Componentes.alternador: '30000001346',
  Componentes.chicote1: '30000000687',
  Componentes.chicote4: '30000000688',
  BocalSelenium.gravidade.nome: '30000000681',
  BocalSelenium.giratorio25.nome: '30000000591',
  BocalSelenium.giratorio30.nome: '30000000573',
  BocalSelenium.engateRapido.nome: '30000000360',
};

/// Itens vendidos por tamanho: um código por comprimento (metros).
final Map<String, Map<int, String>> _codigosPorComprimento = {
  Componentes.caboIsobus: {
    5: '30000000516',
    11: '30000000521',
    14: '30000000947',
    17: '30000000522',
  },
  Componentes.chicotePainel: {
    4: '30000000613',
    9: '30000000612',
    14: '30000000611',
  },
  Componentes.mangueiras: {
    6: '30000000684',
    9: '30000000685',
    12: '30000000647',
    15: '30000000648',
  },
};

/// Reservatório pipoqueira: o código é do reservatório já com o bocal.
const Map<BocalTitanium, String> _pipoqueira = {
  BocalTitanium.pol25: '30000000750',
  BocalTitanium.pol30: '30000000751',
  BocalTitanium.pol25e30: '30000000759',
};

// Código no fim do nome: "Condutor ... - 20000000608" ou "Disco ... (20000002332)".
final _codigoNoNome = RegExp(r'\s*(?:[-–]\s*|\()(\d{11})\)?\s*$');

/// Nome do item e código J.Assy, quando conhecido. O código que vem no fim do
/// nome sai do nome; nos itens por tamanho, depende do [comprimento].
({String nome, String? codigo}) nomeECodigo(
  String componente, {
  int? comprimento,
}) {
  final m = _codigoNoNome.firstMatch(componente);
  if (m != null) {
    return (nome: componente.substring(0, m.start).trim(), codigo: m.group(1));
  }
  final porTamanho = _codigosPorComprimento[componente];
  if (porTamanho != null) {
    return (
      nome: componente,
      codigo: comprimento == null ? null : porTamanho[comprimento],
    );
  }
  return (nome: componente, codigo: _codigos[componente]);
}

/// Uma linha do pedido, com código e comprimento já resolvidos.
class LinhaPedido {
  final String nome;
  final String? codigo;

  /// Comprimento em metros, nos itens vendidos por tamanho.
  final int? comprimento;
  final int quantidade;
  final bool pendente;
  final String? pendencia;

  const LinhaPedido({
    required this.nome,
    required this.codigo,
    required this.quantidade,
    this.comprimento,
    this.pendente = false,
    this.pendencia,
  });
}

/// Itens da configuração como linhas de pedido: o item com vários
/// comprimentos vira uma linha por comprimento (cada um tem código próprio), e
/// o reservatório pipoqueira sai junto com o bocal escolhido.
List<LinhaPedido> linhasDoPedido(ResultadoConfiguracao r) {
  final bocal = r.entrada.bocalTitanium;
  final pipoqueiraComBocal =
      bocal != null && r.item(Componentes.reservatorioPipoqueira) != null;
  final linhas = <LinhaPedido>[];
  for (final i in r.itens) {
    final pendente = i.status == StatusItem.pendente;
    if (pipoqueiraComBocal && i.componente == bocal.nome) continue;
    if (pipoqueiraComBocal &&
        i.componente == Componentes.reservatorioPipoqueira) {
      linhas.add(
        LinhaPedido(
          nome: '${i.componente} ${bocal.nome.toLowerCase()}',
          codigo: _pipoqueira[bocal],
          quantidade: i.quantidade,
        ),
      );
      continue;
    }
    final mistura =
        i.quantidadesPorComprimento.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    if (mistura.isNotEmpty && !pendente) {
      for (final e in mistura) {
        final nc = nomeECodigo(i.componente, comprimento: e.key);
        linhas.add(
          LinhaPedido(
            nome: nc.nome,
            codigo: nc.codigo,
            comprimento: e.key,
            quantidade: e.value,
          ),
        );
      }
      continue;
    }
    final nc = nomeECodigo(i.componente, comprimento: i.comprimento);
    linhas.add(
      LinhaPedido(
        nome: nc.nome,
        codigo: nc.codigo,
        comprimento: i.comprimento,
        quantidade: i.quantidade,
        pendente: pendente,
        pendencia: i.pendencia,
      ),
    );
  }
  return linhas;
}
