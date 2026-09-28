# Brief — Grupo 07 oauth observability

**Author:** Mary (business analyst)  
**Date:** 2026-09-21  
**Audience:** Winston (architecture spine), then bmad-spec  
**Scope:** NestJS `oauth` only, against the professor Prometheus and OpenTelemetry stack already on `main`

## Mandate

Professor commit `e201543` turned on Prometheus, an OpenTelemetry collector, and Blackbox. Grupo 07 must make the oauth process visible to that stack. The T1 identity contract stays in force. This brief does not choose an exporter, a hostname, or a package version.

## Evidence

- `docker-compose.yml` service `oauth` publishes `OAUTH_EXTERNAL_METRICS_PORT` to `OAUTH_INTERNAL_METRICS_PORT`. `.env` sets that internal port to `9464` and the host port to `8381`. `backend/oauth/src/main.ts` listens only on `OAUTH_INTERNAL_API_PORT` (`3001`). Nothing binds `9464`.
- `backend/oauth/package.json` has no OpenTelemetry dependency. `backend/oauth/src/config/keycloak.config.ts` reads `OAUTH_INTERNAL_API_PORT` and does not read `OAUTH_INTERNAL_METRICS_PORT`.
- `infrastructure/dev.local/services/prometheus/prometheus.yml` job `auth` scrapes `auth:9464` at `/metrics` and is commented as a NestJS OpenTelemetry Prometheus exporter. The compose service and container name are `oauth`, not `auth`. The blackbox job probes `http://auth:3001/health`. `GET /health` on the API returns `{ status: "ok" }`.
- `infrastructure/dev.local/services/otel-collector/otel-collector-config.yml` receives OTLP on `4317` (gRPC) and `4318` (HTTP). The metrics pipeline exports Prometheus text on `8889`. The traces and logs pipelines export only to `debug`.
- Prometheus data volume `constrsw-prometheus-data` is `external: true`.
- `_bmad-output/specs/spec-grupo07-keycloak-oauth/SPEC.md` non-goals still list Prometheus. A sibling spec must own this work. T1 capability IDs stay stable. Login, users, roles, authz, the OA error body, and `GET /health` are not redesigned.
- Compose and `.env` stay professor-owned. This brief does not invent new variable names or services.

## Forks the spec must close

1. **Pull versus push.** Scrape Prometheus text from oauth on port `9464` path `/metrics`, or push OTLP to `otel-collector:4317` and rely on the collector's `:8889` export.
2. **Scrape hostname.** Leave the job on `auth`, or retarget the oauth scrape and the oauth health probe to the service name `oauth`. Any other edit to professor Prometheus files is out of this brief.
3. **Traces and logs.** In scope, or out of scope, given the collector does not store them.
4. **Redaction.** Whether access tokens, passwords, client secrets, and the `Authorization` header may appear as metric labels or metric values.

## Inherited constraints

- Implement telemetry in the `backend/oauth` submodule on the group branch.
- Use the professor names `OAUTH_INTERNAL_METRICS_PORT` and `OAUTH_INTERNAL_API_PORT`.
- Do not change the T1 route contracts to make metrics easier to collect.

## Not in this brief

Package versions, bootstrap order, Grafana, other course services, and collector storage changes. Those wait for the spine or are out of scope.
