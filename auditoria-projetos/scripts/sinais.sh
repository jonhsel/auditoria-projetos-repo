#!/usr/bin/env bash
# sinais.sh — levanta pistas rápidas para a auditoria. SOMENTE LEITURA.
# Uso: sinais.sh <pasta-do-projeto>
# Saída: linhas "[#item] mensagem". São pistas, não vereditos: confirme no código.
# Nunca imprime o valor de um segredo, só arquivo:linha.

set -u
DIR="${1:-.}"
[ -d "$DIR" ] || { echo "Pasta não encontrada: $DIR" >&2; exit 1; }
cd "$DIR" || exit 1

EXCL=(--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build
      --exclude-dir=.next --exclude-dir=venv --exclude-dir=.venv --exclude-dir=__pycache__
      --exclude-dir=vendor --exclude-dir=coverage --exclude=*.lock --exclude=package-lock.json
      --exclude=*.min.js --exclude=*.map)

# lista só arquivo:linha (sem o conteúdo da linha)
achar() { grep -rIniE "${EXCL[@]}" -e "$1" . 2>/dev/null | cut -d: -f1,2 | head -"${2:-5}"; }
tem()   { find . \( -name node_modules -o -name .git \) -prune -o -iname "$1" -print 2>/dev/null | head -1 | grep -q .; }
rel()   { local n="$1"; shift; while IFS= read -r l; do [ -n "$l" ] && echo "[#$n] $* → $l"; done; }

echo "== Presença de peças =="
tem Dockerfile                 && echo "[#7] Dockerfile encontrado"            || echo "[#7] sem Dockerfile"
{ [ -d .github/workflows ] || tem .gitlab-ci.yml || tem Jenkinsfile || tem azure-pipelines.yml; } \
                               && echo "[#6] CI/CD encontrado"                  || echo "[#6] sem CI/CD detectado"
{ tem package-lock.json || tem yarn.lock || tem pnpm-lock.yaml || tem poetry.lock || tem Pipfile.lock || tem go.sum || tem Cargo.lock || tem uv.lock; } \
                               && echo "[#108] lockfile encontrado"             || echo "[#108] sem lockfile (versões soltas)"
{ [ -d migrations ] || [ -d prisma/migrations ] || [ -d supabase/migrations ] || [ -d alembic ] || [ -d db/migrate ]; } \
                               && echo "[#81] pasta de migrations encontrada"   || echo "[#81] sem pasta de migrations detectada"
{ tem '*.tf'; }                && echo "[#104/#105] Terraform encontrado"       || echo "[#104] sem IaC detectada"
{ tem .env.example || tem .env.sample; } && echo "[#67] .env.example presente"  || echo "[#67] sem .env.example (documente as variáveis, sem valores)"

echo; echo "== Segredos e exposição =="
if [ -d .git ]; then
  git ls-files 2>/dev/null | grep -E '(^|/)\.env($|\.)' | grep -vE 'example|sample' | rel 67 ".env versionado no git"
  grep -qsE '^\.env' .gitignore || echo "[#67] .gitignore não cobre .env"
fi
achar '-----BEGIN [A-Z ]*PRIVATE KEY-----'                    | rel 67 "chave privada no código"
achar 'AKIA[0-9A-Z]{16}'                                      | rel 67 "possível chave AWS"
achar '(sk|rk)_(live|test)_[0-9A-Za-z]{16,}'                  | rel 67 "possível chave de pagamento"
achar "(api[_-]?key|secret|passw(or)?d|token)[\"']?[[:space:]]*[:=][[:space:]]*[\"'][^\"' ]{12,}[\"']" \
                                                              | rel 67 "possível segredo literal"
achar 'Access-Control-Allow-Origin.*\*|origin:[[:space:]]*[\"'\'']\*[\"'\'']|allow_origins=\[[\"'\'']\*' \
                                                              | rel 76 "CORS aberto para qualquer origem"
achar 'verify[[:space:]]*=[[:space:]]*False|rejectUnauthorized:[[:space:]]*false' \
                                                              | rel 71 "verificação TLS desligada"

echo; echo "== Injeção e entrada do usuário =="
achar '(execute|query|raw)\(.*(f"|f'\''|\+[[:space:]]*[a-z_]+|\$\{|%[[:space:]]*\()' \
                                                              | rel 78 "SQL montado com texto (confira parametrização)"
achar 'innerHTML|dangerouslySetInnerHTML|v-html|document\.write\(' \
                                                              | rel 79 "HTML inserido sem escape (confira a origem do dado)"
achar '\beval\(|new Function\(|os\.system\(|shell=True'       | rel 79 "execução dinâmica (confira a origem do dado)"
achar '(requests|axios|fetch|urlopen|http\.get)\(.*(req\.|request\.|params|query|body|input)' \
                                                              | rel 80 "chamada a URL vinda da requisição (SSRF?)"

echo; echo "== Resiliência e operação =="
achar '(rate[_-]?limit|express-rate-limit|slowapi|throttl|django-ratelimit)' 1 | grep -q . \
  && echo "[#1] indício de rate limit" || echo "[#1] nenhum indício de rate limit"
achar '(/health|/healthz|/readyz|/livez|/ping)' 1 | grep -q . \
  && echo "[#56] endpoint de health encontrado" || echo "[#56] nenhum endpoint de health"
achar 'timeout' 1 | grep -q . \
  && echo "[#11] há uso de timeout (confira se cobre todas as chamadas externas)" || echo "[#11] nenhum timeout no código"
achar '(Sentry\.init|sentry_sdk|opentelemetry|prometheus|datadog|newrelic|pino|winston|structlog)' 1 | grep -q . \
  && echo "[#58/#59/#61] indício de logs/monitoramento" || echo "[#58/#59] sem logs estruturados/monitoramento detectados"
achar '(bcrypt|argon2|scrypt|pbkdf2)' 1 | grep -q . \
  && echo "[#72] hash de senha moderno encontrado" || echo "[#72] nenhum hash de senha moderno (se há login, verifique)"
achar '(pg_dump|backup|snapshot)' 1 | grep -q . \
  && echo "[#84] há menção a backup (restauração testada? só você confirma)" || echo "[#84] nenhuma menção a backup no repositório"

echo; echo "== Concorrência e banco =="
achar '(for|while|forEach|map)\b.*\b(await|\.query|\.find|\.get|SELECT)\b' 5 \
                                                              | rel 27 "consulta dentro de laço (N+1?)"
achar '(FOR UPDATE|select_for_update|version|optimisticLock|\$transaction)' 1 | grep -q . \
  && echo "[#36/#37] há indício de controle de concorrência" \
  || echo "[#39] nenhum controle de concorrência detectado (confira leitura-depois-escrita)"
achar '(CREATE INDEX|add_index|@@index|\.index\(|index=True)' 1 | grep -q . \
  && echo "[#25] índices declarados" || echo "[#25] nenhum índice declarado"

echo; echo "Fim. Pistas não são vereditos: confirme cada uma lendo o código."
