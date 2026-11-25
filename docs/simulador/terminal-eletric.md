# Simulador Elétric

A tela "Simulador Elétric" (equipe e revenda) reproduz o terminal virtual da Linha Elétric no monitor ISOBUS, com dados simulados, para treinamento. Fontes: o treinamento da Linha Elétric e o manual do Selenium, capítulo "Configuração do Terminal Virtual".

## Etapa 1 (pronta): tela de trabalho

- Barra de ícones: área trabalhada, taxa variável, corte de seção, sensor de levante e furos do disco.
- Barra de status e alarmes: Plantando ou Manobra. O alarme aparece em vermelho.
- Quadros TAXA, SINGULAÇÃO e CV, com médias das linhas. Abaixo vêm alvo, espaçamento, falhas e duplos.
- Dois gráficos por linha: Taxa, Singulação, CV, População e Distribuição.
  - Os limites aparecem tracejados.
  - Singulação e distribuição usam o eixo de 80 a 100%.
- Teclas A–J:
  - fonte de velocidade;
  - tensão;
  - Plantar ou Manobrar;
  - Início;
  - Configurações (só o menu).
- Interações:
  - tocar em TAXA ajusta a taxa em passos de 0,1;
  - o título do gráfico troca a grandeza;
  - uma barra abre a tela da linha, onde dá para ligar ou desligar a linha.
- **Explicar a tela:** toque numa parte do terminal para ver o texto do manual.
- **Simular no campo:** entupir a linha 7 (alarme "Fim de Sementes ou Entupimento") e mudar a velocidade.
- O protótipo do Adobe XD continua disponível no botão "Abrir protótipo".

Código: `app/lib/simulador/`. O estado da simulação fica em `terminal_estado.dart`, o desenho do terminal em `terminal_eletric.dart` e os textos de explicação em `explicacoes.dart`.

## Etapa 2 (a fazer): configurações e alarmes

- As telas de configuração:
  - Sistema;
  - Dosagem e Sensoriamento, com senha para os parâmetros de engenharia;
  - Implemento;
  - Filtro de Velocidade;
  - Fonte de Velocidade;
  - Endereçamento;
  - Energia;
  - Sensor de Levante.
- A lista de alarmes do manual.
- A tabela de compatibilidade dos monitores.
