/// Partes do terminal com a explicação do manual de instruções (Selenium,
/// "Configuração do Terminal Virtual") e do treinamento da Linha Elétric.
enum ParteTerminal {
  barraIcones(
    'Barra de ícones',
    'Área trabalhada (ha) e os ícones de estado: taxa variável ativada '
        '(mapa de prescrição do monitor ISO), corte de seção ativado, '
        'estado do sensor de levante e o número de furos do disco de '
        'plantio.',
  ),
  barraMensagens(
    'Barra de alarmes e status',
    'Mostra o estado de trabalho do implemento: Plantando (verde) ou '
        'Manobra (amarelo). Quando há alarme, ele aparece aqui em vermelho, '
        'com o número de alarmes ativos ao lado.',
  ),
  taxa(
    'Taxa média de sementes',
    'Média de sementes por metro de todas as linhas que estão plantando. '
        'Embaixo: a taxa alvo e o espaçamento entre sementes. No terminal, '
        'tocar aqui abre o ajuste da taxa (+ e −, de 0,1 em 0,1 sem/m).',
  ),
  singulacao(
    'Média de singulação, falhas e duplos',
    'Singulação é a porcentagem de sementes que caíram uma a uma. Embaixo, '
        'a média de falhas (×) e de duplos (Y) das linhas. Os limites de '
        'alarme ficam em Configurações > Dosagem e Sensoriamento.',
  ),
  cv(
    'Média de coeficiente de variação',
    'CV dos espaçamentos entre sementes, na média das linhas. Quanto menor, '
        'mais regular a distribuição. Acima do "CV Máximo" configurado, '
        'aparece o alarme CV Elevado.',
  ),
  graficoCima(
    'Gráfico por linha',
    'Uma barra por linha da plantadeira, para achar a linha com problema. '
        'Toque no título para alternar entre Taxa, Singulação, CV, '
        'População e Distribuição. As linhas tracejadas azuis são os '
        'limites de alarme (população máxima e mínima, CV máximo). Toque '
        'numa barra para abrir a linha.',
  ),
  graficoBaixo(
    'Segundo gráfico por linha',
    'O mesmo tipo de gráfico, com outra grandeza. Assim o operador '
        'acompanha duas informações por linha ao mesmo tempo, por exemplo '
        'taxa e singulação.',
  ),
  velocidade(
    'Fonte de velocidade',
    'Velocidade usada para dosar e de onde ela vem: GPS ISOBUS (do '
        'trator), GPS ECU (antena da ECU J.Assy), Radar ou Manual. Sem '
        'fonte, o terminal mostra o alarme Fonte de Velocidade Ausente.',
  ),
  tensao(
    'Fonte de energia',
    'Com alternador hidráulico, mostra a rotação do alternador (RPM); com '
        'bateria, a tensão (V). Recomenda-se no mínimo 3000 RPM, mesmo em '
        'máquinas com menos de 25 linhas. A fonte é escolhida em '
        'Configurações > Energia.',
  ),
  plantar(
    'Levante manual',
    'Quando o levante manual está habilitado (Configurações > Sensor de '
        'Levante), este botão alterna entre Plantar e Manobra. Em Manobra os '
        'dosadores param.',
  ),
  inicio(
    'Tela início',
    'Volta para a tela de trabalho de qualquer outra tela.',
  ),
  configuracoes(
    'Menu de configurações',
    'Sistema, Dosagem e Sensoriamento, Implemento, Filtro de Velocidade, '
        'Fonte de Velocidade, Endereçamento, Energia e Sensor de Levante. '
        'Parâmetros de engenharia ficam protegidos por senha.',
  ),
  cadeado(
    'Senha de engenharia',
    'O cadeado trava os parâmetros de uso restrito à engenharia J.Assy '
        '(Singulação Crítica e Porcentagem de Sujeira). Fechado, eles '
        'aparecem apagados; tocar no cadeado pede a senha de acesso. Aberto, '
        'tocar de novo trava.',
  ),
  rodape(
    'Relógio e páginas',
    'Hora do terminal e a navegação entre as páginas do terminal virtual '
        'do monitor ISOBUS.',
  ),
  cfgSistema(
    'Sistema',
    'Versão do software, hardware e ID da ECU. Em Ajustes de '
        'Compatibilidade: liberar a taxa variável no GS3 e informar o máximo '
        'de seções que o monitor aceita (veja os monitores compatíveis).',
  ),
  cfgDosagem(
    'Dosagem e Sensoriamento',
    'Número de furos do disco e os limites dos alarmes de qualidade: '
        'Máximo de Falhas e de Duplos, População Máxima e Mínima (% acima e '
        'abaixo da taxa alvo), Distribuição Mínima e CV Máximo. Distância de '
        'Medidas é o intervalo, em metros, entre cada amostragem mostrada na '
        'tela. Ajuste de População corrige a leitura do sensor para refletir '
        'a população real no solo; acima de 1, acende o alarme Ganho de '
        'População Ativo. Os dois últimos são da engenharia (senha).',
  ),
  cfgImplemento(
    'Implemento',
    'Número de linhas e distância entre elas, e a geometria da plantadeira: '
        'do engate até as rodas e das rodas até a saída das linhas curtas e '
        'das longas, e quantas linhas são curtas. Com essas medidas o corte '
        'de seção liga e desliga cada linha no ponto certo.',
  ),
  cfgFiltro(
    'Filtro de velocidade',
    'Filtro de dinâmica: evita que os dosadores partam ou parem com '
        'oscilações de velocidade. Eles só partem acima da Velocidade de '
        'Partida, depois do Tempo de Partida, e só param abaixo da Velocidade '
        'de Parada, depois do Tempo de Parada.',
  ),
  cfgFonteVelocidade(
    'Fonte de velocidade',
    'De onde vem a velocidade: GPS ISOBUS (do monitor ou do trator), GPS '
        'ECU (antena na ECU J.Assy, com o DOP máximo aceito), Manual '
        '(velocidade digitada) ou Radar (com a constante de ajuste). A tela '
        'mostra os dados que estão chegando.',
  ),
  cfgEnderecamento(
    'Endereçamento',
    'Liga o endereço de cada dosador ao número da linha. Escolha a linha, '
        'toque em Ler e encoste o ímã no módulo do dosador daquela linha: o '
        'endereço aparece na tela. Depois toque em Gravar.',
  ),
  cfgEnergia(
    'Energia',
    'Bateria ou Alternador hidráulico. Com alternador, configure a rotação '
        'mínima e a máxima: fora da faixa aparecem os alarmes de baixa e de '
        'alta rotação. Recomendado no mínimo 3000 RPM.',
  ),
  cfgLevante(
    'Sensor de levante',
    'Sensores que indicam se a plantadeira está erguida (Manobra) ou '
        'plantando. Habilite os sensores instalados e inverta a lógica se o '
        'sensor trabalhar ao contrário. Sensor Manual habilita a tecla '
        'Plantar/Manobrar. Com dois sensores, escolha se basta um ou se os '
        'dois precisam indicar manobra.',
  ),
  senha(
    'Senha de acesso',
    'Tela que pede a senha dos parâmetros de engenharia. No simulador, '
        'qualquer senha libera.',
  );

  final String titulo;
  final String texto;

  const ParteTerminal(this.titulo, this.texto);
}
