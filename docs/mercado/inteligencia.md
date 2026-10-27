# Inteligência de mercado

O cartão da tela inicial (antes "Mercado") abre três abas. Todas mostram o alerta "Em conceito": o conteúdo ainda não deve ser usado como certo em negociação. Protótipo: canvas "Inteligência de mercado".

## Cotações

A tela de cotações de soja e milho, sem mudanças (veja [cotacoes.md](cotacoes.md)).

## Concorrência

O vendedor escolhe a linha de produto e o formato.

| Linha | J.Assy | Concorrentes |
|---|---|---|
| Dosadores mecânicos | Titanium | TOPlanting TOP X3, Embreparts Plantsystem |
| Dosadores pneumáticos | Selenium | TOPlanting TOP V, Precision Planting vSet, original Stara, original John Deere |
| Motorização elétrica | Titanium e Selenium Elétric | Mafra Tech, Fortron, Orion, Agrosystem |
| Dosador de esteira | Selenium Neo | John Deere ExactEmerge, TOPlanting V Control |
| Dosadores de adubo | Júpiter | Fertisystem, TOPlanting Duplo Sem Fim |
| Controle de pressão | Level | Precision Planting DeltaForce |

**Ficha de batalha:** tese com um número de destaque; onde ganhamos; onde o concorrente escolhido ataca; objeções e respostas (as que dependem de dado interno levam "Confirmar com a engenharia J.Assy"); prova científica com o cuidado ao usar; perguntas para o produtor; e atalhos para provar com o app (Avaliação, ROI, Configurador). Na motorização, um destaque lembra que a J.Assy vende dosador + motor e os concorrentes vendem só o motor.

**Ficha técnica:** tabela por critério, com a coluna J.Assy em verde. Verde = tem, segundo o fabricante; cinza = não informado pela fonte pública. No celular a tabela rola para o lado.

- Conteúdo em `app/lib/inteligencia/concorrencia_dados.dart`. Fatos dos concorrentes: sites e imprensa (26/10/2026). Provas: [base de conhecimento](../base-conhecimento/dosadores-pesquisas.md).
- O app é público: nenhum preço de anúncio aparece nas fichas. Preços ficam na aba seguinte, informados pela equipe.

## Preços da concorrência

- **Informar preço:** linha de produto, concorrente, preço (aceita ponto de milhar, "2.200"), por linha, unidade, kit ou plantadeira, condição, onde viu, cidade e UF, data, observação e nome de quem informou. Preço e cidade são obrigatórios.
- **Resumo por produto:** média, faixa e número de preços, separado por unidade (kit e linha não se misturam).
- **Lista** do mais recente para o mais antigo, com filtro por linha e opção de remover.
- Os preços ficam salvos no aparelho. Para a equipe toda ver, falta o servidor que recebe os envios (o mesmo pendente para os preços informados das cotações).
