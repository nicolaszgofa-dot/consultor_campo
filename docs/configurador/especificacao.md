# Configurador Técnico J.Assy

Aplicação para a equipe comercial e técnica configurar, de forma guiada, as tecnologias de plantio da J.Assy a partir das características da plantadeira. Uso principal: **tablet**, em visitas a produtores, concessionárias e revendas, ao lado da máquina.

Primeira versão: **Titanium Elétric** e **Selenium Elétric**.

## Problema que resolve

Hoje a configuração depende do conhecimento de quem vende. Isso leva a:

- componentes obrigatórios esquecidos;
- erros de quantidade;
- configurações incompatíveis com a plantadeira;
- dificuldade para dimensionar alimentação elétrica e chicotes;
- dependência de profissionais experientes para validar;
- coleta e registro sem padrão.

O configurador centraliza as regras para o processo ficar **simples, repetível e rastreável**.

## Princípios de interface

- **Fluxo guiado:** uma etapa por vez.
- **Produtos reais:** logo J.Assy e imagens do Titanium Elétric e do Selenium Elétric.
- **Linguagem direta,** com os termos técnicos que o público já usa.
- **Campos dinâmicos:** só aparecem quando necessários.
- **Validação imediata:** erros apontados antes de avançar.
- **Resultado transparente:** o que foi configurado e **por que** cada componente entrou.
- **Tablet em campo:** botões grandes e boa leitura.
- **Relatório organizado** para conferência e uso posterior.

Experiência: o vendedor informa as características → o sistema interpreta → o vendedor confere.

## Sequência das etapas

1. Tecnologia que será configurada.
2. Tipo da plantadeira: autotransportável, caixa central, tandem ou solteira.
3. Número de linhas.
4. Número de seções que fecham separadas e linhas de cada seção: só para autotransportável, caixa central e tandem. Na solteira a etapa é pulada.
5. Alimentação (no autotransportável e no tandem com alternador, também se o alternador pode ir no cabeçalho ou no tandem).
6. Resultado.

## Arquitetura da lógica

| Camada | Conteúdo | Onde |
|---|---|---|
| Entrada de dados | tecnologia, tipo de plantadeira, linhas, seções, alternador | telas do app |
| Motor de regras | obrigatórias, condicionais, cálculos, validações | `packages/configurador` |
| Configuração gerada | componentes, quantidades, distribuição das saídas | `packages/configurador` |
| Resultado | resumo, componentes com motivo, validações, relatório | telas do app |

O motor de regras é Dart puro, sem tela, com testes. Cada regra pendente aparece no resultado como **pendente de definição técnica**, nunca como resolvida.

## Regras definidas

| Elemento | Regra |
|---|---|
| Tecnologias | Titanium Elétric e Selenium Elétric usam os mesmos componentes de instalação |
| Conjunto da tecnologia | 1 por linha (Conjunto Titanium Elétric ou Conjunto Selenium Elétric) |
| Conjunto ECU | 1, obrigatório; é um conjunto único com diversos componentes |
| Sensor de levante | 1 unidade, obrigatório |
| Sensor de semente | 1 por linha (quantidade = total de linhas) |
| Cabo ISOBUS | 1, obrigatório; comprimento de 5, 11, 14 ou 17 m |
| Alternador hidráulico | obrigatório a partir de 13 linhas |
| Kit de mangueiras do alternador | 1 quando há alternador: 3 mangueiras, uma mais fina para o dreno; comprimento de 6, 9, 12 ou 15 m |
| Até 12 linhas | perguntar se a máquina terá alternador hidráulico |
| Sem alternador | cabo de alimentação direto da bateria **obrigatório** |
| Chicotes de linha | de 4 linhas e de 1 linha, calculados **por seção**; ver "Chicotes" abaixo |
| Chicote painel | leva a alimentação da saída do alternador até os chicotes de linha; quantidade **recomendada** (ajustável pelo vendedor); comprimento de 4, 9 ou 14 m |
| Comprimentos | o vendedor escolhe conforme o tamanho da máquina; enquanto não escolhe, o item fica pendente. ISOBUS e mangueiras têm sugestão por tipo de máquina (ver "Sugestão de comprimentos") |
| Saídas do alternador | 6 saídas, no máximo 10 linhas por saída |
| Capacidade | acima de 60 linhas (6 × 10) a configuração é **bloqueada** e precisa de validação técnica |
| Tipos de plantadeira | autotransportável, caixa central, tandem e solteira |
| Seções | autotransportável, caixa central e tandem têm seções que fecham separadas (ex.: autotransportável com 3 seções); informar quantas e as linhas de cada uma |
| Solteira | seção única: a máquina inteira é uma seção, sem perguntar seções |
| Linhas por seção | a soma deve ser igual ao total de linhas |

## Distribuição das saídas do alternador

Cada saída alimenta um **conjunto** de no máximo 10 linhas vizinhas.

1. **Primeiro:** cada seção é dividida em conjuntos de até 10 linhas, sem misturar seções. Se o total de conjuntos couber nas 6 saídas, essa é a distribuição.
2. **Se não couber:** as linhas são distribuídas pelas saídas como recurso global (conjuntos equilibrados, em sequência). As saídas que atendem linhas de **duas seções** aparecem em destaque, como **ponto a validar pela engenharia**.
3. **Mais de 60 linhas:** bloqueia.

**Exemplo** (55 linhas, autotransportável, seções 21 + 21 + 13):
- Sem misturar seções seriam 3 + 3 + 2 = 8 saídas, acima das 6 disponíveis.
- Distribuição global: 6 saídas com 10, 9, 9, 9, 9 e 9 linhas.
- Saídas que cruzam a divisão entre seções ficam marcadas para validação.

A distribuição é **indicativa**. O limitante é sempre a saída do alternador (no máximo 10 linhas); na montagem, o técnico ajusta as saídas conforme a máquina e as seções reais.

## Chicotes

A montagem segue a sequência: alternador → de cada saída sai um **chicote painel** → conexão com os **chicotes de linha** que alimentam o conjunto daquela saída. Quando o conjunto passa de uma seção para outra, outro chicote painel liga os chicotes de linha de uma seção aos da seguinte.

### Chicotes de linha: sempre por seção

Os chicotes de linha **nunca** são calculados pelo total de linhas da máquina. Como cada seção fecha sozinha, a montagem considera cada seção como uma **máquina separada**: em cada seção, o máximo de chicotes de 4 linhas, completando com chicotes de 1 linha.

**Exemplo** (45 linhas, seções 17 + 17 + 11):
- Seção de 17 linhas: 4 chicotes de 4 + 1 de 1 (duas seções assim).
- Seção de 11 linhas: 2 chicotes de 4 + 3 de 1.
- Total: **10 chicotes de 4 linhas e 5 de 1 linha.**
- Pelo total da máquina (45 linhas) daria 11 de 4 + 1 de 1, que não serve para montar uma máquina que fecha: é o erro que o configurador evita.

### Chicote painel: quantidade recomendada

A quantidade é **recomendada** pelas seções e saídas usadas, e o vendedor pode ajustar. O comprimento é escolhido pelo vendedor.

- **Com alternador:** 1 por saída usada + 1 a cada troca de seção dentro de uma saída. Ex.: 45 linhas (17 + 17 + 11) usam 6 saídas sem troca de seção → 6. 55 linhas (21 + 21 + 13) usam 6 saídas, duas delas trocam de seção → 8.
- **Sem alternador:** obrigatório e padrão: **2 chicotes painel de 4 m** (o vendedor pode ajustar).

## Sugestão de comprimentos (cabo ISOBUS e mangueiras)

O cabo ISOBUS e as mangueiras do alternador saem de pontos próximos, por isso o sistema sugere os dois **em dupla**, conforme o tipo de máquina:

| Tipo de máquina | ISOBUS / mangueiras |
|---|---|
| Autotransportável que permite o alternador no **cabeçalho** | 5 m / 6 m |
| Autotransportável que não permite o alternador no cabeçalho | 11 m / 12 m |
| Tandem que permite o alternador no **tandem** | 5 m / 6 m |
| Tandem que não permite o alternador no tandem | 11 m / 12 m |
| Caixa central | 17 m / 15 m |
| Solteira | 5 m / 6 m |

- No autotransportável e no tandem com alternador, o configurador pergunta se a máquina permite instalar o alternador no cabeçalho (ou no tandem). Sem a resposta, não há sugestão.
- A sugestão **não fecha o item**: ele continua pendente até o vendedor escolher o comprimento.
- O item sempre mostra a observação: **o comprimento segue o tamanho da máquina; confirmar as características da máquina para ter certeza.**

## Pendências técnicas (não tratar como resolvidas)

- **Sugestão de ISOBUS** no autotransportável e no tandem **sem alternador** (hoje sem sugestão).
- **Sugestão de comprimento do chicote painel** com alternador.
- Se cada chicote painel da máquina pode ter um **comprimento diferente** (hoje é um comprimento para todos).
- Demais regras de **cabeamento**.
- Se uma saída do alternador **pode** atender linhas de duas seções (ver exemplo acima).
- Se algum **tipo de plantadeira** muda outras regras além das seções (cabeamento, chicotes).
- **Commander:** fora desta versão.

## Casos de teste do motor de regras

| Caso | Resultado esperado |
|---|---|
| 8 linhas, 1 seção, sem alternador | conjuntos 8, ECU 1, levante 1, sensores 8, ISOBUS 1 (comprimento pendente), cabo da bateria 1 (obrigatório), 2 chicotes de 4 linhas, 2 chicotes painel de 4 m (obrigatório); sem alternador |
| 12 linhas sem responder sobre o alternador | erro: responder se terá alternador |
| 12 linhas com alternador, seções 6 + 6 | alternador 1; 2 saídas (6 e 6), sem mistura |
| 13 linhas | alternador obrigatório, sem perguntar |
| 30 linhas, seções 10 + 10 + 10 | 3 saídas, uma por seção; 3 chicotes painel, 6 de 4 linhas, 6 de 1 linha |
| 45 linhas, seções 17 + 17 + 11 | 10 chicotes de 4 linhas, 5 de 1 linha; chicote painel recomendado 6 |
| 55 linhas, seções 21 + 21 + 13 | 6 saídas (10, 9, 9, 9, 9, 9); aviso nas que atendem duas seções; 13 chicotes de 4 linhas, 3 de 1 linha; chicote painel recomendado 8 |
| Vendedor ajusta chicote painel para 7 | quantidade 7, recomendação 8 mantida; 0 é erro |
| Comprimentos não escolhidos | ISOBUS, chicote painel e mangueiras pendentes, com as opções |
| Solteira / caixa central | sugestão ISOBUS / mangueiras: 5 / 6 m e 17 / 15 m |
| Autotransportável ou tandem, alternador na frente: sim / não | sugestão 5 / 6 m ou 11 / 12 m; sem resposta, sem sugestão |
| Sugestão aceita pelo vendedor | item definido, com a observação de confirmar a máquina |
| ISOBUS de 10 m | erro: comprimento não existe |
| 61 linhas | bloqueado: acima de 60 linhas |
| Seções 20 + 20 com total 45 | erro: soma das seções (40) diferente do total (45) |
| Solteira, 8 linhas, sem alternador | seção única de 8 linhas; sem perguntar seções |
| Solteira, 55 linhas | 6 saídas (10, 9, 9, 9, 9, 9), sem aviso de mistura |
| Caixa central ou tandem sem seções | erro: informar as seções |
