# Plantabilidade, estande e perdas no plantio

Base de conhecimento técnico do Consultor de Campo. Reúne conceitos, critérios de avaliação e dados de perda de produtividade, com a fonte de cada número.

**Como ler:**
- ✅ **Confirmado:** lido na fonte original (artigo completo, resumo publicado ou página do autor).
- ⚠️ **A confirmar:** aparece só em trabalhos que citam a fonte, ou em material de fabricante. Conferir no original antes de usar em relatório para cliente.

Pesquisa feita em outubro de 2026. Conversões de unidade (bu/ac → kg/ha e sacas) são nossas.

---

## 1. Plantabilidade

**O que é:** a qualidade com que a semeadora coloca cada semente no lugar certo: **espaçamento uniforme na linha** (distribuição longitudinal), **profundidade correta** e contato com o solo, para que as plantas emerjam juntas e sem competir entre si. ✅ (Tosin et al., 2025; Borghi et al., 2018)

Na prática, o termo é usado quase sempre para a **distribuição longitudinal**: quantas sementes caíram no espaçamento certo, quantas caíram juntas (duplas) e onde ficou buraco (falhas).

**Por que importa:** a população de plantas e o arranjo delas na linha definem o teto de produtividade da lavoura. Plantas desiguais competem por luz, água e nutrientes, e as menores produzem pouco. ✅ (Tosin et al., 2025)

**O que mais afeta a plantabilidade** ✅ (Tosin et al., 2025)
- Tipo de dosador: os pneumáticos tendem a distribuir com mais uniformidade que os mecânicos de disco horizontal.
- Velocidade de plantio: quanto mais rápido, maior a variação entre espaçamentos.
- Semente: tamanho, formato e pureza do lote. Sementes fora do padrão do disco geram falhas e duplas.
- Regulagem e manutenção: disco correto para a semente, peças gastas, vácuo, limpeza.

## 2. Estande de plantas

**O que é:** o número de plantas **efetivamente estabelecidas** por área (plantas/ha) ou por metro linear. É diferente da quantidade de sementes distribuídas: a diferença está nas sementes que não germinaram, nas plântulas que morreram e nas falhas da semeadora.

| Termo | Significado |
|---|---|
| População recomendada | Quanto a cultivar/híbrido pede (plantas/ha) |
| Sementes por metro | O que a semeadora deve distribuir; já considera germinação e perdas esperadas |
| Estande inicial | Plantas emergidas, contadas logo após a emergência |
| Estande final | Plantas vivas na colheita |

**Conversão usada no app:** `plantas/ha = plantas por metro × 10.000 ÷ espaçamento entre linhas (m)`.

**O que a pesquisa mostra no Brasil** ✅ (Borghi et al., 2018 — Embrapa/Aprosoja, Circuito Tecnológico 2017)
- 289 talhões de milho safrinha em 32 municípios de Mato Grosso.
- Estande médio de **57.636 plantas/ha**, variando de **32.000 a 88.000**.
- Só **20%** dos talhões tinham distribuição com 100% de precisão (sem falhas nem duplas).
- Em média, as falhas tiraram **4.785 plantas/ha** da lavoura.
- Em média, **3.188 plantas/ha** estavam mais próximas do que o recomendado.
- Conclusão dos autores: mesmo com máquinas modernas, plantabilidade e estande final continuam limitando a produtividade do milho safrinha no estado.

## 3. Duplas, falhas e espaçamentos aceitáveis

Cada espaçamento entre duas plantas vizinhas é comparado com o **espaçamento de referência (Xref)**:

| Classe | Critério |
|---|---|
| Dupla (ou múltipla) | menor que 0,5 × Xref |
| Aceitável | de 0,5 a 1,5 × Xref |
| Falha | maior que 1,5 × Xref |

✅ Critério da ABNT, aplicado por Borghi et al. (2018) e por diversos trabalhos de avaliação de semeadoras.

**Atenção: qual é o Xref?**
- Nas normas de ensaio de semeadora, Xref é o **espaçamento teórico**, calculado pela regulagem (100 ÷ sementes por metro, em cm). É o que o nosso app usa.
- Alguns levantamentos de campo usam o **espaçamento médio medido** (Borghi et al., 2018 descrevem assim).
- Os dois dão resultados diferentes quando a população está errada. No app, mantemos o teórico, porque ele mostra também o erro de população.

**Classificação do desempenho pela % de espaçamentos aceitáveis** ⚠️ (Tourino & Klingensteiner, 1983, citado por vários trabalhos; original não consultado)

| % de aceitáveis | Desempenho |
|---|---|
| 90 a 100% | Ótimo |
| 75 a 90% | Bom |
| 50 a 75% | Regular |
| abaixo de 50% | Insatisfatório |

⚠️ Coelho (1996) é citado como exigindo no mínimo 60% de espaçamentos aceitáveis para certificar dosadores. Original não consultado.

## 4. Coeficiente de variação (CV) no plantio

**O que é:** mede quanto os espaçamentos variam em torno da média. ✅ (Tosin et al., 2025; Kurachi et al., 1989, citado em vários trabalhos)

```
CV (%) = desvio padrão dos espaçamentos ÷ média dos espaçamentos × 100
```

- CV baixo = plantas espaçadas de forma regular.
- O CV complementa a contagem de duplas e falhas: duas linhas podem ter 0 falhas e CVs diferentes.
- No app usamos o desvio padrão **amostral** (n − 1).

**Cuidado ao comparar CVs.** Existem dois CVs diferentes em uso:
1. **CV dos espaçamentos entre plantas** (o do nosso app e o da literatura de semeadoras).
2. **CV do número de plantas por trecho** (ex.: plantas a cada 5 m), usado por alguns aplicativos de fabricante. Dá valores bem diferentes e não deve ser comparado com o primeiro.

**Valores de referência encontrados**

| Situação | CV observado | Fonte |
|---|---|---|
| Soja, dosador pneumático (62 furos) | 11 a 18% | ✅ Tosin et al., 2025 |
| Soja, dosador pneumático (56 furos) | 18 a 27% | ✅ Tosin et al., 2025 |
| Soja, disco horizontal (90 furos) | 37 a 53% | ✅ Tosin et al., 2025 |

Atenção: o estudo de Tosin et al. calculou o CV pelo aplicativo do fabricante a partir de contagens por trecho (tipo 2 acima). Use os números para comparar dosadores entre si, não como meta para o CV de espaçamentos.

Não encontramos uma tabela de classes de CV (ótimo/bom/regular) com fonte original confirmada. Até confirmar, o app **não classifica** o CV de plantabilidade; mostra o valor e as % de duplas/falhas.

## 5. Singularização

**O que é:** a capacidade do dosador de liberar **uma semente de cada vez**, sem pular (falha) e sem soltar duas ou três juntas (dupla/múltipla).

```
Singularização (%) = 100 − % de falhas − % de múltiplas
```
⚠️ (Universidade da Geórgia, Svirk, 2023; fórmula vista em citação, apresentação não aberta)

**Causas comuns de má singularização** ⚠️ (materiais de extensão e de fabricantes)
- Disco incompatível com o tamanho/formato da semente (sementes grandes ou achatadas → falhas).
- Peças gastas no dosador.
- Vácuo ou "eliminador de duplas" fora de regulagem (dosadores pneumáticos).
- Velocidade acima da indicada para o dosador.

**Referências de mercado** ⚠️ (material de fabricante, não independente)
- Dosadores pneumáticos de alta precisão: 98 a 99% de singularização.
- Dedos prensores mecânicos: 94 a 99%, conforme o tamanho da semente.

**Singularização × espaçamento:** um dosador pode singularizar 99% e mesmo assim gerar espaçamentos irregulares, se a semente quica no tubo condutor ou se a velocidade varia. Por isso a avaliação no campo mede o espaçamento entre plantas, não só a singularização.

## 6. Perdas por causa do plantio

### Milho (a cultura mais sensível)

| Estudo | Resultado | Em unidades brasileiras* |
|---|---|---|
| ✅ Nielsen (Purdue), 8 locais-ano, 1987–1996 | −2,5 bu/ac por polegada de desvio padrão dos espaçamentos (de 1,2 a 4,5) | ≈ −62 kg/ha (≈ 1 saca) por **cm** de desvio padrão |
| ✅ Nielsen (Purdue), 2004, 1 local | −2,2 bu/ac por polegada de desvio padrão | ≈ −54 kg/ha por cm |
| ✅ Doerge et al. (Pioneer), 2002 | −3,4 bu/ac por polegada | ≈ −84 kg/ha por cm |
| ⚠️ Purdue, 9 locais, 2004–2006 (resumo do projeto) | −0,3% da produtividade por cm de desvio padrão; até −6,4% no total | — |
| ✅ Precision Planting (fazenda própria), 2018 em diante | −1,9 bu/ac por ponto de singularização abaixo de 99,5% | ≈ −119 kg/ha (≈ 2 sacas) por ponto |

\* 1 bu/ac de milho = 62,8 kg/ha; 1 polegada = 2,54 cm; saca de 60 kg.

**Desvio padrão típico em lavouras** ✅ (Nielsen; levantamentos nos EUA): média de 4,5 polegadas (11 cm) em 354 lavouras de Indiana e Ohio, e 3,3 polegadas (8 cm) em 127 lavouras de Wisconsin.

**Como ler esses números:** com a média de 2,5 bu/ac por polegada, uma lavoura com desvio padrão de 11 cm que melhore para 5 cm ganharia cerca de 6 cm × 62 kg/ha ≈ **370 kg/ha (6 sacas)**. É uma estimativa de ordem de grandeza: os estudos são dos EUA, com outros híbridos e espaçamentos.

**Falhas × duplas no milho** ✅ (Nielsen, 2004)
- Falhas quase sempre reduzem a produtividade: tiram plantas e aumentam a variação.
- O efeito das duplas é discutido. Em algumas populações, plantas mais próximas compensaram parte da perda das falhas.

### Feijão

✅ Bisognin et al. (2019), *Pesquisa Agropecuária Tropical*: a produtividade caiu de forma **linear** com o aumento do CV dos espaçamentos, **−81,5 kg/ha (−4,4%) a cada 10 pontos de CV**. O componente que mais explicou a perda foi o número de grãos por planta.

### Soja

- ✅ Masino et al. (2018): a irregularidade no **espaçamento** afetou uma cultivar precoce (grupo de maturação III), mas não uma tardia (grupo IV). A **emergência desigual no tempo** reduziu a produtividade em todas as cultivares, ou seja, pesou mais que o espaçamento.
- A ideia antiga de que "a soja compensa qualquer falha" é contestada. Plantas vizinhas a uma falha produzem mais, mas não o suficiente para cobrir a perda. ⚠️ (estudo da UFRA citado em buscas; texto original não acessado)
- Excesso de plantas também prejudica: favorece acamamento e pode reduzir a produtividade. ⚠️ (Embrapa Soja e estudo em talhão comercial, vistos em resumo de busca)

### Resumo para o consultor

1. **Milho** é a cultura onde a uniformidade mais paga: cada cm a menos de desvio padrão vale da ordem de 1 saca/ha.
2. **Falhas** custam mais que duplas: tiram plantas do estande e não são compensadas.
3. **Emergência uniforme** (profundidade, umidade, contato com o solo) importa tanto quanto o espaçamento, principalmente na soja.
4. Medir é barato: duas linhas de 5 m por talhão já mostram o problema (método do Circuito Tecnológico).

---

## Implicações para o app

- ✅ O critério de duplas/falhas do módulo de Plantabilidade (0,5 e 1,5 × ideal) está de acordo com a ABNT.
- ✅ O CV do app é o CV dos espaçamentos, com desvio padrão amostral, como na literatura de semeadoras.
- Sugestão: mostrar a **classificação de Tourino & Klingensteiner** (ótimo/bom/regular/insatisfatório) a partir da % de aceitáveis, depois de confirmar a fonte original.
- Sugestão: mostrar o **desvio padrão em cm** e uma **estimativa de perda para milho**, deixando claro que é estimativa baseada em estudos dos EUA.
- O limite de CV < 7% do módulo de Fertilizante veio do app de referência e **não** tem fonte nesta pesquisa. Vale procurar uma norma ou recomendação técnica para ele.

## Fontes

- Borghi, E.; Silva, A. F.; Resende, Á. V.; Gontijo Neto, M. M.; Ferreira, A.; Behling, M. *Avaliação da plantabilidade em lavouras de milho safrinha do estado de Mato Grosso: resultados do Circuito Tecnológico – Etapa Milho.* XXXII Congresso Nacional de Milho e Sorgo, 2018. [Embrapa Alice](https://www.alice.cnptia.embrapa.br/alice/bitstream/doc/1095523/1/Avaliacaoplantabilidade.pdf)
- Tosin, B. K. M.; Marques, T. F. C.; Lima, J. M. T.; Carvalho, L. B. *Plantabilidade e coeficiente de variação com diferentes dosadores de sementes.* CONTECC, 2025. [PDF](https://www.confea.org.br/midias/uploads-imce/CONTECC2025/AGRO/PLANTABILIDADE_E_COEFICIENTE_DE_VARIA%C3%87%C3%83O_COM_DIFERENTES_DOSADORES_DE_SEMENTES.pdf)
- Nielsen, R. L. *Effect of Plant Spacing Variability on Corn Grain Yield.* Purdue University, 2004 (atualizado 2023). [Purdue](https://agry.purdue.edu/Ext/corn/research/psv/Update2004.html)
- Purdue University. Projeto de pesquisa em manejo de milho (resultados 2004–2006). [USDA NIFA](https://portal.nifa.usda.gov/web/crisprojectpages/0091418-agronomic-investigations-in-corn-production-management-systems.html)
- Precision Planting. *Corn Singulation Study.* [Precision Planting](https://precisionplanting.com/resources/research/corn-singulation-study) — estudo do próprio fabricante.
- Svirk, 2023. *Seed Metering Performance.* University of Georgia. [PDF](https://agtechdata.uga.edu/files/2023/07/Seed-Metering-Performance-APRES-2023-Svirk.pdf)
- Bisognin, M. B. et al. *Seed spacing variability reduces common bean yield.* Pesquisa Agropecuária Tropical, v. 49, e55134, 2019. [SciELO](https://www.scielo.br/j/pat/a/sLxT4LdZV4kyC6wfTtXjmsG/abstract/?lang=en)
- Masino, A. et al. *Spatial and temporal plant-to-plant variability effects on soybean yield.* 2018. [INTA](https://repositoriosdigitales.mincyt.gob.ar/vufind/Record/INTADig_fbd71454fa17db9a0410be27ee3e2f45)
- Kurachi, S. A. H. et al. *Avaliação tecnológica de semeadoras e/ou adubadoras: tratamento de dados de ensaios e regularidade de distribuição longitudinal de sementes.* Bragantia, v. 48, n. 2, p. 249-262, 1989. (citado; original não consultado)
- Tourino, M. C. C.; Klingensteiner, P. 1983. (citado; original não consultado) — classificação ótimo/bom/regular/insatisfatório, reproduzida em [UTFPR](https://eventos.utfpr.edu.br//sei/sei2019/paper/download/5029/1190) e [UFPel](https://periodicos.ufpel.edu.br/index.php/CAST/article/view/1388/1374).

## A pesquisar em seguida

- Original de Tourino & Klingensteiner (1983) e de Coelho (1996).
- Norma ABNT vigente para ensaio de semeadoras (texto e definição exata de Xref).
- Dados brasileiros de perda por falha em **soja** (Embrapa Soja, Pesquisa Agropecuária Brasileira).
- Recomendação técnica de CV/tolerância para distribuição de **fertilizante** na linha.
