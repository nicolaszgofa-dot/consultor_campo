# Material técnico

Treinamento, instalação e regulagem da Linha Elétric (Selenium Elétric e Titanium Elétric). É o mesmo card, com o mesmo conteúdo, no app da equipe (JA Campo) e no da revenda (JA Campo Revenda). Na revenda, ele substitui os antigos "Regulagem e instalação" e "Treinamento da revenda".

## Como funciona

- A tela inicial do Material técnico tem dois cards:
  - **Ferramentas de campo:** hoje só o [Desligamento de linha](desligamento-de-linha.md);
  - **Capacitação:** os módulos, cada um mostrando quantas aulas e perguntas tem.
- Cada módulo tem aulas curtas, uma por tela, com "Anterior" e "Próxima aula". A barra do topo mostra o passo.
- Algumas aulas têm um atalho para praticar: o Simulador Elétric, a lista de alarmes ou os monitores compatíveis.
- No fim de cada módulo há um teste de 4 perguntas de múltipla escolha. Cada resposta mostra na hora se está certa e o porquê. Com todas respondidas, aparece "X de 4 certas" e, se errou alguma, o botão "Refazer o teste".
- Nada fica salvo, nem o progresso nem as notas. Isso vale até haver um servidor.

## Módulos

1. **Componentes do sistema:**
   - por que a Linha Elétric (argumentos de venda);
   - as peças do sistema e o motor do dosador;
   - a ECU J.Assy;
   - o LED dos drivers;
   - o alternador hidráulico, com a tabela de RPM por número de linhas.
2. **Instalação e regulagem:**
   - ECU e antenas;
   - energia das linhas (até 10 por ramo);
   - ligar e desligar o alternador;
   - sensor de levante;
   - disco e anel do Titanium: trocar e regular as travas;
   - o que não vem no kit.
3. **Tela de trabalho:**
   - as partes da tela;
   - a barra de ícones e a de mensagens;
   - os boxes e os gráficos;
   - os botões virtuais.
4. **Configurações:**
   - Dosagem e sensoriamento, com cada parâmetro e o alarme que ele dispara;
   - Implemento (linhas encontradas, desencontradas ou personalizadas);
   - fonte e filtro de velocidade;
   - endereçamento com o ímã;
   - energia, levante e sistema.
5. **Alarmes:**
   - como ler um alarme;
   - os mais comuns, com o primeiro passo. A tabela vem do catálogo do simulador (`simulador/alarmes.dart`), com as soluções do Selenium;
   - o que muda no Titanium: grafite, disco e anel em vez da pressão de ar.
6. **Monitores e corte de seção:**
   - as ativações em cada monitor;
   - o sinal de GPS;
   - a regulagem do liga e desliga (adiantada ou atrasada, tempos de sobreposição e salto).

## Fontes

As fontes estão em `CONFIGURADOR/manuais` e `CONFIGURADOR/TREINAMENTO` (ver [manuais-jassy.md](../base-conhecimento/manuais-jassy.md)):

- o manual do Titanium Elétric, para LED, alternador, instalação, implemento e alarmes;
- a apresentação "Treinamento Linha Elétric", para benefícios, composição do kit, tela, configurações e monitores;
- o manual do Selenium, para Configuração do Terminal Virtual, Compatibilidade e Lista de Alarme;
- o manual do Titanium, para o FAQ de grafite e de velocidade;
- o manual do Titanium Elétric, para a troca do disco e do anel e as travas.

As fotos da ECU, dos LEDs, do alternador e do sensor de levante foram reduzidas para `app/assets/treinamento/`.

## A confirmar com a engenharia

- O LED da ECU: o treinamento mostra os estados "parado ou manobra" e "plantando", mas não diz como cada um pisca.
- O estado "vermelho, verde e azul = inicialização" do LED do driver vem só da apresentação de 2024; o manual do Titanium Elétric não traz.
- A tabela de sinais de GPS é um exemplo, com os sinais StarFire. A primeira linha junta as duas gerações de receptor (± 15 a 23 cm).

## Código

- O conteúdo fica em `app/lib/treinamento/treinamento_dados.dart`. A entrada (os dois cards e a lista de ferramentas) fica em `material_tecnico_page.dart`, e a capacitação, as aulas e o teste em `treinamento_page.dart`.
- As aulas usam os mesmos blocos de texto do Conceito (`conceito/conceitos.dart`), mais o bloco `Imagem`.
- Os testes ficam em `app/test/treinamento_test.dart`.
