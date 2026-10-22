# Configurador Técnico J.Assy

Aplicação para a equipe comercial e técnica configurar, de forma guiada, as tecnologias de plantio da J.Assy a partir das características da plantadeira. Uso principal: **tablet**, em visitas a produtores, concessionárias e revendas, ao lado da máquina.

Primeira versão: **Titanium Electric** e **Selenium Electric**.

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
- **Produtos reais:** logo J.Assy e imagens do Titanium Electric e do Selenium Electric.
- **Linguagem direta,** com os termos técnicos que o público já usa.
- **Campos dinâmicos:** só aparecem quando necessários.
- **Validação imediata:** erros apontados antes de avançar.
- **Resultado transparente:** o que foi configurado e **por que** cada componente entrou.
- **Tablet em campo:** botões grandes e boa leitura.
- **Relatório organizado** para conferência e uso posterior.

Experiência: o vendedor informa as características → o sistema interpreta → o vendedor confere.

## Arquitetura da lógica

| Camada | Conteúdo | Onde |
|---|---|---|
| Entrada de dados | tecnologia, linhas, arquitetura, seções, alternador | telas do app |
| Motor de regras | obrigatórias, condicionais, cálculos, validações | `packages/configurador` |
| Configuração gerada | componentes, quantidades, distribuição das saídas | `packages/configurador` |
| Resultado | resumo, componentes com motivo, validações, relatório | telas do app |

O motor de regras é Dart puro, sem tela, com testes. Cada regra pendente aparece no resultado como **pendente de definição técnica**, nunca como resolvida.

## Regras definidas

| Elemento | Regra |
|---|---|
| Tecnologias | Titanium Electric e Selenium Electric (mesmas regras nesta versão) |
| ECU | 1 conjunto, obrigatório |
| Sensor de levante | 1 unidade, obrigatório |
| Sensor de semente | 1 por linha (quantidade = total de linhas) |
| Cabo ISOBUS | 1, obrigatório; **modelo e comprimento pendentes** |
| Alternador hidráulico | obrigatório a partir de 13 linhas |
| Até 12 linhas | perguntar se a máquina terá alternador hidráulico |
| Sem alternador | incluir cabo de alimentação direto da bateria |
| Saídas do alternador | 6 saídas, no máximo 10 linhas por saída |
| Capacidade | acima de 60 linhas (6 × 10) a configuração é **bloqueada** e precisa de validação técnica |
| Seções | características estruturais da máquina (ex.: autotransportável com 3 seções que fecham separadas) |
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

## Pendências técnicas (não tratar como resolvidas)

- Modelo e comprimento do **cabo ISOBUS**.
- Composição dos **chicotes de 1 e 4 linhas**.
- Comprimento do **cabo de painel**.
- Demais regras de **cabeamento**.
- Se uma saída do alternador **pode** atender linhas de duas seções (ver exemplo acima).
- Lista de **arquiteturas** de plantadeira e o que muda em cada uma.
- Diferenças de regra entre **Titanium Electric e Selenium Electric**, se houver.

## Casos de teste do motor de regras

| Caso | Resultado esperado |
|---|---|
| 8 linhas, 1 seção, sem alternador | ECU 1, levante 1, sensores 8, ISOBUS 1 (pendente), cabo da bateria 1; sem alternador |
| 12 linhas sem responder sobre o alternador | erro: responder se terá alternador |
| 12 linhas com alternador, seções 6 + 6 | alternador 1; 2 saídas (6 e 6), sem mistura |
| 13 linhas | alternador obrigatório, sem perguntar |
| 30 linhas, seções 10 + 10 + 10 | 3 saídas, uma por seção |
| 55 linhas, seções 21 + 21 + 13 | 6 saídas (10, 9, 9, 9, 9, 9); aviso nas que atendem duas seções |
| 61 linhas | bloqueado: acima de 60 linhas |
| Seções 20 + 20 com total 45 | erro: soma das seções (40) diferente do total (45) |
