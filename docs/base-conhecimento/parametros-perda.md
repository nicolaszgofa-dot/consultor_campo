# Parâmetros de perda por plantio desuniforme

Coeficientes para estimar, a partir de uma medição de trena, quanto a lavoura perde por duplas, falhas e variação nos espaçamentos. É a base do futuro relatório de perda e ROI.

Conceitos e demais fontes: [plantabilidade.md](plantabilidade.md). Marcação: ✅ lido na fonte original; ⚠️ a confirmar.

---

## Resumo dos parâmetros

| Cultura | Entrada da medição | Parâmetro | Valor médio | Faixa | Fonte |
|---|---|---|---|---|---|
| **Soja** | % de plantas faltando por falhas | fator de não compensação das falhas | **0,74** | 0,49 – 0,93 | ✅ Fiss et al., 2018 |
| **Soja** | % de plantas a mais em duplas/triplas | fator de perda das duplas | **0,21** | 0,14 – 0,28 | ✅ Fiss et al., 2018 |
| **Milho** | desvio padrão dos espaçamentos (cm) | perda por cm acima da referência | **62 kg/ha** | 30 – 111 kg/ha | ✅ Nielsen (Purdue) |
| **Milho** (alternativa) | desvio padrão (cm) | perda relativa por cm | 0,3% | — | ⚠️ Purdue 2004–06 |
| **Feijão** | CV dos espaçamentos (%) | perda por ponto de CV | **0,44%** | — | ✅ Bisognin et al., 2019 |

As faixas viram os cenários **otimista / médio / pessimista** do relatório.

---

## Soja: falhas e duplas (Fiss et al., 2018)

### O estudo

- Duas lavouras comerciais em Capão do Leão (RS), cultivares **Fundacep 59 RR** e **BMX Potência RR**.
- Semeadora de disco regulada para **14 sementes/m** (uma a cada 7 cm), linhas a 50 cm (280.000 plantas/ha).
- Na colheita, foram colhidas e pesadas plantas inteiras em cada situação: planta normal, dupla, tripla e plantas na borda de falhas de 14, 21, 28 e 35 cm (1 a 4 plantas faltando).
- A produtividade por área foi **calculada** supondo uma ocorrência de cada situação por metro de linha.

### O que mostrou (Tabela 2 do artigo)

| Situação (1 por metro) | Fundacep 59 RR | BMX Potência RR |
|---|---|---|
| Linha perfeita | 2.428 kg/ha (100%) | 3.441 kg/ha (100%) |
| Uma dupla | 98,0% | 98,6% |
| Uma tripla | 97,2% | 98,0% |
| Falha de 14 cm (1 planta) | 94,0% | 94,0% |
| Falha de 21 cm (2 plantas) | 92,1% | 91,3% |
| Falha de 28 cm (3 plantas) | 83,4% | 80,1% |
| Falha de 35 cm (4 plantas) | 74,2% | 86,0% |

Conclusões dos autores:
- As plantas na borda da falha produzem mais, mas **não compensam** a planta que falta.
- **Duplas e triplas reduzem a produtividade**, mesmo havendo mais plantas na linha. A planta dupla produziu menos da metade de uma planta normal.
- Na Fundacep 59 RR, a produtividade caiu **21,5 kg/ha por cm de falha** (com uma falha por metro).

### Como transformamos em parâmetro

Dividimos a perda de produtividade pela porcentagem de plantas afetadas. Exemplo: uma falha de 1 planta em 14 tira 7,1% das plantas e custou 6,0% da produtividade, então o fator é 6,0 ÷ 7,1 = **0,84** (as vizinhas recuperaram só 16% da perda).

| Situação | % de plantas afetadas | Perda (Fundacep / BMX) | Fator (Fundacep / BMX) |
|---|---|---|---|
| Falha de 1 planta | 7,1% faltando | 6,0% / 6,0% | 0,84 / 0,84 |
| Falha de 2 plantas | 14,3% faltando | 7,9% / 8,7% | 0,55 / 0,61 |
| Falha de 3 plantas | 21,4% faltando | 16,6% / 19,9% | 0,77 / 0,93 |
| Falha de 4 plantas | 28,6% faltando | 25,8% / 14,0% | 0,90 / 0,49 |
| Dupla | 7,1% a mais | 2,0% / 1,4% | 0,28 / 0,20 |
| Tripla | 14,3% a mais | 2,8% / 2,0% | 0,20 / 0,14 |

**Médias:** falhas **0,74** (faixa 0,49–0,93); duplas e triplas **0,21** (faixa 0,14–0,28).

### Fórmula para o app

```
plantas esperadas   = comprimento medido (cm) ÷ espaçamento ideal (cm)
plantas faltando    = soma, em cada falha, de (arredondar(espaçamento ÷ ideal) − 1)
plantas a mais      = número de espaçamentos classificados como dupla

% faltando          = plantas faltando ÷ plantas esperadas × 100
% a mais            = plantas a mais ÷ plantas esperadas × 100

perda soja (%)      = 0,74 × % faltando + 0,21 × % a mais
perda (sc/ha)       = perda (%) × produtividade esperada (sc/ha) ÷ 100
```

**Exemplo:** soja a 14 sementes/m (ideal 7,1 cm). Em 10 m de linha (140 plantas esperadas) a trena mostrou 15 plantas faltando em falhas (10,7%) e 10 duplas (7,1%).

| Cenário | Cálculo | Perda | Em 60 sc/ha |
|---|---|---|---|
| Otimista | 0,49 × 10,7 + 0,14 × 7,1 | 6,2% | 3,7 sc/ha |
| Médio | 0,74 × 10,7 + 0,21 × 7,1 | 9,4% | 5,6 sc/ha |
| Pessimista | 0,93 × 10,7 + 0,28 × 7,1 | 11,9% | 7,1 sc/ha |

### Limites deste parâmetro

- Um único local, uma safra, duas cultivares, semeadora de disco a 14 sementes/m.
- A produtividade por área foi **calculada** a partir de plantas individuais, com uma ocorrência por metro. Lavouras com muitas falhas seguidas podem se comportar diferente.
- Cultivares de mais ramificação compensam mais (a BMX Potência compensou melhor a falha de 4 plantas).
- Vale bem para falhas de até 4 plantas. Falhas maiores devem ser tratadas como **perda de estande**, sem compensação.

---

## Milho: desvio padrão dos espaçamentos (Nielsen, Purdue)

```
DV de referência    = 5 cm   (≈ 2 polegadas, nível que Nielsen trata como alcançável)
perda milho (kg/ha) = k × (DV medido − DV de referência), só quando o DV medido é maior
k                   = 62 kg/ha por cm   (faixa 30 a 111)
```

| Cenário | k (kg/ha por cm) | Origem (bu/ac por polegada) |
|---|---|---|
| Otimista | 30 | 1,2 (menor valor de Nielsen) |
| Médio | 62 | 2,5 (média de Nielsen, 8 locais-ano) |
| Pessimista | 84 | 3,4 (Doerge et al., Pioneer) |
| Extremo | 111 | 4,5 (maior valor de Nielsen) |

**Exemplo:** DV medido de 9 cm → 4 cm acima da referência → 4 × 62 = **250 kg/ha (≈ 4 sc/ha)**, faixa de 120 a 340 kg/ha.

**Relação com o CV:** `DV = CV × espaçamento médio ÷ 100`. Com espaçamento médio de 25 cm, um CV de 36% corresponde a DV de 9 cm.

⚠️ Os coeficientes vêm de lavouras dos EUA (linhas de 76 cm, híbridos americanos). No Brasil, com linhas de 45–50 cm, o efeito pode ser diferente. Um ensaio próprio da empresa substituiria esses números.

---

## Feijão: CV dos espaçamentos (Bisognin et al., 2019)

```
perda feijão (%) = 0,44 × CV (%)
```

O estudo testou CVs de 0, 20, 40 e 60%: −81,5 kg/ha (−4,4%) a cada 10 pontos de CV, com relação linear. ✅

---

## Referências de campo para comparar no relatório

**Soja no Planalto Médio do RS** ✅ (Santi et al., 2022, safra 2019/20, 23 áreas, 14 produtores)

| | Sequeiro | Irrigado | Geral |
|---|---|---|---|
| CV médio dos espaçamentos | 54,4% | 62,5% | 58,3% |
| Falhas | 15,6% (9,4 – 21,7) | 18,4% (12,0 – 23,7) | — |
| Duplas | 18,6% (7,0 – 32,4) | 22,2% (11,5 – 39,1) | — |
| Espaçamentos aceitáveis | 65,8% | 59,4% | — |

Pela classificação de Tourino & Klingensteiner, 13% das áreas ficaram "bom", 78,3% "regular" e 8,7% "insatisfatório". Nenhuma chegou a "ótimo".

O relatório pode usar essa tabela para mostrar ao produtor onde a lavoura dele está em relação à média da região.

**Atenção à referência dos 16%:** Santi et al. citam Carvalho et al. (2003) dizendo que o CV máximo aceitável para soja seria 16%. Pelo título (*Proposta de classificação dos coeficientes de variação em relação à produtividade e altura da planta de soja*, Pesquisa Agropecuária Brasileira, 2003), esse trabalho classifica o **CV de experimentos** (precisão estatística de ensaios), não o CV dos espaçamentos entre plantas. **Não usar 16% como meta de plantabilidade** até ler o original. ⚠️

**Milho safrinha em MT** ✅ (Borghi et al., 2018): estande médio 57.636 plantas/ha; só 20% dos talhões sem falhas e duplas; falhas tiraram em média 4.785 plantas/ha.

---

## Decisões para o app

1. **Mesma referência (Xref) em todo o app:** usamos o espaçamento ideal (100 ÷ sementes/m). Santi et al. e Borghi et al. usaram o espaçamento médio medido. Na comparação com a tabela regional, avisar que o método difere.
2. **Soja:** usar a fórmula de Fiss et al., que parte das falhas e duplas, em vez do CV.
3. **Milho:** usar o desvio padrão (DV), com referência de 5 cm.
4. **Feijão:** usar o CV.
5. **Sempre três cenários** e a página de premissas e fontes no relatório.
6. **Coeficientes configuráveis:** quando a empresa tiver ensaios próprios, eles substituem os da literatura.

## Fontes

- Fiss, G.; Schuch, L. O. B.; Peske, S. T.; Castellanos, C. I. S.; Meneghello, G. E.; Aumonde, T. Z. *Produtividade e características agronômicas da soja em função de falhas na semeadura.* Revista de Ciências Agrárias (Amazonian Journal of Agricultural and Environmental Sciences), v. 61, 2018. DOI [10.22491/rca.2018.2477](http://dx.doi.org/10.22491/rca.2018.2477). [Artigo](https://btcc.ufra.edu.br/index.php/ajaes/pt_BR/article/view/2477/1531)
- Santi, A. L.; Baron, F. A.; Gerlach, L. F. R.; Fornari, E. Z.; Manfio, E. S.; Gutheil, A. L. M. *Qualidade de semeadura da soja em áreas do Planalto Médio do Rio Grande do Sul.* Tecno-Lógica, v. 26, n. 1, p. 105-108, 2022. DOI 10.17058/tecnolog.v26i1.16965. [Artigo](https://seer.unisc.br/index.php/tecnologica/article/view/16965)
- Nielsen, R. L. *Effect of Plant Spacing Variability on Corn Grain Yield.* Purdue University, 2004. [Purdue](https://agry.purdue.edu/Ext/corn/research/psv/Update2004.html)
- Bisognin, M. B. et al. *Seed spacing variability reduces common bean yield.* Pesquisa Agropecuária Tropical, v. 49, e55134, 2019. [SciELO](https://www.scielo.br/j/pat/a/sLxT4LdZV4kyC6wfTtXjmsG/abstract/?lang=en)
- Borghi, E. et al. *Avaliação da plantabilidade em lavouras de milho safrinha do estado de Mato Grosso.* XXXII Congresso Nacional de Milho e Sorgo, 2018. [Embrapa Alice](https://www.alice.cnptia.embrapa.br/alice/bitstream/doc/1095523/1/Avaliacaoplantabilidade.pdf)

Conversões e fatores derivados (bu/ac → kg/ha, fatores de não compensação) são cálculos nossos sobre os dados publicados.
