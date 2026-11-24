#!/usr/bin/env bash
# Renderiza o mockup responsivo nas larguras dos frames Figma (compact 360, medium 768, expanded 1280).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
html="$here/../mockups/closed-cras-responsivo.html"
out="$here/qa/responsive"
mkdir -p "$out"
chrome="${CHROME:-$(command -v google-chrome-stable || command -v chromium || command -v google-chrome)}"
profile="$(mktemp -d)"
trap 'rm -rf "$profile"' EXIT

routes=(
  "login|#/login"
  "login-401|#/login?erro=401"
  "home-nav|#/home?nav=open"
  "salas|#/salas"
  "salas-dialog|#/salas?dialog=nova"
  "sala-detalhe|#/salas/b201"
  "turma-alunos|#/turmas/se-a?aba=alunos"
  "turma-aulas|#/turmas/se-a?aba=aulas"
  "turma-reservas|#/turmas/se-a?aba=reservas"
  "alunos-503|#/alunos?erro=503"
)
sizes=("compact|360,800" "medium|768,1024" "expanded|1280,800")

for r in "${routes[@]}"; do
  name="${r%%|*}"; hash="${r#*|}"
  for s in "${sizes[@]}"; do
    cls="${s%%|*}"; wh="${s#*|}"
    timeout 60 "$chrome" --headless=new --disable-gpu --no-sandbox --hide-scrollbars \
      --user-data-dir="$profile" --no-first-run \
      --force-device-scale-factor=1 --virtual-time-budget=6000 \
      --window-size="$wh" --screenshot="$out/${name}-${cls}.png" \
      "file://$html$hash" >/dev/null 2>&1
  done
done
ls "$out"
