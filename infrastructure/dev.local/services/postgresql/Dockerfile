FROM postgres:16-alpine
ARG POSTGRESQL_HOST_AUTH_METHOD
ARG POSTGRESQL_DATA
ARG POSTGRESQL_USERNAME
ARG POSTGRESQL_PASSWORD
COPY --chmod=755 init-professors.sh /docker-entrypoint-initdb.d/30-init-professors.sh
