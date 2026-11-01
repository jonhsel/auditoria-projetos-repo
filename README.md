# auditoria-projetos

Skill para o [Claude Code](https://claude.com/claude-code) que audita um projeto de software contra um checklist de 111 itens (tráfego, banco, deploy, observabilidade, segurança, recuperação de desastres, operação) e entrega **só o que importa agora**: os 3 itens para resolver hoje, com evidência, correção sugerida e um teste que prova que acabou.

A ideia é não estudar os 111 conceitos. A auditoria roda, separa o grupo "falta e importa agora" e você resolve os três primeiros. A lista completa fica como dicionário para consultar quando algo quebrar.

## Garantia de segurança

- **Relatório primeiro.** A primeira entrega é sempre o relatório, no chat.
- **Somente leitura.** Durante a auditoria a skill não cria, edita, apaga, move nem instala nada no projeto auditado.
- **Nada muda sem permissão.** Ao final ela pergunta o que você autoriza, item a item, e para até receber resposta. Silêncio vale como "não".

## Instalação

### Com npx, direto do GitHub

```bash
npx github:jonhsel/auditoria-projetos-repo            # para todos os projetos (~/.claude/skills)
npx github:jonhsel/auditoria-projetos-repo --projeto  # só para a pasta atual (./.claude/skills)
```

Se a skill já estiver instalada, o instalador pergunta antes de substituir.

### Manualmente

1. Clone este repositório (`git clone https://github.com/jonhsel/auditoria-projetos-repo.git`) ou baixe o zip.
2. Copie a pasta `auditoria-projetos/` (a de dentro, que contém o `SKILL.md`) para:
   - `~/.claude/skills/` para valer em todos os projetos; ou
   - `.claude/skills/` na raiz de um projeto para valer só nele.
3. Reinicie o Claude Code.

## Uso

Dentro de um projeto, no Claude Code:

```
audite este projeto
```

Também funciona com perguntas como "o que falta no meu projeto?" ou "estou pronto para publicar?".

## O que a skill faz

1. Lê README, manifestos, Docker, CI, migrations e configs para entender stack, estágio e uso.
2. Roda `scripts/sinais.sh`, que levanta pistas por busca de texto (segredo no repositório, CORS aberto, SQL montado com texto, ausência de lockfile, CI, backup, health check etc.).
3. Classifica os 111 itens: **JÁ TEM**, **FALTA E IMPORTA AGORA**, **FALTA E IMPORTA DEPOIS**, **NÃO SE APLICA** ou **A CONFIRMAR**.
4. Entrega o relatório curto com os 3 de hoje.
5. Pergunta o que você autoriza corrigir.

## Estrutura

```
auditoria-projetos/
├── SKILL.md                    # método e regras da skill
├── references/
│   ├── checklist.md            # os 111 itens, em 6 blocos, com "o que verificar"
│   └── situacoes.md            # 5 situações recorrentes e onde olhar primeiro
└── scripts/
    └── sinais.sh               # pistas por grep, somente leitura
```

## Limites

- É um mapa de pontos cegos, não uma norma. Não certifica conformidade (LGPD, ISO, PCI); é triagem técnica.
- Não substitui teste de invasão nem revisão de código linha a linha.
- O script de sinais produz pistas, não vereditos: cada achado precisa ser confirmado no código.

## Licença

[MIT](LICENSE) © 2026 Jonh Selmo de Souza do Nascimento
