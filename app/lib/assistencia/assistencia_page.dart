import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../configurador/configurador_widgets.dart';
import '../tema.dart';
import '../ui/componentes.dart';
import 'chamado.dart';

/// App da revenda: monta o chamado de assistência ou garantia e copia o
/// texto para enviar ao pós-venda J.Assy. Nada fica salvo.
class AssistenciaPage extends StatefulWidget {
  const AssistenciaPage({super.key});

  @override
  State<AssistenciaPage> createState() => _AssistenciaPageState();
}

class _AssistenciaPageState extends State<AssistenciaPage> {
  var _tipo = TipoChamado.assistencia;
  String? _produto;
  final _c = <String, TextEditingController>{
    for (final k in const [
      'revenda',
      'contato',
      'cliente',
      'cidade',
      'plantadeira',
      'serie',
      'instalacao',
      'linhas',
      'problema',
      'jaFeito',
    ])
      k: TextEditingController(),
  };
  bool _tentouEnviar = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Chamado get _chamado => Chamado(
    tipo: _tipo,
    revenda: _c['revenda']!.text,
    contato: _c['contato']!.text,
    cliente: _c['cliente']!.text,
    cidade: _c['cidade']!.text,
    produto: _produto ?? '',
    plantadeira: _c['plantadeira']!.text,
    numeroSerie: _c['serie']!.text,
    instalacao: _c['instalacao']!.text,
    linhas: _c['linhas']!.text,
    problema: _c['problema']!.text,
    jaFeito: _c['jaFeito']!.text,
  );

  Future<void> _copiar() async {
    final chamado = _chamado;
    setState(() => _tentouEnviar = true);
    if (!chamado.completo) return;
    await Clipboard.setData(ClipboardData(text: chamado.comoTexto()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Chamado copiado. Envie ao pós-venda J.Assy pelo WhatsApp ou '
          'e-mail, junto com as fotos.',
        ),
      ),
    );
  }

  String? _erro(String campo) =>
      _tentouEnviar && _chamado.faltando.contains(campo) ? 'Obrigatório' : null;

  Widget _campo(
    String chave,
    String rotulo, {
    String? obrigatorio,
    String? dica,
    int linhas = 1,
    TextInputType? teclado,
    TextCapitalization maiusculas = TextCapitalization.sentences,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _c[chave],
        minLines: linhas,
        maxLines: linhas == 1 ? 1 : linhas + 3,
        keyboardType: teclado,
        textCapitalization: maiusculas,
        onChanged: (_) {
          if (_tentouEnviar) setState(() {});
        },
        decoration: InputDecoration(
          labelText: rotulo,
          hintText: dica,
          errorText: obrigatorio == null ? null : _erro(obrigatorio),
          alignLabelWithHint: linhas > 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faltando = _chamado.faltando;
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoFluxo(titulo: 'Assistência e garantia'),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  children: [
                    const Aviso(
                      'Monte o chamado, copie e envie ao pós-venda J.Assy pelo '
                      'WhatsApp ou e-mail, junto com fotos e vídeos do '
                      'problema. Nada fica salvo no app.',
                    ),
                    const SizedBox(height: 14),
                    const RotuloSecao('Tipo de chamado'),
                    const SizedBox(height: 6),
                    Seletor<TipoChamado>(
                      opcoes: TipoChamado.values,
                      selecionada: _tipo,
                      rotulo: (t) => t.nome,
                      aoEscolher: (t) => setState(() => _tipo = t),
                    ),
                    const SizedBox(height: 18),
                    const RotuloSecao('Revenda'),
                    const SizedBox(height: 8),
                    _campo(
                      'revenda',
                      'Revenda',
                      obrigatorio: 'revenda',
                      maiusculas: TextCapitalization.words,
                    ),
                    _campo(
                      'contato',
                      'Contato (nome e telefone)',
                      obrigatorio: 'contato',
                      maiusculas: TextCapitalization.words,
                    ),
                    const SizedBox(height: 6),
                    const RotuloSecao('Cliente e equipamento'),
                    const SizedBox(height: 8),
                    _campo(
                      'cliente',
                      'Cliente (produtor ou fazenda)',
                      obrigatorio: 'cliente',
                      maiusculas: TextCapitalization.words,
                    ),
                    _campo(
                      'cidade',
                      'Cidade – UF',
                      maiusculas: TextCapitalization.words,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                        initialValue: _produto,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Produto',
                          errorText: _erro('produto'),
                        ),
                        items: [
                          for (final p in produtosChamado)
                            DropdownMenuItem(value: p, child: Text(p)),
                        ],
                        onChanged: (p) => setState(() => _produto = p),
                      ),
                    ),
                    _campo(
                      'plantadeira',
                      'Plantadeira (marca e modelo)',
                      maiusculas: TextCapitalization.words,
                    ),
                    _campo('serie', 'Nº de série ou lote (se tiver)'),
                    _campo(
                      'instalacao',
                      'Quando foi instalado',
                      dica: 'Ex.: setembro de 2025',
                    ),
                    _campo(
                      'linhas',
                      'Linhas com problema',
                      dica: 'Ex.: 3 de 24, ou todas',
                    ),
                    const SizedBox(height: 6),
                    const RotuloSecao('O problema'),
                    const SizedBox(height: 8),
                    _campo(
                      'problema',
                      'O que está acontecendo',
                      obrigatorio: 'problema',
                      linhas: 3,
                      dica: 'Sintoma, desde quando, em que condição aparece',
                    ),
                    _campo(
                      'jaFeito',
                      'O que já foi feito (opcional)',
                      linhas: 2,
                      dica: 'Regulagens, trocas de peça, testes',
                    ),
                    const SizedBox(height: 6),
                    if (_tentouEnviar && faltando.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Falta preencher: ${faltando.join(', ')}.',
                          style: const TextStyle(
                            color: Cores.prejuizo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: _copiar,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar chamado'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
