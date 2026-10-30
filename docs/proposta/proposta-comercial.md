# Proposta comercial (card próprio)

Card **Proposta comercial** na tela inicial. Gera a proposta em PDF com um ou mais produtos, preço de tabela e de campanha, condições de pagamento e, se o vendedor quiser, o retorno do investimento. O PDF reaproveita a proposta do ROI (`docs/roi/proposta.md`).

O código fica em `app/lib/proposta/`. Os textos dos produtos e o PDF ficam em `app/lib/roi/proposta/`.

## Nada é salvo

Decisão de 28/10/2026: nada é registrado nem salvo até existir um servidor. Isso inclui rascunhos, histórico e PDFs.

- O histórico (situações Gerada, Enviada, Aceita, Perdida e Vencida, numeração P-AAAA-NNN) aparece só como conceito, com linhas de exemplo marcadas.
- A proposta fica na memória enquanto o vendedor preenche. Ao sair, o app pergunta "Descartar esta proposta?".
- Na prévia, o PDF é impresso ou compartilhado e depois descartado.

**Motivo:** o app é público, não tem servidor nem login, e guardar no aparelho perderia o histórico ao trocar de celular e deixaria dados pessoais do cliente no aparelho.

## Etapas

1. **Cliente:** nome (obrigatório), CPF/CNPJ, inscrição estadual, telefone, e-mail, cidade da proposta (obrigatória), consultor (obrigatório) e contato.
2. **Itens:** um ou mais produtos: Titanium Elétric, Selenium Elétric, Selenium Neo, Júpiter, Level e Commander. O Commander é cobrado **por seção**; os demais, **por linha**. Cada item tem:
   - fornecimento;
   - plantadeira e linhas;
   - **valor por linha de tabela** e **valor de campanha** opcional.

   Nenhum valor vem preenchido. O total usa o valor de campanha quando houver, e a tela mostra o total sem campanha e a economia do cliente.
3. **Condições:** impostos e frete, entrada e parcelas (precisam somar 100%), validade, prazo, local, agente financeiro e garantia.
4. **Anexos:**
   - páginas dos produtos, ligadas ou desligadas;
   - retorno do investimento: abre o ROI completo já com o total e as linhas da proposta, e precisa pelo menos de área e vida econômica;
   - avaliação de plantio, que fica para a próxima etapa.
5. **Prévia:** o PDF, com imprimir e compartilhar.

## PDF

- **Linhas para o ROI:** por plantadeira, vale a maior quantidade entre os itens cobrados por linha. Titanium e Júpiter na mesma máquina não somam duas vezes, e as seções do Commander não contam.
- **Júpiter, Level e Commander:** página de produto com prova e quatro benefícios (textos das fichas e do site da J.Assy), sem a lista do sistema. O aviso do Controlador de Tarefas aparece para o Commander. A faixa "Solução completa" (dosador + motor) só aparece com Titanium, Selenium ou Neo.

- **Um produto:** capa igual à da proposta do ROI. Com campanha, mostra a condição especial e o valor sem campanha.
- **Vários produtos:** capa com uma linha por item (foto, quantidade, plantadeira, valor por linha e total) e o total da proposta. Com campanha, mostra o total sem campanha e a economia.
- **Retorno e anexo de premissas:** só quando o retorno está ligado. Sem ele, os cartões de benefício não mostram valores do ROI.
- **Páginas de produto:** uma para cada produto diferente. A "Solução completa J.Assy" aparece uma vez, na última.

## Pendências

- Confirmar com a engenharia a lista "O sistema é composto por" do Selenium Neo, montada a partir das fichas.
- Foto do Selenium Neo: hoje o PDF mostra o nome num quadro.
- Lista "O sistema é composto por" de Júpiter, Level e Commander: por decisão do usuário, ainda fora do PDF.
- Confirmar se o Level é cobrado por linha.
- Próxima etapa: anexo da avaliação de plantio; entrada pelo Configurador.
- Servidor: histórico, situações, numeração, versões e duplicar.
