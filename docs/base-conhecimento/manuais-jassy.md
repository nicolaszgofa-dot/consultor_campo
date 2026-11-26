# Manuais e treinamentos J.Assy

Material oficial da J.Assy usado como fonte do app. Os arquivos ficam fora do repositório, na pasta `CONFIGURADOR/manuais` (alguns PPTs passam de 100 MB). Esta página diz o que cada um cobre e onde já foi usado.

| Arquivo | Produto | O que cobre | Usado em |
|---|---|---|---|
| `Manual_Titanium_Eletric.pdf` | Titanium Elétric | <ul><li>componentes, LED do driver e discos e anéis</li><li>alternador: tabela de RPM por nº de linhas, ligar e desligar, mangueiras</li><li>cabeamento (até 10 linhas por ramo), ECU, antenas e sensor de levante</li><li>terminal virtual, relé, FAQ e alarmes com soluções</li></ul> | Material técnico (módulos 1, 2, 4 e 5) |
| `Treinamento Linha Elétric.pptx` | Linha Elétric | <ul><li>por que a tecnologia, benefícios e composição (motor 24 V, 1,6 A, 72 W, 100 ou 45 RPM)</li><li>chicotes, kit alternador, ECU (2 antenas acima de 29 linhas), mangueiras e dreno</li><li>tela de trabalho, configurações, ativações por monitor e regulagem do desligamento</li><li>resultados e "Como montar um pedido"</li></ul> | Material técnico, Simulador Elétric |
| `Manual_Commander.pdf` | Commander | <ul><li>controlador de seção hidráulica (adubo e semente), 100% ISOBUS e sem fio</li><li>instalação, alternador e terminal virtual (Inspec, Redução, Calibração, Adubo)</li><li>endereçamento, compatibilidade e alarmes</li></ul> | ainda não |
| `Commander_Comercial.pptx` | Commander | Até 16 seções hidráulicas (8 de adubo e 8 de semente), o que a máquina precisa ter e os códigos dos chicotes. | ainda não |
| `Manual_Sensores_Visum.pdf` | Visum | <ul><li>sensor de fluxo de adubo e grãos finos, com monitor próprio (RF 2,4 GHz)</li><li>endereçamento com caneta magnética, instalação no mangote</li><li>funções e soluções de problemas</li></ul> | ainda não |
| `Manual_Titanium.pdf` | Titanium (mecânico) | <ul><li>visor, EscovaFlex, PoliFlows e antipulo</li><li>tabela de discos e anéis, fixação e preparo para o plantio</li><li>manutenção, FAQ (grafite, velocidade, tratamento) e produtos complementares</li></ul> | Material técnico (grafite, no módulo 5) |
| `Discos, Anéis, Titanium e Selenium.pptx` | Discos e dosadores | Discos L-Rampa, RampFlow, Apollo Estrutural e SunFlower; anéis (espessuras) e furos por cultura. | ainda não |
| `Treinamento Jupiter.pptx` e `Guia_Rapido_Jupiter.pdf` | Jupiter (adubo) | <ul><li>as dores do adubo e os benefícios (volumétrico, morros, quebra-pedras)</li><li>montagem do corpo e do cartucho, inversão de rotação, Visum, gaveta</li><li>fusível, limitador de pedra e conferência da taxa de adubo</li></ul> | ainda não |
| `Treinamento_SeleniumPro_VendasPDM (2).pptx` | Selenium Pro | Treinamento de vendas e pós-venda: para quem é, principais concorrentes e quiz. | ainda não |
| `Catalogo de produtos.pdf` | Todos | Catálogo comercial da linha. | ainda não |

O material de 2024 usado no Simulador Elétric (`TREINAMENTO/Manual-Selenium_removed.pdf` e `Treinamento Linha Elétric 2024 (1).pptx`) continua valendo. A apresentação nova da Linha Elétric inclui os mesmos slides.

## Como extrair o texto

- **PDF:** `pdftotext -table -enc UTF-8 arquivo.pdf saida.txt`. O modo `-table` mantém as tabelas em colunas; o `-layout` embaralha algumas.
- **PPTX:** é um zip. O texto fica em `ppt/slides/slideN.xml` (tags `<a:t>`) e as imagens em `ppt/media`. Muitos slides são só imagem.

## O que ainda dá para aproveitar

- **Material técnico, outras linhas:** já há material de instalação e regulagem para Titanium, Commander e Jupiter:
  - instalação passo a passo;
  - ligar o alternador;
  - discos e anéis por cultura;
  - conferência da taxa de adubo do Jupiter.
- **Módulos novos:** Titanium, Jupiter, Commander, Visum e Selenium Pro.
- **Conferir a grafia "Apollo" e "RampFlow"** em `concorrencia_dados.dart`. O PPT de discos escreve "Apollo Estrutural" e "Discos RampFlow"; o manual do Titanium Elétric escreve "Rampflow".
