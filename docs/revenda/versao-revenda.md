# JA Campo Revenda

Versão do app para as revendas parceiras. O código é o mesmo do app da equipe. A versão é escolhida na compilação, com `--dart-define=PERFIL=revenda` (ver `app/lib/perfil.dart`).

## O que muda

| | Equipe (JA Campo) | Revenda (JA Campo Revenda) |
|---|---|---|
| Avaliação de plantio, Configurador, ROI, Proposta comercial, Conceito, Simulador Elétric | sim | sim |
| Peças de reposição | lista para copiar | **Pedido de peças** |
| Inteligência de mercado, Playbook, Material técnico, Relatórios | sim | não |
| Assistência e garantia | não | sim |
| Regulagem e instalação | não | em breve |
| Treinamento da revenda | não | em breve |

Como a escolha é feita na compilação, o conteúdo só da equipe nem entra no app da revenda. Isso vale, por exemplo, para as fichas de concorrência e os preços da concorrência.

## Funções da revenda

- **Pedido de peças:** a mesma vista explodida e busca de Peças de reposição. A lista vira um pedido: "Copiar pedido" pede a revenda, a cidade e uma observação, e copia o texto para enviar à J.Assy pelo WhatsApp ou e-mail.
- **Assistência e garantia:** formulário com:
  - o tipo (assistência técnica ou garantia);
  - a revenda e o contato;
  - o cliente, a cidade, o produto, a plantadeira, o número de série, quando foi instalado e as linhas com problema;
  - a descrição do problema e o que já foi feito.

  "Copiar chamado" monta o texto para o pós-venda. As fotos seguem na mesma conversa.
- **Regulagem e instalação** e **Treinamento da revenda:** ficam "Em breve" até a J.Assy enviar o material (manuais, passos de regulagem, conteúdo do treinamento).

Nada fica salvo: pedido e chamado existem só enquanto a tela está aberta, como as propostas. Isso vale até haver um servidor.

## Onde baixar

- **Web:** `https://<usuário>.github.io/consultor_campo/revenda/`. É publicada junto com o site da equipe a cada push no `main`.
- **APK:** no GitHub Actions, execução "APK Android", artefato `ja-campo-revenda-<versão>-<commit>`. Tem pacote próprio (`…consultor_campo.revenda`) e o nome "JA Campo Revenda", então pode ser instalado no mesmo celular que o app da equipe.

## A definir

- O WhatsApp ou e-mail do pós-venda e de peças. Hoje o app só copia o texto, e a revenda escolhe para quem mandar.
- O material de Regulagem e instalação e do Treinamento da revenda.
