# Consultor de Campo

Aplicativo para agrônomos e consultores usarem no campo. Modelo de teste: começa com a **avaliação de plantio** (plantabilidade e dose de fertilizante) e cresce por módulos.

**Abrir no navegador:** https://nicolaszgofa-dot.github.io/consultor_campo/ (atualizado a cada merge na `main`).

## Rodar no computador (modo web)

Requisitos: [Flutter](https://docs.flutter.dev/get-started/install) 3.47 ou mais novo e o Chrome ou o Edge.

```bash
cd app
flutter pub get
flutter run -d chrome
```

Para usar o Edge: `flutter run -d edge`.

## Testes

```bash
cd packages/avaliacao_plantio
flutter test
```

```bash
cd app
flutter test
```

## Organização

| Pasta | Conteúdo |
|---|---|
| `app/` | Aplicativo: tela inicial e navegação entre módulos |
| `packages/avaliacao_plantio/` | Módulo de plantabilidade e fertilizante (cálculo separado da tela, com testes) |
| `packages/configurador/` | Motor de regras do Configurador Técnico J.Assy (Titanium e Selenium Elétric) |
| `docs/configurador/` | Especificação do Configurador e pendências técnicas |
| `packages/roi/` | Cálculo do ROI do retrofit J.Assy (benefícios, payback e comparativo) |
| `docs/roi/` | Especificação do ROI, a partir da planilha da J.Assy |
| `docs/especificacao-calculos.md` | Regras de cálculo e casos de validação |
| `docs/base-conhecimento/` | Base técnica com fontes: plantabilidade, estande, CV, singularização, perdas e emergência |
| `docs/prototipo-web/` | Protótipo HTML das calculadoras (sem Flutter) |

## Revisão por pares

Toda mudança entra por Pull Request com pelo menos uma aprovação. O CI roda análise, testes e gera um build web para o revisor baixar. Veja [CONTRIBUTING.md](CONTRIBUTING.md).

## Próximos módulos (ideias)

- Cadastro de clientes, fazendas e talhões
- Salvar avaliações no aparelho e sincronizar quando houver internet
- Relatório em PDF da avaliação para o cliente (a proposta com o ROI já sai em PDF: `docs/roi/proposta.md`)
- Versão Android para uso no campo
