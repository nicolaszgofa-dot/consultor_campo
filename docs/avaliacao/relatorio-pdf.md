# Relatório da avaliação de plantio (PDF)

Relatório **interno** e técnico da avaliação com trena. Não é para entregar ao cliente: traz todos os números e as leituras brutas.

## Onde gerar

- **Resultado:** botão "Relatório em PDF (sem R\$)".
- **Prejuízo em R\$:** botão no rodapé. Com o preço da saca e da semente preenchidos, o relatório inclui o prejuízo; sem eles, sai sem R\$.

A prévia permite compartilhar ou imprimir. Nada fica salvo no app.

## Conteúdo

1. **Identificação:**
   - cliente, talhão e data;
   - plantadeira e cultura;
   - sementes/m e espaçamento entre linhas;
   - espaçamento ideal e população teórica;
   - produtividade esperada e área.
2. **Aviso de amostra pequena,** quando houver menos de 5 linhas de 10 m.
3. **Resultado geral:**
   - % de plantas no lugar certo, com a faixa verde/falhas/duplas;
   - falhas e duplas (número e %);
   - CV e desvio padrão;
   - espaçamento médio e o ideal;
   - % de espaçamentos aceitáveis;
   - população medida e a teórica;
   - plantas medidas.
4. **Por linha:**
   - metros e plantas;
   - média, DV e CV;
   - % de aceitáveis;
   - falhas, duplas e % no lugar certo.

   A linha com mais falhas fica destacada, com a nota de conferir disco e dosador.
5. **Distribuição dos espaçamentos:** um histograma com faixas de 1/4 do espaçamento ideal, de 0 a 3× o ideal, mais uma faixa "3× ou mais". Os limites de dupla (0,5×) e de falha (1,5×) caem nas bordas das faixas. As cores seguem o app: duplas em azul, aceitáveis em verde, falhas em laranja.
6. **Perda estimada:** sacas/ha, % e kg/ha nos três cenários. O cenário escolhido no app fica destacado, com a fonte científica da cultura.
7. **Prejuízo estimado** (só com os preços):
   - produtividade perdida, sementes desperdiçadas e total por hectare, nos três cenários;
   - o total na área;
   - os preços usados.
8. **Anexo:** as leituras acumuladas da trena, linha a linha.

## Código

- O PDF fica em `app/lib/avaliacao/avaliacao_pdf.dart`, com as funções `gerarAvaliacaoPdf` e `histogramaEspacamentos`.
- A prévia fica em `app/lib/avaliacao/avaliacao_pdf_page.dart`.
- Os testes ficam em `app/test/avaliacao_pdf_test.dart`. Para gravar os exemplos: `PDF_SAIDA=<pasta> flutter test test/avaliacao_pdf_test.dart`.

Fertilizante e emergência ainda não têm relatório.
