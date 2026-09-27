#!/usr/bin/env bash
# Roda todos os testes da API oauth e limpa tudo no final.
#
#   1. Testes isolados (unitarios, integracao MockMvc, contrato com Keycloak simulado)
#   2. Sobe/reconstroi a stack (docker compose up -d --build) e espera ficar healthy
#   3. Teste fim a fim contra a API e o Keycloak reais (dados de teste sao excluidos pelo proprio teste)
#   4. Limpeza: remove backend/oauth/target e, se a stack nao estava no ar antes, docker compose down
#
# Nao precisa de Maven/Java na maquina: os testes rodam no container maven:3.9-eclipse-temurin-21.
#
# Uso: ./scripts/run-all-tests.sh [--keep-stack]

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OAUTH_DIR="$ROOT/backend/oauth"
ENV_FILE="$ROOT/.env"
MAVEN_IMAGE="maven:3.9-eclipse-temurin-21"
M2_CACHE="$HOME/.m2"
KEEP_STACK=false
[ "${1:-}" = "--keep-stack" ] && KEEP_STACK=true

# Evita que o Git Bash (Windows) converta caminhos como /app em C:/Program Files/Git/app
export MSYS_NO_PATHCONV=1

step() { printf '\n\033[36m==> %s\033[0m\n' "$1"; }

env_value() {
  local v
  v="$(grep -E "^$1=" "$ENV_FILE" | head -1 | cut -d= -f2-)"
  echo "${v:-$2}"
}

health() {
  docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$1" 2>/dev/null || echo missing
}

wait_healthy() {
  local deadline=$((SECONDS + $2)) c
  for c in $1; do
    until [ "$(health "$c")" = healthy ]; do
      if [ $SECONDS -gt $deadline ]; then
        echo "Timeout esperando '$c' ficar healthy (status: $(health "$c"))"
        return 1
      fi
      sleep 3
    done
    echo "    $c healthy"
  done
}

# Roda Maven num container descartavel e apaga target/ ao final, preservando o exit code.
run_maven() {
  local maven_args="$1"; shift
  docker run --rm "$@" \
    -v "$OAUTH_DIR:/app" -v "$M2_CACHE:/root/.m2" -w /app \
    "$MAVEN_IMAGE" sh -c "mvn -B $maven_args; rc=\$?; rm -rf target; exit \$rc"
}

declare -a NAMES=() CODES=()
record() { NAMES+=("$1"); CODES+=("$2"); }

STACK_WAS_UP=false
[ "$(health oauth)" = healthy ] && STACK_WAS_UP=true

cleanup() {
  step "Limpeza"
  rm -rf "$OAUTH_DIR/target" 2>/dev/null
  echo "    backend/oauth/target removido"
  echo "    usuarios/roles de teste (e2e-*) excluidos do Keycloak pelo proprio teste"
  if $STACK_WAS_UP || $KEEP_STACK; then
    echo "    stack mantida no ar"
  else
    (cd "$ROOT" && docker compose down)
    echo "    stack derrubada (docker compose down)"
  fi
}

main() {
  step "Testes isolados (unitarios + integracao + contrato)"
  run_maven "test"
  record "Testes isolados" $?

  step "Subindo a stack com o codigo atual (docker compose up -d --build)"
  if ! (cd "$ROOT" && docker compose up -d --build); then
    record "Execucao do script" 1; return
  fi
  if ! wait_healthy "keycloak oauth" 240; then
    record "Execucao do script" 1; return
  fi

  step "Teste fim a fim (API + Keycloak reais)"
  local network
  network="$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' oauth)"
  run_maven "test -Pe2e" \
    --network "$network" \
    -e "E2E_BASE_URL=http://oauth:$(env_value OAUTH_INTERNAL_API_PORT 3001)" \
    -e "E2E_KEYCLOAK_URL=http://keycloak:$(env_value KEYCLOAK_INTERNAL_API_PORT 8080)" \
    -e "KEYCLOAK_REALM=$(env_value KEYCLOAK_REALM constrsw)" \
    -e "KEYCLOAK_ADMIN=$(env_value KEYCLOAK_ADMIN admin)" \
    -e "KEYCLOAK_ADMIN_PASSWORD=$(env_value KEYCLOAK_ADMIN_PASSWORD a12345678)"
  record "Teste fim a fim" $?
}

main
cleanup

step "Resumo"
FAILED=0
for i in "${!NAMES[@]}"; do
  if [ "${CODES[$i]}" -eq 0 ]; then
    printf '    \033[32m[OK]\033[0m    %s\n' "${NAMES[$i]}"
  else
    printf '    \033[31m[FALHA]\033[0m %s\n' "${NAMES[$i]}"
    FAILED=1
  fi
done
exit $FAILED
