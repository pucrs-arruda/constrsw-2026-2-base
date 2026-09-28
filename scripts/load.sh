#!/usr/bin/env bash
# Gera volume de tráfego no oauth para os dashboards do Grafana saírem do zero.
#
# Por que este script e não `npm run test:e2e`: o e2e é integração hermética —
# sobe um app Nest em memória (supertest), troca o Keycloak por um mock e usa um
# registry prom-client descartável. Nada disso passa pelo Prometheus, que só
# raspa o container `oauth:8088`. Este script bate no oauth que está no stack,
# na mesma porta que o Prometheus raspa, e reencena as mesmas operações dos
# specs e2e (login ok, senha errada, refresh, /users, /roles, rota inexistente)
# para os painéis de requisições, latência, 4xx/5xx e chamadas ao Keycloak
# (ok/rejected) se moverem de verdade.
#
# Modelo de carga: vários workers concorrentes, cada um com uma requisição em
# voo. A vazão é limitada pela concorrência (--workers) e pelo Keycloak: POST
# /login leva ~90ms, então este mix satura perto de ~100 req/s. --rps impõe um
# teto global exato (token de tempo compartilhado via flock); --rps 0 solta na
# velocidade máxima. Acima de ~16 workers você bate no Keycloak, não no script.
#
# Prometheus raspa a cada 10s e os painéis usam rate(...[5m]); deixe rodar
# por 1-2 minutos para o gráfico encher.
#
# Usage:
#   ./scripts/load.sh                     # 120s, 16 workers, velocidade máxima
#   ./scripts/load.sh --rps 60            # teto exato de 60 req/s
#   ./scripts/load.sh --workers 24        # mais concorrência (até 32)
#   ./scripts/load.sh --duration 0        # até Ctrl-C
#   ./scripts/load.sh --open              # abre os dashboards do Grafana
set -euo pipefail

cd "$(dirname "$0")/.."

OAUTH=http://localhost:8181
PROMETHEUS=http://localhost:9090
GRAFANA=http://localhost:3030
USER=admin@pucrs.br
PASSWORD=a12345678
MISSING_ROLE=loadtest-missing

MAX_WORKERS=24

DURATION=120   # segundos; 0 = indefinido (Ctrl-C)
WORKERS=16     # requisições em voo simultâneas
RPS=0          # teto global de requisições/s; 0 = velocidade máxima
TOKEN_TTL=60   # renova token/sessão do Keycloak a cada N segundos
OPEN=0

usage() {
  sed -n '2,27p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --duration)  DURATION=${2:?};  shift 2 ;;
    --workers)   WORKERS=${2:?};   shift 2 ;;
    --rps)       RPS=${2:?};       shift 2 ;;
    --open)      OPEN=1; shift ;;
    -h|--help)   usage 0 ;;
    *) echo "Opção desconhecida: $1" >&2; usage 1 ;;
  esac
done

for n in "$DURATION" "$WORKERS" "$RPS"; do
  case "$n" in
    ''|*[!0-9]*) echo "Valor numérico inválido: $n" >&2; exit 1 ;;
  esac
done
[ "$WORKERS" -ge 1 ] || { echo "--workers precisa ser >= 1" >&2; exit 1; }
if [ "$WORKERS" -gt "$MAX_WORKERS" ]; then
  echo "Aviso: --workers $WORKERS é alto; ajustado para $MAX_WORKERS (acima disso o Keycloak satura e o host engasga)." >&2
  WORKERS=$MAX_WORKERS
fi

if [ -t 1 ]; then
  bold=$'\033[1m' dim=$'\033[2m' red=$'\033[31m' green=$'\033[32m' reset=$'\033[0m'
else
  bold='' dim='' red='' green='' reset=''
fi

die() { printf '%s%s%s\n' "$red" "$1" "$reset" >&2; exit 1; }

tools=(curl jq awk)
[ "$RPS" -gt 0 ] && tools+=(flock)
for tool in "${tools[@]}"; do
  command -v "$tool" >/dev/null || die "Ferramenta obrigatória ausente: $tool"
done

# Preflight: o oauth precisa estar no ar. É ele que o Prometheus raspa.
if ! curl -fsS --max-time 5 "$OAUTH/health" >/dev/null 2>&1; then
  die "oauth não respondeu em $OAUTH/health.
Suba o stack antes:  docker compose up -d --wait   (ou ./scripts/demo.sh)"
fi

WORK_DIR=$(mktemp -d)
HIT_LOG="$WORK_DIR/hits.tsv"
TOKEN_FILE="$WORK_DIR/token"
JAR="$WORK_DIR/jar"
NEXT_NS_FILE="$WORK_DIR/next_ns"
SLOT_LOCK="$WORK_DIR/slot.lock"
: > "$HIT_LOG"
: > "$NEXT_NS_FILE"

# Intervalo entre requisições (ns) para o teto global de --rps.
INTERVAL_NS=0
[ "$RPS" -gt 0 ] && INTERVAL_NS=$(( 1000000000 / RPS ))

worker_pids=()
keeper_pid=''

cleanup() {
  for pid in "${worker_pids[@]:-}"; do
    [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
  done
  [ -n "$keeper_pid" ] && kill "$keeper_pid" 2>/dev/null || true
  wait 2>/dev/null || true
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT
trap 'exit 130' INT TERM

# Registra uma requisição como "label<TAB>status" (append atômico, O_APPEND).
record() { printf '%s\t%s\n' "$1" "$2" >> "$HIT_LOG"; }

# Teto global exato: cada worker reserva o próximo instante livre sob flock e
# dorme até ele. Sem --rps, não é chamado (velocidade máxima).
acquire_slot() {
  local now next wait_ns
  exec 8>>"$SLOT_LOCK"
  flock 8
  now=$(date +%s%N)
  next=$(cat "$NEXT_NS_FILE" 2>/dev/null || echo 0)
  [ -z "$next" ] && next=0
  [ "$next" -lt "$now" ] && next=$now
  printf '%s' "$(( next + INTERVAL_NS ))" > "$NEXT_NS_FILE"
  flock -u 8
  wait_ns=$(( next - now ))
  if [ "$wait_ns" -gt 0 ]; then
    sleep "$(printf '%d.%06d' $(( wait_ns / 1000000000 )) $(( (wait_ns % 1000000000) / 1000 )))"
  fi
}

# Login completo e troca atômica do token + cookie jar. Chamado no setup e
# periodicamente pelo keeper, para as rotas autenticadas não caírem em 401.
refresh_session() {
  local resp code body
  resp=$(curl -s --max-time 10 -c "$WORK_DIR/jar.tmp" -w '\n%{http_code}' \
    -X POST "$OAUTH/login" -F "username=$USER" -F "password=$PASSWORD" \
    || printf '\n000')
  code=${resp##*$'\n'}
  body=${resp%$'\n'*}
  if [ "$code" = "201" ]; then
    jq -r '.access_token // empty' <<<"$body" > "$WORK_DIR/token.tmp" 2>/dev/null || true
    [ -s "$WORK_DIR/token.tmp" ] || : > "$WORK_DIR/token.tmp"
    mv "$WORK_DIR/token.tmp" "$TOKEN_FILE"
    mv "$WORK_DIR/jar.tmp" "$JAR"
  fi
}

token() { cat "$TOKEN_FILE" 2>/dev/null || true; }

# Cada cenário emite UMA requisição e devolve o status via stdout. São
# exatamente as operações dos specs e2e, para todas as séries existirem.
sc_login_ok() {
  curl -s --max-time 10 -o /dev/null -w '%{http_code}' -X POST "$OAUTH/login" \
    -F "username=$USER" -F "password=$PASSWORD" || printf '000'
}
sc_login_401() {
  curl -s --max-time 10 -o /dev/null -w '%{http_code}' -X POST "$OAUTH/login" \
    -F "username=$USER" -F "password=wrong-password" || printf '000'
}
sc_refresh() {
  curl -s --max-time 10 -o /dev/null -w '%{http_code}' -X POST "$OAUTH/refresh" \
    -b "$JAR" || printf '000'
}
sc_users() {
  curl -s --max-time 10 -o /dev/null -w '%{http_code}' "$OAUTH/users" \
    -H "Authorization: Bearer $(token)" || printf '000'
}
sc_roles() {
  curl -s --max-time 10 -o /dev/null -w '%{http_code}' "$OAUTH/roles" \
    -H "Authorization: Bearer $(token)" || printf '000'
}
sc_roles_404() {
  curl -s --max-time 10 -o /dev/null -w '%{http_code}' "$OAUTH/roles/$MISSING_ROLE" \
    -H "Authorization: Bearer $(token)" || printf '000'
}
sc_health() {
  curl -s --max-time 10 -o /dev/null -w '%{http_code}' "$OAUTH/health" || printf '000'
}

SCENARIOS=(login_ok login_401 refresh users roles roles_404 health)
LABELS=(
  "POST /login (ok)"
  "POST /login (401)"
  "POST /refresh"
  "GET /users"
  "GET /roles"
  "GET /roles/:id (404)"
  "GET /health"
)

# Loop quente: cada worker emite uma requisição por vez. Com --rps, espera o
# seu slot antes de mandar; sem --rps, dispara assim que a anterior volta.
worker() {
  local idx=$(( $1 % ${#SCENARIOS[@]} ))
  local start=$SECONDS code
  while :; do
    if [ "$DURATION" -gt 0 ] && [ $(( SECONDS - start )) -ge "$DURATION" ]; then
      return 0
    fi
    [ "$RPS" -gt 0 ] && acquire_slot
    code=$("sc_${SCENARIOS[$idx]}")
    record "${LABELS[$idx]}" "$code"
    idx=$(( (idx + 1) % ${#SCENARIOS[@]} ))
  done
}

# Mantém token/cookie vivos sem entrar no caminho crítico dos workers.
keeper() {
  while :; do
    refresh_session
    sleep "$TOKEN_TTL"
  done
}

if [ "$RPS" -gt 0 ]; then
  rate_desc="teto exato de ${RPS} req/s"
else
  rate_desc="velocidade máxima (limitado pelo Keycloak)"
fi
printf '%sGerando tráfego em %s%s  (%s workers em voo, %s, %s)\n' \
  "$bold" "$OAUTH" "$reset" "$WORKERS" "$rate_desc" \
  "$([ "$DURATION" -gt 0 ] && echo "${DURATION}s" || echo 'até Ctrl-C')"
printf '%sCenários: login ok/401, refresh, /users, /roles, 404 e /health.%s\n' "$dim" "$reset"
printf '%sPrometheus raspa a cada 10s; painéis usam rate(...[5m]). Dê ~1-2 min.%s\n\n' "$dim" "$reset"

refresh_session
# stdout/stderr dos filhos vão para /dev/null: senão um curl que sobrevive ao
# fim do script segura o pipe de quem chamou (o terminal/prévia fica esperando).
keeper >/dev/null 2>&1 &
keeper_pid=$!

for i in $(seq 1 "$WORKERS"); do
  worker "$i" >/dev/null 2>&1 &
  worker_pids+=("$!")
done
for pid in "${worker_pids[@]}"; do
  wait "$pid" 2>/dev/null || true
done
kill "$keeper_pid" 2>/dev/null || true
keeper_pid=''

# Resumo ----------------------------------------------------------------------
total=$(wc -l < "$HIT_LOG" | tr -d ' ')
if [ "$total" -eq 0 ]; then
  echo "Nenhuma requisição enviada."
  exit 0
fi

elapsed=$DURATION
[ "$elapsed" -gt 0 ] || elapsed=1
printf '\n%sResumo — %s requisições em ~%ss (~%s req/s)%s\n' \
  "$bold" "$total" "$elapsed" "$(( total / elapsed ))" "$reset"
printf '%s\n' "Por operação:"
awk -F'\t' '{c[$1]++} END {for (k in c) printf "  %6d  %s\n", c[k], k}' "$HIT_LOG" | sort -k2
printf '%s\n' "Por status HTTP:"
awk -F'\t' '{c[$2]++} END {for (k in c) printf "  %6d  %s\n", c[k], k}' "$HIT_LOG" | sort -k2

if [ "$OPEN" -eq 1 ]; then
  for url in "$GRAFANA/d/constrsw-oauth" "$GRAFANA/d/constrsw-overview" \
             "$PROMETHEUS/targets"; do
    printf '  → %s\n' "$url"
    if command -v open >/dev/null; then open "$url"
    elif command -v xdg-open >/dev/null; then xdg-open "$url" >/dev/null 2>&1
    fi
  done
fi

printf '\n%sPronto. Os contadores do oauth reiniciam quando o container reinicia;%s\n' "$dim" "$reset"
printf '%sse algum painel ficar reto, rode de novo com --open para conferir.%s\n' "$dim" "$reset"
