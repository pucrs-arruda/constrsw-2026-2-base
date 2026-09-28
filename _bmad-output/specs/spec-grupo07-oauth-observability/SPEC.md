---
id: SPEC-grupo07-oauth-observability
companions:
  - scrape-contract.md
  - architecture-diagrams.md
  - ../../planning-artifacts/architecture/architecture-constrsw-2026-2-2026-09-21/ARCHITECTURE-SPINE.md
sources:
  - ../../planning-artifacts/brief-grupo07-oauth-observability.md
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability only — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# Grupo 07 — oauth Prometheus metrics

## Why

**Mandate:** Professor commit `e201543` already runs Prometheus, an OpenTelemetry collector, and Blackbox, and the oauth compose service already publishes a metrics port that the process does not serve. Grupo 07 needs that process to show up as a live Prometheus target. The T1 identity API in `spec-grupo07-keycloak-oauth` stays the contract for login, users, roles, and authz.

## Capabilities

- **CAP-1**
  - **intent:** The oauth process exposes Prometheus text on its metrics port.
  - **success:** A GET of `/metrics` on `OAUTH_INTERNAL_METRICS_PORT` returns HTTP 200 and a Prometheus text body.

- **CAP-2**
  - **intent:** An HTTP call to the oauth API increases an HTTP server metric.
  - **success:** After one `GET /health`, the `/metrics` body contains a series whose name starts with `http_server_request_duration` or `http_server_duration`.

- **CAP-3**
  - **intent:** Metric labels and samples do not carry credentials.
  - **success:** After a login attempt, the `/metrics` body does not contain the password, the access token, the client secret, or the `Authorization` header value.

- **CAP-4**
  - **intent:** Login and health keep the T1 HTTP contracts while metrics are on.
  - **success:** `GET /health` still returns a body with status ok, and a successful `POST /login` still returns `200` with the token fields defined in `spec-grupo07-keycloak-oauth`.

## Constraints

- Read `OAUTH_INTERNAL_METRICS_PORT` and `OAUTH_INTERNAL_API_PORT`. Do not invent environment names, compose services, or `.env` keys.
- The metrics listener binds `0.0.0.0`. The Prometheus exporter is the only socket on that port. Path is `/metrics`.
- Start one OpenTelemetry SDK before `NestFactory.create`. Instrument HTTP only. Do not export OTLP. Resource `service.name` is `oauth`.
- Package floor: `@opentelemetry/exporter-prometheus` and `@opentelemetry/sdk-node` at 0.217.0 or newer (CVE-2026-44902). Pins and the rest of the rules are the adopted spine.
- The only professor-file edit is the scrape retarget in `scrape-contract.md`.
- Telemetry code lives in submodule `backend/oauth`. This spec is a sibling of `spec-grupo07-keycloak-oauth`. Do not change that spec's capability IDs or route contracts.

## Non-goals

- Grafana dashboards, Prometheus alert edits, and recording-rule edits.
- OTLP traces or logs, and any change to the OpenTelemetry collector config.
- Metrics for course services other than oauth.
- Business counters beyond HTTP server instrumentation.
- Rewriting the OA error body or the T1 routes.

## Success signal

With external volume `constrsw-prometheus-data` created and the professor compose up, Prometheus shows the oauth scrape target up, `/metrics` returns Prometheus text, `GET /health` stays ok, and a successful `POST /login` still returns `200`.

## Assumptions

- The HTTP series name is in the `http_server_request_duration` or `http_server_duration` family. CAP-2 accepts either prefix.
- Professor `.env` keeps `OAUTH_INTERNAL_METRICS_PORT=9464` and `OAUTH_INTERNAL_API_PORT=3001`.
