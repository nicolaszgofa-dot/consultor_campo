import 'package:avaliacao_plantio/avaliacao_plantio.dart';
import 'package:consultor_campo/avaliacao/avaliacao_estado.dart';
import 'package:consultor_campo/ui/formatos.dart';
import 'package:flutter_test/flutter_test.dart';

const identificacao = Identificacao(
  cultura: Cultura.soja,
  sementesPorMetro: 4,
  espacamentoLinhasM: 0.5,
  produtividadeScHa: 65,
  area: 10,
  unidade: UnidadeArea.alqueirePaulista,
);

void main() {
  group('formatos', () {
    test('número brasileiro', () {
      expect(numeroBr(289560.4, 0), '289.560');
      expect(numeroBr(1234.5), '1.234,5');
      expect(numeroBr(0.25, 2), '0,25');
      expect(reais(21.28), 'R\$ 21,28');
      expect(percentual(87.86), '87,9%');
    });

    test('leitura de número digitado', () {
      expect(lerNumero('0,50'), 0.5);
      expect(lerNumero('0.5'), 0.5);
      expect(lerNumero('1.200,5'), 1200.5);
      expect(lerNumero('R\$ 125,00'), 125);
      expect(lerNumero(''), isNull);
      expect(lerNumero('abc'), isNull);
    });
  });

  group('estado da avaliação', () {
    test('começa com 5 linhas vazias', () {
      final e = AvaliacaoEstado(identificacao);
      expect(e.quantidadeLinhas, 5);
      expect(e.resultado.linhasCompletas, 0);
    });

    test('recusa leitura menor ou igual à anterior', () {
      final e = AvaliacaoEstado(identificacao);
      expect(e.adicionarLeitura(25), isNull);
      expect(e.adicionarLeitura(25), isNotNull);
      expect(e.adicionarLeitura(10), isNotNull);
    });

    test('ao completar 10 m passa para a próxima linha incompleta', () {
      final e = AvaliacaoEstado(identificacao);
      for (var cm = 25.0; cm <= 1000; cm += 25) {
        e.adicionarLeitura(cm);
      }
      expect(e.resultado.linhas.first.completa, isTrue);
      expect(e.linhaAtual, 1);
    });

    test('remover a última leitura', () {
      final e = AvaliacaoEstado(identificacao);
      e.adicionarLeitura(25);
      e.adicionarLeitura(50);
      e.removerUltima();
      expect(e.resultado.linhas.first.plantas, 1);
    });

    test('alqueire paulista em hectares', () {
      expect(identificacao.areaHa, closeTo(24.2, 1e-9));
      expect(identificacao.produtividadeKgHa, 3900);
    });
  });
}
