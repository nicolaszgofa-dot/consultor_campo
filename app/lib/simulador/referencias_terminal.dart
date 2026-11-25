import 'package:flutter/material.dart';

import '../tema.dart';
import '../ui/componentes.dart';
import 'alarmes.dart';

const _vermelho = Color(0xFFD32F2F);
const _amarelo = Color(0xFFF2C200);

/// Bolinha de urgência: vermelha (crítico) ou amarela.
class MarcaUrgencia extends StatelessWidget {
  final bool critico;
  final double tamanho;

  const MarcaUrgencia({super.key, required this.critico, this.tamanho = 14});

  @override
  Widget build(BuildContext context) => Container(
    width: tamanho,
    height: tamanho,
    decoration: BoxDecoration(
      color: critico ? _vermelho : _amarelo,
      shape: BoxShape.circle,
    ),
  );
}

/// Lista de alarmes do terminal, por origem, com o que fazer em cada um.
class AlarmesTerminalPage extends StatelessWidget {
  const AlarmesTerminalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoFluxo(titulo: 'Alarmes do terminal'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const Row(
                  children: [
                    MarcaUrgencia(critico: true),
                    SizedBox(width: 6),
                    Text('Crítico'),
                    SizedBox(width: 18),
                    MarcaUrgencia(critico: false),
                    SizedBox(width: 6),
                    Text('Atenção'),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nos alarmes por linha, o terminal mostra "Linha XX - " antes '
                  'do texto.',
                  style: TextStyle(fontSize: 13, color: Cores.textoSecundario),
                ),
                for (final origem in OrigemAlarme.values) ...[
                  const SizedBox(height: 16),
                  RotuloSecao(origem.nome),
                  const SizedBox(height: 6),
                  for (final a in TipoAlarme.values)
                    if (a.origem == origem)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CartaoAlarme(tipo: a),
                      ),
                ],
                const SizedBox(height: 8),
                const Text(
                  'Fonte: manual de instruções do Selenium (Lista de Alarme) e '
                  'treinamento da Linha Elétric.',
                  style: TextStyle(fontSize: 12, color: Cores.textoSecundario),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão de um alarme: texto do terminal, descrição e o que fazer.
class CartaoAlarme extends StatelessWidget {
  final TipoAlarme tipo;

  /// Texto como aparece no terminal (com a linha); padrão: o do catálogo.
  final String? texto;

  const CartaoAlarme({super.key, required this.tipo, this.texto});

  @override
  Widget build(BuildContext context) {
    return CartaoBranco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MarcaUrgencia(critico: tipo.critico),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  texto ?? tipo.texto,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(tipo.descricao, style: const TextStyle(height: 1.35)),
          if (tipo.solucao != null) ...[
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'O que fazer: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Cores.verdeTexto,
                    ),
                  ),
                  TextSpan(text: tipo.solucao),
                ],
              ),
              style: const TextStyle(height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

/// Monitor ISOBUS e o que funciona nele (manual do Selenium,
/// "Compatibilidade"). "Comprado": a função precisa de licença no monitor.
class MonitorCompativel {
  final String fabricante;
  final String modelo;
  final String versao;
  final String terminalVirtual;
  final String taskController;
  final String controleSecao;
  final String taxaVariavel;
  final String maximoSecoes;
  final String multiprodutos;

  const MonitorCompativel(
    this.fabricante,
    this.modelo, {
    required this.versao,
    required this.terminalVirtual,
    required this.taskController,
    required this.controleSecao,
    required this.taxaVariavel,
    required this.maximoSecoes,
    required this.multiprodutos,
  });
}

const _l = 'Liberado';
const _c = 'Comprado';

const monitoresCompativeis = [
  MonitorCompativel(
    'John Deere',
    'GS3',
    versao: '01.00',
    terminalVirtual: _l,
    taskController: _l,
    controleSecao: _c,
    taxaVariavel: _l,
    maximoSecoes: '16',
    multiprodutos: 'Sim, até 6',
  ),
  MonitorCompativel(
    'John Deere',
    'GS4',
    versao: '—',
    terminalVirtual: _l,
    taskController: _l,
    controleSecao: _c,
    taxaVariavel: _l,
    maximoSecoes: '255',
    multiprodutos: 'Sim',
  ),
  MonitorCompativel(
    'CCI',
    'CCI 1200',
    versao: 'CCI.OS 3.3.0 e CCI.OS 2.0.3',
    terminalVirtual: _l,
    taskController: _l,
    controleSecao: _c,
    taxaVariavel: _c,
    maximoSecoes: '—',
    multiprodutos: 'Sim',
  ),
  MonitorCompativel(
    'Topcon',
    'C3000',
    versao: '3.17.707 (AGCO)',
    terminalVirtual: _l,
    taskController: _l,
    controleSecao: _l,
    taxaVariavel: _l,
    maximoSecoes: '32',
    multiprodutos: 'Sim',
  ),
  MonitorCompativel(
    'Case IH',
    'PRO700, PR1200',
    versao: 'V33.2.0.0, BSP V3.3.0.0, 5.12.00.0',
    terminalVirtual: _l,
    taskController: _c,
    controleSecao: _c,
    taxaVariavel: _c,
    maximoSecoes: '48, 128',
    multiprodutos: 'Sim, até 7',
  ),
  MonitorCompativel(
    'Raven',
    'CR7',
    versao: '22.4.0.103',
    terminalVirtual: _l,
    taskController: _c,
    controleSecao: _c,
    taxaVariavel: _c,
    maximoSecoes: '257',
    multiprodutos: 'Sim, com desbloqueio (máximo não especificado)',
  ),
  MonitorCompativel(
    'Trimble',
    'GPX-750',
    versao: '13.00.000.03.4 e 12.40.000.02.4 (Android 6.0.1)',
    terminalVirtual: _l,
    taskController: _c,
    controleSecao: _c,
    taxaVariavel: _c,
    maximoSecoes: '256',
    multiprodutos: 'Sim, até 2',
  ),
  MonitorCompativel(
    'AgLeader',
    'InCommand 1200',
    versao: '8.0 e 5.6',
    terminalVirtual: _l,
    taskController: _l,
    controleSecao: _l,
    taxaVariavel: _l,
    maximoSecoes: '144',
    multiprodutos: 'Sim, até 8 (com desbloqueio)',
  ),
  MonitorCompativel(
    'Hexagon',
    'Ti7 e Ti10',
    versao: '3.27.1',
    terminalVirtual: 'Liberado (Lib. 1)',
    taskController: 'Liberado (Lib. 2)',
    controleSecao: 'Liberado (Lib. 2)',
    taxaVariavel: 'Liberado (Lib. 2)',
    maximoSecoes: '64',
    multiprodutos: 'Sim, até 10 (Liberação 2)',
  ),
];

/// Monitores ISOBUS compatíveis com o Elétric.
class MonitoresCompativeisPage extends StatelessWidget {
  const MonitoresCompativeisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoFluxo(titulo: 'Monitores compatíveis'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const Text(
                  'O Selenium Elétric funciona com os principais monitores '
                  'ISOBUS. "Liberado": a função já vem no monitor. '
                  '"Comprado": a função precisa de licença comprada para o '
                  'monitor.',
                  style: TextStyle(height: 1.4),
                ),
                const SizedBox(height: 12),
                for (final m in monitoresCompativeis)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CartaoMonitor(m: m),
                  ),
                const Text(
                  'Fonte: manual de instruções do Selenium (Compatibilidade).',
                  style: TextStyle(fontSize: 12, color: Cores.textoSecundario),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoMonitor extends StatelessWidget {
  final MonitorCompativel m;

  const _CartaoMonitor({required this.m});

  @override
  Widget build(BuildContext context) {
    Widget funcao(String nome, String valor) {
      final liberado = valor.startsWith(_l);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: liberado ? const Color(0xFFE5F4DC) : const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$nome: $valor',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: liberado ? Cores.verdeTexto : const Color(0xFF7A5A00),
          ),
        ),
      );
    }

    return CartaoBranco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${m.fabricante} ${m.modelo}',
            style: const TextStyle(
              fontFamily: fonteTitulo,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Versão: ${m.versao}',
            style: const TextStyle(fontSize: 13, color: Cores.textoSecundario),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              funcao('Terminal virtual', m.terminalVirtual),
              funcao('Task Controller', m.taskController),
              funcao('Controle de seção', m.controleSecao),
              funcao('Taxa variável', m.taxaVariavel),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Máximo de seções: ${m.maximoSecoes}  ·  Multiprodutos: '
            '${m.multiprodutos}',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
