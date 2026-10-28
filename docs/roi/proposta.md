# Proposta comercial com o ROI

O vendedor gera a proposta comercial em PDF a partir do ROI: botão **Proposta** no resultado e **Gerar proposta** no comparativo. A proposta e o retorno saem num documento só. Base: os modelos de proposta Titanium e Selenium (Eletric e Motorização) da J.Assy. A proposta também tem um card próprio na tela inicial: `docs/proposta/proposta-comercial.md`.

O código fica em `app/lib/roi/proposta/`. O valor por extenso e a divisão em parcelas ficam em `packages/roi/lib/src/proposta.dart`, com testes.

## O que o vendedor preenche

Nada de preço vem preenchido, porque o app é público. As linhas vêm do ROI. O valor por linha só é sugerido quando o investimento do ROI dividido pelas linhas fecha em centavos.

| Grupo | Campos |
|---|---|
| Produto | Titanium Elétric ou Selenium Elétric; fornecimento (dosador + motorização, ou só motorização / conversão do Selenium G3); plantadeira; linhas; valor por linha; impostos e frete (texto livre, ex.: "+ Difal") |
| Cliente | Nome (obrigatório), CPF/CNPJ, inscrição estadual, telefone, e-mail, cidade da proposta (obrigatória), consultor (obrigatório) e contato |
| Pagamento | Entrada em % e parcelas (% e vencimento). Se preenchidas, precisam somar 100% |
| Demais condições | Validade, prazo e local de entrega, agente financeiro, garantia. Campo vazio não aparece no PDF |

O retorno do PDF recalcula o ROI com **investimento = linhas × valor por linha** e as linhas da proposta. Se esse total for diferente do investimento digitado no ROI, a tela avisa.

## Seções do PDF (A4)

As seções correm uma atrás da outra e quebram de página onde couber (cerca de 4 páginas). O título de cada seção fica junto do primeiro bloco, e os termos ficam junto das assinaturas. O rodapé de todas as páginas traz o aviso de estimativa e o número da página.

1. **Proposta:** logo, cidade e data, cliente, foto e descrição do produto, características, plantadeira, valor por linha, total e total por extenso, e uma chamada para o payback.
2. **Retorno:** curva do ganho acumulado contra o investimento, com o ponto de payback; payback, ROI anual e ganho por ha; rosca com a composição do ganho; barras dos três cenários.
3. **Produto:** prova em destaque e quatro benefícios. Cada benefício mostra seu valor por safra no ROI (plantabilidade, sobreposição, taxa variável, curvas ou operação). Também traz a lista do sistema conforme o fornecimento, o aviso do Controlador de Tarefas e a solução completa.
4. **Condições:** total, linha do tempo do pagamento (a diferença de arredondamento fica na última parcela), condições, instalação, garantia e assinaturas do consultor e do cliente.
5. **Anexo:** comparativo de alternativas (só se concorrente ou plantadeira nova foram preenchidos) e premissas do cálculo.

Os textos do produto vêm dos modelos de proposta e das fichas de batalha, sem citar concorrente. Valor por extenso segue os modelos: "Cento e dez mil e quinhentos reais".

## Pendências

- O card próprio de proposta já existe (`docs/proposta/proposta-comercial.md`); falta puxar do Configurador (produto, plantadeira, linhas e itens).
- Detalhar cultura, velocidade e repetições do ensaio J.Assy usado como prova do Selenium (`docs/base-conhecimento/ensaio-jassy-dosadores.md`).
- No web, a prévia do PDF carrega o leitor de PDF da internet; sem conexão, use o Android.
