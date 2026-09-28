---
baseline_commit: bd45a4a8b37e96359a58a73d4ad817106d1623c9
---

# Story 7.1: Expose oauth Prometheus metrics

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a group developer,
I want the oauth process to expose Prometheus text on the professor metrics port,
so that the professor Prometheus scrape can see oauth without changing login, users, roles, or authz.

## Acceptance Criteria

1. **Given** `OAUTH_INTERNAL_METRICS_PORT` (default 9464)
   **When** the process starts
   **Then** `GET /metrics` on `0.0.0.0` and that port returns HTTP 200 and a Prometheus text body (`# HELP` or `# TYPE`)
   **And** that listener is the OpenTelemetry Prometheus exporter, not a Nest route

2. **Given** the SDK is running
   **When** the API handles one `GET /health`
   **Then** the `/metrics` body contains a series whose name starts with `http_server_request_duration` or `http_server_duration`

3. **Given** a login attempt and a request whose `Authorization` header, password, and client secret are distinctive sentinels
   **When** `/metrics` is scraped
   **Then** the body does not contain those sentinels

4. **Given** the existing T1 routes
   **When** this story is done
   **Then** `GET /health` still returns `{ status: 'ok' }`
   **And** login, refresh, users, roles, authz, and the OA error filter are unchanged
   **And** existing Jest suites still pass

5. **Given** `infrastructure/dev.local/services/prometheus/prometheus.yml`
   **When** this story is done
   **Then** the NestJS job is `job_name: 'oauth'`, target `oauth:9464`, path `/metrics`
   **And** the blackbox list uses `http://oauth:3001/health` instead of `http://auth:3001/health`
   **And** no other job, `docker-compose.yml`, or `.env` line changes

## Tasks / Subtasks

- [x] Task 1 — Pin the SDK in `backend/oauth` (AC: #1)
  - [x] Install exact versions: `@opentelemetry/api@1.9.1`, `@opentelemetry/sdk-node@0.221.0`, `@opentelemetry/exporter-prometheus@0.221.0`, `@opentelemetry/instrumentation-http@0.221.0`
  - [x] Do not install `@opentelemetry/auto-instrumentations-node`, `prom-client`, or any `exporter-trace-otlp-*` / `exporter-metrics-otlp-*` package
  - [x] Do not upgrade `sdk-node` to 0.222.0. Stay on the 0.221.0 line (CVE-2026-44902 is fixed at >= 0.217.0)
- [x] Task 2 — One metrics port reader (AC: #1)
  - [x] Add `internalMetricsPort` to `OAuthServiceSettings` in `src/config/keycloak.config.ts`, using the existing `port()` helper, env name `OAUTH_INTERNAL_METRICS_PORT`, default `9464`
  - [x] Export a function that reads only that port (it must not call `buildAppConfig`, which requires `KEYCLOAK_SERVER_URL` and `KEYCLOAK_CLIENT_SECRET`)
  - [x] Add a `internalMetricsPort` getter on `KeycloakSettingsService` next to `internalApiPort`
  - [x] Extend `keycloak.config.spec.ts` with the same default / numeric / invalid cases already used for `OAUTH_INTERNAL_API_PORT`
- [x] Task 3 — Start the SDK before Nest (AC: #1, #2)
  - [x] Add `src/telemetry/register.ts`. It imports no Nest module. It starts one `NodeSDK` with `serviceName: 'oauth'`, `metricReader: new PrometheusExporter({ host: '0.0.0.0', port })`, and `instrumentations: [new HttpInstrumentation()]`
  - [x] Do not set `traceExporter`. Do not set `OTEL_EXPORTER_OTLP_*`. Do not pass `headersToSpanAttributes` for `authorization` or any credential header
  - [x] `src/main.ts` first import is `./telemetry/register`, and `startTelemetry()` runs before `NestFactory.create`. The API listen stays `settings.internalApiPort` on `0.0.0.0`
  - [x] Export `stopTelemetry()` and call it on `SIGTERM` after `sdk.shutdown()`
  - [x] Do not start the SDK from `AppModule`, a provider, or `onModuleInit`. Existing specs import `AppModule` statically; a listener there binds the port in every suite
- [x] Task 4 — Metrics Jest spec (AC: #1, #2, #3, #4)
  - [x] New spec, not an edit of `health.controller.spec.ts`. Set `OAUTH_INTERNAL_METRICS_PORT` to `19464` before the telemetry module loads. Use a dynamic `import()` of the register module and of `AppModule` after that env write. A static import is too late: TypeScript hoists it and loads `http` before the SDK
  - [x] `GET /health` on the Nest server still expects `{ status: 'ok' }`
  - [x] `GET http://127.0.0.1:19464/metrics` expects 200, a `# HELP` or `# TYPE` line, and an `http_server_request_duration` or `http_server_duration` series
  - [x] Plant sentinels `pw-sentinel-do-not-leak`, `client-secret-sentinel-do-not-leak`, and `Bearer access-token-sentinel-do-not-leak`. Assert none appear in the metrics body
  - [x] `afterAll`: `stopTelemetry()` so the port is released
- [x] Task 5 — Image and scrape retarget (AC: #1, #5)
  - [x] `backend/oauth/Dockerfile`: `EXPOSE 9464` beside `3001`. `CMD` stays `node dist/main` because the register import lives in `main.ts`
  - [x] Parent repo only: edit the two spots in `infrastructure/dev.local/services/prometheus/prometheus.yml` described in the scrape contract. Do not touch compose, `.env`, the collector, alerts, or other jobs
- [x] Task 6 — Regression
  - [x] `npm test` in `backend/oauth` passes, including the existing health, login, users, roles, and authz specs
  - [x] Do not edit those controllers, the OA filter, or the bearer guard

## Dev Notes

### Why the SDK cannot live in the Nest module

`PrometheusExporter` opens its own HTTP server. `HttpInstrumentation` patches `http` when the SDK starts. `src/main.ts` currently imports `NestFactory` at the top, which loads `http` immediately. If the SDK starts inside `bootstrap()` after that import, or inside `AppModule`, two failures follow:

- HTTP metrics never see the Nest server (CAP-2 fails).
- Every existing spec that imports `AppModule` tries to bind the metrics port (suites collide or hang).

`src/telemetry/register.ts` must not import `./app.module`, `./config/keycloak-settings.service`, or anything under `@nestjs/*`. It may import `keycloak.config.ts`, which is plain TypeScript. Read the port through the new helper, not through `KeycloakSettingsService` (that service does not exist until DI starts).

`main.ts` shape:

```ts
import { startTelemetry, stopTelemetry } from './telemetry/register';

void startTelemetry();

import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
```

If the compiler rejects an import after a statement, keep `startTelemetry()` in `register.ts` at module scope and make `import './telemetry/register'` the first line of `main.ts`, with the port read from `process.env` inside that module. Do not move the start call below the Nest imports.

The metrics spec cannot use a top-level `import { AppModule }`. Set the env, then `await import('./telemetry/register')`, then `await import('../app.module')`.

### Current files

| Path | Action | Preserve |
| --- | --- | --- |
| `backend/oauth/package.json` | UPDATE | Nest 11, Jest 29, `testRegex` `.*\\.spec.ts$` |
| `backend/oauth/package-lock.json` | UPDATE | lockfile from the exact installs above |
| `backend/oauth/src/config/keycloak.config.ts` | UPDATE | `port()`, required Keycloak vars, no new env names |
| `backend/oauth/src/config/keycloak.config.spec.ts` | UPDATE | existing cases stay |
| `backend/oauth/src/config/keycloak-settings.service.ts` | UPDATE | existing getters stay |
| `backend/oauth/src/telemetry/register.ts` | NEW | no Nest imports |
| `backend/oauth/src/main.ts` | UPDATE | listen address `0.0.0.0` and `internalApiPort`; OA filter stays registered in `AppModule` |
| `backend/oauth/src/telemetry/register.spec.ts` (name flexible) | NEW | dynamic import, port 19464, `stopTelemetry` in `afterAll` |
| `backend/oauth/Dockerfile` | UPDATE | `CMD ["node", "dist/main"]`, `EXPOSE 3001` |
| `backend/oauth/src/health/health.controller.ts` | DO NOT TOUCH | `{ status: 'ok' }` |
| `backend/oauth/src/health/health.controller.spec.ts` | DO NOT TOUCH | static `AppModule` import, no metrics server |
| `backend/oauth/src/app.module.ts` | DO NOT TOUCH | no telemetry provider |
| Auth, users, roles, authz, `src/errors/**` | DO NOT TOUCH | token redaction from oauth commit `8c5c06e` stays |
| Root `docker-compose.yml`, root `.env` | DO NOT TOUCH | metrics port `9464` and host port `8381` are already published |
| `infrastructure/dev.local/services/otel-collector/**` | DO NOT TOUCH | traces and logs stay on the debug exporter |
| `infrastructure/dev.local/services/prometheus/prometheus.yml` | UPDATE | only the NestJS job and the one blackbox URL |

### Scrape edit (parent repo, not the submodule)

Replace the job at `prometheus.yml` lines 22–27:

```yaml
  # oauth (NestJS — OpenTelemetry Prometheus exporter)
  - job_name: 'oauth'
    static_configs:
      - targets: ['oauth:9464']
    metrics_path: '/metrics'
    scrape_interval: 10s
```

In job `health-checks`, replace `http://auth:3001/health` with `http://oauth:3001/health`. Leave `http://keycloak:9001/health/ready` and every other target.

### Out of scope

- Grafana, alert edits, recording rules, collector config, OTLP push
- A Nest `GET /metrics` controller (the OA filter and bearer guard would wrap it)
- Custom counters beyond what `HttpInstrumentation` emits
- Live `POST /login` against Keycloak. CAP-4 is satisfied by leaving login code alone and keeping the existing login specs green
- `docker compose up`. Volume `constrsw-prometheus-data` is an ops step for a human demo, not a unit-test task
- Editing `_bmad-output/specs/**` or the architecture spine

### Testing

- Runner: Jest 29, `ts-jest`, `supertest`, `rootDir` `src`, pattern `.*\\.spec.ts$`. No new runner.
- Health regression stays in `health.controller.spec.ts`. Do not point it at port 9464.
- Metrics assertions hit `127.0.0.1:19464` with `fetch` or `http.get`, not `supertest` against the Nest server.
- Series prefix is either `http_server_request_duration` or `http_server_duration`. Accept either. Do not assert one exact name.
- Sentinels must be long and unique. Do not assert that the word `ok` or `secret` is absent.

### Previous work to keep

- Oauth commit `8c5c06e` redacts tokens in error logs. Do not log the metrics body, `Authorization`, passwords, or `KEYCLOAK_CLIENT_SECRET`.
- Oauth commit `a31f573` reads client roles from the JWT after UserInfo. Do not change `bearer-auth.guard.ts`.
- Parent commit `889e6ef` merged Prometheus. Compose already maps `OAUTH_EXTERNAL_METRICS_PORT` to `OAUTH_INTERNAL_METRICS_PORT`. This story fills the process and retargets the scrape from `auth` to `oauth`.
- Story 1.3 already verified compose health on the API port. Do not change that healthcheck.

### References

- [Source: `_bmad-output/specs/spec-grupo07-oauth-observability/SPEC.md`] CAP-1..4, constraints, non-goals
- [Source: `_bmad-output/specs/spec-grupo07-oauth-observability/scrape-contract.md`]
- [Source: `_bmad-output/planning-artifacts/architecture/architecture-constrsw-2026-2-2026-09-21/ARCHITECTURE-SPINE.md`] AD-1..AD-7, stack pins
- [Source: `backend/oauth/src/main.ts`] current listen
- [Source: `backend/oauth/src/config/keycloak.config.ts`] `port()` and `OAUTH_INTERNAL_API_PORT`
- npm 2026-09-21: `@opentelemetry/exporter-prometheus` 0.221.0 default port 9464 and path `/metrics`. Versions below 0.217.0 crash the process on a malformed scrape (CVE-2026-44902).

## Dev Agent Record

### Agent Model Used

Grok 4.7

### Debug Log References

- Jest could not see HTTP metrics until `http.Server` was patched on the module Nest actually uses. `@opentelemetry/sdk-node` loads `http` as soon as it is imported, so `src/telemetry/instrument.ts` patches `http` and `https` before that import.
- NodeSDK 0.221.0 defaults to an OTLP trace and log exporter when those options are omitted. `spanProcessors` and `logRecordProcessors` are empty arrays so nothing is pushed.
- The SDK deprecates `metricReader` in favor of `metricReaders`. The Prometheus exporter is the only reader.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- Oauth listens for Prometheus scrapes on `OAUTH_INTERNAL_METRICS_PORT` (default 9464, path `/metrics`) via the OpenTelemetry Prometheus exporter. `service.name` is `oauth`.
- HTTP instrumentation starts before Nest. `GET /health` still returns `{ status: "ok" }`. A scrape after that call includes an `http_server_request_duration` series. Password, client secret, and bearer token sentinels are absent from the text.
- Professor `prometheus.yml` job is `oauth` targeting `oauth:9464`. The blackbox health URL is `http://oauth:3001/health`. Compose and `.env` were not edited.
- `npm test` in `backend/oauth`: 24 suites, 269 tests, all passed. `nest build` succeeded.

### File List

- backend/oauth/package.json
- backend/oauth/package-lock.json
- backend/oauth/Dockerfile
- backend/oauth/src/main.ts
- backend/oauth/src/config/keycloak.config.ts
- backend/oauth/src/config/keycloak.config.spec.ts
- backend/oauth/src/config/keycloak-settings.service.ts
- backend/oauth/src/telemetry/instrument.ts
- backend/oauth/src/telemetry/register.ts
- backend/oauth/src/telemetry/register.spec.ts
- infrastructure/dev.local/services/prometheus/prometheus.yml

## Change Log

- 2026-09-21: Expose oauth Prometheus metrics on the professor metrics port and retarget the scrape from `auth` to `oauth`.
