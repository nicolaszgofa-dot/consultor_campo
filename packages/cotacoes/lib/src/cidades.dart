/// Cidade com posição, para buscar e estimar o preço pela distância.
class Cidade {
  final String nome;
  final String uf;
  final double lat;
  final double lon;

  const Cidade(this.nome, this.uf, this.lat, this.lon);

  String get rotulo => '$nome – $uf';
}

/// Praças das fontes e cidades agrícolas próximas. Posição aproximada da
/// sede do município (IBGE). Uma praça nova no feed precisa estar aqui.
const cidades = <Cidade>[
  // MT
  Cidade('Sorriso', 'MT', -12.55, -55.71),
  Cidade('Tangará da Serra', 'MT', -14.62, -57.49),
  Cidade('Campo Novo do Parecis', 'MT', -13.67, -57.89),
  Cidade('Lucas do Rio Verde', 'MT', -13.05, -55.91),
  Cidade('Nova Mutum', 'MT', -13.83, -56.08),
  Cidade('Sinop', 'MT', -11.86, -55.50),
  Cidade('Sapezal', 'MT', -12.99, -58.76),
  Cidade('Primavera do Leste', 'MT', -15.56, -54.30),
  Cidade('Campo Verde', 'MT', -15.55, -55.16),
  Cidade('Rondonópolis', 'MT', -16.47, -54.64),
  Cidade('Querência', 'MT', -12.60, -52.18),
  Cidade('Diamantino', 'MT', -14.41, -56.45),
  // PR
  Cidade('Ubiratã', 'PR', -24.54, -52.99),
  Cidade('Castro', 'PR', -24.79, -50.01),
  Cidade('Marechal Cândido Rondon', 'PR', -24.56, -54.06),
  Cidade('Paranaguá', 'PR', -25.52, -48.51),
  Cidade('Cascavel', 'PR', -24.96, -53.46),
  Cidade('Toledo', 'PR', -24.72, -53.74),
  Cidade('Ponta Grossa', 'PR', -25.09, -50.16),
  Cidade('Guarapuava', 'PR', -25.39, -51.46),
  Cidade('Londrina', 'PR', -23.31, -51.16),
  Cidade('Campo Mourão', 'PR', -24.05, -52.38),
  // MS
  Cidade('São Gabriel do Oeste', 'MS', -19.39, -54.57),
  Cidade('Maracaju', 'MS', -21.61, -55.17),
  Cidade('Campo Grande', 'MS', -20.47, -54.62),
  Cidade('Eldorado', 'MS', -23.79, -54.28),
  Cidade('Dourados', 'MS', -22.22, -54.81),
  Cidade('Sidrolândia', 'MS', -20.93, -54.96),
  Cidade('Chapadão do Sul', 'MS', -18.79, -52.62),
  Cidade('Ponta Porã', 'MS', -22.54, -55.73),
  // GO
  Cidade('Jataí', 'GO', -17.88, -51.72),
  Cidade('Rio Verde', 'GO', -17.79, -50.92),
  Cidade('Mineiros', 'GO', -17.57, -52.55),
  Cidade('Cristalina', 'GO', -16.77, -47.61),
  Cidade('Montividiu', 'GO', -17.44, -51.17),
  // DF
  Cidade('Brasília', 'DF', -15.78, -47.93),
  // BA
  Cidade('Barreiras', 'BA', -12.15, -45.00),
  Cidade('Luís Eduardo Magalhães', 'BA', -12.09, -45.79),
  Cidade('São Desidério', 'BA', -12.36, -44.97),
  Cidade('Formosa do Rio Preto', 'BA', -11.05, -45.19),
  // SP
  Cidade('Cândido Mota', 'SP', -22.75, -50.39),
  Cidade('Itapetininga', 'SP', -23.59, -48.05),
  Cidade('Santos', 'SP', -23.96, -46.33),
  Cidade('Campinas', 'SP', -22.91, -47.06),
  Cidade('Assis', 'SP', -22.66, -50.41),
  Cidade('Ourinhos', 'SP', -22.98, -49.87),
  Cidade('Itapeva', 'SP', -23.98, -48.88),
  // SC
  Cidade('Rio do Sul', 'SC', -27.21, -49.64),
  Cidade('Chapecó', 'SC', -27.10, -52.61),
  Cidade('Campos Novos', 'SC', -27.40, -51.22),
  Cidade('Xanxerê', 'SC', -26.88, -52.40),
  // MG
  Cidade('Machado', 'MG', -21.67, -45.92),
  Cidade('Unaí', 'MG', -16.36, -46.90),
  Cidade('Uberlândia', 'MG', -18.91, -48.27),
  Cidade('Patos de Minas', 'MG', -18.58, -46.52),
  Cidade('Paracatu', 'MG', -17.22, -46.87),
  // RS
  Cidade('Rio Grande', 'RS', -32.03, -52.10),
  Cidade('Passo Fundo', 'RS', -28.26, -52.40),
  Cidade('Cruz Alta', 'RS', -28.64, -53.61),
  Cidade('Ijuí', 'RS', -28.39, -53.92),
  Cidade('Santo Ângelo', 'RS', -28.30, -54.26),
  // Outros estados (só Conab por enquanto)
  Cidade('Porto Nacional', 'TO', -10.71, -48.42),
  Cidade('Balsas', 'MA', -7.53, -46.04),
  Cidade('Uruçuí', 'PI', -7.23, -44.55),
  Cidade('Paragominas', 'PA', -2.99, -47.35),
  Cidade('Vilhena', 'RO', -12.74, -60.15),
];

Cidade? cidadePorNome(String nome, [String? uf]) {
  for (final c in cidades) {
    if (c.nome == nome && (uf == null || c.uf == uf)) return c;
  }
  return null;
}

/// Busca sem diferenciar maiúsculas e acentos.
List<Cidade> buscarCidades(String termo, {int limite = 8}) {
  final t = semAcento(termo.trim().toLowerCase());
  if (t.length < 2) return const [];
  return [
    for (final c in cidades)
      if (semAcento(c.nome.toLowerCase()).contains(t)) c,
  ].take(limite).toList();
}

String semAcento(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    final i = de.indexOf(ch);
    b.write(i >= 0 ? para[i] : ch);
  }
  return b.toString();
}
