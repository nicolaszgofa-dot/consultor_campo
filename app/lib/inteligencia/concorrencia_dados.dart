/// Conteúdo da aba Concorrência: fichas de batalha e ficha técnica por linha
/// de produto. Fatos dos concorrentes vêm de sites e imprensa (26/10/2026);
/// provas científicas, de docs/base-conhecimento/dosadores-pesquisas.md.
/// Respostas e perguntas são rascunho para o time comercial validar.
library;

enum TipoProva {
  citaJassy('Cita a J.Assy'),
  sustenta('Sustenta a tese'),
  contraConcorrente('Contra o concorrente'),
  contexto('Contexto'),
  cuidado('Cuidado');

  final String rotulo;

  const TipoProva(this.rotulo);

  bool get aFavor =>
      this == citaJassy || this == sustenta || this == contraConcorrente;
}

class Prova {
  final String fonte;
  final TipoProva tipo;
  final String achado;
  final String uso;

  const Prova(this.fonte, this.tipo, this.achado, this.uso);
}

class Objecao {
  final String objecao;
  final String resposta;

  /// Depende de dado técnico interno da J.Assy.
  final bool confirmar;

  const Objecao(this.objecao, this.resposta, {this.confirmar = false});
}

class Concorrente {
  final String id;
  final String nome;
  final String produto;
  final List<String> ataca;
  final List<Objecao> objecoes;

  const Concorrente({
    required this.id,
    required this.nome,
    required this.produto,
    required this.ataca,
    required this.objecoes,
  });
}

/// Ferramenta do app que ajuda a provar o argumento no cliente.
class ProvaApp {
  final String titulo;
  final String texto;

  const ProvaApp(this.titulo, this.texto);
}

enum TipoCelula { tem, info, naoInformado }

class Celula {
  final TipoCelula tipo;
  final String? texto;

  const Celula._(this.tipo, this.texto);
}

Celula tem(String texto) => Celula._(TipoCelula.tem, texto);
Celula info(String texto) => Celula._(TipoCelula.info, texto);
Celula ni([String? nota]) => Celula._(TipoCelula.naoInformado, nota);

class ProdutoTecnico {
  final String marca;
  final String nome;
  final bool jassy;
  final String situacao;
  final Map<String, Celula> valores;

  const ProdutoTecnico({
    required this.marca,
    required this.nome,
    this.jassy = false,
    required this.situacao,
    required this.valores,
  });
}

class Fonte {
  final String rotulo;
  final String url;

  const Fonte(this.rotulo, this.url);
}

class LinhaProduto {
  final String id;
  final String nome;
  final String jassy;

  // Ficha de batalha.
  final String tese;
  final String apoio;
  final String numero;
  final String numeroTexto;
  final String numeroFonte;
  final String? destaque;
  final List<String> ganhamos;
  final List<Concorrente> concorrentes;
  final List<Objecao> objecoesComuns;
  final List<Prova> provas;
  final String cuidado;
  final List<String> perguntas;
  final List<ProvaApp> provasApp;

  // Ficha técnica.
  final List<(String, String)> criterios;
  final List<ProdutoTecnico> produtos;
  final List<Fonte> fontes;

  const LinhaProduto({
    required this.id,
    required this.nome,
    required this.jassy,
    required this.tese,
    required this.apoio,
    required this.numero,
    required this.numeroTexto,
    required this.numeroFonte,
    this.destaque,
    required this.ganhamos,
    required this.concorrentes,
    required this.objecoesComuns,
    required this.provas,
    required this.cuidado,
    required this.perguntas,
    required this.provasApp,
    required this.criterios,
    required this.produtos,
    required this.fontes,
  });
}

const _avaliacaoPlantio = ProvaApp(
  'Avaliação de plantio',
  'Meça duplas, falhas e CV na máquina e na velocidade do cliente.',
);

final linhasProduto = <LinhaProduto>[
  LinhaProduto(
    id: 'mecanicos',
    nome: 'Dosadores mecânicos',
    jassy: 'Titanium',
    tese:
        'Mais velocidade sem perder o plantio: o Titanium segura a '
        'distribuição onde o dosador convencional desaba.',
    apoio:
        'Em estudo de campo da UnB, a diferença aparece exatamente quando o '
        'produtor acelera.',
    numero: '−33%',
    numeroTexto: 'falhas do Titanium contra o convencional a 8,2 km/h, na soja',
    numeroFonte: 'UnB, Energia na Agricultura, 2020',
    ganhamos: [
      'Distribuição constante até 8,2 km/h em campo (UnB): 75,7% de '
          'aceitáveis contra 64,5% do convencional.',
      'Dano à semente perto do dos pneumáticos e menor que o do Plantsystem '
          '(UNESP).',
      'Caminho de upgrade: o mesmo dosador vira Titanium Elétric.',
      'Adaptação catalogada para 14 marcas e 32 modelos; disco Apollo '
          'Rampflow.',
    ],
    concorrentes: [
      Concorrente(
        id: 'x3',
        nome: 'TOPlanting TOP X3',
        produto: 'Dosador mecânico com 3 organizadores',
        ataca: [
          'Preço de kit de entrada nas revendas.',
          'Promete até 20% mais velocidade que dosadores convencionais.',
          'Base universal, monta em quase todas as plantadeiras.',
        ],
        objecoes: [
          Objecao(
            'O TOP X3 promete 20% mais velocidade.',
            'É número do fabricante. O Titanium tem estudo de campo de '
                'universidade: a 8,2 km/h, 33% menos falhas que o '
                'convencional. Pergunte se existe estudo independente do X3.',
          ),
        ],
      ),
      Concorrente(
        id: 'plantsystem',
        nome: 'Embreparts Plantsystem',
        produto: 'Dosador mecânico modificado',
        ataca: [
          'Kit barato e conhecido nas revendas de peças.',
          'Disco Declínio Max e organizador de aletas.',
        ],
        objecoes: [
          Objecao(
            'Já uso Plantsystem e está bom.',
            'No ensaio da UNESP com milho e soja, o Plantsystem teve o pior '
                'resultado em dano à semente entre cinco dosadores; o '
                'Titanium ficou perto dos pneumáticos.',
          ),
        ],
      ),
    ],
    objecoesComuns: [
      Objecao(
        'Dosador mecânico é tudo igual.',
        'A 4,5 km/h quase todos empatam. A diferença aparece acima de '
            '6 km/h: mostre a tabela da UnB na velocidade que o cliente usa.',
      ),
    ],
    provas: [
      Prova(
        'UnB 2020',
        TipoProva.citaJassy,
        'Soja em campo: a 6,2 km/h, 78,1% x 73,7% de aceitáveis; a 8,2 km/h, '
            '75,7% x 64,5%. Falhas 18% e 33% menores no Titanium.',
        'Prova principal da linha. Mostre na faixa de velocidade do cliente.',
      ),
      Prova(
        'UNESP 2021–2022',
        TipoProva.citaJassy,
        'Entre cinco dosadores, os pneumáticos danificaram menos a semente; o '
            'Titanium ficou próximo deles e o Plantsystem foi o pior.',
        'Contra o Plantsystem e para mostrar cuidado com a semente.',
      ),
      Prova(
        'UFPel 2024',
        TipoProva.contexto,
        'No disco horizontal, tubo condutor, inclinação e velocidade mudam '
            'duplas e falhas; melhor resultado a 5 km/h e nivelado.',
        'Explica por que medir na fazenda: o conjunto inteiro conta.',
      ),
    ],
    cuidado:
        'Na UNESP, o dano à semente cresceu com a velocidade em todos os '
        'dosadores, Titanium incluído; 4 a 6 km/h foi a faixa de menor dano. '
        'Não prometa velocidade sem limite.',
    perguntas: [
      'Em que velocidade planta hoje e quer plantar?',
      'Qual a idade dos discos e anéis?',
      'Planta milho, soja ou pipoqueira na mesma máquina?',
      'Já mediu falhas e duplas?',
      'Pensa em motorizar a plantadeira depois?',
    ],
    provasApp: [
      _avaliacaoPlantio,
      ProvaApp('ROI', 'Mostre o ganho por hectare com menos falhas.'),
      ProvaApp(
        'Configurador',
        'Monte a adaptação Titanium para a marca e o modelo do cliente.',
      ),
    ],
    criterios: [
      ('tipo', 'Mecanismo'),
      ('dif', 'Diferencial divulgado'),
      ('compat', 'Compatibilidade'),
      ('cult', 'Culturas e kits'),
      ('vel', 'Velocidade'),
      ('eletrico', 'Versão com motor elétrico'),
    ],
    produtos: [
      ProdutoTecnico(
        marca: 'J.Assy',
        nome: 'Titanium',
        jassy: true,
        situacao: 'No mercado',
        valores: {
          'tipo': info('Mecânico, de disco'),
          'dif': info('Disco Apollo Rampflow, escova e organizadores'),
          'compat': tem('Adaptação para 14 marcas e 32 modelos'),
          'cult': info('Milho e soja; kits pipoqueira e canola'),
          'vel': info('Distribuição constante até 8,2 km/h (UnB)'),
          'eletrico': tem(
            'Titanium Elétric: ISOBUS, linha a linha, taxa '
            'variável, wireless',
          ),
        },
      ),
      ProdutoTecnico(
        marca: 'TOPlanting',
        nome: 'TOP X3',
        situacao: 'No mercado',
        valores: {
          'tipo': info('Mecânico; 3 organizadores com gatilhos retráteis'),
          'dif': info('Elimina duplas (fabricante)'),
          'compat': tem('Base universal: quase todas as plantadeiras'),
          'cult': info('Kit soja'),
          'vel': info('Até 20% acima dos convencionais (fabricante)'),
          'eletrico': ni('o site cita um TOP X3 Control, sem descrição'),
        },
      ),
    ],
    fontes: [
      Fonte(
        'Campo Forte – TOP X3',
        'https://www.campoforte.net/agricultura-de-precisao/top-x3',
      ),
      Fonte('J.Assy – Dosadores', 'https://jassy.ag/dosadores/'),
      Fonte(
        'Park Máquinas – Titanium Elétric',
        'https://parkmaquinas.com/p/dosador-mecanico-com-motor-eletrico-titanium-eletric/',
      ),
    ],
  ),

  LinhaProduto(
    id: 'pneumaticos',
    nome: 'Dosadores pneumáticos',
    jassy: 'Selenium',
    tese:
        'Pneumático que trata bem a semente e cabe em 37 modelos de '
        'plantadeira, com caminho para o elétrico.',
    apoio:
        'Pneumáticos danificam menos a semente que mecânicos; o Selenium leva '
        'isso para a máquina que o produtor já tem.',
    numero: '37',
    numeroTexto: 'modelos de plantadeira com adaptação Selenium, em 11 marcas',
    numeroFonte: 'Catálogo do Configurador',
    ganhamos: [
      'Ensaio J.Assy em campo: Selenium Elétric com 85,4% de aceitáveis '
          'contra 76,1% do vSet, e 9,2 contra 8,5 plantas por metro, com '
          'diferença estatística.',
      'Menos dano à semente que os dosadores mecânicos (UNESP).',
      'Reposição para 11 marcas e 37 modelos, inclusive no lugar do original '
          'de fábrica.',
      'Selenium Elétric: até 60 linhas, ISOBUS, linha a linha; kit conversão '
          'do Selenium G3.',
      'Culturas: algodão, milho, soja, sorgo e feijão.',
    ],
    concorrentes: [
      Concorrente(
        id: 'topv',
        nome: 'TOPlanting TOP V',
        produto: 'Dosador a vácuo',
        ataca: [
          'Eliminador de duplas autoajustável, sem regulagem.',
          'Troca de disco sem ferramentas.',
          'Sete culturas recomendadas.',
        ],
        objecoes: [
          Objecao(
            'O TOP V não precisa de regulagem.',
            'Mostre o caminho para o elétrico e a adaptação por modelo. '
                'Pergunte se o TOP V tem versão motorizada e estudo '
                'independente.',
            confirmar: true,
          ),
        ],
      ),
      Concorrente(
        id: 'vset',
        nome: 'Precision Planting vSet',
        produto: 'Dosador a vácuo com vDrive',
        ataca: [
          'Singulação acima de 99% (fabricante).',
          '13 kits de culturas; mais de 10 marcas no Brasil.',
          'vDrive de fábrica nas plantadeiras Valtra.',
        ],
        objecoes: [
          Objecao(
            'O vSet tem 99% de singulação.',
            'É dado do fabricante, em bancada. No ensaio J.Assy em campo, o '
                'Selenium Elétric teve 85,4% de aceitáveis contra 76,1% do '
                'vSet e mais plantas por metro (9,2 x 8,5). Proponha medir as '
                'duas máquinas na fazenda com a Avaliação de plantio.',
          ),
        ],
      ),
      Concorrente(
        id: 'stara',
        nome: 'Original Stara',
        produto: 'Dosador pneumático de fábrica',
        ataca: ['Já vem na plantadeira; reposição pela rede Stara.'],
        objecoes: [
          Objecao(
            'Prefiro manter a peça original.',
            'Meça o original na velocidade de trabalho. Os estudos da UFSM '
                'mostram que pneumáticos perdem aceitáveis com velocidade e '
                'inclinação; o Selenium abre o caminho para o elétrico.',
          ),
        ],
      ),
      Concorrente(
        id: 'jd',
        nome: 'Original John Deere',
        produto: 'MaxEmerge 5 / 5e e VacuMeter',
        ataca: [
          'De fábrica na linha DB.',
          'MaxEmerge 5e: +16% de precisão e até 7% menos semente '
              '(fabricante).',
        ],
        objecoes: [
          Objecao(
            'John Deere é John Deere.',
            'Pergunte que versão ele tem: o 5e é a versão elétrica. Para quem '
                'tem a versão de entrada, o Selenium Elétric leva linha a '
                'linha e taxa variável sem trocar a plantadeira.',
            confirmar: true,
          ),
        ],
      ),
    ],
    objecoesComuns: [
      Objecao(
        'Meu pneumático original está bom.',
        'Meça antes: a Avaliação de plantio mostra duplas, falhas e CV na '
            'velocidade real.',
      ),
    ],
    provas: [
      Prova(
        'Ensaio J.Assy',
        TipoProva.contraConcorrente,
        'Selenium Elétric x vSet em campo: 85,4% x 76,1% de aceitáveis e '
            '9,2 x 8,5 plantas/m, com diferença estatística. CV (33,1% x '
            '40,9%) e falhas (13,7% x 20,0%) sem diferença estatística.',
        'Prova principal contra o vSet. Venda aceitáveis e estande, não '
            'falhas.',
      ),
      Prova(
        'UNESP 2021–2022',
        TipoProva.citaJassy,
        'Selenium e Jumil (pneumáticos) tiveram mais viabilidade e vigor que '
            'os mecânicos em milho e soja.',
        'Para quem ainda usa mecânico em lavoura de semente cara.',
      ),
      Prova(
        'UFSM 2014',
        TipoProva.contexto,
        'Inclinação lateral e velocidade pioram a distribuição de três '
            'dosadores pneumáticos com soja.',
        'Argumento para medir em terreno inclinado e na velocidade real.',
      ),
      Prova(
        'China 2023',
        TipoProva.contexto,
        'Acima de 12 km/h, a principal falha do pneumático é a semente não '
            'captada; com vácuo acima de 6 kPa ficou abaixo de 10%.',
        'Orientação de regulagem do vácuo em alta velocidade.',
      ),
      Prova(
        'UFSM 2018',
        TipoProva.contexto,
        'Em feijão-caupi, os pneumáticos tiveram mais espaçamentos aceitáveis '
            'que o disco alveolado.',
        'Para culturas além de soja e milho.',
      ),
    ],
    cuidado:
        'Na UNESP o melhor resultado geral foi do Jumil, e em umidade da '
        'semente de milho o Selenium ficou atrás do Plantsystem. Use o estudo '
        'como pneumático x mecânico, não Selenium x Jumil. No ensaio J.Assy, '
        'o Selenium Elétric variou bastante entre repetições e não diferiu do '
        'vSet em CV e falhas; o ensaio é interno, não independente.',
    perguntas: [
      'Qual a marca e o modelo da plantadeira?',
      'Planta em terreno inclinado?',
      'Em que velocidade?',
      'Quais culturas planta?',
      'Tem interesse em linha a linha e taxa variável?',
    ],
    provasApp: [
      _avaliacaoPlantio,
      ProvaApp(
        'Configurador',
        'Veja a adaptação Selenium para o modelo do cliente.',
      ),
      ProvaApp('ROI', 'Compare a reposição Selenium com plantadeira nova.'),
    ],
    criterios: [
      ('tipo', 'Mecanismo'),
      ('dif', 'Diferencial divulgado'),
      ('cult', 'Culturas'),
      ('eletrico', 'Versão com motor elétrico'),
      ('onde', 'Onde se encontra'),
      ('desemp', 'Desempenho divulgado'),
    ],
    produtos: [
      ProdutoTecnico(
        marca: 'J.Assy',
        nome: 'Selenium',
        jassy: true,
        situacao: 'No mercado',
        valores: {
          'tipo': info('Pneumático'),
          'dif': ni(),
          'cult': info('Algodão, milho, soja, sorgo e feijão'),
          'eletrico': tem(
            'Selenium Elétric: até 60 linhas, ISOBUS, linha a '
            'linha, wireless',
          ),
          'onde': tem('Adaptação para 11 marcas e 37 modelos'),
          'desemp': info(
            'Elétric: 85,4% de aceitáveis contra 76,1% do vSet (ensaio '
            'J.Assy); menos dano à semente que os mecânicos (UNESP)',
          ),
        },
      ),
      ProdutoTecnico(
        marca: 'TOPlanting',
        nome: 'TOP V',
        situacao: 'No mercado',
        valores: {
          'tipo': info('A vácuo; semente captada em ângulo no disco'),
          'dif': info(
            'Eliminador de duplas autoajustável; troca de disco sem '
            'ferramentas',
          ),
          'cult': info(
            'Algodão, canola, feijão, girassol, milho, soja e '
            'sorgo',
          ),
          'eletrico': ni(),
          'onde': info('Reposição em revendas'),
          'desemp': ni(),
        },
      ),
      ProdutoTecnico(
        marca: 'Precision Planting',
        nome: 'vSet',
        situacao: 'No mercado',
        valores: {
          'tipo': info('A vácuo, disco plano com singulador'),
          'dif': info('Disco plano aceita sementes de tamanhos variados'),
          'cult': info('13 kits, mais de 20 culturas'),
          'eletrico': tem('vDrive; de fábrica nas plantadeiras Valtra'),
          'onde': tem('Mais de 10 marcas de plantadeira no Brasil'),
          'desemp': info('Singulação acima de 99% (fabricante)'),
        },
      ),
      ProdutoTecnico(
        marca: 'Stara',
        nome: 'Dosador original',
        situacao: 'De fábrica',
        valores: {
          'tipo': info('Pneumático, nas plantadeiras Stara'),
          'dif': ni(),
          'cult': ni(),
          'eletrico': ni(),
          'onde': info('Só Stara; reposição pela rede Stara'),
          'desemp': ni(),
        },
      ),
      ProdutoTecnico(
        marca: 'John Deere',
        nome: 'MaxEmerge 5 / 5e e VacuMeter',
        situacao: 'De fábrica',
        valores: {
          'tipo': info('A vácuo, na linha DB'),
          'dif': info(
            '5e: +16% de precisão e até 7% menos semente com linha '
            'a linha (fabricante)',
          ),
          'cult': ni(),
          'eletrico': tem('MaxEmerge 5e com acionamento elétrico'),
          'onde': info('Só John Deere (DB40, DB50, DB74 e outras)'),
          'desemp': info('+9% de capacidade operacional no 5e (fabricante)'),
        },
      ),
    ],
    fontes: [
      Fonte(
        'TOPlanting – TOP V',
        'https://toplanting.com/produtos-toplanting/dosador-de-sementes-a-vacuo-top-v/',
      ),
      Fonte(
        'Precision Planting – vSet',
        'https://www.precisionplanting.com.br/produtos/vset',
      ),
      Fonte(
        'Revista Cultivar – John Deere MaxEmerge 5e',
        'https://revistacultivar.com.br/noticias/john-deere-lanca-plantadeira-db-maxemerge-5e',
      ),
    ],
  ),

  LinhaProduto(
    id: 'motor',
    nome: 'Motorização elétrica',
    jassy: 'Titanium e Selenium Elétric',
    tese:
        'Motor em dosador gasto só erra mais rápido. A J.Assy troca dosador '
        'e acionamento juntos.',
    apoio:
        'A precisão da semente vem do dosador; o motor só controla a rotação. '
        'Pesquisa com plantadeiras motorizadas confirma.',
    numero: '−17%',
    numeroTexto:
        'na qualidade de plantio de 5 a 12 km/h, mesmo com motor elétrico, por '
        'causa das falhas',
    numeroFonte: 'China, IJABE, 2022',
    destaque:
        'A J.Assy vende a solução completa: dosador + motor. Os concorrentes '
        'desta linha vendem só o motor e usam o dosador que já está na '
        'plantadeira.',
    ganhamos: [
      'Dosador novo e motor no mesmo pacote: precisão da dosagem e controle '
          'elétrico juntos.',
      'Um fornecedor só responde pelo dosador e pelo acionamento.',
      'Monitoramento de duplas, falhas, CV e espaçamento integrado.',
      'Adaptação catalogada: 14 marcas e 32 modelos (Titanium) e 11 marcas e '
          '37 modelos (Selenium).',
    ],
    concorrentes: [
      Concorrente(
        id: 'mafra',
        nome: 'Mafra Tech',
        produto: 'M-Drive (retrofit)',
        ataca: [
          'Kit só de motorização, investimento inicial menor.',
          'M-Power gera energia a partir do trator.',
          'ISOBUS, taxa fixa e variável, linha a linha.',
        ],
        objecoes: [
          Objecao(
            'A Mafra gera a própria energia.',
            'A energia já está resolvida na proposta J.Assy: o Configurador '
                'define alternador ou cabo de bateria para cada plantadeira.',
          ),
        ],
      ),
      Concorrente(
        id: 'fortron',
        nome: 'Fortron',
        produto: 'Controle Elétrico de Plantio',
        ataca: [
          'Usa a tela original do trator (ISOBUS).',
          'Kit só de motor, preço de entrada menor.',
        ],
        objecoes: [
          Objecao(
            'O vizinho instalou Fortron e gostou.',
            'Bom sinal para o elétrico. Pergunte como estão duplas e falhas: '
                'o motor não corrige dosador gasto.',
          ),
        ],
      ),
      Concorrente(
        id: 'orion',
        nome: 'Orion',
        produto: 'Seed Saving',
        ataca: [
          'Compensação em curva divulgada.',
          'Até 7% de semente (15% com taxa variável) e até 14% de '
              'produtividade (fabricante).',
          'Motor 24 V acoplado ao dosador existente.',
        ],
        objecoes: [
          Objecao(
            'A Orion promete 14% de produtividade.',
            'É número do fabricante. Pesquisa nos EUA (2026) mostra que o '
                'ganho do acionamento elétrico é flexibilidade de velocidade, '
                'não produtividade garantida. Proponha medir na fazenda.',
          ),
          Objecao(
            'A Orion compensa a curva. E a J.Assy?',
            'Responda com o dado técnico do Titanium e do Selenium Elétric.',
            confirmar: true,
          ),
        ],
      ),
      Concorrente(
        id: 'agrosystem',
        nome: 'Agrosystem',
        produto: 'Só motor não encontrado; divulga o Bolt (dosador completo)',
        ataca: [
          'Bolt: pressão positiva com turbina por linha; vendas previstas a '
              'partir da Agrishow 2026.',
        ],
        objecoes: [
          Objecao(
            'Vou esperar o Bolt.',
            'O Bolt foi validado só em milho e soja e acabou de sair do '
                'pré-lançamento. A J.Assy já está no campo.',
            confirmar: true,
          ),
        ],
      ),
    ],
    objecoesComuns: [
      Objecao(
        'Só o motor sai mais barato.',
        'Compare o custo total: o dosador antigo continua gastando e errando. '
            'Coloque o valor do concorrente no ROI.',
      ),
      Objecao(
        'Meu dosador ainda está bom.',
        'Meça: dosador com erro alto continua errando com motor.',
      ),
    ],
    provas: [
      Prova(
        'China 2022',
        TipoProva.sustenta,
        'Duas plantadeiras com dosador motorizado perderam 10 a 17% de '
            'qualidade de 5 para 12 km/h, quase tudo por falhas.',
        'Prova de que o motor sozinho não segura a qualidade: o dosador '
            'decide.',
      ),
      Prova(
        'EUA 2026',
        TipoProva.sustenta,
        'Acionamento elétrico e hidráulico mantiveram o estande a 8 km/h '
            'melhor que o de engrenagem; o limite continuou sendo a '
            'singulação do dosador.',
        'Elétrico dá flexibilidade de velocidade; a precisão vem do dosador.',
      ),
    ],
    cuidado:
        'O estudo dos EUA é com amendoim e não encontrou ganho garantido de '
        'produtividade. Venda flexibilidade e redução de risco, não '
        'porcentagem de produtividade.',
    perguntas: [
      'Qual a idade e o estado dos dosadores?',
      'Quanto de duplas e falhas vê hoje?',
      'Em que velocidade quer plantar?',
      'O trator tem monitor ISOBUS? Quantas linhas e seções?',
      'O que mais incomoda: cabeceira, curva, taxa variável ou falha?',
    ],
    provasApp: [
      _avaliacaoPlantio,
      ProvaApp(
        'ROI',
        'Coloque o valor do concorrente e mostre diferença por hectare e '
            'payback.',
      ),
      ProvaApp(
        'Configurador',
        'Monte a proposta completa, com energia e chicotes.',
      ),
    ],
    criterios: [
      ('oferta', 'O que vende'),
      ('dosador', 'Dosador'),
      ('isobus', 'ISOBUS'),
      ('linha', 'Desligamento linha a linha'),
      ('taxa', 'Taxa variável'),
      ('curva', 'Compensação em curva'),
      ('energia', 'Energia'),
      ('desemp', 'Resultado divulgado'),
    ],
    produtos: [
      ProdutoTecnico(
        marca: 'J.Assy',
        nome: 'Titanium / Selenium Elétric',
        jassy: true,
        situacao: 'No mercado',
        valores: {
          'oferta': tem('Dosador + motor'),
          'dosador': tem('Titanium ou Selenium, da J.Assy'),
          'isobus': tem('100% ISOBUS'),
          'linha': tem('Automático'),
          'taxa': tem('Sim'),
          'curva': ni(),
          'energia': info('Alternador ou bateria, conforme a plantadeira'),
          'desemp': ni(),
        },
      ),
      ProdutoTecnico(
        marca: 'Mafra Tech',
        nome: 'M-Drive',
        situacao: 'No mercado',
        valores: {
          'oferta': info('Só motorização e controle'),
          'dosador': info('O da plantadeira'),
          'isobus': tem('Sim'),
          'linha': tem('Sim'),
          'taxa': tem('Fixa e variável'),
          'curva': ni(),
          'energia': info('M-Power; motores de 12 a 24 V'),
          'desemp': ni(),
        },
      ),
      ProdutoTecnico(
        marca: 'Fortron',
        nome: 'Controle Elétrico',
        situacao: 'No mercado',
        valores: {
          'oferta': info('Só motorização e controle'),
          'dosador': info('O da plantadeira'),
          'isobus': tem('Tela original do trator'),
          'linha': tem('Sim'),
          'taxa': tem('Sim'),
          'curva': ni(),
          'energia': ni(),
          'desemp': ni('só depoimento de cliente'),
        },
      ),
      ProdutoTecnico(
        marca: 'Orion',
        nome: 'Seed Saving',
        situacao: 'Desde a safrinha 2025/26',
        valores: {
          'oferta': info('Só motorização e controle'),
          'dosador': info('O da plantadeira (motor 24 V acoplado)'),
          'isobus': tem('Sim'),
          'linha': tem('Sim'),
          'taxa': tem('Sim'),
          'curva': tem('Sim'),
          'energia': info('24 V'),
          'desemp': info(
            'Até 7% menos semente e até 14% de produtividade '
            '(fabricante)',
          ),
        },
      ),
    ],
    fontes: [
      Fonte(
        'Mafra Tech – M-Drive',
        'https://mafra.tech/automacao-para-plantadeira-de-graos/',
      ),
      Fonte(
        'Fortron – caso de retrofit',
        'https://fortron.ag/en/fortron-planter-retrofit/',
      ),
      Fonte(
        'Revista Cultivar – Orion Seed Saving',
        'https://revistacultivar.com.br/noticias/orion-destaca-o-seed-saving-na-expodireto-coopavel',
      ),
    ],
  ),

  LinhaProduto(
    id: 'esteira',
    nome: 'Dosador de esteira',
    jassy: 'Selenium Neo',
    tese:
        'A esteira tira a queda livre do tubo: a semente chega ao solo no '
        'espaçamento do disco, até 16 km/h.',
    apoio:
        'Pesquisas mostram que o tubo condutor e a velocidade mudam duplas e '
        'falhas. O Selenium Neo elimina essa etapa na plantadeira que o '
        'cliente já tem.',
    numero: '94,4%',
    numeroTexto:
        'de espaçamentos aceitáveis do Selenium Neo, contra 84,3% do V Control',
    numeroFonte: 'Ensaio J.Assy',
    ganhamos: [
      'Ensaio J.Assy em campo: 94,4% de aceitáveis e CV de 24,4%, contra '
          '84,3% e 33,2% do V Control, com diferença estatística.',
      'Até 16 km/h com dois motores sincronizados: disco e esteira (J.Assy, '
          'Agrishow 2024).',
      'Retrofit na plantadeira atual; o ExactEmerge vem só de fábrica.',
      'Sensor de semente na esteira, ISOBUS, linha a linha e taxa variável.',
    ],
    concorrentes: [
      Concorrente(
        id: 'exact',
        nome: 'John Deere ExactEmerge',
        produto: 'Esteira de escovas, de fábrica na linha DB',
        ataca: [
          'Marca forte e recorde de área plantada em 24 h no Brasil.',
          'Até 16 km/h.',
        ],
        objecoes: [
          Objecao(
            'Vou comprar plantadeira nova com ExactEmerge.',
            'O Neo leva a esteira para a plantadeira que ele já tem. Use o '
                'ROI: retrofit J.Assy x plantadeira nova.',
          ),
        ],
      ),
      Concorrente(
        id: 'vcontrol',
        nome: 'TOPlanting V Control',
        produto: 'TOP V com condutor de esteira',
        ataca: [
          'Estudo da UFRGS: a 12 km/h, melhor que a plantadeira de referência '
              'a 6 km/h.',
        ],
        objecoes: [
          Objecao(
            'O V Control tem estudo da UFRGS.',
            'O estudo confirma que a esteira funciona em alta velocidade, o '
                'que vale para o Neo também. No ensaio J.Assy lado a lado, o '
                'Neo teve 94,4% de aceitáveis contra 84,3% do V Control e CV '
                'de 24,4% contra 33,2%.',
            confirmar: true,
          ),
        ],
      ),
    ],
    objecoesComuns: [
      Objecao(
        'Esteira é coisa de plantadeira cara.',
        'O Neo é retrofit. Mostre o custo frente a uma plantadeira nova no '
            'ROI.',
      ),
    ],
    provas: [
      Prova(
        'Ensaio J.Assy',
        TipoProva.contraConcorrente,
        'Selenium Neo x V Control em campo: 94,4% x 84,3% de aceitáveis e CV '
            'de 24,4% x 33,2%, com diferença estatística. Falhas (5,1% x '
            '13,9%) e plantas/m (9,4 x 9,4) sem diferença estatística.',
        'Prova principal contra o V Control. Venda aceitáveis e CV, não '
            'falhas.',
      ),
      Prova(
        'UFPel 2024',
        TipoProva.sustenta,
        'O perfil do tubo condutor, a inclinação e a velocidade mudam duplas '
            'e falhas; o melhor resultado foi a 5 km/h e nivelado.',
        'A queda livre no tubo é fonte de erro; a esteira tira essa etapa.',
      ),
      Prova(
        'China 2022',
        TipoProva.sustenta,
        'Mesmo com motor, as falhas sobem com a velocidade entre 5 e 12 km/h.',
        'Para plantar rápido é preciso mudar o caminho da semente, não só o '
            'acionamento.',
      ),
      Prova(
        'UFRGS 2025',
        TipoProva.contexto,
        'Dosador a vácuo com esteira (V Control) a 12 km/h foi melhor que a '
            'referência a 6 km/h.',
        'Mostra que a categoria esteira funciona; vale para o Neo.',
      ),
    ],
    cuidado:
        'O ensaio do Neo é interno (J.Assy), não independente, e a diferença '
        'em falhas não foi significativa. Os 16 km/h são do fabricante; '
        'proponha teste na fazenda.',
    perguntas: [
      'Em que velocidade quer plantar?',
      'Quantos hectares por dia precisa fazer na janela?',
      'Pensa em trocar a plantadeira?',
      'Já sente perda de estande quando acelera?',
    ],
    provasApp: [
      ProvaApp('ROI', 'Compare o retrofit Neo com uma plantadeira nova.'),
      _avaliacaoPlantio,
      ProvaApp('Configurador', 'Monte a adaptação para o modelo do cliente.'),
    ],
    criterios: [
      ('mec', 'Mecanismo'),
      ('vel', 'Velocidade'),
      ('acion', 'Acionamento'),
      ('ctrl', 'Linha a linha e taxa variável'),
      ('sensor', 'Sensor de semente'),
      ('onde', 'Onde se encontra'),
    ],
    produtos: [
      ProdutoTecnico(
        marca: 'J.Assy',
        nome: 'Selenium Neo',
        jassy: true,
        situacao: 'Lançado na Agrishow 2024',
        valores: {
          'mec': info('Disco + esteira de borracha'),
          'vel': tem('Até 16 km/h'),
          'acion': tem('Dois motores sincronizados: disco e esteira'),
          'ctrl': tem('Sim'),
          'sensor': tem('Na esteira'),
          'onde': tem('Retrofit'),
        },
      ),
      ProdutoTecnico(
        marca: 'TOPlanting',
        nome: 'TOP V + V Control',
        situacao: 'No mercado',
        valores: {
          'mec': info('Dosador a vácuo com condutor de esteira'),
          'vel': info('12 km/h no estudo da UFRGS'),
          'acion': ni(),
          'ctrl': ni(),
          'sensor': ni(),
          'onde': info('Reposição em revendas'),
        },
      ),
      ProdutoTecnico(
        marca: 'John Deere',
        nome: 'ExactEmerge',
        situacao: 'No mercado',
        valores: {
          'mec': info('Esteira de escovas (BrushBelt)'),
          'vel': tem('Até 16 km/h'),
          'acion': tem('Elétrico'),
          'ctrl': tem('Sim'),
          'sensor': ni(),
          'onde': info('De fábrica na linha DB'),
        },
      ),
    ],
    fontes: [
      Fonte(
        'Revista Cultivar – Selenium Neo',
        'https://revistacultivar.com.br/noticias/j-assy-apresentou-na-agrishow-2024-o-dosador-de-sementes-selenium-neo',
      ),
      Fonte(
        'UFRGS – estudo do V Control',
        'https://lume.ufrgs.br/handle/10183/285264',
      ),
      Fonte(
        'John Deere – ExactEmerge',
        'https://JohnDeere.com/en/technology-products/precision-ag-technology/precision-upgrades/planter-upgrades/exactemerge-upgrade/',
      ),
    ],
  ),

  LinhaProduto(
    id: 'adubo',
    nome: 'Dosadores de adubo',
    jassy: 'Júpiter',
    tese:
        'Dose certa em qualquer terreno: rotor volumétrico que não depende do '
        'nível do depósito nem da rampa.',
    apoio:
        'As pesquisas mostram que a rosca sem-fim muda a dose com o nível de '
        'adubo e com a inclinação. O Júpiter dosa por volume.',
    numero: '100–600',
    numeroTexto:
        'kg/ha de faixa de dose do Júpiter, com encaixe sem '
        'ferramentas',
    numeroFonte: 'J.Assy',
    ganhamos: [
      'Volumétrico, rotor e calha: menor variação entre linhas (fabricante).',
      'Desempenho em aclive e declive.',
      'Encaixe rápido sem ferramentas; quebra torrões de adubo.',
      'Prêmio iF Design 2023.',
    ],
    concorrentes: [
      Concorrente(
        id: 'ferti',
        nome: 'Fertisystem',
        produto: 'Rosca helicoidal por transbordo',
        ataca: [
          'Um dos dosadores mais usados; mais homogêneo que o caracol '
              'tradicional.',
        ],
        objecoes: [
          Objecao(
            'Já uso Fertisystem.',
            'Na UFMT (2022) o FertSystem teve a maior variação com adubo de '
                'grão fino (04-20-20). Pergunte que adubo ele usa.',
          ),
        ],
      ),
      Concorrente(
        id: 'duplo',
        nome: 'TOPlanting Duplo Sem Fim',
        produto: 'Dois rotores helicoidais',
        ataca: [
          'Preço de entrada baixo.',
          'Estudo da UnB: menor CV em nível e em 15° de rampa.',
          'Fabricante diz variação de até 3%.',
        ],
        objecoes: [
          Objecao(
            'O duplo sem-fim tem estudo bom em rampa.',
            'É verdade na UnB. Na UPF (2020), porém, o duplo sem-fim teve CV '
                'de 7,7% na linha e 8,2% na inclinação, atrás do rotor dentado '
                '(6,1%) e do sem-fim de descarga lateral (4,4%).',
          ),
        ],
      ),
    ],
    objecoesComuns: [
      Objecao(
        'Dosador de adubo é tudo igual.',
        'Não é: a rosca muda a dose com o nível do depósito e com a rampa. '
            'Meça a dose por linha na máquina dele.',
      ),
    ],
    provas: [
      Prova(
        'UNISC 2006 e Tecno-Lógica 2007',
        TipoProva.sustenta,
        'Na rosca por transbordo, quanto mais adubo no depósito, maior a '
            'dose; e toda inclinação muda a dosagem.',
        'A dose varia ao longo do dia conforme o depósito esvazia.',
      ),
      Prova(
        'UFMT 2022',
        TipoProva.contraConcorrente,
        'O FertSystem teve a maior variação com 04-20-20 (grão fino).',
        'Contra o Fertisystem, para quem usa formulado fino.',
      ),
      Prova(
        'UPF 2020',
        TipoProva.contexto,
        'CV na linha: rotor dentado 6,1%, duplo sem-fim 7,7%, transbordo '
            '9,4%, sem-fim lateral 13,3%. Na inclinação, o sem-fim lateral '
            'foi o melhor (4,4%).',
        'O tipo de mecanismo muda o resultado; nenhum é bom em tudo.',
      ),
      Prova(
        'IFRS 2019',
        TipoProva.contexto,
        'O dosador de rosca helicoidal dupla teve CV médio de 36% na '
            'distribuição, sem mudar com a inclinação.',
        'Dado de outra bancada para o duplo sem-fim; use com cuidado.',
      ),
    ],
    cuidado:
        'O Júpiter não aparece em nenhum estudo da base; os argumentos são '
        'pelo tipo de mecanismo. Rotor dentado não é o mesmo que rotor e '
        'calha.',
    perguntas: [
      'Que adubo usa (formulado, grão fino ou grosso)?',
      'Qual a dose por hectare?',
      'Planta em rampa?',
      'Já viu diferença de dose entre o começo e o fim do depósito?',
    ],
    provasApp: [
      ProvaApp(
        'Avaliação de fertilizante',
        'Meça a dose por linha na máquina do cliente.',
      ),
      ProvaApp('ROI', 'Mostre o custo do adubo aplicado a mais ou a menos.'),
      ProvaApp('Configurador', 'Inclua o Júpiter na proposta.'),
    ],
    criterios: [
      ('mec', 'Mecanismo'),
      ('dose', 'Faixa de dose'),
      ('incl', 'Aclive e declive'),
      ('manut', 'Montagem e manutenção'),
      ('desemp', 'Desempenho divulgado'),
    ],
    produtos: [
      ProdutoTecnico(
        marca: 'J.Assy',
        nome: 'Júpiter',
        jassy: true,
        situacao: 'No mercado',
        valores: {
          'mec': info('Volumétrico, rotor e calha; quebra torrões'),
          'dose': info('100 a 600 kg/ha, conforme a máquina'),
          'incl': tem('Alto desempenho em aclive e declive'),
          'manut': tem('Encaixe rápido, sem ferramentas'),
          'desemp': info(
            'Menor variação entre linhas (fabricante); iF Design '
            '2023',
          ),
        },
      ),
      ProdutoTecnico(
        marca: 'Fertisystem',
        nome: 'Rosca helicoidal',
        situacao: 'No mercado',
        valores: {
          'mec': info('Rosca helicoidal por transbordo'),
          'dose': ni(),
          'incl': ni(),
          'manut': ni(),
          'desemp': info(
            'Mais homogêneo que o caracol (IFRS); maior variação '
            'com 04-20-20 (UFMT)',
          ),
        },
      ),
      ProdutoTecnico(
        marca: 'TOPlanting',
        nome: 'Duplo Sem Fim',
        situacao: 'No mercado',
        valores: {
          'mec': info('Dois rotores helicoidais em sentidos opostos'),
          'dose': ni(),
          'incl': tem('Menor CV em nível e em 15° (UnB, 2022)'),
          'manut': ni(),
          'desemp': info('Variação de até 3% (fabricante)'),
        },
      ),
    ],
    fontes: [
      Fonte('J.Assy – Júpiter', 'https://jassy.ag/en/jupiter/'),
      Fonte(
        'Revista Cultivar – dosador duplo de Cruz Alta',
        'https://www.revistacultivar.com.br/noticias/dosador-de-adubo-e-produzido-por-produtor-de-cruz-alta-rs',
      ),
    ],
  ),

  LinhaProduto(
    id: 'pressao',
    nome: 'Controle de pressão',
    jassy: 'Level',
    tese:
        'Profundidade uniforme linha a linha, pensada para o solo brasileiro, '
        'na tela ISOBUS do trator.',
    apoio:
        'Emergência desigual custa produtividade. O Level ajusta a pressão de '
        'cada linha sem exigir monitor próprio.',
    numero: '100%',
    numeroTexto: 'ISOBUS e wireless: usa a tela do trator',
    numeroFonte: 'J.Assy',
    ganhamos: [
      'Pressão diferente em cada linha, conforme o solo.',
      'ISOBUS: dispensa o monitor 20|20 que o DeltaForce usa.',
      'Comunicação wireless; menos trepidação da linha.',
    ],
    concorrentes: [
      Concorrente(
        id: 'delta',
        nome: 'Precision Planting DeltaForce',
        produto: 'Cilindros hidráulicos com células de carga',
        ataca: [
          'Mede o peso na roda limitadora 200 vezes por segundo.',
          'Estudos próprios de downforce (PTI Farm).',
          'Mapas de downforce no monitor 20|20.',
        ],
        objecoes: [
          Objecao(
            'O DeltaForce tem estudos de produtividade.',
            'São estudos do próprio fabricante, nos EUA. Proponha a Avaliação '
                'de emergência na fazenda, com e sem Level.',
          ),
          Objecao(
            'Preciso do monitor 20|20?',
            'Com o Level, não: ele roda na tela ISOBUS do trator.',
          ),
        ],
      ),
    ],
    objecoesComuns: [
      Objecao(
        'Molas resolvem.',
        'Molas aplicam a mesma força em todas as linhas e não reagem à mudança '
            'do solo. Mostre a emergência desigual na Avaliação de '
            'emergência.',
      ),
    ],
    provas: [
      Prova(
        'EUA 2026',
        TipoProva.cuidado,
        'No amendoim, a pressão da linha teve efeito pequeno e inconsistente '
            'no estande; velocidade e vácuo pesaram mais.',
        'Não usar como prova do Level; serve para não exagerar promessas.',
      ),
    ],
    cuidado:
        'Nenhum estudo da base avalia o Level ou o DeltaForce. A prova mais '
        'forte é medir a emergência na fazenda do cliente.',
    perguntas: [
      'O solo varia muito dentro do talhão?',
      'Usa molas ou bolsas de ar hoje?',
      'Vê emergência desigual entre linhas?',
      'O trator tem monitor ISOBUS?',
    ],
    provasApp: [
      ProvaApp('Avaliação de emergência', 'Meça a emergência com e sem Level.'),
      ProvaApp('ROI', 'Mostre o custo da emergência desigual.'),
      ProvaApp('Configurador', 'Inclua o Level na proposta.'),
    ],
    criterios: [
      ('atuador', 'Atuador'),
      ('sensor', 'Medição'),
      ('ctrl', 'Controle'),
      ('tela', 'Monitor / ISOBUS'),
      ('com', 'Comunicação'),
      ('desemp', 'Resultado divulgado'),
    ],
    produtos: [
      ProdutoTecnico(
        marca: 'J.Assy',
        nome: 'Level',
        jassy: true,
        situacao: 'No mercado',
        valores: {
          'atuador': info('Hidráulico'),
          'sensor': info('Índice de flutuação da linha'),
          'ctrl': tem('Pressão diferente em cada linha'),
          'tela': tem('100% ISOBUS'),
          'com': tem('Wireless'),
          'desemp': info('Profundidade e emergência uniformes (fabricante)'),
        },
      ),
      ProdutoTecnico(
        marca: 'Precision Planting',
        nome: 'DeltaForce',
        situacao: 'No mercado',
        valores: {
          'atuador': info('Cilindros hidráulicos no lugar de molas ou bolsas'),
          'sensor': tem('Células de carga, 200 vezes por segundo'),
          'ctrl': tem('Mantém o peso-alvo em cada linha'),
          'tela': info('Monitor 20|20, com mapas de downforce'),
          'com': ni(),
          'desemp': info('Estudos do próprio fabricante (PTI Farm)'),
        },
      ),
    ],
    fontes: [
      Fonte('J.Assy – Level', 'https://jassy.ag/en/level/'),
      Fonte(
        'Precision Planting – DeltaForce',
        'https://www.precisionplanting.com/deltaforce',
      ),
    ],
  ),
];

/// Concorrente pelo id, em qualquer linha.
({LinhaProduto linha, Concorrente concorrente})? concorrentePorId(String id) {
  for (final l in linhasProduto) {
    for (final c in l.concorrentes) {
      if (c.id == id) return (linha: l, concorrente: c);
    }
  }
  return null;
}
