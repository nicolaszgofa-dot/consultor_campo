import 'regras.dart';

/// Códigos J.Assy dos itens que não trazem o código no próprio nome. Fonte:
/// catálogo de peças do Selenium (vista explodida do corpo do dosador).
final Map<String, String> _codigosConhecidos = {
  BocalSelenium.gravidade.nome: '30000000681',
  BocalSelenium.giratorio25.nome: '30000000591',
  BocalSelenium.giratorio30.nome: '30000000573',
  BocalSelenium.engateRapido.nome: '30000000360',
};

// Código no fim do nome: "Condutor ... - 20000000608" ou "Disco ... (20000002332)".
final _codigoNoNome = RegExp(r'\s*(?:[-–]\s*|\()(\d{11})\)?\s*$');

/// Nome do item e código J.Assy, quando conhecido. O código que vem no fim do
/// nome sai do nome.
({String nome, String? codigo}) nomeECodigo(String componente) {
  final m = _codigoNoNome.firstMatch(componente);
  if (m != null) {
    return (nome: componente.substring(0, m.start).trim(), codigo: m.group(1));
  }
  return (nome: componente, codigo: _codigosConhecidos[componente]);
}
