/// Origem do alarme, como na "Lista de Alarme" do manual do Selenium.
enum OrigemAlarme {
  sensor('Sensor de sementes'),
  dosador('Dosador'),
  energia('Fonte de energia'),
  ecu('ECU');

  final String nome;

  const OrigemAlarme(this.nome);
}

/// Alarmes do terminal Elétric: texto e descrição do manual de instruções
/// (Selenium, "Lista de Alarme"); urgência e "o que fazer" do treinamento da
/// Linha Elétric. [critico] é o alarme vermelho; os demais são amarelos.
enum TipoAlarme {
  // Sensor de sementes.
  baixaSingulacao(
    OrigemAlarme.sensor,
    'Baixa Singulação',
    'Singulação abaixo do valor de "Singulação Crítica" configurado.',
    'Verificar a pressão de ar e se não há impurezas no disco dosador.',
    critico: true,
    porLinha: true,
  ),
  fimDeSementes(
    OrigemAlarme.sensor,
    'Fim de Sementes ou Entupimento',
    'O sensor não está recebendo sementes no condutor.',
    'Entupimento ou fim da semente: conferir o reservatório e o condutor '
        'da linha.',
    critico: true,
    porLinha: true,
  ),
  sensorAusente(
    OrigemAlarme.sensor,
    'Sensor Ausente',
    'Sensor não reconhecido pelo sistema.',
    'Provável sensor danificado: fazer a substituição.',
    critico: true,
    porLinha: true,
  ),
  cvElevado(
    OrigemAlarme.sensor,
    'CV Elevado',
    'CV acima do parâmetro "CV Máximo" configurado.',
    'Verificar se há dano no condutor (ou algo parecido) e a pressão na '
        'linha de plantio.',
  ),
  excessoDuplos(
    OrigemAlarme.sensor,
    'Excesso de Duplos',
    'Duplos acima do parâmetro "Máximo de Duplos".',
    'Verificar a pressão de ar; se necessário, reduzir a pressão.',
    porLinha: true,
  ),
  excessoFalhas(
    OrigemAlarme.sensor,
    'Excesso de Falhas',
    'Falhas acima do parâmetro "Máximo de Falhas".',
    'Verificar a pressão de ar; se necessário, checar o dosador.',
    porLinha: true,
  ),
  impurezas(
    OrigemAlarme.sensor,
    'Impurezas no Condutor',
    'Sujeira acima do valor configurado ("Porcentagem de Sujeira").',
    'Limpar os condutores com escova de nylon para condutores.',
    porLinha: true,
  ),
  ganhoPopulacao(
    OrigemAlarme.sensor,
    'Ganho de População Ativo',
    'O parâmetro "Ajuste de População" está maior que 1.',
    'Confirmar se o ajuste é intencional em Configurações > Dosagem e '
        'Sensoriamento.',
  ),
  altaTaxa(
    OrigemAlarme.sensor,
    'Alta Taxa de Sementes',
    'Taxa acima da taxa alvo mais a "População Máxima" (%).',
    'Quantidade de sementes maior que a desejada: verificar se a '
        'quantidade indicada está correta e se não há muitos duplos.',
    porLinha: true,
  ),
  baixaTaxa(
    OrigemAlarme.sensor,
    'Baixa Taxa de Sementes',
    'Taxa abaixo da taxa alvo menos a "População Mínima" (%).',
    'Quantidade de sementes menor que a desejada: verificar se a '
        'quantidade indicada está correta.',
    porLinha: true,
  ),
  distribuicaoRuim(
    OrigemAlarme.sensor,
    'Distribuição Sementes Ruim',
    'Distribuição abaixo da "Distribuição Mínima" configurada.',
    'Verificar se há excesso de falhas e duplos e a qualidade dos '
        'condutores das linhas.',
    porLinha: true,
  ),

  // Dosador.
  falhaRotacao(
    OrigemAlarme.dosador,
    'Falha de Rotação no Motor',
    'Motor travado ou disparado.',
    'Fazer a troca do motor.',
    critico: true,
    porLinha: true,
  ),
  falhaComunicacao(
    OrigemAlarme.dosador,
    'Falha na Comunicação',
    'Sem sinal da linha.',
    'Verificar os cabos e a antena de comunicação.',
    critico: true,
    porLinha: true,
  ),
  velocidadeMaxima(
    OrigemAlarme.dosador,
    'Vel. Máxima atingida',
    'Rotação máxima do disco atingida.',
    'Reduzir a velocidade de plantio. Também aparece sem alternador '
        '(direto na bateria) ou com disco incorreto em alguma linha.',
    porLinha: true,
  ),
  velocidadeMinima(
    OrigemAlarme.dosador,
    'Vel. Mínima atingida',
    'Rotação mínima do disco atingida.',
    'Aumentar a velocidade de plantio.',
    porLinha: true,
  ),
  oscilacaoRotacao(
    OrigemAlarme.dosador,
    'Oscilação de Rotação',
    'Rotação real do motor diferente da rotação alvo.',
    'Verificar a linha e substituir o driver.',
    porLinha: true,
  ),
  compensacaoInativa(
    OrigemAlarme.dosador,
    'Compensação C. Inativa',
    'Versão incompatível com a Compensação de Curva.',
    null,
    porLinha: true,
  ),
  altoConsumo(
    OrigemAlarme.dosador,
    'Alto Consumo de Corrente Elétrica',
    'Consumo de corrente alto demais para alimentar as linhas.',
    'Acontece sem alternador, com as linhas ligadas direto na bateria.',
  ),

  // Fonte de energia.
  altaRotacaoAlternador(
    OrigemAlarme.energia,
    'Alta Rotação do Alternador',
    'Rotação acima da "Rotação Máxima" configurada em Energia.',
    'O alternador está com rotação acima da indicada.',
    critico: true,
  ),
  baixaRotacaoAlternador(
    OrigemAlarme.energia,
    'Baixa Rotação do Alternador',
    'Rotação abaixo da "Rotação Mínima" configurada em Energia.',
    'Indica que o alternador está desligado ou lento. Recomendado no '
        'mínimo 3000 RPM.',
    critico: true,
  ),
  alternadorDesligado(
    OrigemAlarme.energia,
    'Alternador desligado - Consumindo Baterias',
    'Alternador sem rotação: as linhas funcionam com a energia da bateria.',
    'Ligar o alternador hidráulico.',
    critico: true,
  ),
  alternadorSemTensao(
    OrigemAlarme.energia,
    'Alternador Sem Tensão',
    'Rotação insuficiente para gerar a tensão adequada.',
    'Não está passando corrente.',
    critico: true,
  ),
  bateriaBaixa(
    OrigemAlarme.energia,
    'Bateria com Baixa Tensão',
    'Tensão da bateria menor que a "Tensão mínima (V)" configurada.',
    null,
    critico: true,
  ),

  // ECU.
  fonteVelocidadeAusente(
    OrigemAlarme.ecu,
    'Fonte de Velocidade Ausente',
    'Sem fonte de velocidade via ISOBUS ou roda.',
    'Sem sinal de GPS: verificar se há sinal do GPS ISOBUS ou do GPS na '
        'ECU J.Assy.',
    critico: true,
  ),
  gpsDegradado(
    OrigemAlarme.ecu,
    'GPS com Sinal Degradado',
    'Sem sinal na antena de GPS da ECU.',
    'Verificar a antena de GPS da ECU J.Assy.',
    critico: true,
  ),
  velocidadeAngular(
    OrigemAlarme.ecu,
    'Vel. Angular Crítica',
    'Velocidade angular na curva maior que "Vel. Angular máx (°/s)".',
    null,
  ),
  taxaZero(
    OrigemAlarme.ecu,
    'Operação com taxa 0 sem/m',
    'Operação sendo feita com taxa de 0 sementes/m.',
    null,
  ),
  curvaMuitoAlta(
    OrigemAlarme.ecu,
    'Vel. em Curva muito Alta',
    'Velocidade em curva muito alta: ao menos um dosador em rotação máxima.',
    null,
  ),
  curvaMuitoBaixa(
    OrigemAlarme.ecu,
    'Vel. em Curva muito Baixa',
    'Velocidade em curva muito baixa: ao menos um dosador em rotação '
        'mínima.',
    null,
  );

  final OrigemAlarme origem;
  final String texto;
  final String descricao;

  /// Indicativo e solução do treinamento; nulo quando o material não traz.
  final String? solucao;
  final bool critico;

  /// No terminal, o texto vem precedido de "Linha XX - ".
  final bool porLinha;

  const TipoAlarme(
    this.origem,
    this.texto,
    this.descricao,
    this.solucao, {
    this.critico = false,
    this.porLinha = false,
  });
}

/// Alarme ativo no terminal.
class Alarme {
  final TipoAlarme tipo;

  /// Linha da plantadeira (0 = linha 1), nos alarmes por linha.
  final int? linha;

  const Alarme(this.tipo, {this.linha});

  bool get critico => tipo.critico;

  /// Texto como aparece na barra de alarmes do terminal.
  String get texto => linha == null
      ? tipo.texto
      : 'Linha ${(linha! + 1).toString().padLeft(2, '0')} - ${tipo.texto}';
}
