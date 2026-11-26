import 'package:flutter/material.dart';

import '../conceito/conceitos.dart';
import '../simulador/alarmes.dart';

/// Tela do app que a aula indica para praticar.
enum Atalho {
  simulador('Praticar no Simulador Elétric', Icons.touch_app_outlined),
  alarmes('Ver a lista de alarmes', Icons.notifications_active_outlined),
  monitores('Ver os monitores compatíveis', Icons.tv_outlined);

  final String rotulo;
  final IconData icone;

  const Atalho(this.rotulo, this.icone);
}

class Aula {
  final String titulo;
  final List<Bloco> blocos;
  final Atalho? atalho;

  const Aula({required this.titulo, required this.blocos, this.atalho});
}

/// Pergunta de múltipla escolha do teste de cada módulo.
class Pergunta {
  final String enunciado;
  final List<String> opcoes;

  /// Índice da opção certa em [opcoes].
  final int correta;

  /// Mostrada depois da resposta, certa ou errada.
  final String explicacao;

  const Pergunta({
    required this.enunciado,
    required this.opcoes,
    required this.correta,
    required this.explicacao,
  });
}

class ModuloTreino {
  final String titulo;
  final String resumo;
  final IconData icone;
  final List<Aula> aulas;
  final List<Pergunta> perguntas;

  const ModuloTreino({
    required this.titulo,
    required this.resumo,
    required this.icone,
    required this.aulas,
    required this.perguntas,
  });
}

const _img = 'assets/treinamento';

/// Linhas da tabela de alarmes da aula "Alarmes mais comuns", tiradas do
/// mesmo catálogo do simulador (texto do manual e solução do treinamento).
List<List<String>> _linhasAlarmes(List<TipoAlarme> tipos) => [
  for (final t in tipos)
    [(t.porLinha ? 'Linha XX - ' : '') + t.texto, t.solucao ?? t.descricao],
];

/// Treinamento da Linha Elétric para vendedores e mecânicos da revenda.
/// Fontes: apresentações "Treinamento Linha Elétric" e manuais do Selenium e
/// do Titanium Elétric (pasta CONFIGURADOR/manuais). Ver
/// docs/revenda/treinamento.md.
final List<ModuloTreino> modulosTreino = [
  const ModuloTreino(
    titulo: 'Componentes do sistema',
    resumo: 'Por que a Linha Elétric, ECU, drivers e alternador',
    icone: Icons.memory_outlined,
    aulas: [
      Aula(
        titulo: 'Por que a Linha Elétric',
        blocos: [
          Paragrafo(
            'Na Linha Elétric, o disco dosador de cada linha gira com um motor '
            'elétrico próprio, comandado pela ECU J.Assy pelo monitor ISOBUS '
            'do trator. Sai a transmissão mecânica, o câmbio e os cabos de '
            'segundo monitor.',
          ),
          Lista([
            'Selenium Elétric: para o dosador Selenium.',
            'Titanium Elétric: para plantadeiras mecânicas com o dosador '
                'Titanium.',
          ]),
          Subtitulo('O que o produtor ganha'),
          Lista([
            '100% ISOBUS: funciona com os monitores ISO do mercado, sem '
                'segundo monitor na cabine.',
            'Até 62 linhas, em plantadeiras tandem ou articuladas.',
            'Comunicação sem fio: menos cabos e módulos, menos máquina parada '
                'por problema de cabeamento.',
            'Taxa variável: a semente certa para cada parte do talhão, com '
                'economia de semente.',
            'Desligamento linha a linha: menos sobreposição nas bordaduras e '
                'nas pontas, menos acamamento e economia de semente.',
            'Sensor de semente integrado: sem/m ou plantas/ha, singulação, '
                'falhas, duplos, CV e distribuição, linha por linha.',
          ]),
          Paragrafo(
            'Os problemas que ela resolve: população final fora do alvo, '
            'transmissão sem eficiência, câmbio regulado errado, tempo de '
            'regulagem e custo de manutenção.',
          ),
        ],
      ),
      Aula(
        titulo: 'As peças do sistema',
        blocos: [
          Lista([
            'ECU J.Assy: o cérebro do sistema, controla o implemento.',
            'Driver e motor de cada linha: giram o disco dosador.',
            'Sensor de sementes (Dickey-John): conta as sementes no condutor.',
            'Sensor de levante: diz se a plantadeira está plantando ou em '
                'manobra.',
            'Alternador hidráulico: gera a energia dos motores.',
            'Antenas: RF (comunicação com as linhas) e GPS.',
            'Monitor ISOBUS do trator: mostra o terminal virtual da J.Assy.',
          ]),
          Subtitulo('Motor do dosador'),
          Tabela(
            ['', 'Valor'],
            [
              ['Tensão', '24 V'],
              ['Corrente', '1,6 A'],
              ['Potência', 'até 72 W'],
              ['Rotação', '100 RPM ou 45 RPM, conforme o kit'],
            ],
          ),
          Paragrafo(
            'A caixa do driver tem três conectores: alimentação 24 V (cabo de '
            '1 ou 4 vias), controle do motor e sensor de semente.',
          ),
        ],
      ),
      Aula(
        titulo: 'ECU J.Assy',
        blocos: [
          Imagem('$_img/ecu.jpg'),
          Subtitulo('O que a ECU faz'),
          Lista([
            'Controla o implemento: taxa e liga/desliga de cada linha.',
            'Interpreta mapas de prescrição (taxa variável).',
            'Sabe onde está, pela posição do GPS.',
            'Entende a geometria do implemento e do trator.',
            'Cria e envia ao monitor o terminal virtual e a geometria do '
                'implemento.',
          ]),
          Paragrafo(
            'Exemplo: com a taxa variável ativada, o monitor manda a taxa do '
            'mapa (por exemplo, 15 sem/m) e a ECU repassa para as linhas. No '
            'corte de seção, o monitor pede para desligar a linha 1, depois a '
            'linha 2, e a ECU desliga cada uma.',
          ),
          Subtitulo('Conectores e chicote'),
          Lista([
            'Antena RF (2,4 GHz) e antena de GPS, cada uma no seu conector.',
            'Chicote principal: sensores de levante 1 e 2, radar, alternador, '
                'programação e os conectores ISOBUS.',
          ]),
          Nota(
            'A ECU também tem um LED que mostra se a máquina está parada ou '
            'em manobra, ou plantando. Por isso ela vai num lugar onde o '
            'operador consiga ver.',
          ),
        ],
      ),
      Aula(
        titulo: 'LED dos drivers',
        blocos: [
          Imagem(
            '$_img/led_driver_verde.jpg',
            legenda: 'LED verde: driver comunicando com a ECU',
          ),
          Tabela(
            ['LED do driver', 'Significa'],
            [
              ['Verde piscando devagar', 'Comunicando, motor parado'],
              ['Verde piscando rápido', 'Comunicando, motor girando'],
              ['Vermelho piscando devagar', 'Sem comunicação com a ECU'],
              ['Branco piscando', 'Em endereçamento'],
              ['Vermelho, verde e azul', 'Inicialização'],
              ['Apagado', 'Sem energia'],
            ],
          ),
          Imagem(
            '$_img/led_driver_vermelho.jpg',
            legenda: 'LED vermelho: sem comunicação',
          ),
          Paragrafo(
            'LED vermelho com o sistema ligado aparece junto com o alarme '
            '"Linha XX - Falha na Comunicação". Confira os cabos e a antena de '
            'comunicação. LED apagado: confira o cabo de alimentação e o '
            'alternador.',
          ),
        ],
      ),
      Aula(
        titulo: 'Alternador hidráulico',
        blocos: [
          Imagem('$_img/alternador_hidraulico.jpg'),
          Paragrafo(
            'O alternador usa o óleo do trator para gerar a energia dos '
            'motores e atende até 62 linhas. Dentro dele há duas baterias em '
            'série (24 V), que saem desligadas de fábrica e são ligadas na '
            'montagem.',
          ),
          Tabela(
            ['Linhas', 'Mínimo', 'Ideal', 'L/min'],
            [
              ['até 20', '2.000', '3.000', '14,1'],
              ['25', '2.500', '3.000', '17,7'],
              ['30', '3.000', '3.500', '21,2'],
              ['40', '4.000', '4.500', '28,3'],
              ['50', '5.000', '5.500', '35,4'],
              ['60', '6.000', '6.500', '42,4'],
            ],
          ),
          Lista([
            'Rotação mínima = nº de linhas × 100 RPM; a ideal (recomendada) '
                'fica 500 RPM acima. L/min é o óleo que o trator fornece.',
            'No mínimo 3.000 RPM, mesmo em máquinas com menos de 25 linhas.',
            'Máximo de 6.500 RPM. Mais rotação, mais óleo do trator.',
          ]),
          Paragrafo(
            'A faixa aceita fica em Configurações > Energia. Fora dela aparecem '
            'os alarmes de baixa ou de alta rotação.',
          ),
        ],
      ),
    ],
    perguntas: [
      Pergunta(
        enunciado: 'O LED do driver está verde, piscando rápido. O que indica?',
        opcoes: [
          'Comunicando, motor parado',
          'Comunicando, motor girando',
          'Sem comunicação com a ECU',
          'Em endereçamento',
        ],
        correta: 1,
        explicacao:
            'Verde rápido: motor girando. Verde devagar: motor parado. Branco: '
            'endereçamento.',
      ),
      Pergunta(
        enunciado:
            'Qual a rotação mínima recomendada do alternador hidráulico?',
        opcoes: ['1.500 RPM', '2.500 RPM', '3.000 RPM', '6.500 RPM'],
        correta: 2,
        explicacao:
            'No mínimo 3.000 RPM, mesmo em máquinas com menos de 25 linhas.',
      ),
      Pergunta(
        enunciado:
            'Uma plantadeira de 40 linhas deve trabalhar com o alternador em '
            'qual rotação?',
        opcoes: ['3.000 RPM', '4.000 RPM', '4.500 RPM', '6.500 RPM'],
        correta: 2,
        explicacao:
            'O mínimo é 40 × 100 = 4.000 RPM; o recomendado é 4.500 RPM.',
      ),
      Pergunta(
        enunciado: 'Qual argumento é da Linha Elétric?',
        opcoes: [
          'Precisa de um segundo monitor na cabine',
          'Funciona com os monitores ISOBUS, sem segundo monitor',
          'Só atende plantadeiras de até 20 linhas',
          'Depende do câmbio da plantadeira',
        ],
        correta: 1,
        explicacao:
            '100% ISOBUS, até 62 linhas, sem câmbio e com comunicação sem fio.',
      ),
    ],
  ),
  const ModuloTreino(
    titulo: 'Instalação',
    resumo: 'ECU, antenas, energia, alternador e sensor de levante',
    icone: Icons.build_outlined,
    aulas: [
      Aula(
        titulo: 'ECU e antenas',
        blocos: [
          Subtitulo('ECU'),
          Lista([
            'No centro da máquina, onde o operador veja o LED.',
            'Conectores virados para baixo, para não acumular água.',
            'Ligada ao cabo ISOBUS, que vai na tomada ISO do trator.',
          ]),
          Subtitulo('Antena de comunicação (RF)'),
          Lista([
            'No centro da máquina, com a peça de fixação do kit (pode ficar '
                'virada para baixo).',
            'De preferência acima das linhas e das caixas de semente.',
            'Longe de barreiras de metal. O operador não precisa ver a '
                'antena.',
            'Acima de 29 linhas, use 2 antenas (o kit da ECU já traz as '
                'peças).',
          ]),
          Subtitulo('Antena de GPS'),
          Lista([
            'Sem nada que bloqueie o céu. O ímã da base prende em superfície '
                'de metal.',
            'Com a logo da ECU para cima: à esquerda a antena RF, à direita o '
                'GPS. Antena no conector errado tira precisão do sistema.',
          ]),
        ],
      ),
      Aula(
        titulo: 'Energia das linhas',
        blocos: [
          Paragrafo(
            'O alternador tem ramos de alimentação 24 V. Os chicotes de '
            'extensão (1, 4, 9 ou 14 m) saem do painel do alternador e ligam '
            'nos cabos de linha de 1 ou 4 vias.',
          ),
          Formula('Cada ramo de 24 V alimenta no máximo 10 linhas'),
          Nota(
            'Passar de 10 linhas por ramo pode danificar os chicotes. Confira '
            'antes de fechar a montagem.',
          ),
        ],
      ),
      Aula(
        titulo: 'Ligar e desligar o alternador',
        blocos: [
          Subtitulo('Conectar no trator'),
          Lista([
            'Veja se o trator tem retorno de baixa pressão instalado.',
            'Conecte nesta ordem: 1º dreno, 2º retorno, 3º pressão. Para '
                'desconectar, a ordem inversa.',
            'A pressão vai no engate (VCR) com o símbolo de "retração".',
            'O motor hidráulico só gira num sentido: ligado ao contrário, o '
                'alternador não liga.',
          ]),
          Subtitulo('Ligar'),
          Lista([
            '1. Gire a chave do trator e ligue o monitor ISOBUS.',
            '2. A luz vermelha do sinaleiro acende rápido.',
            '3. Com a vazão da VCR no zero, acione a posição de retração.',
            '4. Abra a vazão aos poucos até a rotação recomendada, olhando o '
                'RPM no terminal J.Assy.',
            '5. Confira se os dosadores giram (LED e terminal).',
          ]),
          Subtitulo('Desligar'),
          Paragrafo(
            'Se o retorno está na VCR, use a posição "flutuante" e, com o '
            'alternador parado, volte para o neutro. No fim do dia, com o '
            'trator parado, desligue a chave: o sinaleiro deve ficar apagado, '
            'sinal de que as baterias não estão sendo consumidas.',
          ),
        ],
      ),
      Aula(
        titulo: 'Sensor de levante',
        blocos: [
          Imagem('$_img/sensor_levante.jpg'),
          Paragrafo(
            'O sensor de levante (indutivo) deve ficar acionado com a máquina '
            'plantando e desacionado com ela erguida. Em manobra, os '
            'dosadores param.',
          ),
          Lista([
            'Use a peça de fixação do kit.',
            'Solo compactado do galpão reduz o curso: confira se o ponto de '
                'acionamento deixa erguer um pouco a máquina.',
            'Erga e abaixe a máquina algumas vezes para testar.',
            'Podem ser instalados até 2 sensores.',
            'Se trabalhar ao contrário, inverta a lógica em Configurações > '
                'Sensor de Levante.',
            'Se o sensor estragar no campo, habilite o levante manual: aparece '
                'a tecla Plantar/Manobra.',
          ]),
        ],
      ),
      Aula(
        titulo: 'O que não vem no kit',
        blocos: [
          Lista([
            'Monitor ISOBUS.',
            'Liberação do Controlador de Tarefas no monitor (para taxa '
                'variável).',
            'Liberação do Controle de Seção no monitor (para o corte linha a '
                'linha).',
            'Cabo ISOBUS e terminador ISOBUS.',
          ]),
          Nota(
            'Sem terminador ISOBUS no cabeamento do implemento, o sistema não '
            'funciona direito. Se não achar, compre um novo.',
          ),
        ],
        atalho: Atalho.monitores,
      ),
    ],
    perguntas: [
      Pergunta(
        enunciado: 'Em que ordem conectar as mangueiras do alternador?',
        opcoes: [
          'Dreno, retorno e pressão',
          'Pressão, retorno e dreno',
          'Retorno, pressão e dreno',
          'Tanto faz',
        ],
        correta: 0,
        explicacao:
            '1º dreno, 2º retorno, 3º pressão; para desconectar, o inverso.',
      ),
      Pergunta(
        enunciado: 'Quantas linhas cada ramo de 24 V do alternador alimenta?',
        opcoes: ['Até 4', 'Até 10', 'Até 20', 'Até 62'],
        correta: 1,
        explicacao:
            'No máximo 10 linhas por ramo, para não danificar o chicote.',
      ),
      Pergunta(
        enunciado:
            'Uma plantadeira de 36 linhas precisa de quantas antenas RF?',
        opcoes: ['Nenhuma', '1', '2', '1 por linha'],
        correta: 2,
        explicacao: 'Acima de 29 linhas, o indicado são 2 antenas RF.',
      ),
      Pergunta(
        enunciado: 'Como instalar a ECU?',
        opcoes: [
          'No centro da máquina, com os conectores para baixo',
          'Na cabine, ao lado do monitor',
          'Na ponta da barra, com os conectores para cima',
          'Dentro da caixa de semente',
        ],
        correta: 0,
        explicacao:
            'No centro, à vista do operador, e conectores para baixo para não '
            'acumular água.',
      ),
    ],
  ),
  const ModuloTreino(
    titulo: 'Tela de trabalho',
    resumo: 'O que o operador vê no monitor durante o plantio',
    icone: Icons.dashboard_outlined,
    aulas: [
      Aula(
        titulo: 'As partes da tela',
        blocos: [
          Paragrafo(
            'A tela de trabalho é o terminal virtual da J.Assy no monitor '
            'ISOBUS do trator. Ela mostra o plantio em tempo real, linha por '
            'linha.',
          ),
          Lista([
            'Barra de ícones: área trabalhada e os ícones de estado.',
            'Barra de mensagens: Plantando ou Manobra, e os alarmes ativos.',
            'Boxes: taxa média de sementes, singulação (com falhas e duplos) '
                'e CV.',
            'Gráficos: uma barra por linha, para achar a linha com problema.',
            'Botões virtuais: teclas do lado direito da tela.',
          ]),
        ],
      ),
      Aula(
        titulo: 'Barra de ícones e de mensagens',
        blocos: [
          Tabela(
            ['Ícone', 'O que mostra'],
            [
              ['Nº de furos no disco', 'O disco configurado na Dosagem'],
              ['Estado da máquina', 'Plantando ou Manobra'],
              ['Corte de seção', 'Ativado pelo monitor ISOBUS'],
              ['Taxa variável', 'Ativada pelo monitor ISOBUS (mapa)'],
              ['Sensor de levante', 'Estado do sensor'],
            ],
          ),
          Paragrafo(
            'A barra de mensagens fica verde plantando e amarela em manobra. '
            'Quando há alarme, ele aparece ali em vermelho, com o número de '
            'alarmes ativos ao lado.',
          ),
        ],
      ),
      Aula(
        titulo: 'Boxes e gráficos',
        blocos: [
          Lista([
            'Taxa: média de sementes por metro das linhas que estão '
                'plantando, com a taxa alvo embaixo.',
            'Singulação: % de sementes que caíram uma a uma. Embaixo, a '
                'média de falhas e de duplos.',
            'CV: coeficiente de variação dos espaçamentos. Quanto menor, '
                'mais regular.',
          ]),
          Paragrafo(
            'Os gráficos alternam entre Taxa, Singulação, CV, População e '
            'Distribuição: toque no título para trocar. As linhas tracejadas '
            'são os limites de alarme. Tocar numa barra abre os dados daquela '
            'linha.',
          ),
        ],
      ),
      Aula(
        titulo: 'Botões virtuais',
        blocos: [
          Lista([
            'Fonte de velocidade: de onde vem a velocidade usada para dosar.',
            'Fonte de energia: rotação do alternador ou tensão da bateria.',
            'Levante manual: Plantar/Manobra, só se estiver habilitado.',
            'Tela principal: volta para a tela de trabalho.',
            'Configurações: as oito telas de ajuste do sistema.',
          ]),
          Paragrafo(
            'No simulador dá para tocar em cada parte da tela e ver a '
            'explicação.',
          ),
        ],
        atalho: Atalho.simulador,
      ),
    ],
    perguntas: [
      Pergunta(
        enunciado: 'Onde aparece o alarme ativo na tela de trabalho?',
        opcoes: [
          'Na barra de mensagens',
          'No gráfico de taxa',
          'Nos botões virtuais',
          'No rodapé',
        ],
        correta: 0,
        explicacao:
            'A barra de mensagens mostra Plantando/Manobra e os alarmes, em '
            'vermelho.',
      ),
      Pergunta(
        enunciado: 'O que é singulação?',
        opcoes: [
          'A % de sementes que caíram uma a uma',
          'A taxa média em sementes por metro',
          'A variação da velocidade do trator',
          'A % de linhas ligadas',
        ],
        correta: 0,
        explicacao:
            'Singulação é a porcentagem de sementes individualizadas; falhas '
            'e duplos ficam embaixo.',
      ),
      Pergunta(
        enunciado: 'A tecla Plantar/Manobra só aparece quando…',
        opcoes: [
          'o levante manual está habilitado',
          'o GPS perde o sinal',
          'a taxa variável está ativa',
          'há um alarme ativo',
        ],
        correta: 0,
        explicacao: 'Ela é habilitada em Configurações > Sensor de Levante.',
      ),
      Pergunta(
        enunciado: 'CV alto na tela indica…',
        opcoes: [
          'espaçamento irregular entre as sementes',
          'população acima da taxa alvo',
          'velocidade de plantio alta',
          'bateria fraca',
        ],
        correta: 0,
        explicacao:
            'O CV mede a variação dos espaçamentos: quanto maior, mais '
            'irregular.',
      ),
    ],
  ),
  const ModuloTreino(
    titulo: 'Configurações',
    resumo: 'As oito telas de ajuste e o endereçamento das linhas',
    icone: Icons.tune,
    aulas: [
      Aula(
        titulo: 'Dosagem e sensoriamento',
        blocos: [
          Paragrafo(
            'Aqui ficam o número de furos do disco e os limites dos alarmes '
            'de qualidade.',
          ),
          Tabela(
            ['Parâmetro', 'Alarme que dispara'],
            [
              ['Máximo de Falhas (%)', 'Linha XX - Excesso de Falhas'],
              ['Máximo de Duplos (%)', 'Linha XX - Excesso de Duplos'],
              ['População Máxima (%)', 'Alta Taxa de Sementes'],
              ['População Mínima (%)', 'Baixa Taxa de Sementes'],
              [
                'Distribuição Mínima (%)',
                'Linha XX - Distribuição Sementes Ruim',
              ],
              ['CV Máximo (%)', 'CV Elevado'],
              [
                'Tempo de Fim de Semente (s)',
                'Linha XX - Fim de Sementes ou Entupimento',
              ],
            ],
          ),
          Lista([
            'Distância de Medidas: de quantos em quantos metros a tela '
                'atualiza a qualidade.',
            'Ajuste de População: corrige a leitura do sensor para mostrar a '
                'população real no solo. Acima de 1, acende o alarme Ganho de '
                'População Ativo.',
          ]),
          Nota(
            'Singulação Crítica, Porcentagem de Sujeira e os limiares de '
            'duplos e falhas são da engenharia J.Assy e ficam travados por '
            'senha.',
          ),
        ],
      ),
      Aula(
        titulo: 'Implemento',
        blocos: [
          Paragrafo(
            'Número de linhas, distância entre elas e a geometria da '
            'plantadeira. Com essas medidas, o corte de seção liga e desliga '
            'cada linha no ponto certo.',
          ),
          Tabela(
            ['Tipo de linhas', 'O que informar'],
            [
              [
                'Encontradas',
                'Linhas, distância entre elas, engate-roda e roda-saída',
              ],
              [
                'Desencontradas',
                'O mesmo, com roda-saída curta e longa, e se a primeira linha '
                    'é a 1 ou a 2',
              ],
              [
                'Personalizadas',
                'Onde fica cada linha (curta ou longa) e quantas são de cada',
              ],
            ],
          ),
          Nota(
            'Meça na máquina, não no catálogo. Medida errada faz a linha '
            'ligar ou desligar fora do ponto na cabeceira.',
          ),
        ],
      ),
      Aula(
        titulo: 'Velocidade: fonte e filtro',
        blocos: [
          Subtitulo('Fonte de velocidade'),
          Lista([
            'GPS ISOBUS: velocidade do monitor ou do trator.',
            'GPS ECU: antena ligada na ECU J.Assy, com o DOP máximo aceito.',
            'Manual: velocidade digitada. Serve para seguir plantando se o GPS '
                'parar.',
            'Radar: com a constante de ajuste.',
          ]),
          Subtitulo('Filtro de velocidade'),
          Paragrafo(
            'Evita que os dosadores partam ou parem com oscilações de '
            'velocidade. Eles só partem acima da Velocidade de Partida, '
            'depois do Tempo de Partida, e só param abaixo da Velocidade de '
            'Parada, depois do Tempo de Parada.',
          ),
        ],
      ),
      Aula(
        titulo: 'Endereçamento das linhas',
        blocos: [
          Paragrafo(
            'O endereçamento liga cada dosador ao número da sua linha. Faça '
            'na instalação e sempre que trocar um driver.',
          ),
          Lista([
            '1. Em Configurações > Endereçamento, escolha a linha.',
            '2. Toque em Ler.',
            '3. Encoste o ímã no módulo do dosador daquela linha.',
            '4. Confira o endereço que aparece na tela.',
            '5. Toque em Gravar e passe para a próxima linha.',
          ]),
          Nota(
            'Linha endereçada errada mostra os dados de uma linha no lugar '
            'de outra no gráfico.',
          ),
        ],
        atalho: Atalho.simulador,
      ),
      Aula(
        titulo: 'Energia, levante e sistema',
        blocos: [
          Lista([
            'Energia: bateria ou alternador hidráulico. Com alternador, '
                'rotação mínima e máxima (recomendado no mínimo 3000 RPM).',
            'Sensor de levante: sensores habilitados, lógica invertida, '
                'levante manual e se basta um sensor em manobra.',
            'Sistema: versão do software e ID da ECU, liberação da taxa '
                'variável no GS3 e máximo de seções do monitor.',
          ]),
        ],
        atalho: Atalho.simulador,
      ),
    ],
    perguntas: [
      Pergunta(
        enunciado: 'Para ligar cada dosador ao número da sua linha, usa-se…',
        opcoes: [
          'o endereçamento com o ímã',
          'o filtro de velocidade',
          'o ajuste de população',
          'o sensor de levante',
        ],
        correta: 0,
        explicacao:
            'Em Endereçamento: escolher a linha, Ler, encostar o ímã e '
            'Gravar.',
      ),
      Pergunta(
        enunciado:
            'O alarme "Linha XX - Excesso de Falhas" dispara acima de qual '
            'parâmetro?',
        opcoes: [
          'Máximo de Falhas',
          'CV Máximo',
          'Distribuição Mínima',
          'Singulação Crítica',
        ],
        correta: 0,
        explicacao: 'Máximo de Falhas (%), em Dosagem e Sensoriamento.',
      ),
      Pergunta(
        enunciado: 'Ajuste de População acima de 1 acende qual alarme?',
        opcoes: [
          'Ganho de População Ativo',
          'CV Elevado',
          'Alta Taxa de Sementes',
          'Nenhum',
        ],
        correta: 0,
        explicacao:
            'O alarme avisa que a leitura do sensor está sendo corrigida.',
      ),
      Pergunta(
        enunciado:
            'O corte de seção liga e desliga fora do ponto. O que conferir '
            'primeiro no terminal?',
        opcoes: [
          'As medidas em Implemento',
          'O número de furos do disco',
          'O Tempo de Fim de Semente',
          'A senha de engenharia',
        ],
        correta: 0,
        explicacao:
            'A geometria (engate, rodas e saídas das linhas) define onde '
            'cada linha liga e desliga.',
      ),
    ],
  ),
  ModuloTreino(
    titulo: 'Alarmes',
    resumo: 'Como ler um alarme e o primeiro passo para resolver',
    icone: Icons.notifications_active_outlined,
    aulas: [
      const Aula(
        titulo: 'Como ler um alarme',
        blocos: [
          Paragrafo(
            'O alarme aparece em vermelho na barra de mensagens, com o '
            'número de alarmes ativos ao lado. Quando o texto começa com '
            '"Linha XX", o problema é só naquela linha.',
          ),
          Subtitulo('De onde vem o alarme'),
          Lista([
            'Sensor de sementes: falhas, duplos, CV, entupimento e sujeira.',
            'Dosador: motor, comunicação e limites de rotação.',
            'Fonte de energia: alternador e bateria.',
            'ECU: velocidade, GPS e curvas.',
          ]),
          Paragrafo(
            'Os alarmes críticos (vermelhos) pedem ação na hora; os de '
            'atenção (amarelos) pedem conferência assim que possível.',
          ),
        ],
      ),
      Aula(
        titulo: 'Os alarmes mais comuns',
        blocos: [
          Tabela(
            const ['Alarme', 'Primeiro passo'],
            _linhasAlarmes(const [
              TipoAlarme.fimDeSementes,
              TipoAlarme.baixaSingulacao,
              TipoAlarme.excessoDuplos,
              TipoAlarme.excessoFalhas,
              TipoAlarme.impurezas,
              TipoAlarme.falhaComunicacao,
              TipoAlarme.velocidadeMaxima,
              TipoAlarme.baixaRotacaoAlternador,
              TipoAlarme.fonteVelocidadeAusente,
            ]),
          ),
          const Nota(
            'Soluções do manual do Selenium. A lista completa está no '
            'Simulador Elétric.',
          ),
        ],
        atalho: Atalho.alarmes,
      ),
      const Aula(
        titulo: 'Selenium ou Titanium: muda a causa',
        blocos: [
          Paragrafo(
            'Os alarmes são os mesmos nos dois dosadores, mas os de qualidade '
            'têm causas diferentes. No Selenium, olhe primeiro a pressão de '
            'ar; no Titanium, o grafite e o disco e anel.',
          ),
          Tabela(
            ['Alarme', 'Selenium Elétric', 'Titanium Elétric'],
            [
              [
                'Excesso de duplos',
                'Pressão de ar alta',
                'Grafite, disco e anel',
              ],
              [
                'Excesso de falhas',
                'Pressão de ar, dosador',
                'Grafite, disco e anel',
              ],
              [
                'Baixa singulação',
                'Pressão de ar, impurezas no disco',
                'Disco e anel',
              ],
            ],
          ),
          Subtitulo('No Titanium, sempre'),
          Lista([
            'Nunca plante sem grafite, nem troque por talco: ele lubrifica e '
                'distribui.',
            'Grafite é a última etapa, depois do tratamento da semente.',
            'Semente quebrada no visor: falta grafite ou disco e anel '
                'errados.',
            'Inoculante líquido ou tratamento oleoso na caixa prejudica a '
                'plantabilidade.',
            'Velocidade de plantio: a recomendada pelo fabricante da '
                'plantadeira.',
          ]),
        ],
      ),
    ],
    perguntas: const [
      Pergunta(
        enunciado:
            'Aparece "Linha 07 - Fim de Sementes ou Entupimento". O que '
            'conferir?',
        opcoes: [
          'O reservatório e o condutor da linha 7',
          'A rotação do alternador',
          'O sinal de GPS',
          'A senha de engenharia',
        ],
        correta: 0,
        explicacao:
            'O sensor da linha 7 parou de ver sementes: acabou a semente ou o '
            'condutor entupiu.',
      ),
      Pergunta(
        enunciado: 'Excesso de duplos na linha. Qual o primeiro passo?',
        opcoes: [
          'Verificar a pressão de ar e, se preciso, reduzir',
          'Trocar o motor do driver',
          'Aumentar a velocidade de plantio',
          'Desligar o alternador',
        ],
        correta: 0,
        explicacao:
            'Pressão de ar alta demais faz o disco pegar duas sementes.',
      ),
      Pergunta(
        enunciado: '"Linha XX - Vel. Máxima atingida" pede o quê?',
        opcoes: [
          'Reduzir a velocidade de plantio',
          'Aumentar a velocidade de plantio',
          'Limpar o condutor',
          'Endereçar a linha',
        ],
        correta: 0,
        explicacao:
            'O disco chegou na rotação máxima. Também aparece sem alternador '
            'ou com disco errado na linha.',
      ),
      Pergunta(
        enunciado:
            'Titanium Elétric com excesso de falhas e semente quebrada no '
            'visor. O que conferir?',
        opcoes: [
          'O grafite e o disco e anel',
          'A pressão de ar',
          'A antena de GPS',
          'O terminador ISOBUS',
        ],
        correta: 0,
        explicacao:
            'No Titanium não há pressão de ar: falta de grafite ou disco e '
            'anel errados causam falhas e semente quebrada.',
      ),
    ],
  ),
  const ModuloTreino(
    titulo: 'Monitores e corte de seção',
    resumo: 'Ativações nos monitores, sinal de GPS e regulagem',
    icone: Icons.tv_outlined,
    aulas: [
      Aula(
        titulo: 'Ativações necessárias no monitor',
        blocos: [
          Paragrafo(
            'Para desligar linha por linha, o monitor do trator precisa ter '
            'as ativações certas. Confira antes da instalação.',
          ),
          Tabela(
            ['Monitor', 'Ativação'],
            [
              ['John Deere GS3', 'Controle de seção'],
              ['John Deere GS4', 'Controle de seção'],
              ['Intelliview IV e Pro 700', 'Controlador de tarefas'],
              ['Intelliview 12 e Pro 1200', 'Controle de seção'],
              ['Raven', 'Controlador de tarefas e VRA (taxa variável)'],
              ['Ag Leader', 'Todas ativas'],
              ['Topcon', 'Todas ativas'],
              ['Trimble', 'ISOBUS, Task Controller e Multi-Product Control'],
              ['Hexagon (Ti7 e Ti10)', 'VT e TC ISOBUS'],
            ],
          ),
          Nota(
            'O número de seções e as versões testadas de cada monitor estão '
            'em Monitores compatíveis.',
          ),
        ],
        atalho: Atalho.monitores,
      ),
      Aula(
        titulo: 'Sinal de GPS',
        blocos: [
          Paragrafo(
            'O corte de seção depende da posição do GPS. Quanto melhor o '
            'sinal de correção, mais preciso o liga e desliga nas cabeceiras '
            'e nas pontas.',
          ),
          Tabela(
            ['Sinal', 'Precisão passe a passe', 'Convergência'],
            [
              ['SF1', '± 15 a 23 cm', 'menos de 10 min'],
              ['SF2', '± 5 cm', 'menos de 90 min'],
              ['SF3', '± 3 cm', 'menos de 30 min'],
              ['RTK', '± 2,5 cm', 'menos de 1 min'],
            ],
          ),
          Nota(
            'Exemplo com os sinais StarFire (GPS + GLONASS). Sem sinal na '
            'antena da ECU aparece o alarme GPS com Sinal Degradado.',
          ),
        ],
      ),
      Aula(
        titulo: 'Regulagem do liga e desliga',
        blocos: [
          Paragrafo(
            'Ao entrar numa área já plantada, o monitor desliga as linhas; ao '
            'sair, liga de novo. Se o tempo estiver errado, fica faixa sem '
            'semente ou com semente em dobro na cabeceira.',
          ),
          Tabela(
            ['No campo', 'Regulagem e resultado'],
            [
              ['Desligou antes da área plantada', 'Adiantada: falha'],
              ['Desligou depois', 'Atrasada: semente em dobro'],
              [
                'Ligou antes de sair da área plantada',
                'Adiantada: semente em dobro',
              ],
              ['Ligou depois de sair', 'Atrasada: falha'],
            ],
          ),
          Lista([
            'Confira primeiro as medidas em Configurações > Implemento.',
            'Depois ajuste no monitor do trator os tempos de sobreposição e '
                'de salto (o nome e o lugar mudam conforme a marca; veja o '
                'manual do monitor).',
            'Teste numa cabeceira e confira no chão.',
          ]),
        ],
      ),
    ],
    perguntas: [
      Pergunta(
        enunciado: 'No John Deere GS3, qual ativação é necessária?',
        opcoes: [
          'Controle de seção',
          'Nenhuma',
          'Multi-Product Control',
          'Só o VT',
        ],
        correta: 0,
        explicacao: 'GS3 e GS4 precisam da ativação de Controle de seção.',
      ),
      Pergunta(
        enunciado:
            'A linha desligou antes de chegar na área já plantada. A '
            'regulagem está…',
        opcoes: ['adiantada', 'atrasada', 'certa'],
        correta: 0,
        explicacao: 'Desligou antes: adiantada, e fica uma faixa com falha.',
      ),
      Pergunta(
        enunciado:
            'A linha só ligou depois de sair da área plantada. O que acontece '
            'no chão?',
        opcoes: [
          'Fica uma faixa com falha',
          'Fica uma faixa com sementes em dobro',
          'Nada, está certo',
        ],
        correta: 0,
        explicacao:
            'Ligou depois: regulagem atrasada, sobra faixa sem semente.',
      ),
      Pergunta(
        enunciado: 'Qual sinal de GPS dá a melhor precisão passe a passe?',
        opcoes: ['SF1', 'SF2', 'SF3', 'RTK'],
        correta: 3,
        explicacao: 'RTK: ± 2,5 cm e convergência em menos de 1 minuto.',
      ),
    ],
  ),
];
