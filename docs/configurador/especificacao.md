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
5. Alimentação.
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
| Sem alternador | incluir cabo de alimentação direto da bateria |
| Chicotes de linha | de 4 linhas e de 1 linha; ver "Chicotes" abaixo |
| Chicote painel | leva a alimentação da saída do alternador até os chicotes de linha; comprimento de 4, 9 ou 14 m |
| Comprimentos | o vendedor escolhe conforme o tamanho da máquina; enquanto não escolhe, o item fica pendente |
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

## Chicotes

A montagem segue a sequência: alternador → de cada saída sai um **chicote painel** → conexão com os **chicotes de linha** que alimentam o conjunto daquela saída. Quando o conjunto passa de uma seção para outra, outro chicote painel liga os chicotes de linha de uma seção aos da seguinte.

- **Trecho:** linhas de uma saída dentro de uma mesma seção. Uma saída que atende duas seções tem dois trechos.
- **Chicote painel:** 1 por trecho (1 por saída + 1 a cada troca de seção dentro de uma saída).
- **Chicotes de linha** por trecho, conforme a escolha do vendedor:
  - **4 + 1 (padrão):** o máximo de chicotes de 4 linhas, completando com de 1 linha. Ex.: 10 linhas = 2 de 4 + 2 de 1.
  - **Só de 1 linha:** um chicote por linha. Ex.: 10 linhas = 10 de 1.

**Exemplo** (55 linhas, seções 21 + 21 + 13, padrão 4 + 1):
- Trechos: 10, 9, 2 | 7, 9, 5 | 4, 9 (as saídas 3 e 5 trocam de seção).
- 8 chicotes painel, 11 chicotes de 4 linhas e 11 de 1 linha.

**Sem alternador** (até 12 linhas): os chicotes de linha são calculados por seção.

## Pendências técnicas (não tratar como resolvidas)

- **Sugestão de comprimento** de cabo ISOBUS, chicote painel e mangueiras para cada tipo de plantadeira.
- **Chicote painel sem alternador:** quantos e onde, quando a alimentação vem direto da bateria.
- Se cada chicote painel da máquina pode ter um **comprimento diferente** (hoje é um comprimento para todos).
- Demais regras de **cabeamento**.
- Se uma saída do alternador **pode** atender linhas de duas seções (ver exemplo acima).
- Se algum **tipo de plantadeira** muda outras regras além das seções (cabeamento, chicotes).
- **Commander:** fora desta versão.

## Casos de teste do motor de regras

| Caso | Resultado esperado |
|---|---|
| 8 linhas, 1 seção, sem alternador | conjuntos 8, ECU 1, levante 1, sensores 8, ISOBUS 1 (comprimento pendente), cabo da bateria 1, 2 chicotes de 4 linhas; chicote painel pendente; sem alternador |
| 12 linhas sem responder sobre o alternador | erro: responder se terá alternador |
| 12 linhas com alternador, seções 6 + 6 | alternador 1; 2 saídas (6 e 6), sem mistura |
| 13 linhas | alternador obrigatório, sem perguntar |
| 30 linhas, seções 10 + 10 + 10 | 3 saídas, uma por seção; 3 chicotes painel, 6 de 4 linhas, 6 de 1 linha |
| 55 linhas, seções 21 + 21 + 13 | 6 saídas (10, 9, 9, 9, 9, 9); aviso nas que atendem duas seções; 8 chicotes painel, 11 de 4 linhas, 11 de 1 linha |
| 55 linhas, só chicotes de 1 linha | 55 chicotes de 1 linha |
| Comprimentos não escolhidos | ISOBUS, chicote painel e mangueiras pendentes, com as opções |
| ISOBUS de 10 m | erro: comprimento não existe |
| 61 linhas | bloqueado: acima de 60 linhas |
| Seções 20 + 20 com total 45 | erro: soma das seções (40) diferente do total (45) |
| Solteira, 8 linhas, sem alternador | seção única de 8 linhas; sem perguntar seções |
| Solteira, 55 linhas | 6 saídas (10, 9, 9, 9, 9, 9), sem aviso de mistura |
| Caixa central ou tandem sem seções | erro: informar as seções |
