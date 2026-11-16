import 'dart:convert';
import 'dart:io';

import 'package:configurador/configurador.dart';
import 'package:consultor_campo/configurador/configuracao_pdf.dart';
import 'package:consultor_campo/configurador/configuracao_pdf_page.dart';
import 'package:consultor_campo/roi/proposta/proposta_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

Adaptacao _primeira(Tecnologia t) {
  final marca = adaptacoes[t]!.entries.first;
  return Adaptacao(marca.key, marca.value.first);
}

ResultadoConfiguracao exemploSelenium() => RegrasConfigurador.configurar(
  EntradaConfiguracao(
    tecnologia: Tecnologia.seleniumEletric,
    tipo: TipoPlantadeira.autotransportavel,
    totalLinhas: 36,
    linhasPorSecao: const [12, 12, 12],
    temAlternador: true,
    alternadorNaFrente: true,
    comprimentoIsobus: 11,
    comprimentoMangueiras: 9,
    chicotesPainel: const {4: 2, 9: 4},
    bocalSelenium: BocalSelenium.gravidade,
    kitConversao: false,
    // Adaptação com condutor retrabalhado, para o código aparecer.
    adaptacao: const Adaptacao(
      'John Deere',
      'S-2100 SN abaixo de 99.999 (linha chapa)',
    ),
  ),
);

ResultadoConfiguracao exemploTitanium() => RegrasConfigurador.configurar(
  EntradaConfiguracao(
    tecnologia: Tecnologia.titaniumEletric,
    tipo: TipoPlantadeira.caixaCentral,
    totalLinhas: 26,
    linhasPorSecao: const [13, 13],
    temAlternador: true,
    alternadorNaFrente: false,
    comprimentoIsobus: 14,
    comprimentoMangueiras: 12,
    chicotesPainel: const {9: 2, 14: 2},
    reservatorioPipoqueira: true,
    bocalTitanium: BocalTitanium.pol25e30,
    adaptacao: _primeira(Tecnologia.titaniumEletric),
  ),
);

ResultadoConfiguracao exemploNeo() => RegrasConfigurador.configurar(
  EntradaConfiguracao(
    tecnologia: Tecnologia.seleniumNeo,
    tipo: TipoPlantadeira.solteira,
    totalLinhas: 20,
    linhasPorSecao: const [20],
    bocalNeo: BocalNeo.gravidade,
    comprimentoIsobus: 5,
    comprimentoMangueiras: 6,
    chicotesPainel: const {4: 4},
    velocidadePlantio: 8,
    populacaoSoja: 14,
    populacaoMilho: 3.2,
    adaptacao: _primeira(Tecnologia.seleniumNeo),
  ),
);

int _paginas(List<int> bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length;

void main() {
  test('resumo da máquina traz seções, adaptação e alimentação', () {
    final resumo = Map.fromEntries(
      resumoDaMaquina(exemploSelenium().entrada)
          .map((p) => MapEntry(p.$1, p.$2)),
    );
    expect(resumo['Tecnologia'], 'Selenium Elétric');
    expect(resumo['Linhas'], '36 (12 + 12 + 12)');
    expect(resumo['Alimentação'], 'Alternador, na frente');
    expect(resumo['Kit de conversão'], 'Não');
    expect(resumo.containsKey('Adaptação'), isTrue);

    final neo = Map.fromEntries(
      resumoDaMaquina(exemploNeo().entrada).map((p) => MapEntry(p.$1, p.$2)),
    );
    expect(neo['Linhas'], '20');
    expect(neo.containsKey('Kit de conversão'), isFalse);
    expect(neo['Velocidade'], '8,0 km/h');
  });

  testWidgets('gera o PDF da configuração', (tester) async {
    await tester.runAsync(() async {
      final recursos = await RecursosPdf.carregar();
      for (final (nome, r) in [
        ('selenium', exemploSelenium()),
        ('neo', exemploNeo()),
        ('titanium', exemploTitanium()),
      ]) {
        final bytes = await gerarConfiguracaoPdf(
          resultado: r,
          recursos: recursos,
          identificacao: const IdentificacaoConfiguracao(
            cliente: 'Fazenda Boa Vista',
            local: 'Rio Verde, GO',
            consultor: 'Consultor J.Assy',
          ),
          data: DateTime(2026, 11, 15),
          logoMarca: await carregarLogoMarca(r.entrada.adaptacao!.marca),
        );
        expect(latin1.decode(bytes.take(4).toList()), '%PDF');
        // Para ver o exemplo: PDF_SAIDA=<pasta> flutter test ...
        final saida = Platform.environment['PDF_SAIDA'];
        if (saida != null) {
          File('$saida/configuracao_$nome.pdf').writeAsBytesSync(bytes);
        }
        expect(r.pendentes, isEmpty, reason: nome);
        expect(_paginas(bytes), inInclusiveRange(1, 2), reason: nome);
      }
    });
  });

  test('detalhe da adaptação: condutor, original ou peneira', () {
    expect(
      detalheDaAdaptacao(exemploSelenium().entrada),
      'Leva o condutor de sementes retrabalhado JD1 (20000000608), um por linha.',
    );
    final original = RegrasConfigurador.configurar(
      const EntradaConfiguracao(
        tecnologia: Tecnologia.seleniumEletric,
        tipo: TipoPlantadeira.solteira,
        totalLinhas: 12,
        linhasPorSecao: [12],
        adaptacao: Adaptacao('Stara', 'Princesa'),
      ),
    );
    expect(detalheDaAdaptacao(original.entrada), contains('original'));
    expect(detalheDaAdaptacao(exemploTitanium().entrada), isNull);
  });
}
