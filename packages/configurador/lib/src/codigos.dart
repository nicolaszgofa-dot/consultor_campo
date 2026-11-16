import 'regras.dart';

// Códigos J.Assy passados pela engenharia (nov/2026) e, nos bocais do
// Selenium, conferidos com o catálogo de peças.
final Map<String, String> _codigos = {
  Componentes.kitConversao(Tecnologia.titaniumEletric): '30000000357',
  Componentes.kitConversao(Tecnologia.seleniumEletric): '30000000492',
  // Neo: pressão positiva usa o conjunto padrão; gravidade, o conjunto gravidade.
  Componentes.conjunto(Tecnologia.seleniumNeo): '30000001356',
  Componentes.conjuntoNeoGravidade: '30000001562',
  Componentes.esteiraNeo: '30000001347',
  BocalNeo.gravidade.nome: '30000001122',
  BocalNeo.giratorio30.nome: '30000001701',
  Componentes.sensorSemente: '30000001634',
  Componentes.caboBateria: '30000000523',
  // Código do 250 A como passado pela engenharia: igual ao do alternador
  // hidráulico (100 A).
  Componentes.alternador250: '30000001346',
  Componentes.conjunto(Tecnologia.seleniumEletric): '30000000697',
  Componentes.conjunto(Tecnologia.titaniumEletric): '30000000804',
  // Reservatório pipoqueira já com o bocal.
  Componentes.reservatorioComBocal(BocalTitanium.pol25): '30000000750',
  Componentes.reservatorioComBocal(BocalTitanium.pol30): '30000000751',
  Componentes.reservatorioComBocal(BocalTitanium.pol25e30): '30000000759',
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

/// Itens com código diferente conforme a tecnologia.
const Map<Tecnologia, Map<String, String>> _porTecnologia = {
  Tecnologia.seleniumNeo: {Componentes.ecu: '30000000057'},
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

// Código no fim do nome: "Condutor ... - 20000000608" ou "Disco ... (20000002332)".
final _codigoNoNome = RegExp(r'\s*(?:[-–]\s*|\()(\d{11})\)?\s*$');

/// Nome do item e código J.Assy, quando conhecido. O código que vem no fim do
/// nome sai do nome; nos itens por tamanho, depende do [comprimento], e
/// alguns mudam com a [tecnologia] (a ECU do Neo).
({String nome, String? codigo}) nomeECodigo(
  String componente, {
  int? comprimento,
  Tecnologia? tecnologia,
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
  final daTecnologia = _porTecnologia[tecnologia]?[componente];
  return (nome: componente, codigo: daTecnologia ?? _codigos[componente]);
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
/// comprimentos vira uma linha por comprimento (cada um tem código próprio).
List<LinhaPedido> linhasDoPedido(ResultadoConfiguracao r) {
  final linhas = <LinhaPedido>[];
  for (final i in r.itens) {
    final pendente = i.status == StatusItem.pendente;
    final mistura =
        i.quantidadesPorComprimento.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    if (mistura.isNotEmpty && !pendente) {
      for (final e in mistura) {
        final nc = nomeECodigo(
          i.componente,
          comprimento: e.key,
          tecnologia: r.entrada.tecnologia,
        );
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
    final nc = nomeECodigo(
      i.componente,
      comprimento: i.comprimento,
      tecnologia: r.entrada.tecnologia,
    );
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
