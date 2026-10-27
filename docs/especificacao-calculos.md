# Especificação dos cálculos

Regras do módulo `avaliacao_plantio`. Cada linha das tabelas de casos tem um teste correspondente em `packages/avaliacao_plantio/test/`. Os casos foram validados em campo contra um app de referência do mercado.

## Plantabilidade

**Entradas:** sementes por metro, espaçamento entre linhas (m) e leituras acumuladas da trena (cm), com o zero na primeira planta.

| Grandeza | Regra |
|---|---|
| Espaçamento ideal (cm) | `100 / sementes por metro` |
| Espaçamento | diferença entre leituras seguidas, arredondada a 0,1 cm |
| Dupla | espaçamento `< 0,5 × ideal` |
| Falha | espaçamento `> 1,5 × ideal` |
| Aceitável | demais casos (os limites contam como aceitável) |
| Percentual de cada classe | `contagem / n × 100` |
| Média e DV | média e desvio padrão **amostral (n − 1)** dos espaçamentos |
| CV (%) | `DV × 100 / média` |
| Metros lineares/ha | `10000 / espaçamento entre linhas` |
| População (plantas/ha) | `sementes por metro informadas × metros lineares/ha` |

### Casos (4 sementes/m, 0,50 m → ideal 25 cm)

| Caso | Leituras (cm) | Resultado esperado |
|---|---|---|
| P1 | 25 · 50 · 75 · 100 | 100% aceitáveis, CV 0,0% |
| P2 | 40 · 80 · 120 · 160 | 100% falhas, média 40,00, população 80.000 |
| P3 | 12 · 24,4 · 36,9 · 49,5 · 62,5 | duplas 40% (12 e 12,4), DV 0,36, CV 2,9% |
| P4 | 37 · 74,4 · 111,9 · 149,5 · 187,5 | falhas 40% (37,6 e 38), CV 1,0% |
| P5 | 20 · 50 | DV 7,07, CV 28,3% |
| P6 | 10 · 35 · 75 | 33,3% de cada classe, DV 15,00, CV 60,0% |

## Fertilizante

**Entradas:** dose desejada (kg/ha), espaçamento entre linhas (m), distância de coleta (m), número de linhas e gramas coletadas por linha.

| Grandeza | Regra |
|---|---|
| Ideal por amostra (g) | `kg/ha × espaçamento × distância / 10` |
| Linha dentro do padrão | `|g − ideal| ≤ 5% do ideal` |
| Média, DP | média e desvio padrão **amostral (n − 1)** das linhas |
| CV (%) | `DP × 100 / média` (usa a média coletada, não o ideal) |
| Status | `CV < 7%` → Dentro do padrão; senão → Atenção |
| Dose real (kg/ha) | `média × 10 / (espaçamento × distância)` |
| Mínimo | 2 linhas preenchidas para calcular |

### Casos (espaçamento 0,5 m, distância 10 m)

| Caso | Dose | Gramas | Resultado esperado |
|---|---|---|---|
| A1 | 300 | 150 · 150 | ideal 150 g, CV 0,0%, dentro do padrão, dose real 300 |
| A2 | 300 | 140 · 160 | DP 14,14, CV 9,4%, atenção, as duas linhas fora |
| A3 | 300 | 120 · 150 · 180 | CV 20,0%, só 150 dentro |
| A4 | 250 | 120 · 150 · 180 | ideal 125 g, CV 20,0%, só 120 dentro |
| A5 | 200 | 94 · 95 · 96 · 104 · 105 · 106 | 94 e 106 fora, CV 5,5%, dentro do padrão |
| Limite | 200 | 93,1 · 100 · 106,9 | CV 6,9%, dentro do padrão |
| Limite | 200 | 93 · 100 · 107 | CV 7,0%, atenção |

## Perda estimada

Estima quanto a lavoura perde pela desuniformidade medida na plantabilidade. Sempre em três cenários (otimista, médio, pessimista). Coeficientes e fontes: `docs/base-conhecimento/parametros-perda.md`. Código: `packages/avaliacao_plantio/lib/src/perda/perda_calc.dart`.

**Entradas:** cultura, avaliação de plantabilidade e produtividade esperada (kg/ha).

| Grandeza | Regra |
|---|---|
| Plantas esperadas | comprimento medido ÷ espaçamento ideal |
| Plantas faltando | soma, em cada falha, de `arredondar(espaçamento ÷ ideal) − 1` (mínimo 1) |
| Plantas a mais | uma por dupla |
| Soja (%) | `fator falhas × % faltando + fator duplas × % a mais` |
| Milho (kg/ha) | `k × (DV − 5 cm)`, zero se DV ≤ 5 cm |
| Feijão (%) | `0,44 × CV` |
| Limite | perda entre 0 e 100% |
| Sacas/ha | `kg/ha ÷ 60` |

| Coeficiente | Otimista | Médio | Pessimista |
|---|---|---|---|
| Soja, fator falhas | 0,49 | 0,74 | 0,93 |
| Soja, fator duplas | 0,14 | 0,21 | 0,28 |
| Milho, kg/ha por cm de DV | 30 | 62 | 84 |
| Feijão, % por ponto de CV | 0,44 | 0,44 | 0,44 |

Os coeficientes podem ser substituídos por valores de ensaios próprios (`CoeficientesPerda`).

### Casos (4 sementes/m, 0,50 m → ideal 25 cm, salvo indicação)

| Caso | Entrada | Resultado esperado |
|---|---|---|
| Soja, contagem | leituras 25 · 75 · 100 · 110 · 125 · 200 | 8 esperadas, 3 faltando (37,5%), 1 a mais (12,5%) |
| Soja, perda | mesmas leituras, 3.600 kg/ha | 20,125% / **30,375%** / 38,375%; médio = 1.093,5 kg/ha (18,2 sc/ha) |
| Soja, exemplo da base | 10,7% faltando, 7,1% a mais | 6,2% / 9,4% / 11,9% |
| Soja, linha perfeita | 25 · 50 · 75 · 100 | 0% nos três cenários |
| Milho, exemplo da base | DV 9 cm | 120 / **248** / 336 kg/ha |
| Milho, leituras | 10 · 35 · 75 (DV 15 cm), 10.000 kg/ha | 300 / **620** / 840 kg/ha; médio = 6,2% |
| Milho, abaixo da referência | DV ≤ 5 cm | 0 kg/ha |
| Feijão | CV 10% / 20% | 4,4% / 8,8% |
| Feijão, leituras | 20 · 50 (CV 28,3%), 2.000 kg/ha | médio 12,45% = 248,9 kg/ha |

## Avaliação por linhas (trena)

Código: `packages/avaliacao_plantio/lib/src/avaliacao/avaliacao_calc.dart`.

| Regra | Valor |
|---|---|
| Linha completa | última leitura da trena ≥ 1.000 cm (10 m) |
| Resultado liberado | pelo menos **1 linha completa** |
| Amostra pequena | menos de **5 linhas completas** (recomendado): o resultado sai com aviso nas telas de leituras, resultado e prejuízo |
| Total | soma das plantas esperadas, faltando e a mais de todas as linhas |
| No lugar certo (%) | `100 − (faltando + a mais) ÷ esperadas × 100` |
| CV e DV da avaliação | sobre todos os espaçamentos das linhas juntos |
| Linha em destaque | a de mais falhas, quando passa da média das linhas em 30% ou mais |

| Caso (4 sementes/m) | Resultado esperado |
|---|---|
| 5 linhas perfeitas de 10 m | 200 esperadas, 100% no lugar certo, CV 0% |
| 4 linhas de 10 m + 1 de 9,75 m | 4 completas, resultado liberado com aviso de amostra pequena |
| 1 linha de 9,75 m | nenhuma completa, sem resultado |
| 4 linhas com 1 falha + 1 com 5 | 9 faltando, 95,5% no lugar certo, linha 5 com 178% mais falhas que a média |

## Prejuízo em R$

Código: `packages/avaliacao_plantio/lib/src/perda/prejuizo_calc.dart`.

| Grandeza | Regra |
|---|---|
| Produtividade perdida (R$/ha) | perda (sc/ha) × preço da saca |
| Sementes a mais (por ha) | população alvo × % de plantas a mais nas duplas |
| Sementes desperdiçadas (R$/ha) | sementes a mais × preço do saco ÷ sementes por saco |
| Prejuízo por hectare | produtividade perdida + sementes desperdiçadas |
| Valor que deixa de faturar | prejuízo por hectare × área (ha) |
| Alqueire | paulista = 2,42 ha; mineiro = 4,84 ha |

Sobreposição ainda não entra no desperdício de sementes.

| Caso | Resultado esperado |
|---|---|
| Soja, 700 esperadas, 57 faltando, 28 a mais, 65 sc/ha, saca R$ 125, semente R$ 380 / 200 mil, 280.000 sementes/ha, 500 ha | 11.200 sementes/ha a mais = R$ 21,28/ha; médio: 4,46 sc/ha = R$ 557,84 + R$ 21,28 = R$ 579,12/ha → **R$ 289.560**; faixa R$ 195.484 a R$ 363.787 |

## Emergência (marcação dia após dia)

Código: `packages/avaliacao_plantio/lib/src/emergencia/emergencia_calc.dart`. Método e fontes: `docs/base-conhecimento/emergencia.md`.

**Entradas:** cultura, data do plantio, linhas marcadas, metros por linha, sementes/m e, a cada visita, as plantas **novas** de cada linha.

| Grandeza | Regra |
|---|---|
| DAP | dias entre a data do plantio e a da marcação (só as datas, sem horas) |
| Dia 1 | primeira data com planta emergida; as outras contam a partir dela (dia 2, 3, 4+) |
| Mesma data marcada duas vezes | o app grava a última marcação daquele dia |
| % no 1º dia | plantas do dia 1 ÷ plantas emergidas |
| Emergência | plantas emergidas ÷ (linhas × metros × sementes/m) |
| Linha em destaque | a de menor % no 1º dia, quando fica 10 pontos ou mais abaixo da média |
| Perda (milho) | média, por planta, da redução de potencial: 35% com 1 dia de atraso, 60% com 2 (interpolado), 85% com 3 ou mais |
| Perda (soja, feijão) | sem coeficiente; mostra só a distribuição por dia |

| Caso (milho, plantio 01/10, 5 linhas × 10 m × 2,2 sementes/m) | Resultado esperado |
|---|---|
| 80 plantas no 5º DAP, 15 no 6º, nenhuma no 7º, 5 no 8º | dias 1, 2 e 4; 80% no 1º dia; 100 de 110 = 90,9% de emergência; perda (15 × 35 + 5 × 85) ÷ 100 = **9,5%**; linha 5 em destaque (66,7% contra 84,2% das outras) |

## Diferenças intencionais em relação ao app de referência

- Com todas as amostras iguais (CV 0%) mostramos o resultado; o app de referência o escondia.
- Espaçamento entre linhas acima de 3 é tratado como provável digitação em centímetros.
