# avaliacao_plantio

Duas avaliações de campo para semeadoras, sem dependências além do Flutter:

- **Plantabilidade**: classifica os espaçamentos entre plantas (aceitável, dupla, falha), calcula CV e população.
- **Fertilizante**: compara as gramas coletadas por linha com o ideal e calcula CV e dose real.

A lógica fica em `*_calc.dart` (Dart puro, sem Flutter); as telas em `*_page.dart`.

## Integração

No `pubspec.yaml` do seu app:

```yaml
dependencies:
  avaliacao_plantio:
    path: ../packages/avaliacao_plantio
```

Abrir as telas:

```dart
import 'package:avaliacao_plantio/avaliacao_plantio.dart';

Navigator.push(context, MaterialPageRoute(builder: (_) => const PlantabilidadePage()));
Navigator.push(context, MaterialPageRoute(builder: (_) => const FertilizantePage()));
```

Ou usar só o cálculo:

```dart
final r = PlantabilidadeCalc.calcular(
  const ParametrosPlantabilidade(sementesPorMetro: 4, espacamentoLinhasM: 0.5),
  [12, 24.4, 36.9],          // leituras acumuladas da trena (cm)
);
print('${r.cvPercentual} ${r.percentualDuplas}');
```

## Regras

| | Regra |
|---|---|
| Espaçamento ideal | `100 / sementes por metro` (cm) |
| Dupla / falha | `< 0,5 × ideal` / `> 1,5 × ideal` (limites são aceitáveis) |
| População | `sementes/m × 10000 / espaçamento entre linhas` |
| Ideal por amostra (g) | `kg/ha × espaçamento (m) × distância (m) / 10` |
| Linha de fertilizante OK | `|g − ideal| ≤ 5% do ideal` |
| Status do fertilizante | `CV < 7%` → Dentro do padrão; senão Atenção |
| Desvio padrão | amostral (n − 1) nas duas avaliações |

## Testes

```bash
flutter test
```
