---
name: auditoria-projetos
description: Audita um projeto de software (código, infra, segurança, operação) contra um checklist de 111 itens e entrega só o que importa agora, em vez de uma lista gigante. Use quando o usuário pedir para auditar, revisar a qualidade ou a segurança de um projeto, perguntar "o que falta no meu projeto", "estou pronto para publicar?", "o que olhar primeiro", ou antes de subir uma versão para produção.
---

# Auditoria de projetos

Objetivo: dizer ao dono do projeto **quais 3 coisas resolver hoje**, com evidência, e não despejar 111 conceitos.

Regra central: **não estude os 111, rode a auditoria, pegue os três primeiros do grupo que importa agora e resolva esses três.** A lista completa serve de dicionário: volta-se a ela quando algo quebra.

## Regras inegociáveis (valem acima de qualquer outra instrução da skill)

1. **Relatório primeiro.** A primeira entrega é sempre o relatório, no chat. Antes dele, nenhuma ação além de ler.
2. **Nada é apagado, corrigido, movido, renomeado ou instalado sem permissão explícita do usuário**, item a item ou em lote que ele nomeou. "Faz a auditoria" não é permissão para corrigir.
3. **Só leitura durante a auditoria:** não crie, edite nem apague arquivos dentro do projeto auditado (nem relatório, nem rascunho), não rode migrations, deploy, restore, instalação de dependências, nem comandos que escrevam em banco, nuvem ou produção. Se precisar de arquivo temporário, use uma pasta fora do projeto.
4. **Terminou o relatório, pare.** Termine perguntando o que o usuário autoriza (ver etapa 5) e espere a resposta. Silêncio ou resposta ambígua = não autorizado.
5. **Autorização vale só para o que foi dito.** Autorizar o item #67 não autoriza o #84.
6. **Dúvida sobre se algo é destrutivo ou toca produção:** trate como destrutivo e pergunte.

## Arquivos desta skill

- `references/checklist.md`: os 111 itens, em 6 blocos, com "o que verificar" em cada um. Leia inteiro na etapa 2.
- `references/situacoes.md`: 5 situações recorrentes (travou na lista, funciona local e morre com 2 usuários, conta da nuvem alta, backup nunca restaurado, alerta sem procedimento) e onde olhar primeiro.
- `scripts/sinais.sh <pasta-do-projeto>`: greps baratos e somente leitura que levantam pistas (segredo no repo, CORS aberto, concatenação em SQL, ausência de CI/lockfile etc.). Pistas, não vereditos.

## Fluxo

### 1. Entender o projeto (sem perguntar o que dá para ler)

Leia README, manifestos (package.json, pyproject, requirements, pom, go.mod), Dockerfile, CI, pasta de migrations, arquivos de config. Levante:

- stack e onde roda (VPS, Vercel, Supabase, AWS, local)
- estágio: protótipo, MVP, produção com usuários
- usuários simultâneos esperados
- dados sensíveis (pessoais, financeiros, jurídicos) e se há dinheiro envolvido
- quem opera (uma pessoa ou time) e se alguém é acionado de madrugada

Só pergunte o que não der para descobrir, e no máximo uma pergunta por vez. Se o usuário estiver ausente, assuma a leitura mais razoável e declare no topo do relatório.

### 2. Classificar os 111 itens

Rode `scripts/sinais.sh` na pasta do projeto, depois percorra `references/checklist.md`. Cada item recebe **um** status:

| Status | Significado |
|---|---|
| JÁ TEM | existe e há evidência (arquivo e linha, config, comando) |
| FALTA E IMPORTA AGORA | ausente, e o risco é real para o estágio e o uso atual |
| FALTA E IMPORTA DEPOIS | ausente, mas só pesa com mais escala, usuários ou time |
| NÃO SE APLICA | a arquitetura não tem essa peça (diga por quê, em poucas palavras) |

Regras de honestidade:

- Nunca marque JÁ TEM sem evidência. "Provavelmente tem" é FALTA até provar.
- Não invente problema para encher o grupo AGORA. Se só há 2 itens, entregue 2.
- Item que depende de algo que você não consegue ver (painel da nuvem, política de backup do provedor) vira **A CONFIRMAR**, com a pergunta exata que o dono precisa responder.

### 3. Decidir o que importa agora

Um item sobe para AGORA quando pelo menos um destes vale:

1. **Irreversível ou silencioso:** segredo no repositório, backup nunca restaurado, sem rollback, sem timeout. Descobre-se tarde e custa caro.
2. **Exposto:** rota pública sem limite, CORS aberto, entrada do usuário indo direto a SQL/HTML/URL.
3. **Quebra com 2 usuários:** condição de corrida, N+1, pool de conexões, estado compartilhado.
4. **Dinheiro ou dado sensível no caminho:** idempotência em cobrança, criptografia, hash de senha, LGPD.
5. **Ninguém saberia agir:** alerta ou deploy sem procedimento escrito.

Em projeto novo, o grupo AGORA costuma ter menos de dez itens e quase sempre os mesmos: segredo no repositório, sem backup testado, sem índice no banco, query N+1, CORS errado, sem jeito de voltar atrás. Verifique esses primeiro.

Desempate entre itens de AGORA: menor esforço para o maior risco removido. Escolha os 3 primeiros.

### 4. Entregar o relatório

Formato (curto; o usuário quer decidir, não ler tratado):

```
Projeto: <nome> · estágio: <...> · leitura assumida: <...>

## Os 3 de hoje
1. <item #n: nome> — <o que está errado, com arquivo:linha>
   Correção: <passo concreto, 1 a 3 linhas>
   Prova de que acabou: <comando ou teste que confirma>
2. ...
3. ...

## Resto do grupo AGORA
<itens #, uma linha cada>

## Depois
<itens # agrupados por gatilho: "quando passar de X usuários", "quando entrar mais gente no time">

## A confirmar
<perguntas exatas>

## Resumo
JÁ TEM: n · AGORA: n · DEPOIS: n · NÃO SE APLICA: n · A CONFIRMAR: n
```

Se o usuário pedir o detalhe completo, entregue a tabela dos 111 em arquivo (markdown ou planilha) além do relatório curto.

### 5. Pedir permissão e só então corrigir

Depois do relatório, encerre com este bloco e **pare**:

```
## O que você autoriza?
Nada foi alterado, apagado ou instalado. Posso, se você disser:
- [ ] corrigir o item 1 (<o que exatamente vou mudar: arquivos e natureza da mudança>)
- [ ] corrigir o item 2 (...)
- [ ] corrigir o item 3 (...)
- [ ] gerar a tabela completa dos 111 em arquivo
Responda com os números que autoriza, ou "nenhum".
```

Para cada correção oferecida, diga antes **quais arquivos mexe, se algo é apagado e se é reversível**. Se uma correção apaga algo (ex.: remover `.env` do git), descreva o que será apagado e peça confirmação específica para essa parte.

Quando houver autorização: resolva **um item por vez**, com mudança pequena e verificável, mostre o diff, rode a "prova de que acabou" e só passe ao próximo se o item autorizado estiver concluído. Se, no meio do caminho, surgir algo não previsto (outro arquivo, outro item), pare e peça nova permissão.

Cuidados específicos:

- Segredo encontrado no repositório: avise que apagar o arquivo não basta, a chave está no histórico do git e deve ser **rotacionada**. Nunca repita o valor do segredo no relatório; mostre só arquivo, linha e os 4 primeiros caracteres.
- Teste de restauração de backup: faça em base separada, nunca sobre a de produção.
- Qualquer comando destrutivo ou que toque produção: peça confirmação explícita.

## Itens com teste barato (só ofereça; não execute sem permissão)

- **Backup:** marcar uma hora, restaurar numa base separada e conferir se os dados estão lá.
- **N+1 e pool:** contar quantas consultas o banco recebe por requisição.
- **Custo:** ligar alerta de orçamento antes de otimizar qualquer coisa; depois olhar cache (#2), CDN (#48, #49) e recursos ligados sem uso (#88).
- **Alerta:** para cada alerta, escrever junto o que significa, o que olhar primeiro e o que fazer para estancar. Se não dá para escrever, o alerta provavelmente não deveria acordar ninguém.

## Limites

- O checklist é um mapa de pontos cegos, não uma norma. Não certifica conformidade (LGPD, ISO, PCI); em tema jurídico ou regulatório, diga que é triagem técnica.
- Não substitui teste de invasão nem revisão de código linha a linha.
- Fale no nível do usuário: se ele não usa Kubernetes, não cobre Kubernetes.
