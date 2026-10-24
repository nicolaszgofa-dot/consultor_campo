# ROI do retrofit J.Assy

Calculadora para o vendedor mostrar ao produtor o retorno do retrofit J.Assy. Base: planilha `Calculadora_ROI_Retrofit_JAssy.xlsx` (abas Premissas, Calculadora e Comparativo). O cálculo fica em `packages/roi` e é testado contra o exemplo da planilha.

## Etapas no app

1. Fazenda e produção
2. Sementes e sobreposição
3. Taxa variável
4. Curvas e operação
5. Investimento
6. Resultado
7. Comparativo

Cada campo mostra a orientação "como levantar no cliente" da planilha e um botão **?** com o texto "Como apresentar ao cliente". Indicadores e gráficos do resultado e do comparativo também têm o botão. Os campos começam vazios (o app é público: nenhum preço vem preenchido), menos dois valores mais técnicos, que já vêm preenchidos e o vendedor pode mudar:

- **Redução esperada:** 85%.
- **Perda sem compensação:** 0,5% (Conservador). Embaixo do campo há três botões que preenchem o valor: Conservador 0,5%, Provável 1% e Potencial 2%. Qualquer outro valor pode ser digitado.

Obrigatórios: área plantada, investimento do retrofit e vida econômica (maiores que zero). Percentuais entre 0 e 100%. Os demais podem ficar vazios (contam como zero).

## Premissas

| Grupo | Campo | Unidade |
|---|---|---|
| Fazenda | Área plantada | ha |
| Fazenda | Número de linhas | linhas |
| Produção | Produtividade média | sc/ha |
| Produção | Preço da commodity | R$/sc |
| Sementes | População média | sementes/ha |
| Sementes | Preço da semente | R$/mil sementes |
| Sobreposição | Sobreposição atual | % da área |
| Sobreposição | Redução esperada | % |
| Taxa variável | Área de menor potencial | ha |
| Taxa variável | População atual na zona | sementes/ha |
| Taxa variável | População prescrita | sementes/ha |
| Curvas | Área afetada por curvas | % da área |
| Curvas | Perda sem compensação | % da receita |
| Operação | Economia operacional/manutenção | R$/safra |
| Investimento | Retrofit J.Assy | R$ |
| Investimento | Concorrente | R$ |
| Investimento | Plantadeira nova | R$ |
| Investimento | Valor da plantadeira atual | R$ |
| Horizonte | Vida econômica | safras |

## Cálculo

Benefícios por safra:

- **Sobreposição** = área × população × preço da semente ÷ 1000 × sobreposição × redução
- **Taxa variável** = máx(0; área da zona × (população atual − prescrita) × preço da semente ÷ 1000)
- **Compensação em curvas** = área × % em curvas × sc/ha × R$/sc × perda
- **Operação/manutenção** = valor informado
- **Plantabilidade** = receita bruta (área × sc/ha × R$/sc) × recuperação do cenário

Cenários de recuperação por melhor plantabilidade:

| Cenário | Recuperação | Uso recomendado |
|---|---|---|
| Conservador | 0,5% | Apresentação inicial / cliente cético |
| Provável | 1% | Base da negociação |
| Potencial | 2% | Limite superior para sensibilidade |

Indicadores por cenário:

- **Benefício por safra** = soma dos 5 benefícios
- **Payback** = investimento ÷ benefício por safra (safras)
- **ROI anual** = benefício por safra ÷ investimento (como na planilha)
- **Benefício no horizonte** = benefício por safra × vida econômica
- **Retorno líquido** = (benefício no horizonte − investimento) ÷ investimento (o app mostra os dois ROIs)
- Investimento por linha, por ha (1º ano) e por ha/ano (vida econômica)

Sem área, investimento ou vida econômica, os indicadores que dividem por eles aparecem como "–" (a planilha mostra 0).

## Comparativo

- Investimento líquido: retrofit J.Assy, concorrente e plantadeira nova (preço da nova − valor da atual, nunca negativo).
- Para cada um: R$/linha, R$/ha, R$/ha/ano e diferença em relação à J.Assy.
- Indicadores: diferença J.Assy x concorrente (total, por ha e por ha/ano), capital evitado frente à plantadeira nova, payback e benefício no horizonte do cenário provável.

## Exemplo da planilha (testes)

2.000 ha, 66 linhas, 65 sc/ha, R$ 125/sc, 300.000 sementes/ha a R$ 2,50/mil, sobreposição 3% com redução de 85%, zona de 500 ha de 300.000 para 250.000 sementes/ha, 15% em curvas com perda de 0,5%, R$ 20.000 de operação, retrofit R$ 480.000, concorrente R$ 220.000, nova R$ 1.500.000, atual R$ 600.000, 3 safras.

| | Conservador | Provável | Potencial |
|---|---|---|---|
| Benefício por safra | R$ 214.187,50 | R$ 295.437,50 | R$ 457.937,50 |
| Payback | 2,24 safras | 1,62 safra | 1,05 safra |
| ROI anual | 44,6% | 61,5% | 95,4% |
| Benefício em 3 safras | R$ 642.562,50 | R$ 886.312,50 | R$ 1.373.812,50 |

## Pendências

- Usar a perda medida na avaliação de plantio como cenário de plantabilidade (próxima versão).
- Trazer o número de linhas do Configurador quando o vendedor acabou de configurar a máquina.
