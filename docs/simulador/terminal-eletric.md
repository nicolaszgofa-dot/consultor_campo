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
  - rotação do alternador (ou a tensão, com bateria);
  - Plantar ou Manobrar (só com o levante manual habilitado);
  - Início;
  - cadeado da engenharia (nas configurações);
  - Configurações.
- Interações:
  - tocar em TAXA ajusta a taxa em passos de 0,1;
  - o título do gráfico troca a grandeza;
  - uma barra abre a tela da linha, onde dá para ligar ou desligar a linha.
- **Explicar a tela:** toque numa parte do terminal para ver o texto do manual.
- **Simular no campo:** entupir a linha 7 (alarme "Fim de Sementes ou Entupimento") e mudar a velocidade.
- O protótipo do Adobe XD continua disponível no botão "Abrir protótipo".

## Etapa 2 (pronta): configurações e alarmes

As oito telas de configuração seguem as capturas do treinamento. Os campos brancos abrem um editor com − e +, e os seletores verdes abrem a lista de opções.

| Tela | O que dá para mudar | Efeito na simulação |
|---|---|---|
| Sistema | Taxa variável GS3, máximo de seções do monitor | — |
| Dosagem e Sensoriamento | Furos do disco; máximos de falhas e duplos; população máxima e mínima; distribuição mínima; CV máximo; distância de medidas; ajuste de população | Os limites acendem os alarmes. Ajuste acima de 1 aumenta a taxa e acende "Ganho de População Ativo" |
| (engenharia, com senha) | Singulação crítica, porcentagem de sujeira | Singulação abaixo da crítica acende "Baixa Singulação" |
| Implemento | Número de linhas, distância entre linhas, geometria (engate, rodas, saídas curta e longa), Titanium | O número de linhas muda os gráficos |
| Filtro de Velocidade | Tempos e velocidades de partida e de parada | Abaixo da velocidade de parada, os dosadores param |
| Fonte de Velocidade | GPS ISOBUS, GPS ECU (DOP), Manual (velocidade), Radar (constante) | A tecla A mostra a fonte |
| Endereçamento | Linha; Ler, encostar o ímã, Gravar | Grava o endereço lido na linha |
| Energia | Bateria ou Alternador; rotação mínima e máxima | Fora da faixa acende o alarme de rotação. A tecla B mostra RPM ou V |
| Sensor de Levante | Sensores 1 e 2, inverter lógica, sensor manual, "ambos" ou "basta 1" para manobra | Sem o sensor manual, a tecla C some |

- **Senha:** o cadeado (tecla I) pede a senha. No simulador, qualquer senha libera. A senha real não está no app.
- **Simular no campo:**
  - entupir a linha 7;
  - pressão de ar alta (duplos);
  - parar o alternador;
  - perder o sinal de GPS;
  - a velocidade.

  O primeiro alarme ativo aparece no painel com "O que fazer".
- **Lista de alarmes:** os 29 alarmes do manual, por origem (sensor de sementes, dosador, fonte de energia, ECU). Cada um tem a urgência, a descrição e "o que fazer", tirado do treinamento. Os sem orientação no material ficam só com a descrição.
- **Monitores compatíveis:** a tabela do manual, com 9 monitores. Para cada um: versão, terminal virtual, Task Controller, controle de seção, taxa variável, número de seções e multiprodutos.

Código: `app/lib/simulador/`.
- O estado e a lógica dos alarmes ficam em `terminal_estado.dart`.
- O catálogo de alarmes fica em `alarmes.dart`.
- O desenho fica em `terminal_eletric.dart` e `terminal_configuracoes.dart`.
- As páginas de alarmes e de monitores ficam em `referencias_terminal.dart`.
- Os textos de explicação ficam em `explicacoes.dart`.

## A confirmar com a engenharia

- O valor padrão do "Tempo de Fim de Semente". O manual cita o campo, mas a captura da tela de Dosagem não mostra, então ele ficou de fora.
- A orientação para os alarmes sem "o que fazer" no treinamento:
  - Compensação C. Inativa;
  - Bateria com Baixa Tensão;
  - os alarmes de curva e de velocidade angular;
  - Operação com taxa 0.
- O que a opção "Titanium" da tela Implemento muda na máquina.
