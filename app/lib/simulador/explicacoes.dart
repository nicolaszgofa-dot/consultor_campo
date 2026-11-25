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
    'Tensão que chega às linhas (bateria ou alternador hidráulico). Com '
        'alternador, recomenda-se no mínimo 3000 RPM, mesmo em máquinas com '
        'menos de 25 linhas.',
  ),
  plantar(
    'Levante manual',
    'Quando o levante manual está habilitado, este botão alterna entre '
        'Plantar e Manobra. Em Manobra os dosadores param.',
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
  rodape(
    'Relógio e páginas',
    'Hora do terminal e a navegação entre as páginas do terminal virtual '
        'do monitor ISOBUS.',
  );

  final String titulo;
  final String texto;

  const ParteTerminal(this.titulo, this.texto);
}
