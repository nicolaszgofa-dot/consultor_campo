import 'package:flutter/material.dart';

/// Um pedaço do texto de um conceito.
sealed class Bloco {
  const Bloco();
}

class Paragrafo extends Bloco {
  final String texto;
  const Paragrafo(this.texto);
}

class Subtitulo extends Bloco {
  final String texto;
  const Subtitulo(this.texto);
}

class Lista extends Bloco {
  final List<String> itens;
  const Lista(this.itens);
}

class Formula extends Bloco {
  final String texto;
  const Formula(this.texto);
}

class Tabela extends Bloco {
  final List<String> cabecalho;
  final List<List<String>> linhas;
  const Tabela(this.cabecalho, this.linhas);
}

/// Fonte ou aviso sobre a confiabilidade do dado.
class Nota extends Bloco {
  final String texto;
  const Nota(this.texto);
}

class Conceito {
  final String titulo;
  final String resumo;
  final IconData icone;
  final List<Bloco> blocos;

  const Conceito({
    required this.titulo,
    required this.resumo,
    required this.icone,
    required this.blocos,
  });
}

/// Conceitos da base de conhecimento (docs/base-conhecimento). Dados marcados
/// "a confirmar" ainda não foram lidos na fonte original ou vêm de fabricante.
const conceitos = <Conceito>[
  Conceito(
    titulo: 'Plantabilidade',
    resumo: 'A semente certa, no lugar certo, na profundidade certa',
    icone: Icons.grain,
    blocos: [
      Paragrafo(
        'Plantabilidade é a qualidade com que a semeadora coloca cada semente '
        'no lugar certo: espaçamento uniforme na linha, profundidade correta '
        'e bom contato com o solo, para que as plantas emerjam juntas e sem '
        'competir entre si.',
      ),
      Paragrafo(
        'Na prática, o termo é usado quase sempre para a distribuição na '
        'linha: quantas sementes caíram no espaçamento certo, quantas caíram '
        'juntas (duplas) e onde ficou buraco (falhas).',
      ),
      Subtitulo('Por que importa'),
      Paragrafo(
        'A população de plantas e o arranjo delas na linha definem o teto de '
        'produtividade da lavoura. Plantas desiguais competem por luz, água '
        'e nutrientes, e as menores produzem pouco.',
      ),
      Subtitulo('O que mais afeta'),
      Lista([
        'Tipo de dosador: os pneumáticos tendem a distribuir com mais '
            'uniformidade que os mecânicos de disco horizontal.',
        'Velocidade de plantio: quanto mais rápido, maior a variação entre '
            'espaçamentos.',
        'Semente: tamanho, formato e pureza do lote. Sementes fora do padrão '
            'do disco geram falhas e duplas.',
        'Regulagem e manutenção: disco correto para a semente, peças gastas, '
            'vácuo e limpeza.',
      ]),
      Nota('Fontes: Tosin et al., 2025; Borghi et al., 2018 (Embrapa).'),
    ],
  ),
  Conceito(
    titulo: 'Estande de plantas',
    resumo: 'Plantas efetivamente estabelecidas por área',
    icone: Icons.forest_outlined,
    blocos: [
      Paragrafo(
        'Estande é o número de plantas efetivamente estabelecidas por área '
        '(plantas/ha) ou por metro. É diferente da quantidade de sementes '
        'distribuídas: a diferença está nas sementes que não germinaram, nas '
        'plântulas que morreram e nas falhas da semeadora.',
      ),
      Tabela(
        ['Termo', 'Significado'],
        [
          ['População recomendada', 'Quanto a cultivar ou híbrido pede'],
          [
            'Sementes por metro',
            'O que a semeadora deve distribuir, já considerando germinação '
                'e perdas',
          ],
          ['Estande inicial', 'Plantas contadas logo após a emergência'],
          ['Estande final', 'Plantas vivas na colheita'],
        ],
      ),
      Formula(
        'plantas/ha = plantas por metro × 10.000 ÷ espaçamento entre linhas (m)',
      ),
      Subtitulo('O que a pesquisa mostra'),
      Lista([
        'Milho safrinha em 289 talhões de Mato Grosso: estande médio de '
            '57.636 plantas/ha, de 32.000 a 88.000.',
        'Só 20% dos talhões tinham distribuição sem falhas nem duplas.',
        'Em média, as falhas tiraram 4.785 plantas/ha da lavoura.',
      ]),
      Nota('Fonte: Borghi et al., 2018 (Embrapa/Aprosoja).'),
    ],
  ),
  Conceito(
    titulo: 'Duplas e falhas',
    resumo: 'Como classificar cada espaçamento medido na trena',
    icone: Icons.straighten,
    blocos: [
      Paragrafo(
        'Cada espaçamento entre duas plantas vizinhas é comparado com o '
        'espaçamento ideal, calculado pela regulagem (100 ÷ sementes por '
        'metro, em cm).',
      ),
      Tabela(
        ['Classe', 'Critério'],
        [
          ['Dupla', 'menor que 0,5 × o ideal'],
          ['Aceitável', 'de 0,5 a 1,5 × o ideal'],
          ['Falha', 'maior que 1,5 × o ideal'],
        ],
      ),
      Nota('Critério da ABNT, usado em avaliações de semeadoras.'),
      Subtitulo('Desempenho pela % de aceitáveis'),
      Tabela(
        ['% de aceitáveis', 'Desempenho'],
        [
          ['90 a 100%', 'Ótimo'],
          ['75 a 90%', 'Bom'],
          ['50 a 75%', 'Regular'],
          ['abaixo de 50%', 'Insatisfatório'],
        ],
      ),
      Nota(
        'A confirmar: Tourino & Klingensteiner (1983), citado por vários '
        'trabalhos; original não consultado.',
      ),
    ],
  ),
  Conceito(
    titulo: 'Coeficiente de variação',
    resumo: 'Quanto os espaçamentos variam em torno da média',
    icone: Icons.ssid_chart,
    blocos: [
      Paragrafo(
        'O CV mostra quanto os espaçamentos variam em torno da média. CV '
        'baixo quer dizer plantas espaçadas de forma regular. Ele complementa '
        'a contagem de duplas e falhas: duas linhas podem ter zero falhas e '
        'CVs diferentes.',
      ),
      Formula('CV (%) = desvio padrão dos espaçamentos ÷ média × 100'),
      Subtitulo('Cuidado ao comparar'),
      Lista([
        'CV dos espaçamentos entre plantas: o usado no app e na literatura '
            'de semeadoras.',
        'CV do número de plantas por trecho (por exemplo, a cada 5 m): '
            'usado por alguns aplicativos de fabricante. Dá valores bem '
            'diferentes e não deve ser comparado com o primeiro.',
      ]),
      Subtitulo('Valores encontrados na soja'),
      Tabela(
        ['Dosador', 'CV observado'],
        [
          ['Pneumático, 62 furos', '11 a 18%'],
          ['Pneumático, 56 furos', '18 a 27%'],
          ['Disco horizontal, 90 furos', '37 a 53%'],
        ],
      ),
      Nota(
        'Fonte: Tosin et al., 2025, com CV por trecho; serve para comparar '
        'dosadores, não como meta. Ainda não há uma tabela de classes de CV '
        '(ótimo, bom, regular) com fonte confirmada.',
      ),
    ],
  ),
  Conceito(
    titulo: 'Singularização',
    resumo: 'Uma semente de cada vez, sem pular e sem duplicar',
    icone: Icons.filter_1,
    blocos: [
      Paragrafo(
        'Singularização é a capacidade do dosador de liberar uma semente de '
        'cada vez, sem pular (falha) e sem soltar duas ou três juntas (dupla '
        'ou múltipla).',
      ),
      Formula('Singularização (%) = 100 − % de falhas − % de múltiplas'),
      Subtitulo('Causas comuns de má singularização'),
      Lista([
        'Disco incompatível com o tamanho ou formato da semente.',
        'Peças gastas no dosador.',
        'Vácuo ou eliminador de duplas fora de regulagem (pneumáticos).',
        'Velocidade acima da indicada para o dosador.',
      ]),
      Paragrafo(
        'Um dosador pode singularizar 99% e mesmo assim gerar espaçamentos '
        'irregulares, se a semente quica no tubo condutor ou se a velocidade '
        'varia. Por isso a avaliação no campo mede o espaçamento entre '
        'plantas, não só a singularização.',
      ),
      Nota(
        'A confirmar: fórmula e causas vistas em material de universidade '
        '(Svirk, 2023) e de extensão.',
      ),
    ],
  ),
  Conceito(
    titulo: 'Perdas por plantio desuniforme',
    resumo: 'Quanto a lavoura perde com duplas, falhas e variação',
    icone: Icons.trending_down,
    blocos: [
      Subtitulo('Milho: o mais sensível'),
      Paragrafo(
        'Cada cm a mais de desvio padrão dos espaçamentos custa em média '
        'cerca de 62 kg/ha (≈ 1 saca/ha), acima de uma referência de 5 cm. '
        'A faixa vai de 30 a 111 kg/ha por cm.',
      ),
      Formula('perda (kg/ha) = 62 × (desvio padrão medido − 5 cm)'),
      Nota(
        'Fonte: Nielsen (Purdue). Estudos dos EUA, com linhas de 76 cm; no '
        'Brasil o efeito pode ser diferente.',
      ),
      Subtitulo('Soja: falhas e duplas'),
      Paragrafo(
        'A soja não compensa toda falha: as plantas vizinhas produzem mais, '
        'mas recuperaram em média só cerca de 25% da perda. Duplas e triplas '
        'também reduzem a produtividade.',
      ),
      Formula('perda (%) = 0,74 × % de plantas faltando + 0,21 × % a mais'),
      Nota('Fonte: Fiss et al., 2018 (UFPel), um local e duas cultivares.'),
      Subtitulo('Feijão'),
      Formula('perda (%) = 0,44 × CV (%)'),
      Nota('Fonte: Bisognin et al., 2019.'),
      Subtitulo('Resumo para o consultor'),
      Lista([
        'Milho é a cultura onde a uniformidade mais paga.',
        'Falhas custam mais que duplas: tiram plantas do estande e não são '
            'compensadas.',
        'Emergência uniforme importa tanto quanto o espaçamento, '
            'principalmente na soja.',
        'Medir é barato: poucas linhas medidas por talhão já mostram o '
            'problema.',
      ]),
    ],
  ),
  Conceito(
    titulo: 'Emergência uniforme',
    resumo: 'Todas as plantas saindo do solo ao mesmo tempo',
    icone: Icons.spa_outlined,
    blocos: [
      Paragrafo(
        'Emergência uniforme é todas as plantas da linha saírem do solo ao '
        'mesmo tempo, no mesmo dia ou com poucas horas de diferença. É a '
        'outra metade da plantabilidade: o espaçamento mostra onde a planta '
        'está; a emergência mostra quando ela começou a competir.',
      ),
      Paragrafo(
        'Uma planta que emerge depois das vizinhas passa a safra inteira em '
        'desvantagem: fica menor e disputa luz, água e nutrientes com plantas '
        'mais fortes. Na prática, vira planta dominada: ocupa espaço, consome '
        'insumo e produz pouco ou nada.',
      ),
      Subtitulo('Quanto se perde no milho'),
      Tabela(
        ['Emergência da planta', 'Redução do potencial'],
        [
          ['5 dias após o plantio', 'referência'],
          ['6 dias (1 dia depois)', '35%'],
          ['8 dias (3 dias depois)', '85%'],
        ],
      ),
      Nota(
        'Referência usada pela equipe J.Assy; fonte do estudo a informar. '
        'Regra de campo: a cada 2 dias de atraso, a planta fica 1 estádio '
        'atrás.',
      ),
      Tabela(
        ['Situação no estande', 'Perda'],
        [
          ['Parte do estande ~1,5 semana atrasada', '6 a 9%'],
          ['25% das plantas 3 semanas atrasadas', '~10%'],
          ['50 a 75% das plantas 3 semanas atrasadas', '20 a 22%'],
        ],
      ),
      Nota('Fonte: Nafziger, Carter & Graham, 1991 (Illinois e Wisconsin).'),
      Subtitulo('Causas da emergência desigual'),
      Lista([
        'Profundidade irregular: semente rasa fica no seco; funda demais '
            'demora a emergir.',
        'Downforce insuficiente: a linha flutua e deixa a semente rasa.',
        'Downforce em excesso: compacta as paredes do sulco e prejudica a '
            'raiz.',
        'Umidade desigual no sulco, palha no sulco e mau contato '
            'semente-solo.',
        'Solo diferente entre linhas, inclusive pelo rodado do trator.',
      ]),
      Paragrafo(
        'O ponto comum: quase todas as causas de máquina passam por '
        'profundidade e contato semente-solo, e os dois dependem da força na '
        'linha estar certa em cada linha, o tempo todo.',
      ),
    ],
  ),
  Conceito(
    titulo: 'Downforce',
    resumo: 'A força certa em cada linha: o conceito J.Assy',
    icone: Icons.compress,
    blocos: [
      Paragrafo(
        'Downforce é a força resultante na linha de plantio, considerando o '
        'peso da linha, a força aplicada sobre ela e a resistência do solo à '
        'penetração.',
      ),
      Formula(
        'Downforce = força aplicada + peso da linha − resistência do solo',
      ),
      Lista([
        'A resultante chega ao solo pelas rodas limitadoras de profundidade: '
            'é ali que se instala o sensor para medi-la.',
        'É a força necessária para a semente ficar sempre na profundidade '
            'desejada, sem compactar o sulco ao redor dela.',
        'Funciona como um indicador da densidade do solo ao redor da '
            'semente.',
      ]),
      Tabela(
        ['Downforce', 'No sulco', 'Efeito'],
        [
          [
            'Acima do adequado',
            'Compactação (espelhamento)',
            'Prejudica as raízes',
          ],
          [
            'Abaixo do ideal',
            'Sulco desmorona antes das rodas cobridoras',
            'Germinação irregular',
          ],
          [
            'Muito abaixo',
            'Semente não alcança a umidade',
            'Emergência atrasada ou falha',
          ],
        ],
      ),
      Subtitulo('Medir e corrigir'),
      Lista([
        'Medir em tempo real: o sensor LoadPin, no apoio das rodas '
            'limitadoras, lê a downforce metro a metro e mostra onde e em que '
            'linha a força está errada.',
        'Corrigir em tempo real: molas e bolsas de ar aplicam a mesma força '
            'em todas as linhas. Um pistão hidráulico com controle por '
            'linha ajusta a força enquanto planta.',
      ]),
      Subtitulo('Level (J.Assy)'),
      Lista([
        'Controle de pressão da linha por força hidráulica, desenvolvido '
            'para as condições brasileiras.',
        'Pressões diferentes em cada linha, conforme o solo.',
        'Usa o índice de flutuação da linha para manter profundidade e '
            'emergência uniformes.',
      ]),
      Nota('Fonte: material técnico da J.Assy.'),
    ],
  ),
];
