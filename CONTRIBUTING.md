# Como contribuir e revisar

Este repositório é um modelo de teste do **Consultor de Campo**. Toda mudança passa por revisão de outra pessoa antes de entrar na `main`.

## Fluxo

1. Crie uma branch a partir da `main`: `git switch -c funcionalidade/nome-curto` (ou `correcao/...`).
2. Faça commits pequenos, com mensagens que digam o que mudou: `Adiciona tolerância de 5% por linha no fertilizante`.
3. Rode localmente antes de enviar:
   ```bash
   cd packages/avaliacao_plantio && flutter test
   cd app && dart analyze && flutter test
   ```
4. Envie a branch e abra um Pull Request. Preencha o modelo: o que muda e como testar.
5. O CI roda análise, testes e gera o build web. Se falhar, corrija na mesma branch.
6. Pelo menos **1 revisor** aprova. Comentários são resolvidos por quem abriu o PR.
7. Quem abriu o PR faz o merge (squash) depois da aprovação.

## Como revisar

- **Números primeiro.** Compare o resultado com a tabela de casos em [docs/especificacao-calculos.md](docs/especificacao-calculos.md). Uma regra agronômica errada é o defeito mais grave.
- **Teste o app.** Baixe o build web na aba *Actions* → execução do PR → *Artifacts* → `consultor-campo-web`, ou rode `flutter run -d chrome` na branch.
- **Leia o código.** A lógica de cálculo fica em `*_calc.dart` (Dart puro, com teste); as telas só exibem.
- **Seja específico.** Comente na linha, diga o que espera e por quê. Use "sugestão" para o que é opcional.

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `app/` | Aplicativo Flutter (web por enquanto; Android/iOS depois) |
| `packages/avaliacao_plantio/` | Módulo de plantabilidade e fertilizante: cálculo, telas e testes |
| `docs/` | Especificação das regras e protótipo web |
