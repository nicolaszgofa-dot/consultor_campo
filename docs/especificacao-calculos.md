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

## Diferenças intencionais em relação ao app de referência

- Com todas as amostras iguais (CV 0%) mostramos o resultado; o app de referência o escondia.
- Espaçamento entre linhas acima de 3 é tratado como provável digitação em centímetros.
