# Desligamento de linha

Ferramenta de campo do Material técnico, igual nos apps da equipe e da revenda. Ajuda a configurar o corte de seção (desligamento linha a linha) da Linha Elétric em três abas. Nada fica salvo.

Para abrir: Material técnico > "Ferramenta de campo: Desligamento de linha", ou o atalho na aula "Regulagem do liga e desliga" do módulo 6.

## Monitor

Você escolhe um dos 9 monitores compatíveis (a mesma lista do simulador). Para cada um, a ferramenta mostra:

- as ativações pedidas pelo treinamento da Linha Elétric;
- o controle de seção, o Task Controller e o máximo de seções, do manual do Selenium;
- o nome do ajuste de tempo de liga e desliga nesse monitor e onde ele fica;
- um selo:
  - **"Conferido no manual do fabricante"**, quando o caminho foi lido na documentação oficial;
  - **"Confira no manual do monitor"**, quando é só orientação geral.

Depois vem a lista do que conferir antes de ir ao campo:
- ativações;
- terminador ISOBUS;
- medidas do implemento;
- sinal de GPS;
- linhas endereçadas.

## Geometria

São as medidas para o terminal J.Assy (Configurações > Implemento), nos três tipos do manual do Titanium Elétric:

- **Encontradas:** linhas, espaçamento, engate-roda e roda-saída.
- **Desencontradas:** o mesmo, com saída curta e saída longa, e se a linha 1 é curta ou longa.
- **Personalizadas:** você toca nas linhas do desenho para marcar quais são longas.

O desenho mostra a plantadeira vista de cima com as cotas, e o resultado vem pronto para digitar no terminal, com a largura de trabalho. A ferramenta avisa quando uma medida parece errada:
- mais de 62 linhas;
- espaçamento fora de 0,15 a 1,2 m;
- saída longa mais perto das rodas que a curta;
- medida acima de 15 m.

## No campo

O técnico informa o que viu no chão:

| | Regulagem | No chão | O que fazer |
|---|---|---|---|
| Desligou antes | adiantada | falha | diminuir o tempo de desligar |
| Desligou depois | atrasada | sobreposição | aumentar o tempo de desligar |
| Ligou antes | adiantada | sobreposição | diminuir o tempo de ligar |
| Ligou depois | atrasada | falha | aumentar o tempo de ligar |

A correção é **tempo = distância medida ÷ velocidade** (km/h ÷ 3,6). Exemplo: 1 m a 7,2 km/h = 0,5 s. Com o tempo atual do monitor, a ferramenta já dá o novo valor, que nunca fica abaixo de zero.

"Tempo" aqui é o tempo de reação que o monitor desconta para mandar ligar ou desligar antes. Cada marca chama de um jeito: retardo, atraso, antecipação ou look-ahead. Aumentar faz o comando sair mais cedo.

## Fontes

- **Treinamento Linha Elétric:**
  - ativações por monitor;
  - regulagem adiantada e atrasada;
  - medidas do implemento.
- **Manual do Titanium Elétric:**
  - tipos de implemento;
  - "regular os tempos de sobreposição e saltos conferindo no solo";
  - consultar o fornecedor do monitor.
- **Manual do Selenium:** compatibilidade.
- **John Deere Geração 4** (ajuda on-line do 4640):
  - [Retardo mecânico](https://displaysimulator.deere.com/onscreen_help/4640/current/en/seedstar/impl_profile_mechanical_delay.htm): Mechanical Delay On/Off, de 0,10 a 15 s, com o procedimento de medição e o Ajuste de desempenho (Performance Tuning);
  - [como o controle de seção decide](https://displaysimulator.deere.com/onscreen_help/4640/current/en/section_control/section_control_theory.htm).
- **John Deere** ([perfil de implemento](https://displaysimulator.deere.com/onscreen_help/S7combine/current/en/implement_profiles/implement_profiles_mechanical_delay.htm)): para plantadeiras, 0,5 a 1,0 s para ligar e 0,3 s para desligar, como valor de partida.
- **Raven:** manual do Viper Pro (look-ahead de ligar e desligar, em segundos).
- **Topcon:** índice do manual do X35 (Controle de seção > Temporização).
- **ISOBUS:** DDI [205](https://www.isobus.net/isobus/dDEntity/926) e [206](https://www.isobus.net/isobus/dDEntity/927) (SC Setpoint Turn On/Off Time).

## A confirmar

- **Tempos de partida para o Elétric:** o motor elétrico responde diferente de uma transmissão mecânica. Hoje a ferramenta só mostra o valor da John Deere para plantadeiras.
- **Se a ECU J.Assy informa os tempos ao monitor:** pelo ISOBUS (DDI 205 e 206) o implemento pode mandar o seu tempo de ligar e desligar.
- **O caminho do menu nos monitores:** CCI 1200, Case IH, Trimble, Ag Leader, Hexagon, Raven CR7, Topcon C3000 e o GS3.

## Código

- Dados e cálculos: `app/lib/desligamento/desligamento_dados.dart`.
- Tela: `desligamento_page.dart`.
- Desenho: `desenho_geometria.dart`.
- Testes: `app/test/desligamento_test.dart`.
