# Desligamento de linha

Ferramenta de campo do Material técnico, igual nos apps da equipe e da revenda. Ajuda a configurar o corte de seção (desligamento linha a linha) da Linha Elétric em três abas. Nada fica salvo.

Para abrir: Material técnico > Ferramentas de campo > Desligamento de linha, ou o atalho na aula "Regulagem do liga e desliga" do módulo 7 (Capacitação).

## Monitor

Você escolhe um dos 9 monitores compatíveis (a mesma lista do simulador). Para cada um, a ferramenta mostra:

- **Selo de origem:**
  - **"Conferido no tutorial J.Assy":** GS3, C3000, Pro 700/1200, CR7, GFX 750, InCommand 1200 e Hexagon.
  - **"Conferido no manual do fabricante":** GS4.
  - **"Confira no manual do monitor":** CCI 1200, que ainda não tem tutorial.
- **Licenças:** o que comprar e o que já vem liberado.
- **Passo a passo:** onde fica o corte de seção, com as recomendações da J.Assy.
- **Ajuste fino:** o nome do campo de ligar e o de desligar, em segundos ou em metros.
- **Vídeo:** o botão "Ver o tutorial em vídeo", que abre o tutorial J.Assy no YouTube.

Depois vem a lista do que conferir antes de ir ao campo:
- ativações;
- terminador ISOBUS;
- medidas do implemento;
- sinal de GPS;
- linhas endereçadas.

| Monitor | Licença para o corte | Ajuste fino (ligar / desligar) | Unidade |
|---|---|---|---|
| John Deere GS3 | Controle de seção | Ligar / Desligar (atraso) | s |
| John Deere GS4 | Controle de seção | Retardo mecânico Ligado / Desligado | s |
| Topcon C3000 | Controle automático de seção (até 32) | Tempo de atividade / Tempo de inatividade | s |
| Case Pro 700 | Task Controller (até 48) | Atraso do produto | s |
| Case Pro 1200 | De fábrica + Controlador de tarefas | Atraso iniciar / Atraso interromper (com Calibrar) | s |
| Raven CR7 | Controlador de tarefas | Olhar adiante para ligar / desligar | s |
| Trimble GFX 750 | Task Controller (até 256, por QR Code) | Latência ligada / desligada | s |
| Ag Leader InCommand 1200 | ISOBUS | Antecipação Ligar / Desligar | m |
| Hexagon Ti7/Ti10 | TC e VT | Antecipação de entrada / de saída | m |

Recomendações dos tutoriais para a sobreposição:
- **Hexagon:** 50%.
- **InCommand:** 50 a 70%.
- **Pro 1200 e GFX 750:** não usar 99%, porque o corte fica muito sensível.
- **Hexagon:** deixe "Sempre sobrepor" desligado.
- **InCommand:** deixe desmarcados os atrasos de seção vindos da ECU, porque o ajuste é feito no monitor.

## Geometria

São as medidas para o terminal J.Assy (Configurações > Implemento), nos três tipos do manual do Titanium Elétric:

- **Encontradas:** linhas, espaçamento, engate-roda e roda-saída.
- **Desencontradas:** o mesmo, com saída curta e saída longa, e se a linha 1 é curta ou longa.
- **Personalizadas:** você toca nas linhas do desenho para marcar quais são longas.

O desenho mostra a plantadeira vista de cima com as cotas, e o resultado vem pronto para digitar no terminal, com a largura de trabalho. Nos tutoriais, os monitores puxam essas medidas do terminal J.Assy sozinhos; a posição da antena GPS no trator é configurada no próprio monitor.

## No campo

O técnico informa o que viu no chão:

| | Regulagem | No chão | O comando precisa vir |
|---|---|---|---|
| Desligou antes | adiantada | falha | mais tarde |
| Desligou depois | atrasada | sobreposição | mais cedo |
| Ligou antes | adiantada | sobreposição | mais tarde |
| Ligou depois | atrasada | falha | mais cedo |

A correção em tempo é **distância medida ÷ velocidade** (km/h ÷ 3,6). Exemplo: 1 m a 7,2 km/h = 0,5 s.

Com o monitor escolhido na aba Monitor, a ferramenta diz o campo exato, por exemplo: Aumente "Latência desligada" em 0,50 s.

- Nos ajustes de tempo, valor maior manda o comando mais cedo.
- Nos de distância (InCommand e Hexagon), a correção é a própria distância medida.
- No Hexagon, a saída é o contrário: valor maior desliga mais tarde, então a ferramenta inverte o sentido.

Com o valor atual, ela já dá o novo, que nunca fica abaixo de zero. Sem monitor escolhido, a resposta vem em segundos e em metros.

## Fontes

- **Tutoriais J.Assy** no YouTube, playlist [Monitores ISOBUS](https://www.youtube.com/playlist?list=PL_ya3TnusvURcXwA5VPsZpmBsxidQGwC9). Lidos pela transcrição:
  - [GS3](https://www.youtube.com/watch?v=OIZF7UgBhIk);
  - [Pro 700](https://www.youtube.com/watch?v=XfvS9gRLkL8);
  - [Pro 1200](https://www.youtube.com/watch?v=Ax1rRUE6AwQ);
  - [C3000](https://www.youtube.com/watch?v=1sMy4I6cnHc);
  - [CR7](https://www.youtube.com/watch?v=WXhLNXwpL-w);
  - [GFX 750](https://www.youtube.com/watch?v=po5IVsjCkRg);
  - [InCommand 1200](https://www.youtube.com/watch?v=V7r-_KhTvn8);
  - [Hexagon Ti10](https://www.youtube.com/watch?v=tBoc9WMMJYM).
- **Treinamento Linha Elétric:** ativações por monitor e regulagem adiantada e atrasada.
- **Manual do Titanium Elétric:** tipos de implemento e "regular os tempos de sobreposição e saltos conferindo no solo".
- **Manual do Selenium:** compatibilidade.
- **John Deere Geração 4** (ajuda on-line do 4640): [Retardo mecânico](https://displaysimulator.deere.com/onscreen_help/4640/current/en/seedstar/impl_profile_mechanical_delay.htm), de 0,10 a 15 s, com o Ajuste de desempenho.
- **John Deere** ([perfil de implemento](https://displaysimulator.deere.com/onscreen_help/S7combine/current/en/implement_profiles/implement_profiles_mechanical_delay.htm)): para plantadeiras, 0,5 a 1,0 s para ligar e 0,3 s para desligar, como valor de partida.

## A confirmar

- **CCI 1200:** onde fica o ajuste fino. Ainda não há tutorial.
- **Pro 700:** os nomes exatos das distâncias em metros do menu Sobreposição, porque a transcrição ficou incompleta nesse trecho.
- **Tempos de partida para o Elétric:** hoje a ferramenta só mostra a referência da John Deere.
- **Se a ECU J.Assy informa os atrasos ao monitor:** o InCommand tem a opção de usar os atrasos vindos da ECU, mas o tutorial deixa desmarcada.

## Código

- Dados e cálculos: `app/lib/desligamento/desligamento_dados.dart`.
- Tela: `desligamento_page.dart`.
- Desenho: `desenho_geometria.dart`.
- Testes: `app/test/desligamento_test.dart`.
