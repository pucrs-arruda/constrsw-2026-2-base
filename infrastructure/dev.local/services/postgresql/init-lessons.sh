#!/bin/sh
set -eu

# PostgreSQL's image runs this on an empty volume. The same script can be
# invoked in a running container to provision Lessons on an existing volume.
psql --no-psqlrc --set=ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'SQL'
\getenv lessons_user LESSONS_USERNAME
\getenv lessons_password LESSONS_PASSWORD
\getenv lessons_db LESSONS_DB

SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'lessons_user', :'lessons_password')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'lessons_user') \gexec

SELECT format('CREATE DATABASE %I OWNER %I', :'lessons_db', :'lessons_user')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'lessons_db') \gexec
SQL
