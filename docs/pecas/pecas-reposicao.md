# Peças de reposição

Aba da tela inicial para achar o código de uma peça pela vista explodida de cada produto.

## Navegação

1. **Produtos:** os mesmos do configurador. Só o **Selenium Elétric** tem catálogo por enquanto; os outros aparecem como "Em breve".
2. **Conjuntos do produto:** cada um com a miniatura da vista explodida.
   - Corpo do dosador: 18 peças.
   - Disco, condutores e tampa: 22 peças.
   - Motorização Elétric: 4 peças.
3. **Vista explodida e lista de peças:**
   - Tocar num código no desenho destaca a peça e leva a lista até ela.
   - Tocar numa peça da lista destaca o código no desenho e aproxima nele.
   - O desenho amplia com dois dedos; o botão no canto volta ao desenho inteiro.

Pela **busca** no topo dá para procurar por código ou por palavras da descrição, sem precisar de acento ("roseta milho", "feijao", "30000000615"). O resultado abre o conjunto com a peça já destacada.

## Lista de peças

- O botão **+** de cada peça põe a peça na lista, e cada toque a mais soma uma unidade.
- A barra no rodapé abre a lista, onde dá para ajustar as quantidades e **copiar a lista** em texto para colar no WhatsApp ou no e-mail.
- A lista **não é salva**: some ao sair da aba, como nas propostas, até haver servidor.
- O app é público, então a tela não mostra preço nem estoque.

## Como cadastrar um conjunto

Os dados ficam em `app/lib/pecas/pecas_dados.dart`, e as imagens em `app/assets/pecas/`. Cada peça tem:

- o código;
- a descrição;
- o retângulo onde o código aparece na imagem, em pixels da imagem original.

## A confirmar no catálogo

- `30000000639` aparece duas vezes no corpo do dosador: em "Kit entrada de ar traseira" e em "Kit Poliflow".
- `20000000621` aparece duas vezes nos condutores: em "SM4 com furo" e em "SM4 sem furo".
- `20000000639` ("Condutor de semente Selenium retrabalhado") tem o mesmo final de `30000000639`.

O app mostra esses códigos como estão no desenho.
