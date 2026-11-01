# Checklist dos 111 itens

Use na etapa 2 da auditoria. Cada linha: número, item, o que verificar no projeto.
Marque **NÃO SE APLICA** quando a arquitetura não tem a peça (ex.: sem Kubernetes, sem filas).

---

## Bloco 1 · Itens 1–19 · Tráfego e conversa entre serviços

Aparece quando mais de uma pessoa usa o app ao mesmo tempo, ou quando o código chama uma API que não é sua.

| # | Item | O que verificar |
|---|---|---|
| 1 | Limite de requisições | Rate limit por usuário/IP, principalmente em login, cadastro e rotas caras |
| 2 | Cache | Consultas e respostas repetidas e caras, com TTL definido |
| 3 | Balanceamento de carga | Mais de uma instância atrás de balanceador; sessão não presa a uma máquina |
| 4 | Proxy reverso | Nginx/Caddy/ingress na frente; o app não fica exposto direto à internet |
| 5 | API gateway | Autenticação, medição e limite centralizados quando há vários serviços |
| 6 | CI/CD | Pipeline que roda testes e publica a cada commit; deploy manual conta como falta |
| 7 | Docker | Dockerfile reproduzível, sem segredo na imagem, sem rodar como root |
| 8 | Kubernetes | Só se houver cluster: réplicas, restart automático, limites de CPU/memória |
| 9 | Descoberta de serviços | Endereços de outros serviços vêm de config/DNS, não de IP fixo no código |
| 10 | Circuit breaker | Chamadas a terceiros param de insistir quando o destino já está falhando |
| 11 | Timeouts | Toda chamada externa (HTTP, banco, fila) tem timeout explícito |
| 12 | Retries | Retry só em falha passageira e operação segura, com limite de tentativas |
| 13 | Backoff exponencial | Espera crescente (com jitter) entre tentativas |
| 14 | Idempotência | Cobrança, criação e webhook com chave de idempotência; a mesma chamada duas vezes não duplica |
| 15 | Filas de mensagens | Trabalho lento (e-mail, relatório, IA) sai da requisição e vai para fila |
| 16 | Pub/Sub | Um evento, vários consumidores, emissor sem conhecê-los (só se há necessidade real) |
| 17 | Arquitetura orientada a eventos | Sistema reage a fatos ocorridos; confira se o acoplamento realmente caiu |
| 18 | Transações distribuídas | Operação que passa por 2+ serviços/bancos acontece inteira ou não acontece |
| 19 | Padrão Saga | Cada passo da operação tem um passo que o desfaz |

---

## Bloco 2 · Itens 20–41 · Fila, banco e duas coisas ao mesmo tempo

O bloco que mais pega quem programa com IA: o código funciona testado sozinho e quebra quando dois usuários chegam juntos.

| # | Item | O que verificar |
|---|---|---|
| 20 | Dead letter queue | Mensagem que falhou várias vezes vai para fila separada, com alerta |
| 21 | Cron jobs | Tarefas agendadas existem, são idempotentes, não rodam duplicadas com várias instâncias, deixam log |
| 22 | WebSockets | Autenticação no handshake, reconexão, limite de conexões por usuário |
| 23 | Long polling | Se usado: timeout e custo por cliente conectado |
| 24 | Server-Sent Events | Alternativa mais simples ao WebSocket quando o fluxo é só servidor → navegador |
| 25 | Índices no banco | Colunas de WHERE, JOIN, ORDER BY e chaves estrangeiras indexadas |
| 26 | Otimização de queries | EXPLAIN nas lentas; sem SELECT * em tabela grande; paginação em listas |
| 27 | Queries N+1 | Consulta dentro de loop; ORM sem eager loading/include; conte consultas por requisição |
| 28 | Pool de conexões | Pool configurado, tamanho coerente com o limite do banco, conexões devolvidas |
| 29 | Réplicas de leitura | Só se a leitura pesa; atenção ao atraso da réplica |
| 30 | Sharding | Raro em projeto pequeno; só quando um banco não aguenta |
| 31 | Particionamento | Tabelas gigantes (logs, eventos) divididas, por exemplo por data |
| 32 | Replicação | Cópias sincronizadas do banco para aguentar queda |
| 33 | Eleição de líder | Onde só uma instância deve executar (cron, consumidor), há quem decida qual |
| 34 | Teorema CAP | Decisão consciente: com a rede partida, o sistema responde ou continua certo? |
| 35 | Consistência eventual | Telas que leem de réplica toleram atraso; fluxo crítico lê do primário |
| 36 | Lock otimista | Coluna version/updated_at ao editar o mesmo registro por vários usuários |
| 37 | Lock pessimista | SELECT ... FOR UPDATE em saldo/estoque, com transações curtas |
| 38 | Locks distribuídos | Entre máquinas, sempre com expiração (TTL); difícil de acertar |
| 39 | Condições de corrida | Ler e depois escrever sem trava (checar estoque, contador, "se não existe, cria"); falta constraint única |
| 40 | Deadlocks | Ordem consistente de travas, transações curtas, retry em deadlock |
| 41 | Vazamento de memória | Memória que só cresce: listeners não removidos, cache sem limite, globais que acumulam |

---

## Bloco 3 · Itens 42–59 · Escalar e publicar sem derrubar

Começa a importar no dia em que publicar uma versão nova passou a dar medo. Quase tudo aqui existe para poder voltar atrás.

| # | Item | O que verificar |
|---|---|---|
| 42 | Coleta de lixo | Pausas e uso de memória; ajuste só com evidência |
| 43 | Thread safety | Estado mutável global ou compartilhado entre requisições/threads |
| 44 | Backpressure | Filas e streams com limite; o produtor desacelera em vez de explodir |
| 45 | Autoscaling | Regras com mínimo e máximo (o máximo protege a conta) |
| 46 | Escala horizontal | App sem estado local: sessão e arquivos fora do disco da máquina |
| 47 | Escala vertical | Máquina maior como saída simples; tem teto |
| 48 | CDN | Imagens, JS, CSS e vídeo servidos por CDN |
| 49 | Cache na borda | Cache-Control correto; respostas públicas guardadas na CDN |
| 50 | Invalidação de cache | Estratégia para quando o dado muda (versão no nome do arquivo, purge, TTL) |
| 51 | Feature flags | Funcionalidade nova atrás de flag, desligável sem publicar código |
| 52 | Deploy blue-green | Duas versões no ar; voltar é virar a chave de novo |
| 53 | Release canário | Versão nova para ~1% dos usuários antes do resto |
| 54 | Rolling deploys | Máquinas trocadas aos poucos, nunca todas de uma vez |
| 55 | Rollbacks | Voltar à versão anterior em um comando, já testado; migrations compatíveis |
| 56 | Health checks | Endereço que diz se o app está vivo |
| 57 | Liveness e readiness | Dois checks distintos: vivo, e pronto para receber tráfego |
| 58 | Monitoramento | Números do sistema olhados de fora, continuamente |
| 59 | Logs | Estruturados, com id para seguir a requisição, sem dado sensível |

---

## Bloco 4 · Itens 60–82 · Enxergar o que está acontecendo, e trancar as portas

Separa quem tem um app no ar de quem tem um app que dá para operar. A metade de segurança não é opcional em momento nenhum.

| # | Item | O que verificar |
|---|---|---|
| 60 | Rastreamento distribuído | Um id só seguindo a requisição por todos os serviços |
| 61 | Métricas | Contagem de chamadas, tempo de resposta, falhas, ao longo do tempo |
| 62 | Alertas | Aviso quando o número passa do limite, com destinatário e procedimento escrito |
| 63 | SLOs | Meta prometida (ex.: 99,9% das chamadas abaixo de 300 ms) |
| 64 | SLIs | O número que mede se a meta está sendo cumprida |
| 65 | Error budgets | Quanto de falha a meta ainda permite no mês; acabou, para de publicar e conserta |
| 66 | Observabilidade | Dá para responder pergunta nova sobre o sistema sem publicar código |
| 67 | Gestão de segredos | Senha e chave fora do código e do repositório (inclusive histórico do git), em cofre |
| 68 | IAM | Quem é quem e o que pode; sempre o mínimo necessário; app sem credencial de administrador |
| 69 | OAuth | Login com provedor externo; confira redirect URIs, state e PKCE |
| 70 | Rotação de JWT | Expiração curta, renovação, segredo forte, algoritmo fixado |
| 71 | TLS | HTTPS forçado, redirecionamento, HSTS, certificado que renova sozinho |
| 72 | Criptografia em repouso | Banco, discos e buckets cifrados; senhas com hash (bcrypt/argon2) |
| 73 | Criptografia em trânsito | Dado cifrado entre navegador e servidor, e também entre seus serviços e o banco |
| 74 | WAF | Filtro na frente do app contra ataque conhecido |
| 75 | Proteção contra DDoS | Proteção na borda e limites contra enxurrada de tráfego |
| 76 | CORS | Origens permitidas explícitas; nada de `*` com credenciais |
| 77 | CSRF | Token anti-CSRF ou cookies SameSite nas ações do usuário logado |
| 78 | SQL injection | Consultas parametrizadas; nunca concatenar texto do usuário na query |
| 79 | XSS | Escape na saída; cuidado com innerHTML/dangerouslySetInnerHTML; CSP |
| 80 | SSRF | URL informada pelo usuário validada (lista permitida; bloquear endereço interno e metadata) |
| 81 | Migrations de banco | Mudanças de estrutura versionadas em arquivo e aplicadas em ordem |
| 82 | Versionamento de schema | Mudar a estrutura sem quebrar a versão do código ainda no ar |

---

## Bloco 5 · Itens 83–101 · Quando dá errado de verdade, e as contas que explicam

Metade é plano para quando cai, metade é vocabulário de rede e desempenho. Leia com atenção depois do primeiro susto.

| # | Item | O que verificar |
|---|---|---|
| 83 | Recuperação de desastres | Plano escrito para a queda de uma região inteira da nuvem |
| 84 | Backups | Cópia dos dados **com restauração já testada**; sem teste, é suposição |
| 85 | Failover | Virada automática para a cópia reserva quando a principal cai |
| 86 | Deploy multirregião | Rodar em mais de uma região ao mesmo tempo (só se o custo se justifica) |
| 87 | Engenharia do caos | Derrubar coisa de propósito para descobrir o que quebra junto |
| 88 | Otimização de custos | Alerta de orçamento ligado; recursos ligados sem uso; tráfego de saída |
| 89 | Cold starts | Primeira chamada após ociosidade é lenta; medir em serverless |
| 90 | Limites do serverless | Teto de tempo, memória e execuções simultâneas da plataforma |
| 91 | Latência | Quanto tempo uma chamada demora, medido |
| 92 | Throughput | Quantas chamadas por segundo aguenta (não é o mesmo que latência) |
| 93 | Latência P99 | Tempo que 99% das chamadas não ultrapassam; a média esconde o problema |
| 94 | Latência de cauda | O 1% lento; em sistema com muitas partes, quase toda chamada encosta nele |
| 95 | Partições de rede | Parte do sistema deixa de enxergar a outra, mas as duas continuam vivas |
| 96 | Clock skew | Relógios desencontrados; use UTC, sincronização e folga na expiração de token |
| 97 | DNS | Cache de DNS como causa de "mas eu já mudei"; reduzir TTL antes de migrar |
| 98 | TCP vs UDP | Um garante entrega e ordem; o outro é rápido e não garante |
| 99 | HTTP/2 e HTTP/3 | Várias coisas pelo mesmo canal, sem fila |
| 100 | gRPC | Chamada binária entre serviços, mais rápida e mais rígida que JSON |
| 101 | Webhooks | O outro sistema chama você; valide assinatura, responda rápido, seja idempotente |

---

## Bloco 6 · Itens 102–111 · Versionar, operar e aprender com o que quebrou

O bloco mais ignorado e o que mais economiza noite perdida. Os três últimos são sobre gente, não sobre código.

| # | Item | O que verificar |
|---|---|---|
| 102 | Versionamento de API | Mudar a API sem quebrar quem usa a versão antiga (`/v1`, política de descontinuação) |
| 103 | Versionamento semântico | maior.menor.correção; o primeiro número subir significa quebra de compatibilidade |
| 104 | Infraestrutura como código | Servidor e banco descritos em arquivo versionado, não clicados no painel |
| 105 | Terraform | Estado remoto com trava; `plan` revisado antes do `apply` |
| 106 | Helm charts | Pacotes de configuração para instalar no Kubernetes sem reescrever tudo |
| 107 | Cache de build | Passo que não mudou não é refeito a cada commit |
| 108 | Inferno de dependências | Lockfile versionado, auditoria de vulnerabilidades, versões conflitantes entre bibliotecas |
| 109 | Incidentes em produção | Procedimento escrito para quando quebra de verdade com usuário sentindo |
| 110 | Plantão | Alguém de sobreaviso, com escala (não depende de um herói) |
| 111 | Postmortems | Documento do que quebrou e por quê, sem caçar culpado, com ações e responsáveis |
