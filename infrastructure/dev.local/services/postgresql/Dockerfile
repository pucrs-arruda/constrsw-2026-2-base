FROM postgres:17-alpine

ARG POSTGRESQL_HOST_AUTH_METHOD
ARG POSTGRESQL_DATA
ARG POSTGRESQL_USERNAME
ARG POSTGRESQL_PASSWORD

# Configurar variáveis de ambiente do PostgreSQL
ENV POSTGRES_HOST_AUTH_METHOD=${POSTGRESQL_HOST_AUTH_METHOD}
ENV PGDATA=${POSTGRESQL_DATA}
ENV PGUSER=${POSTGRESQL_USERNAME}
ENV POSTGRES_USER=${POSTGRESQL_USERNAME}
ENV POSTGRES_PASSWORD=${POSTGRESQL_PASSWORD}

WORKDIR /docker-entrypoint-initdb.d/

# Scripts para criar os databases das APIs de backend
COPY databases.sql /docker-entrypoint-initdb.d/
COPY init-postgres.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/init-postgres.sh
