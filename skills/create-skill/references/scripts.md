# Scripts, verificação e edição

Leia ao **criar ou alterar** scripts de uma skill, ao **mover** um script de
lugar, ou ao **verificar** se um refactor não quebrou nada. São regras de
autoria — o inventário e a deduplicação da biblioteca ficam no
`skills-management`.

## Scripts executáveis por agente

- Sem prompt interativo sem bypass (`--yes`/env): agente trava em `read -p`.
- Saia com código diferente de zero em falha — validador que sempre sai 0
  esconde quebra real de quem chama por cron.
- Monte comandos de shell como **array**, não string interpolada: caminho de
  usuário traz espaço e acento que quebram expansão sem aspas.
- Quando o script ganha flag ou muda uso, atualize as linhas de uso no `SKILL.md`
  e os ponteiros em `references/` **no mesmo lote** — uso obsoleto roteia o
  agente para flag que não existe mais.
- Skill sem `scripts/` ainda precisa de fluxo executável: descreva a execução
  conversacional (que consultas rodar, que julgamento aplicar, como é a saída) e
  **nunca** documente comando fantasma tipo `./skill` que não aponta para nada.
- Quando scripts irmãos copiam o mesmo parser ou formatador, extraia um módulo
  compartilhado **da skill base** (import por caminho relativo entre irmãos, para
  as cópias seguirem funcionando) e re-rode um comando real por consumidor,
  comparando antes/depois — a contagem tem de bater exatamente com a ferramenta
  autoritativa.

## Documentação vs implementação

- Quando a doc descreve flag ou subcomando que a implementação não tem, **corte a
  doc para a realidade** por padrão. Implementar a superfície que falta é feature
  nova, com risco próprio (ex.: um `--apply` de reconciliação escreve no razão) e
  precisa de aprovação separada. Nunca deixe um comando documentado que falha.

## Verificação (o passo que costuma ser pulado)

- Verifique a **saída** contra a fonte autoritativa, não só o código de saída:
  `exit 0` com zeros ou vazios é a forma de falha mais comum (include não
  parseado, filtro de sinal invertido). Confirme um número real contra o
  relatório da própria ferramenta antes de confiar em qualquer refactor.
- O mesmo vale para busca com **zero resultados**: lista vazia não é prova de
  ausência. Antes de declarar um arquivo, skill ou símbolo como não referenciado
  (ou seguro de apagar), re-rode o check por um segundo método — caminhada
  decodificada, outra ferramenta, revisão explícita — e confirme o mesmo zero,
  porque uma busca que não casa nada em silêncio (escopo errado, encoding não
  decodificado, forma de caminho que a ferramenta rejeita) inverte a recomendação
  de manter para apagar.

## Mover ou editar um script

- Ao mover um script, conserte as suposições de profundidade que ele carrega
  (`Path(__file__).parent*N`, nomes relativos ao CWD) — elas codificam a posição
  antiga e resolvem para o diretório errado em silêncio depois da mudança.
  Resolva a raiz do projeto por env-com-fallback-de-CWD e re-rode a partir do
  diretório de trabalho real, confirmando comportamento idêntico ao de antes.
- Prefira `patch` para edição pequena de `SKILL.md`: o `write_file` recusa a
  sobrescrita depois de qualquer leitura paginada, então cada edição pequena
  custa uma releitura inteira.
