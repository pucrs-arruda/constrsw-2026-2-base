#!/bin/sh
set -eu

# Runs on an empty data volume. Creates the professors role and database
# that the professors API expects. Other services keep their own init scripts.
psql --no-psqlrc --set=ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'SQL'
\getenv professors_user PROFESSORS_USERNAME
\getenv professors_password PROFESSORS_PASSWORD
\getenv professors_db PROFESSORS_DB

SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'professors_user', :'professors_password')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'professors_user') \gexec

SELECT format('CREATE DATABASE %I OWNER %I', :'professors_db', :'professors_user')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'professors_db') \gexec
SQL
