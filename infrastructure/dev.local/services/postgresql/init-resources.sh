#!/bin/sh
set -eu

# PostgreSQL's image runs this on an empty volume. It creates the Resources
# role/database and applies the module's DDL + seed (mounted at /resources-init).
psql --no-psqlrc --set=ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${POSTGRES_DB:-$POSTGRES_USER}" <<'SQL'
\getenv resources_user RESOURCES_USERNAME
\getenv resources_password RESOURCES_PASSWORD
\getenv resources_db RESOURCES_DB

SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'resources_user', :'resources_password')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'resources_user') \gexec

SELECT format('CREATE DATABASE %I OWNER %I', :'resources_db', :'resources_user')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'resources_db') \gexec
SQL

for f in /resources-init/*.sql; do
  [ -f "$f" ] || continue
  PGPASSWORD="$RESOURCES_PASSWORD" psql --no-psqlrc --set=ON_ERROR_STOP=1 \
    --username "$RESOURCES_USERNAME" --dbname "$RESOURCES_DB" -f "$f"
done
