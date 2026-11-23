#!/usr/bin/env bash
set -euo pipefail

sudo service docker start

ready=0
for _ in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done

if [ "$ready" -ne 1 ]; then
  echo "O daemon do Docker nao ficou pronto." >&2
  exit 1
fi

for volume in \
  constrsw-prometheus-data \
  constrsw-keycloak-data \
  constrsw-postgresql-data \
  constrsw-mongodb-data
do
  docker volume create "$volume" >/dev/null
done
