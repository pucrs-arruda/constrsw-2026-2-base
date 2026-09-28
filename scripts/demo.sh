#!/usr/bin/env bash
# Guided walkthrough of the local stack, for presentations.
#
# Brings the stack up, then goes through Keycloak, login, Swagger, /metrics,
# Prometheus and Grafana. Each step opens with a banner saying what is about to
# happen and waits for Enter before doing it. From the login step on, a
# background loop sends traffic to oauth so the graphs move. It stops when the
# script exits.
#
# Usage: ./scripts/demo.sh
set -euo pipefail

cd "$(dirname "$0")/.."

OAUTH=http://localhost:8181
KEYCLOAK_MANAGEMENT=http://localhost:9001
PROMETHEUS=http://localhost:9090
GRAFANA=http://localhost:3030
DEMO_USER=admin@pucrs.br
DEMO_PASSWORD=a12345678

# User and role created in the Swagger examples. Unique per run: deletes are
# logical, so a name from an earlier run still exists and would get a 409.
DEMO_SUFFIX=$(date +%H%M%S)
NEW_USER="aluno.$DEMO_SUFFIX@pucrs.br"
NEW_ROLE="monitor-$DEMO_SUFFIX"

# Same four panels as the README link: targets up, requests/s, p95 latency and
# oauth → Keycloak calls by result.
PROMETHEUS_QUERIES="$PROMETHEUS/query?g0.expr=up%7Bjob%3D~%22oauth%7Ckeycloak%22%7D&g0.tab=table&g0.range_input=1h&g1.expr=sum%20by%20%28uri%2C%20status%29%20%28rate%28http_server_requests_seconds_count%7Bjob%3D%22oauth%22%7D%5B5m%5D%29%29&g1.tab=graph&g1.range_input=1h&g2.expr=histogram_quantile%280.95%2C%20sum%20by%20%28le%2C%20uri%29%20%28rate%28http_server_requests_seconds_bucket%7Bjob%3D%22oauth%22%7D%5B5m%5D%29%29%29&g2.tab=graph&g2.range_input=1h&g3.expr=sum%20by%20%28operation%2C%20result%29%20%28rate%28oauth_keycloak_request_duration_seconds_count%5B5m%5D%29%29&g3.tab=graph&g3.range_input=1h"

if [ -t 1 ]; then
  bold=$'\033[1m' dim=$'\033[2m' red=$'\033[31m' reset=$'\033[0m'
  banner_style=$'\033[1;97;44m' banner_fill=' '
else
  bold='' dim='' red='' reset=''
  banner_style='' banner_fill='='
fi

# Full-width banner announcing the next step, then waits for Enter to run it.
# Keep titles ASCII: the padding counts bytes, not characters.
step() {
  local title width edge
  title="  $(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')"
  shift
  width=$(tput cols 2>/dev/null || echo 80)
  [ "$width" -le 80 ] || width=80
  edge=$(printf '%*s' "$width" '' | tr ' ' "$banner_fill")

  printf '\n\n%s%s%s\n' "$banner_style" "$edge" "$reset"
  printf '%s%-*s%s\n' "$banner_style" "$width" "$title" "$reset"
  printf '%s%s%s\n\n' "$banner_style" "$edge" "$reset"
  printf '%s\n' "$@"
  echo
  read -rp "${dim}↵ Enter to go${reset} " _
  echo
}

# Prints the command before running it, so the audience sees what happens.
run() {
  printf '%s$ %s%s\n' "$dim" "$*" "$reset"
  "$@"
}

section() {
  printf '\n%s%s%s\n' "$bold" "$1" "$reset"
}

# One numbered Swagger example: method and path, the request body if there is
# one, and what to point out in the response.
example_count=0
example() {
  example_count=$((example_count + 1))
  printf '%3d. %s%-6s %s%s\n' "$example_count" "$bold" "$1" "$2" "$reset"
  [ -z "$3" ] || printf '     %s\n' "$3"
  printf '     %s→ %s%s\n' "$dim" "$4" "$reset"
}

open_url() {
  printf '  → %s\n' "$1"
  if command -v open >/dev/null; then
    open "$1"
  elif command -v xdg-open >/dev/null; then
    xdg-open "$1" >/dev/null 2>&1
  fi
}

die() {
  printf '%s%s%s\n' "$red" "$1" "$reset" >&2
  exit 1
}

login() {
  curl -s --max-time 10 -X POST "$OAUTH/login" -F "username=$1" -F "password=$2" "${@:3}"
}

# One round of oauth traffic per second: a login, /users, /roles and a login
# with a wrong password (401). Skips /health and /metrics, which the metrics
# interceptor doesn't count.
send_traffic() {
  local token
  while true; do
    token=$(login "$DEMO_USER" "$DEMO_PASSWORD" | jq -r '.access_token // empty' 2>/dev/null) || true
    curl -s --max-time 10 -o /dev/null "$OAUTH/users" -H "Authorization: Bearer $token" || true
    curl -s --max-time 10 -o /dev/null "$OAUTH/roles" -H "Authorization: Bearer $token" || true
    login "$DEMO_USER" wrong-password -o /dev/null || true
    sleep 1
  done
}

traffic_pid=''
stop_traffic() {
  if [ -n "$traffic_pid" ]; then
    kill "$traffic_pid" 2>/dev/null || true
    traffic_pid=''
  fi
}
trap stop_traffic EXIT
trap 'exit 130' INT TERM

# 0. Preflight -----------------------------------------------------------------
for tool in docker curl jq; do
  command -v "$tool" >/dev/null || die "Missing required tool: $tool"
done
docker info >/dev/null 2>&1 || die "Docker isn't running. Start Docker Desktop and try again."

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi
for volume in constrsw-keycloak-data constrsw-prometheus-data; do
  docker volume inspect "$volume" >/dev/null 2>&1 || run docker volume create "$volume"
done

# 1. Stack ---------------------------------------------------------------------
step "Step 1 of 8: Starting the stack" \
  "Builds the images and starts every container. --wait returns once Keycloak" \
  "and oauth report healthy (oauth only starts after Keycloak is up)."
run docker compose up -d --build --wait
echo
run docker compose ps --format 'table {{.Service}}\t{{.Status}}'

# 2. Keycloak ------------------------------------------------------------------
step "Step 2 of 8: Checking Keycloak" \
  "Identity provider. oauth talks to it over the Docker network; its health" \
  "and metrics are published on port 9001."
printf '%s$ curl %s/health/ready%s\n' "$dim" "$KEYCLOAK_MANAGEMENT" "$reset"
curl -s --max-time 10 "$KEYCLOAK_MANAGEMENT/health/ready" | jq .
cat <<EOF

Realm ${bold}constrsw${reset}, test users (password a12345678):
  admin@pucrs.br         administrator
  coordinator@pucrs.br   coordinator
  professor@pucrs.br     professor
  student@pucrs.br       student
EOF

# 3. Login ---------------------------------------------------------------------
step "Step 3 of 8: Logging in through oauth" \
  "oauth exchanges the credentials with Keycloak and returns its JWT. After" \
  "that, background traffic starts so the metrics have something to show."
printf '%s$ curl -X POST %s/login -F username=%s -F password=%s%s\n' \
  "$dim" "$OAUTH" "$DEMO_USER" "$DEMO_PASSWORD" "$reset"
response=$(login "$DEMO_USER" "$DEMO_PASSWORD" -w '\n%{http_code}')
status=${response##*$'\n'}
body=${response%$'\n'*}
echo "HTTP $status"
[ "$status" = 201 ] || die "Login failed: $body"

token=$(jq -r .access_token <<<"$body")
jq '{token_type, expires_in, access_token}' <<<"$body"
echo
echo "Claims inside the access token:"
jq -R 'split(".")[1] | gsub("-"; "+") | gsub("_"; "/") | @base64d | fromjson
  | {preferred_username, email, realm_roles: .realm_access.roles, expires_at: (.exp | todate)}' <<<"$token"

if command -v pbcopy >/dev/null; then
  printf '%s' "$token" | pbcopy
  echo
  echo "Access token copied to the clipboard."
fi

send_traffic &
traffic_pid=$!
echo "Started background traffic (login, /users, /roles, wrong-password login every second)."

# 4. Swagger -------------------------------------------------------------------
step "Step 4 of 8: Opening Swagger" \
  "Interactive API docs. Click Authorize, paste the token from the clipboard" \
  "into bearer, then go through the examples below in order."
open_url "$OAUTH/docs"
echo
echo "{userId} and {roleId} are the ids returned by examples 3 and 8."

section "Health"
example GET /health "" '200 {"status":"ok","service":"oauth"}'

section "Users (Keycloak checks the admin token)"
example GET /users "" "200, the four test users"
example POST /users \
  "{\"username\": \"$NEW_USER\", \"first-name\": \"Aluno\", \"last-name\": \"Demo\", \"password\": \"a12345678\"}" \
  "201, copy the id: it's {userId}. Send it again: 409, username taken"
example GET "/users/{userId}" "" "200, the new user"
example PATCH "/users/{userId}" '{"first-name": "Aluna"}' "200, changes only first-name"
example PUT "/users/{userId}" \
  "{\"username\": \"$NEW_USER\", \"first-name\": \"Aluna\", \"last-name\": \"Demonstração\"}" \
  "200, replaces the whole user (the password only changes through PATCH)"

section "Roles"
example GET /roles "" "200, the realm roles"
example POST /roles "{\"name\": \"$NEW_ROLE\", \"description\": \"Monitor de disciplina\"}" \
  "201, copy the id: it's {roleId}"
example GET "/roles/{roleId}" "" "200, the new role"
example PATCH "/roles/{roleId}" '{"description": "Monitor de laboratório"}' "200, changes only the description"
example PUT "/roles/{roleId}" "{\"name\": \"$NEW_ROLE\", \"description\": \"Monitor de disciplina\"}" \
  "200, replaces name and description"
example POST "/roles/{roleId}/users/{userId}" "" "204, the new user now has the role"

section "Auth"
example POST /login "{\"username\": \"$NEW_USER\", \"password\": \"a12345678\"}" \
  "201, the new token carries $NEW_ROLE. Wrong password: 401"
example POST /refresh "" "201, new tokens from the session cookie that /login set"

section "Clean up (deletes are logical)"
example DELETE "/roles/{roleId}/users/{userId}" "" "204, the role is removed from the user"
example DELETE "/roles/{roleId}" "" "204, hidden from GET /roles but kept in Keycloak"
example DELETE "/users/{userId}" "" "204, user disabled: GET /users with enabled=false lists it"
example POST /logout "" "201, clears the session cookie"

# 5. Raw metrics ---------------------------------------------------------------
step "Step 5 of 8: Reading the oauth metrics" \
  "Prometheus text format, exposed by prom-client. Request counts by route and" \
  "status, plus calls to Keycloak by operation and result."
printf '%s$ curl %s/metrics | grep …%s\n' "$dim" "$OAUTH" "$reset"
curl -s --max-time 10 "$OAUTH/metrics" \
  | grep -E '^(http_server_requests_seconds_count|oauth_keycloak_request_duration_seconds_count)' \
  | head -n 12 || true
open_url "$OAUTH/metrics"

# 6. Prometheus targets --------------------------------------------------------
step "Step 6 of 8: Opening the Prometheus targets" \
  "Prometheus scrapes oauth every 10s and Keycloak every 30s, and probes" \
  "their health endpoints through the blackbox exporter."
open_url "$PROMETHEUS/targets"

# 7. Prometheus queries --------------------------------------------------------
step "Step 7 of 8: Querying oauth in Prometheus" \
  "Targets up, oauth requests/s, p95 latency and oauth → Keycloak calls by result."
open_url "$PROMETHEUS_QUERIES"

# 8. Grafana -------------------------------------------------------------------
step "Step 8 of 8: Opening the Grafana dashboards" \
  "Provisioned dashboards, refreshing every 10s. No login needed to view."
open_url "$GRAFANA/d/constrsw-oauth"
open_url "$GRAFANA/d/constrsw-overview"

# Wrap-up ----------------------------------------------------------------------
step "Done: stopping the traffic" \
  "Background traffic is still running so the graphs keep moving. Press Enter" \
  "when you're finished to stop it. The stack keeps running."
stop_traffic
echo "Traffic stopped. Stop the stack with: docker compose down"
