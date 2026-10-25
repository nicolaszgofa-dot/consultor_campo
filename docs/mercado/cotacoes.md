# Mercado: cotações

Preço da saca (R$/sc 60 kg) de soja e milho por praça e por estado. O vendedor vê a cotação da sua região e a dos outros estados, e pode informar um preço que viu. Protótipo: canvas "Mercado – Cotações".

## Tela

- **Produto:** Soja ou Milho.
- **Status:** hora da última atualização. Sem internet, mostra os valores salvos e a hora em que foram recebidos. Aviso quando a cotação mais nova é de antes do último dia útil.
- **Mapa por estado (tablet):** grade com a média Conab do estado, mais escura quanto maior o preço. Tocar abre o estado. No celular, o mapa vira lista (estados com preço primeiro).
- **Referências nacionais:** indicadores Cepea e B3 futuro.
- **Estado:** média Conab da semana, praças com cotação (praça, porto, indicador, informado) e as outras cidades com preço estimado.
- **Cidade:** busca sem acento; o cartão mostra preço, etiqueta de origem e explicação. "Usar como minha região" guarda a cidade no aparelho e o Mercado abre nela.
- **Informar preço:** produto, local, preço, tipo de fonte (cooperativa, trading, cerealista, corretora, revenda, produtor, outro), nome da fonte, data e nome de quem informou (opcional). Fica salvo no aparelho e pode ser removido.

## Preço da cidade

Ordem de prioridade:

1. Cotação da própria cidade: praça ou preço informado (vale o mais recente).
2. Estimado: praças e preços informados até 250 km, média com peso 1/distância² (piso de 10 km). Portos, indicadores e futuro ficam de fora, porque têm outra base de preço.
3. Média Conab do estado.

Cada preço leva a etiqueta da origem: Praça, Porto, Indicador, Informado, Estimado ou Conab UF.

## Atualização

- O app guarda o último feed no aparelho e, ao abrir com internet, busca o novo em `app/assets/cotacoes/cotacoes.json` no GitHub (raw). Trocar esse arquivo na `main` já atualiza os aparelhos, sem novo deploy.
- Sem internet e sem nada salvo, usa a cópia embutida no app.
- Um feed mais antigo que o salvo nunca substitui o salvo.

## Formato do feed

```json
{ "versao": 1, "geradoEm": "2026-10-02T18:05:00-03:00",
  "cotacoes": [
    { "produto": "soja", "tipo": "praca", "uf": "MT", "local": "Sorriso",
      "detalhe": "Ceres", "preco": 139.9, "variacao": -0.14,
      "data": "2026-10-02", "fonte": "Notícias Agrícolas" },
    { "produto": "soja", "tipo": "conab_uf", "uf": "MT", "preco": 142.2,
      "variacao": 0.42, "data": "2026-10-02", "inicio": "2026-09-28",
      "fonte": "Conab" } ] }
```

`tipo`: `praca`, `porto`, `indicador`, `futuro`, `conab_uf`, `informado`. Linha com produto ou tipo desconhecido é ignorada. Toda praça precisa estar na lista de cidades (`packages/cotacoes/lib/src/cidades.dart`), com a posição.

## Fontes e próximos passos

Valores atuais: 02/10/2026. Praças: Notícias Agrícolas. Indicadores: Cepea e B3. Estados: Conab, preço semanal ao produtor.

- Só a Conab é de uso livre. Praças do dia, Cepea e B3 precisam de contrato ou autorização para uso comercial.
- Coletor: um serviço (GitHub Action ou Cloudflare Worker) com um conector por fonte grava o feed nesse formato e guarda as chaves de acesso. No app, muda só `urlFeedCotacoes`.
- Preço informado ainda fica só no aparelho. Para a equipe toda ver, o coletor precisa receber os envios.
