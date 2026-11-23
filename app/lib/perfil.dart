/// Versão do app escolhida na compilação:
/// `flutter build ... --dart-define=PERFIL=revenda` gera o app das revendas
/// parceiras; sem o parâmetro sai o app da equipe J.Assy.
///
/// As constantes são de compilação: o que é só da equipe (como Inteligência
/// de mercado) nem entra no app da revenda.
library;

enum Perfil { equipe, revenda }

const _perfilCompilado = String.fromEnvironment('PERFIL');

const bool ehRevenda = _perfilCompilado == 'revenda';

const Perfil perfil = ehRevenda ? Perfil.revenda : Perfil.equipe;

/// Nome mostrado no app (o nome completo da marca só vai em apresentação).
const String nomeApp = ehRevenda ? 'JA Campo Revenda' : 'JA Campo';
