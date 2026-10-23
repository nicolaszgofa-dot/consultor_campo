import 'package:configurador/configurador.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import 'configurador_estado.dart';
import 'configurador_widgets.dart';

/// Coloca os filhos lado a lado quando há largura; senão, um embaixo do outro.
class _LadoALado extends StatelessWidget {
  static const _larguraMinima = 520.0;

  final List<Widget> filhos;

  const _LadoALado({required this.filhos});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth < _larguraMinima) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < filhos.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                filhos[i],
              ],
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < filhos.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: filhos[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

const _imagens = {
  Tecnologia.titaniumEletric: 'assets/configurador/titanium_eletric.webp',
  Tecnologia.seleniumEletric: 'assets/configurador/selenium_eletric.webp',
};

const _descricoes = {
  Tecnologia.titaniumEletric: 'Dosador mecânico de sementes com motor elétrico',
  Tecnologia.seleniumEletric:
      'Dosador pneumático de sementes com motor elétrico',
};

class EtapaTecnologia extends StatelessWidget {
  final ConfiguradorEstado estado;

  const EtapaTecnologia({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    return _LadoALado(
      filhos: [
        for (final t in Tecnologia.values)
          CartaoOpcao(
            selecionado: estado.tecnologia == t,
            aoTocar: () => estado.escolherTecnologia(t),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Image.asset(
                      _imagens[t]!,
                      fit: BoxFit.contain,
                      semanticLabel: t.nome,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      t.nome,
                      style: const TextStyle(
                        fontFamily: fonteTitulo,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (estado.tecnologia == t) const Etiqueta('Selecionada'),
                  ],
                ),
                Text(
                  _descricoes[t]!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Cores.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

const _iconesTipo = {
  TipoPlantadeira.autotransportavel: Icons.local_shipping_outlined,
  TipoPlantadeira.caixaCentral: Icons.inventory_2_outlined,
  TipoPlantadeira.tandem: Icons.view_week_outlined,
  TipoPlantadeira.solteira: Icons.agriculture_outlined,
};

class EtapaTipo extends StatelessWidget {
  final ConfiguradorEstado estado;

  const EtapaTipo({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    Widget cartao(TipoPlantadeira t) => CartaoOpcao(
      selecionado: estado.tipo == t,
      aoTocar: () => estado.escolherTipo(t),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Cores.neutro,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_iconesTipo[t], size: 30, color: Cores.verdeEscuro),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.nome,
                  style: const TextStyle(
                    fontFamily: fonteTitulo,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                t.secoesSeparadas
                    ? const Etiqueta('Seções separadas')
                    : const Etiqueta(
                        'Seção única',
                        fundo: Cores.neutro,
                        cor: Cores.textoSecundario,
                      ),
              ],
            ),
          ),
        ],
      ),
    );

    final tipos = TipoPlantadeira.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LadoALado(filhos: [cartao(tipos[0]), cartao(tipos[1])]),
        const SizedBox(height: 12),
        _LadoALado(filhos: [cartao(tipos[2]), cartao(tipos[3])]),
      ],
    );
  }
}

class EtapaLinhas extends StatefulWidget {
  final ConfiguradorEstado estado;

  const EtapaLinhas({super.key, required this.estado});

  @override
  State<EtapaLinhas> createState() => _EtapaLinhasState();
}

class _EtapaLinhasState extends State<EtapaLinhas> {
  static const _atalhos = [8, 12, 20, 33, 45, 55];

  late final _campo = TextEditingController(
    text: widget.estado.totalLinhas > 0 ? '${widget.estado.totalLinhas}' : '',
  );

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _definir(int n) {
    widget.estado.definirLinhas(n);
    final texto = n > 0 ? '$n' : '';
    if (_campo.text != texto) _campo.text = texto;
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.estado;
    final total = estado.totalLinhas;
    // Só o bloqueio acima da capacidade aparece; as regras ficam no motor.
    final erro = total > RegrasConfigurador.capacidadeMaxima
        ? estado.bloqueio
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CartaoBranco(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BotaoGrande(
                    icone: Icons.remove,
                    dica: 'Menos uma linha',
                    cheio: false,
                    aoTocar: total > 1 ? () => _definir(total - 1) : null,
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: _campo,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      style: const TextStyle(
                        fontFamily: fonteTitulo,
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        helperText: 'linhas',
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                      ),
                      onChanged: (t) =>
                          widget.estado.definirLinhas(int.tryParse(t) ?? 0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _BotaoGrande(
                    icone: Icons.add,
                    dica: 'Mais uma linha',
                    cheio: true,
                    aoTocar: () => _definir(total + 1),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final n in _atalhos)
                    _Atalho(
                      texto: '$n',
                      ativo: n == total,
                      aoTocar: () => _definir(n),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _BarraDeLinhas(total: total),
            ],
          ),
        ),
        if (erro != null) ...[
          const SizedBox(height: 12),
          Aviso(erro, tipo: TipoAviso.erro),
        ],
      ],
    );
  }
}

class _BotaoGrande extends StatelessWidget {
  final IconData icone;
  final String dica;
  final bool cheio;
  final VoidCallback? aoTocar;

  const _BotaoGrande({
    required this.icone,
    required this.dica,
    required this.cheio,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final ativo = aoTocar != null;
    return Tooltip(
      message: dica,
      child: Material(
        color: cheio && ativo ? Cores.verdeEscuro : Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: ativo ? Cores.verdeEscuro : Cores.borda,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: aoTocar,
          child: SizedBox(
            width: 72,
            height: 72,
            child: Icon(
              icone,
              size: 36,
              color: !ativo
                  ? Cores.cinza
                  : cheio
                  ? Cores.branco
                  : Cores.verdeEscuro,
            ),
          ),
        ),
      ),
    );
  }
}

class _Atalho extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback aoTocar;

  const _Atalho({
    required this.texto,
    required this.ativo,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: ativo,
      button: true,
      child: Material(
        color: ativo ? Cores.verdeEscuro : Cores.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: ativo ? Cores.verdeEscuro : Cores.cinza),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: aoTocar,
          child: SizedBox(
            width: 64,
            height: 44,
            child: Center(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ativo ? Cores.branco : Cores.tinta,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 60 marcas, uma por linha possível; as usadas ficam verdes.
class _BarraDeLinhas extends StatelessWidget {
  final int total;

  const _BarraDeLinhas({required this.total});

  @override
  Widget build(BuildContext context) {
    const maximo = 60;
    return Semantics(
      label: '$total de $maximo linhas possíveis',
      child: ExcludeSemantics(
        child: Column(
          children: [
            for (var fileira = 0; fileira < 2; fileira++) ...[
              if (fileira > 0) const SizedBox(height: 4),
              Row(
                children: [
                  for (var i = 1; i <= 30; i++) ...[
                    if (i > 1) const SizedBox(width: 3),
                    Expanded(
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: fileira * 30 + i <= total
                              ? Cores.verde
                              : Cores.neutro,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EtapaSecoes extends StatelessWidget {
  final ConfiguradorEstado estado;

  const EtapaSecoes({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final secoes = estado.secoes;
    final soma = secoes.fold(0, (s, n) => s + n);
    final erro = estado.bloqueio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CartaoBranco(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(
                    '${secoes.length} ${secoes.length == 1 ? 'seção' : 'seções'}',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: secoes.length > 1
                            ? estado.removerSecao
                            : null,
                        child: const Text('Remover seção'),
                      ),
                      FilledButton.tonal(
                        onPressed: estado.adicionarSecao,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(64, 40),
                          backgroundColor: Cores.verdeClaro,
                          foregroundColor: Cores.verdeTexto,
                        ),
                        child: const Text('+ Seção'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              for (var i = 0; i < secoes.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Cores.neutro)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: corDaSecao(i),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Seção ${i + 1}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Contador(
                        valor: secoes[i],
                        rotulo: 'uma linha na seção ${i + 1}',
                        aoMenos: secoes[i] > 1
                            ? () => estado.mudarSecao(i, -1)
                            : null,
                        aoMais: () => estado.mudarSecao(i, 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RotuloSecao('Vista da barra'),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < secoes.length; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      flex: secoes[i] < 1 ? 1 : secoes[i],
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: corDaSecao(i),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${secoes[i]}',
                          style: const TextStyle(
                            color: Cores.branco,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Soma das seções: $soma de ${estado.totalLinhas} linhas',
                style: const TextStyle(color: Cores.textoSecundario),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (erro == null)
          const Aviso(
            'Seções conferem com o total de linhas.',
            tipo: TipoAviso.ok,
          )
        else
          Aviso(erro, tipo: TipoAviso.erro),
      ],
    );
  }
}

class EtapaAlimentacao extends StatelessWidget {
  final ConfiguradorEstado estado;

  const EtapaAlimentacao({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final entrada = estado.entrada;
    final resultado = estado.resultado;
    final sugestao = RegrasConfigurador.sugestaoComprimentos(entrada);
    final perguntaFrente = RegrasConfigurador.perguntaAlternadorNaFrente(
      entrada,
    );
    final distribuicao = resultado.distribuicao;
    final filhos = <Widget>[];

    if (estado.perguntarAlternador) {
      filhos.add(
        CartaoBranco(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'A máquina terá alternador hidráulico?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Só a solteira de até 12 linhas pode funcionar sem '
                'alternador, ligada direto na bateria.',
                style: TextStyle(color: Cores.textoSecundario),
              ),
              const SizedBox(height: 12),
              SimNao(
                valor: estado.temAlternador,
                aoEscolher: estado.responderAlternador,
              ),
            ],
          ),
        ),
      );
    }

    if (estado.usaAlternador) {
      final alternador = resultado.item(Componentes.alternador);
      filhos.add(
        CartaoBranco(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Cores.verdeClaro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt, color: Cores.verdeTexto),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alternador hidráulico',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${alternador?.motivo ?? ''} 6 saídas, até 10 linhas '
                      'por saída: ${estado.totalLinhas} de '
                      '${RegrasConfigurador.capacidadeMaxima} linhas usadas.',
                      style: const TextStyle(color: Cores.textoSecundario),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      if (perguntaFrente != null) {
        filhos.add(
          CartaoBranco(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  perguntaFrente,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SimNao(
                  valor: estado.alternadorNaFrente,
                  aoEscolher: estado.responderAlternadorNaFrente,
                ),
              ],
            ),
          ),
        );
      }
      filhos.add(
        sugestao == null
            ? const Aviso(
                'Responda à pergunta acima para ver a sugestão de comprimento '
                'do cabo ISOBUS e das mangueiras.',
              )
            : Aviso(
                'Sugestão: cabo ISOBUS ${sugestao.isobus} m e mangueiras '
                '${sugestao.mangueiras} m. '
                '${RegrasConfigurador.observacaoComprimento}',
                tipo: TipoAviso.ok,
              ),
      );
      if (distribuicao != null) {
        filhos.add(_MapaSaidas(distribuicao: distribuicao));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < filhos.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          filhos[i],
        ],
      ],
    );
  }
}

class _MapaSaidas extends StatelessWidget {
  final DistribuicaoSaidas distribuicao;

  const _MapaSaidas({required this.distribuicao});

  @override
  Widget build(BuildContext context) {
    // Seção de cada linha, pela ordem das saídas.
    final secaoDaLinha = <int, int>{};
    for (final s in distribuicao.saidas) {
      var linha = s.primeiraLinha;
      for (var t = 0; t < s.trechos.length; t++) {
        for (var k = 0; k < s.trechos[t]; k++) {
          secaoDaLinha[linha++] = s.secoes[t];
        }
      }
    }
    final secoes = {for (final s in distribuicao.saidas) ...s.secoes}.toList()
      ..sort();
    return CartaoBranco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RotuloSecao('Distribuição das saídas (indicativa)'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            children: [
              for (final s in secoes)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: corDaSecao(s - 1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Seção $s',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Cores.textoSecundario,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final s in distribuicao.saidas)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          'Saída ${s.numero}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        child: ExcludeSemantics(
                          child: Row(
                            children: [
                              for (var k = 0; k < 10; k++) ...[
                                if (k > 0) const SizedBox(width: 3),
                                Expanded(
                                  child: Container(
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: k < s.linhas
                                          ? corDaSecao(
                                              secaoDaLinha[s.primeiraLinha +
                                                      k]! -
                                                  1,
                                            )
                                          : Cores.neutro,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 70, top: 2),
                    child: Text(
                      'Linhas ${s.primeiraLinha}–${s.ultimaLinha} · '
                      '${s.linhas} linhas'
                      '${s.misturaSecoes ? ' · seções ${s.secoes.join(' e ')}' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: s.misturaSecoes
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: s.misturaSecoes
                            ? TipoAviso.atencao.cor
                            : Cores.textoSecundario,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class EtapaAcessorios extends StatelessWidget {
  final ConfiguradorEstado estado;

  const EtapaAcessorios({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    if (estado.tecnologia == Tecnologia.seleniumEletric) {
      return _CartaoPergunta(
        pergunta: 'Qual kit bocal de sementes?',
        child: _ListaOpcoes<BocalSelenium>(
          opcoes: BocalSelenium.values,
          escolhida: estado.bocalSelenium,
          rotulo: (b) => b.nome,
          aoEscolher: estado.escolherBocalSelenium,
        ),
      );
    }
    final pipoqueira = estado.reservatorioPipoqueira;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CartaoPergunta(
          pergunta: 'Terá reservatório de sementes pipoqueira?',
          child: SimNao(
            valor: pipoqueira,
            aoEscolher: estado.responderPipoqueira,
          ),
        ),
        if (pipoqueira == true) ...[
          const SizedBox(height: 12),
          _CartaoPergunta(
            pergunta: 'Qual bocal do reservatório?',
            child: _ListaOpcoes<BocalTitanium>(
              opcoes: BocalTitanium.values,
              escolhida: estado.bocalTitanium,
              rotulo: (b) => b.nome,
              aoEscolher: estado.escolherBocalTitanium,
            ),
          ),
        ],
      ],
    );
  }
}

class _CartaoPergunta extends StatelessWidget {
  final String pergunta;
  final Widget child;

  const _CartaoPergunta({required this.pergunta, required this.child});

  @override
  Widget build(BuildContext context) {
    return CartaoBranco(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            pergunta,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Lista de opções em que só uma pode ser escolhida.
class _ListaOpcoes<T> extends StatelessWidget {
  final List<T> opcoes;
  final T? escolhida;
  final String Function(T) rotulo;
  final ValueChanged<T> aoEscolher;

  const _ListaOpcoes({
    required this.opcoes,
    required this.escolhida,
    required this.rotulo,
    required this.aoEscolher,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final o in opcoes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              selected: o == escolhida,
              button: true,
              child: Material(
                color: o == escolhida ? Cores.verdeClaro : Cores.branco,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: o == escolhida ? Cores.verde : Cores.borda,
                    width: o == escolhida ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => aoEscolher(o),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          o == escolhida
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: o == escolhida
                              ? Cores.verdeTexto
                              : Cores.cinza,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            rotulo(o),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
